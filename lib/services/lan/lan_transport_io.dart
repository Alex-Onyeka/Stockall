import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/local_database/shop_logos/shop_logos_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_addresses.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_peer_client.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_server_watch.dart';
import 'package:stockall/services/remote/lan_http_client.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_move_proof.dart';
import 'package:stockall/services/lan/lan_pairing.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_logo_storage.dart';
import 'package:stockall/services/lan/rest/lan_supabase_proxy.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/lan_table_writes.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';
import 'package:stockall/services/lan/sync/lan_invalidator.dart';
import 'package:stockall/services/lan/sync/lan_puller.dart';
import 'package:stockall/services/lan/sync/lan_server_scheduler.dart';
import 'package:stockall/services/lan/sync/lan_server_sync.dart';
import 'package:stockall/services/lan/sync/lan_supabase_reader.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _PairingAttempt {
  _PairingAttempt(this.connection, this.client, this.serverDeviceId);

  final LanConnection connection;
  final LanPairingClient client;
  final String serverDeviceId;
}

/// LAN transport on platforms with dart:io. The server side only ever runs
/// on desktop, and never in the customer-display (alt) window.
class LanTransport implements LanTransportApi {
  static final LanTransport _instance = LanTransport._internal();
  factory LanTransport() => _instance;
  LanTransport._internal();

  /// Replaceable in tests.
  LanDiscoveryBackend discovery = BonsoirDiscoveryBackend();
  Future<List<LanInterface>> Function() interfaces = listLanInterfaces;
  List<int> serverPorts = LanConstants.allPorts;
  Duration browseTimeout = LanConstants.findBrowse;
  Duration claimBrowseTimeout = LanConstants.claimBrowse;

  /// Whether the server can reach Supabase (replaceable in tests).
  bool Function() isOnline = () => ConnectivityProvider().isConnected;

  /// Makes the connection's LAN client (replaceable in tests).
  SupabaseClient Function({
    required LanConnection connection,
    required String token,
    required String deviceId,
    Future<void> Function(
      http.BaseRequest request,
      List<int> body,
      http.StreamedResponse response,
    )?
    onAnswer,
  })
  remoteFactory = createLanRemote;

  @override
  void Function()? onChanged;

  @override
  LanServerViewCallback? onServerView;

  @override
  void Function()? onServerSynced;

  @override
  void Function(Set<String>? tables)? onInvalidate;

  @override
  void Function(Map<String, double> reserved)? onStock;

  @override
  void Function()? onConnected;

  @override
  Future<void> Function(LanServerCandidate winner)? onOutranked;

  @override
  void Function(LanServerCandidate loser)? onOutranks;

  @override
  Future<void> Function(
    int shopId,
    LanServerView from,
    LanServerCandidate to,
  )?
  onMoved;

  @override
  Future<void> Function(int shopId, LanServerView cleared)? onClearedElsewhere;

  Duration loginBrowseTimeout = LanConstants.loginBrowse;

  /// How often a client reads its server's view again while the server's
  /// backfill runs (replaceable in tests).
  Duration backfillPollEvery = LanConstants.backfillPoll;

  /// How long a till's holds outlast its last socket (replaceable in
  /// tests). Read when the server starts.
  Duration holdGrace = LanConstants.holdGrace;

  LanServer? _server;
  HiveRestEngine? _engine;
  LanHandoffStatusSource? _handoffStatus;
  LanPuller? _puller;
  LanInvalidator? _invalidator;
  LanStockService? _stock;

  /// Cart stock holds, while serving.
  LanStockService? get stock => _stock;
  String? _servingDeviceId;

  /// While serving: the look for another server of the shop.
  LanServerWatch? _watch;
  LanServerWatch? get serverWatch => _watch;
  String? _serverFingerprint;

  @override
  LanStockLink? stockLink({String? userId}) {
    final service = _stock;
    final own = _servingDeviceId;
    if (service != null && own != null && _server != null) {
      // The server's own till: the same calls, in process.
      return LanStockLink(
        inProcess: true,
        call: (rpc, params) =>
            service.call(rpc, params, device: own, userId: userId),
        reservedElsewhere: (product) => service.reservedElsewhere(product, own),
      );
    }
    final remote = _client == null ? null : _clientRemote;
    if (remote == null) return null;
    return LanStockLink(
      call: (rpc, params) async {
        final res = await remote.rpc(rpc, params: params);
        return res is Map<String, dynamic>
            ? res
            : Map<String, dynamic>.from(res as Map);
      },
    );
  }

  static Map<String, double> _reservedOf(Object? json) => {
    if (json is Map)
      for (final e in json.entries)
        if (e.value is num) '${e.key}': (e.value as num).toDouble(),
  };
  LanServerScheduler? _scheduler;

  /// The server's pulls from Supabase, while serving.
  LanPuller? get puller => _puller;
  Timer? _syncAfterWrites;
  LocalServerRecord? _serverRecord;
  String? _serverShopKey;

  LanConnection? _client;
  int? _clientShopId;
  String? _clientShopKey;
  LanSessionHeaders? _clientSession;
  LanServerView? _clientView;

  /// The full view the server last gave this client (its internet and
  /// backfill), and the timer that reads it again while a backfill runs.
  Map<String, dynamic>? _clientFull;
  Timer? _backfillPoll;
  SupabaseClient? _clientRemote;
  WebSocket? _clientWs;
  StreamSubscription<dynamic>? _clientWsSub;
  bool _clientClosing = false;
  int _reconnectAttempts = 0;

  _PairingAttempt? _pairing;

  @override
  bool get isAvailable => true;

  @override
  bool get isServing => _server?.isRunning ?? false;

  @override
  int? get servingShopId => isServing ? _serverRecord?.shopId : null;

  @override
  int? get serverPort => _server?.port;

  @override
  String? get pendingPairingCode => _server?.pairing.pendingCode;

  @override
  bool get isClientConnected => _client != null;

  @override
  List<String> get clientAddresses => _addressesOf(_client);

  @override
  SupabaseClient? get lanClient => _clientRemote;

  @override
  LanServerView? get clientServerView => _client == null ? null : _clientView;

  @override
  LanServerHealth? get serverHealth {
    if (_server != null) {
      return LanServerHealth(
        online: isOnline(),
        backfill: LanBackfillStatus.fromJson(_puller?.progress.toJson()),
      );
    }
    final full = _client == null ? null : _clientFull;
    return full == null ? null : LanServerHealth.fromJson(full);
  }

  @override
  List<LanConnectedDevice> connectedDevices() {
    final record = _serverRecord;
    final stock = _stock;
    final own = _servingDeviceId;
    if (record == null || _server == null) return const [];
    final shopId = record.shopId;
    final now = DateTime.now().toUtc();
    final latest = <String, ({String userId, DateTime at})>{};
    try {
      for (final s in LanServerSessionsFunc().sessionsBox.values) {
        if (s.shopId != shopId || s.expiresAt.isBefore(now)) continue;
        final seen = latest[s.deviceId];
        if (seen == null || s.lastUsedAt.isAfter(seen.at)) {
          latest[s.deviceId] = (userId: s.userId, at: s.lastUsedAt);
        }
      }
    } catch (e) {
      unawaited(mainLocalLog('LAN devices: sessions not read: $e'));
    }
    final holds = stock?.holds.toList() ?? const <LanHold>[];
    final sockets = stock?.connected ?? const <String, int>{};
    final devices = {
      if (own != null) own,
      ...latest.keys,
      ...sockets.keys,
      for (final h in holds) h.deviceId,
    };
    String? emailOf(String? userId) {
      if (userId == null) return null;
      try {
        return LanCredentialsFunc().get(shopId, userId)?.email;
      } catch (_) {
        return null;
      }
    }

    final out = [
      for (final d in devices)
        LanConnectedDevice(
          deviceId: d,
          isThisDevice: d == own,
          connected: d == own || (sockets[d] ?? 0) > 0,
          holds: [
            for (final h in holds)
              if (h.deviceId == d)
                (
                  cartId: h.cartId,
                  productUuid: h.productUuid,
                  quantity: h.quantity,
                ),
          ],
          userEmail: emailOf(latest[d]?.userId),
          lastSeen: latest[d]?.at,
        ),
    ];
    out.sort((a, b) {
      if (a.isThisDevice != b.isThisDevice) return a.isThisDevice ? -1 : 1;
      if (a.connected != b.connected) return a.connected ? -1 : 1;
      final at = a.lastSeen;
      final bt = b.lastSeen;
      if (at == null || bt == null) return at == null ? 1 : -1;
      return bt.compareTo(at);
    });
    return out;
  }

  @override
  Future<int> releaseDeviceHolds(String deviceId) async {
    final stock = _stock;
    if (stock == null) return 0;
    final released = await stock.releaseDevice(deviceId);
    onChanged?.call();
    return released;
  }

  bool _serverAllowed() {
    return (Platform.isMacOS || Platform.isWindows || Platform.isLinux) &&
        !runningInAltWindow;
  }

  Future<List<String>> _candidates(Iterable<String> raw) async {
    return buildCandidates(
      raw,
      await interfaces(),
      isWindows: Platform.isWindows,
    );
  }

  List<String> _addressesOf(LanConnection? connection) {
    if (connection == null) return const [];
    return connection.endpoints.map((e) => e.address).toSet().toList();
  }

  Future<List<LanFound>> _browseAll(String type, Duration timeout) async {
    try {
      return await discovery.browse(type, timeout).toList();
    } catch (e) {
      await mainLocalLog('LAN browse $type failed: $e');
      return const [];
    }
  }

  Map<String, String> _txt(String shopKey, int epoch, String deviceId) {
    return {
      'v': LanConstants.protocolVersion,
      't': shopTag(shopKey),
      'tv': LanConstants.shopTagVersion,
      'e': '$epoch',
      'd': deviceId,
    };
  }

  String _instanceName(String prefix, String deviceId) {
    final short = deviceId.length >= 6 ? deviceId.substring(0, 6) : deviceId;
    return '$prefix-$short';
  }

  // ---------------------------------------------------------------- server

  @override
  Future<String> serverFingerprint() async {
    return (await LanTlsIdentity.loadOrCreate()).fingerprint;
  }

  @override
  Future<LanClaimPreflight> claimPreflight({
    required String shopKey,
    required String ownDeviceId,
    List<String> lastKnownAddresses = const [],
  }) async {
    final tag = shopTag(shopKey);
    final browsed = await Future.wait([
      _browseAll(LanConstants.serverServiceType, claimBrowseTimeout),
      _browseAll(LanConstants.peerServiceType, claimBrowseTimeout),
    ]);
    var maxEpoch = 0;
    var liveServerFound = false;

    for (final peer in browsed[1]) {
      if (peer.shopTag != tag || peer.deviceId == ownDeviceId) continue;
      maxEpoch = max(maxEpoch, peer.epoch);
    }

    final probes = <List<LanEndpoint>>[];
    for (final server in browsed[0]) {
      if (server.shopTag != tag || server.deviceId == ownDeviceId) continue;
      maxEpoch = max(maxEpoch, server.epoch);
      probes.add([
        for (final a in await _candidates(server.addresses))
          LanEndpoint(a, server.port),
      ]);
    }
    final known = await _candidates(lastKnownAddresses);
    if (known.isNotEmpty) {
      probes.add([
        for (final a in known)
          for (final p in LanConstants.allPorts) LanEndpoint(a, p),
      ]);
    }

    // An advert can be stale, so a server only counts as live if it
    // answers and says it isn't cleared.
    for (final endpoints in probes) {
      final view = await _probeServerView(endpoints);
      if (view == null || view.shopTag != tag) continue;
      maxEpoch = max(maxEpoch, view.epoch);
      if (!view.cleared && view.serverDeviceId != ownDeviceId) {
        liveServerFound = true;
      }
    }
    return LanClaimPreflight(
      liveServerFound: liveServerFound,
      maxEpoch: maxEpoch,
    );
  }

  Future<LanServerView?> _probeServerView(List<LanEndpoint> endpoints) async {
    if (endpoints.isEmpty) return null;
    final connection = await LanConnection.openUnpinned(endpoints);
    if (connection == null) return null;
    try {
      return LanServerView.fromJson(await connection.getJson('/v1/server'));
    } catch (_) {
      return null;
    } finally {
      connection.close();
    }
  }

  @override
  Future<int> startServer({
    required LocalServerRecord record,
    required String deviceId,
    required String shopKey,
  }) async {
    if (!_serverAllowed()) {
      throw UnsupportedError(
        'The LAN server runs on desktop only, never in the alt window',
      );
    }
    if (record.serverDeviceId != deviceId) {
      throw StateError('The server record does not name this device');
    }
    await stopServer();
    final identity = await LanTlsIdentity.loadOrCreate();
    _serverFingerprint = identity.fingerprint;
    int servedShop() => _serverRecord!.shopId;
    bool online() => isOnline();
    // Other stores' reads and writes go to Supabase as this device.
    final proxy = LanSupabaseProxy.of(() => Supabase.instance.client);
    final logos = LanLogoStorage(
      publicUrlOf: (path) =>
          Supabase.instance.client.storage.from('logos').getPublicUrl(path),
      storedLogo: () => ShopLogosFunc().shopLogosBox.get(servedShop()),
      // The app's offline logo path: its sync uploads it.
      queueLogo: (logo) async {
        final created = CreatedShopLogosFunc().createdShopLogosBox;
        await created.clear();
        await created.put(servedShop(), logo);
        await ShopLogosFunc().shopLogosBox.clear();
        await ShopLogosFunc().shopLogosBox.put(servedShop(), logo);
      },
    );
    final tables = lanTables(
      shopId: servedShop,
      logos: logos,
      staff: _serverStaff,
      onShopSaved: _showSavedShop,
    );
    // Kept over logout for the same store; another store's are dropped.
    await LanAppliedDeltasFunc().forShop(record.shopId);
    final deltas = LanDeltaRpcs(
      rpcs: lanDeltaRpcs(
        shopId: servedShop,
        remoteLookup: (table, uuid) async => online()
            ? proxy.lookup(table, uuid)
            : LanRemoteRow.unknown,
        wasDeleted: (table, uuid) =>
            LanDeletedItemsFunc().contains(table, uuid),
        recordDeleted: (table, uuid) =>
            LanDeletedItemsFunc().add(table, uuid),
      ),
      applied: const HiveAppliedDeltas(),
      journal: const HiveDeltaJournal(),
      onApplied: _scheduleSync,
    );
    // Cart stock holds: under the same lock as the deltas and pulls;
    // a checkout applies its sale's deltas and releases its cart at once.
    final stock = LanStockService(
      exclusive: deltas.runExclusive,
      product: (uuid) => ProductsFunc().productBox.get(uuid),
      prepareCheckout: (body) =>
          deltas.prepare('update_product_quantities', body),
      applyCheckout: (body) => deltas.applyHoldingLock(
        'update_product_quantities',
        body,
        skipUnknown: true,
      ),
      ownDeviceId: () => deviceId,
      send: (event) {
        _server?.broadcast(event);
        // The server's own till shows what other tills hold too.
        onStock?.call(_reservedOf(event['reserved']));
      },
      productChanges: () =>
          ProductsFunc().productBox.watch().map((e) => '${e.key}'),
      grace: holdGrace,
    );
    final engine = HiveRestEngine(
      tables: tables,
      shopId: servedShop,
      manageDepartments: () =>
          ShopFunc().shopBox.get(_serverRecord!.shopId)?.manageDepartments ==
          true,
      isOnline: online,
      proxy: proxy,
      rpcs: deltas,
      onWrite: _scheduleSync,
      onlineOnlyTables: LanConstants.onlineOnlyTables,
      onlineOnlyRpcs: LanConstants.onlineOnlyRpcs,
      onDenied: (what, who) => unawaited(
        mainLocalLog('LAN server refused $what for ${who.userId}: no permission'),
      ),
      // A user or a store's members changed on Supabase: refresh logins.
      onMembersChanged: () =>
          unawaited(LanUserBackfill().ensure(servedShop()).catchError((_) => false)),
      onDeleted: (table, key) async {
        if (lanDeltaTables.contains(table)) {
          await LanDeletedItemsFunc().add(table, key);
        }
      },
      stock: stock,
    );
    // The served store's data from Supabase into this server's boxes:
    // pages stored under the delta lock, never while this device's own sync
    // runs.
    final puller = LanPuller(
      tables: tables,
      reader: LanSupabaseReader.of(() => Supabase.instance.client),
      shopId: servedShop,
      exclusive: deltas.runExclusive,
      canPull: () => online() && !returnData().isSyncing,
      onRemoteDeleted: (table, uuid) =>
          LanDeletedItemsFunc().add(table, uuid),
    );
    // Writes are queued before they are acknowledged: empty queues mean
    // everything acknowledged so far was sent to Supabase.
    final handoffStatus = LanHandoffStatusSource(
      queuesEmpty: serverQueuesEmpty,
    );
    final server = LanServer(
      identity: identity,
      deviceId: deviceId,
      serverView: _currentView,
      fullServerView: _fullView,
      auth: LanAuthService(shopId: () => _serverRecord!.shopId),
      rest: engine,
      storage: logos,
      handoffStatus: handoffStatus,
      onPairingChanged: () => onChanged?.call(),
      onDeviceOnline: stock.deviceOnline,
      onDeviceOffline: stock.deviceOffline,
      peerProof: _peerProof,
      onSuperseded: _onSupersededNotice,
      onHandedOver: (device, epoch) async {
        await LanAlertsFunc().recordHandedOver(device, epoch);
        await mainLocalLog(
          'LAN server: $device handed over everything from epoch $epoch',
        );
      },
      handedOver: () => [
        for (final h in LanAlertsFunc().handedOver())
          {'device': h.device, 'epoch': h.epoch},
      ],
      // Only paired devices sign in (S4).
      admission: const LanHiveAdmission(),
      acceptMoved: _acceptMoved,
      onSteppingDown: _onSteppingDown,
      onRefreshCredentials: () async {
        try {
          await LanUserBackfill().ensure(servedShop());
          await mainLocalLog('LAN: logins fetched again for a till');
        } catch (e) {
          await mainLocalLog('LAN: logins not fetched again: $e');
        }
      },
    );
    // Every change to a served table, batched, tells LAN clients.
    final invalidator = LanInvalidator(tables: tables, send: server.broadcast);
    _engine = engine;
    _handoffStatus = handoffStatus;
    _puller = puller;
    _invalidator = invalidator;
    _stock = stock;
    _servingDeviceId = deviceId;
    // The holds kept from before a restart; other devices get the grace
    // from now to come back.
    stock.start();
    // From now on the providers' own Supabase fetches are skipped.
    LanServerSync.pullerActive = true;
    _serverRecord = record;
    _serverShopKey = shopKey;
    final port = await server.start(ports: serverPorts);
    _server = server;
    invalidator.start();
    await _advertiseServer();
    // Another server of the shop (a split network that rejoined): the
    // lower one stops.
    final ownTag = shopTag(shopKey);
    _watch = LanServerWatch(
      find: () => _findProven(shopKey, deviceId),
      self: () => LanServerView.fromRecord(_serverRecord!, ownTag),
      onOutranked: (winner) async => await onOutranked?.call(winner),
      onOutranks: (loser) async {
        // Proven a server of the shop that this one outranks: a move it
        // signs lets its paired tills sign in here.
        await LanPairedDevicesFunc().addFormerServer(loser.fingerprint);
        onOutranks?.call(loser);
        final port = _server?.port;
        final fingerprint = _serverFingerprint;
        if (port == null || fingerprint == null) return;
        await notifyLanServerSuperseded(
          loser: loser,
          selfAddresses: await ownLanAddresses(),
          selfPort: port,
          selfFingerprint: fingerprint,
        );
      },
    )..start();
    onChanged?.call();
    await mainLocalLog('LAN server started on port $port, epoch ${record.epoch}');
    // A backfill if none ever completed (a fresh claim), otherwise each
    // table reconciled when its day is up, else pulled by its cursor.
    if (online()) unawaited(puller.catchUp());
    // Then the schedule: pulls, reconciles and the logins.
    _scheduler = LanServerScheduler(
      puller: puller,
      refreshCredentials: () async {
        await LanUserBackfill().ensure(servedShop());
      },
      online: online,
      syncing: () => returnData().isSyncing,
    )..start();
    return port;
  }

  Map<String, dynamic> _currentView() {
    final record = _serverRecord!;
    return LanServerView.fromRecord(record, shopTag(_serverShopKey!)).toJson();
  }

  Map<String, dynamic> _fullView() {
    return {
      ...LanServerView.fullJson(_serverRecord!, shopTag(_serverShopKey!)),
      // Whether it reaches the internet: clients show online-only screens
      // only then.
      'online': isOnline(),
      // Where the backfill is (the status shows "still loading").
      if (_puller case final puller?) 'backfill': puller.progress.toJson(),
    };
  }

  Future<void> _advertiseServer() async {
    final record = _serverRecord;
    final server = _server;
    final port = server?.port;
    if (record == null || server == null || port == null) return;
    try {
      await discovery.advertiseServer(
        name: _instanceName('Stockall', server.deviceId),
        port: port,
        txt: _txt(_serverShopKey!, record.epoch, server.deviceId),
      );
    } catch (e) {
      // The server still answers last-known addresses, QR and sweep.
      await mainLocalLog('LAN server advert failed: $e');
    }
  }

  @override
  Future<void> updateServerRecord(LocalServerRecord record) async {
    final server = _server;
    if (server == null || _serverRecord?.shopId != record.shopId) return;
    _serverRecord = record;
    server.broadcastServerEvent();
    if (!record.isCleared) await _advertiseServer();
    onChanged?.call();
  }

  // ------------------------------------------------------ two servers

  /// `POST /v1/peer/prove`: this server's claim, proved for [nonce].
  Map<String, dynamic>? _peerProof(String nonce) {
    final record = _serverRecord;
    final shopKey = _serverShopKey;
    final fingerprint = _serverFingerprint;
    if (record == null || shopKey == null || fingerprint == null) return null;
    final view = LanServerView.fromRecord(record, shopTag(shopKey));
    return {
      'view': view.toJson(),
      'mac': LanPeerProof.mac(
        shopKey: shopKey,
        nonce: nonce,
        fingerprint: fingerprint,
        view: view,
      ),
    };
  }

  /// `POST /v1/server/superseded`: another server says it outranks this
  /// one. Proven here, pinned to the certificate it names, before anything
  /// changes.
  void _onSupersededNotice(Map<String, dynamic> body) {
    if (body['kind'] == 'cleared') {
      _onClearedNotice(body);
      return;
    }
    final record = _serverRecord;
    final shopKey = _serverShopKey;
    final addresses = body['addresses'];
    final port = body['port'];
    final fingerprint = body['fingerprint'];
    if (record == null ||
        shopKey == null ||
        body['kind'] != 'server' ||
        addresses is! List ||
        port is! int ||
        fingerprint is! String) {
      return;
    }
    _track(() async {
      final winner = await proveServer(
        shopKey: shopKey,
        addresses: [
          for (final a in addresses)
            if (a is String) a,
        ],
        port: port,
        fingerprint: fingerprint,
      );
      final current = _serverRecord;
      if (winner == null || current == null) {
        await mainLocalLog('LAN server: a superseded notice was not proven');
        return;
      }
      final self = LanServerView.fromRecord(current, shopTag(shopKey));
      if (pickOutranking([winner], self) == null) {
        await mainLocalLog(
          'LAN server: ${winner.view.serverDeviceId} does not outrank this '
          'server; notice ignored',
        );
        return;
      }
      await onOutranked?.call(winner);
    }());
  }

  /// Superseded notices still being proven (see [noticesHandled]).
  final Set<Future<void>> _pendingNotices = {};

  void _track(Future<void> work) {
    _pendingNotices.add(work);
    unawaited(work.whenComplete(() => _pendingNotices.remove(work)));
  }

  /// Completes once every superseded notice received so far was proven or
  /// refused (tests wait on it instead of sleeping).
  @visibleForTesting
  Future<void> noticesHandled() => Future.wait(List.of(_pendingNotices));

  /// `POST /v1/server/superseded {kind: cleared, view, mac}`: a
  /// device of the shop says the shop's server was cleared at a higher
  /// epoch while this one was away. Proven by an HMAC from the shop key
  /// over the cleared view, bound to this server's certificate (so it
  /// can't be replayed to another server).
  void _onClearedNotice(Map<String, dynamic> body) {
    final record = _serverRecord;
    final shopKey = _serverShopKey;
    final fingerprint = _serverFingerprint;
    final viewJson = body['view'];
    final mac = body['mac'];
    final view = viewJson is Map
        ? LanServerView.fromJson(Map<String, dynamic>.from(viewJson))
        : null;
    if (record == null ||
        shopKey == null ||
        fingerprint == null ||
        view == null ||
        mac is! String) {
      return;
    }
    if (!view.cleared ||
        view.epoch <= record.epoch ||
        !LanPeerProof.verify(
          shopKey: shopKey,
          nonce: LanPeerProof.clearedNotice,
          fingerprint: fingerprint,
          view: view,
          mac: mac,
        )) {
      unawaited(mainLocalLog('LAN server: a cleared notice was not proven'));
      return;
    }
    unawaited(mainLocalLog(
      'LAN server: the shop\'s server was cleared at epoch ${view.epoch} '
      'while this one was away; stopping',
    ));
    unawaited(onClearedElsewhere?.call(record.shopId, view));
  }

  /// The proven servers of the shop, other than [ownDeviceId], seen in
  /// one browse.
  Future<List<LanServerCandidate>> _findProven(
    String shopKey,
    String ownDeviceId, {
    Duration timeout = LanConstants.serverWatchBrowse,
  }) async {
    final tag = shopTag(shopKey);
    final found = await _browseAll(LanConstants.serverServiceType, timeout);
    final proven = <LanServerCandidate>[];
    final seen = <String>{};
    for (final f in found) {
      final device = f.deviceId;
      if (f.shopTag != tag || device == null || device == ownDeviceId) {
        continue;
      }
      if (!seen.add(device)) continue;
      final candidate = await proveServer(
        shopKey: shopKey,
        addresses: f.addresses,
        port: f.port,
      );
      if (candidate != null) proven.add(candidate);
    }
    return proven;
  }

  @override
  Future<LanServerCandidate?> proveServer({
    required String shopKey,
    required List<String> addresses,
    required int port,
    String? fingerprint,
  }) async {
    return proveLanServer(
      shopKey: shopKey,
      endpoints: [
        for (final a in await _candidates(addresses)) LanEndpoint(a, port),
      ],
      pin: fingerprint,
    );
  }

  @override
  Future<List<LanServerCandidate>> findProvenServers({
    required String shopKey,
    required String ownDeviceId,
    Duration timeout = LanConstants.serverWatchBrowse,
  }) => _findProven(shopKey, ownDeviceId, timeout: timeout);

  @override
  Future<LanServerCandidate?> findOutrankingServer({
    required String shopKey,
    required String ownDeviceId,
    required LanServerView self,
    Duration timeout = LanConstants.serverWatchBrowse,
  }) async {
    return pickOutranking(
      await _findProven(shopKey, ownDeviceId, timeout: timeout),
      self,
    );
  }

  @override
  void broadcastMoved(LanServerCandidate winner) {
    final server = _server;
    final record = _serverRecord;
    final shopKey = _serverShopKey;
    final device = _servingDeviceId;
    if (server == null || record == null || shopKey == null || device == null) {
      return;
    }
    // Signed with this server's certificate key: its tills pinned that
    // certificate, so only they can tell this move from a forged one. The
    // devices paired here go with it: the new server lets them sign in.
    final paired = server.admission?.deviceIds() ?? const <String>[];
    final text = LanMoveProof.message(
      shopTag: shopTag(shopKey),
      fromDeviceId: device,
      fromEpoch: record.epoch,
      to: winner,
      paired: paired,
    );
    server.broadcast({
      'type': LanConstants.movedEvent,
      'to': winner.toJson(),
      'from_device_id': device,
      'from_epoch': record.epoch,
      'paired': paired,
      'cert': server.identity.certificatePem,
      'sig': LanMoveProof.sign(server.identity.privateKeyPem, text),
    });
  }

  @override
  Future<void> announceSteppingDown(LanServerCandidate winner) async {
    final port = _server?.port;
    final fingerprint = _serverFingerprint;
    if (port == null || fingerprint == null) return;
    final connection = await LanConnection.open([
      for (final a in winner.addresses) LanEndpoint(a, winner.port),
    ], pin: winner.fingerprint);
    if (connection == null) return;
    try {
      await connection
          .postJson('/v1/server/stepping-down', {
            'addresses': await ownLanAddresses(),
            'port': port,
            'fingerprint': fingerprint,
          })
          .timeout(LanConstants.restTimeout);
    } catch (e) {
      await mainLocalLog('LAN server: stepping-down notice not delivered: $e');
    } finally {
      connection.close();
    }
  }

  /// `POST /v1/server/stepping-down`: a server of the shop stops for this
  /// one. Proven here (pinned to the certificate it names, outranked by
  /// this server) while it still serves; then a move it signs lets its
  /// paired tills sign in here.
  Future<void> _onSteppingDown(Map<String, dynamic> body) async {
    final shopKey = _serverShopKey;
    final addresses = body['addresses'];
    final port = body['port'];
    final fingerprint = body['fingerprint'];
    if (shopKey == null ||
        addresses is! List ||
        port is! int ||
        fingerprint is! String) {
      return;
    }
    final loser = await proveServer(
      shopKey: shopKey,
      addresses: [
        for (final a in addresses)
          if (a is String) a,
      ],
      port: port,
      fingerprint: fingerprint,
    );
    final current = _serverRecord;
    if (loser == null || current == null) {
      await mainLocalLog('LAN server: a stepping-down notice was not proven');
      return;
    }
    final self = LanServerView.fromRecord(current, shopTag(shopKey));
    if (loser.view.cleared || loser.rankAgainstView(self) >= 0) {
      await mainLocalLog(
        'LAN server: ${loser.view.serverDeviceId} does not rank below this '
        'server; stepping-down notice ignored',
      );
      return;
    }
    await LanPairedDevicesFunc().addFormerServer(loser.fingerprint);
  }

  /// A `moved` event a till presents at login (S4): signed by a former
  /// server of the shop (one this server proved it outranks, or one this
  /// device itself trusted as a client), naming this server, and listing
  /// [deviceId] as paired there.
  bool _acceptMoved(Map<String, dynamic> moved, String deviceId) {
    final record = _serverRecord;
    final shopKey = _serverShopKey;
    final own = _serverFingerprint;
    final to = LanServerCandidate.fromJson(moved['to']);
    final cert = moved['cert'];
    final sig = moved['sig'];
    final from = moved['from_device_id'];
    final fromEpoch = moved['from_epoch'];
    final pairedJson = moved['paired'];
    if (record == null ||
        shopKey == null ||
        own == null ||
        to == null ||
        cert is! String ||
        sig is! String ||
        from is! String ||
        fromEpoch is! int ||
        pairedJson is! List) {
      return false;
    }
    final paired = [
      for (final d in pairedJson)
        if (d is String) d,
    ];
    final signer = LanMoveProof.fingerprintOf(cert);
    if (signer == null ||
        !paired.contains(deviceId) ||
        to.fingerprint.toLowerCase() != own.toLowerCase() ||
        to.view.serverDeviceId != _servingDeviceId ||
        to.view.shopTag != shopTag(shopKey) ||
        !(LanPairedDevicesFunc().isFormerServer(signer) ||
            LanPairedServersFunc().isTrusted(signer))) {
      return false;
    }
    return LanMoveProof.verify(
      certificatePem: cert,
      pinnedFingerprint: signer,
      text: LanMoveProof.message(
        shopTag: to.view.shopTag,
        fromDeviceId: from,
        fromEpoch: fromEpoch,
        to: to,
        paired: paired,
      ),
      signature: sig,
    );
  }

  /// Whether a `moved` event was signed by the server this device is
  /// connected to (the certificate it pinned) for the claim it serves.
  bool _movedIsVouched(
    Map<dynamic, dynamic> event,
    LanServerView from,
    LanServerCandidate to,
    String pin,
  ) {
    final cert = event['cert'];
    final sig = event['sig'];
    final paired = event['paired'] ?? const [];
    if (cert is! String || sig is! String || paired is! List) return false;
    if (event['from_device_id'] != from.serverDeviceId ||
        event['from_epoch'] != from.epoch ||
        from.serverDeviceId == null) {
      return false;
    }
    return LanMoveProof.verify(
      certificatePem: cert,
      pinnedFingerprint: pin,
      text: LanMoveProof.message(
        shopTag: from.shopTag,
        fromDeviceId: from.serverDeviceId!,
        fromEpoch: from.epoch,
        to: to,
        paired: [
          for (final d in paired)
            if (d is String) d,
        ],
      ),
      signature: sig,
    );
  }


  @override
  void broadcastHandedOver(int epoch) {
    final device = _servingDeviceId;
    if (device == null) return;
    _server?.broadcast({
      'type': LanConstants.handedOverEvent,
      'server_device_id': device,
      'epoch': epoch,
    });
  }

  /// While this device pushes the queue it kept as a server, a write
  /// the new server refuses for permission is set aside for Supabase.
  Future<bool> _setAsideRefused(http.BaseRequest request, List<int> body) async {
    if (LanAlertsFunc().pushingShop() == null) return false;
    final view = _clientView;
    final serverDeviceId = view?.serverDeviceId;
    if (view == null || serverDeviceId == null) return false;
    // Only a write that was kept is answered as taken.
    final kept = await LanHandoffs().recordRefused(
      method: request.method,
      url: request.url,
      headers: request.headers,
      body: body,
      serverDeviceId: serverDeviceId,
      epoch: view.epoch,
    );
    if (!kept) return false;
    await mainLocalLog(
      'LAN: ${request.method} ${request.url.path} refused for permission; '
      'kept for Supabase',
    );
    return true;
  }

  @override
  Future<void> stopServer() async {
    final server = _server;
    if (server == null) return;
    try {
      await discovery.stopServerAdvert();
    } catch (_) {}
    await _invalidator?.stop();
    _invalidator = null;
    await _stock?.stop();
    _stock = null;
    _servingDeviceId = null;
    _watch?.stop();
    _watch = null;
    _serverFingerprint = null;
    _scheduler?.stop();
    _scheduler = null;
    await server.stop();
    _syncAfterWrites?.cancel();
    _syncAfterWrites = null;
    await _engine?.dispose();
    _engine = null;
    _handoffStatus = null;
    _puller?.stop();
    _puller = null;
    LanServerSync.pullerActive = false;
    _server = null;
    _serverRecord = null;
    _serverShopKey = null;
    onChanged?.call();
    await mainLocalLog('LAN server stopped');
  }

  LanStaff _serverStaff() {
    try {
      final user = currentUser();
      return (id: user.userId, name: user.name);
    } catch (_) {
      return (id: null, name: null);
    }
  }

  /// A shop changed over the LAN replaces the server's in-memory copy, as
  /// the app does with an updated shop from Supabase, so the server's own
  /// screens show it and don't write an older copy back.
  void _showSavedShop(TempShopClass shop) {
    try {
      final provider = ShopProvider();
      final shops = provider.userShops;
      final i = shops.indexWhere((s) => s.shopId == shop.shopId);
      if (i == -1) return;
      shops[i] = shop;
      provider.setShops(shops);
    } catch (e) {
      unawaited(mainLocalLog('LAN: could not refresh the shop: $e'));
    }
  }

  /// LAN writes land in the server's queues; its own sync sends them to
  /// Supabase, once per burst of writes.
  void _scheduleSync() {
    _syncAfterWrites?.cancel();
    _syncAfterWrites = Timer(LanConstants.syncAfterWrites, () {
      _syncAfterWrites = null;
      if (_server != null) syncData();
    });
  }

  @override
  void notifyServerSynced() {
    final server = _server;
    final source = _handoffStatus;
    if (server == null || source == null) return;
    // Supabase now has this server's changes: pull the busy tables.
    _scheduler?.afterSync();
    if (!serverQueuesEmpty()) return;
    server.broadcast(const {'type': 'synced'});
  }

  @override
  void interfaceChanged() {
    final scheduler = _scheduler;
    if (scheduler != null) unawaited(scheduler.tick());
    // Its clients read its view again (its `online` changed).
    _server?.broadcastServerEvent();
    onChanged?.call();
  }

  @override
  void cancelServerPairing() {
    final server = _server;
    if (server == null) return;
    server.pairing.cancel();
    onChanged?.call();
  }

  @override
  Future<String?> pairingQrPayload() async {
    final server = _server;
    final port = server?.port;
    if (server == null || port == null) return null;
    return LanPairingQr(
      fingerprint: server.identity.fingerprint,
      port: port,
      addresses: ownAddresses(await interfaces()),
      deviceId: server.deviceId,
      token: server.issueQrToken(),
    ).encode();
  }

  // ------------------------------------------------------------------ peer

  @override
  Future<void> advertisePeer({
    required String shopKey,
    required int epoch,
    required String deviceId,
  }) async {
    try {
      await discovery.advertisePeer(
        name: _instanceName('Stockall-peer', deviceId),
        txt: _txt(shopKey, epoch, deviceId),
      );
    } catch (e) {
      await mainLocalLog('LAN peer advert failed: $e');
    }
  }

  @override
  Future<bool> shopPeerVisible({
    required String shopKey,
    required String ownDeviceId,
  }) async {
    final tag = shopTag(shopKey);
    final found = await Future.wait([
      _browseAll(LanConstants.peerServiceType, loginBrowseTimeout),
      _browseAll(LanConstants.serverServiceType, loginBrowseTimeout),
    ]);
    return found
        .expand((f) => f)
        .any((f) => f.shopTag == tag && f.deviceId != ownDeviceId);
  }

  @override
  Future<List<String>> ownLanAddresses() async {
    return ownAddresses(await interfaces());
  }

  @override
  Future<void> stopPeer() async {
    try {
      await discovery.stopPeerAdvert();
    } catch (_) {}
  }

  // ---------------------------------------------------------------- client

  @override
  Future<List<LanFound>> browseServers() {
    return _browseAll(LanConstants.serverServiceType, browseTimeout);
  }

  @override
  Future<bool> connectToServer({
    required int shopId,
    required String shopKey,
    required String pin,
    required List<String> addresses,
    required int port,
    required String token,
    required String deviceId,
    bool quick = false,
    Map<String, dynamic>? Function(LanServerView view, String fingerprint)?
    staleNotice,
  }) async {
    await disconnectClient();
    final tag = shopTag(shopKey);
    final session = LanSessionHeaders(token: token, deviceId: deviceId);
    final connection = await _findServer(
      matches: (found) => found.shopTag == tag,
      pin: pin,
      known: addresses,
      port: port,
      quick: quick,
    );
    if (connection == null) return false;

    LanServerView? view;
    Map<String, dynamic>? full;
    try {
      full = await connection.getJson('/v1/server', session: session);
      view = LanServerView.fromJson(full);
    } catch (_) {
      view = null;
    }
    if (view == null || view.shopTag != tag) {
      connection.close();
      return false;
    }
    // A server the shop moved away from while it was off: not
    // used; it is told, when there is something to tell it.
    final notice = staleNotice?.call(view, connection.pin);
    if (notice != null) {
      await mainLocalLog(
        'LAN: ${view.serverDeviceId} (epoch ${view.epoch}) is not the '
        "shop's server any more; not used",
      );
      if (notice.isNotEmpty) {
        try {
          await connection.postJson('/v1/server/superseded', notice);
        } catch (e) {
          await mainLocalLog('LAN: superseded notice not delivered: $e');
        }
      }
      connection.close();
      return false;
    }
    _client = connection;
    _clientShopId = shopId;
    _clientShopKey = shopKey;
    _clientSession = session;
    _clientView = view;
    _clientFull = full;
    _pollBackfill();
    // One LAN client (and JSON-decoding isolate) for this connection.
    LanHttpClient.setAsideRefused = _setAsideRefused;
    _clientRemote = remoteFactory(
      connection: connection,
      token: token,
      deviceId: deviceId,
      onAnswer: _recordHandoff,
    );
    _clientClosing = false;
    _reconnectAttempts = 0;
    onServerView?.call(shopId, view, _addressesOf(connection), connection.pin);
    await _openClientSocket();
    onChanged?.call();
    return true;
  }

  /// Finds the paired server: mDNS first, then the known addresses (last
  /// known, then pairing data), then a /24 sweep. [quick] (login, logout)
  /// tries the known addresses first, browses for less time and skips the
  /// sweep, so an unreachable server doesn't hold up the fallback login.
  Future<LanConnection?> _findServer({
    required bool Function(LanFound found) matches,
    required String pin,
    required List<String> known,
    required int port,
    bool quick = false,
  }) async {
    final ports = {port, ...LanConstants.allPorts}.toList();

    Future<List<LanEndpoint>> fromMdns() async {
      final found = await _browseAll(
        LanConstants.serverServiceType,
        quick ? loginBrowseTimeout : browseTimeout,
      );
      return [
        for (final f in found.where(matches))
          for (final a in await _candidates(f.addresses)) LanEndpoint(a, f.port),
      ];
    }

    Future<List<LanEndpoint>> fromKnown() async {
      return [
        for (final a in await _candidates(known))
          for (final p in ports) LanEndpoint(a, p),
      ];
    }

    Future<List<LanEndpoint>> fromSweep() async {
      return tcpSweep(sweepTargets(await interfaces()), ports);
    }

    final steps = quick
        ? [fromKnown, fromMdns]
        : [fromMdns, fromKnown, fromSweep];
    for (final step in steps) {
      final endpoints = await step();
      if (endpoints.isEmpty) continue;
      final connection = await LanConnection.open(
        endpoints,
        pin: pin,
        refresh: fromMdns,
      );
      if (connection != null) return connection;
    }
    return null;
  }

  Future<void> _refreshServerView() async {
    final connection = _client;
    final shopId = _clientShopId;
    final shopKey = _clientShopKey;
    if (connection == null || shopId == null || shopKey == null) return;
    try {
      final full = await connection.getJson(
        '/v1/server',
        session: _clientSession,
      );
      final view = LanServerView.fromJson(full);
      if (view == null || view.shopTag != shopTag(shopKey)) return;
      if (!identical(_client, connection)) return;
      _clientView = view;
      _clientFull = full;
      _pollBackfill();
      onChanged?.call();
      onServerView?.call(
        shopId,
        view,
        _addressesOf(connection),
        connection.pin,
      );
    } catch (e) {
      await mainLocalLog('LAN server view refresh failed: $e');
    }
  }

  /// While the server's backfill runs, its view is read again now and then
  /// (the progress shown on this device).
  void _pollBackfill() {
    _backfillPoll?.cancel();
    _backfillPoll = null;
    final backfill = serverHealth?.backfill;
    if (_client == null || backfill == null || backfill.done) return;
    _backfillPoll = Timer(
      backfillPollEvery,
      () => unawaited(_refreshServerView()),
    );
  }

  Future<void> _openClientSocket() async {
    final connection = _client;
    if (connection == null) return;
    try {
      final ws = await connection.openWebSocket(session: _clientSession);
      _clientWs = ws;
      _clientWsSub = ws.listen(
        (message) {
          _reconnectAttempts = 0;
          if (message is! String) return;
          try {
            final decoded = jsonDecode(message);
            if (decoded is Map && decoded['type'] == 'server') {
              unawaited(_refreshServerView());
            }
            if (decoded is Map && decoded['type'] == 'synced') {
              onServerSynced?.call();
            }
            if (decoded is Map &&
                decoded['type'] == 'invalidate' &&
                decoded['tables'] is List) {
              onInvalidate?.call({
                for (final t in decoded['tables'] as List)
                  if (t is String) t,
              });
            }
            if (decoded is Map && decoded['type'] == 'stock') {
              onStock?.call(_reservedOf(decoded['reserved']));
            }
            if (decoded is Map &&
                decoded['type'] == LanConstants.handedOverEvent &&
                decoded['server_device_id'] is String &&
                decoded['epoch'] is int) {
              // A former server's queue is all at this one.
              unawaited(_endHandedOver(
                decoded['server_device_id'] as String,
                decoded['epoch'] as int,
              ));
            }
            if (decoded is Map &&
                decoded['type'] == LanConstants.movedEvent) {
              // The server says the shop's server is now another one:
              // proven before anything changes.
              final to = LanServerCandidate.fromJson(decoded['to']);
              final from = _clientView;
              final shopId = _clientShopId;
              final pin = _client?.pin;
              if (to != null && from != null && shopId != null && pin != null) {
                // Only a move signed with the pinned certificate's key is
                // followed; anything else waits for a person to pair.
                if (_movedIsVouched(decoded, from, to, pin)) {
                  // Presented at the first login there (S4); kept on disk
                  // until then.
                  unawaited(() async {
                    await LanPairedDevicesFunc().putMove(
                      to.fingerprint.toLowerCase(),
                      Map<String, dynamic>.from(decoded),
                    );
                    await onMoved?.call(shopId, from, to);
                  }());
                } else {
                  unawaited(
                    mainLocalLog(
                      'LAN: a moved event not signed by this server; '
                      'not followed',
                    ),
                  );
                }
              }
            }
          } catch (_) {}
        },
        onDone: () => unawaited(_onClientSocketClosed()),
        onError: (Object _) => unawaited(_onClientSocketClosed()),
        cancelOnError: true,
      );
      // The server knows this device is here again: its holds are
      // re-synced.
      onConnected?.call();
    } catch (e) {
      await mainLocalLog('LAN ws connect failed: $e');
      unawaited(_onClientSocketClosed());
    }
  }

  Future<void> _onClientSocketClosed() async {
    _clientWs = null;
    final subscription = _clientWsSub;
    _clientWsSub = null;
    await subscription?.cancel();
    final connection = _client;
    if (connection == null || _clientClosing) return;
    final failedOver =
        _reconnectAttempts < 3 && await connection.failover();
    // Meanwhile this device may have connected to another server (it
    // followed a `moved` event): leave that connection alone.
    if (!identical(_client, connection)) return;
    if (!failedOver) {
      await mainLocalLog('LAN server unreachable; working offline');
      await disconnectClient();
      return;
    }
    _reconnectAttempts++;
    await _refreshServerView();
    await _openClientSocket();
    // Changes made while the socket was down were never announced.
    if (_clientWs != null) onInvalidate?.call(null);
    onChanged?.call();
  }

  @override
  Future<void> disconnectClient() async {
    _clientClosing = true;
    final subscription = _clientWsSub;
    _clientWsSub = null;
    await subscription?.cancel();
    try {
      await _clientWs?.close();
    } catch (_) {}
    _clientWs = null;
    final hadClient = _client != null;
    final remote = _clientRemote;
    _clientRemote = null;
    // Nothing may reach the client being disposed: the router stops using
    // it first (routing picks the next route).
    if (remote != null && RemoteRouter.usingLan) RemoteRouter.useNothing();
    // Ends the connection's JSON-decoding isolate.
    try {
      await remote?.dispose();
    } catch (_) {}
    _client?.close();
    _client = null;
    _clientShopId = null;
    _clientShopKey = null;
    _clientSession = null;
    _clientView = null;
    _clientFull = null;
    _backfillPoll?.cancel();
    _backfillPoll = null;
    _reconnectAttempts = 0;
    if (hadClient) onChanged?.call();
  }

  Future<void> _endHandedOver(String device, int epoch) async {
    final ended = await LanHandoffs().endDeltasFrom(device, epoch);
    if (ended > 0) {
      await mainLocalLog(
        'LAN: $device handed over; $ended stock/account changes end here',
      );
    }
  }

  @override
  Future<bool> reportHandedOver(int epoch) async {
    final connection = _client;
    if (connection == null) return false;
    try {
      await connection.postJson('/v1/handoff/handed-over', {
        'epoch': epoch,
      }, session: _clientSession);
      return true;
    } catch (e) {
      await mainLocalLog('LAN: handed-over not acknowledged: $e');
      return false;
    }
  }

  /// Keeps a copy of every write the server acknowledges (handoffs),
  /// before the answer reaches the queue that deletes its entry.
  Future<void> _recordHandoff(
    http.BaseRequest request,
    List<int> body,
    http.StreamedResponse response,
  ) async {
    final view = _clientView;
    final serverDeviceId = view?.serverDeviceId;
    if (view == null || serverDeviceId == null) return;
    await LanHandoffs().recordAnswer(
      method: request.method,
      url: request.url,
      headers: request.headers,
      body: body,
      status: response.statusCode,
      answerHeaders: response.headers,
      serverDeviceId: serverDeviceId,
      epoch: view.epoch,
    );
  }

  @override
  Future<LanHandoffStatus?> handoffStatus() async {
    final connection = _client;
    if (connection == null) return null;
    try {
      return LanHandoffStatus.fromJson(
        await connection.getJson('/v1/handoff/status', session: _clientSession),
      );
    } catch (e) {
      await mainLocalLog('LAN handoff status failed: $e');
      return null;
    }
  }

  // ------------------------------------------------------------------ auth

  @override
  Future<LanLoginOutcome> loginToPairedServer({
    required String email,
    required String password,
    required String deviceId,
    String? serverDeviceId,
  }) async {
    // A password only goes to a certificate a person paired (code or QR),
    // or one such a server signed a move to.
    final trust = LanPairedServersFunc();
    final paired = trust.all()
      ..retainWhere(
        (s) =>
            (serverDeviceId == null || s.serverDeviceId == serverDeviceId) &&
            trust.isTrusted(s.certFingerprint),
      )
      ..sort((a, b) => b.pairedAt.compareTo(a.pairedAt));
    final notPairedBy = <String>[];
    for (final server in paired) {
      final connection = await _findPaired(server);
      if (connection == null) continue;
      try {
        // The secret this device got when it paired there, or the signed
        // move it followed there (S4).
        final fingerprint = server.certFingerprint.toLowerCase();
        final secret = LanPairedDevicesFunc().secretFor(fingerprint);
        final moved = LanPairedDevicesFunc().moveTo(fingerprint);
        final body = await connection.postJson('/v1/auth/login', {
          'email': email,
          'password': password,
          'device_id': deviceId,
          if (secret != null) 'pair_secret': secret,
          if (secret == null && moved != null) 'moved': moved,
        });
        if (body['pair_secret'] case final String issued) {
          await LanPairedDevicesFunc().putSecret(fingerprint, issued);
        }
        final token = body['token'];
        final user = body['user'];
        final shop = body['shop'];
        final shopKey = body['shop_key'];
        if (token is! String ||
            user is! Map<String, dynamic> ||
            shop is! Map<String, dynamic> ||
            shopKey is! String) {
          await mainLocalLog('LAN login: incomplete response');
          return const LanLoginOutcome(LanAuthResult.failed);
        }
        // Signed in there: the move it followed is no longer needed.
        await LanPairedDevicesFunc().removeMove(fingerprint);
        await LanPairedServersFunc().put(
          server.withAddresses(
            _addressesOf(connection),
            newPort: connection.current.port,
          ),
        );
        return LanLoginOutcome(
          LanAuthResult.ok,
          serverDeviceId: server.serverDeviceId,
          token: token,
          expiresAt: DateTime.tryParse('${body['expires_at']}'),
          user: user,
          shop: shop,
          shopKey: shopKey,
        );
      } on LanHttpException catch (e) {
        if (e.statusCode == 403 && e.errorCode == 'not_paired') {
          // The server doesn't know this device: as if it weren't there,
          // until a person pairs them.
          await mainLocalLog(
            'LAN login: ${server.serverDeviceId} says this device is not '
            'paired with it; pair again',
          );
          notPairedBy.add(server.serverDeviceId);
          continue;
        }
        return LanLoginOutcome(_authResultOf(e));
      } catch (e) {
        await mainLocalLog('LAN login failed: $e');
        return const LanLoginOutcome(LanAuthResult.failed);
      } finally {
        connection.close();
      }
    }
    return LanLoginOutcome(
      LanAuthResult.unreachable,
      notPairedBy: notPairedBy,
    );
  }

  @override
  Future<bool> requestCredentialRefresh({required String deviceId}) async {
    final trust = LanPairedServersFunc();
    final paired = trust.all()
      ..retainWhere((s) => trust.isTrusted(s.certFingerprint))
      ..sort((a, b) => b.pairedAt.compareTo(a.pairedAt));
    for (final server in paired) {
      final secret = LanPairedDevicesFunc().secretFor(
        server.certFingerprint.toLowerCase(),
      );
      if (secret == null) continue;
      final connection = await _findPaired(server);
      if (connection == null) continue;
      try {
        await connection.postJson('/v1/auth/refresh', {
          'device_id': deviceId,
          'pair_secret': secret,
        });
        await mainLocalLog(
          'LAN: asked ${server.serverDeviceId} to fetch its logins again',
        );
        return true;
      } on LanHttpException catch (e) {
        // Asked moments ago (by this till or another): it is fetching.
        if (e.statusCode == 429) return true;
        await mainLocalLog('LAN: login refresh refused: ${e.statusCode}');
      } catch (e) {
        await mainLocalLog('LAN: login refresh not asked: $e');
      } finally {
        connection.close();
      }
    }
    return false;
  }

  @override
  Future<void> logoutFromServer({
    required String serverDeviceId,
    required String token,
    required String deviceId,
  }) async {
    final server = LanPairedServersFunc().get(serverDeviceId);
    if (server == null) return;
    LanConnection? connection;
    try {
      connection = await _findPaired(
        server,
      ).timeout(LanConstants.logoutTimeout, onTimeout: () => null);
      await connection
          ?.postJson(
            '/v1/auth/logout',
            const {},
            session: LanSessionHeaders(token: token, deviceId: deviceId),
          )
          .timeout(LanConstants.logoutTimeout);
    } catch (e) {
      await mainLocalLog('LAN logout not acknowledged: $e');
    } finally {
      connection?.close();
    }
  }

  @override
  Future<LanAuthResult> verifyPasswordOnServer({
    required String serverDeviceId,
    required String token,
    required String deviceId,
    required String password,
  }) async {
    final server = LanPairedServersFunc().get(serverDeviceId);
    if (server == null) return LanAuthResult.unreachable;
    final connection = await _findPaired(server);
    if (connection == null) return LanAuthResult.unreachable;
    try {
      await connection.postJson(
        '/v1/auth/verify-password',
        {'password': password},
        session: LanSessionHeaders(token: token, deviceId: deviceId),
      );
      return LanAuthResult.ok;
    } on LanHttpException catch (e) {
      return _authResultOf(e);
    } catch (e) {
      await mainLocalLog('LAN password check failed: $e');
      return LanAuthResult.failed;
    } finally {
      connection.close();
    }
  }

  /// The paired server, quickly: its known addresses, then mDNS by device
  /// id. Pinned to the paired certificate.
  Future<LanConnection?> _findPaired(LanPairedServer server) {
    return _findServer(
      matches: (found) => found.deviceId == server.serverDeviceId,
      pin: server.certFingerprint,
      known: server.addresses,
      port: server.port,
      quick: true,
    );
  }

  LanAuthResult _authResultOf(LanHttpException e) {
    switch (e.statusCode) {
      case 401:
      case 403:
        return LanAuthResult.invalidCredentials;
      case 429:
        return LanAuthResult.rateLimited;
    }
    return LanAuthResult.failed;
  }

  // --------------------------------------------------------------- pairing

  @override
  Future<LanPairOutcome> beginPairing({
    required List<String> addresses,
    required int port,
  }) async {
    await cancelPairing();
    final endpoints = [
      for (final a in await _candidates(addresses)) LanEndpoint(a, port),
    ];
    final connection = await LanConnection.openUnpinned(endpoints);
    if (connection == null) {
      return const LanPairOutcome(
        LanPairResult.failed,
        message: 'Server not reachable',
      );
    }
    try {
      final hello = await connection.getJson('/v1/hello');
      final serverDeviceId = hello['device_id'];
      if (serverDeviceId is! String || serverDeviceId.isEmpty) {
        throw const FormatException('Bad hello');
      }
      final client = LanPairingClient(
        deviceId: await DeviceIdentity().deviceId(),
        fingerprintSeen: connection.pin,
      );
      final started = await connection.postJson('/v1/pair/start', {
        'device_id': client.deviceId,
        'commit': client.commit,
      });
      client.started(
        sessionId: started['session_id'] as String,
        ns: started['ns'] as String,
      );
      await connection.postJson('/v1/pair/reveal', {
        'session_id': client.sessionId,
        'nc': client.nc,
      });
      _pairing = _PairingAttempt(connection, client, serverDeviceId);
      return const LanPairOutcome(LanPairResult.awaitingCode);
    } on LanHttpException catch (e) {
      connection.close();
      return LanPairOutcome(
        LanPairResult.failed,
        message: e.errorCode ?? 'HTTP ${e.statusCode}',
      );
    } catch (e) {
      connection.close();
      return LanPairOutcome(LanPairResult.failed, message: e.toString());
    }
  }

  @override
  Future<LanPairOutcome> submitPairingCode(String code) async {
    final attempt = _pairing;
    if (attempt == null) {
      return const LanPairOutcome(
        LanPairResult.failed,
        message: 'No pairing in progress',
      );
    }
    if (!attempt.client.matches(code)) {
      await cancelPairing();
      return const LanPairOutcome(
        LanPairResult.codeMismatch,
        message: "Code doesn't match: this may not be your server",
      );
    }
    try {
      final confirmed = await attempt.connection.postJson('/v1/pair/confirm', {
        'session_id': attempt.client.sessionId,
        'proof': attempt.client.proof,
      });
      // What this device presents to sign in there (S4).
      if (confirmed['pair_secret'] case final String secret) {
        await LanPairedDevicesFunc().putSecret(
          attempt.connection.pin.toLowerCase(),
          secret,
        );
      }
    } catch (e) {
      // The code matched, so the pin is proven; without the secret the
      // server refuses this device's logins until it pairs again.
      await mainLocalLog('LAN pairing confirm not acknowledged: $e');
    }
    final paired = LanPairedServer(
      serverDeviceId: attempt.serverDeviceId,
      certFingerprint: attempt.connection.pin,
      port: attempt.connection.current.port,
      addresses: _addressesOf(attempt.connection),
      pairedAt: DateTime.now().toUtc(),
      label: _instanceName('Stockall', attempt.serverDeviceId),
    );
    await LanPairedServersFunc().put(paired);
    await LanPairedServersFunc().markPairedByPerson(paired.certFingerprint);
    _pairing = null;
    attempt.connection.close();
    return LanPairOutcome(LanPairResult.paired, server: paired);
  }

  @override
  Future<LanPairOutcome> pairFromQr(String payload) async {
    final qr = LanPairingQr.decode(payload);
    if (qr == null) {
      return const LanPairOutcome(
        LanPairResult.failed,
        message: 'Not a Stockall pairing code',
      );
    }
    final endpoints = [
      for (final a in await _candidates(qr.addresses)) LanEndpoint(a, qr.port),
    ];
    final connection = await LanConnection.open(
      endpoints,
      pin: qr.fingerprint,
    );
    if (connection == null) {
      return const LanPairOutcome(
        LanPairResult.failed,
        message: 'Server not reachable',
      );
    }
    try {
      final hello = await connection.getJson('/v1/hello');
      if (hello['device_id'] != qr.deviceId) {
        return const LanPairOutcome(
          LanPairResult.failed,
          message: 'Unexpected server',
        );
      }
      // The QR code's token, for the secret this device signs in with.
      final token = qr.token;
      if (token != null) {
        final admitted = await connection.postJson('/v1/pair/qr', {
          'token': token,
          'device_id': await DeviceIdentity().deviceId(),
        });
        if (admitted['pair_secret'] case final String secret) {
          await LanPairedDevicesFunc().putSecret(
            qr.fingerprint.toLowerCase(),
            secret,
          );
        }
      }
      final paired = LanPairedServer(
        serverDeviceId: qr.deviceId,
        certFingerprint: qr.fingerprint,
        port: connection.current.port,
        addresses: _addressesOf(connection),
        pairedAt: DateTime.now().toUtc(),
        label: _instanceName('Stockall', qr.deviceId),
      );
      await LanPairedServersFunc().put(paired);
      await LanPairedServersFunc().markPairedByPerson(paired.certFingerprint);
      return LanPairOutcome(LanPairResult.paired, server: paired);
    } catch (e) {
      return LanPairOutcome(LanPairResult.failed, message: e.toString());
    } finally {
      connection.close();
    }
  }

  /// Ends this device's pairing attempt, and tells the server, so a
  /// mistyped code or a cancel doesn't keep other devices from pairing
  /// until the session expires.
  @override
  Future<void> cancelPairing() async {
    final attempt = _pairing;
    _pairing = null;
    if (attempt == null) return;
    final sessionId = attempt.client.sessionId;
    if (sessionId != null) {
      try {
        await attempt.connection
            .postJson('/v1/pair/abort', {'session_id': sessionId})
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        await mainLocalLog('LAN pairing abort not acknowledged: $e');
      }
    }
    attempt.connection.close();
  }
}
