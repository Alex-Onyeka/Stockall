import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

/// Page size, same as the other report tables.
const int customerReportPageSize = 100;

// ---------------------------------------------------------------
// Access: settings and permissions
// ---------------------------------------------------------------

/// Everything the customer report reads from the shop settings and
/// the user's permissions. The app builds it from the providers,
/// tests build it by hand.
///
/// Department and own-transactions rules are the Receipts Report's
/// ([ReceiptsReportAccess.scope]), applied to receipts, invoices,
/// orders and, as it has no department, the staff rule only to the
/// customer account ledger.
class CustomerReportAccess {
  final bool departmentsEnabled;
  final bool canViewAllDepartments;
  final String? currentDepartmentUuid;
  final bool canViewAllTransactions;
  final String? currentUserId;

  /// `TempShopClass.manageCustomerAccount`.
  final bool manageCustomerAccount;

  /// `TempShopClass.manageCustomerReward`.
  final bool manageCustomerReward;

  /// `Authorizations().viewCustomersAccount`.
  final bool canViewCustomersAccount;

  /// `Authorizations().viewDate`.
  final bool canPickDate;

  const CustomerReportAccess({
    required this.departmentsEnabled,
    required this.canViewAllDepartments,
    required this.currentDepartmentUuid,
    required this.canViewAllTransactions,
    required this.currentUserId,
    required this.manageCustomerAccount,
    required this.manageCustomerReward,
    required this.canViewCustomersAccount,
    required this.canPickDate,
  });

  /// Account balance column, KPI, section and table.
  bool get showAccount => manageCustomerAccount && canViewCustomersAccount;

  /// Reward earnings column, KPI, section and table.
  bool get showReward => manageCustomerReward && canViewCustomersAccount;

  /// Total balance adds the visible parts only.
  bool get showTotalBalance => showAccount || showReward;

  /// All time (loaded data) with the View Date permission,
  /// otherwise today: the period button is disabled without it.
  ReceiptsReportPeriod initialPeriod({DateTime? now, TimeOfDay? closingTime}) {
    return ReceiptsReportPeriod.today(now: now, closingTime: closingTime);
  }

  bool get _restrictDepartment =>
      departmentsEnabled &&
      (!canViewAllDepartments || currentDepartmentUuid != null);

  bool _allows(String? departmentUuid, String? staffId) {
    if (_restrictDepartment &&
        !reportDepartmentMatches(departmentUuid, currentDepartmentUuid)) {
      return false;
    }
    return _allowsStaff(staffId);
  }

  bool _allowsStaff(String? staffId) =>
      canViewAllTransactions || staffId == currentUserId;

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

  List<CustomerAccountReceipts> scopeLedger(
    List<CustomerAccountReceipts> entries,
  ) {
    return entries.where((e) => _allowsStaff(e.staffId)).toList();
  }
}

// ---------------------------------------------------------------
// Source data and the period-independent base
// ---------------------------------------------------------------

/// Loaded data, as the providers hold it. [customers] is already
/// department scoped (`CustomersProvider.customersMain()`).
class CustomerReportSource {
  final List<TempCustomersClass> customers;

  /// Every loaded receipt. Invoice and order payments are counted
  /// from all of them, as the Invoice and Order reports do.
  final List<TempMainReceipt> receipts;
  final List<TempProductSaleRecord> productSales;
  final List<TempInvoice> invoices;
  final List<Orders> orders;
  final List<CustomerAccountReceipts> ledger;

  /// Invoices and orders of other shops are left out, as their
  /// reports do. Null keeps them all.
  final int? shopId;

  const CustomerReportSource({
    required this.customers,
    required this.receipts,
    this.productSales = const [],
    this.invoices = const [],
    this.orders = const [],
    this.ledger = const [],
    this.shopId,
  });
}

/// Which side of the customer account a ledger entry is on.
enum CustomerLedgerKind { account, reward }

/// Earned / credited, or redeemed / deducted / debited.
enum CustomerLedgerDirection { added, deducted }

/// One `CustomerAccountReceipts` entry, as the two ledger tables
/// show it.
class CustomerLedgerRow {
  final CustomerAccountReceipts entry;
  final CustomerLedgerKind kind;

  /// Local time. Null only for malformed entries: those are shown
  /// for All time and sink to the bottom.
  final DateTime? createdAt;
  final String title;

  /// As stored, never negative in practice.
  final double amount;

  /// The receipt that wrote the entry, when it is loaded.
  final TempMainReceipt? receipt;

  /// `#barcode` of [receipt], if loaded.
  final String? receiptDisplayId;

  CustomerLedgerRow({
    required this.entry,
    required this.kind,
    required this.createdAt,
    required this.title,
    required this.amount,
    this.receipt,
  }) : receiptDisplayId =
           receipt == null ? null : ReceiptsReportRowBuilder.displayId(receipt);

  /// Null `isBalance` is the account, as the provider treats it.
  static CustomerLedgerKind kindOf(CustomerAccountReceipts e) =>
      e.isBalance == false
          ? CustomerLedgerKind.reward
          : CustomerLedgerKind.account;

  /// Same defaults as `createCustomerAccountReceipts`.
  static String defaultTitle(CustomerAccountReceipts e) {
    final reward = kindOf(e) == CustomerLedgerKind.reward;
    if (e.isAdd) return reward ? 'Reward Earned' : 'Account Credited';
    return reward ? 'Reward Deducted' : 'Account Debited';
  }

  factory CustomerLedgerRow.build(
    CustomerAccountReceipts entry, {
    TempMainReceipt? receipt,
  }) {
    final stored = entry.title?.trim();
    return CustomerLedgerRow(
      entry: entry,
      kind: kindOf(entry),
      createdAt: entry.createdAt?.toLocal(),
      title: (stored == null || stored.isEmpty) ? defaultTitle(entry) : stored,
      amount: entry.amount ?? 0,
      receipt: receipt,
    );
  }

  String get uuid => entry.uuid ?? '';
  String? get customerKey => _key(entry.customerUuid);
  bool get isAdd => entry.isAdd;
  CustomerLedgerDirection get direction =>
      isAdd ? CustomerLedgerDirection.added : CustomerLedgerDirection.deducted;
  double get signedAmount => isAdd ? amount : -amount;
  double? get oldBalance => entry.oldBalance;
  double? get newBalance => entry.newBalance;
  String? get staffKey => _key(entry.staffId);
  String? get staffName => _name(entry.staffName);
  String? get comment => _name(entry.comment);
  String? get receiptUuid => _key(entry.receiptUuid);

  bool inPeriod(ReceiptsReportPeriod period, {TimeOfDay? closingTime}) {
    if (period.isAllTime) return true;
    final at = createdAt;
    return at != null && period.contains(at, closingTime: closingTime);
  }
}

/// Report rows built once from the loaded data and the user's
/// scope, before any period. Only records with a customer are kept:
/// each row is built on its own, so this changes no customer's
/// numbers.
class CustomerReportBase {
  final CustomerReportAccess access;
  final List<TempCustomersClass> customers;
  final List<ReceiptsReportRow> receiptRows;
  final List<InvoiceReportRow> invoiceRows;
  final List<OrderReportRow> orderRows;

  /// Only the kinds the user may see ([CustomerReportAccess]).
  final List<CustomerLedgerRow> ledgerRows;

  const CustomerReportBase({
    required this.access,
    required this.customers,
    required this.receiptRows,
    required this.invoiceRows,
    required this.orderRows,
    required this.ledgerRows,
  });

  factory CustomerReportBase.build({
    required CustomerReportSource source,
    required CustomerReportAccess access,
  }) {
    bool hasCustomer(String? key) => _key(key) != null;
    final shopId = source.shopId;

    final receipts =
        access
            .scopeReceipts(source.receipts)
            .where((r) => hasCustomer(r.customerUuid))
            .toList();
    final receiptRows = ReceiptsReportRowBuilder.buildAll(
      receipts: receipts,
      legacySales: source.productSales,
    );

    final invoices =
        access
            .scopeInvoices(
              source.invoices
                  .where((i) => shopId == null || i.shopId == shopId)
                  .toList(),
            )
            .where((i) => hasCustomer(i.customerUuid))
            .toList();
    final invoiceRows = InvoiceReportRowBuilder.buildAll(
      invoices: invoices,
      allReceipts: source.receipts,
      allProductSales: source.productSales,
      customerMap: {
        for (final c in source.customers)
          if (_key(c.uuid) != null) c.uuid!: c,
      },
    );

    final orders =
        access
            .scopeOrders(
              source.orders
                  .where((o) => shopId == null || o.shopId == shopId)
                  .toList(),
            )
            .where((o) => hasCustomer(o.customerId))
            .toList();
    final orderRows = OrderReportRowBuilder.buildAll(
      orders: orders,
      allReceipts: source.receipts,
      allProductSales: source.productSales,
    );

    final ledgerRows = <CustomerLedgerRow>[];
    if (access.showAccount || access.showReward) {
      final receiptsByUuid = <String, TempMainReceipt>{
        for (final r in source.receipts)
          if (_key(r.uuid) != null) r.uuid!: r,
      };
      for (final e in access.scopeLedger(source.ledger)) {
        if (!hasCustomer(e.customerUuid)) continue;
        final kind = CustomerLedgerRow.kindOf(e);
        if (kind == CustomerLedgerKind.account && !access.showAccount) {
          continue;
        }
        if (kind == CustomerLedgerKind.reward && !access.showReward) {
          continue;
        }
        ledgerRows.add(
          CustomerLedgerRow.build(e, receipt: receiptsByUuid[e.receiptUuid]),
        );
      }
    }

    return CustomerReportBase(
      access: access,
      customers: source.customers,
      receiptRows: receiptRows,
      invoiceRows: invoiceRows,
      orderRows: orderRows,
      ledgerRows: ledgerRows,
    );
  }
}

// ---------------------------------------------------------------
// Period slice: each report's own query, grouped by customer
// ---------------------------------------------------------------

/// [period] as the Invoice Report table takes it
/// (`InvoiceReportFilters.dateRange`). All time is null.
DateTimeRange? customerReportDateRange(ReceiptsReportPeriod period) {
  if (period.isAllTime) return null;
  return DateTimeRange(start: period.start!, end: period.end!);
}

/// The base rows in one period, grouped by customer uuid, newest
/// first. Each report's own query selects the rows with no filter
/// other than the period, so a customer's group is exactly what
/// that report shows when filtered to the customer.
///
/// [closingTime] reaches the receipts, orders and ledger. The
/// Invoice Report query has no such parameter and always uses the
/// shop's closing time, which is also what the others use when
/// [closingTime] is null, as in the app.
class CustomerReportSlice {
  final CustomerReportBase base;
  final ReceiptsReportPeriod period;
  final Map<String, List<ReceiptsReportRow>> receipts;
  final Map<String, List<InvoiceReportRow>> invoices;
  final Map<String, List<OrderReportRow>> orders;
  final Map<String, List<CustomerLedgerRow>> rewards;
  final Map<String, List<CustomerLedgerRow>> accountTransactions;

  const CustomerReportSlice._({
    required this.base,
    required this.period,
    required this.receipts,
    required this.invoices,
    required this.orders,
    required this.rewards,
    required this.accountTransactions,
  });

  factory CustomerReportSlice.of(
    CustomerReportBase base,
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

    final ledger =
        base.ledgerRows
            .where((r) => r.inPeriod(period, closingTime: closingTime))
            .toList()
          ..sort(CustomerLedgerQuery.newestFirst);

    final rewards = <String, List<CustomerLedgerRow>>{};
    final account = <String, List<CustomerLedgerRow>>{};
    for (final r in ledger) {
      final target = r.kind == CustomerLedgerKind.reward ? rewards : account;
      (target[r.customerKey!] ??= []).add(r);
    }

    return CustomerReportSlice._(
      base: base,
      period: period,
      receipts: _group(receiptRows, (r) => r.customerKey),
      invoices: _group(invoiceRows, (r) => _key(r.invoice.customerUuid)),
      orders: _group(orderRows, (r) => r.customerKey),
      rewards: rewards,
      accountTransactions: account,
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

  List<ReceiptsReportRow> receiptsOf(String? customerUuid) =>
      receipts[customerUuid] ?? const [];
  List<InvoiceReportRow> invoicesOf(String? customerUuid) =>
      invoices[customerUuid] ?? const [];
  List<OrderReportRow> ordersOf(String? customerUuid) =>
      orders[customerUuid] ?? const [];
  List<CustomerLedgerRow> rewardsOf(String? customerUuid) =>
      rewards[customerUuid] ?? const [];
  List<CustomerLedgerRow> accountTransactionsOf(String? customerUuid) =>
      accountTransactions[customerUuid] ?? const [];
}

// ---------------------------------------------------------------
// Customer rows
// ---------------------------------------------------------------

enum CustomerReportSortField {
  name,
  phone,
  location,
  accountBalance,
  rewardEarnings,
  totalBalance,
  receiptPurchases,
  invoicePurchases,
  revenue,
  credit,
}

/// One customer in one period. Every value is calculated once,
/// when the row is built.
class CustomerReportRow {
  final TempCustomersClass customer;

  /// Current balances, as the customer details page shows them.
  /// The period does not change them.
  final double accountBalance;
  final double rewardEarnings;

  /// Account + reward, the visible parts only.
  final double totalBalance;

  /// Revenue of Sales receipts: the Receipts table with
  /// Customer = this customer and Type = Sales.
  final double receiptPurchases;

  /// Sum of invoice totals: the Invoice table's total for this
  /// customer.
  final double invoicePurchases;

  /// Revenue of every receipt type (cash + bank + customer
  /// account, VAT included): the Receipts table's total for this
  /// customer.
  final double revenue;

  /// What the customer owes: the Invoice table's balance total for
  /// this customer.
  final double credit;

  /// Receipts of every type, as the Receipts table counts them.
  final int receiptCount;
  final int salesReceiptCount;
  final int invoiceCount;
  final int orderCount;

  /// Order Report totals for this customer.
  final double orderTotal;
  final double orderPaid;
  final double orderBalance;

  /// Earliest and latest Sales receipt, invoice or order.
  final DateTime? firstPurchase;
  final DateTime? lastPurchase;

  CustomerReportRow({
    required this.customer,
    required this.accountBalance,
    required this.rewardEarnings,
    required this.totalBalance,
    required this.receiptPurchases,
    required this.invoicePurchases,
    required this.revenue,
    required this.credit,
    required this.receiptCount,
    required this.salesReceiptCount,
    required this.invoiceCount,
    required this.orderCount,
    required this.orderTotal,
    required this.orderPaid,
    required this.orderBalance,
    required this.firstPurchase,
    required this.lastPurchase,
  });

  String get uuid => customer.uuid ?? '';
  String get name => _name(customer.name) ?? 'Not Set';
  String? get phone => _name(customer.phone);
  String? get email => _name(customer.email);
  String? get address => _name(customer.address);
  String? get city => _name(customer.city);
  String? get state => _name(customer.state);
  String? get country => _name(customer.country);

  /// Address, city, state and country as stored, comma separated.
  String? get locationLabel {
    final parts = [address, city, state, country].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get countryKey => _locationKey(customer.country);
  String? get stateKey => _locationKey(customer.state);

  bool get hasCredit => credit > 0;
  bool get hasAccountBalance => accountBalance > 0;
}

class CustomerReportRowBuilder {
  static CustomerReportRow build({
    required TempCustomersClass customer,
    required CustomerReportSlice slice,
  }) {
    final access = slice.base.access;
    final key = _key(customer.uuid);
    final receipts = slice.receiptsOf(key);
    final invoices = slice.invoicesOf(key);
    final orders = slice.ordersOf(key);

    double revenue = 0;
    double receiptPurchases = 0;
    int salesCount = 0;
    DateTime? first;
    DateTime? last;
    void seen(DateTime at) {
      if (first == null || at.isBefore(first!)) first = at;
      if (last == null || at.isAfter(last!)) last = at;
    }

    for (final r in receipts) {
      revenue += r.revenue;
      if (r.type == ReceiptType.sales) {
        receiptPurchases += r.revenue;
        salesCount++;
        seen(r.createdAt);
      }
    }

    double invoicePurchases = 0;
    double credit = 0;
    for (final r in invoices) {
      invoicePurchases += r.invoiceTotal ?? 0;
      credit += r.balance ?? 0;
      seen(r.createdAt.toLocal());
    }

    double orderTotal = 0;
    double orderPaid = 0;
    double orderBalance = 0;
    for (final r in orders) {
      orderTotal += r.total;
      orderPaid += r.paid;
      orderBalance += r.balance;
      seen(r.createdAt);
    }

    final account = customer.balance ?? 0;
    final reward = customer.cashReward ?? 0;
    return CustomerReportRow(
      customer: customer,
      accountBalance: account,
      rewardEarnings: reward,
      totalBalance:
          (access.showAccount ? account : 0) + (access.showReward ? reward : 0),
      receiptPurchases: receiptPurchases,
      invoicePurchases: invoicePurchases,
      revenue: revenue,
      credit: credit,
      receiptCount: receipts.length,
      salesReceiptCount: salesCount,
      invoiceCount: invoices.length,
      orderCount: orders.length,
      orderTotal: orderTotal,
      orderPaid: orderPaid,
      orderBalance: orderBalance,
      firstPurchase: first,
      lastPurchase: last,
    );
  }

  /// One row per customer, with or without activity.
  static List<CustomerReportRow> buildAll(CustomerReportSlice slice) {
    return [
      for (final c in slice.base.customers) build(customer: c, slice: slice),
    ];
  }
}

// ---------------------------------------------------------------
// Filters, options, sorting, totals and paging
// ---------------------------------------------------------------

class CustomerReportFilterOption {
  final String key;
  final String label;

  const CustomerReportFilterOption(this.key, this.label);
}

/// Country and state choices, from the customers in the report.
/// Spelling and case differences of one place share a choice.
class CustomerReportOptions {
  static List<CustomerReportFilterOption> _build(
    List<CustomerReportRow> rows,
    String? Function(CustomerReportRow) value,
  ) {
    final labels = <String, String>{};
    for (final r in rows) {
      final label = _name(value(r));
      if (label == null) continue;
      labels.putIfAbsent(label.toLowerCase(), () => label);
    }
    return labels.entries
        .map((e) => CustomerReportFilterOption(e.key, e.value))
        .toList()
      ..sort((a, b) {
        final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
        return c != 0 ? c : a.key.compareTo(b.key);
      });
  }

  static List<CustomerReportFilterOption> countries(
    List<CustomerReportRow> rows,
  ) => _build(rows, (r) => r.country);

  /// States of [countryKey] only, when one is chosen.
  static List<CustomerReportFilterOption> states(
    List<CustomerReportRow> rows, {
    String? countryKey,
  }) => _build(
    countryKey == null
        ? rows
        : rows.where((r) => r.countryKey == countryKey).toList(),
    (r) => r.state,
  );
}

/// All user-selectable filters, combined with AND.
class CustomerReportFilters {
  String search;

  /// [CustomerReportOptions] keys.
  String? countryKey;
  String? stateKey;
  bool hasCredit;

  /// Applied only while account balances are visible.
  bool hasAccountBalance;

  CustomerReportFilters({
    this.search = '',
    this.countryKey,
    this.stateKey,
    this.hasCredit = false,
    this.hasAccountBalance = false,
  });

  CustomerReportFilters copy() => CustomerReportFilters(
    search: search,
    countryKey: countryKey,
    stateKey: stateKey,
    hasCredit: hasCredit,
    hasAccountBalance: hasAccountBalance,
  );

  int activeCount({required bool showAccount}) =>
      (countryKey != null ? 1 : 0) +
      (stateKey != null ? 1 : 0) +
      (hasCredit ? 1 : 0) +
      (showAccount && hasAccountBalance ? 1 : 0);

  bool hasAnything({required bool showAccount}) =>
      activeCount(showAccount: showAccount) > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    countryKey = null;
    stateKey = null;
    hasCredit = false;
    hasAccountBalance = false;
  }

  bool matchesSearch(CustomerReportRow r) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.name) ||
        has(r.phone) ||
        has(r.email) ||
        has(r.address) ||
        has(r.city) ||
        has(r.state) ||
        has(r.country);
  }

  bool matches(CustomerReportRow r, {required bool showAccount}) {
    if (!matchesSearch(r)) return false;
    if (countryKey != null && r.countryKey != countryKey) {
      return false;
    }
    if (stateKey != null && r.stateKey != stateKey) return false;
    if (hasCredit && !r.hasCredit) return false;
    if (showAccount && hasAccountBalance && !r.hasAccountBalance) {
      return false;
    }
    return true;
  }
}

class CustomerReportTotals {
  final int count;
  final double accountBalance;
  final double rewardEarnings;
  final double totalBalance;
  final double receiptPurchases;
  final double invoicePurchases;
  final double revenue;
  final double credit;

  const CustomerReportTotals({
    required this.count,
    required this.accountBalance,
    required this.rewardEarnings,
    required this.totalBalance,
    required this.receiptPurchases,
    required this.invoicePurchases,
    required this.revenue,
    required this.credit,
  });

  factory CustomerReportTotals.of(Iterable<CustomerReportRow> rows) {
    int count = 0;
    double account = 0;
    double reward = 0;
    double total = 0;
    double receipts = 0;
    double invoices = 0;
    double revenue = 0;
    double credit = 0;
    for (final r in rows) {
      count++;
      account += r.accountBalance;
      reward += r.rewardEarnings;
      total += r.totalBalance;
      receipts += r.receiptPurchases;
      invoices += r.invoicePurchases;
      revenue += r.revenue;
      credit += r.credit;
    }
    return CustomerReportTotals(
      count: count,
      accountBalance: account,
      rewardEarnings: reward,
      totalBalance: total,
      receiptPurchases: receipts,
      invoicePurchases: invoices,
      revenue: revenue,
      credit: credit,
    );
  }
}

class CustomerReportPage {
  final List<CustomerReportRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  /// Over the full filtered set, not just this page.
  final CustomerReportTotals totals;

  const CustomerReportPage({
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

class CustomerReportQuery {
  static int _cmp<T extends Comparable>(T? a, T? b, bool asc) {
    // Null values always sink to the bottom, in both directions.
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  /// [sortField] when its column is visible, otherwise name.
  static CustomerReportSortField visibleSort(
    CustomerReportSortField sortField,
    CustomerReportAccess access,
  ) {
    switch (sortField) {
      case CustomerReportSortField.accountBalance:
        return access.showAccount ? sortField : CustomerReportSortField.name;
      case CustomerReportSortField.rewardEarnings:
        return access.showReward ? sortField : CustomerReportSortField.name;
      case CustomerReportSortField.totalBalance:
        return access.showTotalBalance
            ? sortField
            : CustomerReportSortField.name;
      default:
        return sortField;
    }
  }

  /// Search and filters, then sorted. The whole set is sorted
  /// before pagination.
  static List<CustomerReportRow> filterAndSort({
    required List<CustomerReportRow> rows,
    required CustomerReportFilters filters,
    required CustomerReportSortField sortField,
    required bool ascending,
    required CustomerReportAccess access,
  }) {
    final out =
        rows
            .where((r) => filters.matches(r, showAccount: access.showAccount))
            .toList();
    final field = visibleSort(sortField, access);

    int compare(CustomerReportRow a, CustomerReportRow b) {
      final asc = ascending;
      int c;
      switch (field) {
        case CustomerReportSortField.name:
          c = _cmp(a.name.toLowerCase(), b.name.toLowerCase(), asc);
          break;
        case CustomerReportSortField.phone:
          c = _cmp(a.phone, b.phone, asc);
          break;
        case CustomerReportSortField.location:
          c = _cmp(
            a.locationLabel?.toLowerCase(),
            b.locationLabel?.toLowerCase(),
            asc,
          );
          break;
        case CustomerReportSortField.accountBalance:
          c = _cmp(a.accountBalance, b.accountBalance, asc);
          break;
        case CustomerReportSortField.rewardEarnings:
          c = _cmp(a.rewardEarnings, b.rewardEarnings, asc);
          break;
        case CustomerReportSortField.totalBalance:
          c = _cmp(a.totalBalance, b.totalBalance, asc);
          break;
        case CustomerReportSortField.receiptPurchases:
          c = _cmp(a.receiptPurchases, b.receiptPurchases, asc);
          break;
        case CustomerReportSortField.invoicePurchases:
          c = _cmp(a.invoicePurchases, b.invoicePurchases, asc);
          break;
        case CustomerReportSortField.revenue:
          c = _cmp(a.revenue, b.revenue, asc);
          break;
        case CustomerReportSortField.credit:
          c = _cmp(a.credit, b.credit, asc);
          break;
      }
      if (c != 0) return c;
      // Deterministic tie-breakers keep pagination stable.
      final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return n != 0 ? n : a.uuid.compareTo(b.uuid);
    }

    out.sort(compare);
    return out;
  }

  static CustomerReportPage paginate(
    List<CustomerReportRow> sorted,
    int requestedPage, {
    int pageSize = customerReportPageSize,
  }) {
    final total = sorted.length;
    final pages = total == 0 ? 1 : (total / pageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * pageSize;
    final end = math.min(start + pageSize, total);
    return CustomerReportPage(
      rows: total == 0 ? <CustomerReportRow>[] : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      pageSize: pageSize,
      totalPages: pages,
      totals: CustomerReportTotals.of(sorted),
    );
  }
}

// ---------------------------------------------------------------
// Ledger tables (reward earnings, account transactions)
// ---------------------------------------------------------------

enum CustomerLedgerSortField {
  createdAt,
  title,
  direction,
  amount,
  oldBalance,
  newBalance,
  staff,
  comment,
  receipt,
}

/// Staff choices, taken from the entries in the table. Each staff
/// id shows its newest name.
class CustomerLedgerOptions {
  static List<CustomerReportFilterOption> staff(List<CustomerLedgerRow> rows) {
    final newestFirst = List<CustomerLedgerRow>.from(rows)
      ..sort(CustomerLedgerQuery.newestFirst);
    final labels = <String, String>{};
    for (final r in newestFirst) {
      final k = r.staffKey;
      if (k == null) continue;
      labels.putIfAbsent(k, () => r.staffName ?? 'Not Set');
    }
    return labels.entries
        .map((e) => CustomerReportFilterOption(e.key, e.value))
        .toList()
      ..sort((a, b) {
        final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
        return c != 0 ? c : a.key.compareTo(b.key);
      });
  }
}

class CustomerLedgerFilters {
  String search;
  CustomerLedgerDirection? direction;

  /// `CustomerAccountReceipts.staffId`.
  String? staffKey;

  /// On the unsigned amount.
  double? amountMin;
  double? amountMax;

  CustomerLedgerFilters({
    this.search = '',
    this.direction,
    this.staffKey,
    this.amountMin,
    this.amountMax,
  });

  CustomerLedgerFilters copy() => CustomerLedgerFilters(
    search: search,
    direction: direction,
    staffKey: staffKey,
    amountMin: amountMin,
    amountMax: amountMax,
  );

  /// Message for a min above its max, otherwise null.
  String? get amountRangeError =>
      (amountMin != null && amountMax != null && amountMin! > amountMax!)
          ? 'Minimum cannot be more than maximum'
          : null;

  int get activeCount =>
      (direction != null ? 1 : 0) +
      (staffKey != null ? 1 : 0) +
      (amountMin != null || amountMax != null ? 1 : 0);

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    direction = null;
    staffKey = null;
    amountMin = null;
    amountMax = null;
  }

  bool matches(CustomerLedgerRow r) {
    if (direction != null && r.direction != direction) return false;
    if (staffKey != null && r.staffKey != staffKey) return false;
    // An invalid range is not applied.
    if (amountRangeError == null) {
      if (amountMin != null && r.amount < amountMin!) return false;
      if (amountMax != null && r.amount > amountMax!) return false;
    }
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.title) ||
        has(r.comment) ||
        has(r.staffName) ||
        has(r.receiptDisplayId);
  }
}

class CustomerLedgerTotals {
  final int count;

  /// Earned / credited.
  final double added;

  /// Redeemed or deducted / debited.
  final double deducted;

  const CustomerLedgerTotals({
    required this.count,
    required this.added,
    required this.deducted,
  });

  double get net => added - deducted;

  factory CustomerLedgerTotals.of(Iterable<CustomerLedgerRow> rows) {
    int count = 0;
    double added = 0;
    double deducted = 0;
    for (final r in rows) {
      count++;
      if (r.isAdd) {
        added += r.amount;
      } else {
        deducted += r.amount;
      }
    }
    return CustomerLedgerTotals(count: count, added: added, deducted: deducted);
  }
}

class CustomerLedgerPage {
  final List<CustomerLedgerRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  /// Over the full filtered set, not just this page.
  final CustomerLedgerTotals totals;

  const CustomerLedgerPage({
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

class CustomerLedgerQuery {
  /// Newest first; undated entries last.
  static int newestFirst(CustomerLedgerRow a, CustomerLedgerRow b) {
    final c = CustomerReportQuery._cmp(a.createdAt, b.createdAt, false);
    return c != 0 ? c : a.uuid.compareTo(b.uuid);
  }

  /// One customer's entries of one [kind], in [period], then
  /// search and filters, then sorted.
  static List<CustomerLedgerRow> filterAndSort({
    required CustomerReportBase base,
    required String customerUuid,
    required CustomerLedgerKind kind,
    required ReceiptsReportPeriod period,
    required CustomerLedgerFilters filters,
    required CustomerLedgerSortField sortField,
    required bool ascending,
    TimeOfDay? closingTime,
  }) {
    final out =
        base.ledgerRows
            .where(
              (r) =>
                  r.kind == kind &&
                  r.customerKey == customerUuid &&
                  r.inPeriod(period, closingTime: closingTime) &&
                  filters.matches(r),
            )
            .toList();

    int compare(CustomerLedgerRow a, CustomerLedgerRow b) {
      final asc = ascending;
      int c;
      switch (sortField) {
        case CustomerLedgerSortField.createdAt:
          c = CustomerReportQuery._cmp(a.createdAt, b.createdAt, asc);
          break;
        case CustomerLedgerSortField.title:
          c = CustomerReportQuery._cmp(
            a.title.toLowerCase(),
            b.title.toLowerCase(),
            asc,
          );
          break;
        case CustomerLedgerSortField.amount:
          c = CustomerReportQuery._cmp(a.signedAmount, b.signedAmount, asc);
          break;
        case CustomerLedgerSortField.direction:
          c = CustomerReportQuery._cmp(
            a.direction.index,
            b.direction.index,
            asc,
          );
          break;
        case CustomerLedgerSortField.oldBalance:
          c = CustomerReportQuery._cmp(a.oldBalance, b.oldBalance, asc);
          break;
        case CustomerLedgerSortField.newBalance:
          c = CustomerReportQuery._cmp(a.newBalance, b.newBalance, asc);
          break;
        case CustomerLedgerSortField.staff:
          c = CustomerReportQuery._cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            asc,
          );
          break;
        case CustomerLedgerSortField.comment:
          c = CustomerReportQuery._cmp(
            a.comment?.toLowerCase(),
            b.comment?.toLowerCase(),
            asc,
          );
          break;
        case CustomerLedgerSortField.receipt:
          c = CustomerReportQuery._cmp(
            a.receiptDisplayId,
            b.receiptDisplayId,
            asc,
          );
          break;
      }
      return c != 0 ? c : newestFirst(a, b);
    }

    out.sort(compare);
    return out;
  }

  static CustomerLedgerPage paginate(
    List<CustomerLedgerRow> sorted,
    int requestedPage, {
    int pageSize = customerReportPageSize,
  }) {
    final total = sorted.length;
    final pages = total == 0 ? 1 : (total / pageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * pageSize;
    final end = math.min(start + pageSize, total);
    return CustomerLedgerPage(
      rows: total == 0 ? <CustomerLedgerRow>[] : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      pageSize: pageSize,
      totalPages: pages,
      totals: CustomerLedgerTotals.of(sorted),
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

String? _locationKey(String? value) => _name(value)?.toLowerCase();
