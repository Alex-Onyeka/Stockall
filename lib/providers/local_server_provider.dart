import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stockall/classes/lan/lan_client_session.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_held_deltas.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_password_hash.dart' as lan_hash;
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_transport.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum LocalServerChange {
  applied,
  refusedNotCleared,
  alreadyCleared,
  notDesktop,
  notNewer,
  liveServerFound,
  notAvailable,
  serverStartFailed,

  /// No staff credentials or shop key yet: be online once with the shop
  /// (and run the `shops.lan_key` migration).
  needsInternet,
}

/// What the sign-in does after a LAN login answered.
enum LanLoginStep {
  /// Signed in through the store server.
  signedIn,

  /// The store server refused the password and the cloud can't be asked:
  /// its answer is final.
  refused,
  rateLimited,

  /// The store server refused the password: its logins may be out of
  /// date, so the cloud decides (never the offline check).
  cloudOnly,

  /// No store server answered: the existing cloud or offline login.
  fallback,
}

LanLoginStep lanLoginStep(LanAuthResult result, {required bool interfaceUp}) =>
    switch (result) {
      LanAuthResult.ok => LanLoginStep.signedIn,
      LanAuthResult.rateLimited => LanLoginStep.rateLimited,
      LanAuthResult.invalidCredentials =>
        interfaceUp ? LanLoginStep.cloudOnly : LanLoginStep.refused,
      LanAuthResult.unreachable || LanAuthResult.failed => LanLoginStep.fallback,
    };

/// What following another server came to.
enum LanFollowResult {
  /// Paired and signed in there.
  followed,

  /// Proven and kept as the shop's server, but signing in there failed:
  /// this device works offline until someone signs in.
  signInFailed,

  /// It didn't prove its claim, or it doesn't outrank this device's
  /// record.
  refused,

  /// Not on this device (web, or it serves the shop itself).
  notAvailable,
}

/// Where this device stands with the store server.
enum LanStatusKind {
  /// This desktop serves the store.
  server,

  /// Connected to the store server.
  connected,

  /// On the store's network, but its server isn't answering: working
  /// offline.
  serverUnreachable,

  /// Away from the store's network: straight to the cloud when online.
  offLan,

  /// Not using a store server.
  standalone,
}

class LanStatus {
  const LanStatus({
    required this.kind,
    this.serverOnline,
    this.backfill,
    this.mustPairAgain = false,
    this.needsCloudSignIn = false,
  });

  final LanStatusKind kind;

  /// A server of the store was found that this device doesn't trust
  /// (proven only with the shop key): a person must pair with it using
  /// its code or QR before this device signs in there.
  final bool mustPairAgain;

  /// Away from the store's network, signed in only through the store
  /// server: nothing goes to the cloud until the user signs in to it.
  final bool needsCloudSignIn;

  /// Whether the store server reaches the internet (server or connected
  /// only; null when not known).
  final bool? serverOnline;

  /// The store server's first load from the cloud (server or connected).
  final LanBackfillStatus? backfill;

  /// Still loading store data from the cloud.
  bool get loading => backfill != null && !backfill!.done;
}

/// What a force-clear came to.
enum LanForceClearResult {
  applied,

  /// The signed-in user lacks `Manage Local Server`.
  noPermission,

  /// The password typed isn't the signed-in user's.
  wrongPassword,

  /// No server on record, or it is cleared already.
  alreadyCleared,

  /// Not on the shop's LAN (or no LAN session): from here a server that
  /// works can't be told from a dead one.
  notOnLan,

  /// A server answered within the last 60 s.
  tooSoon,

  /// A fresh look found a server of the shop answering.
  liveServerFound,

  /// Not on this device (web), or this device serves the shop (it clears
  /// the server the usual way).
  notAvailable,
}

/// Reads, caches, sets and clears this device's copy of the shop's
/// [LocalServerRecord], and drives the LAN transport: serving on desktop,
/// connecting and pairing as a client.
class LocalServerProvider extends ChangeNotifier {
  static final LocalServerProvider _instance =
      LocalServerProvider._internal();
  factory LocalServerProvider() => _instance;
  LocalServerProvider._internal() {
    LanTransport().onChanged = notifyListeners;
    LanTransport().onServerView = _onServerView;
    LanTransport().onOutranked = _onOutranked;
    LanTransport().onOutranks = _onOutranks;
    LanTransport().onMoved = _onMoved;
    LanTransport().onClearedElsewhere = _onClearedElsewhere;
    // The route decides the status and the online-only screens.
    RemoteRouter.addListener(notifyListeners);
  }

  // ------------------------------------------------------- status

  /// Where this device stands with the store server.
  LanStatus get status {
    final health = LanTransport().serverHealth;
    final pairAgain = _mustPairAgainHere();
    switch (RemoteRouter.route) {
      case LanRoute.server:
        return LanStatus(
          kind: LanStatusKind.server,
          serverOnline: health?.online,
          backfill: health?.backfill,
          mustPairAgain: pairAgain,
        );
      case LanRoute.lanUp:
        return LanStatus(
          kind: LanStatusKind.connected,
          serverOnline: health?.online,
          backfill: health?.backfill,
          mustPairAgain: pairAgain,
        );
      case LanRoute.lanDown:
        return LanStatus(
          kind: LanStatusKind.serverUnreachable,
          mustPairAgain: pairAgain,
        );
      case LanRoute.offLan:
        return LanStatus(
          kind: LanStatusKind.offLan,
          mustPairAgain: pairAgain,
          needsCloudSignIn: RemoteRouter.needsCloudSignIn,
        );
      case LanRoute.standalone:
        return LanStatus(
          kind: LanStatusKind.standalone,
          mustPairAgain: pairAgain,
        );
    }
  }

  /// Shops where a server this device doesn't trust was found: shown until
  /// a person pairs this device again.
  final Set<int> _mustPairAgain = {};

  bool _mustPairAgainHere() {
    try {
      final shop = LanRoutingDeps.currentShopId();
      return shop != null && _mustPairAgain.contains(shop);
    } catch (_) {
      return false;
    }
  }

  void _setMustPairAgain(int shopId) {
    if (_mustPairAgain.add(shopId)) notifyListeners();
  }

  @visibleForTesting
  bool mustPairAgainFor(int shopId) => _mustPairAgain.contains(shopId);

  /// Highest epoch this device knows for [shopId]: a server claim may be
  /// at most [LocalServerRecord.maxEpochJump] above it, so a forged claim
  /// can't leap past every real one. 0: nothing known yet (no cap).
  int _highestKnownEpoch(int shopId) =>
      max(LocalServerFunc().epochFloor(shopId), record(shopId: shopId)?.epoch ?? 0);

  bool _epochPlausible(int shopId, int epoch) {
    final known = _highestKnownEpoch(shopId);
    return known == 0 || LocalServerRecord.withinEpochCap(epoch, known);
  }

  /// Stores the shop key a login answer carries only when this device has
  /// none for [shopId]. A key already held is never replaced from a server's
  /// answer: whoever controls it would control which servers this device
  /// accepts.
  Future<void> _keepShopKey(int shopId, String key) async {
    final held = LanShopKeysFunc().get(shopId);
    if (held == null) {
      await LanShopKeysFunc().put(shopId, key);
    } else if (held != key) {
      await mainLocalLog(
        'LAN: a server answered with a different shop key for shop $shopId; '
        'kept the one held',
      );
    }
  }

  /// Signs in to the cloud (Supabase) on a device signed in only through
  /// the store server, so it can sync while away from the store's network.
  /// Returns an error message, or null when signed in.
  Future<String?> signInToCloud(String password) async {
    final user = LoggedInUserFunc().getLoggedInUser()?.loggedInUser;
    final email = user?.email;
    if (email == null || email.isEmpty) return 'No signed-in user';
    try {
      await sb.Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on sb.AuthException catch (e) {
      return e.message;
    } catch (e) {
      await mainLocalLog('Cloud sign-in failed: $e');
      return 'Could not reach the cloud. Try again when online.';
    }
    notifyListeners();
    // Off the store's network the queue can go to the cloud now.
    await LanRouting().evaluate();
    if (!RemoteRouter.needsCloudSignIn) unawaited(returnData().syncData());
    return null;
  }

  /// Whether screens that need the internet (payments, notifications, the
  /// update check, password reset) are shown: on the
  /// store's network only while its server reaches the internet (it
  /// forwards them); anywhere else as before.
  bool get onlineFeaturesAvailable {
    switch (RemoteRouter.route) {
      case LanRoute.lanUp:
        return LanTransport().serverHealth?.online == true;
      case LanRoute.lanDown:
        return false;
      case LanRoute.server:
      case LanRoute.offLan:
      case LanRoute.standalone:
        return true;
    }
  }

  /// The password re-entry before a server-role change: checked by
  /// this device's own credential store when it serves [shopId]; else by
  /// the store server when it answers; else against the password kept for
  /// offline login (no server yet, or none answering).
  Future<LanAuthResult> confirmPassword({
    required int shopId,
    required String userId,
    required String password,
  }) async {
    final transport = LanTransport();
    final serving = transport.isServing && transport.servingShopId == shopId;
    if (serving ||
        (transport.isClientConnected &&
            LanClientSessionFunc().get(shopId) != null)) {
      final result = await verifyPassword(
        shopId: shopId,
        userId: userId,
        password: password,
      );
      if (serving || result != LanAuthResult.unreachable) return result;
    }
    final stored = LoggedInUserFunc().getLoggedInUser()?.loggedInUser;
    final kept = stored?.password;
    if (stored == null ||
        stored.userId != userId ||
        kept == null ||
        kept.isEmpty) {
      return LanAuthResult.invalidCredentials;
    }
    return kept == password
        ? LanAuthResult.ok
        : LanAuthResult.invalidCredentials;
  }

  /// On the server: the devices signed in on it, with their holds.
  List<LanConnectedDevice> connectedDevices() =>
      LanTransport().connectedDevices();

  /// On the server: releases [deviceId]'s holds.
  Future<int> releaseDeviceHolds(String deviceId) async {
    final released = await LanTransport().releaseDeviceHolds(deviceId);
    notifyListeners();
    return released;
  }

  final Map<int, LocalServerRecord?> _cache = {};

  LocalServerRecord? record({required int shopId}) {
    if (!_cache.containsKey(shopId)) {
      _cache[shopId] = LocalServerFunc().getRecord(shopId);
    }
    return _cache[shopId];
  }

  bool get isServing => LanTransport().isServing;
  bool get isClientConnected => LanTransport().isClientConnected;

  /// The code to show on the server's screen while a client pairs.
  String? get pendingPairingCode => LanTransport().pendingPairingCode;

  Future<String?> pairingQrPayload() => LanTransport().pairingQrPayload();

  /// On the server: ends the pairing session it shows.
  void cancelServerPairing() => LanTransport().cancelServerPairing();

  /// Claims the server role for this desktop: the local record must be
  /// cleared, no live server may answer for the shop, and the new epoch is
  /// one above the highest known (local floor, peers, servers).
  Future<LocalServerChange> setThisDeviceAsServer({
    required int shopId,
    required String userId,
  }) async {
    final transport = LanTransport();
    if (!transport.isAvailable || runningInAltWindow) {
      return LocalServerChange.notAvailable;
    }
    if (!ShopProvider().isDesktop()) {
      return LocalServerChange.notDesktop;
    }
    final current = record(shopId: shopId);
    if (current != null && !current.isCleared) {
      return LocalServerChange.refusedNotCleared;
    }
    // The server signs staff in from its own store, so it needs their
    // credentials and the shop key before it can serve.
    final ready = await LanUserBackfill().ensure(shopId);
    final shopKey = LanShopKeysFunc().get(shopId);
    if (!ready || shopKey == null) {
      return LocalServerChange.needsInternet;
    }
    final deviceId = await DeviceIdentity().deviceId();
    final preflight = await transport.claimPreflight(
      shopKey: shopKey,
      ownDeviceId: deviceId,
      lastKnownAddresses: [
        ...?current?.lastKnownAddresses,
        for (final paired in LanPairedServersFunc().all()) ...paired.addresses,
      ],
    );
    if (preflight.liveServerFound) {
      return LocalServerChange.liveServerFound;
    }
    // A peer's epoch far above anything known here is not believed: a
    // forged claim must not push this one's epoch up with it.
    var peerEpoch = preflight.maxEpoch;
    if (!_epochPlausible(shopId, peerEpoch)) {
      await mainLocalLog(
        'Local Server: a peer claims epoch $peerEpoch, more than '
        '${LocalServerRecord.maxEpochJump} above any known here; ignored',
      );
      peerEpoch = 0;
    }
    final next = LocalServerRecord.claim(
      current,
      shopId: shopId,
      deviceId: deviceId,
      userId: userId,
      now: DateTime.now().toUtc(),
      certFingerprint: await transport.serverFingerprint(),
      highestKnownEpoch: max(LocalServerFunc().epochFloor(shopId), peerEpoch),
    );
    if (next == null) {
      return LocalServerChange.refusedNotCleared;
    }
    await _write(next);
    await mainLocalLog(
      'Local Server Set: shop $shopId, epoch ${next.epoch}',
    );
    try {
      await transport.startServer(
        record: next,
        deviceId: deviceId,
        shopKey: shopKey,
      );
    } catch (e, s) {
      await mainLocalLog(
        'Local Server claimed but failed to start: $e',
        error: e,
        stackTrace: s,
      );
      return LocalServerChange.serverStartFailed;
    }
    return LocalServerChange.applied;
  }

  /// On desktop launch: start serving again if this device holds the role.
  Future<void> resumeServerIfOwned() async {
    final transport = LanTransport();
    if (!transport.isAvailable ||
        runningInAltWindow ||
        !ShopProvider().isDesktop()) {
      return;
    }
    try {
      final deviceId = await DeviceIdentity().deviceId();
      for (final owned in LocalServerFunc().allRecords()) {
        if (owned.serverDeviceId != deviceId) continue;
        _cache[owned.shopId] = owned;
        final fingerprint = await transport.serverFingerprint();
        if (owned.certFingerprint != null &&
            owned.certFingerprint != fingerprint) {
          await mainLocalLog(
            'Local Server certificate changed: clients must pair again',
          );
        }
        final shopKey = LanShopKeysFunc().get(owned.shopId);
        if (shopKey == null) {
          await mainLocalLog(
            'Local Server not resumed: no shop key for shop ${owned.shopId}',
          );
          return;
        }
        // Another server of the shop may have taken over while this one
        // was off (a split network): look first.
        final winner = await transport.findOutrankingServer(
          shopKey: shopKey,
          ownDeviceId: deviceId,
          self: LanServerView.fromRecord(owned, shopTag(shopKey)),
          timeout: LanConstants.serverWatchBrowse,
        );
        if (winner != null) {
          await demoteTo(winner, shopId: owned.shopId);
          return;
        }
        await transport.startServer(
          record: owned,
          deviceId: deviceId,
          shopKey: shopKey,
        );
        notifyListeners();
        if (ConnectivityProvider().isConnected) {
          // Pick up staff and password changes made while it was off.
          unawaited(LanUserBackfill().ensure(owned.shopId));
        }
        return;
      }
    } catch (e, s) {
      await mainLocalLog(
        'Could not resume Local Server: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<LocalServerChange> clearServer({
    required int shopId,
    required String userId,
  }) async {
    final served = record(shopId: shopId);
    final next = LocalServerRecord.clear(
      served,
      userId: userId,
      now: DateTime.now().toUtc(),
    );
    if (next == null) {
      return LocalServerChange.alreadyCleared;
    }
    await _write(next);
    await mainLocalLog(
      'Local Server Cleared: shop $shopId, epoch ${next.epoch}',
    );
    final transport = LanTransport();
    if (transport.isServing && transport.servingShopId == shopId) {
      // This device sends its own queue on (as a standalone device), so its
      // clients' copies of its deltas end; then they are told it is
      // cleared, and it stops serving.
      transport.broadcastHandedOver(served!.epoch);
      await transport.updateServerRecord(next);
      await transport.stopServer();
    }
    return LocalServerChange.applied;
  }

  /// Keeps [incoming] only if it has a higher epoch for the same shop.
  Future<LocalServerChange> adoptIfNewer(
    LocalServerRecord incoming,
  ) async {
    if (!LocalServerRecord.supersedes(
      incoming,
      record(shopId: incoming.shopId),
    )) {
      return LocalServerChange.notNewer;
    }
    await _write(incoming);
    return LocalServerChange.applied;
  }

  void clearCache() {
    _cache.clear();
    notifyListeners();
  }

  /// Stops serving and every advert from this device, leaving the stored
  /// records alone. `clearAllShopData` calls this on logout and store switch
  /// so a desktop doesn't keep serving the previous shop until restart.
  Future<void> stopServingAndAdverts() async {
    final transport = LanTransport();
    await transport.stopServer();
    await transport.stopPeer();
  }

  // ---------------------------------------------------------------- client

  /// Connects to the shop's paired server (`LanRouting` decides when).
  /// [quick]: known addresses and a short browse only, no sweep. Server
  /// records it reports go through [adoptIfNewer].
  Future<bool> connectToServer({
    required int shopId,
    bool quick = false,
  }) async {
    final transport = LanTransport();
    if (!transport.isAvailable) return false;
    final session = LanClientSessionFunc().get(shopId);
    final shopKey = LanShopKeysFunc().get(shopId);
    if (session == null || shopKey == null) return false;
    final paired = LanPairedServersFunc().get(session.serverDeviceId);
    if (paired == null) return false;
    final current = record(shopId: shopId);
    final connected = await transport.connectToServer(
      shopId: shopId,
      shopKey: shopKey,
      pin: paired.certFingerprint,
      addresses: [...?current?.lastKnownAddresses, ...paired.addresses],
      port: paired.port,
      token: session.token,
      deviceId: await DeviceIdentity().deviceId(),
      quick: quick,
      staleNotice: (view, fingerprint) =>
          _staleNotice(shopId, shopKey, view, fingerprint),
    );
    if (connected) {
      await LanPairedServersFunc().put(
        paired.withAddresses(transport.clientAddresses),
      );
    }
    return connected;
  }

  Future<void> disconnectFromServer() => LanTransport().disconnectClient();

  // ------------------------------------------------------------------ auth

  /// Signs in on a paired LAN server. On success it saves what the
  /// Supabase login saves today (user, logged-in user with the typed
  /// password so offline login keeps working, the shop), plus the LAN
  /// session and the shop key. [LanAuthResult.unreachable] means "use the
  /// existing login".
  Future<LanAuthResult> loginViaLan({
    required String email,
    required String password,
  }) async {
    final transport = LanTransport();
    if (!transport.isAvailable || LanPairedServersFunc().all().isEmpty) {
      return LanAuthResult.unreachable;
    }
    final deviceId = await DeviceIdentity().deviceId();
    final outcome = await transport.loginToPairedServer(
      email: email,
      password: password,
      deviceId: deviceId,
    );
    if (outcome.result != LanAuthResult.ok) {
      await mainLocalLog('LAN login: ${outcome.result.name}');
      // A server that doesn't know this device: the status asks to pair.
      if (outcome.notPairedBy.isNotEmpty) {
        final shop = LanRoutingDeps.currentShopId();
        if (shop != null) _setMustPairAgain(shop);
      }
      return outcome.result;
    }
    try {
      final user = TempUserClass.fromJson({
        ...outcome.user!,
        'password': password,
      });
      final shop = shopFromLanLogin(outcome.shop);
      if (shop == null) {
        // Nothing saved yet. Fail cleanly so the normal login runs, and
        // end the session the server just issued.
        await mainLocalLog('LAN login: incomplete shop from the server');
        await transport.logoutFromServer(
          serverDeviceId: outcome.serverDeviceId!,
          token: outcome.token!,
          deviceId: deviceId,
        );
        return LanAuthResult.failed;
      }
      final shopId = shop.shopId;
      if (user.userId == null || shopId == null) {
        throw const FormatException('LAN login: no user or shop id');
      }
      await _keepShopKey(shopId, outcome.shopKey!);
      await LanClientSessionFunc().put(
        LanClientSession(
          serverDeviceId: outcome.serverDeviceId!,
          shopId: shopId,
          userId: user.userId!,
          token: outcome.token!,
          expiresAt:
              outcome.expiresAt ??
              DateTime.now().toUtc().add(const Duration(days: 1)),
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await ShopFunc().insertShops([shop]);
      await UserFunc().insertUser(user);
      await LoggedInUserFunc().insertLoggedInUser(
        LoggedInUser(loggedInUser: user),
      );
      // Routing reads the current shop from here (the shops in memory are
      // only loaded later).
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: shopId),
      );
      await mainLocalLog('✅ LAN login: ${user.email}, shop $shopId');
      notifyListeners();
      // Route this device to the server now that it has a session.
      unawaited(LanRouting().evaluate());
      return LanAuthResult.ok;
    } catch (e, s) {
      await mainLocalLog(
        'LAN login: could not save the session: $e',
        error: e,
        stackTrace: s,
      );
      return LanAuthResult.failed;
    }
  }

  /// After the cloud took a password the store server refused (its logins
  /// were out of date): asks the server to fetch them again. Best effort.
  Future<void> refreshServerCredentials() async {
    final transport = LanTransport();
    if (!transport.isAvailable || LanPairedServersFunc().all().isEmpty) {
      return;
    }
    try {
      await transport.requestCredentialRefresh(
        deviceId: await DeviceIdentity().deviceId(),
      );
    } catch (e) {
      await mainLocalLog('LAN: could not ask for a login refresh: $e');
    }
  }

  /// The shop a LAN login returned, or null when a field
  /// `TempShopClass.fromJson` can't do without (`shop_id`, `user_id`,
  /// `name`, `currency`, `is_verified`, `created_at`) is missing or of the
  /// wrong type. No defaults: a guessed currency would be saved as real.
  static TempShopClass? shopFromLanLogin(Map<String, dynamic>? json) {
    if (json == null) return null;
    final createdAt = json['created_at'];
    if (json['shop_id'] is! int ||
        json['user_id'] is! String ||
        json['name'] is! String ||
        json['currency'] is! String ||
        json['is_verified'] is! bool ||
        createdAt is! String ||
        DateTime.tryParse(createdAt) == null) {
      return null;
    }
    try {
      return TempShopClass.fromJson(json);
    } catch (_) {
      // Any other field of the wrong type.
      return null;
    }
  }

  /// Ends this device's LAN sessions on their servers (best effort) and
  /// forgets them locally. The sessions are read before the first await,
  /// so `AuthService.signOut` can leave this running while
  /// `clearAllShopData` wipes the box.
  Future<void> logoutFromLan() async {
    final transport = LanTransport();
    if (!transport.isAvailable) return;
    final sessions = LanClientSessionFunc().all();
    // This device's cart stock holds go while its session still works;
    // waits a few seconds at most.
    try {
      await LanStockClient().releaseAll();
    } catch (e) {
      await mainLocalLog('LAN stock release on logout failed: $e');
    }
    try {
      await transport.disconnectClient();
      final deviceId = await DeviceIdentity().deviceId();
      for (final session in sessions) {
        await LanClientSessionFunc().delete(session.shopId);
        await transport.logoutFromServer(
          serverDeviceId: session.serverDeviceId,
          token: session.token,
          deviceId: deviceId,
        );
      }
    } catch (e) {
      await mainLocalLog('LAN logout failed: $e');
    }
  }

  /// The password re-entry before setting or clearing the server: checked
  /// against this device's own credential store when it serves [shopId],
  /// otherwise by the shop's LAN server.
  Future<LanAuthResult> verifyPassword({
    required int shopId,
    required String userId,
    required String password,
  }) async {
    final transport = LanTransport();
    if (transport.isServing && transport.servingShopId == shopId) {
      final credential = LanCredentialsFunc().get(shopId, userId);
      if (credential == null) return LanAuthResult.invalidCredentials;
      final matches = await lan_hash.verifyPassword(
        password,
        lan_hash.LanPasswordHash(
          salt: credential.salt,
          hash: credential.hash,
          iterations: credential.iterations,
        ),
      );
      return matches ? LanAuthResult.ok : LanAuthResult.invalidCredentials;
    }
    final session = LanClientSessionFunc().get(shopId);
    if (!transport.isAvailable || session == null) {
      return LanAuthResult.unreachable;
    }
    return transport.verifyPasswordOnServer(
      serverDeviceId: session.serverDeviceId,
      token: session.token,
      deviceId: await DeviceIdentity().deviceId(),
      password: password,
    );
  }

  Future<void> _onServerView(
    int shopId,
    LanServerView view,
    List<String> addresses,
    String fingerprint,
  ) async {
    final before = record(shopId: shopId);
    final incoming = LocalServerRecord(
      shopId: shopId,
      epoch: view.epoch,
      serverDeviceId: view.cleared ? null : view.serverDeviceId,
      claimedAt: view.claimedAt,
      certFingerprint: view.cleared ? null : fingerprint,
      lastKnownAddresses: view.cleared ? const [] : addresses,
    );
    final result = await adoptIfNewer(incoming);
    final current = record(shopId: shopId);
    if (result == LocalServerChange.notNewer &&
        current != null &&
        !current.isCleared &&
        current.epoch == view.epoch &&
        current.serverDeviceId == view.serverDeviceId) {
      // Same record: refresh the address cache only.
      await _write(current.withAddresses(addresses));
    }
    if (view.cleared) {
      await LanTransport().disconnectClient();
      // Cleared from elsewhere while it was away (a force-clear): what this
      // till still holds for it is listed.
      if (result == LocalServerChange.applied) {
        await _reportHeldFor(before, shopId: shopId);
      }
    }
  }

  /// This till learned that [old]'s server was force-cleared (the cleared
  /// record, or a new server after a clear): the stock changes it still
  /// holds for that server are listed in an alert, as in the force-clear
  /// report. They stay held. Once per server and epoch.
  Future<void> _reportHeldFor(LocalServerRecord? old, {required int shopId}) async {
    final device = old?.serverDeviceId;
    if (old == null || device == null) return;
    // With the changes sent to it that it never answered for.
    final held = [
      ...heldDeltasOf(LanHandoffs().deltasFor(device)),
      ...heldQueuedFor(device),
    ];
    if (held.isEmpty) return;
    if (!await LanAlertsFunc().once('held:$device|${old.epoch}')) return;
    await LanAlerts().raise(
      shopId: shopId,
      kind: LanAlertKind.forceCleared,
      title: 'Store server cleared',
      message:
          'The store server (${_short(device)}) was cleared on another device '
          'after it stopped answering. These stock changes were sent to it '
          'from this device and may never reach the cloud if it doesn\'t '
          'come back: check these items\' stock by hand.',
      columns: heldDeltaColumns,
      rows: heldDeltaRows(held),
    );
  }

  /// Lets a desktop that is about to claim learn this device's epoch.
  Future<void> advertisePeer({required int shopId}) async {
    final transport = LanTransport();
    if (!transport.isAvailable) return;
    final shopKey = LanShopKeysFunc().get(shopId);
    if (shopKey == null) return;
    await transport.advertisePeer(
      shopKey: shopKey,
      epoch: max(
        record(shopId: shopId)?.epoch ?? 0,
        LocalServerFunc().epochFloor(shopId),
      ),
      deviceId: await DeviceIdentity().deviceId(),
    );
  }

  Future<void> stopPeer() => LanTransport().stopPeer();

  // --------------------------------------------------------------- pairing

  Future<List<LanFound>> browseServers() => LanTransport().browseServers();

  Future<LanPairOutcome> beginPairing({
    required List<String> addresses,
    required int port,
  }) {
    return LanTransport().beginPairing(addresses: addresses, port: port);
  }

  Future<LanPairOutcome> submitPairingCode(String code) async {
    final outcome = await LanTransport().submitPairingCode(code);
    if (outcome.result == LanPairResult.paired) _mustPairAgain.clear();
    notifyListeners();
    return outcome;
  }

  Future<LanPairOutcome> pairFromQr(String payload) async {
    final outcome = await LanTransport().pairFromQr(payload);
    if (outcome.result == LanPairResult.paired) _mustPairAgain.clear();
    notifyListeners();
    return outcome;
  }

  Future<void> cancelPairing() => LanTransport().cancelPairing();

  /// After pairing with [serverDeviceId]: signs in there as the
  /// user signed in on this device, with the password kept for offline
  /// login, and routes there. [LanAuthResult.invalidCredentials]: ask for
  /// the password and use [loginViaLan].
  Future<LanAuthResult> signInAfterPairing({
    required int shopId,
    required String serverDeviceId,
  }) async {
    final result = await signInOnServer(
      shopId,
      serverDeviceId: serverDeviceId,
    );
    if (result == LanAuthResult.ok) {
      notifyListeners();
      unawaited(LanRouting().evaluate());
    }
    return result;
  }

  // ------------------------------------------------- one server per shop

  bool _demoting = false;
  final Set<String> _toldDown = {};

  Future<void> _onOutranked(LanServerCandidate winner) async {
    final shopId = LanTransport().servingShopId;
    if (shopId == null) return;
    await demoteTo(winner, shopId: shopId);
  }

  /// This device's server outranks [loser] (it is told to step down by the
  /// transport): the alert, once per claim.
  void _onOutranks(LanServerCandidate loser) {
    final shopId = LanTransport().servingShopId;
    if (shopId == null) return;
    if (!_toldDown.add('${loser.view.serverDeviceId}|${loser.view.epoch}')) {
      return;
    }
    unawaited(
      LanAlerts().raise(
        shopId: shopId,
        kind: LanAlertKind.conflict,
        title: 'Two store servers found',
        message:
            'Another device (${_short(loser.view.serverDeviceId)}) was also '
            'serving this store, probably while the network was split. This '
            'device stays the store server; the other one stops and sends '
            'it every change made there meanwhile. Stock may now be below '
            'zero for items sold on both sides.',
      ),
    );
  }

  static String _short(String? deviceId) {
    final d = deviceId ?? '?';
    return d.length > 6 ? d.substring(0, 6) : d;
  }

  /// This device stops serving the shop for [winner], a server that
  /// outranks it:
  /// 1. [winner] is proven again, pinned to its certificate (a notice or
  ///    an advert is never trusted alone);
  /// 2. connected clients are told where the server is now, then this
  ///    device stops serving;
  /// 3. its holds and server sessions go (holds aren't migrated);
  /// 4. it keeps [winner]'s record and pairs with it;
  /// 5. it signs in there as the user signed in here (stored password) and
  ///    routes to it, so the normal sync pushes the whole queue it kept as
  ///    a server. Writes the winner refuses for permission are set aside
  ///    for Supabase until that push is done.
  Future<LocalServerChange> demoteTo(
    LanServerCandidate winner, {
    required int shopId,
  }) async {
    if (_demoting) return LocalServerChange.notNewer;
    _demoting = true;
    try {
      final transport = LanTransport();
      final shopKey = LanShopKeysFunc().get(shopId);
      final own = record(shopId: shopId);
      if (shopKey == null || own == null) return LocalServerChange.notAvailable;
      final fresh = await transport.proveServer(
        shopKey: shopKey,
        addresses: winner.addresses,
        port: winner.port,
        fingerprint: winner.fingerprint,
      );
      if (fresh == null ||
          fresh.view.cleared ||
          fresh.rankAgainst(
                epoch: own.epoch,
                claimedAt: own.claimedAt,
                deviceId: own.serverDeviceId,
              ) <=
              0) {
        await mainLocalLog(
          'Local Server: ${winner.view.serverDeviceId} not proven to outrank '
          'this one; still serving',
        );
        return LocalServerChange.notNewer;
      }
      if (!_epochPlausible(shopId, fresh.view.epoch)) {
        await mainLocalLog(
          'Local Server: ${fresh.view.serverDeviceId} claims epoch '
          '${fresh.view.epoch}, more than ${LocalServerRecord.maxEpochJump} '
          'above any known here; still serving',
        );
        return LocalServerChange.notNewer;
      }
      await mainLocalLog(
        'Local Server: ${fresh.view.serverDeviceId} (epoch '
        '${fresh.view.epoch}) outranks this device; stopping',
      );
      if (transport.isServing && transport.servingShopId == shopId) {
        // The winner proves this server first, so the move signed next
        // lets this server's tills sign in there.
        await transport.announceSteppingDown(fresh);
        transport.broadcastMoved(fresh);
        await transport.stopServer();
      }
      await LanStockHoldsFunc().clearHolds();
      await LanServerSessionsFunc().clearSessions();
      await _write(fresh.toRecord(shopId));
      await LanPairedServersFunc().put(
        LanPairedServer(
          serverDeviceId: fresh.view.serverDeviceId!,
          certFingerprint: fresh.fingerprint,
          port: fresh.port,
          addresses: fresh.addresses,
          pairedAt: DateTime.now().toUtc(),
          label: 'Stockall-${_short(fresh.view.serverDeviceId)}',
        ),
      );
      // Once the queue is all there, the new server is told.
      await LanAlertsFunc().setHandingOverEpoch(own.epoch);
      await LanAlertsFunc().setPushingShop(shopId);
      // The winner was proven with the shop key only: the stored password
      // goes there only if a person already paired this device with it.
      final trusted = LanPairedServersFunc().isTrusted(fresh.fingerprint);
      final signedIn =
          trusted &&
          await signInOnServer(
                shopId,
                serverDeviceId: fresh.view.serverDeviceId!,
              ) ==
              LanAuthResult.ok;
      if (!trusted) _setMustPairAgain(shopId);
      final next = signedIn
          ? ''
          : trusted
          ? ' Sign in again on this device to send them.'
          : ' Pair this device with it using the code it shows (Settings › '
                'Store Network) to send them.';
      await LanAlerts().raise(
        shopId: shopId,
        kind: LanAlertKind.demoted,
        title: 'This device stopped serving the store',
        message:
            'Another store server (${_short(fresh.view.serverDeviceId)}) was '
            'found on the network, probably after it was split. This device '
            'is now its client and is sending it every change made here '
            'meanwhile.$next',
      );
      unawaited(LanRouting().evaluate());
      return LocalServerChange.applied;
    } catch (e, s) {
      await mainLocalLog('Local Server demotion failed: $e', error: e, stackTrace: s);
      return LocalServerChange.serverStartFailed;
    } finally {
      _demoting = false;
    }
  }

  /// Signs in on the paired server [serverDeviceId] as the user signed in
  /// on this device, with the password kept for offline login (answer
  /// 4). Saves the session only (the user and shop are already here).
  Future<LanAuthResult> signInOnServer(
    int shopId, {
    required String serverDeviceId,
  }) async {
    final user = LoggedInUserFunc().getLoggedInUser()?.loggedInUser;
    final email = user?.email;
    final password = user?.password;
    if (user == null ||
        email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return LanAuthResult.invalidCredentials;
    }
    final deviceId = await DeviceIdentity().deviceId();
    final outcome = await LanTransport().loginToPairedServer(
      email: email,
      password: password,
      deviceId: deviceId,
      serverDeviceId: serverDeviceId,
    );
    if (outcome.result != LanAuthResult.ok ||
        outcome.serverDeviceId != serverDeviceId ||
        outcome.token == null) {
      await mainLocalLog('Local Server: sign-in on the new server: '
          '${outcome.result.name}');
      // The server doesn't know this device: the status asks to pair.
      if (outcome.notPairedBy.isNotEmpty) _setMustPairAgain(shopId);
      return outcome.result == LanAuthResult.ok
          ? LanAuthResult.failed
          : outcome.result;
    }
    if (outcome.shopKey != null) {
      await _keepShopKey(shopId, outcome.shopKey!);
    }
    await LanClientSessionFunc().put(
      LanClientSession(
        serverDeviceId: outcome.serverDeviceId!,
        shopId: shopId,
        userId: user.userId ?? '',
        token: outcome.token!,
        expiresAt:
            outcome.expiresAt ??
            DateTime.now().toUtc().add(const Duration(days: 1)),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return LanAuthResult.ok;
  }

  // ------------------------------------------- clients follow the winner

  Future<LanFollowResult>? _following;
  DateTime? _lastFollowSearch;

  /// Claims (device|epoch) whose sign-in was refused with the stored
  /// password: not tried again by themselves (a wrong password would only
  /// get this device rate limited). A manual sign-in still works.
  final Set<String> _followRefused = {};

  /// The least time between two searches for a server to follow while the
  /// paired one can't be reached (each browses for a few seconds).
  @visibleForTesting
  Duration followSearchEvery = LanConstants.serverWatchEvery;

  @visibleForTesting
  void resetFollow() {
    _lastFollowSearch = null;
    _followRefused.clear();
  }

  /// This device's server [from] said the shop's server is now [to] (it
  /// stepped down). Followed once [to] proves its claim; then the
  /// deltas [from] acknowledged end here, since [from] delivers them
  /// itself.
  Future<void> _onMoved(
    int shopId,
    LanServerView from,
    LanServerCandidate to,
  ) async {
    // The transport calls this only for a move signed with the key of the
    // certificate this device pinned: that server vouches for [to].
    final result = await followServer(
      to,
      shopId: shopId,
      reportHeld: false,
      vouched: true,
    );
    if (result != LanFollowResult.followed &&
        result != LanFollowResult.signInFailed) {
      return;
    }
    final device = from.serverDeviceId;
    if (device == null) return;
    final ended = await LanHandoffs().endDeltasFrom(device, from.epoch);
    if (ended > 0) {
      await mainLocalLog(
        'LAN: $ended stock/account changes are delivered by $device itself',
      );
    }
  }

  /// Follows [to], a server of the shop that outranks this device's record:
  /// proves it again pinned to its certificate, keeps its
  /// record, pairs with it, signs in there with the stored password and
  /// (with [route]) routes to it; holds re-sync on connect. One at a
  /// time: a call during one gets its result.
  ///
  /// Only a certificate this device trusts is followed: one a person
  /// paired, or one a trusted server signed a move to ([vouched]: this
  /// call comes from such a move; its trust is kept once the follow is
  /// accepted). Anything else is refused and the status asks for pairing.
  ///
  /// When [to] is at least two epochs above the server on record, that
  /// server was cleared in between (a force-clear): with [reportHeld], what
  /// this till still holds for it is listed (it stays held).
  Future<LanFollowResult> followServer(
    LanServerCandidate to, {
    required int shopId,
    bool route = true,
    bool reportHeld = true,
    bool vouched = false,
  }) {
    return _following ??= _follow(
      to,
      shopId: shopId,
      route: route,
      reportHeld: reportHeld,
      vouched: vouched,
    ).whenComplete(() => _following = null);
  }

  Future<LanFollowResult> _follow(
    LanServerCandidate to, {
    required int shopId,
    required bool route,
    required bool reportHeld,
    required bool vouched,
  }) async {
    try {
      final transport = LanTransport();
      if (!transport.isAvailable ||
          (transport.isServing && transport.servingShopId == shopId)) {
        return LanFollowResult.notAvailable;
      }
      final shopKey = LanShopKeysFunc().get(shopId);
      if (shopKey == null) return LanFollowResult.notAvailable;
      // Only a certificate a person paired, or one a trusted server signed
      // a move to: a proof with the shop key alone could come from any
      // signed-in device of the store.
      if (!vouched && !LanPairedServersFunc().isTrusted(to.fingerprint)) {
        await mainLocalLog(
          'LAN: ${to.view.serverDeviceId} is not paired with this device; '
          'not followed (pair with its code)',
        );
        _setMustPairAgain(shopId);
        return LanFollowResult.refused;
      }
      final fresh = await transport.proveServer(
        shopKey: shopKey,
        addresses: to.addresses,
        port: to.port,
        fingerprint: to.fingerprint,
      );
      final device = fresh?.view.serverDeviceId;
      if (fresh == null || device == null || fresh.view.cleared) {
        await mainLocalLog(
          'LAN: ${to.view.serverDeviceId} did not prove its claim; '
          'not followed',
        );
        return LanFollowResult.refused;
      }
      if (!_epochPlausible(shopId, fresh.view.epoch)) {
        await mainLocalLog(
          'LAN: $device claims epoch ${fresh.view.epoch}, more than '
          '${LocalServerRecord.maxEpochJump} above any known here; '
          'not followed',
        );
        return LanFollowResult.refused;
      }
      final current = record(shopId: shopId);
      final incoming = fresh.toRecord(shopId);
      final same =
          current != null &&
          !current.isCleared &&
          current.serverDeviceId == device &&
          current.epoch == fresh.view.epoch;
      if (!same && !LocalServerRecord.supersedes(incoming, current)) {
        await mainLocalLog(
          'LAN: $device (epoch ${fresh.view.epoch}) does not outrank this '
          "device's server record; not followed",
        );
        return LanFollowResult.refused;
      }
      // Accepted: the move's signer vouches for this certificate.
      if (vouched) await LanPairedServersFunc().markVouched(fresh.fingerprint);
      final claim = '$device|${fresh.view.epoch}';
      final session = LanClientSessionFunc().get(shopId);
      if (same && session?.serverDeviceId == device) {
        if (route) unawaited(LanRouting().evaluate());
        return LanFollowResult.followed;
      }
      await _write(same ? current.withAddresses(fresh.addresses) : incoming);
      if (reportHeld &&
          !same &&
          current != null &&
          current.serverDeviceId != device &&
          fresh.view.epoch >= current.epoch + 2) {
        await _reportHeldFor(current, shopId: shopId);
      }
      await LanPairedServersFunc().put(
        LanPairedServer(
          serverDeviceId: device,
          certFingerprint: fresh.fingerprint,
          port: fresh.port,
          addresses: fresh.addresses,
          pairedAt: DateTime.now().toUtc(),
          label: 'Stockall-${_short(device)}',
        ),
      );
      if (_followRefused.contains(claim)) return LanFollowResult.signInFailed;
      await mainLocalLog(
        'LAN: following $device (epoch ${fresh.view.epoch}), the shop\'s '
        'server now',
      );
      await transport.disconnectClient();
      final signIn = await signInOnServer(
        shopId,
        serverDeviceId: device,
      );
      if (signIn != LanAuthResult.ok) {
        if (signIn == LanAuthResult.invalidCredentials ||
            signIn == LanAuthResult.rateLimited) {
          _followRefused.add(claim);
        }
        await mainLocalLog(
          'LAN: could not sign in on $device (${signIn.name}); working '
          'offline until someone signs in',
        );
        return LanFollowResult.signInFailed;
      }
      notifyListeners();
      if (route) unawaited(LanRouting().evaluate());
      return LanFollowResult.followed;
    } catch (e, s) {
      await mainLocalLog('LAN: following a server failed: $e',
          error: e, stackTrace: s);
      return LanFollowResult.refused;
    }
  }

  /// The paired server can't be reached (routing, while `lanDown`): looks
  /// for a proven server of the shop that outranks this device's record,
  /// or the one the record already names when the session is for another
  /// (a client that missed the `moved` event), and follows it without
  /// routing (the caller connects) only when this device already trusts its
  /// certificate; otherwise the status asks for pairing again. True when
  /// this device now has a session there. At most once per
  /// [followSearchEvery].
  Future<bool> findAndFollowServer(int shopId) async {
    final running = _following;
    if (running != null) return await running == LanFollowResult.followed;
    final transport = LanTransport();
    if (!transport.isAvailable ||
        (transport.isServing && transport.servingShopId == shopId)) {
      return false;
    }
    final now = DateTime.now();
    final last = _lastFollowSearch;
    if (last != null && now.difference(last) < followSearchEvery) return false;
    _lastFollowSearch = now;
    final shopKey = LanShopKeysFunc().get(shopId);
    final session = LanClientSessionFunc().get(shopId);
    if (shopKey == null || session == null) return false;
    final current = record(shopId: shopId);
    final found = await transport.findProvenServers(
      shopKey: shopKey,
      ownDeviceId: await DeviceIdentity().deviceId(),
      timeout: LanConstants.serverWatchBrowse,
    );
    LanServerCandidate? best;
    for (final c in found) {
      final device = c.view.serverDeviceId;
      if (c.view.cleared || device == null) continue;
      if (device == session.serverDeviceId &&
          current?.serverDeviceId == device) {
        continue;
      }
      final same =
          current != null &&
          !current.isCleared &&
          current.serverDeviceId == device &&
          current.epoch == c.view.epoch;
      if (!same && !LocalServerRecord.supersedes(c.toRecord(shopId), current)) {
        continue;
      }
      if (best == null || c.rankAgainstView(best.view) > 0) best = c;
    }
    if (best == null) return false;
    return await followServer(best, shopId: shopId, route: false) ==
        LanFollowResult.followed;
  }

  // ------------------------------------ force-clear and propagation

  /// When the server [view] is older than this device's record (the shop
  /// moved on while it was off): the notice to send it (empty when
  /// there is nothing to prove), so it stops; null to use it.
  Map<String, dynamic>? _staleNotice(
    int shopId,
    String shopKey,
    LanServerView view,
    String fingerprint,
  ) {
    final own = record(shopId: shopId);
    if (own == null || own.epoch <= view.epoch) return null;
    if (own.isCleared) {
      final cleared = LanServerView.fromRecord(own, shopTag(shopKey));
      return {
        'kind': 'cleared',
        'view': cleared.toJson(),
        'mac': LanPeerProof.mac(
          shopKey: shopKey,
          nonce: LanPeerProof.clearedNotice,
          fingerprint: fingerprint,
          view: cleared,
        ),
      };
    }
    final device = own.serverDeviceId;
    final paired = device == null ? null : LanPairedServersFunc().get(device);
    if (paired == null) return const {};
    // It proves that server itself before acting.
    return {
      'kind': 'server',
      'addresses': paired.addresses,
      'port': paired.port,
      'fingerprint': paired.certFingerprint,
    };
  }

  /// This device's server was force-cleared elsewhere while it was off,
  /// as a device proved: it keeps the cleared record, tells its
  /// clients (the cleared `server` event) and stops serving. Its own queue
  /// then goes to Supabase as a standalone device's does.
  Future<void> _onClearedElsewhere(int shopId, LanServerView cleared) async {
    final current = record(shopId: shopId);
    if (current != null && current.epoch >= cleared.epoch) return;
    final next = LocalServerRecord(
      shopId: shopId,
      epoch: cleared.epoch,
      claimedAt: cleared.claimedAt,
    );
    await _write(next);
    final transport = LanTransport();
    if (transport.isServing && transport.servingShopId == shopId) {
      await transport.updateServerRecord(next);
      await transport.stopServer();
    }
    await LanAlerts().raise(
      shopId: shopId,
      kind: LanAlertKind.forceCleared,
      title: 'This device stopped serving the store',
      message:
          'While this device was off, the store server was cleared on '
          'another device because it had stopped answering. This device no '
          'longer serves the store; changes made here are sent to the cloud '
          'when it is online.',
    );
    unawaited(LanRouting().evaluate());
  }

  /// Clears the shop's server from a device that isn't it, when that
  /// server has stopped answering: for a user with `Manage
  /// Local Server` who types their password again, on the shop's LAN, no
  /// server having answered for 60 s, and a fresh look (browse and the
  /// known addresses) finding none. The record moves to a higher epoch,
  /// cleared, so a desktop can claim the next one; the old server stops if
  /// it ever comes back (a device tells it). The stock changes still held
  /// for it are listed in the alert, and stay held.
  Future<LanForceClearResult> forceClearServer({
    required int shopId,
    required String password,
  }) async {
    final transport = LanTransport();
    if (!transport.isAvailable ||
        (transport.isServing && transport.servingShopId == shopId)) {
      return LanForceClearResult.notAvailable;
    }
    final bool allowed;
    try {
      allowed = authorization(
        authorized: Authorizations().manageLocalServer,
      );
    } catch (_) {
      return LanForceClearResult.noPermission;
    }
    if (!allowed) return LanForceClearResult.noPermission;
    final user = LoggedInUserFunc().getLoggedInUser()?.loggedInUser;
    final stored = user?.password;
    if (user == null ||
        stored == null ||
        stored.isEmpty ||
        stored != password) {
      return LanForceClearResult.wrongPassword;
    }
    final current = record(shopId: shopId);
    if (current == null || current.isCleared) {
      return LanForceClearResult.alreadyCleared;
    }
    switch (RemoteRouter.route) {
      case LanRoute.lanDown:
        break;
      case LanRoute.lanUp:
        return LanForceClearResult.liveServerFound;
      default:
        return LanForceClearResult.notOnLan;
    }
    final waited = LanRouting().unreachableFor;
    if (waited == null || waited < LanConstants.forceClearAfter) {
      return LanForceClearResult.tooSoon;
    }
    final shopKey = LanShopKeysFunc().get(shopId);
    if (shopKey == null) return LanForceClearResult.notAvailable;
    final preflight = await transport.claimPreflight(
      shopKey: shopKey,
      ownDeviceId: await DeviceIdentity().deviceId(),
      lastKnownAddresses: [
        ...current.lastKnownAddresses,
        for (final paired in LanPairedServersFunc().all()) ...paired.addresses,
      ],
    );
    if (preflight.liveServerFound) {
      return LanForceClearResult.liveServerFound;
    }
    final now = DateTime.now().toUtc();
    final next = LocalServerRecord(
      shopId: shopId,
      epoch: max(current.epoch, preflight.maxEpoch) + 1,
      claimedAt: now,
      claimedByUserId: user.userId,
    );
    await _write(next);
    final old = current.serverDeviceId;
    await mainLocalLog(
      'Local Server force-cleared: shop $shopId, epoch ${next.epoch} '
      '(was $old at ${current.epoch})',
    );
    // With the changes sent to it that it never answered for.
    final held = old == null
        ? const <LanHeldDelta>[]
        : [
            ...heldDeltasOf(LanHandoffs().deltasFor(old)),
            ...heldQueuedFor(old),
          ];
    await LanAlerts().raise(
      shopId: shopId,
      kind: LanAlertKind.forceCleared,
      title: 'Store server cleared',
      message:
          '${user.name} cleared the store server (${_short(old)}), which had '
          'stopped answering. Set another desktop as the store server to '
          'use the store network again.${held.isEmpty ? '' : ' These stock '
                    'changes were sent to the old server and may never reach '
                    'the cloud if it doesn\'t come back: check these items\' '
                    'stock by hand.'}',
      columns: held.isEmpty ? const [] : heldDeltaColumns,
      rows: heldDeltaRows(held),
    );
    unawaited(LanRouting().evaluate());
    return LanForceClearResult.applied;
  }

  Future<void> _write(LocalServerRecord next) async {
    await LocalServerFunc().putRecord(next);
    await LocalServerFunc().raiseEpochFloor(next.shopId, next.epoch);
    _cache[next.shopId] = next;
    notifyListeners();
  }
}
