import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_carts.dart';
import 'helpers/lan_fixtures.dart';

/// `SalesProvider.checkoutMain` end to end against a real store server:
/// the server runs in its own isolate with its own Hive (as on
/// another machine) and is reached over TLS with a signed-in device
/// session; the till has every box the app opens (`initHive`).
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; this
  // test talks to a real server over TLS.
  HttpOverrides.global = null;

  late _Server server;
  late SupabaseClient lan;
  late LanConnection connection;
  final client = LanStockClient();
  final sales = SalesProvider();

  setUpAll(() async {
    final tillDir = Directory.systemTemp.createTempSync('stockall_till');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tillDir.path,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('screen_retriever'),
      (call) async => {'displays': <Object?>[]},
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
    // The till: every box the app opens.
    await MainDatabase().initHive();
    // The cashier signed in on the till.
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(
        loggedInUser: TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: '',
          role: 'Cashier',
          departmentUuids: const [],
          access: const ['Make Sale'],
        ),
      ),
    );
    await UserProvider().fetchCurrentUserOffline();
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
    // Queues stay on the till during the test (no Supabase to reach).
    RemoteRouter.useNothing();

    server = await _Server.spawn();
    connection =
        (await LanConnection.open([
          LanEndpoint('127.0.0.1', server.port),
        ], pin: server.pin))!;
    final login = await connection.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': 'phone-1',
    });
    lan = createLanRemote(
      connection: connection,
      token: login['token'] as String,
      deviceId: 'phone-1',
    );
  });

  tearDownAll(() async {
    await client.stop();
    client.reset();
    await lan.dispose();
    connection.close();
    await server.stop();
    RemoteRouter.useSupabase();
  });

  testWidgets('checkoutMain on a LAN till: the receipt is saved, and the '
      'server applies the sale once and releases the cart in one step', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<ReceiptsProvider>.value(
            value: ReceiptsProvider(),
          ),
          ChangeNotifierProvider<NavProvider>.value(value: NavProvider()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      // A cart id is a uuid (the receipt takes it; the app shows its start).
      const sale = '5a1e0000-0000-4000-8000-000000000001';
      // The till's own copy of the product, and its carts: the sale in
      // c1, an empty c2 beside it.
      final p1 = product('p1')..quantity = 5;
      await ProductsFunc().productBox.put('p1', p1.copyWith());
      DataProvider().productListMain = [p1.copyWith()];
      await CartFunc().createMainCart(
        TempMainCart(
          mainCartId: 'm1',
          cartQueue: [
            cart(sale, [line(p1, 2)]),
            cart('c2', []),
          ],
        ),
      );
      sales.mainCartQueue = CartFunc().getMainCart();
      sales.mainCartIdCache = 'm1';
      sales.cartIdCache = sale;

      // As the app's client deps, over this device's LAN session.
      await client.stop();
      client
        ..reset()
        ..deps = LanStockClientDeps(
          link:
              () => LanStockLink(
                call:
                    (rpc, params) async => Map<String, dynamic>.from(
                      await lan.rpc(rpc, params: params) as Map,
                    ),
              ),
          route: () => LanRoute.lanUp,
          carts: () => CartFunc().cartBox.values.expand((m) => m.cartQueue),
          held:
              (p) => DataProvider().productListMain.any(
                (x) => x.uuid == p && x.isManaged,
              ),
          queued:
              () => {
                for (final q in QuantityUpdateFunc().getQuantitiesUpdate())
                  if (q.uuid != null)
                    q.uuid!: {
                      'hiveUuid': q.uuid,
                      'itemUuid': q.productUuid,
                      'quantity': q.quantity,
                      'isIncrement': q.isIncrement,
                      'isStorage': q.isStorage,
                    },
              },
          dropQueued: (uuids) async {
            for (final uuid in uuids) {
              await QuantityUpdateFunc().deleteQuantityUpdate(uuid: uuid);
            }
          },
          cartChanges: () => CartFunc().cartBox.watch(),
          debounce: const Duration(milliseconds: 5),
        )
        ..start();

      await client.reconcile();
      var state = await server.state();
      expect(state['holds'], {'phone-1|$sale|p1': 2.0});

      final tillQueueBefore =
          QuantityUpdateFunc().quantityUpdateBox.keys.toSet();
      final result = await sales.checkoutMain(
        context: context,
        salesCartItem: sales.currentCart(),
        shopId: 7,
        payments: [
          PaymentEntry(
            method: PaymentMethods.cash,
            amount: sales.calcFinalTotal(),
          ),
        ],
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // The till: the receipt saved, its stock taken, the cart gone.
      expect(result?.receipt?.uuid, sale);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(sales.currentMainCart().cartQueue.map((c) => c.id), ['c2']);
      // The sale's stock change reached the server in the checkout, so it
      // left the till's queue (the server sends it to Supabase).
      expect(
        QuantityUpdateFunc().quantityUpdateBox.keys.toSet(),
        tillQueueBefore,
      );
      expect(LanPendingCheckoutsFunc().all(), isEmpty);
      expect(client.own, isEmpty);

      // The server: applied once, the cart released, queued for Supabase.
      state = await server.state();
      expect(state['quantity'], 3.0);
      expect(state['holds'], isEmpty);
      final queued = (state['queued'] as List).cast<String>();
      expect(queued, hasLength(1));
      expect(
        await server.applied([
          'update_product_quantities:${queued.single}',
        ]),
        [true],
      );

      // A repeat (a retry after a lost answer) changes nothing.
      await lan.rpc(
        'lan_checkout',
        params: {
          'cart_id': sale,
          'receipt_uuid': sale,
          'updates': [
            {
              'hiveUuid': queued.single,
              'itemUuid': 'p1',
              'quantity': 2,
              'isIncrement': false,
              'isStorage': false,
            },
          ],
        },
      );
      expect((await server.state())['quantity'], 3.0);
    });
  });
}

/// The store server in its own isolate and Hive: stock 5 of `p1`, one
/// cashier login (ada@shop.test / right).
class _Server {
  _Server._(this.port, this.pin, this._commands, this._isolate);

  final int port;
  final String pin;
  final SendPort _commands;
  final Isolate _isolate;

  static Future<_Server> spawn() async {
    final ready = ReceivePort();
    final dir = Directory.systemTemp.createTempSync('stockall_store').path;
    final isolate = await Isolate.spawn(_serverMain, [ready.sendPort, dir]);
    final hello = await ready.first as Map;
    return _Server._(
      hello['port'] as int,
      hello['pin'] as String,
      hello['commands'] as SendPort,
      isolate,
    );
  }

  Future<Object?> _ask(Map<String, Object?> message) async {
    final reply = ReceivePort();
    _commands.send({...message, 'reply': reply.sendPort});
    return reply.first;
  }

  Future<Map<String, Object?>> state() async =>
      Map<String, Object?>.from(await _ask({'cmd': 'state'}) as Map);

  Future<List<bool>> applied(List<String> keys) async =>
      (await _ask({'cmd': 'applied', 'keys': keys}) as List).cast<bool>();

  Future<void> stop() async {
    await _ask({'cmd': 'stop'});
    _isolate.kill();
  }
}

@pragma('vm:entry-point')
Future<void> _serverMain(List<Object?> args) async {
  final ready = args[0] as SendPort;
  Hive.init(args[1] as String);
  registerAllHiveAdapters();
  await LanCredentialsFunc().init();
  await LanServerSessionsFunc().init();
  await LanShopKeysFunc().init();
  await ProductsFunc().init();
  await QuantityUpdateFunc().init();
  await LanAppliedDeltasFunc().init();
  await LanDeletedItemsFunc().init();
  await LanStockHoldsFunc().init();
  await LanUserBackfill().apply(
    7,
    const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
    [
      TempUserClass(
        userId: 'cashier',
        name: 'Ada',
        email: 'ada@shop.test',
        password: 'right',
        role: 'Cashier',
        departmentUuids: const [],
        access: const ['Make Sale'],
      ),
    ],
    iterations: 1000,
  );
  await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);

  final identity = LanTlsIdentity.generate();
  final deltas = LanDeltaRpcs(
    rpcs: lanDeltaRpcs(shopId: () => 7),
    applied: const HiveAppliedDeltas(),
  );
  LanServer? live;
  final stock = LanStockService(
    exclusive: deltas.runExclusive,
    product: (uuid) => ProductsFunc().productBox.get(uuid),
    applyCheckout:
        (body) => deltas.applyHoldingLock(
          'update_product_quantities',
          body,
          skipUnknown: true,
        ),
    ownDeviceId: () => 'desk-1',
    send: (event) => live?.broadcast(event),
  )..start();
  final engine = HiveRestEngine(
    tables: const [],
    shopId: () => 7,
    manageDepartments: () => false,
    rpcs: deltas,
    stock: stock,
  );
  final server = LanServer(
    identity: identity,
    deviceId: 'desk-1',
    serverView: () => {'epoch': 1, 'cleared': false},
    auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
    rest: engine,
    onDeviceOnline: stock.deviceOnline,
    onDeviceOffline: stock.deviceOffline,
  );
  await server.start(ports: const [0]);
  live = server;

  final commands = ReceivePort();
  ready.send({
    'port': server.port,
    'pin': identity.fingerprint,
    'commands': commands.sendPort,
  });
  await for (final message in commands) {
    final m = message as Map;
    final reply = m['reply'] as SendPort;
    switch (m['cmd']) {
      case 'state':
        reply.send({
          'quantity': ProductsFunc().productBox.get('p1')?.quantity,
          'holds': {for (final h in stock.holds) h.key: h.quantity},
          'queued': [
            for (final k in QuantityUpdateFunc().quantityUpdateBox.keys) '$k',
          ],
        });
      case 'applied':
        reply.send([
          for (final k in m['keys'] as List)
            const HiveAppliedDeltas().contains(k as String),
        ]);
      case 'stop':
        await stock.stop();
        await server.stop();
        await engine.dispose();
        reply.send(null);
        commands.close();
    }
  }
}
