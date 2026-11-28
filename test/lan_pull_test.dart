import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/customer_account_receipts/customer_account_receipts_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/department_func/departments_func.dart';
import 'package:stockall/local_database/drafts_func/drafts_func.dart';
import 'package:stockall/local_database/error_log/error_log_func.dart';
import 'package:stockall/local_database/events_log/events_log_func.dart';
import 'package:stockall/local_database/expenses/expense_categories_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_pull_cursors_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/materials_item_history/materials_item_histories_func.dart';
import 'package:stockall/local_database/materials_usage/production_materials_usage_func.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
import 'package:stockall/local_database/production_item_history/production_item_histories_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/productions/production_records_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/storage_item_history/storage_item_histories_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/local_database/sub_staff/sub_staff_func.dart';
import 'package:stockall/local_database/suppliers_func/suppliers_func.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/sync/lan_pending_deltas.dart';
import 'package:stockall/services/lan/sync/lan_puller.dart';
import 'package:stockall/services/lan/sync/lan_supabase_reader.dart';

import 'helpers/lan_fixtures.dart';
import 'helpers/lan_samples.dart';

/// Plays Supabase's REST API for the pulls: `eq.`, `gt.` and `in.`
/// filters, `select`, `order`, `limit` and `offset`, over in-memory tables.
class FakeSupabase {
  late HttpServer server;
  final tables = <String, List<Map<String, dynamic>>>{};
  final requests = <Uri>[];

  /// Response bytes sent, all tables.
  var bytes = 0;

  /// Runs before a table is answered (to change things mid-pull).
  Future<void> Function(String table)? onGet;

  String get restUrl => 'http://127.0.0.1:${server.port}/rest/v1';

  static int _cmp(Object? a, String b) {
    if (a is num) return a.compareTo(num.parse(b));
    final s = '$a';
    final da = s.contains(':') ? DateTime.tryParse(s) : null;
    final db = b.contains(':') ? DateTime.tryParse(b) : null;
    if (da != null && db != null) return da.compareTo(db);
    return s.compareTo(b);
  }

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add(request.uri);
      final table = request.uri.pathSegments.last;
      await onGet?.call(table);
      final q = request.uri.queryParameters;
      var rows = List.of(tables[table] ?? const <Map<String, dynamic>>[]);
      for (final MapEntry(:key, :value) in q.entries) {
        if (const {'order', 'limit', 'offset', 'select'}.contains(key)) {
          continue;
        }
        if (key == 'or') {
          // The keyset page: (a.gt."T",and(a.eq."T",k.gt."K")).
          final m = RegExp(
            r'^\((\w+)\.gt\."([^"]*)",and\((\w+)\.eq\."([^"]*)",(\w+)\.gt\."([^"]*)"\)\)$',
          ).firstMatch(value);
          if (m == null) throw StateError('unsupported or=$value');
          final (a, t, k, last) = (m[1]!, m[2]!, m[5]!, m[6]!);
          rows = rows.where((r) {
            if (r[a] == null) return false;
            final c = _cmp(r[a], t);
            return c > 0 || (c == 0 && _cmp(r[k], last) > 0);
          }).toList();
          continue;
        }
        if (value.startsWith('eq.')) {
          rows = rows.where((r) => '${r[key]}' == value.substring(3)).toList();
        } else if (value.startsWith('gt.')) {
          rows = rows
              .where((r) => r[key] != null && _cmp(r[key], value.substring(3)) > 0)
              .toList();
        } else if (value.startsWith('in.(') && value.endsWith(')')) {
          final ids = {
            for (final v in value.substring(4, value.length - 1).split(','))
              v.replaceAll('"', ''),
          };
          rows = rows.where((r) => ids.contains('${r[key]}')).toList();
        }
      }
      final order = [
        for (final term in (q['order'] ?? '').split(','))
          if (term.isNotEmpty) term.split('.'),
      ];
      rows.sort((a, b) {
        for (final o in order) {
          final c = _cmp(a[o[0]], '${b[o[0]]}');
          if (c != 0) return o.length > 1 && o[1] == 'desc' ? -c : c;
        }
        return 0;
      });
      final offset = int.tryParse(q['offset'] ?? '') ?? 0;
      final limit = int.tryParse(q['limit'] ?? '') ?? rows.length;
      rows = rows.skip(offset).take(limit).toList();
      final select = q['select'];
      if (select != null && select != '*') {
        final columns = select.split(',');
        rows = [
          for (final r in rows) {for (final c in columns) c: r[c]},
        ];
      }
      final body = jsonEncode(rows);
      bytes += body.length;
      request.response
        ..headers.contentType = ContentType.json
        ..write(body);
      await request.response.close();
    });
  }

  List<Uri> requestsFor(String table) =>
      requests.where((u) => u.pathSegments.last == table).toList();
}

Map<String, dynamic> wire(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

String at(int day, [int hour = 8]) =>
    '2026-11-${'$day'.padLeft(2, '0')}T${'$hour'.padLeft(2, '0')}:00:00+00:00';

/// A product as Supabase sends it.
Map<String, dynamic> remoteProduct(
  String uuid, {
  double quantity = 10,
  String? updatedAt,
  int shopId = 7,
  bool withUnits = true,
}) {
  final p = product(uuid, shopId: shopId);
  p.quantity = quantity;
  final json = wire(p.toJson(isIncludeQuantity: true))
    ..['updated_at'] = updatedAt ?? at(1);
  if (!withUnits) {
    json
      ..['units_list'] = <Object>[]
      ..['prices_list'] = <Object>[];
  }
  return json;
}

void main() {
  late FakeSupabase supabase;
  late LanPuller puller;
  var online = true;
  var lock = LanDeltaRpcs(rpcs: const [], applied: _NoApplied());

  LanPuller make({int pageSize = 1000, DateTime Function()? clock}) {
    return LanPuller(
      tables: lanTables(shopId: () => 7),
      reader: LanSupabaseReader(
        restUrl: () => supabase.restUrl,
        headers: () => const {'apikey': 'anon'},
        client: http.Client(),
      ),
      shopId: () => 7,
      exclusive: lock.runExclusive,
      canPull: () => online,
      onRemoteDeleted: (table, uuid) => LanDeletedItemsFunc().add(table, uuid),
      pageSize: pageSize,
      clock: clock,
    );
  }

  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_pull').path);
    registerAllHiveAdapters();
    for (final init in [
      DraftsFunc().init,
      CustomerAccountReceiptsFunc().init,
      CategoryFunc().init,
      DepartmentsFunc().init,
      SuppliersFunc().init,
      SubStaffFunc().init,
      StorageProductsFunc().init,
      StorageItemHistoriesFunc().init,
      ItemHistoriesFunc().init,
      InventoryUpdatesFunc().init,
      EventsLogFunc().init,
      ErrorLogFunc().init,
      PurchaseFunc().init,
      MaterialsFunc().init,
      ProductionMaterialsUsageFunc().init,
      ProductionItemsFunc().init,
      ProductionItemHistoriesFunc().init,
      MaterialsItemHistoriesFunc().init,
      ProductionRecordsFunc().init,
      ExpenseCategoriesFunc().init,
      ShopFunc().init,
      UpdatedShopFunc().init,
      PermissionFunc().init,
      ProductsFunc().init,
      MainReceiptFunc().init,
      InvoicesFunc().init,
      OrdersFunc().init,
      CustomerFunc().init,
      ExpensesFunc().init,
      QuantityUpdateFunc().init,
      MaterialsQuantityUpdateFunc().init,
      ProductionItemsQuantityUpdateFunc().init,
      CustomerAccountUpdateFunc().init,
      LanCredentialsFunc().init,
      LanDeletedItemsFunc().init,
      LanPullCursorsFunc().init,
      SentEntriesFunc().init,
    ]) {
      await init();
    }
  });

  setUp(() async {
    online = true;
    lock = LanDeltaRpcs(rpcs: const [], applied: _NoApplied());
    for (final box in [
      ProductsFunc().productBox,
      CreatedProductFunc().createdProductsBox,
      UpdatedProductsFunc().updatedProductsBox,
      DeletedProductsFunc().deletedProductsBox,
      QuantityUpdateFunc().quantityUpdateBox,
      CustomerFunc().customerBox,
      CustomerAccountUpdateFunc().customerAccountUpdateBox,
      ItemHistoriesFunc().itemHistoryBox,
      CategoryFunc().categoryBox,
      ShopFunc().shopBox,
      UpdatedShopFunc().updatedShopBox,
      PermissionFunc().permissionModelBox,
      LanDeletedItemsFunc().deletedItemsBox,
      LanPullCursorsFunc().pullCursorsBox,
    ]) {
      await (box as Box).clear();
    }
    await SentEntriesFunc().clearSentEntries();
    supabase = FakeSupabase();
    await supabase.start();
    puller = make();
  });

  tearDown(() => supabase.server.close(force: true));

  tearDownAll(() async {
    await Hive.close();
  });

  test('a backfill pages through every table in order, stores rows without '
      'queueing them, and reports where it is', () async {
    supabase.tables['products'] = [
      for (var i = 0; i < 2500; i++)
        remoteProduct(
          'p${'$i'.padLeft(4, '0')}',
          updatedAt: at(1 + i % 20),
        ),
      // Another store's: never asked for.
      remoteProduct('x1', shopId: 8),
    ];
    supabase.tables['categories'] = [
      {...lanSamples().firstWhere((s) => s.table == 'categories').json},
    ];
    supabase.tables['item_history'] = [
      {...lanSamples().firstWhere((s) => s.table == 'item_history').json},
    ];
    puller = make();

    expect(puller.progress.toJson()['done'], isFalse);
    final ok = await puller.backfill();

    expect(ok, isTrue);
    expect(ProductsFunc().productBox.length, 2500);
    expect(ProductsFunc().productBox.containsKey('x1'), isFalse);
    expect(CategoryFunc().categoryBox.length, 1);
    expect(ItemHistoriesFunc().itemHistoryBox.length, 1);
    // Pulled rows are already on Supabase: nothing is queued.
    expect(CreatedProductFunc().getProducts(), isEmpty);
    // Three pages of products, by key.
    final pages = supabase.requestsFor('products');
    expect(pages, hasLength(3));
    expect(pages.first.queryParameters, {
      'shop_id': 'eq.7',
      'order': 'uuid.asc',
      'limit': '1000',
    });
    expect(pages[1].queryParameters['uuid'], 'gt.p0999');
    // Store lists first, then what a sale needs, then records and logs.
    final order = <String>{
      for (final u in supabase.requests) u.pathSegments.last,
    }.toList();
    expect(order.indexOf('categories'), lessThan(order.indexOf('products')));
    expect(order.indexOf('products'), lessThan(order.indexOf('orders')));
    expect(order.indexOf('orders'), lessThan(order.indexOf('receipts')));
    expect(order.indexOf('receipts'), lessThan(order.indexOf('item_history')));
    expect(order, isNot(contains('users')));
    // The newest change seen, as Supabase wrote it.
    expect(LanPullCursorsFunc().cursor('products'), at(20));
    expect(LanPullCursorsFunc().backfillAt(), isNotNull);
    final progress = puller.progress.toJson();
    expect(progress['done'], isTrue);
    expect(progress['running'], isFalse);
    expect(progress['at'], isNotNull);
  });

  test('local work is never overwritten; queued stock and account changes '
      'are added back to the rows pulled', () async {
    supabase.tables['products'] = [
      for (final id in ['p1', 'p2', 'p3', 'p4', 'p5'])
        remoteProduct(id, quantity: 10),
    ];
    for (final id in ['p1', 'p3', 'p4', 'p5']) {
      await ProductsFunc().productBox.put(id, product(id)..quantity = 3);
    }
    // p1: an update queued; p2: a create queued; p3: a delete queued (the
    // app adds it under an automatic key).
    await UpdatedProductsFunc().updatedProductsBox.put(
      'p1',
      UpdatedProducts(product: product('p1'), includeQuantity: false),
    );
    await CreatedProductFunc().createdProductsBox.put(
      'p2',
      CreatedProducts(product: product('p2'), includeQuantity: true),
    );
    await ProductsFunc().productBox.delete('p3');
    await DeletedProductsFunc().deletedProductsBox.add(
      DeletedProducts(productUuid: 'p3', date: DateTime.now()),
    );
    // p4: a sale of 2 and a storage move of 5 still queued.
    for (final (id, q, storage) in [('q1', 2.0, false), ('q2', 5.0, true)]) {
      await QuantityUpdateFunc().quantityUpdateBox.put(
        id,
        QuantityUpdate(
          uuid: id,
          createdAt: DateTime.now(),
          quantity: q,
          productUuid: 'p4',
          isIncrement: false,
          isStorage: storage,
        ),
      );
    }
    supabase.tables['customers'] = [
      wire(customer('c1').toJson(isMoneyUpdate: true))..['balance'] = 100.0,
    ];
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

    expect(await puller.fullPull('products'), isTrue);
    expect(await puller.fullPull('customers'), isTrue);

    final box = ProductsFunc().productBox;
    expect(box.get('p1')!.quantity, 3, reason: 'update queued');
    expect(box.containsKey('p2'), isFalse, reason: 'create queued');
    expect(box.containsKey('p3'), isFalse, reason: 'delete queued');
    expect(box.get('p4')!.quantity, 8, reason: 'Supabase 10, sale of 2');
    expect(box.get('p5')!.quantity, 10);
    final c1 = CustomerFunc().customerBox.get('c1')!;
    expect(c1.balance, 105);
    expect(c1.cashReward, -1);
  });

  test('a queued change sent while a page was out: the page is dropped and '
      'pulled again; a page is stored only between delta batches', () async {
    supabase.tables['products'] = [remoteProduct('p1', quantity: 10)];
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
    // The server's sync sends q1 while the page is on its way.
    supabase.onGet = (table) async {
      if (table == 'products') {
        await QuantityUpdateFunc().quantityUpdateBox.delete('q1');
        supabase.tables['products'] = [remoteProduct('p1', quantity: 8)];
      }
    };
    expect(await puller.fullPull('products'), isFalse);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    expect(LanPullCursorsFunc().cursor('products'), isNull);

    supabase.onGet = null;
    expect(await puller.fullPull('products'), isTrue);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);

    // A delta batch holds the lock: the pull's page waits for it.
    supabase.tables['products'] = [remoteProduct('p1', quantity: 20)];
    final release = Completer<void>();
    final batch = lock.runExclusive(() => release.future);
    final pull = puller.fullPull('products');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
    release.complete();
    await batch;
    expect(await pull, isTrue);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 20);
  });

  test('a page fetched while a queued change is out (the server\'s sync '
      'sent it, no answer yet) is not stored; once answered, the next page '
      'is stored with nothing added back', () async {
    // Supabase has applied the sale of 2 already: 8.
    supabase.tables['products'] = [remoteProduct('p1', quantity: 8)];
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
    final queue = QuantityUpdateFunc().quantityUpdateBoxName;
    await SentEntriesFunc().markSent(queue, ['q1']);

    expect(await puller.fullPull('products'), isFalse);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);

    // The answer: removed from the queue and unmarked.
    await QuantityUpdateFunc().quantityUpdateBox.delete('q1');
    await SentEntriesFunc().unmark(queue, ['q1']);
    expect(await puller.fullPull('products'), isTrue);
    expect(ProductsFunc().productBox.get('p1')!.quantity, 8);
  });

  test('an item with a change sent to another store server that never '
      'answered keeps its stored amount (the pulled row may or may not have '
      'it); the others get their queued changes added back', () async {
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 7);
    for (final (id, item) in [('q1', 'p1'), ('q2', 'p2')]) {
      await QuantityUpdateFunc().quantityUpdateBox.put(
        id,
        QuantityUpdate(
          uuid: id,
          createdAt: DateTime.now(),
          quantity: 2,
          productUuid: item,
          isIncrement: false,
          isStorage: false,
        ),
      );
    }
    final queue = QuantityUpdateFunc().quantityUpdateBoxName;
    await SentEntriesFunc().markSent(queue, ['q1'], toServer: 'desk-1');

    // This device's queues go to Supabase now: not in flight, but held.
    expect(PendingDeltas.stillQueued('products', {'q1', 'q2'}), isTrue);
    expect(PendingDeltas.heldItems('products'), {'p1'});
    final rows = [
      product('p1')..quantity = 10,
      product('p2')..quantity = 10,
    ];
    PendingDeltas.reapply('products', rows);
    expect(rows[0].quantity, 7);
    expect(rows[1].quantity, 8);
  });

  test('incremental: from the cursor on Supabase\'s clock, 5 s back; '
      'histories by created_at; a table never pulled is pulled in full',
      () async {
    supabase.tables['products'] = [
      remoteProduct('p1', updatedAt: at(2)),
      remoteProduct('p2', updatedAt: at(3)),
    ];
    final history = {
      ...lanSamples().firstWhere((s) => s.table == 'item_history').json,
    };
    supabase.tables['item_history'] = [history];
    expect(await puller.pullIncremental(['products', 'item_history']), isTrue);
    // Never pulled: in full (no cursor filter).
    expect(
      supabase.requestsFor('products').single.queryParameters['updated_at'],
      isNull,
    );
    expect(LanPullCursorsFunc().cursor('products'), at(3));

    supabase.tables['products']!.add(
      remoteProduct('p3', quantity: 7, updatedAt: at(4)),
    );
    supabase.tables['item_history']!.add({
      ...history,
      'uuid': 'ih-2',
      'created_at': '2026-11-05T08:00:00.000Z',
    });
    supabase.requests.clear();
    expect(await puller.pullIncremental(['products', 'item_history']), isTrue);

    final productQuery = supabase.requestsFor('products').single.queryParameters;
    expect(productQuery['updated_at'], 'gt.2026-11-03T07:59:55.000Z');
    expect(productQuery['order'], 'updated_at.asc,uuid.asc');
    expect(ProductsFunc().productBox.get('p3')!.quantity, 7);
    expect(LanPullCursorsFunc().cursor('products'), at(4));
    final historyQuery =
        supabase.requestsFor('item_history').single.queryParameters;
    expect(historyQuery.containsKey('created_at'), isTrue);
    expect(historyQuery.containsKey('updated_at'), isFalse);
    expect(ItemHistoriesFunc().itemHistoryBox.containsKey('ih-2'), isTrue);
  });

  test('incremental pages by (updated_at, uuid): a row updated while paging '
      'shifts nothing out of a page (D6)', () async {
    puller = make(pageSize: 2);
    await LanPullCursorsFunc().setCursor('products', at(1));
    supabase.tables['products'] = [
      for (var i = 1; i <= 5; i++) remoteProduct('p$i', updatedAt: at(i + 1)),
    ];
    var gets = 0;
    supabase.onGet = (table) async {
      if (table != 'products' || ++gets != 2) return;
      // p1 (on the first page) changes on Supabase before the second page.
      final p1 = supabase.tables['products']!.removeAt(0);
      supabase.tables['products']!.add({
        ...p1,
        'quantity': 99,
        'updated_at': at(9),
      });
    };
    expect(await puller.pullIncremental(['products']), isTrue);

    for (var i = 1; i <= 5; i++) {
      expect(ProductsFunc().productBox.containsKey('p$i'), isTrue, reason: 'p$i');
    }
    expect(ProductsFunc().productBox.get('p1')!.quantity, 99);
    final pages = supabase.requestsFor('products');
    expect(pages.first.queryParameters['updated_at'], startsWith('gt.'));
    expect(
      pages[1].queryParameters['or'],
      '(updated_at.gt."${at(3)}",and(updated_at.eq."${at(3)}",uuid.gt."p2"))',
    );
    expect(pages.every((u) => !u.queryParameters.containsKey('offset')), isTrue);
    expect(LanPullCursorsFunc().cursor('products'), at(9));
  });

  test('a row the server\'s own till changes while its page is out is not '
      'overwritten; it is pulled again next time (D5)', () async {
    await LanPullCursorsFunc().setCursor('products', at(1));
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 10);
    supabase.tables['products'] = [
      remoteProduct('p1', quantity: 10, updatedAt: at(2)),
      remoteProduct('p2', quantity: 5, updatedAt: at(3)),
    ];
    var sold = false;
    supabase.onGet = (table) async {
      if (table != 'products' || sold) return;
      sold = true;
      // A sale on the server's own till, outside the lock: the row first,
      // its queued change a moment later.
      await ProductsFunc().productBox.put('p1', product('p1')..quantity = 9);
    };
    expect(await puller.pullIncremental(['products']), isTrue);
    await QuantityUpdateFunc().createQuantityUpdate(
      QuantityUpdate(
        uuid: 's1',
        createdAt: DateTime.now(),
        quantity: 1,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );

    expect(ProductsFunc().productBox.get('p1')!.quantity, 9);
    expect(ProductsFunc().productBox.get('p2')!.quantity, 5);
    // The cursor stays at p1, so the next pull asks for it again.
    expect(LanPullCursorsFunc().cursor('products'), at(2));

    expect(await puller.pullIncremental(['products']), isTrue);
    // Supabase's 10 and the queued sale.
    expect(ProductsFunc().productBox.get('p1')!.quantity, 9);
    expect(LanPullCursorsFunc().cursor('products'), at(3));
  });

  test('a full pull removes rows Supabase no longer has and records them as '
      'deleted; a queued create and other stores\' rows stay', () async {
    supabase.tables['products'] = [remoteProduct('p1')];
    for (final id in ['p1', 'p-gone', 'p-new']) {
      await ProductsFunc().productBox.put(id, product(id));
    }
    await ProductsFunc().productBox.put('x1', product('x1', shopId: 8));
    await CreatedProductFunc().createdProductsBox.put(
      'p-new',
      CreatedProducts(product: product('p-new'), includeQuantity: true),
    );

    expect(await puller.fullPull('products'), isTrue);

    expect(
      ProductsFunc().productBox.keys.toSet(),
      {'p1', 'p-new', 'x1'},
    );
    expect(LanDeletedItemsFunc().contains('products', 'p-gone'), isTrue);
    expect(LanDeletedItemsFunc().contains('products', 'p-new'), isFalse);
  });

  test('a row the server\'s own sync sent after the list was taken is not '
      'removed', () async {
    supabase.tables['products'] = [remoteProduct('p1')];
    await ProductsFunc().productBox.put('p-late', product('p-late'));
    // Its create was sent while the pull ran: Supabase has it by the time
    // it is asked about it again.
    supabase.onGet = (table) async {
      if (supabase.requests.last.queryParameters['select'] == 'uuid') {
        supabase.tables['products']!.add(remoteProduct('p-late'));
      }
    };
    expect(await puller.fullPull('products'), isTrue);
    expect(ProductsFunc().productBox.containsKey('p-late'), isTrue);
    expect(LanDeletedItemsFunc().contains('products', 'p-late'), isFalse);
  });

  test('a pulled product keeps the default unit and price pinned on read, '
      'and the fields Supabase doesn\'t have', () async {
    final stored = product('p1')
      ..id = 41
      ..category = 'Grains';
    await ProductsFunc().productBox.put('p1', stored);
    supabase.tables['products'] = [
      remoteProduct('p1', quantity: 9, withUnits: false),
    ];

    expect(await puller.fullPull('products'), isTrue);

    final p = ProductsFunc().productBox.get('p1')!;
    expect(p.quantity, 9);
    expect(p.unitsList!.single.uuid, 'u-p1');
    expect(p.pricesList!.single.uuid, 'p-p1');
    expect(p.category, 'Grains');
  });

  test('offline (or while the server\'s own sync runs): nothing is asked',
      () async {
    online = false;
    supabase.tables['products'] = [remoteProduct('p1')];
    expect(await puller.backfill(), isFalse);
    expect(await puller.pullIncremental(), isFalse);
    expect(supabase.requests, isEmpty);
    expect(LanPullCursorsFunc().backfillAt(), isNull);
  });

  test('catch-up: a backfill when none ever completed; then each table by '
      'its cursor, or reconciled when its day is up', () async {
    var now = DateTime.utc(2026, 11, 25, 12);
    final started = now;
    puller = make(clock: () => now);
    expect(await puller.catchUp(), isTrue);
    expect(LanPullCursorsFunc().backfillAt(), now);
    final full = supabase.requests.length;

    supabase.requests.clear();
    now = now.add(const Duration(hours: 2));
    supabase.tables['products'] = [remoteProduct('p1', updatedAt: at(2))];
    expect(await puller.catchUp(), isTrue);
    // No new backfill: each table by its cursor (none had a row yet, so
    // each is asked for once, in full).
    expect(LanPullCursorsFunc().backfillAt(), started);
    expect(supabase.requests.length, full);
    expect(puller.reconcileDue('products'), isFalse);

    // A day on: reconciled, by key and updated_at only; still no backfill.
    supabase.requests.clear();
    now = now.add(const Duration(days: 1));
    expect(puller.reconcileDue('products'), isTrue);
    expect(await puller.catchUp(), isTrue);
    expect(LanPullCursorsFunc().backfillAt(), started);
    expect(
      supabase.requestsFor('products').first.queryParameters['select'],
      'uuid,updated_at',
    );
    expect(puller.reconcileDue('products'), isFalse);
  });

  test('the daily reconcile lists keys and updated_at only, fetches what is '
      'missing or changed, removes what Supabase no longer has; every row '
      'is fetched again weekly', () async {
    var now = DateTime.utc(2026, 11, 20, 12);
    puller = make(clock: () => now);
    supabase.tables['products'] = [
      for (final id in ['p1', 'p2', 'p3', 'p5'])
        remoteProduct(id, quantity: 10, updatedAt: at(1)),
    ];
    final history = {
      ...lanSamples().firstWhere((s) => s.table == 'item_history').json,
    };
    supabase.tables['item_history'] = [history];
    expect(await puller.fullPull('products'), isTrue);
    expect(await puller.fullPull('item_history'), isTrue);

    // Since then, on Supabase: p2 changed, p4 added, p3 deleted, and p1
    // changed without its updated_at moving. p5 has an update queued here.
    final remote = supabase.tables['products']!;
    remote[0]['quantity'] = 99.0;
    remote[1] = remoteProduct('p2', quantity: 4, updatedAt: at(5));
    remote.removeAt(2);
    remote[2] = remoteProduct('p5', quantity: 1, updatedAt: at(6));
    remote.add(remoteProduct('p4', quantity: 6, updatedAt: at(3)));
    await UpdatedProductsFunc().updatedProductsBox.put(
      'p5',
      UpdatedProducts(product: product('p5'), includeQuantity: true),
    );
    supabase.tables['item_history']!.add({...history, 'uuid': 'ih-2'});

    supabase.requests.clear();
    supabase.bytes = 0;
    now = now.add(const Duration(days: 1));
    expect(await puller.reconcile('products'), isTrue);
    expect(await puller.reconcile('item_history'), isTrue);

    final asked = [
      for (final u in supabase.requestsFor('products')) u.queryParameters,
    ];
    expect(asked, hasLength(3));
    // 1. The list: keys and updated_at only.
    expect(asked[0], {
      'shop_id': 'eq.7',
      'select': 'uuid,updated_at',
      'order': 'uuid.asc',
      'limit': '1000',
    });
    // 2. The rows missing here or changed (not p5: its update is queued).
    expect(asked[1], {'shop_id': 'eq.7', 'uuid': 'in.("p2","p4")'});
    // 3. p3 is asked about once more before it is removed.
    expect(asked[2], {
      'shop_id': 'eq.7',
      'select': 'uuid',
      'uuid': 'in.("p3")',
    });
    final box = ProductsFunc().productBox;
    expect(box.get('p2')!.quantity, 4);
    expect(box.get('p4')!.quantity, 6);
    expect(box.containsKey('p3'), isFalse);
    expect(LanDeletedItemsFunc().contains('products', 'p3'), isTrue);
    expect(box.get('p1')!.quantity, 10, reason: 'updated_at did not move');
    expect(box.get('p5')!.quantity, 10, reason: 'update queued');
    expect(LanPullCursorsFunc().cursor('products'), at(6));
    // Histories: by key only.
    final historyList = supabase.requestsFor('item_history').first;
    expect(historyList.queryParameters['select'], 'uuid');
    expect(ItemHistoriesFunc().itemHistoryBox.containsKey('ih-2'), isTrue);
    // A full row is far bigger than a key and a time.
    final daily = supabase.bytes;
    supabase.bytes = 0;
    supabase.requests.clear();

    // A week after the last full pull: every row again.
    now = now.add(const Duration(days: 6));
    await UpdatedProductsFunc().updatedProductsBox.clear();
    expect(await puller.reconcile('products'), isTrue);
    expect(
      supabase.requestsFor('products').first.queryParameters,
      {'shop_id': 'eq.7', 'order': 'uuid.asc', 'limit': '1000'},
    );
    expect(box.get('p1')!.quantity, 99);
    expect(box.get('p5')!.quantity, 1);
    expect(supabase.bytes, greaterThan(daily));
  });

  test('the store\'s settings and the permissions catalogue are pulled; a '
      'queued settings change is kept', () async {
    final shop = Map<String, dynamic>.of(shopSample)..['name'] = 'New name';
    supabase.tables['shops'] = [shop];
    supabase.tables['permissions'] = [permissionSample];
    final saved = <TempShopClass>[];
    puller = LanPuller(
      tables: lanTables(shopId: () => 7, onShopSaved: saved.add),
      reader: LanSupabaseReader(
        restUrl: () => supabase.restUrl,
        headers: () => const {},
        client: http.Client(),
      ),
      shopId: () => 7,
      exclusive: lock.runExclusive,
      canPull: () => true,
    );

    expect(await puller.fullPull('shops'), isTrue);
    expect(await puller.fullPull('permissions'), isTrue);
    expect(ShopFunc().shopBox.get(7)!.name, 'New name');
    expect(saved.single.name, 'New name');
    // The catalogue is not per store: no shop filter.
    expect(
      supabase.requestsFor('permissions').single.queryParameters,
      isNot(contains('shop_id')),
    );
    expect(PermissionFunc().permissionModelBox.get('perm-1')!.permitNumber, 2);

    // A reconcile by key and updated_at, a day on: the shop is the same.
    expect(await puller.reconcile('shops'), isTrue);
    expect(ShopFunc().shopBox.get(7)!.name, 'New name');

    await UpdatedShopFunc().updatedShopBox.add(
      UpdatedShop(shop: TempShopClass.fromJson(shopSample)),
    );
    shop['name'] = 'Newer name';
    expect(await puller.fullPull('shops'), isTrue);
    expect(ShopFunc().shopBox.get(7)!.name, 'New name');
  });

  test('every table the server serves is pulled, except users', () {
    final served = {for (final t in lanTables(shopId: () => 7)) t.name};
    expect(served.difference(lanPullPlans.keys.toSet()), {'users'});
    expect(lanPullPlans.keys.toSet().difference(served), isEmpty);
    expect(make().tableNames.toSet(), lanPullPlans.keys.toSet());
  });
}

class _NoApplied implements LanAppliedDeltas {
  @override
  Future<void> add(String key) async {}

  @override
  bool contains(String key) => false;
}
