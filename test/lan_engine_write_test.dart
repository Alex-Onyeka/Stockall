import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/created/created_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/deleted/deleted_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/updated/updated_invoices_func.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/created/created_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/deleted/deleted_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/updated/updated_orders_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_supabase_proxy.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';

final a = Authorizations();

/// Every permission the six tables' writes accept.
final List<String> everything = [
  a.addProduct,
  a.updateProduct,
  a.deleteProduct,
  a.makeSale,
  a.updateSale,
  a.deleteSale,
  a.updateInvoice,
  a.deleteInvoice,
  a.addOrders,
  a.updateOrders,
  a.deleteOrders,
  a.addCustomer,
  a.updateCustomer,
  a.deleteCustomer,
  a.addExpense,
  a.updateExpenses,
  a.deleteExpenses,
];

class ProxyStub implements LanProxy {
  final forwarded = <(PgRequest, Set<int>)>[];

  @override
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  ) async {
    forwarded.add((request, otherShops));
    return const PgResponse(201);
  }
}

PgFilter eq(String column, String value) =>
    PgFilter(column, PgFilterOp.eq, value);

MaterialClass material(String uuid, double quantity) {
  return MaterialClass(
    uuid: uuid,
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
    quantity: quantity,
  );
}

Future<void> clearBoxes() async {
  await ProductsFunc().productBox.clear();
  await CreatedProductFunc().createdProductsBox.clear();
  await UpdatedProductsFunc().updatedProductsBox.clear();
  await DeletedProductsFunc().deletedProductsBox.clear();
  await QuantityUpdateFunc().quantityUpdateBox.clear();
  await MainReceiptFunc().receiptBox.clear();
  await CreatedReceiptsFunc().createdReceiptsBox.clear();
  await UpdatedReceiptsFunc().updatedReceiptsBox.clear();
  await DeletedReceiptsFunc().deletedReceiptsBox.clear();
  await InvoicesFunc().invoicesBox.clear();
  await CreatedInvoicesFunc().createdInvoicesBox.clear();
  await UpdatedInvoicesFunc().updatedInvoicesBox.clear();
  await DeletedInvoicesFunc().deletedInvoicesBox.clear();
  await OrdersFunc().orderBox.clear();
  await CreatedOrdersFunc().createdOrdersBox.clear();
  await UpdatedOrdersFunc().updatedOrdersBox.clear();
  await DeletedOrdersFunc().deletedOrdersBox.clear();
  await CustomerFunc().customerBox.clear();
  await CreatedCustomersFunc().createdCustomersBox.clear();
  await UpdatedCustomersFunc().updatedCustomersBox.clear();
  await DeletedCustomersFunc().deletedCustomersBox.clear();
  await ExpensesFunc().expensesBox.clear();
  await CreatedExpensesFunc().createdExpensesBox.clear();
  await UpdatedExpensesFunc().updatedExpensesBox.clear();
  await DeletedExpensesFunc().deletedExpensesBox.clear();
  await CustomerAccountUpdateFunc().customerAccountUpdateBox.clear();
  await MaterialsFunc().materialBox.clear();
  await MaterialsQuantityUpdateFunc().clearMaterialsQuantitiesUpdate();
  await ProductionItemsFunc().productionItemsBox.clear();
  await LanAppliedDeltasFunc().clearAppliedDeltas();
  await LanDeletedItemsFunc().clearDeletedItems();
}

void main() {
  var manageDepartments = false;
  var online = false;
  var writes = 0;
  // What Supabase says about items the server doesn't hold: their store,
  // or no such row; anything else, no answer (offline).
  final remoteShops = <String, int>{};
  final remoteMissing = <String>{};
  late ProxyStub proxy;
  late HiveRestEngine engine;

  final owner = principal(access: everything);

  Matcher pg(int status, String code) => throwsA(
    isA<PgError>()
        .having((e) => e.status, 'status', status)
        .having((e) => e.code, 'code', code),
  );

  Future<PgResponse> write(
    String table,
    PgOp op, {
    Object? body,
    List<PgFilter> filters = const [],
    LanPrincipal? who,
    bool returning = false,
    List<String>? columns,
    String? onConflict,
  }) {
    return engine.handle(
      PgRequest(
        table: table,
        op: op,
        body: body,
        filters: filters,
        returnRepresentation: returning,
        columns: columns,
        onConflict: onConflict,
      ),
      who ?? owner,
    );
  }

  Map<String, dynamic> productJson(
    String uuid, {
    bool withQuantity = true,
    String? department,
    int shopId = 7,
  }) => product(
    uuid,
    department: department,
    shopId: shopId,
  ).toJson(isIncludeQuantity: withQuantity);

  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_write').path);
    registerAllHiveAdapters();
    await ProductsFunc().init();
    await MainReceiptFunc().init();
    await InvoicesFunc().init();
    await OrdersFunc().init();
    await CustomerFunc().init();
    await ExpensesFunc().init();
    await MaterialsFunc().init();
    await ProductionItemsFunc().init();
    await CustomerAccountUpdateFunc().init();
    await LanAppliedDeltasFunc().init();
    await LanDeletedItemsFunc().init();
  });

  tearDownAll(() async {
    await engine.dispose();
    await Hive.close();
  });

  setUp(() async {
    await clearBoxes();
    manageDepartments = false;
    online = false;
    writes = 0;
    remoteShops.clear();
    remoteMissing.clear();
    proxy = ProxyStub();
    engine = HiveRestEngine(
      tables: lanTables(shopId: () => 7),
      shopId: () => 7,
      manageDepartments: () => manageDepartments,
      isOnline: () => online,
      proxy: proxy,
      rpcs: LanDeltaRpcs(
        rpcs: lanDeltaRpcs(
          shopId: () => 7,
          remoteLookup: (table, uuid) async {
            if (remoteMissing.contains(uuid)) return LanRemoteRow.missing;
            final shop = remoteShops[uuid];
            return shop == null
                ? LanRemoteRow.unknown
                : LanRemoteRow(LanRemoteAnswer.found, shopId: shop);
          },
          wasDeleted: LanDeletedItemsFunc().contains,
          recordDeleted: LanDeletedItemsFunc().add,
        ),
        applied: const HiveAppliedDeltas(),
      ),
      onWrite: () => writes++,
      onDeleted: (table, key) async {
        if (lanDeltaTables.contains(table)) {
          await LanDeletedItemsFunc().add(table, key);
        }
      },
    );
  });

  group('products: the app\'s offline queue rules', () {
    test('insert: main box and one created entry; a duplicate is 23505 and '
        'changes nothing', () async {
      final r = await write('products', PgOp.insert, body: productJson('p1'));
      expect(r.status, 201);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 4);
      final created = CreatedProductFunc().getProducts();
      expect(created.single.product.uuid, 'p1');
      expect(created.single.includeQuantity, isTrue);
      expect(writes, 1);

      // A batch with one new row and one duplicate stores neither.
      await expectLater(
        write(
          'products',
          PgOp.insert,
          body: [productJson('p2'), productJson('p1')],
        ),
        pg(409, '23505'),
      );
      expect(ProductsFunc().productBox.containsKey('p2'), isFalse);
      expect(CreatedProductFunc().getProducts(), hasLength(1));
    });

    test('update of a product not yet synced refreshes its created entry',
        () async {
      await write('products', PgOp.insert, body: productJson('p1'));
      final patch = productJson('p1', withQuantity: false)..['name'] = 'Rice';

      await write(
        'products',
        PgOp.update,
        body: patch,
        filters: [eq('uuid', 'p1')],
      );

      final created = CreatedProductFunc().getProducts().single;
      expect(created.product.name, 'Rice');
      // The pending insert still sends the quantity it had.
      expect(created.includeQuantity, isTrue);
      expect(UpdatedProductsFunc().getProducts(), isEmpty);
    });

    test('update of a synced product: one updated entry, quantity and '
        'local-only fields kept', () async {
      final stored = product('p1')
        ..id = 41
        ..category = 'Grains'
        ..createdAt = t0;
      await ProductsFunc().productBox.put('p1', stored);

      final r = await write(
        'products',
        PgOp.update,
        body: productJson('p1', withQuantity: false)..['name'] = 'Rice',
        filters: [eq('uuid', 'p1')],
        returning: true,
      );

      final row = ProductsFunc().productBox.get('p1')!;
      expect(row.name, 'Rice');
      expect(row.quantity, 4);
      expect(row.id, 41);
      expect(row.category, 'Grains');
      expect(row.createdAt, t0);
      final updated = UpdatedProductsFunc().getProducts().single;
      expect(updated.product.uuid, 'p1');
      expect(updated.includeQuantity, isFalse);
      expect(CreatedProductFunc().getProducts(), isEmpty);
      expect((r.body as List).single['name'], 'Rice');
    });

    test('delete: a synced product is queued for deletion; one not yet '
        'synced just leaves the created queue', () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      await write('products', PgOp.insert, body: productJson('p2'));

      final r = await write(
        'products',
        PgOp.delete,
        filters: [
          PgFilter('uuid', PgFilterOp.inList, ['p1', 'p2']),
        ],
        returning: true,
        columns: ['uuid'],
      );

      expect(r.body, [
        {'uuid': 'p1'},
        {'uuid': 'p2'},
      ]);
      expect(ProductsFunc().productBox.isEmpty, isTrue);
      expect(
        DeletedProductsFunc().getProductIds().map((d) => d.productUuid),
        ['p1'],
      );
      expect(CreatedProductFunc().getProducts(), isEmpty);
    });

    test('a write is visible to the next date-window read at once', () async {
      await write('products', PgOp.insert, body: productJson('p1'));
      final r = await engine.handle(
        PgRequest(
          table: 'products',
          op: PgOp.select,
          filters: [
            PgFilter('updated_at', PgFilterOp.gte, t0.toIso8601String()),
          ],
        ),
        owner,
      );
      expect((r.body as List).map((p) => p['uuid']), ['p1']);
    });
  });

  group('the other five tables', () {
    test('receipts: insert, upsert on uuid, partial update, delete',
        () async {
      await write('receipts', PgOp.insert, body: receipt('r0', t0).toJson());
      expect(CreatedReceiptsFunc().getReceipts().single.receipt.uuid, 'r0');

      // A synced receipt (with its Supabase id), upserted and patched.
      final json = receipt('r1', t0).toJson();
      await MainReceiptFunc().receiptBox.put('r1', receipt('r1', t0));
      await write(
        'receipts',
        PgOp.upsert,
        body: {...json, 'comment': 'paid'},
        onConflict: 'uuid',
      );
      await write(
        'receipts',
        PgOp.update,
        body: {'is_invoice': true},
        filters: [eq('uuid', 'r1')],
      );
      final row = MainReceiptFunc().receiptBox.get('r1')!;
      expect(row.comment, 'paid');
      expect(row.isInvoice, isTrue);
      expect(row.id, 'r1'.hashCode, reason: 'local-only id kept');
      expect(
        UpdatedReceiptsFunc().getReceiptIds().map((u) => u.receiptUuid),
        everyElement('r1'),
      );

      await write('receipts', PgOp.delete, filters: [eq('uuid', 'r1')]);
      expect(MainReceiptFunc().receiptBox.keys, ['r0']);
      expect(DeletedReceiptsFunc().getReceiptIds().single.receiptUuid, 'r1');
    });

    test('invoices are keyed by invoice_uuid', () async {
      await write('invoices', PgOp.insert, body: invoice('i1', t0).toJson());
      await CreatedInvoicesFunc().clearInvoices();
      await write(
        'invoices',
        PgOp.update,
        body: {'comment': 'later'},
        filters: [eq('invoice_uuid', 'i1')],
      );
      expect(InvoicesFunc().invoicesBox.get('i1')!.comment, 'later');
      expect(
        UpdatedInvoicesFunc().getInvoiceIds().single.updatedInvoice.uuid,
        'i1',
      );
      // What deleteInvoicesSync sends.
      await write(
        'invoices',
        PgOp.delete,
        filters: [eq('invoice_uuid', 'i1'), eq('shop_id', '7')],
      );
      expect(InvoicesFunc().invoicesBox.isEmpty, isTrue);
      expect(DeletedInvoicesFunc().getInvoiceIds().single.invoiceUuid, 'i1');
      expect(UpdatedInvoicesFunc().getInvoiceIds(), isEmpty);
    });

    test('orders: insert, update, delete', () async {
      await write('orders', PgOp.insert, body: order('o1').toJson());
      expect(CreatedOrdersFunc().getOrders().single.order.uuid, 'o1');
      await CreatedOrdersFunc().clearOrders();
      await write(
        'orders',
        PgOp.update,
        body: {'comment': 'ready'},
        filters: [eq('uuid', 'o1')],
      );
      expect(UpdatedOrdersFunc().getOrderIds().single.order.comment, 'ready');
      await write('orders', PgOp.delete, filters: [eq('uuid', 'o1')]);
      expect(DeletedOrdersFunc().getOrderIds().single.orderUuid, 'o1');
    });

    test('customers: a profile update keeps the balance', () async {
      await write(
        'customers',
        PgOp.insert,
        body: [
          customer('c1').toJson(isMoneyUpdate: true),
          customer('c2').toJson(isMoneyUpdate: true),
        ],
        returning: true,
        columns: ['uuid'],
      );
      expect(CreatedCustomersFunc().getCustomers(), hasLength(2));
      await CreatedCustomersFunc().clearCustomers();

      await write(
        'customers',
        PgOp.update,
        body: customer('c1').toJson(isMoneyUpdate: false)..['name'] = 'Ada',
        filters: [eq('uuid', 'c1')],
      );
      final row = CustomerFunc().customerBox.get('c1')!;
      expect(row.name, 'Ada');
      expect(row.balance, 12.5);
      expect(UpdatedCustomersFunc().getCustomers().single.customer.uuid, 'c1');

      await write('customers', PgOp.delete, filters: [eq('uuid', 'c2')]);
      expect(DeletedCustomersFunc().getCustomerIds().single.customerUuid, 'c2');
    });

    test('expenses: purchase_uuid is unique; the update by purchase_uuid '
        'the app sends after a 23505 works', () async {
      // e1 is synced (it has its Supabase id).
      await ExpensesFunc().expensesBox.put('e1', expense('e1'));
      await expectLater(
        write('expenses', PgOp.insert, body: expense('e2').toJson()),
        pg(409, '23505'),
      );
      // Two expenses with no purchase never collide.
      await write(
        'expenses',
        PgOp.insert,
        body: [
          expense('e3', purchaseUuid: null).toJson(),
          expense('e4', purchaseUuid: null).toJson(),
        ],
      );
      await CreatedExpensesFunc().clearExpenses();

      await write(
        'expenses',
        PgOp.update,
        body: expense('e2').toJson()
          ..remove('uuid')
          ..['amount'] = 75,
        filters: [eq('purchase_uuid', 'pur-1')],
      );
      expect(ExpensesFunc().expensesBox.get('e1')!.amount, 75);
      expect(ExpensesFunc().expensesBox.get('e1')!.id, 3);
      expect(UpdatedExpensesFunc().getExpenses().single.expenses.uuid, 'e1');

      await write('expenses', PgOp.delete, filters: [eq('uuid', 'e3')]);
      expect(DeletedExpensesFunc().getExpenseIds().single.expensesUuid, 'e3');
    });
  });

  group('permissions and departments', () {
    test('a write without any of its permissions is 403 LAN02 and changes '
        'nothing', () async {
      final cashier = principal(access: [a.makeSale]);
      await expectLater(
        write('customers', PgOp.delete, filters: [eq('uuid', 'c1')], who: cashier),
        pg(403, 'LAN02'),
      );
      // A sale may create a custom item.
      await write('products', PgOp.insert, body: productJson('p1'), who: cashier);
      await expectLater(
        write('products', PgOp.delete, filters: [eq('uuid', 'p1')], who: cashier),
        pg(403, 'LAN02'),
      );
      expect(ProductsFunc().productBox.containsKey('p1'), isTrue);
    });

    test('a row in a department the user cannot see is 403 LAN04', () async {
      manageDepartments = true;
      await ProductsFunc().productBox.put('p1', product('p1', department: 'd2'));
      final inD1 = principal(access: everything, departments: ['d1']);
      await expectLater(
        write(
          'products',
          PgOp.update,
          body: {'name': 'X'},
          filters: [eq('uuid', 'p1')],
          who: inD1,
        ),
        pg(403, 'LAN04'),
      );
      expect(ProductsFunc().productBox.get('p1')!.name, 'Item');
      expect(UpdatedProductsFunc().getProducts(), isEmpty);
    });
  });

  group('writes to another store', () {
    test('offline: refused with a clear message; nothing stored', () async {
      await expectLater(
        write('products', PgOp.insert, body: productJson('t1', shopId: 8)),
        throwsA(
          isA<PgError>()
              .having((e) => e.status, 'status', 503)
              .having((e) => e.code, 'code', 'LAN01')
              .having((e) => e.message, 'message', contains('another store')),
        ),
      );
      expect(ProductsFunc().productBox.isEmpty, isTrue);
      expect(proxy.forwarded, isEmpty);
    });

    test('online: forwarded to Supabase, whatever the table (the branch '
        'transfer\'s item_history)', () async {
      online = true;
      // updateProductForOtherShops filters by uuid only; the body names
      // the other store.
      await write(
        'products',
        PgOp.update,
        body: productJson('t1', shopId: 8),
        filters: [eq('uuid', 't1')],
      );
      await write(
        'item_history',
        PgOp.insert,
        body: {'uuid': 'h1', 'shop_id': 8},
      );
      expect(proxy.forwarded.map((f) => f.$1.table), [
        'products',
        'item_history',
      ]);
      expect(proxy.forwarded.map((f) => f.$2), everyElement({8}));
      expect(ProductsFunc().productBox.isEmpty, isTrue);

      // For this store, a table the server does not serve is unknown.
      await expectLater(
        write('product_sales', PgOp.insert, body: {'uuid': 'h2', 'shop_id': 7}),
        pg(404, 'PGRST205'),
      );
    });

    test('still needs the permission, and cannot mix stores', () async {
      online = true;
      await expectLater(
        write(
          'products',
          PgOp.insert,
          body: productJson('t1', shopId: 8),
          who: principal(),
        ),
        pg(403, 'LAN02'),
      );
      await expectLater(
        write(
          'products',
          PgOp.insert,
          body: [productJson('t1', shopId: 8), productJson('p1')],
        ),
        pg(400, 'LAN05'),
      );
      expect(proxy.forwarded, isEmpty);
    });
  });

  group('delta RPCs (D15)', () {
    PgRequest rpc(String name, List<Map<String, dynamic>> updates) =>
        PgRequest(table: name, op: PgOp.rpc, body: {'updates': updates});

    test('a product delta sent twice changes stock once and is queued once',
        () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      final batch = rpc('update_product_quantities', [
        {
          'hiveUuid': 'q1',
          'itemUuid': 'p1',
          'quantity': 3,
          'isIncrement': false,
          'isStorage': false,
        },
      ]);

      // A sale's stock change (S3: under the sale permissions).
      final cashier = principal(access: [a.makeSale]);
      final first = await engine.handle(batch, cashier);
      final again = await engine.handle(batch, cashier);

      expect(ProductsFunc().productBox.get('p1')!.quantity, 1);
      final queued = QuantityUpdateFunc().getQuantitiesUpdate();
      expect(queued.single.uuid, 'q1');
      expect(queued.single.quantity, 3);
      expect(queued.single.isIncrement, isFalse);
      // The client deletes each returned hiveUuid from its queue.
      for (final r in [first, again]) {
        expect(r.status, 200);
        expect((r.body as List).map((e) => e['hiveUuid']), ['q1']);
      }
    });

    test('an item the server does not hold yet: the batch is refused with a '
        'retryable error, nothing applied; the retry applies it once',
        () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      final batch = rpc('update_product_quantities', [
        // No hiveUuid: applying it before the refusal would double it.
        {'itemUuid': 'p1', 'quantity': 1, 'isIncrement': true},
        {
          'hiveUuid': 'q2',
          'itemUuid': 'p-new',
          'quantity': 2,
          'isIncrement': false,
          'isStorage': false,
        },
      ]);

      await expectLater(
        engine.handle(batch, owner),
        throwsA(
          isA<PgError>()
              .having((e) => e.status, 'status', 503)
              .having((e) => e.code, 'code', 'LAN06')
              .having((e) => e.details, 'details', contains('p-new')),
        ),
      );
      expect(ProductsFunc().productBox.get('p1')!.quantity, 4);
      expect(QuantityUpdateFunc().getQuantitiesUpdate(), isEmpty);

      // The server pulls the item; the client's retry goes through.
      await ProductsFunc().productBox.put('p-new', product('p-new'));
      await engine.handle(batch, owner);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 5);
      expect(ProductsFunc().productBox.get('p-new')!.quantity, 2);
      expect(QuantityUpdateFunc().getQuantitiesUpdate(), hasLength(2));
    });

    test('an item of another store is skipped, whether the server holds it '
        'or Supabase says so', () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      await ProductsFunc().productBox.put('x1', product('x1', shopId: 8));
      remoteShops['x2'] = 8;
      Map<String, dynamic> entry(String id, String item) => {
        'hiveUuid': id,
        'itemUuid': item,
        'quantity': 1,
        'isIncrement': false,
        'isStorage': false,
      };

      final r = await engine.handle(
        rpc('update_product_quantities', [
          entry('q1', 'p1'),
          entry('q2', 'x1'),
          entry('q3', 'x2'),
        ]),
        owner,
      );

      expect(r.status, 200);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(ProductsFunc().productBox.get('x1')!.quantity, 4);
      expect(
        QuantityUpdateFunc().getQuantitiesUpdate().map((q) => q.uuid),
        ['q1'],
      );

      // Supabase saying "this store" does not make a missing item local.
      remoteShops['x3'] = 7;
      await expectLater(
        engine.handle(
          rpc('update_product_quantities', [entry('q4', 'x3')]),
          owner,
        ),
        pg(503, 'LAN06'),
      );
    });

    test('an item deleted here in the last 30 days: its delta is dropped, '
        'not refused, and the rest of the batch applies', () async {
      Map<String, dynamic> entry(String id, String item) => {
        'hiveUuid': id,
        'itemUuid': item,
        'quantity': 1,
        'isIncrement': false,
        'isStorage': false,
      };
      await ProductsFunc().productBox.put('p1', product('p1'));
      await ProductsFunc().productBox.put('p2', product('p2'));
      await ProductsFunc().productBox.put('p3', product('p3'));
      // Deleted by a LAN client, and on the server's own screens.
      await write('products', PgOp.delete, filters: [eq('uuid', 'p2')]);
      await ProductsFunc().deleteProduct('p3');

      final r = await engine.handle(
        rpc('update_product_quantities', [
          entry('q1', 'p1'),
          entry('q2', 'p2'),
          entry('q3', 'p3'),
        ]),
        owner,
      );

      expect(r.status, 200);
      // Every entry comes back, so the client drops the dead ones too.
      expect((r.body as List).map((e) => e['hiveUuid']), ['q1', 'q2', 'q3']);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(ProductsFunc().productBox.containsKey('p2'), isFalse);
      expect(
        QuantityUpdateFunc().getQuantitiesUpdate().map((q) => q.uuid),
        ['q1'],
      );

      // Same for a customer's account.
      await CustomerFunc().customerBox.put('c1', customer('c1'));
      await write('customers', PgOp.delete, filters: [eq('uuid', 'c1')]);
      final account = await engine.handle(
        rpc('update_customer_account', [
          {
            'hiveUuid': 'a1',
            'customerUuid': 'c1',
            'amount': 5,
            'isIncrement': true,
            'isBalance': true,
          },
        ]),
        owner,
      );
      expect(account.status, 204);
      expect(CustomerAccountUpdateFunc().getQuantitiesUpdate(), isEmpty);

      // A deletion older than 30 days is forgotten: unknown again.
      await LanDeletedItemsFunc().add(
        'products',
        'p4',
        now: DateTime.now().subtract(const Duration(days: 31)),
      );
      await expectLater(
        engine.handle(
          rpc('update_product_quantities', [entry('q4', 'p4')]),
          owner,
        ),
        pg(503, 'LAN06'),
      );
      // A deleted item of another table doesn't count for products.
      await LanDeletedItemsFunc().add('customers', 'p5');
      await expectLater(
        engine.handle(
          rpc('update_product_quantities', [entry('q5', 'p5')]),
          owner,
        ),
        pg(503, 'LAN06'),
      );
    });

    test('an item Supabase has no row for (asked when the server is online) '
        'is dropped and recorded as deleted; no answer still retries',
        () async {
      Map<String, dynamic> entry(String id, String item) => {
        'hiveUuid': id,
        'itemUuid': item,
        'quantity': 1,
        'isIncrement': false,
        'isStorage': false,
      };
      await ProductsFunc().productBox.put('p1', product('p1'));
      remoteMissing.add('gone');

      final r = await engine.handle(
        rpc('update_product_quantities', [
          entry('q1', 'p1'),
          entry('q2', 'gone'),
        ]),
        owner,
      );

      expect(r.status, 200);
      expect((r.body as List).map((e) => e['hiveUuid']), ['q1', 'q2']);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(
        QuantityUpdateFunc().getQuantitiesUpdate().map((q) => q.uuid),
        ['q1'],
      );
      // Recorded: the next delta for it is dropped without asking again.
      expect(LanDeletedItemsFunc().contains('products', 'gone'), isTrue);
      remoteMissing.clear();
      final again = await engine.handle(
        rpc('update_product_quantities', [entry('q3', 'gone')]),
        owner,
      );
      expect(again.status, 200);
      expect(QuantityUpdateFunc().getQuantitiesUpdate(), hasLength(1));

      // Supabase can't be asked (offline, an error): still retryable.
      await expectLater(
        engine.handle(
          rpc('update_product_quantities', [entry('q4', 'unknown')]),
          owner,
        ),
        pg(503, 'LAN06'),
      );
      expect(LanDeletedItemsFunc().contains('products', 'unknown'), isFalse);
    });

    test('the Supabase lookup: no rows is "missing"; a row gives its store; '
        'an error or an odd reply is "unknown"', () async {
      final supabase = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => supabase.close(force: true));
      final queries = <String>[];
      supabase.listen((request) async {
        queries.add('${request.uri.path}?${request.uri.query}');
        final uuid = request.uri.queryParameters['uuid'];
        final (status, body) = switch (uuid) {
          'eq.gone' => (200, '[]'),
          'eq.x1' => (200, '[{"shop_id":8}]'),
          'eq.two' => (200, '[{"shop_id":7},{"shop_id":8}]'),
          'eq.odd' => (200, '{"shop_id":7}'),
          _ => (500, '{"message":"boom"}'),
        };
        request.response
          ..statusCode = status
          ..headers.contentType = ContentType.json
          ..write(body);
        await request.response.close();
      });
      final lookups = LanSupabaseProxy(
        restUrl: () => 'http://127.0.0.1:${supabase.port}/rest/v1',
        headers: () => const {'apikey': 'anon'},
        client: http.Client(),
      );

      expect((await lookups.lookup('products', 'gone')).answer,
          LanRemoteAnswer.missing);
      final found = await lookups.lookup('products', 'x1');
      expect(found.answer, LanRemoteAnswer.found);
      expect(found.shopId, 8);
      for (final uuid in ['two', 'odd', 'error']) {
        expect((await lookups.lookup('products', uuid)).answer,
            LanRemoteAnswer.unknown, reason: uuid);
      }
      expect(queries.first, '/rest/v1/products?select=shop_id&uuid=eq.gone');
    });

    test('materials: a merged entry with a new amount is a new change',
        () async {
      await MaterialsFunc().materialBox.put('m1', material('m1', 10));
      final storekeeper = principal(access: [a.updateMaterialQuantity]);
      Map<String, dynamic> entry(double q) => {
        'hiveUuid': 'mq1',
        'materialItemUuid': 'm1',
        'quantity': q,
        'isIncrement': true,
      };

      await engine.handle(rpc('update_materials_quantities', [entry(2)]), storekeeper);
      await engine.handle(rpc('update_materials_quantities', [entry(2)]), storekeeper);
      expect(MaterialsFunc().materialBox.get('m1')!.quantity, 12);

      // The client merged another +3 into the same entry before retrying.
      final r = await engine.handle(
        rpc('update_materials_quantities', [entry(5)]),
        storekeeper,
      );
      expect(r.status, 204);
      expect(MaterialsFunc().materialBox.get('m1')!.quantity, 17);
      // The server queues each change as its own entry (never merged, so
      // finishing one after a crash can't add it twice): +2 and +5.
      final queued = MaterialsQuantityUpdateFunc().getMaterialsQuantitiesUpdate();
      expect(queued.map((q) => q.quantity).toList()..sort(), [2, 5]);
      expect(queued.every((q) => q.isIncrement), isTrue);
    });

    test('customer account: balance or cash reward; entries without '
        'hiveUuid (older clients) apply every time', () async {
      await CustomerFunc().customerBox.put('c1', customer('c1'));
      final balance = {
        'customerUuid': 'c1',
        'amount': 2.5,
        'isIncrement': false,
        'isBalance': true,
      };
      final reward = {
        'customerUuid': 'c1',
        'amount': 4,
        'isIncrement': true,
        'isBalance': false,
      };

      await engine.handle(
        rpc('update_customer_account', [
          {...balance, 'hiveUuid': 'a1'},
          reward,
        ]),
        owner,
      );
      await engine.handle(
        rpc('update_customer_account', [
          {...balance, 'hiveUuid': 'a1'},
          reward,
        ]),
        owner,
      );

      final c = CustomerFunc().customerBox.get('c1')!;
      expect(c.balance, 10);
      expect(c.cashReward, 8);
      expect(CustomerAccountUpdateFunc().getQuantitiesUpdate(), hasLength(3));
    });

    test('batches from two clients at once never interleave', () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      await Future.wait([
        for (var i = 0; i < 20; i++)
          engine.handle(
            rpc('update_product_quantities', [
              {
                'hiveUuid': 'c$i',
                'itemUuid': 'p1',
                'quantity': 1,
                'isIncrement': true,
                'isStorage': false,
              },
            ]),
            owner,
          ),
      ]);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 24);
      expect(QuantityUpdateFunc().getQuantitiesUpdate(), hasLength(20));
    });

    test('a malformed batch changes nothing; an unknown RPC is PGRST202',
        () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      await expectLater(
        engine.handle(
          rpc('update_product_quantities', [
            {'hiveUuid': 'q1', 'itemUuid': 'p1', 'quantity': 1},
            {'hiveUuid': 'q2', 'itemUuid': 'p1', 'quantity': 'two'},
          ]),
          owner,
        ),
        pg(400, '22P02'),
      );
      expect(ProductsFunc().productBox.get('p1')!.quantity, 4);
      await expectLater(
        engine.handle(rpc('mark_all_notifications_viewed', []), owner),
        pg(404, 'PGRST202'),
      );
    });
  });

  group('end to end through a real SupabaseClient', () {
    late LanServer server;
    late LanConnection connection;
    late SupabaseClient lan;

    setUpAll(() async {
      await LanCredentialsFunc().init();
      await LanServerSessionsFunc().init();
      await LanShopKeysFunc().init();
      await LanUserBackfill().apply(
        7,
        const LanBackfillShop(ownerId: 'owner', employees: ['staff-1']),
        [
          TempUserClass(
            userId: 'staff-1',
            name: 'Ada',
            email: 'ada@shop.test',
            password: 'right',
            role: 'Cashier',
            departmentUuids: const [],
            access: [a.makeSale, a.addProduct, a.updateProduct],
          ),
        ],
        iterations: 1000,
      );
    });

    setUp(() async {
      final identity = LanTlsIdentity.generate();
      server = LanServer(
        identity: identity,
        deviceId: 'desk-1',
        serverView: () => {'epoch': 1},
        auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
        rest: engine,
      );
      await server.start(ports: const [0]);
      connection = (await LanConnection.open([
        LanEndpoint('127.0.0.1', server.port!),
      ], pin: identity.fingerprint))!;
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

    tearDown(() async {
      await lan.dispose();
      connection.close();
      await server.stop();
    });

    test('the products sync calls, a duplicate, a refused delete, and the '
        'quantity RPC', () async {
      // createProductsSync
      await lan
          .from('products')
          .insert(product('p1').toJson(isIncludeQuantity: true));
      // ... and its 23505 branch.
      await expectLater(
        lan.from('products').insert(product('p1').toJson(isIncludeQuantity: true)),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', '23505'),
        ),
      );

      // updateProductsSync: check, then update.
      final remote = await lan
          .from('products')
          .select('uuid, updated_at')
          .eq('uuid', 'p1')
          .maybeSingle();
      expect(remote!['uuid'], 'p1');
      final updated = await lan
          .from('products')
          .update(
            (product('p1')..name = 'Rice').toJson(isIncludeQuantity: false),
          )
          .eq('uuid', 'p1')
          .select()
          .maybeSingle();
      expect(TempProductClass.fromJson(updated!).name, 'Rice');
      final none = await lan
          .from('products')
          .update({'name': 'Nobody'})
          .eq('uuid', 'nope')
          .select()
          .maybeSingle();
      expect(none, isNull);

      // No "Delete Items": refused with the LAN code.
      await expectLater(
        lan.from('products').delete().inFilter('uuid', ['p1']).select('uuid'),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', 'LAN02'),
        ),
      );

      // quantityUpdateSync
      final res = await lan.rpc(
        'update_product_quantities',
        params: {
          'updates': [
            {
              'hiveUuid': 'q1',
              'itemUuid': 'p1',
              'quantity': 1.5,
              'isIncrement': false,
              'isStorage': false,
            },
          ],
        },
      );
      expect(res, [
        {'hiveUuid': 'q1', 'itemUuid': 'p1'},
      ]);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 2.5);

      // A void RPC answers nothing.
      final none2 = await lan.rpc(
        'update_customer_account',
        params: {'updates': <Object>[]},
      );
      expect(none2, isNull);
    });
  });
}
