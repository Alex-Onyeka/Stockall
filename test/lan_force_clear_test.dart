import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/components/alert_dialogues/lan_server_alert.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';
import 'helpers/lan_peer_server.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

/// mDNS as the tests set it: the servers and other devices "seen".
class _FakeDiscovery implements LanDiscoveryBackend {
  List<LanFound> servers = [];
  List<LanFound> peers = [];

  @override
  Future<void> advertiseServer({
    required String name,
    required int port,
    required Map<String, String> txt,
  }) async {}

  @override
  Future<void> stopServerAdvert() async {}

  @override
  Future<void> advertisePeer({
    required String name,
    required Map<String, String> txt,
  }) async {}

  @override
  Future<void> stopPeerAdvert() async {}

  @override
  Stream<LanFound> browse(String type, Duration timeout) => Stream.fromIterable(
    type == LanConstants.serverServiceType ? servers : peers,
  );
}

/// End to end: this test's app is a till of the shop whose
/// server, "old-desk" (its own isolate and Hive), stops answering. Ada is
/// signed in with `Manage Local Server`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to real servers over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  const access = ['Make Sale', 'Manage Local Server'];
  final discovery = _FakeDiscovery();
  late PeerServer old;
  var shift = Duration.zero;

  TempUserClass ada({List<String> access = access}) => TempUserClass(
    userId: 'cashier',
    name: 'Ada',
    email: 'ada@shop.test',
    password: 'right',
    role: 'Cashier',
    departmentUuids: const [],
    access: access,
  );

  LanFound advert(String type, int port, String device, {int epoch = 2}) =>
      LanFound(
        name: '$type-$device',
        addresses: const ['127.0.0.1'],
        port: port,
        txt: {
          'v': LanConstants.protocolVersion,
          't': shopTag(key),
          'tv': LanConstants.shopTagVersion,
          'e': '$epoch',
          'd': device,
        },
      );

  Future<void> eventually(
    FutureOr<bool> Function() done, {
    Duration within = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(within);
    while (!await done()) {
      if (DateTime.now().isAfter(end)) fail('timed out');
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<LanForceClearResult> forceClear([String password = 'right']) =>
      LocalServerProvider().forceClearServer(shopId: 7, password: password);

  /// old-desk serves epoch 2; this till is paired, signed in and routed
  /// there, and has handed it a sale's stock change. Another till of the
  /// shop is seen nearby (so this one knows it is on the shop's LAN).
  Future<void> joinOld() async {
    shift = Duration.zero;
    await LanTransport().disconnectClient();
    RemoteRouter.useSupabase();
    discovery
      ..servers = []
      ..peers = [advert('peer', 0, 'phone-2')];
    old = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'old-desk',
      epoch: 2,
      claimedAt: DateTime.utc(2026, 11, 20),
      access: access,
    );
    await LanClientSessionFunc().delete(7);
    await LanPairedServersFunc().pairedServersBox.clear();
    await LanPairedServersFunc().trustBox.clear();
    await LanHandoffsFunc().clearHandoffs();
    await LanAlertsFunc().clearAlerts();
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: 'old-desk',
        claimedAt: DateTime.utc(2026, 11, 20),
        certFingerprint: old.fingerprint,
        lastKnownAddresses: const ['127.0.0.1'],
      ),
    );
    LocalServerProvider()
      ..clearCache()
      ..resetFollow()
      ..followSearchEvery = Duration.zero;
    await LanPairedServersFunc().put(
      LanPairedServer(
        serverDeviceId: 'old-desk',
        certFingerprint: old.fingerprint,
        port: old.port,
        addresses: const ['127.0.0.1'],
        pairedAt: DateTime.now().toUtc(),
        label: 'Stockall-old-de',
      ),
    );
    await LanPairedServersFunc().markPairedByPerson(old.fingerprint);
    expect(
      await LocalServerProvider().loginViaLan(
        email: 'ada@shop.test',
        password: 'right',
      ),
      LanAuthResult.ok,
    );
    await UserProvider().fetchCurrentUserOffline();
    await eventually(() => RemoteRouter.route == LanRoute.lanUp);
    await QuantityUpdateFunc().createQuantityUpdate(
      QuantityUpdate(
        uuid: 'q-fc1',
        createdAt: DateTime.now(),
        quantity: 2,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    await returnData().syncData();
    await eventually(
      () => LanHandoffs().deltasFor('old-desk').length == 1,
    );
  }

  /// old-desk goes away; the route is lanDown (on the LAN, no server).
  Future<void> loseOld() async {
    await old.halt();
    await eventually(() async {
      await LanRouting().evaluate(quick: true);
      return RemoteRouter.route == LanRoute.lanDown;
    });
  }

  setUpAll(() async {
    final tillDir = Directory.systemTemp.createTempSync('stockall_p8c_till');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tillDir.path,
    );
    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    await MainDatabase().initHive();
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 7),
    );
    ShopProvider().userShops = [
      TempShopClass(
        shopId: 7,
        createdAt: DateTime.utc(2026),
        userId: 'owner',
        name: 'Shop',
        currency: 'NGN',
        isVerified: true,
        applyVAT: false,
        manageInventoryStorage: false,
        wholeSale: false,
        manageDepartments: false,
        printSalesDocket: false,
        closeSaleTimeString: null,
        trackCart: false,
        accessPin: null,
        manageProductions: false,
        manageProductionsStorage: false,
        manageProductionItems: false,
        customerPercentageReward: 0,
        manageCustomerReward: false,
        manageCustomerAccount: false,
      ),
    ];
    await LoggedInUserFunc().insertLoggedInUser(LoggedInUser(loggedInUser: ada()));
    await UserProvider().fetchCurrentUserOffline();
    await LanShopKeysFunc().put(7, key);
    // Named "Item" here and on old-desk (the till pulls it from there).
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);

    LanTransport()
      ..discovery = discovery
      ..interfaces = (() async => const [])
      ..serverPorts = const [0]
      ..browseTimeout = const Duration(milliseconds: 10)
      ..loginBrowseTimeout = const Duration(milliseconds: 10)
      ..claimBrowseTimeout = const Duration(milliseconds: 10)
      ..isOnline = (() => false);
    LocalServerProvider();
    ConnectivityProvider().interfaceUp = true;
    LanRouting()
      ..now = (() => DateTime.now().add(shift))
      ..start();
  });

  tearDown(() async {
    await LanTransport().disconnectClient();
    await old.stop();
  });

  tearDownAll(() async {
    LanRouting()
      ..stop()
      ..now = DateTime.now;
    RemoteRouter.useSupabase();
  });

  test('refused: while the server answers, off the LAN, under 60 s, a wrong '
      'password, without Manage Local Server, or when a fresh look finds a '
      'server answering', () async {
    await joinOld();
    expect(await forceClear(), LanForceClearResult.liveServerFound);

    await loseOld();
    expect(await forceClear(), LanForceClearResult.tooSoon);

    // No other device of the shop in sight: off the LAN.
    discovery.peers = [];
    await LanRouting().evaluate(quick: true);
    expect(RemoteRouter.route, LanRoute.offLan);
    expect(await forceClear(), LanForceClearResult.notOnLan);
    discovery.peers = [advert('peer', 0, 'phone-2')];
    await LanRouting().evaluate(quick: true);
    expect(RemoteRouter.route, LanRoute.lanDown);

    shift = LanConstants.forceClearAfter + const Duration(seconds: 1);
    expect(await forceClear('wrong'), LanForceClearResult.wrongPassword);

    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(loggedInUser: ada(access: const ['Make Sale'])),
    );
    await UserProvider().fetchCurrentUserOffline();
    expect(await forceClear(), LanForceClearResult.noPermission);
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(loggedInUser: ada()),
    );
    await UserProvider().fetchCurrentUserOffline();

    // A server of the shop answers on the network (not the paired one).
    final other = LanServer(
      identity: LanTlsIdentity.generate(),
      deviceId: 'desk-9',
      serverView: () => LanServerView(
        shopTag: shopTag(key),
        epoch: 2,
        serverDeviceId: 'desk-9',
        cleared: false,
        claimedAt: DateTime.utc(2026, 11, 21),
      ).toJson(),
    );
    await other.start(ports: const [0]);
    discovery.servers = [advert('server', other.port!, 'desk-9')];
    expect(await forceClear(), LanForceClearResult.liveServerFound);
    await other.stop();
    discovery.servers = [];

    // Nothing changed.
    final record = LocalServerProvider().record(shopId: 7)!;
    expect(record.epoch, 2);
    expect(record.serverDeviceId, 'old-desk');
    expect(LanAlerts().all(), isEmpty);
  });

  test('cleared: a higher epoch, cleared; the alert lists the stock change '
      'still held for old-desk, which stays held', () async {
    await joinOld();
    await loseOld();
    shift = LanConstants.forceClearAfter + const Duration(seconds: 1);

    expect(await forceClear(), LanForceClearResult.applied);

    final record = LocalServerProvider().record(shopId: 7)!;
    expect(record.epoch, 3);
    expect(record.isCleared, isTrue);
    expect(record.claimedByUserId, 'cashier');
    final alert = LanAlerts().all().single;
    expect(alert.kind, LanAlertKind.forceCleared);
    expect(alert.message, contains('check these items'));
    expect(alert.columns, ['Item', 'Change', 'From', 'Sent']);
    expect(alert.rows.single.sublist(0, 3), [
      'Item (Product)',
      '-2',
      'Change q-fc1',
    ]);
    // Kept, never replayed.
    expect(LanHandoffs().deltasFor('old-desk'), hasLength(1));
  });

  test('old-desk comes back: the till tells it the shop\'s server was '
      'cleared (proven for its certificate) and doesn\'t use it', () async {
    await joinOld();
    await loseOld();
    shift = LanConstants.forceClearAfter + const Duration(seconds: 1);
    expect(await forceClear(), LanForceClearResult.applied);

    final port = await old.resume();
    discovery.servers = [advert('server', port, 'old-desk')];
    await eventually(() async {
      await LanRouting().evaluate(quick: true);
      return (await old.state())['last_notice'] != null;
    });

    final notice = Map<String, dynamic>.from(
      (await old.state())['last_notice'] as Map,
    );
    expect(notice['kind'], 'cleared');
    final view = LanServerView.fromJson(
      Map<String, dynamic>.from(notice['view'] as Map),
    )!;
    expect(view.cleared, isTrue);
    expect(view.epoch, 3);
    expect(
      LanPeerProof.verify(
        shopKey: key,
        nonce: LanPeerProof.clearedNotice,
        fingerprint: old.fingerprint,
        view: view,
        mac: notice['mac'] as String,
      ),
      isTrue,
    );
    expect(LanTransport().isClientConnected, isFalse);
    expect(RemoteRouter.route, LanRoute.lanDown);
    expect(LocalServerProvider().record(shopId: 7)!.epoch, 3);
  });

  test('a till whose server is cleared from elsewhere lists the stock '
      'changes it still holds for it, once; they stay held', () async {
    await joinOld();
    await old.clearClaim(3);

    await eventually(() => LanAlerts().all().isNotEmpty);
    final record = LocalServerProvider().record(shopId: 7)!;
    expect(record.epoch, 3);
    expect(record.isCleared, isTrue);
    final alert = LanAlerts().all().single;
    expect(alert.kind, LanAlertKind.forceCleared);
    expect(alert.message, contains('from this device'));
    expect(alert.columns, ['Item', 'Change', 'From', 'Sent']);
    expect(alert.rows.single.sublist(0, 3), [
      'Item (Product)',
      '-2',
      'Change q-fc1',
    ]);
    expect(LanHandoffs().deltasFor('old-desk'), hasLength(1));
  });

  test('a till that finds a new server after a clear (two epochs up) waits '
      'for a person to pair it (proven with the shop key only); then it '
      'lists what it still holds for the old one; it stays held', () async {
    await joinOld();
    final fresh = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'new-desk',
      epoch: 4,
      claimedAt: DateTime.utc(2026, 11, 25),
      access: access,
    );
    addTearDown(fresh.stop);
    discovery.servers = [advert('server', fresh.port, 'new-desk', epoch: 4)];
    await old.halt();

    await eventually(() async {
      await LanRouting().evaluate(quick: true);
      return LocalServerProvider().mustPairAgainFor(7);
    });
    expect(LanClientSessionFunc().get(7)?.serverDeviceId, 'old-desk');

    // A person pairs this till with new-desk (its code or QR).
    await LanPairedServersFunc().markPairedByPerson(fresh.fingerprint);
    await eventually(() async {
      await LanRouting().evaluate(quick: true);
      return LanClientSessionFunc().get(7)?.serverDeviceId == 'new-desk';
    });
    final alert = LanAlerts().all().single;
    expect(alert.kind, LanAlertKind.forceCleared);
    expect(alert.rows.single[1], '-2');
    expect(LanHandoffs().deltasFor('old-desk'), hasLength(1));
  });

  test('signing in shows the alerts waiting for a user with Manage Local '
      'Server', () async {
    await joinOld();
    final shown = <String>[];
    final presenter = LanServerAlertPresenter()
      ..mayManage = (() => true)
      ..shopId = (() => 7)
      ..show = (alert) async {
        shown.add(alert.title);
        return true;
      };
    addTearDown(() {
      presenter
        ..show = ((_) async => false)
        ..mayManage = (() => false);
    });
    // Raised before (no presenter listening): waiting.
    await LanAlerts().raise(
      shopId: 7,
      kind: LanAlertKind.merged,
      title: 'Changes sent to the store server',
      message: 'Every change has reached the store server.',
    );
    expect(LanAlerts().unshown(7), hasLength(1));

    expect(await AuthService().signIn('ada@shop.test', 'right'), 1);
    await eventually(() => shown.isNotEmpty);
    expect(shown, ['Changes sent to the store server']);
    expect(LanAlerts().unshown(7), isEmpty);
  });
}
