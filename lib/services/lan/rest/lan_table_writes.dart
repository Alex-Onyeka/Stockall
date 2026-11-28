import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/deleted_customers/deleted_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/updated/updated_customers.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expenses/created_expenses.dart';
import 'package:stockall/classes/temp_expenses/unsynced/deleted_expenses/deleted_expenses.dart';
import 'package:stockall/classes/temp_expenses/unsynced/updated/updated_expenses.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_invoices/unsynced/created_invoices/created_invoices.dart';
import 'package:stockall/classes/temp_invoices/unsynced/deleted_invoices/deleted_invoices.dart';
import 'package:stockall/classes/temp_invoices/unsynced/updated/updated_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/created_receipts/created_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/updated/updated_receipts.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/created/created_orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/deleted/deleted_orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/updated/updated_orders.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/created/created_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/deleted/deleted_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/updated/updated_invoices_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/created/created_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/deleted/deleted_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/updated/updated_orders_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';

/// The server's write hooks for the six busy tables. Each mirrors the
/// app's own offline path for that table (`DataProvider.createProduct` /
/// `updateProduct` / `deleteProductMain`, `ReceiptsProvider.createReceipt`
/// / `updateReceipt` / delete, and the same in the invoices, orders,
/// customers and expenses providers):
/// - insert: the main box, then the created queue;
/// - update: the main box; a record still in the created queue has that
///   entry refreshed, otherwise it goes to the updated queue;
/// - delete: the main box; a record still in the created queue just
///   leaves it (Supabase never saw it), otherwise it goes to the deleted
///   queue; any updated-queue entry is dropped.
///
/// The main box gets the row as sent (its `updated_at` included), as
/// Supabase would store it; the queue Funcs then do what they do for the
/// app (some move `updatedAt` forward).

LanWrites<TempProductClass> productWrites() {
  bool queuedCreate(String uuid) =>
      CreatedProductFunc().createdProductsBox.containsKey(uuid);
  return LanWrites<TempProductClass>(
    fromJson: TempProductClass.fromJson,
    queues: Map.fromEntries([
      lanQueue<CreatedProducts>('createdProductsBoxStockall'),
      lanQueue<UpdatedProducts>('updatedProductsBoxStockall'),
      lanQueue<DeletedProducts>('deletedProductsBoxStockall'),
    ]),
    find: (uuid) => ProductsFunc().productBox.get(uuid),
    pull: LanPullStore(
      put: (p) => ProductsFunc().productBox.put(p.uuid, p),
      remove: (uuid) => ProductsFunc().productBox.delete(uuid),
      // A pull keeps the default unit and price pinned on read.
      adopt: (stored, pulled) {
        if (pulled.unitsList?.isEmpty ?? true) {
          pulled.unitsList = stored.unitsList;
        }
        if (pulled.pricesList?.isEmpty ?? true) {
          pulled.pricesList = stored.pricesList;
        }
      },
      pending: () => {
        for (final c in CreatedProductFunc().getProducts()) c.product.uuid,
        for (final u in UpdatedProductsFunc().getProducts()) u.product.uuid,
        for (final d in DeletedProductsFunc().getProductIds()) d.productUuid,
      }.whereType<String>().toSet(),
    ),
    carryOver: (old, fresh) {
      fresh
        ..id = old.id
        ..category = old.category
        ..createdAt ??= old.createdAt;
    },
    insert: (p, json) async {
      await ProductsFunc().productBox.put(p.uuid, p);
      await CreatedProductFunc().createProduct(
        CreatedProducts(
          product: p,
          includeQuantity: json.containsKey('quantity'),
        ),
      );
    },
    update: (p, patch) async {
      final uuid = p.uuid!;
      final includeQuantity = patch.containsKey('quantity');
      await ProductsFunc().productBox.put(uuid, p);
      if (queuedCreate(uuid)) {
        // Keep a quantity the pending insert still has to send.
        final pending = CreatedProductFunc().createdProductsBox.get(uuid);
        await CreatedProductFunc().updateProduct(
          CreatedProducts(
            product: p,
            includeQuantity:
                includeQuantity || (pending?.includeQuantity ?? true),
          ),
        );
      } else {
        final pending = UpdatedProductsFunc().updatedProductsBox.get(uuid);
        await UpdatedProductsFunc().createUpdatedProduct(
          UpdatedProducts(
            product: p,
            includeQuantity:
                includeQuantity || (pending?.includeQuantity ?? false),
          ),
        );
      }
    },
    delete: (p) async {
      final uuid = p.uuid!;
      await ProductsFunc().productBox.delete(uuid);
      if (queuedCreate(uuid)) {
        await CreatedProductFunc().createdProductsBox.delete(uuid);
      } else {
        await DeletedProductsFunc().createDeletedProduct(
          DeletedProducts(productUuid: uuid, date: DateTime.now()),
        );
      }
      if (UpdatedProductsFunc().updatedProductsBox.containsKey(uuid)) {
        await UpdatedProductsFunc().deleteUpdatedProduct(uuid);
      }
      await QuantityUpdateFunc().deleteQuantityUpdatesByProductUuid(
        productUuid: uuid,
      );
    },
  );
}

LanWrites<TempMainReceipt> receiptWrites() {
  bool queuedCreate(String uuid) =>
      CreatedReceiptsFunc().getReceipts().any((c) => c.receipt.uuid == uuid);
  return LanWrites<TempMainReceipt>(
    fromJson: TempMainReceipt.fromJson,
    queues: Map.fromEntries([
      lanQueue<CreatedReceipts>('createdReceiptsBoxStockall'),
      lanQueue<UpdatedReceipts>('updatedReceiptsBoxStockall'),
      lanQueue<DeletedReceipts>('deletedReceiptsBoxStockall'),
    ]),
    find: (uuid) => MainReceiptFunc().receiptBox.get(uuid),
    pull: LanPullStore(
      put: (r) => MainReceiptFunc().receiptBox.put(r.uuid, r),
      remove: (uuid) => MainReceiptFunc().receiptBox.delete(uuid),
      pending: () => {
        for (final c in CreatedReceiptsFunc().getReceipts()) c.receipt.uuid,
        for (final u in UpdatedReceiptsFunc().getReceiptIds()) u.receiptUuid,
        for (final d in DeletedReceiptsFunc().getReceiptIds()) d.receiptUuid,
      }.whereType<String>().toSet(),
    ),
    carryOver: (old, fresh) {
      fresh
        ..id = old.id
        ..tempItems = old.tempItems;
    },
    insert: (r, _) async {
      await MainReceiptFunc().receiptBox.put(r.uuid, r);
      await CreatedReceiptsFunc().createReceipts(CreatedReceipts(receipt: r));
    },
    update: (r, _) async {
      final uuid = r.uuid!;
      await MainReceiptFunc().receiptBox.put(uuid, r);
      if (queuedCreate(uuid)) {
        await CreatedReceiptsFunc().createReceipts(CreatedReceipts(receipt: r));
      } else {
        await UpdatedReceiptsFunc().createUpdatedReceipt(uuid);
      }
    },
    delete: (r) async {
      final uuid = r.uuid!;
      final queuedUpdate = UpdatedReceiptsFunc().getReceiptIds().any(
        (u) => u.receiptUuid == uuid,
      );
      await MainReceiptFunc().receiptBox.delete(uuid);
      if (queuedCreate(uuid)) {
        await CreatedReceiptsFunc().deleteReceipt(uuid);
      } else {
        await DeletedReceiptsFunc().createDeletedReceipt(
          DeletedReceipts(receiptUuid: uuid),
        );
      }
      if (queuedUpdate) {
        await UpdatedReceiptsFunc().deleteUpdatedReceipt(uuid);
      }
    },
  );
}

LanWrites<TempInvoice> invoiceWrites() {
  bool queuedCreate(String uuid) =>
      CreatedInvoicesFunc().getInvoices().any((c) => c.invoice.uuid == uuid);
  return LanWrites<TempInvoice>(
    fromJson: TempInvoice.fromJson,
    queues: Map.fromEntries([
      lanQueue<CreatedInvoices>('createdInvoicesBoxStockall'),
      lanQueue<UpdatedInvoices>('updatedInvoicesBoxStockall'),
      lanQueue<DeletedInvoices>('deletedInvoicesBoxStockall'),
    ]),
    key: 'invoice_uuid',
    find: (uuid) => InvoicesFunc().invoicesBox.get(uuid),
    pull: LanPullStore(
      put: (i) => InvoicesFunc().invoicesBox.put(i.uuid, i),
      remove: (uuid) => InvoicesFunc().invoicesBox.delete(uuid),
      pending: () => {
        for (final c in CreatedInvoicesFunc().getInvoices()) c.invoice.uuid,
        for (final u in UpdatedInvoicesFunc().getInvoiceIds())
          u.updatedInvoice.uuid,
        for (final d in DeletedInvoicesFunc().getInvoiceIds()) d.invoiceUuid,
      }.whereType<String>().toSet(),
    ),
    carryOver: (old, fresh) {
      fresh
        ..id = old.id
        ..tempItems = old.tempItems;
    },
    insert: (i, _) async {
      await InvoicesFunc().invoicesBox.put(i.uuid, i);
      await CreatedInvoicesFunc().createInvoice(CreatedInvoices(invoice: i));
    },
    update: (i, _) async {
      final uuid = i.uuid!;
      await InvoicesFunc().invoicesBox.put(uuid, i);
      if (queuedCreate(uuid)) {
        await CreatedInvoicesFunc().createInvoice(CreatedInvoices(invoice: i));
      } else {
        await UpdatedInvoicesFunc().createUpdatedInvoice(
          UpdatedInvoices(updatedInvoice: i),
        );
      }
    },
    delete: (i) async {
      final uuid = i.uuid!;
      final queuedUpdate = UpdatedInvoicesFunc().getInvoiceIds().any(
        (u) => u.updatedInvoice.uuid == uuid,
      );
      await InvoicesFunc().invoicesBox.delete(uuid);
      if (queuedCreate(uuid)) {
        await CreatedInvoicesFunc().deleteInvoice(uuid);
      } else {
        await DeletedInvoicesFunc().createDeletedInvoice(
          DeletedInvoices(invoiceUuid: uuid),
        );
      }
      if (queuedUpdate) {
        await UpdatedInvoicesFunc().deleteUpdatedInvoice(uuid);
      }
    },
  );
}

LanWrites<Orders> orderWrites() {
  bool queuedCreate(String uuid) =>
      CreatedOrdersFunc().getOrders().any((c) => c.order.uuid == uuid);
  return LanWrites<Orders>(
    fromJson: Orders.fromJson,
    queues: Map.fromEntries([
      lanQueue<CreatedOrders>('createdOrdersBoxStockall'),
      lanQueue<UpdatedOrders>('updatedOrdersBoxStockall'),
      lanQueue<DeletedOrders>('deletedOrdersBoxStockall'),
    ]),
    find: (uuid) => OrdersFunc().orderBox.get(uuid),
    pull: LanPullStore(
      put: (o) => OrdersFunc().orderBox.put(o.uuid, o),
      remove: (uuid) => OrdersFunc().orderBox.delete(uuid),
      pending: () => {
        for (final c in CreatedOrdersFunc().getOrders()) c.order.uuid,
        for (final u in UpdatedOrdersFunc().getOrderIds()) u.order.uuid,
        for (final d in DeletedOrdersFunc().getOrderIds()) d.orderUuid,
      }.whereType<String>().toSet(),
    ),
    insert: (o, _) async {
      await OrdersFunc().orderBox.put(o.uuid, o);
      await CreatedOrdersFunc().createOrders(CreatedOrders(order: o));
    },
    update: (o, _) async {
      final uuid = o.uuid!;
      await OrdersFunc().orderBox.put(uuid, o);
      if (queuedCreate(uuid)) {
        await CreatedOrdersFunc().createOrders(CreatedOrders(order: o));
      } else {
        await UpdatedOrdersFunc().createUpdatedOrder(o);
      }
    },
    delete: (o) async {
      final uuid = o.uuid!;
      final queuedUpdate = UpdatedOrdersFunc().getOrderIds().any(
        (u) => u.order.uuid == uuid,
      );
      await OrdersFunc().orderBox.delete(uuid);
      if (queuedCreate(uuid)) {
        await CreatedOrdersFunc().deleteOrder(uuid);
      } else {
        await DeletedOrdersFunc().createDeletedOrder(
          DeletedOrders(orderUuid: uuid),
        );
      }
      if (queuedUpdate) {
        await UpdatedOrdersFunc().deleteUpdatedOrder(uuid);
      }
    },
  );
}

LanWrites<TempCustomersClass> customerWrites() {
  bool queuedCreate(String uuid) =>
      CreatedCustomersFunc().getCustomers().any((c) => c.customer.uuid == uuid);
  return LanWrites<TempCustomersClass>(
    fromJson: TempCustomersClass.fromJson,
    queues: Map.fromEntries([
      lanQueue<CreatedCustomers>('createdCustomersBoxStockall'),
      lanQueue<UpdatedCustomers>('updatedCustomersBoxStockall'),
      lanQueue<DeletedCustomers>('deletedCustomersBoxStockall'),
    ]),
    find: (uuid) => CustomerFunc().customerBox.get(uuid),
    pull: LanPullStore(
      put: (c) => CustomerFunc().customerBox.put(c.uuid, c),
      remove: (uuid) => CustomerFunc().customerBox.delete(uuid),
      pending: () => {
        for (final c in CreatedCustomersFunc().getCustomers()) c.customer.uuid,
        for (final u in UpdatedCustomersFunc().getCustomers()) u.customer.uuid,
        for (final d in DeletedCustomersFunc().getCustomerIds()) d.customerUuid,
      }.whereType<String>().toSet(),
    ),
    carryOver: (old, fresh) => fresh.id = old.id,
    insert: (c, _) async {
      await CustomerFunc().customerBox.put(c.uuid, c);
      await CreatedCustomersFunc().createCustomers(
        CreatedCustomers(customer: c),
      );
    },
    update: (c, _) async {
      final uuid = c.uuid!;
      await CustomerFunc().customerBox.put(uuid, c);
      if (queuedCreate(uuid)) {
        await CreatedCustomersFunc().updateCustomers(
          CreatedCustomers(customer: c),
        );
      } else {
        await UpdatedCustomersFunc().createUpdatedCustomer(
          UpdatedCustomers(customer: c),
        );
      }
    },
    delete: (c) async {
      final uuid = c.uuid!;
      final queuedUpdate = UpdatedCustomersFunc().getCustomers().any(
        (u) => u.customer.uuid == uuid,
      );
      await CustomerFunc().customerBox.delete(uuid);
      if (queuedCreate(uuid)) {
        await CreatedCustomersFunc().deleteCustomer(uuid);
      } else {
        await DeletedCustomersFunc().createDeletedCustomer(
          DeletedCustomers(customerUuid: uuid, shopId: c.shopId),
        );
      }
      if (queuedUpdate) {
        await UpdatedCustomersFunc().deleteUpdatedCustomer(uuid);
      }
    },
  );
}

LanWrites<TempExpensesClass> expenseWrites() {
  bool queuedCreate(String uuid) =>
      CreatedExpensesFunc().getExpenses().any((c) => c.expenses.uuid == uuid);
  return LanWrites<TempExpensesClass>(
    fromJson: TempExpensesClass.fromJson,
    queues: Map.fromEntries([
      lanQueue<CreatedExpenses>('createdExpensesBoxStockall'),
      lanQueue<UpdatedExpenses>('updatedExpensesBoxStockall'),
      lanQueue<DeletedExpenses>('deletedExpensesBoxStockall'),
    ]),
    find: (uuid) => ExpensesFunc().expensesBox.get(uuid),
    pull: LanPullStore(
      put: (e) => ExpensesFunc().expensesBox.put(e.uuid, e),
      remove: (uuid) => ExpensesFunc().expensesBox.delete(uuid),
      pending: () => {
        for (final c in CreatedExpensesFunc().getExpenses()) c.expenses.uuid,
        for (final u in UpdatedExpensesFunc().getExpenses()) u.expenses.uuid,
        for (final d in DeletedExpensesFunc().getExpenseIds()) d.expensesUuid,
      }.whereType<String>().toSet(),
    ),
    // A purchase has at most one Stock Purchase expense: the app looks it
    // up with `maybeSingle()` and treats a second insert's 23505 as "it is
    // already there".
    unique: const ['purchase_uuid'],
    carryOver: (old, fresh) => fresh.id = old.id,
    insert: (e, _) async {
      await ExpensesFunc().expensesBox.put(e.uuid, e);
      await CreatedExpensesFunc().createExpenses(CreatedExpenses(expenses: e));
    },
    update: (e, _) async {
      final uuid = e.uuid!;
      await ExpensesFunc().expensesBox.put(uuid, e);
      if (queuedCreate(uuid)) {
        await CreatedExpensesFunc().updateExpenses(
          CreatedExpenses(expenses: e),
        );
      } else {
        await UpdatedExpensesFunc().createUpdatedExpense(
          UpdatedExpenses(expenses: e),
        );
      }
    },
    delete: (e) async {
      final uuid = e.uuid!;
      final queuedUpdate = UpdatedExpensesFunc().getExpenses().any(
        (u) => u.expenses.uuid == uuid,
      );
      await ExpensesFunc().expensesBox.delete(uuid);
      if (queuedCreate(uuid)) {
        await CreatedExpensesFunc().deleteExpenses(uuid);
      } else {
        await DeletedExpensesFunc().createDeletedExpense(
          DeletedExpenses(expensesUuid: uuid, shopId: e.shopId),
        );
      }
      if (queuedUpdate) {
        await UpdatedExpensesFunc().deleteUpdatedExpense(uuid);
      }
    },
  );
}

/// Who the server's made-up defaults are by (its signed-in user).
typedef LanStaff = ({String? id, String? name});

/// The unit `ProductUnitsClass.getUnitList` makes up for an item with none.
ProductUnitsClass _defaultUnit(String? itemUuid, LanStaff by, int? dimension) {
  return ProductUnitsClass(
    uuid: uuidGen(),
    staffUuid: by.id,
    createdAt: DateTime.now(),
    staffName: by.name,
    conversion: 1,
    name: 'Unit(s)',
    isPrimary: true,
    productUuid: itemUuid ?? '',
    dimensionType: dimension,
  );
}

/// Saves a row whose defaults were just pinned. A failed save is not the
/// read's problem: the row keeps them in memory, and the next read after a
/// restart pins new ones.
void _save<T>(Future<void> Function(T row) persist, T row) {
  Future.sync(() => persist(row)).catchError((Object _) {});
}

/// The `toJson` of products, storage products, materials and production
/// items makes up a unit (and, for products, a price) each time it is
/// called on a row that has none: a new uuid, now, the current user. On the
/// server they are made once per row, with the values `toJson` would use,
/// and kept on the row in the server's box, so every LAN read gives the
/// same ones. They are not queued for Supabase: its row is left as it is.
void Function(TempProductClass product) productDefaultsPinner({
  required Future<void> Function(TempProductClass product) persist,
  required LanStaff Function() staff,
}) {
  return (p) {
    final noUnits = p.unitsList == null || p.unitsList!.isEmpty;
    final noPrices = p.pricesList == null || p.pricesList!.isEmpty;
    if (!noUnits && !noPrices) return;
    final by = staff();
    if (noUnits) {
      p.unitsList = [
        _defaultUnit(
          p.uuid,
          by,
          p.quantityType == 2
              ? (ProductUnitsClass.isAreaUnitName(p.unit)
                    ? ProductUnitsClass.areaUnit
                    : ProductUnitsClass.sheetUnit)
              : null,
        ),
      ];
    }
    if (noPrices) {
      p.pricesList = [
        ProductPricesClass(
          uuid: uuidGen(),
          staffUuid: by.id,
          createdAt: DateTime.now(),
          staffName: by.name,
          priceValue: 0,
          name: 'Prices',
          isPrimary: true,
          itemUuid: p.uuid ?? '',
          priceType: 1,
        ),
      ];
    }
    _save(persist, p);
  };
}

/// The same for the other items with a unit list.
void Function(T row) unitDefaultsPinner<T>({
  required List<ProductUnitsClass>? Function(T row) units,
  required void Function(T row, List<ProductUnitsClass> units) setUnits,
  required String? Function(T row) uuidOf,
  int? Function(T row)? dimensionOf,
  required Future<void> Function(T row) persist,
  required LanStaff Function() staff,
}) {
  return (row) {
    final current = units(row);
    if (current != null && current.isNotEmpty) return;
    setUnits(row, [
      _defaultUnit(uuidOf(row), staff(), dimensionOf?.call(row)),
    ]);
    _save(persist, row);
  };
}
