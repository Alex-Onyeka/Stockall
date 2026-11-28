import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/services/lan/lan_constants.dart';

/// Who a LAN session belongs to, as the server sees it.
class LanPrincipal {
  const LanPrincipal({
    required this.userId,
    required this.shopId,
    required this.role,
    required this.access,
    required this.departmentUuids,
    required this.isOwner,
    this.deviceId,
  });

  factory LanPrincipal.fromCredential(
    LanUserCredential credential, {
    String? deviceId,
  }) {
    return LanPrincipal(
      userId: credential.userId,
      shopId: credential.shopId,
      role: credential.role,
      access: List.unmodifiable(credential.access),
      departmentUuids: List.unmodifiable(credential.departmentUuids),
      isOwner: credential.isOwner,
      deviceId: deviceId,
    );
  }

  final String userId;
  final int shopId;
  final String role;
  final List<String> access;
  final List<String> departmentUuids;
  final bool isOwner;

  /// The device the session was issued to (its stock holds are its
  /// own); null outside a session.
  final String? deviceId;
}

class LanAccessDenied implements Exception {
  const LanAccessDenied(this.permission);
  final String permission;

  @override
  String toString() => 'LanAccessDenied($permission)';
}

/// Server-side mirror of the app's checks, so a modified client can't do
/// more than the UI allows.
class LanAccessPolicy {
  LanAccessPolicy._();

  static bool isMember(LanPrincipal? principal, int shopId) {
    return principal != null && principal.shopId == shopId;
  }

  /// The same rule as `authorization()`: the permission string must be in
  /// the user's `access` list. Owners get no implicit pass, exactly as in
  /// the app.
  static bool has(LanPrincipal principal, String permission) {
    return principal.access.contains(permission);
  }

  static void require(LanPrincipal principal, String permission) {
    if (!has(principal, permission)) throw LanAccessDenied(permission);
  }

  /// The app's department rule (`DepartmentProvider.departmentRecordVisible`)
  /// without the device's "current department", which the server can't
  /// know. The device then narrows to its current department itself, so
  /// this must let through everything any of the user's departments shows:
  /// - departments off, or "View All Departments": visible;
  /// - staff in no department: only records in no department;
  /// - staff in departments: records in one of their departments, plus
  ///   records in no department where the app passes
  ///   `includeUnassignedWhenDeptSelected` ([includeUnassigned]: shared
  ///   products, customers, …).
  static bool canSeeDepartment(
    LanPrincipal principal, {
    required bool manageDepartments,
    String? departmentUuid,
    List<String>? departmentUuids,
    bool includeUnassigned = false,
  }) {
    if (!manageDepartments) return true;
    if (has(principal, Authorizations().viewAllDepartments)) return true;
    final recordDepartments = {
      if (departmentUuid != null && departmentUuid.trim().isNotEmpty)
        departmentUuid,
      ...?departmentUuids?.where((d) => d.trim().isNotEmpty),
    };
    if (principal.departmentUuids.isEmpty) return recordDepartments.isEmpty;
    if (recordDepartments.isEmpty) return includeUnassigned;
    return recordDepartments.any(principal.departmentUuids.contains);
  }

  /// The permissions that allow a write: any one of them is enough. Empty
  /// means membership alone (histories, logs, sales lines). Null means
  /// the table/op is not mapped, which is denied.
  static Set<String>? writePermissions(String table, LanWriteOp op) {
    return _writeMap[table]?[op];
  }

  /// Whether [principal] may make this write. [ownRow] is true when the
  /// write targets the user's own `users` row (name, password, PIN), which
  /// the app lets everyone change.
  static bool canWrite(
    LanPrincipal principal,
    String table,
    LanWriteOp op, {
    bool ownRow = false,
  }) {
    if (table == 'users' && op == LanWriteOp.update && ownRow) return true;
    final allowed = writePermissions(table, op);
    if (allowed == null) return false;
    if (allowed.isEmpty) return true;
    return allowed.any(principal.access.contains);
  }

  /// The permissions that allow an RPC: any one of them is enough. Empty
  /// means membership alone; null (not mapped) is denied.
  static Set<String>? rpcPermissions(String name) => _rpcMap[name];

  static bool canCall(LanPrincipal principal, String name) {
    final allowed = rpcPermissions(name);
    if (allowed == null) return false;
    if (allowed.isEmpty) return true;
    return allowed.any(principal.access.contains);
  }

  /// Each RPC under every permission whose screen sends it: a stock or
  /// account change comes from the screens that write that table (the
  /// table's insert and update sets above) and from the sale, refund,
  /// order, purchase and production screens that move stock; holds and
  /// checkouts come from the cart (a sale, or editing a receipt, invoice
  /// or order in it). Releasing a hold only lets stock go: membership.
  static final Map<String, Set<String>> _rpcMap = () {
    final a = Authorizations();
    Set<String> writers(String table) => {
      ...?_writeMap[table]?[LanWriteOp.insert],
      ...?_writeMap[table]?[LanWriteOp.update],
    };
    final production = {
      a.addProductionRecords,
      a.updateProductionRecords,
      a.deleteProductionRecords,
    };
    final cart = {
      a.makeSale,
      a.updateSale,
      a.makeRefund,
      a.updateInvoice,
      a.addOrders,
      a.updateOrders,
      a.manageOrders,
      a.makeSalesFromCustomersAccount,
    };
    return {
      'update_product_quantities': {
        ...writers('products'),
        ...cart,
        a.deleteSale,
        a.deleteInvoice,
        a.deleteOrders,
        a.managePurchases,
        a.manageInventoryStorage,
        ...production,
      },
      'update_materials_quantities': {
        ...writers('production_materials'),
        a.addMaterialsUsage,
        a.updateMaterialsUsage,
        a.deleteMaterialsUsage,
        ...production,
      },
      'update_production_items_quantities': {
        ...writers('production_items'),
        ...production,
      },
      'update_customer_account': {
        ...writers('customer_account_receipts'),
        ...writers('customers'),
        a.deleteCustomersTransactions,
        a.deleteSale,
        a.updateSale,
        a.makeRefund,
      },
      LanConstants.stockReserveRpc: cart,
      LanConstants.stockSyncRpc: cart,
      LanConstants.stockCheckoutRpc: cart,
      LanConstants.stockReleaseRpc: const <String>{},
      // Online only: marking this store's notifications read (any member
      // may update them), and reading the subscription's payments.
      'mark_all_notifications_viewed': const <String>{},
      'get_this_month_subscription_payments': const <String>{},
    };
  }();

  /// Several screens write the same table under different permissions
  /// (a sale creates a custom item, a transfer creates the item in the
  /// destination department, the price screen updates it), so each op
  /// lists every permission whose screen sends it. The sets of the six
  /// busy tables (products, receipts, invoices, orders, customers,
  /// expenses) were checked against the app's call sites; the rest are
  /// inferred from the permission names.
  static final Map<String, Map<LanWriteOp, Set<String>>> _writeMap = () {
    final a = Authorizations();
    const member = <String>{};
    Map<LanWriteOp, Set<String>> all(Set<String> p) => {
      for (final op in LanWriteOp.values) op: p,
    };
    Map<LanWriteOp, Set<String>> crud(
      Set<String> insert,
      Set<String> update,
      Set<String> delete,
    ) => {
      LanWriteOp.insert: insert,
      LanWriteOp.update: update,
      LanWriteOp.delete: delete,
    };
    final customerMoney = {
      a.creditCustomersAccount,
      a.debitCustomersAccount,
      a.redeemCustomersReward,
      a.makeSalesFromCustomersAccount,
      a.makeSale,
    };
    return {
      // Served and checked against the app.
      'products': crud(
        {a.addProduct, a.transferProduct, a.makeSale},
        {
          a.updateProduct,
          a.editSellingPrice,
          a.manageCostPrice,
          a.generateBarcode,
          a.manageInventoryStorage,
          a.manageMultipleUnits,
          a.transferProduct,
          a.updateItemQuantity,
        },
        {a.deleteProduct},
      ),
      'receipts': crud(
        {a.makeSale, a.updateInvoice, a.manageOrders, a.updateOrders},
        {a.updateSale, a.makeSale, a.makeRefund, a.updateInvoice},
        {a.deleteSale},
      ),
      'invoices': crud(
        {a.makeSale},
        {a.updateInvoice, a.makeSale},
        {a.deleteInvoice},
      ),
      'orders': crud(
        {a.addOrders, a.manageOrders, a.makeSale},
        {a.updateOrders, a.manageOrders, a.makeSale},
        {a.deleteOrders, a.manageOrders},
      ),
      'customers': crud(
        {a.addCustomer, a.makeSale},
        {a.updateCustomer, ...customerMoney},
        {a.deleteCustomer},
      ),
      'expenses': crud(
        {a.addExpense, a.managePurchases},
        {a.updateExpenses, a.managePurchases},
        {a.deleteExpenses, a.managePurchases},
      ),
      // Membership only.
      'product_sales': all(member),
      'item_history': all(member),
      'storage_item_history': all(member),
      'production_item_history': all(member),
      'production_materials_item_history': all(member),
      'inventory_updates': all(member),
      'event_logs': all(member),
      'error_logs': all(member),
      // Inferred from the permission names.
      'drafts': all({a.makeSale}),
      'customer_account_receipts': crud(
        customerMoney,
        customerMoney,
        {a.deleteCustomersTransactions, a.deleteSale},
      ),
      'expense_categories': crud(
        {a.addExpense, a.updateExpenses},
        {a.updateExpenses},
        {a.deleteExpenses},
      ),
      'categories': crud(
        {a.addProduct, a.updateProduct},
        {a.updateProduct},
        {a.deleteProduct},
      ),
      'departments': all({a.manageShop}),
      'suppliers': crud(
        {a.addSupplier, a.managePurchases},
        {a.updateSupplier},
        {a.deleteSupplier},
      ),
      'sub_staff': all({a.manageSubStaff}),
      'storage_products': all({a.manageInventoryStorage}),
      'purchases': all({a.managePurchases}),
      'waybills': all({a.managePurchases}),
      'way_bills': all({a.managePurchases}),
      'production_materials': crud(
        {a.addMaterials, a.transferMaterials},
        {a.updateMaterials, a.transferMaterials, a.updateMaterialQuantity},
        {a.deleteMaterials},
      ),
      'production_items': crud(
        {a.addProductionItems, a.transferProductionItems},
        {
          a.updateProductionItems,
          a.transferProductionItems,
          a.updateProductionItemQuantity,
        },
        {a.deleteProductionItems},
      ),
      'production_records': crud(
        {a.addProductionRecords},
        {a.updateProductionRecords},
        {a.deleteProductionRecords},
      ),
      'production_materials_usage': crud(
        {a.addMaterialsUsage},
        {a.updateMaterialsUsage},
        {a.deleteMaterialsUsage},
      ),
      'users': crud({a.addEmployee}, {a.updateEmployee}, {a.deleteEmployee}),
      // A shop's settings are spread over many screens; its members
      // (employees) change on the employee screens.
      'shops': crud(
        {a.createShop},
        {
          a.manageShop,
          a.manageVAT,
          a.generalDiscount,
          a.salesDiscount,
          a.editReceiptTemplate,
          a.manageAccessPin,
          a.manageInventoryStorage,
          a.toggleBulkSale,
          a.toggleTrackCart,
          a.toggleUseGroupUnit,
          a.togglePrintSalesDocket,
          a.toggleManageProductions,
          a.toggleManageProductionsStorage,
          a.toggleManageProductionItems,
          a.toggleManageCustomersReward,
          a.toggleManageCustomersAccount,
          a.addEmployee,
          a.updateEmployee,
          a.deleteEmployee,
        },
        {a.deleteShop},
      ),
      // Online only (forwarded to Supabase).
      'notifications': {
        LanWriteOp.update: member,
        LanWriteOp.delete: {a.deleteNotification},
      },
      'subscription': {
        LanWriteOp.insert: {a.manageShop},
        LanWriteOp.update: {a.manageShop},
      },
      'subscription_payments': {
        LanWriteOp.insert: {a.manageShop},
        LanWriteOp.update: {a.manageShop},
      },
    };
  }();
}

enum LanWriteOp { insert, update, delete }
