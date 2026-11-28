import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_logo_storage.dart';
import 'package:stockall/services/lan/rest/lan_more_tables.dart';
import 'package:stockall/services/lan/rest/lan_store_tables.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/rest/lan_table_writes.dart';

/// Every table the LAN server answers itself: the six busy tables,
/// the other 20 ([moreLanTables]), and this store's shop,
/// users and the permissions catalogue. Column names are the models'
/// `toJson` keys, so a filter means on the LAN what it means on Supabase;
/// `lan_registry_parity_test` checks every accessor against `toJson`.
///
/// [shopId] is the served store; [logos] handles the shop's logo; [staff]
/// is the server's signed-in user (for products' default unit and price);
/// [onShopSaved] lets the server's own screens pick up a shop changed over
/// the LAN.
List<LanTable<dynamic>> lanTables({
  required int Function() shopId,
  LanLogoStorage? logos,
  LanStaff Function()? staff,
  void Function(TempShopClass shop)? onShopSaved,
}) => [
  productsTable(
    () => ProductsFunc().productBox.values,
    changes: () => ProductsFunc().productBox.watch(),
    writes: productWrites(),
    ensureDefaults: productDefaultsPinner(
      persist: (p) => ProductsFunc().productBox.put(p.uuid, p),
      staff: staff ?? () => (id: null, name: null),
    ),
  ),
  receiptsTable(
    () => MainReceiptFunc().receiptBox.values,
    changes: () => MainReceiptFunc().receiptBox.watch(),
    writes: receiptWrites(),
  ),
  invoicesTable(
    () => InvoicesFunc().invoicesBox.values,
    changes: () => InvoicesFunc().invoicesBox.watch(),
    writes: invoiceWrites(),
  ),
  ordersTable(
    () => OrdersFunc().orderBox.values,
    changes: () => OrdersFunc().orderBox.watch(),
    writes: orderWrites(),
  ),
  customersTable(
    () => CustomerFunc().customerBox.values,
    changes: () => CustomerFunc().customerBox.watch(),
    writes: customerWrites(),
  ),
  expensesTable(
    () => ExpensesFunc().expensesBox.values,
    changes: () => ExpensesFunc().expensesBox.watch(),
    writes: expenseWrites(),
  ),
  ...moreLanTables(staff: staff),
  shopsTable(
    () => ShopFunc().shopBox.values,
    changes: () => ShopFunc().shopBox.watch(),
    writes: shopWrites(
      find: (id) => ShopFunc().shopBox.get(id),
      // The app's offline settings path: the shop box, then the queue.
      save: (shop) async {
        await ShopFunc().shopBox.put(shop.shopId, shop);
        await UpdatedShopFunc().createUpdatedShop(UpdatedShop(shop: shop));
        onShopSaved?.call(shop);
      },
      prepareUpdate: logos?.preparePatch,
      // Pulled settings: the shop box and the server's own screens;
      // never while a settings change is still queued, and never removed.
      pull: LanPullStore(
        put: (shop) async {
          await ShopFunc().shopBox.put(shop.shopId, shop);
          onShopSaved?.call(shop);
        },
        remove: (_) async {},
        pending: () => {
          for (final u in UpdatedShopFunc().getUpdatedShop())
            if (u.shop.shopId case final id?) '$id',
        },
      ),
    ),
  ),
  usersTable(() => LanCredentialsFunc().forShop(shopId())),
  permissionsTable(
    () => PermissionFunc().permissionModelBox.values,
    pull: LanPullStore(
      fromJson: PermissionModel.fromJson,
      put: (p) => PermissionFunc().permissionModelBox.put(p.id, p),
      remove: (id) => PermissionFunc().permissionModelBox.delete(id),
      pending: () => const {},
    ),
  ),
];

/// Every one of the app's sync queues that the LAN server's writes, delta
/// RPCs and logo uploads add to: box name, and whether it is empty. When
/// all are empty, everything the server acknowledged has reached Supabase.
Map<String, bool Function()> lanQueues() => _lanQueues ??= {
  for (final t in lanTables(shopId: () => 0)) ...?t.writes?.queues,
  for (final r in lanDeltaRpcs(shopId: () => 0)) r.queueBox: r.queueEmpty,
  // `LanLogoStorage.queueLogo`: the app's logo upload queue.
  'createdShopLogosBoxStockall': () =>
      CreatedShopLogosFunc().createdShopLogosBox.isEmpty,
};

Map<String, bool Function()>? _lanQueues;

const _text = LanColumnType.text;
const _number = LanColumnType.number;
const _bool = LanColumnType.boolean;
const _time = LanColumnType.timestamp;
const _texts = LanColumnType.textArray;

LanTable<TempProductClass> productsTable(
  Iterable<TempProductClass> Function() rows, {
  Stream<Object?> Function()? changes,
  LanWrites<TempProductClass>? writes,
  void Function(TempProductClass product)? ensureDefaults,
}) {
  return LanTable<TempProductClass>(
    name: 'products',
    rows: rows,
    changes: changes,
    writes: writes,
    toJson: (p) {
      ensureDefaults?.call(p);
      return p.toJson(isIncludeQuantity: true);
    },
    shopIdOf: (p) => p.shopId,
    departmentOf: (p) => p.departmentUuid,
    departmentsOf: (p) => p.departmentUuids,
    // The app shows shared products to every department.
    includeUnassigned: true,
    dateIndexes: const {'updated_at'},
    columns: {
      'shop_id': LanColumn(_number, (p) => p.shopId),
      'uuid': LanColumn(_text, (p) => p.uuid),
      'name': LanColumn(_text, (p) => p.name),
      'barcode': LanColumn(_text, (p) => p.barcode),
      'updated_at': LanColumn(_time, (p) => p.updatedAt),
      'department_uuid': LanColumn(_text, (p) => p.departmentUuid),
      // toJson sends [] for none.
      'department_uuids': LanColumn(_texts, (p) => p.departmentUuids ?? const []),
      'category_uuid': LanColumn(_text, (p) => p.categoryUuid),
      'quantity': LanColumn(_number, (p) => p.quantity),
    },
  );
}

LanTable<TempMainReceipt> receiptsTable(
  Iterable<TempMainReceipt> Function() rows, {
  Stream<Object?> Function()? changes,
  LanWrites<TempMainReceipt>? writes,
}) {
  return LanTable<TempMainReceipt>(
    name: 'receipts',
    rows: rows,
    changes: changes,
    writes: writes,
    toJson: (r) => r.toJson(),
    shopIdOf: (r) => r.shopId,
    // `department_uuid` on receipts is a legacy int; the uuid is `_new`.
    departmentOf: (r) => r.departmentUuidNew,
    dateIndexes: const {'created_at'},
    columns: {
      'shop_id': LanColumn(_number, (r) => r.shopId),
      'uuid': LanColumn(_text, (r) => r.uuid),
      'created_at': LanColumn(_time, (r) => r.createdAt),
      'department_uuid_new': LanColumn(_text, (r) => r.departmentUuidNew),
      'invoice_uuid': LanColumn(_text, (r) => r.invoiceUuid),
      'order_uuid': LanColumn(_text, (r) => r.orderUuid),
      'customer_uuid': LanColumn(_text, (r) => r.customerUuid),
      'staff_id': LanColumn(_text, (r) => r.staffId),
      'is_invoice': LanColumn(_bool, (r) => r.isInvoice),
      'balance': LanColumn(_number, (r) => r.balance),
      'barcode': LanColumn(_text, (r) => r.barcode),
    },
  );
}

LanTable<TempInvoice> invoicesTable(
  Iterable<TempInvoice> Function() rows, {
  Stream<Object?> Function()? changes,
  LanWrites<TempInvoice>? writes,
}) {
  return LanTable<TempInvoice>(
    name: 'invoices',
    rows: rows,
    changes: changes,
    writes: writes,
    toJson: (i) => i.toJson(),
    shopIdOf: (i) => i.shopId,
    departmentOf: (i) => i.departmentUuidNew,
    dateIndexes: const {'created_at'},
    columns: {
      'shop_id': LanColumn(_number, (i) => i.shopId),
      // The model calls it `uuid`; the column is `invoice_uuid`.
      'invoice_uuid': LanColumn(_text, (i) => i.uuid),
      'created_at': LanColumn(_time, (i) => i.createdAt),
      'updated_at': LanColumn(_time, (i) => i.updatedAt),
      'department_uuid_new': LanColumn(_text, (i) => i.departmentUuidNew),
      'customer_uuid': LanColumn(_text, (i) => i.customerUuid),
      'staff_id': LanColumn(_text, (i) => i.staffId),
      'barcode': LanColumn(_text, (i) => i.barcode),
    },
  );
}

LanTable<Orders> ordersTable(
  Iterable<Orders> Function() rows, {
  Stream<Object?> Function()? changes,
  LanWrites<Orders>? writes,
}) {
  return LanTable<Orders>(
    name: 'orders',
    rows: rows,
    changes: changes,
    writes: writes,
    toJson: (o) => o.toJson(),
    shopIdOf: (o) => o.shopId,
    departmentOf: (o) => o.departmentUuid,
    dateIndexes: const {'created_at'},
    columns: {
      'shop_id': LanColumn(_number, (o) => o.shopId),
      'uuid': LanColumn(_text, (o) => o.uuid),
      'created_at': LanColumn(_time, (o) => o.createdAt),
      'updated_at': LanColumn(_time, (o) => o.updatedAt),
      'department_uuid': LanColumn(_text, (o) => o.departmentUuid),
      // The model calls it `customerId`; the column is `customer_uuid`.
      'customer_uuid': LanColumn(_text, (o) => o.customerId),
      'staff_id': LanColumn(_text, (o) => o.staffId),
      'balance': LanColumn(_number, (o) => o.balance),
      'barcode': LanColumn(_text, (o) => o.barcode),
    },
  );
}

LanTable<TempCustomersClass> customersTable(
  Iterable<TempCustomersClass> Function() rows, {
  Stream<Object?> Function()? changes,
  LanWrites<TempCustomersClass>? writes,
}) {
  return LanTable<TempCustomersClass>(
    name: 'customers',
    rows: rows,
    changes: changes,
    writes: writes,
    toJson: (c) => c.toJson(isMoneyUpdate: true),
    shopIdOf: (c) => c.shopId,
    departmentOf: (c) => c.departmentUuid,
    // The app shows customers in no department to every department.
    includeUnassigned: true,
    dateIndexes: const {'updated_at'},
    columns: {
      'shop_id': LanColumn(_number, (c) => c.shopId),
      'uuid': LanColumn(_text, (c) => c.uuid),
      'name': LanColumn(_text, (c) => c.name),
      'email': LanColumn(_text, (c) => c.email),
      'phone': LanColumn(_text, (c) => c.phone),
      'date_added': LanColumn(_time, (c) => c.dateAdded),
      'updated_at': LanColumn(_time, (c) => c.updatedAt),
      'department_uuid': LanColumn(_text, (c) => c.departmentUuid),
      'balance': LanColumn(_number, (c) => c.balance),
    },
  );
}

LanTable<TempExpensesClass> expensesTable(
  Iterable<TempExpensesClass> Function() rows, {
  Stream<Object?> Function()? changes,
  LanWrites<TempExpensesClass>? writes,
}) {
  return LanTable<TempExpensesClass>(
    name: 'expenses',
    rows: rows,
    changes: changes,
    writes: writes,
    toJson: (e) => e.toJson(),
    shopIdOf: (e) => e.shopId,
    departmentOf: (e) => e.departmentUuid,
    dateIndexes: const {'created_date'},
    columns: {
      'shop_id': LanColumn(_number, (e) => e.shopId),
      'uuid': LanColumn(_text, (e) => e.uuid),
      'name': LanColumn(_text, (e) => e.name),
      'created_date': LanColumn(_time, (e) => e.createdDate),
      'updated_at': LanColumn(_time, (e) => e.updatedAt),
      'expense_type': LanColumn(_text, (e) => e.expenseType),
      'expense_category_uuid': LanColumn(
        _text,
        (e) => e.expenseCategoryUuid,
      ),
      'purchase_uuid': LanColumn(_text, (e) => e.purchaseUuid),
      'staff_uuid': LanColumn(_text, (e) => e.staffUuid),
      'user_id': LanColumn(_text, (e) => e.userId),
      'department_uuid': LanColumn(_text, (e) => e.departmentUuid),
    },
  );
}
