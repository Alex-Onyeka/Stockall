import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

// Expenses analysis: figures for one period, no other filter.
//
// Total Expenses, shares, the trend and the top lists leave Stock
// Purchase expenses out (see expenses_report_table_logic.dart). They
// get their own figure, and their own row at the end of the
// category breakdown, marked as not in the total.
//
// Every breakdown row carries an [ExpensesTableHandoff] that opens
// the table on exactly its expenses.

/// What a breakdown row opens: the table's filters and its "Include
/// stock purchases" option. The option is off, so a staff or
/// channel row shows the expenses it counts; the Stock Purchase
/// category row still shows them, through its category filter.
class ExpensesTableHandoff {
  final ExpensesReportFilters filters;
  final bool includeStockPurchases;

  const ExpensesTableHandoff(
    this.filters, {
    this.includeStockPurchases = false,
  });

  /// [base] with the given keys set.
  factory ExpensesTableHandoff.of({
    ExpensesReportFilters? base,
    String? categoryKey,
    String? staffKey,
    String? paidStaffKey,
    String? channelKey,
    String? departmentKey,
    String? search,
  }) {
    final f = (base ?? ExpensesReportFilters()).copy();
    if (categoryKey != null) f.categoryKey = categoryKey;
    if (staffKey != null) f.staffKey = staffKey;
    if (paidStaffKey != null) f.paidStaffKey = paidStaffKey;
    if (channelKey != null) f.channelKey = channelKey;
    if (departmentKey != null) f.departmentKey = departmentKey;
    if (search != null) f.search = search;
    return ExpensesTableHandoff(f);
  }

  /// The table rows this handoff opens, in [period].
  List<ExpensesReportRow> apply(
    List<ExpensesReportRow> rows, {
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    TimeOfDay? closingTime,
  }) => ExpensesReportQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: filters,
    departmentsEnabled: departmentsEnabled,
    includeStockPurchases: includeStockPurchases,
    closingTime: closingTime,
  );
}

/// Statistic cards. Stock Purchase expenses are only in the
/// stockPurchase figures.
class ExpensesSummaryStats {
  final int expenseCount;
  final double totalExpenses;

  /// Null without expenses.
  final ExpensesReportRow? largest;

  final int salaryCount;
  final double salaryTotal;

  /// Distinct staff paid (salaries saved without one not counted).
  final int staffPaidCount;

  final int withLinesCount;
  final int lineCount;

  /// Expenses whose lines no longer add up to their amount.
  final int linesMismatchCount;

  final int stockPurchaseCount;
  final double stockPurchaseTotal;

  /// Distinct categories with an expense.
  final int categoriesUsed;

  /// Distinct staff who recorded an expense.
  final int distinctStaff;

  const ExpensesSummaryStats({
    required this.expenseCount,
    required this.totalExpenses,
    required this.largest,
    required this.salaryCount,
    required this.salaryTotal,
    required this.staffPaidCount,
    required this.withLinesCount,
    required this.lineCount,
    required this.linesMismatchCount,
    required this.stockPurchaseCount,
    required this.stockPurchaseTotal,
    required this.categoriesUsed,
    required this.distinctStaff,
  });

  /// Per expense; 0 without expenses.
  double get average => expenseCount == 0 ? 0 : totalExpenses / expenseCount;
}

/// One row of a breakdown table.
class ExpensesBreakdownRow {
  /// Unique within the page: tab and key.
  final String id;
  final String key;
  final String label;

  /// "No staff" / "No staff paid" / "No Department": always last,
  /// before [excluded] rows.
  final bool isNone;

  /// The Stock Purchase category row: shown, not in Total Expenses,
  /// no share. Always last.
  final bool excluded;
  final int count;
  final double amount;

  /// Amount / the tab's total * 100. Null for [excluded] rows or a
  /// total not above 0.
  final double? share;
  final DateTime? lastDate;
  final ExpensesTableHandoff handoff;

  const ExpensesBreakdownRow({
    required this.id,
    required this.key,
    required this.label,
    required this.isNone,
    required this.excluded,
    required this.count,
    required this.amount,
    required this.share,
    required this.lastDate,
    required this.handoff,
  });

  double get average => count == 0 ? 0 : amount / count;
}

/// One sub-expense name across expenses ("Transportation" on three
/// expenses). Opens the table searched by the name, so expenses
/// whose own name or description matches are listed too.
class ExpensesLineSummary {
  /// Lower-cased name.
  final String key;

  /// Most recent spelling.
  final String label;
  int lineCount = 0;
  int expenseCount = 0;
  double amount = 0;

  ExpensesLineSummary(this.key, this.label);

  ExpensesTableHandoff get handoff => ExpensesTableHandoff.of(search: label);
}

enum ExpensesBreakdownTab { category, salary, staff, channel, department }

extension ExpensesBreakdownTabLabel on ExpensesBreakdownTab {
  String get label {
    switch (this) {
      case ExpensesBreakdownTab.category:
        return 'Category';
      case ExpensesBreakdownTab.salary:
        return 'Staff Salary';
      case ExpensesBreakdownTab.staff:
        return 'Created by';
      case ExpensesBreakdownTab.channel:
        return 'Channel';
      case ExpensesBreakdownTab.department:
        return 'Departments';
    }
  }
}

enum ExpensesBreakdownSortField { name, count, amount, average, share, lastDate }

/// One bucket of the trend chart. Stock Purchases are left out.
class ExpensesTrendPoint {
  final DateTime start;
  double total = 0;
  double salary = 0;
  int count = 0;

  ExpensesTrendPoint(this.start);
}

/// Everything the analysis page shows for one period.
class ExpensesSummaryResult {
  /// Every expense in the period, Stock Purchases included.
  final List<ExpensesReportRow> rows;
  final ExpensesSummaryStats stats;
  final Map<ExpensesBreakdownTab, List<ExpensesBreakdownRow>> breakdowns;

  /// Largest first, Stock Purchases left out.
  final List<ExpensesReportRow> topExpenses;
  final List<ExpensesLineSummary> topLines;
  final List<ExpensesTrendPoint> trend;

  /// Null without a chart (all time with no expenses).
  final ReceiptsTrendInterval? interval;

  const ExpensesSummaryResult({
    required this.rows,
    required this.stats,
    required this.breakdowns,
    required this.topExpenses,
    required this.topLines,
    required this.trend,
    required this.interval,
  });

  /// Empty for a tab that is not shown (Departments when off).
  List<ExpensesBreakdownRow> breakdown(ExpensesBreakdownTab tab) =>
      breakdowns[tab] ?? const [];
}

class ExpensesSummaryBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  static ExpensesSummaryStats stats(List<ExpensesReportRow> rows) {
    int count = 0;
    double total = 0;
    ExpensesReportRow? largest;
    int salaryCount = 0;
    double salaryTotal = 0;
    final paid = <String>{};
    int withLines = 0;
    int lines = 0;
    int mismatch = 0;
    int stockCount = 0;
    double stockTotal = 0;
    final categories = <String>{};
    final staff = <String>{};

    for (final r in rows) {
      if (!r.countsInTotal) {
        stockCount++;
        stockTotal += r.amount;
        continue;
      }
      count++;
      total += r.amount;
      if (largest == null ||
          r.amount > largest.amount ||
          (r.amount == largest.amount &&
              ExpensesReportRow.newestFirst(r, largest) < 0)) {
        largest = r;
      }
      if (r.isStaffSalary) {
        salaryCount++;
        salaryTotal += r.amount;
        final k = r.paidStaffKey;
        if (k != null) paid.add(k);
      }
      if (r.hasLines) {
        withLines++;
        lines += r.lineCount;
      }
      if (r.linesMismatch) mismatch++;
      categories.add(r.categoryKey);
      final s = r.staffKey;
      if (s != null) staff.add(s);
    }

    return ExpensesSummaryStats(
      expenseCount: count,
      totalExpenses: total,
      largest: largest,
      salaryCount: salaryCount,
      salaryTotal: salaryTotal,
      staffPaidCount: paid.length,
      withLinesCount: withLines,
      lineCount: lines,
      linesMismatchCount: mismatch,
      stockPurchaseCount: stockCount,
      stockPurchaseTotal: stockTotal,
      categoriesUsed: categories.length,
      distinctStaff: staff.length,
    );
  }

  /// Groups [rows] by [key], each with its most recent name.
  /// Amount, largest first; the none row last. Shares are of
  /// [shareTotal].
  static List<ExpensesBreakdownRow> _groups(
    ExpensesBreakdownTab tab,
    List<ExpensesReportRow> rows, {
    required String? Function(ExpensesReportRow) key,
    required String? Function(ExpensesReportRow) name,
    required String noneLabel,
    required double shareTotal,
    required ExpensesTableHandoff Function(String key) handoff,
    bool excluded = false,
  }) {
    final newestFirst = List<ExpensesReportRow>.from(rows)
      ..sort(ExpensesReportRow.newestFirst);
    final order = <String>[];
    final labels = <String, String?>{};
    final counts = <String, int>{};
    final amounts = <String, double>{};
    final last = <String, DateTime?>{};
    for (final r in newestFirst) {
      final k = key(r) ?? expensesReportNoneKey;
      if (!counts.containsKey(k)) {
        order.add(k);
        counts[k] = 0;
        amounts[k] = 0;
        last[k] = r.createdAt;
      }
      labels[k] ??= name(r);
      counts[k] = counts[k]! + 1;
      amounts[k] = amounts[k]! + r.amount;
    }
    final out = [
      for (final k in order)
        ExpensesBreakdownRow(
          id: '${tab.name}-$k',
          key: k,
          label:
              k == expensesReportNoneKey
                  ? noneLabel
                  : (labels[k] ?? 'Not Set'),
          isNone: k == expensesReportNoneKey,
          excluded: excluded,
          count: counts[k]!,
          amount: amounts[k]!,
          share: excluded ? null : _share(amounts[k]!, shareTotal),
          lastDate: last[k],
          handoff: handoff(k),
        ),
    ];
    return sortBreakdown(
      out,
      field: ExpensesBreakdownSortField.amount,
      ascending: false,
    );
  }

  /// Every category in the period, then Stock Purchase (excluded).
  static List<ExpensesBreakdownRow> categories(
    List<ExpensesReportRow> rows, {
    ExpensesReportFilters? base,
  }) {
    final counted = rows.where((r) => r.countsInTotal).toList();
    final total = counted.fold<double>(0, (s, r) => s + r.amount);
    ExpensesTableHandoff handoff(String k) =>
        ExpensesTableHandoff.of(base: base, categoryKey: k);
    return [
      ..._groups(
        ExpensesBreakdownTab.category,
        counted,
        key: (r) => r.categoryKey,
        name: (r) => r.categoryLabel,
        noneLabel: '',
        shareTotal: total,
        handoff: handoff,
      ),
      ..._groups(
        ExpensesBreakdownTab.category,
        rows.where((r) => !r.countsInTotal).toList(),
        key: (r) => r.categoryKey,
        name: (r) => r.categoryLabel,
        noneLabel: '',
        shareTotal: 0,
        handoff: handoff,
        excluded: true,
      ),
    ];
  }

  /// Salaries per staff paid. Shares are of the salary total.
  static List<ExpensesBreakdownRow> salaries(
    List<ExpensesReportRow> rows, {
    ExpensesReportFilters? base,
  }) {
    final salaries = rows.where((r) => r.isStaffSalary).toList();
    final total = salaries.fold<double>(0, (s, r) => s + r.amount);
    return _groups(
      ExpensesBreakdownTab.salary,
      salaries,
      key: (r) => r.paidStaffKey,
      name: (r) => r.paidStaffName,
      noneLabel: expensesNoPaidStaffLabel,
      shareTotal: total,
      handoff:
          (k) => ExpensesTableHandoff.of(
            base: base,
            categoryKey: ExpenseType.staffSalary,
            paidStaffKey: k,
          ),
    );
  }

  static List<ExpensesBreakdownRow> _counted(
    ExpensesBreakdownTab tab,
    List<ExpensesReportRow> rows, {
    required String? Function(ExpensesReportRow) key,
    required String? Function(ExpensesReportRow) name,
    required String noneLabel,
    required ExpensesTableHandoff Function(String key) handoff,
  }) {
    final counted = rows.where((r) => r.countsInTotal).toList();
    return _groups(
      tab,
      counted,
      key: key,
      name: name,
      noneLabel: noneLabel,
      shareTotal: counted.fold<double>(0, (s, r) => s + r.amount),
      handoff: handoff,
    );
  }

  /// Per staff who recorded the expenses.
  static List<ExpensesBreakdownRow> staff(
    List<ExpensesReportRow> rows, {
    ExpensesReportFilters? base,
  }) => _counted(
    ExpensesBreakdownTab.staff,
    rows,
    key: (r) => r.staffKey,
    name: (r) => r.staffName,
    noneLabel: expensesNoStaffLabel,
    handoff: (k) => ExpensesTableHandoff.of(base: base, staffKey: k),
  );

  /// Per payment channel. A Split expense counts once, under Split.
  static List<ExpensesBreakdownRow> channels(
    List<ExpensesReportRow> rows, {
    ExpensesReportFilters? base,
  }) => _counted(
    ExpensesBreakdownTab.channel,
    rows,
    key: (r) => r.channelKey,
    name: (r) => r.channelLabel,
    noneLabel: '',
    handoff: (k) => ExpensesTableHandoff.of(base: base, channelKey: k),
  );

  static List<ExpensesBreakdownRow> departments(
    List<ExpensesReportRow> rows, {
    ExpensesReportFilters? base,
  }) => _counted(
    ExpensesBreakdownTab.department,
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    noneLabel: expensesNoDepartmentLabel,
    handoff: (k) => ExpensesTableHandoff.of(base: base, departmentKey: k),
  );

  /// Largest first, then newest. Stock Purchases left out.
  static List<ExpensesReportRow> topExpenses(
    List<ExpensesReportRow> rows, {
    int count = 5,
  }) {
    final sorted =
        rows.where((r) => r.countsInTotal).toList()..sort((a, b) {
          final c = b.amount.compareTo(a.amount);
          return c != 0 ? c : ExpensesReportRow.newestFirst(a, b);
        });
    return sorted.take(count).toList();
  }

  /// Sub-expense names across expenses, by amount, largest first;
  /// ties by name. Same spelling in any case shares a row.
  static List<ExpensesLineSummary> topLines(
    List<ExpensesReportRow> rows, {
    int count = 5,
  }) {
    final newestFirst =
        rows.where((r) => r.countsInTotal && r.hasLines).toList()
          ..sort(ExpensesReportRow.newestFirst);
    final byKey = <String, ExpensesLineSummary>{};
    for (final r in newestFirst) {
      final seen = <String>{};
      for (final line in r.lines) {
        final label = line.name.trim();
        if (label.isEmpty) continue;
        final k = label.toLowerCase();
        final s = byKey.putIfAbsent(k, () => ExpensesLineSummary(k, label));
        s.lineCount++;
        s.amount += line.amount;
        if (seen.add(k)) s.expenseCount++;
      }
    }
    final out =
        byKey.values.toList()..sort((a, b) {
          final c = b.amount.compareTo(a.amount);
          return c != 0 ? c : a.key.compareTo(b.key);
        });
    return out.take(count).toList();
  }

  /// Sorted copy. A null [field] keeps the built order. Excluded
  /// rows are always last, none rows just before them; nulls sink
  /// to the bottom; ties: label, then key.
  static List<ExpensesBreakdownRow> sortBreakdown(
    List<ExpensesBreakdownRow> rows, {
    required ExpensesBreakdownSortField? field,
    required bool ascending,
  }) {
    final cmp = ExpensesReportQuery.cmp;
    final order = {for (var i = 0; i < rows.length; i++) rows[i].id: i};
    int compare(ExpensesBreakdownRow a, ExpensesBreakdownRow b) {
      if (a.excluded != b.excluded) return a.excluded ? 1 : -1;
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case null:
          return order[a.id]!.compareTo(order[b.id]!);
        case ExpensesBreakdownSortField.name:
          c = cmp(a.label.toLowerCase(), b.label.toLowerCase(), ascending);
          break;
        case ExpensesBreakdownSortField.count:
          c = cmp(a.count, b.count, ascending);
          break;
        case ExpensesBreakdownSortField.amount:
          c = cmp(a.amount, b.amount, ascending);
          break;
        case ExpensesBreakdownSortField.average:
          c = cmp(a.average, b.average, ascending);
          break;
        case ExpensesBreakdownSortField.share:
          c = cmp(a.share, b.share, ascending);
          break;
        case ExpensesBreakdownSortField.lastDate:
          c = cmp(a.lastDate, b.lastDate, ascending);
          break;
      }
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<ExpensesBreakdownRow>.from(rows)..sort(compare);
  }

  /// [rows] are the report's base rows; only those in [period] are
  /// used (no other filter: the analysis has none).
  static ExpensesSummaryResult build({
    required List<ExpensesReportRow> rows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    TimeOfDay? closingTime,
    DateTime? now,
    int topCount = 5,
  }) {
    final inPeriod = ExpensesReportQuery.filterAndSort(
      rows: rows,
      period: period,
      filters: ExpensesReportFilters(),
      departmentsEnabled: departmentsEnabled,
      closingTime: closingTime,
    );
    final range = ExpensesTrendBuilder.span(
      rows: inPeriod,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    return ExpensesSummaryResult(
      rows: inPeriod,
      stats: stats(inPeriod),
      breakdowns: {
        ExpensesBreakdownTab.category: categories(inPeriod),
        ExpensesBreakdownTab.salary: salaries(inPeriod),
        ExpensesBreakdownTab.staff: staff(inPeriod),
        ExpensesBreakdownTab.channel: channels(inPeriod),
        if (departmentsEnabled)
          ExpensesBreakdownTab.department: departments(inPeriod),
      },
      topExpenses: topExpenses(inPeriod, count: topCount),
      topLines: topLines(inPeriod, count: topCount),
      trend: ExpensesTrendBuilder.build(
        rows: inPeriod,
        period: period,
        now: now,
        closingTime: closingTime,
      ),
      interval:
          range == null
              ? null
              : ReceiptsTrendBuilder.intervalFor(range.start, range.end),
    );
  }
}

/// Trend buckets by business date, using the same closing time as
/// the report period. Intervals as the receipts and purchase trends.
/// Undated and Stock Purchase expenses are left out.
class ExpensesTrendBuilder {
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  static List<ExpensesReportRow> _charted(List<ExpensesReportRow> rows) =>
      rows.where((r) => r.countsInTotal && r.createdAt != null).toList();

  /// First and last business day the chart covers. All time runs
  /// from the earliest expense to today. Null without expenses in
  /// an all-time period.
  static DateTimeRange? span({
    required List<ExpensesReportRow> rows,
    required ReceiptsReportPeriod period,
    required DateTime now,
    TimeOfDay? closingTime,
  }) {
    if (!period.isAllTime) {
      return DateTimeRange(start: period.start!, end: period.end!);
    }
    final charted = _charted(rows);
    if (charted.isEmpty) return null;
    DateTime business(DateTime at) =>
        ReceiptsTrendBuilder.businessDate(at, closingTime: closingTime);
    var first = business(charted.first.createdAt!);
    var last = _dateOnly(resolveBusinessDate(now, customClosingTime: closingTime));
    for (final r in charted) {
      final d = business(r.createdAt!);
      if (d.isBefore(first)) first = d;
      if (d.isAfter(last)) last = d;
    }
    return DateTimeRange(start: first, end: last);
  }

  /// Buckets from the start to the end of the period, empty ones
  /// included (as 0). [rows] must already be in the period.
  static List<ExpensesTrendPoint> build({
    required List<ExpensesReportRow> rows,
    required ReceiptsReportPeriod period,
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    final range = span(
      rows: rows,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    if (range == null) return [];
    final charted = _charted(rows);
    final interval = ReceiptsTrendBuilder.intervalFor(range.start, range.end);

    final points = <ExpensesTrendPoint>[];
    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      for (var h = 0; h < 24; h++) {
        points.add(ExpensesTrendPoint(dayStart.add(Duration(hours: h))));
      }
      for (final r in charted) {
        final i = r.createdAt!.difference(dayStart).inHours.clamp(0, 23);
        _add(points[i], r);
      }
      return points;
    }

    DateTime bucketOf(DateTime d) {
      switch (interval) {
        case ReceiptsTrendInterval.weekly:
          return _weekStart(d);
        case ReceiptsTrendInterval.monthly:
          return DateTime(d.year, d.month, 1);
        default:
          return d;
      }
    }

    DateTime next(DateTime d) {
      switch (interval) {
        case ReceiptsTrendInterval.weekly:
          return DateTime(d.year, d.month, d.day + 7);
        case ReceiptsTrendInterval.monthly:
          return DateTime(d.year, d.month + 1, 1);
        default:
          return DateTime(d.year, d.month, d.day + 1);
      }
    }

    final byStart = <DateTime, ExpensesTrendPoint>{};
    final last = bucketOf(range.end);
    for (var d = bucketOf(range.start); !d.isAfter(last); d = next(d)) {
      final p = ExpensesTrendPoint(d);
      points.add(p);
      byStart[d] = p;
    }
    for (final r in charted) {
      final d = bucketOf(
        ReceiptsTrendBuilder.businessDate(r.createdAt!, closingTime: closingTime),
      );
      final p = byStart[d];
      if (p != null) _add(p, r);
    }
    return points;
  }

  static void _add(ExpensesTrendPoint p, ExpensesReportRow r) {
    p.total += r.amount;
    p.count++;
    if (r.isStaffSalary) p.salary += r.amount;
  }
}
