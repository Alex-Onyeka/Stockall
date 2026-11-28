import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';

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

/// On the store server: the devices signed in on it with their holds,
/// releasing a device's holds, its `online` flag in the full view, and the
/// password re-entry checked by its own credential store. This test's app
/// serves the shop.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to a real server over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  late String me;
  final opened = <LanConnection>[];

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

  /// [device] signed in as Ada: its connection, session and LAN client.
  Future<(LanConnection, LanSessionHeaders, SupabaseClient)> signIn(
    String device,
  ) async {
    final transport = LanTransport();
    final connection =
        (await LanConnection.open([
          LanEndpoint('127.0.0.1', transport.serverPort!),
        ], pin: await transport.serverFingerprint()))!;
    opened.add(connection);
    // Paired with this server (as pairing would).
    final secret = (await LanHiveAdmission(
      shopId: () => 7,
    ).admit(device, byPerson: true))!;
    final login = await connection.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': device,
      'pair_secret': secret,
    });
    final token = login['token'] as String;
    return (
      connection,
      LanSessionHeaders(token: token, deviceId: device),
      createLanRemote(connection: connection, token: token, deviceId: device),
    );
  }

  Future<void> reserve(SupabaseClient lan, String cart, double quantity) =>
      lan.rpc(
        LanConstants.stockReserveRpc,
        params: {
          'holds': [
            {'cart_id': cart, 'product_uuid': 'p1', 'quantity': quantity},
          ],
        },
      );

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('stockall_p10_server');
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
      access: const ['Make Sale'],
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
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);

    final transport = LanTransport()
      ..discovery = _NoDiscovery()
      ..interfaces = (() async => const [])
      ..serverPorts = const [0]
      // This desktop can't reach the internet in these tests.
      ..isOnline = (() => false);
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
    RemoteRouter.useSupabase(LanRoute.server);
  });

  tearDown(() async {
    for (final c in opened) {
      c.close();
    }
    opened.clear();
    await LanStockHoldsFunc().clearHolds();
  });

  tearDownAll(() async {
    await LanTransport().stopServer();
    RemoteRouter.useSupabase();
  });

  test('the devices signed in here, this desktop first, with who is '
      'signed in, whether connected now, and their holds; a till\'s holds '
      'can be released by hand, and its other tills are told', () async {
    final (phone, phoneSession, phoneLan) = await signIn('phone-1');
    final ws = await phone.openWebSocket(session: phoneSession);
    final events = <Map<String, dynamic>>[];
    ws.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
    );
    await reserve(phoneLan, 'cart-a', 2);
    // A till that signed in and held stock, with no socket open.
    final (_, _, tabletLan) = await signIn('tablet-1');
    await reserve(tabletLan, 'cart-b', 1);

    final provider = LocalServerProvider();
    final devices = provider.connectedDevices();
    expect(devices.map((d) => d.deviceId), [me, 'phone-1', 'tablet-1']);
    expect(devices[0].isThisDevice, isTrue);
    final phoneRow = devices[1];
    expect(phoneRow.connected, isTrue);
    expect(phoneRow.userEmail, 'ada@shop.test');
    expect(phoneRow.holds, [
      (cartId: 'cart-a', productUuid: 'p1', quantity: 2.0),
    ]);
    expect(devices[2].connected, isFalse);
    expect(devices[2].holds.single.quantity, 1.0);

    expect(await provider.releaseDeviceHolds('tablet-1'), 1);
    final after = provider.connectedDevices();
    expect(after.firstWhere((d) => d.deviceId == 'tablet-1').holds, isEmpty);
    expect(after.firstWhere((d) => d.deviceId == 'phone-1').holds, hasLength(1));
    // The phone hears p1's total change (3 held → 2).
    await eventually(
      () => events.any(
        (e) => e['type'] == 'stock' && (e['reserved'] as Map)['p1'] == 2,
      ),
    );
    await ws.close();
  });

  test('the full view says whether this server reaches the internet; a '
      'change of network tells its clients; its status shows it', () async {
    final (phone, phoneSession, _) = await signIn('phone-1');
    final full = await phone.getJson('/v1/server', session: phoneSession);
    expect(full['online'], isFalse);
    expect(full['backfill'], isA<Map<String, dynamic>>());

    final ws = await phone.openWebSocket(session: phoneSession);
    final events = <Map<String, dynamic>>[];
    ws.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
    );
    await eventually(() => events.isNotEmpty);
    final before = events.length;
    LanTransport().interfaceChanged();
    await eventually(
      () => events.skip(before).any((e) => e['type'] == 'server'),
    );

    final status = LocalServerProvider().status;
    expect(status.kind, LanStatusKind.server);
    expect(status.serverOnline, isFalse);
    // On the server itself the online-only screens are as before.
    expect(LocalServerProvider().onlineFeaturesAvailable, isTrue);
    await ws.close();
  });

  test('the password re-entry on the server: its own credential store',
      () async {
    final provider = LocalServerProvider();
    expect(
      await provider.confirmPassword(
        shopId: 7,
        userId: 'cashier',
        password: 'right',
      ),
      LanAuthResult.ok,
    );
    expect(
      await provider.confirmPassword(
        shopId: 7,
        userId: 'cashier',
        password: 'wrong',
      ),
      LanAuthResult.invalidCredentials,
    );
  });
}
