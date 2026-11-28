import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_categories/unsynced/created_category/created_category.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/created_materials/created_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/created_categories/created_categories_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/materials/unsync_funcs/created_materials/created_materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/providers/categories_provider.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/customer_account_receipts_provider.dart';
import 'package:stockall/providers/customers_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/production_folder/material_quantity_update_provider.dart';
import 'package:stockall/providers/quantity_update_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/sync/lan_pending_deltas.dart';
import 'package:stockall/services/lan/sync/lan_server_sync.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';
import 'helpers/lan_samples.dart';
import 'lan_remote_router_test.dart' show MemoryAsyncStorage;

/// A device with no LAN session (every device before LAN sync) behaves as
/// before LAN sync, through the real app: the real routing, `ConnectivityProvider`,
/// `backend()` and `DataProvider.syncData()`, against a local fake Supabase.
void main() {
  late HttpServer supabase;
  final received = <String>[];
  // What a GET of each table answers (else nothing), and a hook run first.
  final rowsFor = <String, List<Map<String, dynamic>>>{};
  Future<void> Function(String table)? onGet;
  // Every POST's path and decoded body, and a hook run while one is out.
  final posted = <(String, Object?)>[];
  Future<void> Function(String path)? onPost;
  late Directory dir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Real sockets for the fake Supabase (the binding fakes HTTP).
    HttpOverrides.global = null;
    dir = Directory.systemTemp.createTempSync('stockall_standalone');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // initHive() keeps the boxes in the app-support directory.
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => dir.path,
    );
    // No connectivity plugin under `flutter test`.
    messenger.setMockStreamHandler(
      const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
      MockStreamHandler.inline(onListen: (_, _) {}),
    );

    supabase = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    supabase.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      received.add('${request.method} ${request.uri.path}');
      request.response.headers.contentType = ContentType.json;
      if (request.method == 'POST') {
        // What PostgREST returns for insert(...).select('uuid').
        final rows = jsonDecode(body);
        posted.add((request.uri.path, rows));
        await onPost?.call(request.uri.path);
        request.response
          ..statusCode = 201
          ..write(
            jsonEncode([
              for (final r in rows is List ? rows : [rows]) {'uuid': r['uuid']},
            ]),
          );
      } else {
        final table = request.uri.pathSegments.last;
        await onGet?.call(table);
        request.response
          ..statusCode = 200
          ..write(jsonEncode(rowsFor[table] ?? const []));
      }
      await request.response.close();
    });
    await Supabase.initialize(
      url: 'http://127.0.0.1:${supabase.port}',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    await MainDatabase().initHive();
    ShopProvider().setShops([TempShopClass.fromJson(shopSample)]);
    // Left over from an earlier LAN life: must stay untouched.
    await LanHandoffsFunc().add(
      jsonEncode(
        LanHandoff(
          kind: LanHandoffKind.rest,
          method: 'POST',
          path: 'products',
          query: '',
          headers: const {'content-type': 'application/json'},
          body: '{"uuid":"old"}',
          serverDeviceId: 'desk-1',
          epoch: 3,
          serverTime: 1,
          handedAt: DateTime.now().toUtc(),
        ).toJson(),
      ),
    );
    LanRouting().start();
  });

  tearDownAll(() async {
    LanRouting().stop();
    await supabase.close(force: true);
  });

  Future<void> queueCategory(String uuid) =>
      CreatedCategoriesFunc().createdCategoriesBox.put(
        uuid,
        CreatedCategory(
          category: CategoryClass(
            name: 'Grains',
            shopId: 7,
            uuid: uuid,
            departmentId: null,
            departmentName: null,
            createdAt: DateTime.utc(2026, 11, 1),
            updatedAt: DateTime.utc(2026, 11, 1),
          ),
        ),
      );

  test('no LAN session: the route is standalone and backend() is '
      'Supabase.instance.client itself', () async {
    expect(ShopProvider().userShop()?.shopId, 7);
    expect(LanClientSessionFunc().get(7), isNull);
    expect(await LanRouting().evaluate(), LanRoute.standalone);
    expect(RemoteRouter.usingLan, isFalse);
    expect(identical(backend(), Supabase.instance.client), isTrue);
  });

  test('isConnected and isOnline() are the interface flag, as before',
      () async {
    final connectivity = ConnectivityProvider();
    connectivity.checkConnection(true);
    expect(connectivity.isConnected, isTrue);
    expect(await connectivity.isOnline(), isTrue);
    connectivity.checkConnection(false);
    expect(connectivity.isConnected, isFalse);
    expect(await connectivity.isOnline(), isFalse);
    connectivity.isConnected = true;
    expect(connectivity.interfaceUp, isTrue);
    expect(connectivity.isConnected, isTrue);
    // Interface changes re-run routing, which stays standalone.
    await LanRouting().evaluate();
    expect(RemoteRouter.route, LanRoute.standalone);
  });

  test('syncData(): offline it keeps the queue; online it sends the queue '
      'to Supabase, with no handoff replayed, recorded or confirmed',
      () async {
    await queueCategory('cat-1');
    final data = DataProvider();
    // What a server reports to its clients: not synced while one is queued.
    expect(data.isSynced(), 0);
    expect(serverQueuesEmpty(), isFalse);

    ConnectivityProvider().checkConnection(false);
    await data.syncData();
    expect(received, isEmpty);
    expect(CreatedCategoriesFunc().getCreateCategories(), hasLength(1));

    ConnectivityProvider().checkConnection(true);
    await data.syncData();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(received, contains('POST /rest/v1/categories'));
    // Nothing else of LAN sync: the old handoff is not replayed, no new one
    // is kept, no handoff status is asked for.
    expect(received.where((r) => r.contains('/products')), isEmpty);
    expect(received.where((r) => r.contains('/v1/handoff')), isEmpty);
    expect(CreatedCategoriesFunc().getCreateCategories(), isEmpty);
    expect(LanHandoffs().all().map((e) => e.$2.body), ['{"uuid":"old"}']);
    expect(data.isSynced(), 1);
    expect(serverQueuesEmpty(), isTrue);
  });

  test('on a serving device, while its puller is active, the providers\' '
      'own fetches are skipped, so their box is never emptied (D29)',
      () async {
    ConnectivityProvider().checkConnection(true);
    await CreatedCategoriesFunc().createdCategoriesBox.clear();
    await CategoryFunc().categoryBox.put(
      'cat-local',
      CategoryClass(
        name: 'Grains',
        shopId: 7,
        uuid: 'cat-local',
        departmentId: null,
        departmentName: null,
      ),
    );
    received.clear();
    LanServerSync.pullerActive = true;
    addTearDown(() => LanServerSync.pullerActive = false);

    await CategoriesProvider().getCategories(7, forceRefresh: true);
    await DataProvider().syncProductsIncremental(shopId: 7);

    expect(received, isEmpty);
    expect(CategoryFunc().categoryBox.containsKey('cat-local'), isTrue);
    expect(
      CategoriesProvider().categoriesMain.map((c) => c.uuid),
      contains('cat-local'),
    );

    // Without the puller, as before: fetched, and the box replaced.
    LanServerSync.pullerActive = false;
    await CategoriesProvider().getCategories(7, forceRefresh: true);
    expect(received, contains('GET /rest/v1/categories'));
    expect(CategoryFunc().categoryBox.containsKey('cat-local'), isFalse);
  });

  test('the app\'s own products pull adds back stock changes still queued, '
      'and pulls again when one was sent meanwhile (D27)', () async {
    ConnectivityProvider().checkConnection(true);
    final data = DataProvider();
    // Supabase has 10; a sale of 2 is still queued here, so 8 locally.
    final local = product('p1')..quantity = 8;
    await ProductsFunc().productBox.put('p1', local);
    data.productListMain = [local];
    await ProductsFunc().setLastSyncTime(DateTime.utc(2026, 11, 1));
    await QuantityUpdateFunc().quantityUpdateBox.put(
      'q1',
      QuantityUpdate(
        uuid: 'q1',
        createdAt: DateTime.now(),
        quantity: 2,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    addTearDown(() async {
      onGet = null;
      rowsFor.clear();
      await QuantityUpdateFunc().quantityUpdateBox.clear();
    });
    Map<String, dynamic> remote(double quantity, String price) => {
      ...jsonDecode(jsonEncode(product('p1').toJson(isIncludeQuantity: true)))
          as Map<String, dynamic>,
      'quantity': quantity,
      'selling_price': double.parse(price),
      'updated_at': '2026-11-02T08:00:00.000Z',
    };
    rowsFor['products'] = [remote(10, '20')];

    await data.syncProductsIncremental(shopId: 7);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    expect(ProductsFunc().productBox.get('p1')!.sellingPrice, 20);
    expect(data.productListMain.single.quantity, 8);

    // The sale is sent while the pull is out: Supabase now has 8, and the
    // rows are not stored (nor the sync time moved): pulled again later.
    final before = ProductsFunc().getLastSyncTime();
    onGet = (table) async {
      if (table != 'products') return;
      await QuantityUpdateFunc().quantityUpdateBox.delete('q1');
      rowsFor['products'] = [remote(8, '25')];
    };
    await data.syncProductsIncremental(shopId: 7);
    expect(ProductsFunc().productBox.get('p1')!.sellingPrice, 20);
    expect(ProductsFunc().getLastSyncTime(), before);

    onGet = null;
    await data.syncProductsIncremental(shopId: 7);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    expect(ProductsFunc().productBox.get('p1')!.sellingPrice, 25);
  });

  test('the app\'s full products fetch (getProducts) adds back stock '
      'changes still queued, and discards its rows when one was sent '
      'meanwhile (D27)', () async {
    ConnectivityProvider().checkConnection(true);
    final data = DataProvider();
    addTearDown(data.stopPeriodicIncrementalSync);
    await ProductsFunc().productBox.clear();
    await ProductsFunc().productBox.put(
      'p1',
      product('p1')
        ..quantity = 8
        ..sellingPrice = 20,
    );
    await ProductsFunc().syncMetaBox?.clear();
    await QuantityUpdateFunc().quantityUpdateBox.put(
      'q1',
      QuantityUpdate(
        uuid: 'q1',
        createdAt: DateTime.now(),
        quantity: 2,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    addTearDown(() async {
      onGet = null;
      rowsFor.clear();
      await QuantityUpdateFunc().quantityUpdateBox.clear();
    });
    Map<String, dynamic> remote(double quantity, String price) => {
      ...jsonDecode(jsonEncode(product('p1').toJson(isIncludeQuantity: true)))
          as Map<String, dynamic>,
      'quantity': quantity,
      'selling_price': double.parse(price),
    };

    // The sale is sent while the fetch is out: Supabase has 8 by then, and
    // the rows are discarded (no sync time recorded): what is stored stays.
    rowsFor['products'] = [remote(10, '25')];
    onGet = (table) async {
      if (table != 'products') return;
      await QuantityUpdateFunc().quantityUpdateBox.delete('q1');
      rowsFor['products'] = [remote(8, '25')];
    };
    await data.getProducts(7);
    expect(ProductsFunc().productBox.get('p1')!.sellingPrice, 20);
    expect(data.productListMain.single.sellingPrice, 20);
    expect(ProductsFunc().getLastSyncTime(), isNull);

    // Pulled again by the next sync: Supabase's row is stored.
    onGet = null;
    await data.syncProductsIncremental(shopId: 7);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    expect(ProductsFunc().productBox.get('p1')!.sellingPrice, 25);
    expect(ProductsFunc().getLastSyncTime(), isNotNull);

    // With a sale of 2 queued and Supabase at 10: 8, not 10.
    await QuantityUpdateFunc().quantityUpdateBox.put(
      'q2',
      QuantityUpdate(
        uuid: 'q2',
        createdAt: DateTime.now(),
        quantity: 2,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    rowsFor['products'] = [remote(10, '30')];
    await data.getProducts(7);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    expect(ProductsFunc().productBox.get('p1')!.sellingPrice, 30);
    expect(data.productListMain.single.quantity, 8);
  });

  test('the app\'s own customers pull, in full and incremental, adds back '
      'balance and reward changes still queued (D27)', () async {
    ConnectivityProvider().checkConnection(true);
    final c1 = customer('c1', department: null);
    Map<String, dynamic> remote(double balance, String name) => {
      ...jsonDecode(jsonEncode(c1.toJson(isMoneyUpdate: true)))
          as Map<String, dynamic>,
      'balance': balance,
      'cash_reward': 0.0,
      'name': name,
    };
    rowsFor['customers'] = [remote(100, 'Bola')];
    addTearDown(() async {
      rowsFor.clear();
      await CustomerAccountUpdateFunc().customerAccountUpdateBox.clear();
    });
    for (final (id, amount, balance) in [('a1', 5.0, true), ('a2', 1.0, false)]) {
      await CustomerAccountUpdateFunc().customerAccountUpdateBox.put(
        id,
        CustomerAccountUpdate(
          uuid: id,
          createdAt: DateTime.now(),
          amount: amount,
          customerUuid: 'c1',
          isIncrement: balance,
          isBalance: balance,
        ),
      );
    }

    // In full (first fetch).
    await CustomersProvider().fetchCustomers(7, forceRefresh: true);
    var stored = CustomerFunc().customerBox.get('c1')!;
    expect(stored.balance, 105);
    expect(stored.cashReward, -1);

    // Incremental (fetched before): the same.
    rowsFor['customers'] = [remote(100, 'Bola A.')];
    await CustomersProvider().fetchCustomers(7);
    stored = CustomerFunc().customerBox.get('c1')!;
    expect(stored.name, 'Bola A.');
    expect(stored.balance, 105);
    expect(stored.cashReward, -1);
  });

  test('a stock change for a product whose create is still queued waits: '
      'the other changes go, it stays queued for a later run', () async {
    ConnectivityProvider().checkConnection(true);
    posted.clear();
    addTearDown(() async {
      await CreatedProductFunc().createdProductsBox.clear();
      await QuantityUpdateFunc().quantityUpdateBox.clear();
    });
    await CreatedProductFunc().createProduct(
      CreatedProducts(product: product('p-new'), includeQuantity: true),
    );
    for (final (id, item) in [('q-new', 'p-new'), ('q-old', 'p1')]) {
      await QuantityUpdateFunc().quantityUpdateBox.put(
        id,
        QuantityUpdate(
          uuid: id,
          createdAt: DateTime.now(),
          quantity: 1,
          productUuid: item,
          isIncrement: false,
          isStorage: false,
        ),
      );
    }

    await QuantityUpdateProvider().quantityUpdateSync();

    final sent = posted.where(
      (p) => p.$1 == '/rest/v1/rpc/update_product_quantities',
    );
    expect(sent, hasLength(1));
    final updates = (sent.single.$2 as Map)['updates'] as List;
    expect(updates.map((u) => (u as Map)['hiveUuid']), ['q-old']);
    expect(QuantityUpdateFunc().quantityUpdateBox.keys, ['q-new']);
  });

  test('a material change queued while a batch is out becomes a new entry '
      '(not merged into the sent one); only the sent entry is removed after '
      'the answer', () async {
    ConnectivityProvider().checkConnection(true);
    posted.clear();
    final queue = MaterialsQuantityUpdateFunc();
    addTearDown(() async {
      onPost = null;
      await queue.materialsQuantityUpdateBox.clear();
    });
    await queue.createMaterialsQuantityUpdate(
      MaterialQuantityUpdate(
        uuid: 'm-a',
        createdAt: DateTime.now(),
        quantity: 2,
        materialUuid: 'mat-1',
        isIncrement: false,
      ),
    );
    onPost = (path) async {
      if (!path.endsWith('/rpc/update_materials_quantities')) return;
      // A usage recorded while the batch is out.
      await queue.createMaterialsQuantityUpdate(
        MaterialQuantityUpdate(
          uuid: 'm-b',
          createdAt: DateTime.now(),
          quantity: 3,
          materialUuid: 'mat-1',
          isIncrement: false,
        ),
      );
    };

    await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();

    final sent = posted.singleWhere(
      (p) => p.$1 == '/rest/v1/rpc/update_materials_quantities',
    );
    final updates = (sent.$2 as Map)['updates'] as List;
    expect(updates.single['quantity'], 2);
    // Off the LAN no hiveUuid goes to Supabase.
    expect((updates.single as Map).containsKey('hiveUuid'), isFalse);
    expect(queue.materialsQuantityUpdateBox.keys, ['m-b']);
    expect(queue.materialsQuantityUpdateBox.get('m-b')!.quantity, 3);
    expect(
      SentEntriesFunc().isSent(queue.materialsQuantityUpdateBoxName, 'm-a'),
      isFalse,
    );
  });

  test('a material change for a material whose create is still queued '
      'waits: the other changes go, it stays queued for a later run',
      () async {
    ConnectivityProvider().checkConnection(true);
    posted.clear();
    final queue = MaterialsQuantityUpdateFunc();
    addTearDown(() async {
      await CreatedMaterialsFunc().createdMaterialsBox.clear();
      await queue.materialsQuantityUpdateBox.clear();
    });
    await CreatedMaterialsFunc().createMaterial(
      CreatedMaterial(
        material: MaterialClass(
          uuid: 'mat-new',
          name: 'Flour',
          unit: 'kg',
          costPrice: 1,
          shopId: 7,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: null,
          qttyPerGroup: null,
          categories: const [],
          useGroupUnit: false,
          unitsList: const [],
          quantity: 10,
        ),
        includeQuantity: true,
      ),
    );
    for (final (id, item) in [('mq-new', 'mat-new'), ('mq-old', 'mat-1')]) {
      await queue.materialsQuantityUpdateBox.put(
        id,
        MaterialQuantityUpdate(
          uuid: id,
          createdAt: DateTime.now(),
          quantity: 1,
          materialUuid: item,
          isIncrement: false,
        ),
      );
    }

    await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();

    final sent = posted.singleWhere(
      (p) => p.$1 == '/rest/v1/rpc/update_materials_quantities',
    );
    final updates = (sent.$2 as Map)['updates'] as List;
    expect(updates.map((u) => (u as Map)['materialItemUuid']), ['mat-1']);
    expect(queue.materialsQuantityUpdateBox.keys, ['mq-new']);
  });

  test('an account change for a customer whose create is still queued '
      'waits: the other changes go, it stays queued for a later run',
      () async {
    ConnectivityProvider().checkConnection(true);
    posted.clear();
    final queue = CustomerAccountUpdateFunc();
    addTearDown(() async {
      await CreatedCustomersFunc().createdCustomersBox.clear();
      await queue.customerAccountUpdateBox.clear();
    });
    await CreatedCustomersFunc().createCustomers(
      CreatedCustomers(customer: customer('c-new')),
    );
    for (final (id, item) in [('ca-new', 'c-new'), ('ca-old', 'c-1')]) {
      await queue.customerAccountUpdateBox.put(
        id,
        CustomerAccountUpdate(
          uuid: id,
          createdAt: DateTime.now(),
          amount: 5,
          customerUuid: item,
          isIncrement: true,
          isBalance: true,
        ),
      );
    }

    await CustomerAccountReceiptsProvider().customerAccountUpdateSync();

    final sent = posted.singleWhere(
      (p) => p.$1 == '/rest/v1/rpc/update_customer_account',
    );
    final updates = (sent.$2 as Map)['updates'] as List;
    expect(updates.map((u) => (u as Map)['customerUuid']), ['c-1']);
    expect(queue.customerAccountUpdateBox.keys, ['ca-new']);
  });
  test('no LAN session: a products fetch while the stock batch is out '
      '(Supabase applied it, the answer is not back) does not add the sale '
      'back a second time; nor is a fetch stored once a sync has started',
      () async {
    ConnectivityProvider().checkConnection(true);
    final data = DataProvider();
    addTearDown(data.stopPeriodicIncrementalSync);
    await ProductsFunc().productBox.clear();
    await ProductsFunc().syncMetaBox?.clear();
    // Supabase has 10; a sale of 2 is queued here, so 8 locally.
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 8);
    await QuantityUpdateFunc().quantityUpdateBox.put(
      'q1',
      QuantityUpdate(
        uuid: 'q1',
        createdAt: DateTime.now(),
        quantity: 2,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    Map<String, dynamic> remote(double quantity) => {
      ...jsonDecode(jsonEncode(product('p1').toJson(isIncludeQuantity: true)))
          as Map<String, dynamic>,
      'quantity': quantity,
    };
    addTearDown(() async {
      onPost = null;
      onGet = null;
      rowsFor.clear();
      data.toggleSyncing(false);
      await QuantityUpdateFunc().quantityUpdateBox.clear();
      await SentEntriesFunc().clearSentEntries();
    });
    rowsFor['products'] = [remote(10)];
    var fetchedWhileOut = false;
    onPost = (path) async {
      if (!path.endsWith('rpc/update_product_quantities')) return;
      onPost = null;
      // Supabase has applied the sale; its answer is still on the way.
      rowsFor['products'] = [remote(8)];
      expect(
        SentEntriesFunc().isSent(
          QuantityUpdateFunc().quantityUpdateBoxName,
          'q1',
        ),
        isTrue,
      );
      int gets() =>
          received.where((r) => r == 'GET /rest/v1/products').length;
      final before = gets();
      await data.getProducts(7);
      fetchedWhileOut = gets() > before;
      expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    };
    await QuantityUpdateProvider().quantityUpdateSync();
    expect(fetchedWhileOut, isTrue);
    expect(QuantityUpdateFunc().quantityUpdateBox.isEmpty, isTrue);
    expect(SentEntriesFunc().sentEntriesBox.isEmpty, isTrue);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);

    // A sync starts while a fetch is out: its rows are not stored.
    rowsFor['products'] = [remote(5)];
    onGet = (table) async {
      if (table == 'products') data.toggleSyncing(true);
    };
    await data.getProducts(7);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    data.toggleSyncing(false);
    onGet = null;
    await data.getProducts(7);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 5);
  });

  test('no LAN session: an entry out (sent, not answered) means a pull must '
      'not add the queue back', () async {
    final queue = CustomerAccountUpdateFunc();
    await queue.customerAccountUpdateBox.put(
      'a1',
      CustomerAccountUpdate(
        uuid: 'a1',
        createdAt: DateTime.now(),
        amount: 5,
        customerUuid: 'c1',
        isIncrement: true,
        isBalance: true,
      ),
    );
    addTearDown(() async {
      await queue.customerAccountUpdateBox.clear();
      await SentEntriesFunc().clearSentEntries();
    });
    final before = PendingDeltas.queueKeys('customers');
    expect(PendingDeltas.stillQueued('customers', before), isTrue);
    await SentEntriesFunc().markSent(queue.customerAccountUpdateBoxName, [
      'a1',
    ]);
    expect(PendingDeltas.stillQueued('customers', before), isFalse);
    expect(PendingDeltas.stillQueued('products', const {}), isTrue);
  });
}
