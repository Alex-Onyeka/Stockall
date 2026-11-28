import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
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
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_peer_client.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_carts.dart';
import 'helpers/lan_fixtures.dart';
import 'helpers/lan_peer_server.dart';
import 'helpers/lan_till.dart';

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

/// The verification list as one store, end to end, from a
/// till: this test's app is "till-a" (its whole client: pairing, sign-in,
/// routing, stock holds, handoffs, force-clear); "desk-1" and later
/// "desk-2" are store servers in their own isolates and Hive, as on other
/// machines; "till-b" is another till on the network (`LanTill`). The
/// steps run in order and share the store; a failed step fails the ones
/// after it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to real servers over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  const access = ['Make Sale', 'Update Items', 'Manage Local Server'];
  final discovery = _FakeDiscovery();
  final conflicts = <LanStockConflict>[];
  StreamSubscription<List<LanStockConflict>>? conflictSub;
  late PeerServer desk1;
  PeerServer? desk2;
  var shift = Duration.zero;
  var tillB = LanTill('till-b');

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

  List<LanHandoff> handoffsTo(String device) => [
    for (final (_, h) in LanHandoffs().all())
      if (h.serverDeviceId == device) h,
  ];

  Future<bool> connectedTo(String device) async {
    await LanRouting().evaluate(quick: true);
    return RemoteRouter.route == LanRoute.lanUp &&
        LanTransport().clientServerView?.serverDeviceId == device;
  }

  setUpAll(() async {
    final tillDir = Directory.systemTemp.createTempSync('stockall_p11_till');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
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
    // Signed in on this till before (online), as the app keeps it.
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(
        loggedInUser: TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Cashier',
          departmentUuids: const [],
          access: access,
        ),
      ),
    );
    await UserProvider().fetchCurrentUserOffline();
    await LanShopKeysFunc().put(7, key);
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 1);

    LanTransport()
      ..discovery = discovery
      ..interfaces = (() async => const [])
      ..serverPorts = const [0]
      ..browseTimeout = const Duration(milliseconds: 10)
      ..loginBrowseTimeout = const Duration(milliseconds: 10)
      ..claimBrowseTimeout = const Duration(milliseconds: 10)
      ..backfillPollEvery = const Duration(milliseconds: 100)
      ..isOnline = (() => false);
    LocalServerProvider()
      ..resetFollow()
      ..followSearchEvery = Duration.zero;
    ConnectivityProvider().interfaceUp = true;
    // Another till of the shop is seen nearby: this one knows when it is
    // on the shop's network.
    discovery.peers = [advert('peer', 0, 'phone-2')];
    LanRouting()
      ..now = (() => DateTime.now().add(shift))
      ..start();
    final stock = LanStockClient();
    await stock.stop();
    stock
      ..reset()
      ..deps = LanStockClientDeps(
        link: () => LanTransport().stockLink(userId: 'cashier'),
        route: () => RemoteRouter.route,
        carts: () => CartFunc().cartBox.values.expand((m) => m.cartQueue),
        held: (p) => p == 'p1',
        queued: () => const {},
        dropQueued: (_) async {},
        debounce: const Duration(milliseconds: 5),
      )
      ..start();
    conflictSub = stock.conflicts.listen(conflicts.addAll);

    // The store server: the last unit of p1.
    desk1 = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'desk-1',
      epoch: 2,
      claimedAt: DateTime.utc(2026, 11, 20),
      stock: 1,
      access: access,
    );
  });

  tearDownAll(() async {
    await conflictSub?.cancel();
    await LanStockClient().stop();
    await tillB.close();
    await LanTransport().disconnectClient();
    LanRouting()
      ..stop()
      ..now = DateTime.now;
    RemoteRouter.useSupabase();
    await desk1.stop();
    await desk2?.stop();
  });

  test('1. pairing as the Store Network page does: a mistyped code keeps '
      'nothing; the code shown pairs; signed in with the password kept '
      'here, and routed to the server', () async {
    final provider = LocalServerProvider();
    expect(LanPairedServersFunc().all(), isEmpty);
    expect(provider.record(shopId: 7), isNull);

    var outcome = await provider.beginPairing(
      addresses: const ['127.0.0.1'],
      port: desk1.port,
    );
    expect(outcome.result, LanPairResult.awaitingCode);
    final shown = (await desk1.pairingCode())!;
    outcome = await provider.submitPairingCode(
      '${shown.substring(0, 7)}${shown.endsWith('A') ? 'B' : 'A'}',
    );
    expect(outcome.result, LanPairResult.codeMismatch);
    expect(LanPairedServersFunc().all(), isEmpty);
    // This till told desk-1: its session ended, so another till can pair
    // at once.
    expect(await desk1.pairingCode(), isNull);
    expect(await tillB.startPairing(desk1.port), await desk1.pairingCode());
    expect(await tillB.typeCode((await desk1.pairingCode())!), isTrue);

    outcome = await provider.beginPairing(
      addresses: const ['127.0.0.1'],
      port: desk1.port,
    );
    expect(outcome.result, LanPairResult.awaitingCode);
    outcome = await provider.submitPairingCode((await desk1.pairingCode())!);
    expect(outcome.result, LanPairResult.paired);
    expect(outcome.server!.serverDeviceId, 'desk-1');
    expect(outcome.server!.certFingerprint, desk1.fingerprint);

    expect(
      await provider.signInAfterPairing(shopId: 7, serverDeviceId: 'desk-1'),
      LanAuthResult.ok,
    );
    await eventually(() => connectedTo('desk-1'));
    expect(provider.status.kind, LanStatusKind.connected);
    expect(provider.record(shopId: 7)?.serverDeviceId, 'desk-1');

    // Till-b (paired above) signs in too.
    expect(await tillB.signIn(desk1.port), isNull);
    await tillB.openSocket();
  });

  test('2. the server loses its internet: the online-only screens go on '
      'this till, and come back with it', () async {
    final provider = LocalServerProvider();
    await eventually(() => provider.onlineFeaturesAvailable);
    await desk1.setOnline(false);
    await eventually(() => !provider.onlineFeaturesAvailable);
    expect(provider.status.serverOnline, isFalse);
    await desk1.setOnline(true);
    await eventually(() => provider.onlineFeaturesAvailable);
  });

  test('3. the last unit across tills: held on till-b, refused here; '
      'released there, held here', () async {
    final stock = LanStockClient();
    final here = cart('cart-a', [line(product('p1'), 1)]);
    expect((await tillB.hold('cart-b', 'p1', 1))['ok'], isTrue);

    final refused = await stock.hold(here, 'p1', 1);
    expect(refused.ok, isFalse);
    expect(refused.available, 0);

    await tillB.release(cart: 'cart-b');
    final held = await stock.hold(here, 'p1', 1);
    expect(held.ok, isTrue);
    expect(
      ((await desk1.state())['holds'] as Map).values.single,
      1.0,
    );
    // Set down again for the next steps.
    await stock.releaseAll();
    await eventually(
      () async => ((await desk1.state())['holds'] as Map).isEmpty,
    );
  });

  test('4. a split network: desk-2 claims on the other half and till-b '
      'sells there; on rejoining desk-1 is outranked and steps down; this '
      'till follows, its writes replay once, its stock change is left to '
      'desk-1; nothing is applied twice', () async {
    // The other half: desk-2 claimed while it couldn't see desk-1 (an
    // earlier claim at the same epoch outranks).
    final other = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'desk-2',
      epoch: 2,
      claimedAt: DateTime.utc(2026, 11, 19),
      stock: 5,
      access: access,
    );
    desk2 = other;
    await tillB.close();
    tillB = LanTill('till-b');
    await tillB.startPairing(other.port);
    expect(await tillB.typeCode((await other.pairingCode())!), isTrue);
    expect(await tillB.signIn(other.port), isNull);
    expect((await tillB.hold('cart-b2', 'p1', 1))['ok'], isTrue);
    final sold = await tillB.checkout(
      'cart-b2',
      changeUuid: 'sale-b',
      product: 'p1',
      quantity: 1,
    );
    expect(sold['done'], ['sale-b']);
    expect((await other.state())['quantity'], 4.0);

    // This till's half: a new product, and a sale's stock change.
    await LanTransport().lanClient!
        .from('products')
        .insert(
          (product('p2')..name = 'Made on desk-1').toJson(
            isIncludeQuantity: true,
          ),
        );
    await QuantityUpdateFunc().createQuantityUpdate(
      QuantityUpdate(
        uuid: 'sale-a',
        createdAt: DateTime.now(),
        quantity: 1,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    await returnData().syncData();
    expect(await desk1.applied(['update_product_quantities:sale-a']), [true]);
    await eventually(
      () => handoffsTo('desk-1').any((h) => h.kind == LanHandoffKind.delta),
    );
    expect(
      handoffsTo('desk-1').where((h) => h.kind == LanHandoffKind.rest),
      hasLength(1),
    );

    // Rejoined: desk-1's watch finds desk-2, which outranks it.
    expect(await desk1.watchOnce(other.port), 'outranked');
    final winner = (await proveLanServer(
      shopKey: key,
      endpoints: [LanEndpoint('127.0.0.1', other.port)],
    ))!;
    await desk1.moveTo(winner.toJson());

    await eventually(() => connectedTo('desk-2'));
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'desk-2');
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, 'desk-2');
    // The write desk-1 took reaches desk-2, once.
    await eventually(
      () => handoffsTo('desk-1').every((h) => h.kind == LanHandoffKind.delta),
    );
    expect(((await other.state())['products'] as Map)['p2'], 'Made on desk-1');
    // The stock change is desk-1's to deliver: not sent again from here.
    expect(await other.applied(['update_product_quantities:sale-a']), [false]);
    expect((await other.state())['quantity'], 4.0);
    // desk-1 says its whole queue is at desk-2: this till's copy
    // ends.
    await other.recordHandedOver('desk-1', 2);
    await eventually(() => handoffsTo('desk-1').isEmpty);
  });

  test('5. the server dies: not cleared before a minute without it; then a '
      'manager clears it; when it comes back it is told and not used',
      () async {
    final other = desk2!;
    final provider = LocalServerProvider();
    await other.halt();
    await eventually(() async {
      await LanRouting().evaluate(quick: true);
      return RemoteRouter.route == LanRoute.lanDown;
    });
    expect(provider.status.kind, LanStatusKind.serverUnreachable);
    expect(provider.onlineFeaturesAvailable, isFalse);
    expect(
      await provider.forceClearServer(shopId: 7, password: 'right'),
      LanForceClearResult.tooSoon,
    );

    shift = LanConstants.forceClearAfter + const Duration(seconds: 1);
    expect(
      await provider.forceClearServer(shopId: 7, password: 'wrong'),
      LanForceClearResult.wrongPassword,
    );
    expect(
      await provider.forceClearServer(shopId: 7, password: 'right'),
      LanForceClearResult.applied,
    );
    final record = provider.record(shopId: 7)!;
    expect(record.isCleared, isTrue);
    expect(record.epoch, 3);
    expect(
      LanAlerts().all().where((a) => a.kind == LanAlertKind.forceCleared),
      hasLength(1),
    );

    // desk-2 comes back: this till tells it, and stays off it.
    final port = await other.resume();
    discovery.servers = [advert('server', port, 'desk-2')];
    await eventually(() async {
      await LanRouting().evaluate(quick: true);
      return (await other.state())['last_notice'] != null;
    });
    final notice = (await other.state())['last_notice'] as Map;
    expect(notice['kind'], 'cleared');
    expect(LanTransport().isClientConnected, isFalse);
    expect(RemoteRouter.route, LanRoute.lanDown);
    expect(provider.record(shopId: 7)!.epoch, 3);
  });
}
