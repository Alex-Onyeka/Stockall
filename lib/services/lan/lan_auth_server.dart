import 'package:flutter/foundation.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_password_hash.dart';
import 'package:stockall/services/lan/lan_session.dart';

/// An HTTP status and JSON body for `LanServer` to send.
class LanAuthResponse {
  const LanAuthResponse(this.status, this.body);
  final int status;
  final Map<String, dynamic> body;
}

/// The LAN server's login, logout, password check and session lookup, for
/// the one shop it serves. No HTTP here: `LanServer` routes to it.
class LanAuthService {
  LanAuthService({
    required this.shopId,
    Map<String, dynamic>? Function(int shopId)? shopJson,
    DateTime Function()? clock,
    this.maxTrackedKeys = 1000,
  }) : _clock = clock ?? (() => DateTime.now().toUtc()),
       _shopJson = shopJson ?? _storedShopJson,
       sessions = LanSessionManager(clock: clock);

  /// The shop this server serves right now.
  final int Function() shopId;
  final LanSessionManager sessions;
  final DateTime Function() _clock;
  final Map<String, dynamic>? Function(int shopId) _shopJson;

  final Map<String, List<DateTime>> _failures = {};
  final Map<String, List<DateTime>> _attemptsByAddress = {};

  /// Keys kept per log at most: past it, expired keys go, then the oldest.
  final int maxTrackedKeys;

  @visibleForTesting
  int get trackedFailureKeys => _failures.length;

  @visibleForTesting
  int get trackedAddresses => _attemptsByAddress.length;

  static Map<String, dynamic>? _storedShopJson(int shopId) {
    try {
      final shop = ShopFunc().shopBox.get(shopId);
      if (shop == null) return null;
      // `toJson` leaves out shop_id; the client needs it.
      return {...shop.toJson(), 'shop_id': shop.shopId};
    } catch (_) {
      return null;
    }
  }

  /// `POST /v1/auth/login {email, password, device_id}`.
  Future<LanAuthResponse> login(
    Map<String, dynamic> body, {
    required String remoteAddress,
  }) async {
    final email = _text(body, 'email')?.trim().toLowerCase();
    final password = _text(body, 'password');
    final deviceId = _text(body, 'device_id');
    if (email == null || password == null || deviceId == null) {
      return const LanAuthResponse(400, {'error': 'bad_request'});
    }
    final now = _clock();
    final limited = _limited(
          _attemptsByAddress,
          remoteAddress,
          LanConstants.loginAttemptsPerAddressPerMinute,
          const Duration(minutes: 1),
          now,
        ) ??
        _limited(
          _failures,
          'login:$email',
          LanConstants.loginFailuresPerEmail,
          LanConstants.loginFailureWindow,
          now,
        );
    if (limited != null) return _rateLimited(limited);
    _record(_attemptsByAddress, remoteAddress, now, const Duration(minutes: 1));

    final shop = shopId();
    final credential = LanCredentialsFunc().byEmail(shop, email);
    // Unknown emails are checked against a dummy hash so they take as long
    // as a wrong password.
    final matches = await verifyPassword(
      password,
      credential == null ? lanDummyPasswordHash : _hashOf(credential),
    );
    if (credential == null || !matches) {
      _record(_failures, 'login:$email', now, LanConstants.loginFailureWindow);
      return const LanAuthResponse(401, {'error': 'invalid_credentials'});
    }
    _failures.remove('login:$email');

    final created = await sessions.create(
      shopId: shop,
      userId: credential.userId,
      deviceId: deviceId,
    );
    return LanAuthResponse(200, {
      'token': created.token,
      'expires_at': created.session.expiresAt.toIso8601String(),
      'user': credential.profile(),
      'shop': _shopJson(shop),
      'shop_key': LanShopKeysFunc().get(shop),
    });
  }

  /// The signed-in member behind a request, or null. Membership is checked
  /// again on every request: a user dropped by the backfill has no
  /// credential, so their session stops working.
  Future<LanPrincipal?> principal({
    required String? token,
    required String? deviceId,
  }) async {
    final session = await sessions.resolve(
      token: token,
      deviceId: deviceId,
      shopId: shopId(),
    );
    if (session == null) return null;
    final credential = LanCredentialsFunc().get(
      session.shopId,
      session.userId,
    );
    if (credential == null) {
      await LanServerSessionsFunc().delete(session.tokenHash);
      return null;
    }
    return LanPrincipal.fromCredential(credential, deviceId: deviceId);
  }

  /// `POST /v1/auth/logout` (with a session).
  Future<LanAuthResponse> logout(String token) async {
    await sessions.revoke(token);
    return const LanAuthResponse(200, {'ok': true});
  }

  /// `POST /v1/auth/verify-password {password}` (with a session): the
  /// password re-entry before setting or clearing the server.
  Future<LanAuthResponse> verifyPasswordFor(
    LanPrincipal principal,
    Map<String, dynamic> body, {
    required String remoteAddress,
  }) async {
    final password = _text(body, 'password');
    if (password == null) {
      return const LanAuthResponse(400, {'error': 'bad_request'});
    }
    final now = _clock();
    final key = 'verify:${principal.shopId}:${principal.userId}';
    final limited = _limited(
          _attemptsByAddress,
          remoteAddress,
          LanConstants.loginAttemptsPerAddressPerMinute,
          const Duration(minutes: 1),
          now,
        ) ??
        _limited(
          _failures,
          key,
          LanConstants.loginFailuresPerEmail,
          LanConstants.loginFailureWindow,
          now,
        );
    if (limited != null) return _rateLimited(limited);
    _record(_attemptsByAddress, remoteAddress, now, const Duration(minutes: 1));

    final credential = LanCredentialsFunc().get(
      principal.shopId,
      principal.userId,
    );
    if (credential == null) {
      return const LanAuthResponse(401, {'error': 'session_invalid'});
    }
    if (!await verifyPassword(password, _hashOf(credential))) {
      _record(_failures, key, now, LanConstants.loginFailureWindow);
      return const LanAuthResponse(403, {'error': 'bad_password'});
    }
    _failures.remove(key);
    return const LanAuthResponse(200, {'ok': true});
  }

  LanPasswordHash _hashOf(LanUserCredential credential) {
    return LanPasswordHash(
      salt: credential.salt,
      hash: credential.hash,
      iterations: credential.iterations,
    );
  }

  LanAuthResponse _rateLimited(Duration retryAfter) {
    final seconds = retryAfter.inSeconds < 1 ? 1 : retryAfter.inSeconds;
    return LanAuthResponse(429, {
      'error': 'rate_limited',
      'retry_after': seconds,
    });
  }

  String? _text(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is! String || value.isEmpty || value.length > 256) return null;
    return value;
  }

  /// How long until [key] may try again, or null if it may now.
  Duration? _limited(
    Map<String, List<DateTime>> log,
    String key,
    int max,
    Duration window,
    DateTime now,
  ) {
    final entries = log[key];
    if (entries == null) return null;
    entries.removeWhere((t) => now.difference(t) >= window);
    if (entries.isEmpty) {
      log.remove(key);
      return null;
    }
    if (entries.length < max) return null;
    return window - now.difference(entries.first);
  }

  void _record(
    Map<String, List<DateTime>> log,
    String key,
    DateTime now,
    Duration window,
  ) {
    if (!log.containsKey(key) && log.length >= maxTrackedKeys) {
      // Expired first; then the keys whose last attempt is oldest.
      log.removeWhere((_, times) {
        times.removeWhere((t) => now.difference(t) >= window);
        return times.isEmpty;
      });
      if (log.length >= maxTrackedKeys) {
        final oldest = log.keys.toList()
          ..sort((a, b) => log[a]!.last.compareTo(log[b]!.last));
        for (final k in oldest.take(log.length - maxTrackedKeys + 1)) {
          log.remove(k);
        }
      }
    }
    (log[key] ??= []).add(now);
  }
}
