import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_transport.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/lan/sync/lan_invalidator.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Whether no sync is running and every queue the LAN server's writes add
/// to ([lanQueues]) is empty: then everything it acknowledged has reached
/// Supabase. A queue box that isn't open counts as not empty (its entries
/// may still be on disk), so a handoff is never ended too soon.
bool serverQueuesEmpty({
  bool Function()? syncing,
  Map<String, bool Function()>? queues,
}) {
  try {
    if ((syncing ?? () => returnData().isSyncing)()) return false;
  } catch (_) {
    return false;
  }
  for (final q in (queues ?? lanQueues()).entries) {
    if (!lanQueueEmpty(q.key, q.value)) return false;
  }
  return true;
}

/// Whether the queue box [name] is open and [isEmpty] says it holds
/// nothing.
bool lanQueueEmpty(String name, bool Function() isEmpty) {
  if (!Hive.isBoxOpen(name)) return false;
  try {
    return isEmpty();
  } catch (_) {
    return false;
  }
}

/// Whether this device is on the shop's LAN, as far as it can tell.
enum LanPresence { onLan, offLan, unsure }

/// The routing rule:
/// - this device serves the shop → its own backend is Supabase;
/// - no LAN session for the shop → Supabase, as before;
/// - the server answers → the server;
/// - on the LAN (or unsure) without the server → offline, queue;
/// - off the LAN → Supabase directly when online.
LanRoute decideLanRoute({
  required bool serving,
  required bool hasSession,
  required bool serverReachable,
  required LanPresence presence,
}) {
  if (serving) return LanRoute.server;
  if (!hasSession) return LanRoute.standalone;
  if (serverReachable) return LanRoute.lanUp;
  return presence == LanPresence.offLan ? LanRoute.offLan : LanRoute.lanDown;
}

/// Whether one of [own] is in the same private IPv4 /24 as one of
/// [server] (the subnet the LAN sweep assumes too).
bool sharesSubnet(Iterable<String> own, Iterable<String> server) {
  String? prefix(String address) {
    final parts = address.split('.');
    if (parts.length != 4 || parts.any((p) => int.tryParse(p) == null)) {
      return null;
    }
    final a = int.parse(parts[0]);
    final b = int.parse(parts[1]);
    final private =
        a == 10 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
    return private ? parts.take(3).join('.') : null;
  }

  final servers = server.map(prefix).whereType<String>().toSet();
  return own.any((o) => servers.contains(prefix(o)));
}

/// What routing needs from the app; replaceable in tests.
class LanRoutingDeps {
  const LanRoutingDeps({
    this.shopId = LanRoutingDeps.currentShopId,
    required this.serving,
    required this.hasSession,
    required this.connectedClient,
    required this.connect,
    required this.presence,
    required this.interfaceUp,
    required this.sync,
    required this.handoffStatus,
    required this.supabaseTarget,
    required this.notifyServerSynced,
    this.handoffs,
    this.follow,
    this.currentServer,
    this.lanTarget,
    this.reportHandedOver,
    this.hasCloudSession,
  });

  /// Whether this device holds a Supabase session. A device signed in only
  /// through the store server has none: away from the store's network it
  /// queues instead of syncing. Null counts as having one.
  final bool Function()? hasCloudSession;

  /// The signed-in shop, or null. By default [currentShopId].
  final int? Function() shopId;

  /// The current shop as stored on this device (not the shops loaded
  /// into memory, which are empty until they are fetched).
  static int? currentShopId() {
    final shops = CurrentShopFunc();
    if (!Hive.isBoxOpen(shops.currentShopBoxName)) return null;
    try {
      return shops.getCurrentShop()?.currentShopId;
    } catch (_) {
      return null;
    }
  }
  final bool Function(int shopId) serving;
  final bool Function(int shopId) hasSession;

  /// The connection's LAN client, when connected.
  final SupabaseClient? Function() connectedClient;
  final Future<bool> Function(int shopId, {required bool quick}) connect;
  final Future<LanPresence> Function(int shopId) presence;
  final bool Function() interfaceUp;
  final Future<void> Function() sync;
  final Future<LanHandoffStatus?> Function() handoffStatus;
  final LanHandoffTarget Function() supabaseTarget;
  final void Function() notifyServerSynced;
  final LanHandoffs? handoffs;

  /// The paired server can't be reached; looks for a proven
  /// server of the shop that outranks it and follows it (pairs, signs in).
  /// True when this device now has a session there.
  final Future<bool> Function(int shopId)? follow;

  /// The view of the server this device is connected to.
  final LanServerView? Function()? currentServer;

  /// That server, as a replay target.
  final LanHandoffTarget? Function()? lanTarget;

  /// Tells that server this device's queue from when it served
  /// at the epoch given is all there.
  final Future<bool> Function(int epoch)? reportHandedOver;

  factory LanRoutingDeps.app() {
    final transport = LanTransport();
    return LanRoutingDeps(
      serving: (shop) =>
          transport.isServing && transport.servingShopId == shop,
      hasSession: (shop) =>
          LanClientSessionFunc().get(shop) != null &&
          LanShopKeysFunc().get(shop) != null,
      connectedClient: () =>
          transport.isClientConnected ? transport.lanClient : null,
      connect: (shop, {required quick}) =>
          LocalServerProvider().connectToServer(shopId: shop, quick: quick),
      presence: _appPresence,
      interfaceUp: () => ConnectivityProvider().interfaceUp,
      sync: () => returnData().syncData(),
      handoffStatus: transport.handoffStatus,
      supabaseTarget: () => LanHandoffTarget.supabase(Supabase.instance.client),
      notifyServerSynced: transport.notifyServerSynced,
      follow: (shop) => LocalServerProvider().findAndFollowServer(shop),
      currentServer: () => transport.clientServerView,
      lanTarget: () {
        final lan = transport.isClientConnected ? transport.lanClient : null;
        return lan == null ? null : LanHandoffTarget.lan(lan);
      },
      reportHandedOver: transport.reportHandedOver,
      hasCloudSession: () {
        try {
          return Supabase.instance.client.auth.currentSession != null;
        } catch (_) {
          return false;
        }
      },
    );
  }

  /// On the LAN when this device shares a subnet with the server's last
  /// known addresses, or another device of the shop is visible; off it
  /// when neither; unsure when it can't tell (then treated as on it).
  static Future<LanPresence> _appPresence(int shop) async {
    try {
      final transport = LanTransport();
      final own = await transport.ownLanAddresses();
      final session = LanClientSessionFunc().get(shop);
      final paired = session == null
          ? null
          : LanPairedServersFunc().get(session.serverDeviceId);
      final serverAddresses = [
        ...?LocalServerFunc().getRecord(shop)?.lastKnownAddresses,
        ...?paired?.addresses,
      ];
      if (sharesSubnet(own, serverAddresses)) return LanPresence.onLan;
      final shopKey = LanShopKeysFunc().get(shop);
      if (shopKey != null &&
          await transport.shopPeerVisible(
            shopKey: shopKey,
            ownDeviceId: await DeviceIdentity().deviceId(),
          )) {
        return LanPresence.onLan;
      }
      return LanPresence.offLan;
    } catch (e) {
      await mainLocalLog('LAN presence unknown: $e');
      return LanPresence.unsure;
    }
  }
}

/// Keeps [RemoteRouter] on the right backend: on app start, when the
/// network or the server connection changes, after a LAN login, and on a
/// timer while the server can't be reached. Not a provider: the UI reads
/// the route from [RemoteRouter] and `ConnectivityProvider.isConnected`.
class LanRouting {
  static final LanRouting _instance = LanRouting._internal();
  factory LanRouting() => _instance;
  LanRouting._internal();

  LanRoutingDeps? _deps;
  LanRoutingDeps get deps => _deps ??= LanRoutingDeps.app();
  set deps(LanRoutingDeps value) => _deps = value;

  LanHandoffs get _handoffs => deps.handoffs ?? LanHandoffs();

  bool _started = false;
  Timer? _timer;
  StreamSubscription<BoxEvent>? _shopWatch;
  int? _lastShop;
  Future<LanRoute>? _running;
  bool _again = false;
  bool? _lastInterface;
  bool? _lastConnected;
  bool? _lastServing;

  /// Since when the route has been `lanDown` (no server answering on the
  /// shop's LAN); null on any other route.
  DateTime? _unreachableSince;

  @visibleForTesting
  DateTime Function() now = DateTime.now;

  /// How long no server has answered while on the shop's LAN; null when
  /// the route isn't `lanDown`.
  Duration? get unreachableFor {
    final since = _unreachableSince;
    if (since == null || RemoteRouter.route != LanRoute.lanDown) return null;
    return now().difference(since);
  }

  /// Main isolate, main window only (never the alt window).
  void start() {
    if (_started) return;
    _started = true;
    // A device with a LAN session sends nothing anywhere until the first
    // evaluation has picked its route.
    final d = deps;
    final shop = d.shopId();
    if (shop != null && !d.serving(shop) && d.hasSession(shop)) {
      RemoteRouter.useNothing();
    }
    _lastShop = shop;
    final shops = CurrentShopFunc();
    if (Hive.isBoxOpen(shops.currentShopBoxName)) {
      _shopWatch = shops.currentShopBox.watch().listen((_) => _onShopChanged());
    }
    RemoteRouter.onBeforeSync = beforeSync;
    RemoteRouter.onAfterSync = afterSync;
    if (LanTransport().isAvailable) {
      LanTransport().onServerSynced = () => unawaited(confirm());
      LanTransport().onInvalidate = (tables) => tables == null
          ? LanInvalidations().receiveAll()
          : LanInvalidations().receive(tables);
      ConnectivityProvider().addListener(_onConnectivity);
      LocalServerProvider().addListener(_onLanChanged);
    }
    unawaited(evaluate());
  }

  @visibleForTesting
  void stop() {
    _timer?.cancel();
    _timer = null;
    unawaited(_shopWatch?.cancel());
    _shopWatch = null;
    if (_started && LanTransport().isAvailable) {
      ConnectivityProvider().removeListener(_onConnectivity);
      LocalServerProvider().removeListener(_onLanChanged);
      LanTransport().onServerSynced = null;
      LanTransport().onInvalidate = null;
    }
    _started = false;
    RemoteRouter.onBeforeSync = null;
    RemoteRouter.onAfterSync = null;
  }

  /// The current shop changed (a login, a store switch, a logout).
  void _onShopChanged() {
    final shop = deps.shopId();
    if (shop == _lastShop) return;
    _lastShop = shop;
    unawaited(evaluate());
  }

  void _onConnectivity() {
    final up = deps.interfaceUp();
    if (up == _lastInterface) return;
    _lastInterface = up;
    unawaited(evaluate());
    // A serving device's pulls and login refresh.
    if (LanTransport().isAvailable) LanTransport().interfaceChanged();
  }

  void _onLanChanged() {
    final shop = deps.shopId();
    final connected = deps.connectedClient() != null;
    final serving = shop != null && deps.serving(shop);
    if (connected == _lastConnected && serving == _lastServing) return;
    _lastConnected = connected;
    _lastServing = serving;
    unawaited(evaluate(quick: true));
  }

  /// Works out the route and switches to it. Runs one at a time; a call
  /// during a run runs once more after it.
  Future<LanRoute> evaluate({bool quick = false}) {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final run = _evaluateSafely(quick).whenComplete(() {
      _running = null;
      if (_again) {
        _again = false;
        unawaited(evaluate(quick: true));
      }
    });
    _running = run;
    return run;
  }

  /// Never throws: on an error the route stays as it was (and is tried
  /// again on the next trigger).
  Future<LanRoute> _evaluateSafely(bool quick) async {
    try {
      return await _evaluate(quick);
    } catch (e, s) {
      await mainLocalLog('LAN routing failed: $e', error: e, stackTrace: s);
      return RemoteRouter.route;
    }
  }

  Future<LanRoute> _evaluate(bool quick) async {
    final before = RemoteRouter.route;
    final d = deps;
    final shop = d.shopId();
    LanRoute route;
    if (shop == null) {
      route = LanRoute.standalone;
      RemoteRouter.useSupabase();
    } else if (d.serving(shop)) {
      route = LanRoute.server;
      RemoteRouter.useSupabase(LanRoute.server);
    } else if (!d.hasSession(shop)) {
      route = LanRoute.standalone;
      RemoteRouter.useSupabase();
    } else {
      var client = d.connectedClient();
      if (client == null && d.interfaceUp()) {
        if (await d.connect(shop, quick: quick)) client = d.connectedClient();
      }
      // The paired server is gone: the shop may have moved to another
      // server while this device missed the `moved` event.
      final follow = d.follow;
      if (client == null &&
          d.interfaceUp() &&
          follow != null &&
          await follow(shop) &&
          await d.connect(shop, quick: true)) {
        client = d.connectedClient();
      }
      route = decideLanRoute(
        serving: false,
        hasSession: true,
        serverReachable: client != null,
        presence: client != null || !d.interfaceUp()
            ? LanPresence.unsure
            : await d.presence(shop),
      );
      switch (route) {
        case LanRoute.lanUp:
          RemoteRouter.useLan(client!);
        case LanRoute.offLan:
          RemoteRouter.useOffLan(
            needsSignIn: !(d.hasCloudSession?.call() ?? true),
          );
        default:
          RemoteRouter.useNothing();
      }
    }
    _lastShop = shop;
    _lastConnected = d.connectedClient() != null;
    _lastServing = shop != null && d.serving(shop);
    _lastInterface = d.interfaceUp();
    if (route != LanRoute.lanDown) {
      _unreachableSince = null;
    } else if (before != LanRoute.lanDown || _unreachableSince == null) {
      _unreachableSince = now();
    }
    _schedule(route);
    // Following another server keeps the route lanUp: writes handed to the
    // one before it are replayed whenever any are held.
    if (route == LanRoute.lanUp && route == before) {
      unawaited(replaySuperseded());
    }
    if (route != before) {
      await mainLocalLog('LAN route: ${before.name} → ${route.name}');
      // The server is back (sync to it) or the device left the LAN (the
      // direct sync replays handoffs first, in beforeSync).
      if (route == LanRoute.lanUp) {
        // Writes handed to a server the shop moved away from go to this
        // one first.
        unawaited(() async {
          await replaySuperseded();
          await _syncSafely();
        }());
      } else if (route == LanRoute.offLan &&
          d.interfaceUp() &&
          !RemoteRouter.needsCloudSignIn) {
        unawaited(_syncSafely());
      }
    }
    return route;
  }

  void _schedule(LanRoute route) {
    _timer?.cancel();
    _timer = null;
    final every = switch (route) {
      LanRoute.lanDown => LanConstants.lanDownRetry,
      LanRoute.offLan => LanConstants.offLanRecheck,
      _ => null,
    };
    if (every == null || !_started) return;
    _timer = Timer(every, () => unawaited(evaluate(quick: true)));
  }

  Future<void> _syncSafely() async {
    try {
      await deps.sync();
    } catch (e) {
      await mainLocalLog('LAN route sync failed: $e');
    }
  }

  /// Off the LAN, the direct sync sends held handoffs first, so a record
  /// never reaches Supabase before one it depends on.
  Future<void> beforeSync() async {
    if (RemoteRouter.route != LanRoute.offLan) return;
    // No cloud session: nothing can be replayed to Supabase yet.
    if (RemoteRouter.needsCloudSignIn) return;
    final result = await _handoffs.replay(deps.supabaseTarget());
    if (result.sent > 0 || result.kept > 0) {
      await mainLocalLog(
        'LAN handoffs replayed to Supabase: ${result.sent} sent, '
        '${result.kept} held${result.stopped ? ', stopped' : ''}',
      );
    }
    final stale = _handoffs.staleDeltas();
    if (stale > 0) {
      await mainLocalLog(
        '⚠️ $stale stock/account changes have waited over '
        '${LanConstants.staleDeltaHandoff.inDays} days for the store server',
      );
    }
  }

  Future<void> afterSync() async {
    switch (RemoteRouter.route) {
      case LanRoute.lanUp:
        await replaySuperseded();
        await confirm();
        // Checkouts the server hasn't confirmed.
        unawaited(LanStockClient().retryPending());
        await afterDemotionSync();
      case LanRoute.server:
        deps.notifyServerSynced();
      default:
        break;
    }
  }

  /// After a demotion, on each LAN sync:
  /// - writes the new server refused for permission go straight to
  ///   Supabase once nothing else this device sent is still on its way
  ///   (what they need is there by then); 23503 keeps one for later;
  /// - once the queue this device kept as a server is empty, the alert
  ///   says so, listing what is still set aside and the products now below
  ///   zero (sold on both sides of the split), and the new server is told
  ///   (its tills end their copies of this device's deltas).
  Future<void> afterDemotionSync() async {
    final alerts = LanAlertsFunc();
    if (!alerts.isOpen) return;
    final held = _handoffs.all();
    final refused = [
      for (final (_, h) in held)
        if (h.kind == LanHandoffKind.refused) h,
    ];
    if (refused.isNotEmpty &&
        refused.length == held.length &&
        deps.interfaceUp()) {
      final result = await _handoffs.replay(
        deps.supabaseTarget(),
        refusedOnly: true,
      );
      await mainLocalLog(
        'LAN refused writes sent to Supabase: ${result.sent} sent, '
        '${result.kept} held${result.stopped ? ', stopped' : ''}',
      );
    }
    final shop = alerts.pushingShop();
    if (shop != null && serverQueuesEmpty()) {
      await alerts.setPushingShop(null);
      final left = _handoffs.refused();
      final tables = {for (final h in left) h.path.split('/').first}.toList()
        ..sort();
      final belowZero = productsBelowZero(shop);
      final sent = left.isEmpty
          ? 'Every change made on this device while it served the store has '
                'reached the store server.'
          : 'Every change made on this device while it served the store has '
                'reached the store server, except ${left.length} that the '
                'person signed in here may not make (${tables.join(', ')}). '
                'They will be sent straight to the cloud when this device is '
                'online.';
      final check = belowZero.isEmpty
          ? ''
          : ' Items sold on both sides of the split are now below zero: '
                'check their stock.';
      await LanAlerts().raise(
        shopId: shop,
        kind: LanAlertKind.merged,
        title: 'Changes sent to the store server',
        message: '$sent$check',
        columns: belowZero.isEmpty ? const [] : const ['Item', 'In stock'],
        rows: belowZero,
      );
    }
    // Once the queue is empty, the new server is told.
    final epoch = alerts.handingOverEpoch();
    final report = deps.reportHandedOver;
    if (epoch == null ||
        report == null ||
        alerts.pushingShop() != null ||
        !serverQueuesEmpty() ||
        RemoteRouter.route != LanRoute.lanUp) {
      return;
    }
    if (await report(epoch)) {
      await alerts.setHandingOverEpoch(null);
      await mainLocalLog(
        'LAN: told the store server everything from epoch $epoch is there',
      );
    }
  }

  /// The shop's products with stock below zero on this device: name and
  /// quantity (the merge report).
  static List<List<String>> productsBelowZero(int shopId) {
    try {
      final products = [
        for (final p in ProductsFunc().productBox.values)
          if (p.shopId == shopId && (p.quantity ?? 0) < 0) p,
      ]..sort((a, b) => a.name.compareTo(b.name));
      return [
        for (final p in products)
          [
            p.name,
            p.quantity! == p.quantity!.roundToDouble()
                ? p.quantity!.toStringAsFixed(0)
                : '${p.quantity}',
          ],
      ];
    } catch (_) {
      return const [];
    }
  }

  /// REST writes handed to a server the shop has moved away
  /// from are sent to the server this device is connected to now, oldest
  /// first, with the last-write-wins guard; its answers become handoffs to
  /// it. Deltas are not sent: their server delivers them (see
  /// [LanHandoffs.endDeltasFrom]). One run at a time; never throws.
  Future<void> replaySuperseded() =>
      _replaying ??= _replaySuperseded().whenComplete(() => _replaying = null);

  Future<void>? _replaying;

  Future<void> _replaySuperseded() async {
    try {
      if (RemoteRouter.route != LanRoute.lanUp) return;
      final view = deps.currentServer?.call();
      final device = view?.serverDeviceId;
      if (view == null || device == null) return;
      bool superseded(LanHandoff h) =>
          h.kind == LanHandoffKind.rest &&
          LanHandoffs.isSuperseded(h, device, view.epoch);
      if (!_handoffs.all().any((e) => superseded(e.$2))) return;
      final target = deps.lanTarget?.call();
      if (target == null) return;
      final result = await _handoffs.replay(target, only: superseded);
      await mainLocalLog(
        'LAN handoffs to a former server replayed to $device: '
        '${result.sent} sent${result.stopped ? ', stopped' : ''}',
      );
    } catch (e) {
      await mainLocalLog('LAN handoff replay to the server failed: $e');
    }
  }

  /// Ends the handoffs the server says reached Supabase.
  Future<void> confirm() async {
    if (RemoteRouter.route != LanRoute.lanUp) return;
    final status = await deps.handoffStatus();
    if (status == null) return;
    final done = await _handoffs.confirm(status);
    if (done > 0) await mainLocalLog('LAN handoffs confirmed: $done');
  }
}
