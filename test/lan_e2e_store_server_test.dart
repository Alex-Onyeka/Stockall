import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';
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

class _NoDiscovery implements LanDiscoveryBackend {
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
  Stream<LanFound> browse(String type, Duration timeout) =>
      const Stream.empty();
}

/// The verification list as one store, end to end: this
/// test's app is the store server (its whole server: TLS, sign-in, the
/// REST engine, the stock service); "till-a" and "till-b" are two tills
/// on the network (`LanTill`). The steps run in order and share the
/// store; a failed step fails the ones after it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to a real server over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  late String me;
  late int port;
  var online = false;
  final tillA = LanTill('till-a');
  final tillB = LanTill('till-b');

  Future<void> eventually(
    FutureOr<bool> Function() done, {
    Duration within = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(within);
    while (!await done()) {
      if (DateTime.now().isAfter(end)) fail('timed out');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  LanConnectedDevice device(String id) => LocalServerProvider()
      .connectedDevices()
      .firstWhere((d) => d.deviceId == id);

  int queued(String change) => QuantityUpdateFunc().quantityUpdateBox.values
      .where((q) => q.uuid == change)
      .length;

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('stockall_p11_server');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => dir.path,
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
    final ada = TempUserClass(
      userId: 'cashier',
      name: 'Ada',
      email: 'ada@shop.test',
      password: 'right',
      role: 'Cashier',
      departmentUuids: const [],
      access: const ['Make Sale', 'Manage Local Server'],
    );
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(loggedInUser: ada),
    );
    await UserProvider().fetchCurrentUserOffline();
    await LanShopKeysFunc().put(7, key);
    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
      [ada],
      iterations: 1000,
    );
    // The last unit.
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 1);

    final transport = LanTransport()
      ..discovery = _NoDiscovery()
      ..interfaces = (() async => const [])
      ..serverPorts = const [0]
      ..holdGrace = const Duration(seconds: 1)
      ..isOnline = (() => online);
    LocalServerProvider();
    ConnectivityProvider().interfaceUp = true;
    me = await DeviceIdentity().deviceId();
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: me,
        claimedAt: DateTime.utc(2026, 11, 20),
        certFingerprint: await transport.serverFingerprint(),
      ),
    );
    LocalServerProvider().clearCache();
    await LocalServerProvider().resumeServerIfOwned();
    expect(transport.isServing, isTrue);
    port = transport.serverPort!;
    RemoteRouter.useSupabase(LanRoute.server);
  });

  tearDownAll(() async {
    await tillA.close();
    await tillB.close();
    await LanTransport().stopServer();
    RemoteRouter.useSupabase();
  });

  test('1. pairing: the code the server shows is the one each till '
      'expects; a mistyped code keeps nothing and frees the server at once '
      'for another till; the server\'s Cancel ends a pairing; both tills '
      'pair', () async {
    final expected = await tillB.startPairing(port);
    final shown = LanTransport().pendingPairingCode!;
    expect(shown, expected);
    final mistyped =
        '${shown.substring(0, 7)}${shown.endsWith('A') ? 'B' : 'A'}';
    expect(await tillB.typeCode(mistyped), isFalse);
    expect(tillB.pin, isNull);
    // The session ended with it: till-a needn't wait for it to expire.
    expect(LanTransport().pendingPairingCode, isNull);
    await tillA.startPairing(port);
    expect(await tillA.typeCode(LanTransport().pendingPairingCode!), isTrue);

    // Cancelled on the server's screen: the code goes, and typing it
    // pairs nothing.
    await tillB.startPairing(port);
    final cancelled = LanTransport().pendingPairingCode!;
    LocalServerProvider().cancelServerPairing();
    expect(LanTransport().pendingPairingCode, isNull);
    await expectLater(
      tillB.typeCode(cancelled),
      throwsA(
        isA<LanHttpException>().having(
          (e) => e.errorCode,
          'error',
          'unknown_session',
        ),
      ),
    );
    expect(tillB.pin, isNull);

    expect(await tillB.startPairing(port), LanTransport().pendingPairingCode);
    expect(await tillB.typeCode(LanTransport().pendingPairingCode!), isTrue);
    expect(tillB.pin, await LanTransport().serverFingerprint());
    expect(LanTransport().pendingPairingCode, isNull);
    expect(tillA.pin, tillB.pin);
  });

  test('2. signing in: a wrong password is refused; both tills sign in and '
      'connect; the server lists them', () async {
    expect(await tillA.signIn(port, password: 'wrong'), isNotNull);
    expect(await tillA.signIn(port), isNull);
    expect(await tillB.signIn(port), isNull);
    await tillA.openSocket();
    await tillB.openSocket();

    await eventually(
      () => device('till-a').connected && device('till-b').connected,
    );
    final devices = LocalServerProvider().connectedDevices();
    expect(devices.first.deviceId, me);
    expect(devices.first.isThisDevice, isTrue);
    expect(device('till-a').userEmail, 'ada@shop.test');
  });

  test('3. the last unit: one till holds it and the other is refused; '
      'released, the other takes it and sells it; the sale lands once',
      () async {
    expect((await tillA.hold('cart-a', 'p1', 1))['ok'], isTrue);
    final refused = await tillB.hold('cart-b', 'p1', 1);
    expect(refused['ok'], isFalse);
    expect(refused['available'], 0.0);
    await eventually(() => tillB.heardHeld('p1', 1.0));

    await tillA.release(cart: 'cart-a');
    await eventually(() => tillB.heardHeld('p1', 0.0));
    expect((await tillB.hold('cart-b', 'p1', 1))['ok'], isTrue);

    final sold = await tillB.checkout(
      'cart-b',
      changeUuid: 'sale-1',
      product: 'p1',
      quantity: 1,
    );
    expect(sold['done'], ['sale-1']);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 0);
    expect(device('till-b').holds, isEmpty);
    // Queued once for the cloud; a repeated checkout changes nothing.
    expect(queued('sale-1'), 1);
    await tillB.checkout(
      'cart-b',
      changeUuid: 'sale-1',
      product: 'p1',
      quantity: 1,
    );
    expect(ProductsFunc().productBox.get('p1')!.quantity, 0);
    expect(queued('sale-1'), 1);
  });

  test('4. a till drops with a cart open: its hold outlasts it for the '
      'grace, then goes, and the other till is told; a till\'s holds can '
      'also be released by hand on the server', () async {
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 2);
    expect((await tillA.hold('cart-a2', 'p1', 1))['ok'], isTrue);
    await eventually(() => tillB.heardHeld('p1', 1.0));
    tillB.events.clear();

    await tillA.dropSocket();
    await eventually(() => !device('till-a').connected);
    // Still held within the grace…
    expect(device('till-a').holds, hasLength(1));
    // …then released, and announced.
    await eventually(() => tillB.heardHeld('p1', 0.0));
    expect(device('till-a').holds, isEmpty);

    expect((await tillB.hold('cart-b2', 'p1', 2))['ok'], isTrue);
    tillB.events.clear();
    expect(await LocalServerProvider().releaseDeviceHolds('till-b'), 1);
    await eventually(() => tillB.heardHeld('p1', 0.0));
    expect(device('till-b').holds, isEmpty);
  });

  test('5. the server\'s internet comes and goes: its tills are told, its '
      'view says so, and its status shows it', () async {
    expect((await tillB.serverView())['online'], isFalse);
    expect(LocalServerProvider().status.serverOnline, isFalse);

    tillB.events.clear();
    online = true;
    LanTransport().interfaceChanged();
    await eventually(() => tillB.heard((e) => e['type'] == 'server'));
    expect((await tillB.serverView())['online'], isTrue);
    expect(LocalServerProvider().status.serverOnline, isTrue);

    tillB.events.clear();
    online = false;
    LanTransport().interfaceChanged();
    await eventually(() => tillB.heard((e) => e['type'] == 'server'));
    expect((await tillB.serverView())['online'], isFalse);
    // On the server itself the online-only screens are as before.
    expect(LocalServerProvider().onlineFeaturesAvailable, isTrue);
  });
}
