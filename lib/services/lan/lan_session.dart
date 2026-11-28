import 'package:stockall/classes/lan/lan_server_session.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';

/// Issues and checks LAN server sessions. The token itself is only ever
/// held by the client; the server stores its SHA-256.
class LanSessionManager {
  LanSessionManager({DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final DateTime Function() _clock;

  /// A new session for [userId] on [deviceId]. Replaces that device's
  /// previous sessions for the user.
  Future<({String token, LanServerSession session})> create({
    required int shopId,
    required String userId,
    required String deviceId,
  }) async {
    await LanServerSessionsFunc().deleteForDevice(
      shopId: shopId,
      userId: userId,
      deviceId: deviceId,
    );
    final token = newSessionToken();
    final now = _clock();
    final session = LanServerSession(
      tokenHash: hashSessionToken(token),
      shopId: shopId,
      userId: userId,
      deviceId: deviceId,
      createdAt: now,
      expiresAt: now.add(LanConstants.sessionTtl),
      lastUsedAt: now,
    );
    await LanServerSessionsFunc().put(session);
    return (token: token, session: session);
  }

  /// The live session for [token], sent from [deviceId], for [shopId]; or
  /// null. Expired sessions are deleted. A used session's expiry slides
  /// forward, written at most once per [LanConstants.sessionTouchEvery].
  Future<LanServerSession?> resolve({
    required String? token,
    required String? deviceId,
    required int shopId,
  }) async {
    if (token == null || token.isEmpty) return null;
    if (deviceId == null || deviceId.isEmpty) return null;
    final session = LanServerSessionsFunc().get(hashSessionToken(token));
    if (session == null) return null;
    final now = _clock();
    if (session.isExpired(now)) {
      await LanServerSessionsFunc().delete(session.tokenHash);
      return null;
    }
    if (session.deviceId != deviceId || session.shopId != shopId) return null;
    if (now.difference(session.lastUsedAt) >= LanConstants.sessionTouchEvery) {
      final touched = session.touched(now, LanConstants.sessionTtl);
      await LanServerSessionsFunc().put(touched);
      return touched;
    }
    return session;
  }

  Future<void> revoke(String token) async {
    await LanServerSessionsFunc().delete(hashSessionToken(token));
  }
}
