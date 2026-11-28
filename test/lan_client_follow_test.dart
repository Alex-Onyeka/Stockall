import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';
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
import 'package:stockall/services/lan/device_identity.dart';
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

/// mDNS as the tests set it: the servers "seen" on the network.
class _FakeDiscovery implements LanDiscoveryBackend {
  List<LanFound> servers = [];

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
    type == LanConstants.serverServiceType ? servers : const [],
  );
}

/// End to end: this test's app (every box `initHive` opens, the real
/// `LanTransport`, `LocalServerProvider`, `LanRouting` and
/// `LanStockClient`) is a till signed in on the shop's server, "old-desk".
/// Another server of the shop, "new-desk", claimed epoch 2 first (a split
/// network), so it outranks old-desk. Each runs in its own isolate and
/// Hive, as on its own machine.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to real servers over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  const cartId = '5a1e0000-0000-4000-8000-0000000000c1';
  final t1 = DateTime.utc(2026, 11, 20, 9);
  final t2 = DateTime.utc(2026, 11, 20, 10);
  final discovery = _FakeDiscovery();
  late PeerServer loser;
  late PeerServer winner;
  late String me;
  final conflicts = <LanStockConflict>[];
  StreamSubscription<List<LanStockConflict>>? conflictSub;

  LanFound advert(int port, String device) => LanFound(
    name: 'Stockall-$device',
    addresses: const ['127.0.0.1'],
    port: port,
    txt: {
      'v': LanConstants.protocolVersion,
      't': shopTag(key),
      'tv': LanConstants.shopTagVersion,
      'e': '2',
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

  List<LanHandoff> handoffsTo(String device) => [
    for (final (_, h) in LanHandoffs().all())
      if (h.serverDeviceId == device) h,
  ];

  /// The winner as a client gets it in a `moved` event.
  Future<LanServerCandidate> winnerCandidate() async =>
      (await proveLanServer(
        shopKey: key,
        endpoints: [LanEndpoint('127.0.0.1', winner.port)],
      ))!;

  /// Both servers fresh; this till paired with old-desk, signed in there
  /// (Ada's password kept for offline login, as the app does) and routed
  /// to it.
  Future<void> joinLoser() async {
    final transport = LanTransport();
    await transport.disconnectClient();
    RemoteRouter.useSupabase();
    discovery.servers = [];
    conflicts.clear();
    loser = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'old-desk',
      epoch: 2,
      claimedAt: t2,
      access: const ['Make Sale', 'Update Items'],
    );
    winner = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'new-desk',
      epoch: 2,
      claimedAt: t1,
      access: const ['Make Sale', 'Update Items'],
    );
    await LanClientSessionFunc().delete(7);
    await LanPairedServersFunc().pairedServersBox.clear();
    await LanPairedServersFunc().trustBox.clear();
    await LanHandoffsFunc().clearHandoffs();
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: 'old-desk',
        claimedAt: t2,
        certFingerprint: loser.fingerprint,
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
        certFingerprint: loser.fingerprint,
        port: loser.port,
        addresses: const ['127.0.0.1'],
        pairedAt: DateTime.now().toUtc(),
        label: 'Stockall-old-de',
      ),
    );
    await LanPairedServersFunc().markPairedByPerson(loser.fingerprint);
    expect(
      await LocalServerProvider().loginViaLan(
        email: 'ada@shop.test',
        password: 'right',
      ),
      LanAuthResult.ok,
    );
    await eventually(
      () =>
          RemoteRouter.route == LanRoute.lanUp &&
          transport.clientServerView?.serverDeviceId == 'old-desk',
    );
  }

  /// Writes this till hands to old-desk: a new product and two edits of
  /// p1 (the newer first), then a sale's stock change through the queue.
  Future<void> writeToLoser(String saleUuid) async {
    final lan = LanTransport().lanClient!;
    await lan
        .from('products')
        .insert(
          (product('p2')..name = 'Made on the old side').toJson(
            isIncludeQuantity: true,
          ),
        );
    await lan
        .from('products')
        .update({
          'name': 'Newer',
          'updated_at': DateTime.utc(2026, 11, 24).toIso8601String(),
        })
        .eq('uuid', 'p1');
    await lan
        .from('products')
        .update({
          'name': 'Older',
          'updated_at': DateTime.utc(2026, 10, 1).toIso8601String(),
        })
        .eq('uuid', 'p1');
    await QuantityUpdateFunc().createQuantityUpdate(
      QuantityUpdate(
        uuid: saleUuid,
        createdAt: DateTime.now(),
        quantity: 1,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    await returnData().syncData();
    await eventually(
      () => handoffsTo('old-desk').any((h) => h.kind == LanHandoffKind.delta),
    );
    expect(
      handoffsTo('old-desk').where((h) => h.kind == LanHandoffKind.rest),
      hasLength(3),
    );
    expect((await loser.applied(['update_product_quantities:$saleUuid'])), [
      true,
    ]);
  }

  setUpAll(() async {
    final tillDir = Directory.systemTemp.createTempSync('stockall_p8b_till');
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
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(
        loggedInUser: TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Cashier',
          departmentUuids: const [],
          access: const ['Make Sale', 'Update Items'],
        ),
      ),
    );
    await UserProvider().fetchCurrentUserOffline();
    await LanShopKeysFunc().put(7, key);
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);
    // The till's cart: 4 of p1.
    await CartFunc().createMainCart(
      TempMainCart(
        mainCartId: 'm1',
        cartQueue: [
          cart(cartId, [line(product('p1'), 4)]),
        ],
      ),
    );

    LanTransport()
      ..discovery = discovery
      ..interfaces = (() async => const [])
      ..serverPorts = const [0]
      ..browseTimeout = const Duration(milliseconds: 10)
      ..loginBrowseTimeout = const Duration(milliseconds: 10)
      ..isOnline = (() => false);
    // Its callbacks on the transport.
    LocalServerProvider();
    ConnectivityProvider().interfaceUp = true;
    me = await DeviceIdentity().deviceId();
    LanRouting().start();
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
  });

  tearDown(() async {
    await LanTransport().disconnectClient();
    await loser.stop();
    await winner.stop();
  });

  tearDownAll(() async {
    await conflictSub?.cancel();
    await LanStockClient().stop();
    LanRouting().stop();
    RemoteRouter.useSupabase();
  });

  test('the server steps down (moved): the till proves the new server, pairs '
      'and signs in there, re-syncs its holds (a conflict is reported), and '
      'replays the writes old-desk had taken; its stock changes are left to '
      'old-desk', () async {
    await joinLoser();
    await LanStockClient().reconcile();
    await eventually(
      () async =>
          ((await loser.state())['holds'] as Map)['$me|$cartId|p1'] == 4.0,
    );
    await writeToLoser('q-c1');
    // Sales on the other side of the split.
    await winner.setQuantity(3);

    await loser.moveTo((await winnerCandidate()).toJson());

    // Paired, signed in and routed there.
    await eventually(
      () =>
          RemoteRouter.route == LanRoute.lanUp &&
          LanTransport().clientServerView?.serverDeviceId == 'new-desk',
    );
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'new-desk');
    final record = LocalServerProvider().record(shopId: 7)!;
    expect(record.serverDeviceId, 'new-desk');
    expect(record.certFingerprint, winner.fingerprint);
    expect(LanPairedServersFunc().get('new-desk'), isNotNull);
    // Trusted because old-desk, which a person paired, signed the move.
    expect(LanPairedServersFunc().isTrusted(winner.fingerprint), isTrue);
    // It signed in there presenting that move, then dropped it.
    expect((await winner.state())['moved_logins'], 1);
    expect(LanPairedDevicesFunc().moveTo(winner.fingerprint), isNull);

    // Holds re-synced there: 3 of the 4 fit; the rest is a conflict.
    await eventually(
      () async =>
          ((await winner.state())['holds'] as Map)['$me|$cartId|p1'] == 3.0,
    );
    await eventually(() => conflicts.isNotEmpty);
    expect(conflicts.single.productUuid, 'p1');
    expect(conflicts.single.wanted, 4);
    expect(conflicts.single.held, 3);

    // The REST writes old-desk took reach new-desk; the older edit of p1
    // doesn't undo the newer one (last write wins).
    await eventually(
      () async => handoffsTo('old-desk').isEmpty,
    );
    final products = (await winner.state())['products'] as Map;
    expect(products['p2'], 'Made on the old side');
    expect(products['p1'], 'Newer');
    // The sale's stock change is old-desk's to deliver (it pushes its
    // queue to new-desk): not sent again from here.
    expect(await winner.applied(['update_product_quantities:q-c1']), [false]);
    expect((await winner.state())['quantity'], 3.0);
  });

  test('a followed move survives a restart: the first sign-in on new-desk '
      'fails; after a restart the till still presents the signed move there, '
      'and drops it once signed in', () async {
    await joinLoser();
    await winner.refuseLogins(true);

    await loser.moveTo((await winnerCandidate()).toJson());
    await eventually(
      () async => (await winner.state())['moved_logins'] as int >= 1,
    );
    expect(LanClientSessionFunc().get(7)?.serverDeviceId, isNot('new-desk'));

    // A restart: the box closed and opened again; nothing kept in memory.
    await LanPairedDevicesFunc().movesBox.close();
    await LanPairedDevicesFunc().init();
    expect(LanPairedDevicesFunc().moveTo(winner.fingerprint), isNotNull);

    await winner.refuseLogins(false);
    final before = (await winner.state())['moved_logins'] as int;
    expect(
      await LocalServerProvider().signInOnServer(7, serverDeviceId: 'new-desk'),
      LanAuthResult.ok,
    );
    expect((await winner.state())['moved_logins'], before + 1);
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'new-desk');
    expect(LanPairedDevicesFunc().moveTo(winner.fingerprint), isNull);
  });

  test('the till missed the event (old-desk vanished): new-desk proves its '
      'claim with the shop key only, so the till doesn\'t follow it, sends it '
      'no password and asks to pair again; once a person pairs it, it '
      'follows and replays the writes; the stock change waits until '
      'new-desk says old-desk handed over', () async {
    await joinLoser();
    await writeToLoser('q-c2');
    final keyBefore = LanShopKeysFunc().get(7);
    final loginsBefore = (await winner.state())['logins'] as int;
    discovery.servers = [advert(winner.port, 'new-desk')];

    await loser.halt();

    await eventually(() => LocalServerProvider().mustPairAgainFor(7));
    expect(LocalServerProvider().status.mustPairAgain, isTrue);
    expect(RemoteRouter.route, isNot(LanRoute.lanUp));
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'old-desk');
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, 'old-desk');
    expect((await winner.state())['logins'], loginsBefore);
    expect(LanShopKeysFunc().get(7), keyBefore);
    expect(handoffsTo('old-desk'), isNotEmpty);

    // A person pairs this till with new-desk (its code or QR).
    await LanPairedServersFunc().markPairedByPerson(winner.fingerprint);
    await LanRouting().evaluate();

    await eventually(
      () =>
          RemoteRouter.route == LanRoute.lanUp &&
          LanTransport().clientServerView?.serverDeviceId == 'new-desk',
    );
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'new-desk');
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, 'new-desk');
    await eventually(
      () => handoffsTo('old-desk').every((h) => h.kind == LanHandoffKind.delta),
    );
    expect(((await winner.state())['products'] as Map)['p2'], isNotNull);
    // Kept: old-desk delivers it when it comes back (and demotes).
    expect(handoffsTo('old-desk'), hasLength(1));
    expect(await winner.applied(['update_product_quantities:q-c2']), [false]);

    // Once old-desk says its queue is all at new-desk, new-desk
    // tells its tills, and this one's copy ends.
    await winner.recordHandedOver('old-desk', 2);
    await eventually(() => handoffsTo('old-desk').isEmpty);
  });

  test('a moved event the till can\'t verify changes nothing: a server '
      'without the named certificate, or one that doesn\'t outrank '
      'old-desk', () async {
    await joinLoser();
    final real = await winnerCandidate();
    final wrongCert = LanServerCandidate(
      view: real.view,
      fingerprint: 'not-its-certificate',
      addresses: real.addresses,
      port: real.port,
    );
    await loser.moveTo(wrongCert.toJson(), stop: false);
    // The right server, but the move not signed by old-desk's certificate:
    // unsigned, or signed with another key.
    final loginsBefore = (await winner.state())['logins'] as int;
    await loser.moveTo(real.toJson(), stop: false, signWith: 'none');
    await loser.moveTo(real.toJson(), stop: false, signWith: 'other');
    // A real server of the shop, but claimed after old-desk.
    await winner.setClaim(epoch: 2, claimedAt: DateTime.utc(2026, 11, 21));
    await loser.moveTo((await winnerCandidate()).toJson(), stop: false);
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(LanTransport().clientServerView?.serverDeviceId, 'old-desk');
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'old-desk');
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, 'old-desk');
    expect(LanPairedServersFunc().get('new-desk'), isNull);
    expect(LanPairedServersFunc().isTrusted(winner.fingerprint), isFalse);
    expect((await winner.state())['logins'], loginsBefore);
  });

  test('even a signed move isn\'t followed to a claim more than two epochs '
      'above any this till knows', () async {
    await joinLoser();
    final loginsBefore = (await winner.state())['logins'] as int;
    await winner.setClaim(epoch: 5, claimedAt: t1);
    // What a verified move to it would do.
    expect(
      await LocalServerProvider().followServer(
        await winnerCandidate(),
        shopId: 7,
        vouched: true,
      ),
      LanFollowResult.refused,
    );

    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'old-desk');
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, 'old-desk');
    expect(LanPairedServersFunc().isTrusted(winner.fingerprint), isFalse);
    expect((await winner.state())['logins'], loginsBefore);
  });
}
