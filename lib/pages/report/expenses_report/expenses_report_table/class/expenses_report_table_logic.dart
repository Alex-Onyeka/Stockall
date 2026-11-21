import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

// Expenses Report table: one row per expense, with its category,
// staff, staff paid (salaries), payment channel and sub-expense
// lines.
//
// Stock Purchase expenses are the payments of purchases, already
// counted under purchases and in gross profit's cost. They are shown
// (as on the Expenses page) but left out of Total Expenses, so the
// report's total equals the General Report's and the dashboard's.
//
// Sub-expense lines are a breakdown of their expense: the expense's
// amount already includes them, so they never enter a total.

/// Page size, same as the other report tables.
const int expensesReportPageSize = 100;

/// Filter key of the rows without a value (no staff, no staff paid,
/// no department).
const String expensesReportNoneKey = '__none__';

const String expensesNoStaffLabel = 'No staff';
const String expensesNoPaidStaffLabel = 'No staff paid';
const String expensesNoDepartmentLabel = 'No Department';

/// Category filter keys. System categories use their
/// [ExpenseType]; a custom category uses its uuid, or its saved name
/// once the category was deleted (the uuid is cleared then).
class ExpenseCategoryKey {
  static const String customPrefix = 'custom:';
  static const String customNamePrefix = 'custom-name:';

  static String of(TempExpensesClass e) {
    if (e.isCustomCategory) {
      final uuid = e.expenseCategoryUuid?.trim();
      if (uuid != null && uuid.isNotEmpty) return '$customPrefix$uuid';
      final name = e.expenseCategoryName?.trim().toLowerCase() ?? '';
      return '$customNamePrefix$name';
    }
    if (ExpenseType.systemTypes.contains(e.expenseType)) {
      return e.expenseType;
    }
    // Unknown types are read as Simple Expenses, as their label.
    return ExpenseType.simpleExpense;
  }

  static String forCategory(ExpenseCategory c) => '$customPrefix${c.uuid}';

  static bool isCustom(String key) =>
      key.startsWith(customPrefix) || key.startsWith(customNamePrefix);

  /// Simple, Salary, Stock Purchase, then custom categories.
  static int systemOrder(String key) {
    final i = ExpenseType.systemTypes.indexOf(key);
    return i < 0 ? ExpenseType.systemTypes.length : i;
  }
}

/// "2 Bags", "1.5", or null when not set. The table, the sub-expense
/// lines and the export use it.
String? expenseQuantityLabel(double? quantity, String? unit) {
  if (quantity == null) return null;
  final n =
      quantity == quantity.roundToDouble()
          ? quantity.toStringAsFixed(0)
          : '$quantity';
  final u = _name(unit);
  return u == null ? n : '$n $u';
}

/// The notes under the toolbar, worded the same on the screen and in
/// the export. [totals] are the filtered set's.
List<String> expensesReportNotes({
  required ReceiptsReportPeriod period,
  required ExpensesReportTotals totals,
  required String Function(num amount) money,
}) => [
  if (period.isAllTime) 'All time covers the expenses loaded on this device.',
  if (totals.stockPurchaseCount > 0)
    'Stock purchase payments (${totals.stockPurchaseCount}): '
        '${money(totals.stockPurchaseTotal)}, shown but not counted in '
        'Total Expenses (they are counted under purchases).',
];

// ---------------------------------------------------------------
// Access
// ---------------------------------------------------------------

/// Settings and permissions the report reads. The app builds it from
/// the providers, tests build it by hand.
class ExpensesReportAccess {
  final bool departmentsEnabled;
  final bool canViewAllDepartments;
  final String? currentDepartmentUuid;

  /// `Authorizations().viewAllTransactionRecords`. Without it the
  /// user sees only the expenses they created.
  final bool canViewAllTransactions;
  final String? currentUserId;

  /// `Authorizations().viewDate`: range and All time.
  final bool canPickDate;

  /// Expenses of other shops are left out. Null keeps them all.
  final int? shopId;

  const ExpensesReportAccess({
    required this.departmentsEnabled,
    required this.canViewAllDepartments,
    required this.currentDepartmentUuid,
    required this.canViewAllTransactions,
    required this.currentUserId,
    required this.canPickDate,
    this.shopId,
  });

  /// Today's business day, as the Purchase and Receipts reports.
  ReceiptsReportPeriod initialPeriod({DateTime? now, TimeOfDay? closingTime}) =>
      ReceiptsReportPeriod.today(now: now, closingTime: closingTime);

  /// The General Report's rule (department, then own records), so
  /// both reports see the same expenses.
  List<TempExpensesClass> scope(List<TempExpensesClass> expenses) {
    return GeneralReportExpenses.scope(
      expenses:
          shopId == null
              ? expenses
              : expenses.where((e) => e.shopId == shopId).toList(),
      departmentsEnabled: departmentsEnabled,
      canViewAllDepartments: canViewAllDepartments,
      currentDepartmentUuid: currentDepartmentUuid,
      canViewAllTransactions: canViewAllTransactions,
      currentUserId: currentUserId,
    );
  }
}

// ---------------------------------------------------------------
// Rows
// ---------------------------------------------------------------

/// One expense. Every value is calculated once, when the row is
/// built.
class ExpensesReportRow {
  final TempExpensesClass expense;

  /// Local time. Null only for malformed expenses: those are shown
  /// for All time and sink to the bottom.
  final DateTime? createdAt;

  /// [ExpenseCategoryKey.of].
  final String categoryKey;

  /// The custom category's current name when it still exists.
  final String categoryLabel;

  /// Current name of the staff paid (salaries), else the saved one.
  final String? paidStaffName;

  /// Cash, a bank name, or Split ([TempExpensesClass.resolvedPaymentChannelLabel]).
  final String channelLabel;

  ExpensesReportRow({
    required this.expense,
    required this.categoryLabel,
    required this.paidStaffName,
  }) : createdAt = expense.createdDate?.toLocal(),
       categoryKey = ExpenseCategoryKey.of(expense),
       channelLabel = expense.resolvedPaymentChannelLabel;

  String get uuid => expense.uuid ?? '';
  String get name => _name(expense.name) ?? 'Not Set';
  String? get description => _name(expense.description);
  double? get quantity => expense.quantity;
  String? get unit => _name(expense.unit);
  String? get quantityLabel => expenseQuantityLabel(quantity, unit);
  double get amount => expense.amount;

  /// The staff who recorded it (`userId`, `creator`).
  String? get staffKey => _key(expense.userId);
  String? get staffName => _name(expense.creator) ?? _name(expense.userName);
  String get staffLabel => staffName ?? 'Not Set';

  /// Salaries only.
  String? get paidStaffKey => isStaffSalary ? _key(expense.staffUuid) : null;
  String get paidStaffLabel => paidStaffName ?? '—';

  /// Case-insensitive, so "gtbank" and "GTBank" share a filter.
  String get channelKey => channelLabel.trim().toLowerCase();

  String? get departmentKey => _key(expense.departmentUuid)?.trim();
  String? get departmentName => _name(expense.departmentName);
  String get departmentLabel =>
      departmentKey == null
          ? expensesNoDepartmentLabel
          : (departmentName ?? 'Not Set');

  bool get isStaffSalary => expense.isStaffSalary;
  bool get isStockPurchase => expense.isStockPurchase;

  /// False for Stock Purchase expenses (see the file comment).
  bool get countsInTotal => !isStockPurchase;

  List<SubExpense> get lines =>
      expense.subExpenses ?? const <SubExpense>[];
  int get lineCount => lines.length;
  bool get hasLines => expense.hasSubExpenses;

  /// The lines no longer add up to [amount].
  bool get linesMismatch => expense.subExpensesMismatch;

  bool inPeriod(ReceiptsReportPeriod period, {TimeOfDay? closingTime}) {
    if (period.isAllTime) return true;
    final at = createdAt;
    return at != null && period.contains(at, closingTime: closingTime);
  }

  /// Newest first; undated expenses last.
  static int newestFirst(ExpensesReportRow a, ExpensesReportRow b) {
    final c = ExpensesReportQuery.cmp(a.createdAt, b.createdAt, false);
    return c != 0 ? c : a.uuid.compareTo(b.uuid);
  }
}

class ExpensesReportRowBuilder {
  /// [expenses] already scoped ([ExpensesReportAccess.scope]).
  /// [categories] give custom categories their current names;
  /// [staffNames] (user id -> full name) the staff paid theirs.
  static List<ExpensesReportRow> buildAll({
    required List<TempExpensesClass> expenses,
    List<ExpenseCategory> categories = const [],
    Map<String, String> staffNames = const {},
  }) {
    return [
      for (final e in expenses)
        ExpensesReportRow(
          expense: e,
          categoryLabel: e.categoryLabelWith(categories),
          paidStaffName:
              e.isStaffSalary
                  ? (staffNames[_key(e.staffUuid)] ?? _name(e.staffName))
                  : null,
        ),
    ];
  }
}

// ---------------------------------------------------------------
// Filters and options
// ---------------------------------------------------------------

/// All user-selectable filters, combined with AND. Keys are the row
/// keys or [expensesReportNoneKey], so an analysis row can open the
/// table on exactly its expenses.
class ExpensesReportFilters {
  String search;

  /// [ExpenseCategoryKey.of].
  String? categoryKey;
  String? staffKey;
  String? paidStaffKey;

  /// [ExpensesReportRow.channelKey].
  String? channelKey;
  String? departmentKey;

  /// True: only expenses with sub-expenses; false: only without.
  bool? hasLines;
  double? amountMin;
  double? amountMax;

  ExpensesReportFilters({
    this.search = '',
    this.categoryKey,
    this.staffKey,
    this.paidStaffKey,
    this.channelKey,
    this.departmentKey,
    this.hasLines,
    this.amountMin,
    this.amountMax,
  });

  ExpensesReportFilters copy() => ExpensesReportFilters(
    search: search,
    categoryKey: categoryKey,
    staffKey: staffKey,
    paidStaffKey: paidStaffKey,
    channelKey: channelKey,
    departmentKey: departmentKey,
    hasLines: hasLines,
    amountMin: amountMin,
    amountMax: amountMax,
  );

  /// Message for a min above its max, otherwise null.
  String? get amountRangeError =>
      ReceiptsReportFilters.rangeError(amountMin, amountMax);

  /// Set and valid. An invalid range is not applied.
  bool get amountRangeActive =>
      (amountMin != null || amountMax != null) && amountRangeError == null;

  int get activeCount =>
      (categoryKey != null ? 1 : 0) +
      (staffKey != null ? 1 : 0) +
      (paidStaffKey != null ? 1 : 0) +
      (channelKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (hasLines != null ? 1 : 0) +
      (amountMin != null || amountMax != null ? 1 : 0);

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    categoryKey = null;
    staffKey = null;
    paidStaffKey = null;
    channelKey = null;
    departmentKey = null;
    hasLines = null;
    amountMin = null;
    amountMax = null;
  }

  /// Null [filterKey] matches all; [expensesReportNoneKey] matches a
  /// null [rowKey].
  static bool keyMatches(String? filterKey, String? rowKey) {
    if (filterKey == null) return true;
    if (filterKey == expensesReportNoneKey) return rowKey == null;
    return rowKey == filterKey;
  }

  /// Name, description, unit, category, staff, staff paid, the
  /// sub-expense lines' names and descriptions, and the department
  /// when departments are on.
  bool matchesSearch(
    ExpensesReportRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    if (has(r.name) ||
        has(r.description) ||
        has(r.unit) ||
        has(r.categoryLabel) ||
        has(r.staffName) ||
        has(r.paidStaffName) ||
        (departmentsEnabled && has(r.departmentName))) {
      return true;
    }
    for (final line in r.lines) {
      if (has(line.name) || has(line.description)) return true;
    }
    return false;
  }

  /// [departmentsEnabled] switches off the department search and
  /// filter, hidden in the UI then.
  bool matches(ExpensesReportRow r, {required bool departmentsEnabled}) {
    if (!matchesSearch(r, departmentsEnabled: departmentsEnabled)) {
      return false;
    }
    if (categoryKey != null && r.categoryKey != categoryKey) return false;
    if (!keyMatches(staffKey, r.staffKey)) return false;
    if (!keyMatches(paidStaffKey, r.paidStaffKey)) return false;
    if (channelKey != null && r.channelKey != channelKey) return false;
    if (departmentsEnabled && !keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (hasLines != null && r.hasLines != hasLines) return false;
    if (amountRangeActive &&
        !ReceiptsReportFilters.inRange(r.amount, amountMin, amountMax)) {
      return false;
    }
    return true;
  }
}

/// One choice in a filter.
class ExpensesFilterOption {
  final String key;
  final String label;

  const ExpensesFilterOption(this.key, this.label);
}

/// Filter choices, taken from the expenses themselves so deleted
/// staff and categories can still be selected. Each key shows its
/// most recent name.
class ExpensesReportOptions {
  static List<ExpensesFilterOption> _build(
    List<ExpensesReportRow> rows, {
    required String? Function(ExpensesReportRow) key,
    required String? Function(ExpensesReportRow) name,
    required String fallbackName,
    String? noneLabel,
  }) {
    final newestFirst = List<ExpensesReportRow>.from(rows)
      ..sort(ExpensesReportRow.newestFirst);
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in newestFirst) {
      final k = key(r);
      if (k == null) {
        hasNone = true;
        continue;
      }
      labels.putIfAbsent(k, () => name(r) ?? fallbackName);
    }
    final options = _sorted(labels);
    if (hasNone && noneLabel != null) {
      options.add(ExpensesFilterOption(expensesReportNoneKey, noneLabel));
    }
    return options;
  }

  static List<ExpensesFilterOption> _sorted(Map<String, String> labels) =>
      labels.entries.map((e) => ExpensesFilterOption(e.key, e.value)).toList()
        ..sort((a, b) {
          final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
          return c != 0 ? c : a.key.compareTo(b.key);
        });

  /// The three system categories always, then every custom category
  /// in [categories] or on an expense, A-Z.
  static List<ExpensesFilterOption> categories(
    List<ExpensesReportRow> rows, {
    List<ExpenseCategory> categories = const [],
  }) {
    final custom = <String, String>{};
    for (final c in categories) {
      custom[ExpenseCategoryKey.forCategory(c)] = ExpenseType.labelFor(
        ExpenseType.custom,
        customCategoryName: c.name,
      );
    }
    final newestFirst = List<ExpensesReportRow>.from(rows)
      ..sort(ExpensesReportRow.newestFirst);
    for (final r in newestFirst) {
      if (ExpenseCategoryKey.isCustom(r.categoryKey)) {
        custom.putIfAbsent(r.categoryKey, () => r.categoryLabel);
      }
    }
    return [
      for (final t in ExpenseType.systemTypes)
        ExpensesFilterOption(t, ExpenseType.labelFor(t)),
      ..._sorted(custom),
    ];
  }

  static List<ExpensesFilterOption> staff(List<ExpensesReportRow> rows) =>
      _build(
        rows,
        key: (r) => r.staffKey,
        name: (r) => r.staffName,
        fallbackName: 'Not Set',
        noneLabel: expensesNoStaffLabel,
      );

  /// From the salaries only. "No staff paid" when a salary was saved
  /// without one.
  static List<ExpensesFilterOption> paidStaff(List<ExpensesReportRow> rows) =>
      _build(
        rows.where((r) => r.isStaffSalary).toList(),
        key: (r) => r.paidStaffKey,
        name: (r) => r.paidStaffName,
        fallbackName: 'Not Set',
        noneLabel: expensesNoPaidStaffLabel,
      );

  static List<ExpensesFilterOption> channels(List<ExpensesReportRow> rows) =>
      _build(
        rows,
        key: (r) => r.channelKey,
        name: (r) => r.channelLabel,
        fallbackName: 'Cash',
      );

  static List<ExpensesFilterOption> departments(
    List<ExpensesReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    fallbackName: 'Not Set',
    noneLabel: expensesNoDepartmentLabel,
  );
}

// ---------------------------------------------------------------
// Totals, sorting and paging
// ---------------------------------------------------------------

/// Totals of a set of rows. [total] is Total Expenses: Stock
/// Purchase expenses are counted apart, in [stockPurchaseTotal].
class ExpensesReportTotals {
  /// Every row, Stock Purchases included.
  final int count;

  /// Rows in [total].
  final int countedCount;
  final double total;
  final int stockPurchaseCount;
  final double stockPurchaseTotal;

  /// Expenses with sub-expenses, and their lines (information only:
  /// each expense's amount already includes its lines).
  final int withLinesCount;
  final int lineCount;

  const ExpensesReportTotals({
    required this.count,
    required this.countedCount,
    required this.total,
    required this.stockPurchaseCount,
    required this.stockPurchaseTotal,
    required this.withLinesCount,
    required this.lineCount,
  });

  factory ExpensesReportTotals.of(Iterable<ExpensesReportRow> rows) {
    int count = 0;
    int counted = 0;
    double total = 0;
    int stockCount = 0;
    double stockTotal = 0;
    int withLines = 0;
    int lines = 0;
    for (final r in rows) {
      count++;
      if (r.countsInTotal) {
        counted++;
        total += r.amount;
      } else {
        stockCount++;
        stockTotal += r.amount;
      }
      if (r.hasLines) {
        withLines++;
        lines += r.lineCount;
      }
    }
    return ExpensesReportTotals(
      count: count,
      countedCount: counted,
      total: total,
      stockPurchaseCount: stockCount,
      stockPurchaseTotal: stockTotal,
      withLinesCount: withLines,
      lineCount: lines,
    );
  }
}

enum ExpensesSortField {
  createdAt,
  name,
  category,
  staff,
  paidStaff,
  channel,
  department,
  lines,
  amount,
}

/// Result of [ExpensesReportQuery.paginate].
class ExpensesReportPage {
  final List<ExpensesReportRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  /// Over the full filtered set, not just this page.
  final ExpensesReportTotals totals;

  const ExpensesReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    required this.totals,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * expensesReportPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ExpensesReportQuery {
  /// Null values always sink to the bottom, in both directions.
  static int cmp<T extends Comparable>(T? a, T? b, bool asc) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  /// First direction of a newly picked column: text A-Z; dates,
  /// counts and amounts newest / largest first.
  static bool defaultAscending(ExpensesSortField f) {
    switch (f) {
      case ExpensesSortField.name:
      case ExpensesSortField.category:
      case ExpensesSortField.staff:
      case ExpensesSortField.paidStaff:
      case ExpensesSortField.channel:
      case ExpensesSortField.department:
        return true;
      case ExpensesSortField.createdAt:
      case ExpensesSortField.lines:
      case ExpensesSortField.amount:
        return false;
    }
  }

  /// Rows in [period], then search and filters, then sorted. The
  /// whole set is sorted before pagination.
  ///
  /// [includeStockPurchases] false hides Stock Purchase expenses,
  /// unless the category filter asks for them.
  static List<ExpensesReportRow> filterAndSort({
    required List<ExpensesReportRow> rows,
    required ReceiptsReportPeriod period,
    required ExpensesReportFilters filters,
    ExpensesSortField sortField = ExpensesSortField.createdAt,
    bool ascending = false,
    required bool departmentsEnabled,
    bool includeStockPurchases = true,
    TimeOfDay? closingTime,
  }) {
    final showStock =
        includeStockPurchases ||
        filters.categoryKey == ExpenseType.stockPurchase;
    final out =
        rows
            .where(
              (r) =>
                  (showStock || !r.isStockPurchase) &&
                  r.inPeriod(period, closingTime: closingTime) &&
                  filters.matches(r, departmentsEnabled: departmentsEnabled),
            )
            .toList();

    String? lower(String? s) => s?.toLowerCase();

    int compare(ExpensesReportRow a, ExpensesReportRow b) {
      final asc = ascending;
      int c;
      switch (sortField) {
        case ExpensesSortField.createdAt:
          c = cmp(a.createdAt, b.createdAt, asc);
          break;
        case ExpensesSortField.name:
          c = cmp(lower(a.name), lower(b.name), asc);
          break;
        case ExpensesSortField.category:
          c = cmp(lower(a.categoryLabel), lower(b.categoryLabel), asc);
          break;
        case ExpensesSortField.staff:
          c = cmp(lower(a.staffName), lower(b.staffName), asc);
          break;
        case ExpensesSortField.paidStaff:
          c = cmp(lower(a.paidStaffName), lower(b.paidStaffName), asc);
          break;
        case ExpensesSortField.channel:
          c = cmp(lower(a.channelLabel), lower(b.channelLabel), asc);
          break;
        case ExpensesSortField.department:
          c = cmp(
            a.departmentKey == null ? null : lower(a.departmentLabel),
            b.departmentKey == null ? null : lower(b.departmentLabel),
            asc,
          );
          break;
        case ExpensesSortField.lines:
          c = cmp(a.lineCount, b.lineCount, asc);
          break;
        case ExpensesSortField.amount:
          c = cmp(a.amount, b.amount, asc);
          break;
      }
      // Deterministic tie-breakers keep pagination stable.
      return c != 0 ? c : ExpensesReportRow.newestFirst(a, b);
    }

    out.sort(compare);
    return out;
  }

  static ExpensesReportPage paginate(
    List<ExpensesReportRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: expensesReportPageSize,
    );
    return ExpensesReportPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totals: ExpensesReportTotals.of(sorted),
    );
  }
}

// ---------------------------------------------------------------
// Group by
// ---------------------------------------------------------------

/// "Group by" of the table. A view option, not a filter: Reset All
/// keeps it.
enum ExpensesGroupBy { off, category, staff, paidStaff, channel }

extension ExpensesGroupByLabel on ExpensesGroupBy {
  String get label {
    switch (this) {
      case ExpensesGroupBy.off:
        return 'Off';
      case ExpensesGroupBy.category:
        return 'Category';
      case ExpensesGroupBy.staff:
        return 'Staff';
      case ExpensesGroupBy.paidStaff:
        return 'Staff Paid';
      case ExpensesGroupBy.channel:
        return 'Channel';
    }
  }

  /// Pager label for the grouped rows.
  String get pagerLabel {
    switch (this) {
      case ExpensesGroupBy.category:
        return 'categories';
      case ExpensesGroupBy.staff:
      case ExpensesGroupBy.paidStaff:
        return 'staff';
      case ExpensesGroupBy.channel:
        return 'channels';
      case ExpensesGroupBy.off:
        return 'rows';
    }
  }
}

enum ExpensesGroupSortField { name, count, amount, lastDate }

/// One table row when grouped. [amount] is every expense in the
/// group, as the rows' Amount column; [countedAmount] leaves out
/// Stock Purchases, as Total Expenses.
class ExpensesGroupRow {
  final String key;

  /// The "No staff" / "No staff paid" row, always last.
  final bool isNone;
  final String _noneLabel;

  /// Most recent name in the group.
  String? name;

  int count = 0;
  double amount = 0;
  double stockPurchaseAmount = 0;
  int lineCount = 0;
  DateTime? lastDate;

  ExpensesGroupRow({
    required this.key,
    required this.isNone,
    required this.name,
    String noneLabel = '',
  }) : _noneLabel = noneLabel;

  String get label => isNone ? _noneLabel : (name ?? 'Not Set');

  double get countedAmount => amount - stockPurchaseAmount;

  void add(ExpensesReportRow r) {
    count++;
    amount += r.amount;
    if (!r.countsInTotal) stockPurchaseAmount += r.amount;
    lineCount += r.lineCount;
    final at = r.createdAt;
    if (at != null && (lastDate == null || at.isAfter(lastDate!))) {
      lastDate = at;
    }
  }
}

/// Result of [ExpensesGrouping.paginate].
class ExpensesGroupPage {
  final List<ExpensesGroupRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  /// Totals of every grouped expense, not just this page.
  final ExpensesReportTotals totals;

  const ExpensesGroupPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    required this.totals,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * expensesReportPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ExpensesGrouping {
  /// Groups [rows] that already passed the period and filters
  /// ([ExpensesReportQuery.filterAndSort]).
  static List<ExpensesGroupRow> build(
    List<ExpensesReportRow> rows,
    ExpensesGroupBy by,
  ) {
    if (by == ExpensesGroupBy.off) return [];
    final newestFirst = List<ExpensesReportRow>.from(rows)
      ..sort(ExpensesReportRow.newestFirst);
    final groups = <String, ExpensesGroupRow>{};
    for (final r in newestFirst) {
      final String? key;
      final String? name;
      String noneLabel = '';
      switch (by) {
        case ExpensesGroupBy.category:
          key = r.categoryKey;
          name = r.categoryLabel;
          break;
        case ExpensesGroupBy.staff:
          key = r.staffKey;
          name = r.staffName;
          noneLabel = expensesNoStaffLabel;
          break;
        case ExpensesGroupBy.paidStaff:
          key = r.paidStaffKey;
          name = r.paidStaffName;
          noneLabel = expensesNoPaidStaffLabel;
          break;
        case ExpensesGroupBy.channel:
          key = r.channelKey;
          name = r.channelLabel;
          break;
        case ExpensesGroupBy.off:
          key = null;
          name = null;
      }
      final g = groups.putIfAbsent(
        key ?? expensesReportNoneKey,
        () => ExpensesGroupRow(
          key: key ?? expensesReportNoneKey,
          isNone: key == null,
          name: name,
          noneLabel: noneLabel,
        ),
      );
      // Newest first, so only fill a name the newer ones lacked.
      g.name ??= name;
      g.add(r);
    }
    return groups.values.toList();
  }

  /// Sorted copy. The none row is always last; nulls sink to the
  /// bottom; ties: label, then key.
  static List<ExpensesGroupRow> sort(
    List<ExpensesGroupRow> groups, {
    required ExpensesGroupSortField field,
    required bool ascending,
  }) {
    final cmp = ExpensesReportQuery.cmp;
    int compare(ExpensesGroupRow a, ExpensesGroupRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case ExpensesGroupSortField.name:
          c = cmp(a.label.toLowerCase(), b.label.toLowerCase(), ascending);
          break;
        case ExpensesGroupSortField.count:
          c = cmp(a.count, b.count, ascending);
          break;
        case ExpensesGroupSortField.amount:
          c = cmp(a.amount, b.amount, ascending);
          break;
        case ExpensesGroupSortField.lastDate:
          c = cmp(a.lastDate, b.lastDate, ascending);
          break;
      }
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<ExpensesGroupRow>.from(groups)..sort(compare);
  }

  /// [rows] are the grouped expenses, for the totals.
  static ExpensesGroupPage paginate(
    List<ExpensesGroupRow> sorted,
    int requestedPage, {
    required List<ExpensesReportRow> rows,
  }) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: expensesReportPageSize,
    );
    return ExpensesGroupPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totals: ExpensesReportTotals.of(rows),
    );
  }
}

// ---------------------------------------------------------------
// Table state
// ---------------------------------------------------------------

/// Filters, view options, sorts and page of the table.
class ExpensesReportTableState {
  final ExpensesReportFilters filters;
  ExpensesGroupBy groupBy;
  ExpensesSortField sortField;
  bool ascending;
  ExpensesGroupSortField groupSortField;
  bool groupAscending;

  /// "Include stock purchases". A view option: Reset All keeps it.
  bool includeStockPurchases;
  int page;

  ExpensesReportTableState({
    ExpensesReportFilters? filters,
    this.groupBy = ExpensesGroupBy.off,
    this.sortField = ExpensesSortField.createdAt,
    this.ascending = false,
    this.groupSortField = ExpensesGroupSortField.amount,
    this.groupAscending = false,
    this.includeStockPurchases = true,
    this.page = 1,
  }) : filters = filters ?? ExpensesReportFilters();

  bool get grouped => groupBy != ExpensesGroupBy.off;

  /// Clears the search and every filter. Grouping, sorting and the
  /// stock purchase option are view options and stay.
  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}

String? _key(String? value) =>
    (value == null || value.trim().isEmpty) ? null : value;

String? _name(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
