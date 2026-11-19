import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

/// Page size, same as the other report tables.
const int staffReportPageSize = 100;

/// Role filter key of the staff no longer in the shop.
const String staffReportFormerRoleKey = '__former__';

/// Role filter key of the staff saved without a role.
const String staffReportNoRoleKey = '__none__';

const String staffReportFormerRoleLabel = 'Former staff';

// ---------------------------------------------------------------
// Access: settings and permissions
// ---------------------------------------------------------------

/// Everything the staff report reads from the shop settings and the
/// user's permissions. The app builds it from the providers, tests
/// build it by hand.
///
/// Department and own-transactions rules are the Receipts Report's
/// ([ReceiptsReportAccess.scope]), applied to every record kind, as
/// in [CustomerReportAccess].
class StaffReportAccess {
  final bool departmentsEnabled;
  final bool canViewAllDepartments;
  final String? currentDepartmentUuid;

  /// `Authorizations().viewAllTransactionRecords`. Without it the
  /// user sees only their own row.
  final bool canViewAllTransactions;
  final String? currentUserId;

  /// Orders column, KPIs, section and "See all": the plan's
  /// `manageOrders`, as the Order Report tile.
  final bool showOrders;

  /// Purchases column, KPIs, section and "See all":
  /// `Authorizations().managePurchases`, as the Purchase Report
  /// tile.
  final bool showPurchases;

  /// Expenses column, KPIs, section and "See all": the Expenses
  /// page's own gate, `!isStoreKeeper()`.
  final bool showExpenses;

  /// `Authorizations().viewDate`.
  final bool canPickDate;

  const StaffReportAccess({
    required this.departmentsEnabled,
    required this.canViewAllDepartments,
    required this.currentDepartmentUuid,
    required this.canViewAllTransactions,
    required this.currentUserId,
    required this.showOrders,
    required this.showPurchases,
    required this.showExpenses,
    required this.canPickDate,
  });

  /// All time (loaded data) with the View Date permission,
  /// otherwise today: the period button is disabled without it.
  ReceiptsReportPeriod initialPeriod({DateTime? now, TimeOfDay? closingTime}) {
    if (canPickDate) return const ReceiptsReportPeriod.allTime();
    return ReceiptsReportPeriod.today(now: now, closingTime: closingTime);
  }

  /// Whether [staffKey]'s row is shown at all.
  bool canSeeStaff(String staffKey) =>
      canViewAllTransactions || staffKey == currentUserId;

  bool get _restrictDepartment =>
      departmentsEnabled &&
      (!canViewAllDepartments || currentDepartmentUuid != null);

  bool _allows(String? departmentUuid, String? staffId) {
    if (_restrictDepartment &&
        !reportDepartmentMatches(departmentUuid, currentDepartmentUuid)) {
      return false;
    }
    return canViewAllTransactions || staffId == currentUserId;
  }

  List<TempMainReceipt> scopeReceipts(List<TempMainReceipt> receipts) {
    return ReceiptsReportAccess.scope(
      receipts: receipts,
      departmentsEnabled: departmentsEnabled,
      canViewAllDepartments: canViewAllDepartments,
      currentDepartmentUuid: currentDepartmentUuid,
      canViewAllTransactions: canViewAllTransactions,
      currentUserId: currentUserId,
    );
  }

  List<TempInvoice> scopeInvoices(List<TempInvoice> invoices) {
    return invoices
        .where((i) => _allows(i.departmentUuidNew, i.staffId))
        .toList();
  }

  List<Orders> scopeOrders(List<Orders> orders) {
    return orders.where((o) => _allows(o.departmentUuid, o.staffId)).toList();
  }

  List<TempPurchase> scopePurchases(List<TempPurchase> purchases) {
    return PurchaseReportAccess.scope(
      purchases: purchases,
      departmentsEnabled: departmentsEnabled,
      canViewAllDepartments: canViewAllDepartments,
      currentDepartmentUuid: currentDepartmentUuid,
      canViewAllTransactions: canViewAllTransactions,
      currentUserId: currentUserId,
    );
  }

  /// Stock Purchase expenses are left out: they are the staff's
  /// purchase payments, already counted under purchases.
  List<TempExpensesClass> scopeExpenses(List<TempExpensesClass> expenses) {
    return expenses
        .where(
          (e) => !e.isStockPurchase && _allows(e.departmentUuid, e.userId),
        )
        .toList();
  }
}

// ---------------------------------------------------------------
// Source data and the period-independent base
// ---------------------------------------------------------------

/// Loaded data, as the providers hold it.
class StaffReportSource {
  /// The shop's staff (`UserProvider.usersMain`). The owner is not
  /// one of the shop's employees, so it comes as [owner].
  final List<TempUserClass> staff;
  final TempUserClass? owner;

  /// The signed-in user, so their own row shows even when the
  /// staff list has not loaded.
  final TempUserClass? currentUser;

  /// Every loaded receipt. Invoice and order payments are counted
  /// from all of them, as the Invoice and Order reports do.
  final List<TempMainReceipt> receipts;
  final List<TempProductSaleRecord> productSales;
  final List<TempInvoice> invoices;
  final List<Orders> orders;
  final List<TempPurchase> purchases;
  final List<TempExpensesClass> expenses;

  /// Customer names for invoices saved without one.
  final List<TempCustomersClass> customers;

  /// As `PurchaseReportEnv`: item_purchase_records lines, current
  /// supplier names, and purchases queued for deletion (left out).
  final List<TempItemPurchaseRecord> purchaseLegacyLines;
  final Map<String, String> supplierNames;
  final Set<String> pendingDeletedPurchaseUuids;

  /// Invoices, orders and expenses of other shops are left out, as
  /// their reports do. Null keeps them all.
  final int? shopId;

  const StaffReportSource({
    required this.staff,
    this.owner,
    this.currentUser,
    required this.receipts,
    this.productSales = const [],
    this.invoices = const [],
    this.orders = const [],
    this.purchases = const [],
    this.expenses = const [],
    this.customers = const [],
    this.purchaseLegacyLines = const [],
    this.supplierNames = const {},
    this.pendingDeletedPurchaseUuids = const {},
    this.shopId,
  });
}

/// One expense, as the staff report and the Staff Expenses table
/// show it.
class StaffExpenseRow {
  final TempExpensesClass expense;

  /// Local time. Null only for malformed expenses: those are shown
  /// for All time and sink to the bottom.
  final DateTime? createdAt;

  StaffExpenseRow(this.expense) : createdAt = expense.createdDate?.toLocal();

  String get uuid => expense.uuid ?? '';
  double get amount => expense.amount;
  String get title => _name(expense.name) ?? 'Not Set';
  String? get description => _name(expense.description);
  double? get quantity => expense.quantity;
  String? get unit => _name(expense.unit);
  String? get staffKey => _key(expense.userId);

  /// `creator`; `userName` is never written.
  String? get staffName => _name(expense.creator) ?? _name(expense.userName);
  String? get departmentKey => _key(expense.departmentUuid);
  String? get departmentName => _name(expense.departmentName);

  bool inPeriod(ReceiptsReportPeriod period, {TimeOfDay? closingTime}) {
    if (period.isAllTime) return true;
    final at = createdAt;
    return at != null && period.contains(at, closingTime: closingTime);
  }

  /// Newest first; undated expenses last.
  static int newestFirst(StaffExpenseRow a, StaffExpenseRow b) {
    final c = StaffReportQuery.cmp(a.createdAt, b.createdAt, false);
    return c != 0 ? c : a.uuid.compareTo(b.uuid);
  }
}

/// Report rows built once from the loaded data and the user's
/// scope, before any period. Only records with a staff are kept:
/// each row is built on its own, so this changes no staff's
/// numbers. Hidden kinds ([StaffReportAccess.showOrders] etc.) are
/// not built.
class StaffReportBase {
  final StaffReportAccess access;

  /// The staff the user may see, owner first, one per user id.
  final List<TempUserClass> staff;
  final List<ReceiptsReportRow> receiptRows;
  final List<InvoiceReportRow> invoiceRows;
  final List<OrderReportRow> orderRows;
  final List<PurchaseReportRow> purchaseRows;
  final List<StaffExpenseRow> expenseRows;

  /// Newest name each staff id was saved with, for former staff.
  final Map<String, String> recordNames;

  const StaffReportBase({
    required this.access,
    required this.staff,
    required this.receiptRows,
    required this.invoiceRows,
    required this.orderRows,
    required this.purchaseRows,
    required this.expenseRows,
    required this.recordNames,
  });

  factory StaffReportBase.build({
    required StaffReportSource source,
    required StaffReportAccess access,
  }) {
    bool hasStaff(String? key) => _key(key) != null;
    bool inShop(int shopId) => source.shopId == null || shopId == source.shopId;

    final staff = <TempUserClass>[];
    final seen = <String>{};
    for (final u in [source.owner, source.currentUser, ...source.staff]) {
      final id = _key(u?.userId);
      if (id == null || !access.canSeeStaff(id) || !seen.add(id)) continue;
      staff.add(u!);
    }

    final receiptRows = ReceiptsReportRowBuilder.buildAll(
      receipts:
          access
              .scopeReceipts(source.receipts)
              .where((r) => hasStaff(r.staffId))
              .toList(),
      legacySales: source.productSales,
    );

    final invoiceRows = InvoiceReportRowBuilder.buildAll(
      invoices:
          access
              .scopeInvoices(
                source.invoices.where((i) => inShop(i.shopId)).toList(),
              )
              .where((i) => hasStaff(i.staffId))
              .toList(),
      allReceipts: source.receipts,
      allProductSales: source.productSales,
      customerMap: {
        for (final c in source.customers)
          if (_key(c.uuid) != null) c.uuid!: c,
      },
    );

    final orderRows =
        access.showOrders
            ? OrderReportRowBuilder.buildAll(
              orders:
                  access
                      .scopeOrders(
                        source.orders.where((o) => inShop(o.shopId)).toList(),
                      )
                      .where((o) => hasStaff(o.staffId))
                      .toList(),
              allReceipts: source.receipts,
              allProductSales: source.productSales,
            )
            : <OrderReportRow>[];

    final purchaseRows =
        access.showPurchases
            ? PurchaseReportRowBuilder.buildAll(
              purchases:
                  access
                      .scopePurchases(source.purchases)
                      .where((p) => hasStaff(p.staffId))
                      .toList(),
              legacyLines: source.purchaseLegacyLines,
              supplierNames: source.supplierNames,
              pendingDeletedUuids: source.pendingDeletedPurchaseUuids,
            )
            : <PurchaseReportRow>[];

    final expenseRows =
        access.showExpenses
            ? access
                .scopeExpenses(
                  source.expenses.where((e) => inShop(e.shopId)).toList(),
                )
                .where((e) => hasStaff(e.userId))
                .map(StaffExpenseRow.new)
                .toList()
            : <StaffExpenseRow>[];

    return StaffReportBase(
      access: access,
      staff: staff,
      receiptRows: receiptRows,
      invoiceRows: invoiceRows,
      orderRows: orderRows,
      purchaseRows: purchaseRows,
      expenseRows: expenseRows,
      recordNames: _recordNames(
        receiptRows: receiptRows,
        invoiceRows: invoiceRows,
        orderRows: orderRows,
        purchaseRows: purchaseRows,
        expenseRows: expenseRows,
      ),
    );
  }

  /// Sales, invoices, orders and purchases first: an edited
  /// expense may carry the editor's name as its creator.
  static Map<String, String> _recordNames({
    required List<ReceiptsReportRow> receiptRows,
    required List<InvoiceReportRow> invoiceRows,
    required List<OrderReportRow> orderRows,
    required List<PurchaseReportRow> purchaseRows,
    required List<StaffExpenseRow> expenseRows,
  }) {
    final primary = <String, ({DateTime at, String name})>{};
    final fallback = <String, ({DateTime at, String name})>{};
    void note(
      Map<String, ({DateTime at, String name})> into,
      String? key,
      String? name,
      DateTime? at,
    ) {
      final n = _name(name);
      if (key == null || n == null || at == null) return;
      final current = into[key];
      if (current == null || at.isAfter(current.at)) {
        into[key] = (at: at, name: n);
      }
    }

    for (final r in receiptRows) {
      note(primary, r.staffKey, r.staffName, r.createdAt);
    }
    for (final r in invoiceRows) {
      note(primary, _key(r.invoice.staffId), r.invoice.staffName, r.createdAt);
    }
    for (final r in orderRows) {
      note(primary, r.staffKey, r.staffName, r.createdAt);
    }
    for (final r in purchaseRows) {
      note(primary, r.staffKey, r.staffName, r.createdAt);
    }
    for (final r in expenseRows) {
      note(fallback, r.staffKey, r.staffName, r.createdAt);
    }
    // Later entries win: a sales-side name over an expense's.
    return {
      for (final e in fallback.entries) e.key: e.value.name,
      for (final e in primary.entries) e.key: e.value.name,
    };
  }
}

// ---------------------------------------------------------------
// Period slice: each report's own query, grouped by staff
// ---------------------------------------------------------------

/// The base rows in one period, grouped by staff id, newest first.
/// Each report's own query selects the rows with no filter other
/// than the period, so a staff's group is exactly what that report
/// shows when filtered to the staff.
///
/// [closingTime] reaches the receipts, orders, purchases and
/// expenses. The Invoice Report query has no such parameter and
/// always uses the shop's closing time, which is also what the
/// others use when [closingTime] is null, as in the app.
class StaffReportSlice {
  final StaffReportBase base;
  final ReceiptsReportPeriod period;
  final Map<String, List<ReceiptsReportRow>> receipts;
  final Map<String, List<InvoiceReportRow>> invoices;
  final Map<String, List<OrderReportRow>> orders;
  final Map<String, List<PurchaseReportRow>> purchases;
  final Map<String, List<StaffExpenseRow>> expenses;

  const StaffReportSlice._({
    required this.base,
    required this.period,
    required this.receipts,
    required this.invoices,
    required this.orders,
    required this.purchases,
    required this.expenses,
  });

  factory StaffReportSlice.of(
    StaffReportBase base,
    ReceiptsReportPeriod period, {
    TimeOfDay? closingTime,
  }) {
    final departmentsEnabled = base.access.departmentsEnabled;

    final receiptRows = ReceiptsReportQuery.filterAndSort(
      rows: base.receiptRows,
      period: period,
      filters: ReceiptsReportFilters(),
      sortField: ReceiptsSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: false,
      profitVisible: false,
      closingTime: closingTime,
    );

    final invoiceRows = InvoiceReportQuery.filterAndSort(
      rows: base.invoiceRows,
      filters: InvoiceReportFilters(dateRange: customerReportDateRange(period)),
      sortField: InvoiceSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      bulkSaleEnabled: false,
      costFilterAllowed: false,
    );

    final orderRows = OrderReportQuery.filterAndSort(
      rows: base.orderRows,
      period: period,
      filters: OrderReportFilters(),
      sortField: OrderSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: false,
      profitVisible: false,
      closingTime: closingTime,
    );

    final purchaseRows = PurchaseReportQuery.filterAndSort(
      rows: base.purchaseRows,
      period: period,
      filters: PurchaseReportFilters(),
      sortField: PurchasesSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      closingTime: closingTime,
    );

    final expenseRows =
        base.expenseRows
            .where((r) => r.inPeriod(period, closingTime: closingTime))
            .toList()
          ..sort(StaffExpenseRow.newestFirst);

    return StaffReportSlice._(
      base: base,
      period: period,
      receipts: _group(receiptRows, (r) => r.staffKey),
      invoices: _group(invoiceRows, (r) => _key(r.invoice.staffId)),
      orders: _group(orderRows, (r) => r.staffKey),
      purchases: _group(purchaseRows, (r) => r.staffKey),
      expenses: _group(expenseRows, (r) => r.staffKey),
    );
  }

  static Map<String, List<T>> _group<T>(
    List<T> rows,
    String? Function(T) keyOf,
  ) {
    final map = <String, List<T>>{};
    for (final r in rows) {
      final k = keyOf(r);
      if (k == null) continue;
      (map[k] ??= []).add(r);
    }
    return map;
  }

  List<ReceiptsReportRow> receiptsOf(String? staffKey) =>
      receipts[staffKey] ?? const [];
  List<InvoiceReportRow> invoicesOf(String? staffKey) =>
      invoices[staffKey] ?? const [];
  List<OrderReportRow> ordersOf(String? staffKey) =>
      orders[staffKey] ?? const [];
  List<PurchaseReportRow> purchasesOf(String? staffKey) =>
      purchases[staffKey] ?? const [];
  List<StaffExpenseRow> expensesOf(String? staffKey) =>
      expenses[staffKey] ?? const [];

  /// Staff ids with at least one record in the period.
  Set<String> get activeKeys => {
    ...receipts.keys,
    ...invoices.keys,
    ...orders.keys,
    ...purchases.keys,
    ...expenses.keys,
  };
}

// ---------------------------------------------------------------
// Staff rows
// ---------------------------------------------------------------

enum StaffReportSortField {
  name,
  role,
  phone,
  receiptSales,
  invoiceSales,
  orderCount,
  orderTotal,
  purchaseCount,
  purchaseTotal,
  expenseCount,
  expenseTotal,
  lastActivity,
}

/// One staff in one period. Every value is calculated once, when
/// the row is built.
class StaffReportRow {
  /// `TempUserClass.userId`, the staff id every record carries.
  final String key;

  /// Null for former staff: their id is on records but no longer
  /// in the shop's staff list.
  final TempUserClass? user;
  final String name;

  /// Revenue of every receipt type (cash + bank + customer
  /// account, VAT included): the Receipts table's total for this
  /// staff.
  final double receiptSales;
  final int receiptCount;

  /// Sum of invoice totals: the Invoice table's total for this
  /// staff.
  final double invoiceSales;
  final int invoiceCount;

  /// Order Report totals for this staff.
  final double orderTotal;
  final int orderCount;

  /// Purchase Report totals for this staff.
  final double purchaseTotal;
  final int purchaseCount;

  /// Staff Expenses table totals for this staff.
  final double expenseTotal;
  final int expenseCount;

  /// Earliest and latest record of any visible kind.
  final DateTime? firstActivity;
  final DateTime? lastActivity;

  StaffReportRow({
    required this.key,
    required this.user,
    required this.name,
    required this.receiptSales,
    required this.receiptCount,
    required this.invoiceSales,
    required this.invoiceCount,
    required this.orderTotal,
    required this.orderCount,
    required this.purchaseTotal,
    required this.purchaseCount,
    required this.expenseTotal,
    required this.expenseCount,
    required this.firstActivity,
    required this.lastActivity,
  });

  bool get isFormer => user == null;
  String? get role => isFormer ? null : _name(user!.role);
  String? get phone => isFormer ? null : _name(user!.phone);
  String? get email => isFormer ? null : _name(user!.email);

  String get roleLabel =>
      isFormer ? staffReportFormerRoleLabel : (role ?? 'Not Set');

  /// [StaffReportOptions.roles] key. Spelling and case differences
  /// of one role share a key.
  String get roleKey {
    if (isFormer) return staffReportFormerRoleKey;
    return role?.toLowerCase() ?? staffReportNoRoleKey;
  }

  int get activityCount =>
      receiptCount + invoiceCount + orderCount + purchaseCount + expenseCount;

  /// "First Last" as saved, else 'Not Set'.
  static String nameOf(TempUserClass user) {
    final parts =
        [_name(user.name), _name(user.lastName)].whereType<String>().toList();
    return parts.isEmpty ? 'Not Set' : parts.join(' ');
  }
}

class StaffReportRowBuilder {
  /// [user] null builds a former staff row, named from the records.
  static StaffReportRow build({
    required String key,
    required TempUserClass? user,
    required StaffReportSlice slice,
  }) {
    final receipts = slice.receiptsOf(key);
    final invoices = slice.invoicesOf(key);
    final orders = slice.ordersOf(key);
    final purchases = slice.purchasesOf(key);
    final expenses = slice.expensesOf(key);

    DateTime? first;
    DateTime? last;
    void seen(DateTime? at) {
      if (at == null) return;
      if (first == null || at.isBefore(first!)) first = at;
      if (last == null || at.isAfter(last!)) last = at;
    }

    double receiptSales = 0;
    for (final r in receipts) {
      receiptSales += r.revenue;
      seen(r.createdAt);
    }

    double invoiceSales = 0;
    for (final r in invoices) {
      invoiceSales += r.invoiceTotal ?? 0;
      seen(r.createdAt.toLocal());
    }

    double orderTotal = 0;
    for (final r in orders) {
      orderTotal += r.total;
      seen(r.createdAt);
    }

    double purchaseTotal = 0;
    for (final r in purchases) {
      purchaseTotal += r.total;
      seen(r.createdAt);
    }

    double expenseTotal = 0;
    for (final r in expenses) {
      expenseTotal += r.amount;
      seen(r.createdAt);
    }

    return StaffReportRow(
      key: key,
      user: user,
      name:
          user != null
              ? StaffReportRow.nameOf(user)
              : slice.base.recordNames[key] ?? 'Not Set',
      receiptSales: receiptSales,
      receiptCount: receipts.length,
      invoiceSales: invoiceSales,
      invoiceCount: invoices.length,
      orderTotal: orderTotal,
      orderCount: orders.length,
      purchaseTotal: purchaseTotal,
      purchaseCount: purchases.length,
      expenseTotal: expenseTotal,
      expenseCount: expenses.length,
      firstActivity: first,
      lastActivity: last,
    );
  }

  /// One row per staff, with or without activity, then one per
  /// former staff with records in the period. Records without a
  /// staff are no one's row.
  static List<StaffReportRow> buildAll(StaffReportSlice slice) {
    final base = slice.base;
    final rows = <StaffReportRow>[];
    final known = <String>{};
    for (final u in base.staff) {
      final key = u.userId!;
      known.add(key);
      rows.add(build(key: key, user: u, slice: slice));
    }
    final former =
        slice.activeKeys
            .where((k) => !known.contains(k) && base.access.canSeeStaff(k))
            .toList()
          ..sort();
    for (final key in former) {
      rows.add(build(key: key, user: null, slice: slice));
    }
    return rows;
  }

  /// The row of [staffKey], as [buildAll] gives it. A former
  /// staff without records in the period gets a row of zeros.
  static StaffReportRow single({
    required String staffKey,
    required StaffReportSlice slice,
  }) {
    TempUserClass? user;
    for (final u in slice.base.staff) {
      if (u.userId == staffKey) {
        user = u;
        break;
      }
    }
    return build(key: staffKey, user: user, slice: slice);
  }
}

// ---------------------------------------------------------------
// Filters, options, sorting, totals and paging
// ---------------------------------------------------------------

class StaffReportFilterOption {
  final String key;
  final String label;

  const StaffReportFilterOption(this.key, this.label);
}

/// Role choices, from the staff in the report.
class StaffReportOptions {
  static List<StaffReportFilterOption> roles(List<StaffReportRow> rows) {
    final labels = <String, String>{};
    for (final r in rows) {
      labels.putIfAbsent(r.roleKey, () => r.roleLabel);
    }
    return labels.entries
        .map((e) => StaffReportFilterOption(e.key, e.value))
        .toList()
      ..sort((a, b) {
        final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
        return c != 0 ? c : a.key.compareTo(b.key);
      });
  }
}

/// All user-selectable filters, combined with AND.
class StaffReportFilters {
  String search;

  /// [StaffReportOptions.roles] key.
  String? roleKey;

  StaffReportFilters({this.search = '', this.roleKey});

  StaffReportFilters copy() =>
      StaffReportFilters(search: search, roleKey: roleKey);

  int get activeCount => roleKey != null ? 1 : 0;

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    roleKey = null;
  }

  bool matchesSearch(StaffReportRow r) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.name) || has(r.phone) || has(r.email) || has(r.roleLabel);
  }

  bool matches(StaffReportRow r) {
    if (!matchesSearch(r)) return false;
    if (roleKey != null && r.roleKey != roleKey) return false;
    return true;
  }
}

class StaffReportTotals {
  final int count;
  final double receiptSales;
  final int receiptCount;
  final double invoiceSales;
  final int invoiceCount;
  final double orderTotal;
  final int orderCount;
  final double purchaseTotal;
  final int purchaseCount;
  final double expenseTotal;
  final int expenseCount;

  const StaffReportTotals({
    required this.count,
    required this.receiptSales,
    required this.receiptCount,
    required this.invoiceSales,
    required this.invoiceCount,
    required this.orderTotal,
    required this.orderCount,
    required this.purchaseTotal,
    required this.purchaseCount,
    required this.expenseTotal,
    required this.expenseCount,
  });

  factory StaffReportTotals.of(Iterable<StaffReportRow> rows) {
    int count = 0;
    double receiptSales = 0;
    int receiptCount = 0;
    double invoiceSales = 0;
    int invoiceCount = 0;
    double orderTotal = 0;
    int orderCount = 0;
    double purchaseTotal = 0;
    int purchaseCount = 0;
    double expenseTotal = 0;
    int expenseCount = 0;
    for (final r in rows) {
      count++;
      receiptSales += r.receiptSales;
      receiptCount += r.receiptCount;
      invoiceSales += r.invoiceSales;
      invoiceCount += r.invoiceCount;
      orderTotal += r.orderTotal;
      orderCount += r.orderCount;
      purchaseTotal += r.purchaseTotal;
      purchaseCount += r.purchaseCount;
      expenseTotal += r.expenseTotal;
      expenseCount += r.expenseCount;
    }
    return StaffReportTotals(
      count: count,
      receiptSales: receiptSales,
      receiptCount: receiptCount,
      invoiceSales: invoiceSales,
      invoiceCount: invoiceCount,
      orderTotal: orderTotal,
      orderCount: orderCount,
      purchaseTotal: purchaseTotal,
      purchaseCount: purchaseCount,
      expenseTotal: expenseTotal,
      expenseCount: expenseCount,
    );
  }
}

class StaffReportPage {
  final List<StaffReportRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  /// Over the full filtered set, not just this page.
  final StaffReportTotals totals;

  const StaffReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totals,
  });

  int get firstIndex => totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + rows.length;
}

class StaffReportQuery {
  /// Null values always sink to the bottom, in both directions.
  static int cmp<T extends Comparable>(T? a, T? b, bool asc) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  /// First direction of a newly picked column: text A-Z; counts,
  /// amounts and dates largest / newest first.
  static bool defaultAscending(StaffReportSortField f) {
    switch (f) {
      case StaffReportSortField.name:
      case StaffReportSortField.role:
      case StaffReportSortField.phone:
        return true;
      default:
        return false;
    }
  }

  /// [sortField] when its column is visible, otherwise name.
  static StaffReportSortField visibleSort(
    StaffReportSortField sortField,
    StaffReportAccess access,
  ) {
    switch (sortField) {
      case StaffReportSortField.orderCount:
      case StaffReportSortField.orderTotal:
        return access.showOrders ? sortField : StaffReportSortField.name;
      case StaffReportSortField.purchaseCount:
      case StaffReportSortField.purchaseTotal:
        return access.showPurchases ? sortField : StaffReportSortField.name;
      case StaffReportSortField.expenseCount:
      case StaffReportSortField.expenseTotal:
        return access.showExpenses ? sortField : StaffReportSortField.name;
      default:
        return sortField;
    }
  }

  /// Search and filters, then sorted. The whole set is sorted
  /// before pagination.
  static List<StaffReportRow> filterAndSort({
    required List<StaffReportRow> rows,
    required StaffReportFilters filters,
    required StaffReportSortField sortField,
    required bool ascending,
    required StaffReportAccess access,
  }) {
    final out = rows.where(filters.matches).toList();
    final field = visibleSort(sortField, access);

    int compare(StaffReportRow a, StaffReportRow b) {
      final asc = ascending;
      int c;
      switch (field) {
        case StaffReportSortField.name:
          c = cmp(a.name.toLowerCase(), b.name.toLowerCase(), asc);
          break;
        case StaffReportSortField.role:
          c = cmp(a.roleLabel.toLowerCase(), b.roleLabel.toLowerCase(), asc);
          break;
        case StaffReportSortField.phone:
          c = cmp(a.phone, b.phone, asc);
          break;
        case StaffReportSortField.receiptSales:
          c = cmp(a.receiptSales, b.receiptSales, asc);
          break;
        case StaffReportSortField.invoiceSales:
          c = cmp(a.invoiceSales, b.invoiceSales, asc);
          break;
        case StaffReportSortField.orderCount:
          c = cmp(a.orderCount, b.orderCount, asc);
          break;
        case StaffReportSortField.orderTotal:
          c = cmp(a.orderTotal, b.orderTotal, asc);
          break;
        case StaffReportSortField.purchaseCount:
          c = cmp(a.purchaseCount, b.purchaseCount, asc);
          break;
        case StaffReportSortField.purchaseTotal:
          c = cmp(a.purchaseTotal, b.purchaseTotal, asc);
          break;
        case StaffReportSortField.expenseCount:
          c = cmp(a.expenseCount, b.expenseCount, asc);
          break;
        case StaffReportSortField.expenseTotal:
          c = cmp(a.expenseTotal, b.expenseTotal, asc);
          break;
        case StaffReportSortField.lastActivity:
          c = cmp(a.lastActivity, b.lastActivity, asc);
          break;
      }
      if (c != 0) return c;
      // Deterministic tie-breakers keep pagination stable.
      final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    out.sort(compare);
    return out;
  }

  static StaffReportPage paginate(
    List<StaffReportRow> sorted,
    int requestedPage, {
    int pageSize = staffReportPageSize,
  }) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: pageSize,
    );
    return StaffReportPage(
      rows: sorted.isEmpty ? <StaffReportRow>[] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      pageSize: pageSize,
      totalPages: b.pages,
      totals: StaffReportTotals.of(sorted),
    );
  }
}

String? _key(String? value) =>
    (value == null || value.trim().isEmpty) ? null : value;

String? _name(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
