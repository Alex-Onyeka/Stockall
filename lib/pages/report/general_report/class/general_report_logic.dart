import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

// General Report: revenue and gross profit from the receipts report
// logic, purchases from the purchase report logic, expenses from
// `ExpensesProvider.expensesMain`. Net profit = gross profit -
// expenses; purchases are shown but not subtracted, since gross
// profit already counts the cost of what was sold.

/// Below this, an amount counts as 0 (float sums).
const double generalReportZeroTolerance = 0.005;

/// Expenses the current user may see, and their total for a period.
class GeneralReportExpenses {
  /// Same rule as `ReceiptsReportAccess.scope`, on the expense's
  /// department and `userId`.
  static List<TempExpensesClass> scope({
    required List<TempExpensesClass> expenses,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
    required bool canViewAllTransactions,
    required String? currentUserId,
  }) {
    final restrictDepartment =
        departmentsEnabled &&
        (!canViewAllDepartments ||
            currentDepartmentUuid != null);
    return expenses.where((expense) {
      if (restrictDepartment &&
          !reportDepartmentMatches(
            expense.departmentUuid,
            currentDepartmentUuid,
          )) {
        return false;
      }
      if (!canViewAllTransactions &&
          expense.userId != currentUserId) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Expenses in [period]. One without a created date cannot be
  /// placed in a period and is left out. Stock Purchase expenses
  /// are left out too: they are the payments of purchases, already
  /// shown under purchases and in gross profit's cost.
  static List<TempExpensesClass> inPeriod(
    List<TempExpensesClass> expenses,
    ReceiptsReportPeriod period, {
    TimeOfDay? closingTime,
  }) {
    return expenses
        .where(
          (expense) =>
              !expense.isStockPurchase &&
              expense.createdDate != null &&
              period.contains(
                expense.createdDate!,
                closingTime: closingTime,
              ),
        )
        .toList();
  }

  /// Total of [expenses], without Stock Purchase expenses (see
  /// [inPeriod]).
  static double total(List<TempExpensesClass> expenses) =>
      expenses.fold<double>(
        0,
        (sum, expense) =>
            expense.isStockPurchase ? sum : sum + expense.amount,
      );
}

/// Every figure of the page for one period. Profit values are null
/// without the Manage Cost Price permission.
class GeneralReportFigures {
  final ReceiptsReportPeriod period;
  final bool profitVisible;

  final double totalRevenue;
  final double? grossProfit;
  final double totalPurchases;
  final double totalExpenses;
  final double? netProfit;

  /// Receipts whose profit has a line without a cost price
  /// (counted as 0).
  final int? costMissingCount;

  /// Receipts without item data, left out of the gross profit.
  final int? noItemDataCount;

  final int receiptCount;
  final int purchaseCount;
  final int expenseCount;

  /// Rows and expenses in the period, for the trend.
  final List<ReceiptsReportRow> receiptRows;
  final List<TempExpensesClass> expenses;

  const GeneralReportFigures({
    required this.period,
    required this.profitVisible,
    required this.totalRevenue,
    required this.grossProfit,
    required this.totalPurchases,
    required this.totalExpenses,
    required this.netProfit,
    required this.costMissingCount,
    required this.noItemDataCount,
    required this.receiptCount,
    required this.purchaseCount,
    required this.expenseCount,
    required this.receiptRows,
    required this.expenses,
  });

  /// [receiptRows], [purchaseRows] and [expenses] must already be
  /// scoped to the user (`ReceiptsReportAccess.scope`,
  /// `PurchaseReportAccess.scope`, [GeneralReportExpenses.scope]).
  /// Totals are the Receipts Report and Purchase Report totals with
  /// no filters, so the figures match those reports.
  static GeneralReportFigures build({
    required List<ReceiptsReportRow> receiptRows,
    required List<PurchaseReportRow> purchaseRows,
    required List<TempExpensesClass> expenses,
    required ReceiptsReportPeriod period,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    final receipts = ReceiptsReportQuery.filterAndSort(
      rows: receiptRows,
      period: period,
      filters: ReceiptsReportFilters(),
      sortField: ReceiptsSortField.createdAt,
      ascending: false,
      departmentsEnabled: false,
      subStaffEnabled: false,
      profitVisible: profitVisible,
      closingTime: closingTime,
    );
    final receiptTotals = ReceiptsReportQuery.paginate(
      receipts,
      1,
    );
    final stats = ReceiptsSummaryBuilder.stats(receipts);

    final purchases = PurchaseReportQuery.filterAndSort(
      rows: purchaseRows,
      period: period,
      filters: PurchaseReportFilters(),
      sortField: PurchasesSortField.createdAt,
      ascending: false,
      departmentsEnabled: false,
      closingTime: closingTime,
    );
    final purchaseTotals = PurchaseReportQuery.paginate(
      purchases,
      1,
    );

    final periodExpenses = GeneralReportExpenses.inPeriod(
      expenses,
      period,
      closingTime: closingTime,
    );
    final totalExpenses = GeneralReportExpenses.total(
      periodExpenses,
    );

    final grossProfit =
        profitVisible ? receiptTotals.totalProfit : null;
    return GeneralReportFigures(
      period: period,
      profitVisible: profitVisible,
      totalRevenue: receiptTotals.totalRevenue,
      grossProfit: grossProfit,
      totalPurchases: purchaseTotals.total,
      totalExpenses: totalExpenses,
      netProfit:
          grossProfit == null
              ? null
              : grossProfit - totalExpenses,
      costMissingCount:
          profitVisible ? stats.costMissingCount : null,
      noItemDataCount:
          profitVisible ? stats.profitUnknownCount : null,
      receiptCount: receipts.length,
      purchaseCount: purchases.length,
      expenseCount: periodExpenses.length,
      receiptRows: receipts,
      expenses: periodExpenses,
    );
  }
}

class GeneralReportPeriods {
  /// Business days in a dated period, counted on UTC dates so a
  /// daylight-saving day is still one day.
  static int dayCount(ReceiptsReportPeriod period) {
    final s = period.start!;
    final e = period.end!;
    return DateTime.utc(e.year, e.month, e.day)
            .difference(DateTime.utc(s.year, s.month, s.day))
            .inDays +
        1;
  }

  /// The same number of days, ending the day before [period]
  /// starts: Today compares with yesterday, a 7-day range with the
  /// 7 days before it. Null for all time.
  static ReceiptsReportPeriod? previous(
    ReceiptsReportPeriod period,
  ) {
    if (period.isAllTime) return null;
    final s = period.start!;
    final days = dayCount(period);
    return ReceiptsReportPeriod.range(
      DateTime(s.year, s.month, s.day - days),
      DateTime(s.year, s.month, s.day - 1),
    );
  }
}

enum GeneralReportChangeKind { percent, amount }

/// Change against the previous period: a percentage, or the
/// difference in amount where a percentage would mislead (previous
/// 0, or a profit that was 0 or negative).
class GeneralReportChange {
  final GeneralReportChangeKind kind;

  /// Percent (12.5 = 12.5%) or amount.
  final double value;

  const GeneralReportChange(this.kind, this.value);

  bool get isPercent => kind == GeneralReportChangeKind.percent;

  bool get isUp => value > 0;
  bool get isDown => value < 0;

  /// Null when there is no previous value (all time, or a hidden
  /// profit).
  static GeneralReportChange? compare({
    required double? current,
    required double? previous,
    bool isProfit = false,
  }) {
    if (current == null || previous == null) return null;
    final diff = current - previous;
    if (previous.abs() < generalReportZeroTolerance ||
        (isProfit && previous <= 0)) {
      return GeneralReportChange(
        GeneralReportChangeKind.amount,
        diff,
      );
    }
    return GeneralReportChange(
      GeneralReportChangeKind.percent,
      diff / previous * 100,
    );
  }
}

/// One change per figure. Every field is null without a previous
/// period; the profit ones also without the cost permission.
class GeneralReportChanges {
  final GeneralReportChange? revenue;
  final GeneralReportChange? grossProfit;
  final GeneralReportChange? purchases;
  final GeneralReportChange? expenses;
  final GeneralReportChange? netProfit;

  const GeneralReportChanges({
    this.revenue,
    this.grossProfit,
    this.purchases,
    this.expenses,
    this.netProfit,
  });

  static const none = GeneralReportChanges();

  static GeneralReportChanges between(
    GeneralReportFigures current,
    GeneralReportFigures? previous,
  ) {
    if (previous == null) return none;
    return GeneralReportChanges(
      revenue: GeneralReportChange.compare(
        current: current.totalRevenue,
        previous: previous.totalRevenue,
      ),
      grossProfit: GeneralReportChange.compare(
        current: current.grossProfit,
        previous: previous.grossProfit,
        isProfit: true,
      ),
      purchases: GeneralReportChange.compare(
        current: current.totalPurchases,
        previous: previous.totalPurchases,
      ),
      expenses: GeneralReportChange.compare(
        current: current.totalExpenses,
        previous: previous.totalExpenses,
      ),
      netProfit: GeneralReportChange.compare(
        current: current.netProfit,
        previous: previous.netProfit,
        isProfit: true,
      ),
    );
  }
}

/// One bucket of the trend chart. Profit values are null without
/// the cost permission.
class GeneralReportTrendPoint {
  final DateTime start;
  final bool profitVisible;
  double revenue = 0;
  double _grossProfit = 0;
  double expenses = 0;

  GeneralReportTrendPoint(
    this.start, {
    required this.profitVisible,
  });

  /// Known profit, as the receipts trend's `knownProfit`.
  double? get grossProfit =>
      profitVisible ? _grossProfit : null;

  double? get netProfit =>
      profitVisible ? _grossProfit - expenses : null;
}

class GeneralReportTrend {
  /// Null when there are no buckets.
  final ReceiptsTrendInterval? interval;
  final List<GeneralReportTrendPoint> points;

  const GeneralReportTrend({
    required this.interval,
    required this.points,
  });

  static const empty = GeneralReportTrend(
    interval: null,
    points: [],
  );
}

/// Buckets as `ReceiptsTrendBuilder`: business dates with the
/// same closing time, hourly / daily / weekly (from Monday) /
/// monthly by length. Expenses go in the same buckets.
class GeneralReportTrendBuilder {
  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  /// First and last business day the chart covers. All time runs
  /// from the earliest receipt or expense to today. Null without
  /// either in an all-time period.
  static DateTimeRange? span({
    required List<ReceiptsReportRow> receiptRows,
    required List<TempExpensesClass> expenses,
    required ReceiptsReportPeriod period,
    required DateTime now,
    TimeOfDay? closingTime,
  }) {
    if (!period.isAllTime) {
      return DateTimeRange(
        start: period.start!,
        end: period.end!,
      );
    }
    final dates = <DateTime>[
      for (final r in receiptRows) r.createdAt,
      for (final e in expenses)
        if (e.createdDate != null) e.createdDate!,
    ];
    if (dates.isEmpty) return null;
    DateTime? first;
    var last = _dateOnly(
      resolveBusinessDate(
        now,
        customClosingTime: closingTime,
      ),
    );
    for (final createdAt in dates) {
      final d = ReceiptsTrendBuilder.businessDate(
        createdAt,
        closingTime: closingTime,
      );
      if (first == null || d.isBefore(first)) first = d;
      if (d.isAfter(last)) last = d;
    }
    return DateTimeRange(start: first!, end: last);
  }

  /// [receiptRows] and [expenses] must already be in the period
  /// ([GeneralReportFigures.receiptRows] / `.expenses`).
  static GeneralReportTrend build({
    required List<ReceiptsReportRow> receiptRows,
    required List<TempExpensesClass> expenses,
    required ReceiptsReportPeriod period,
    required bool profitVisible,
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    final range = span(
      receiptRows: receiptRows,
      expenses: expenses,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    if (range == null) return GeneralReportTrend.empty;
    final interval = ReceiptsTrendBuilder.intervalFor(
      range.start,
      range.end,
    );
    final dated = [
      for (final e in expenses)
        if (e.createdDate != null) e,
    ];

    final points = <GeneralReportTrendPoint>[];
    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      for (var h = 0; h < 24; h++) {
        points.add(
          GeneralReportTrendPoint(
            dayStart.add(Duration(hours: h)),
            profitVisible: profitVisible,
          ),
        );
      }
      int hourOf(DateTime createdAt) => createdAt
          .toLocal()
          .difference(dayStart)
          .inHours
          .clamp(0, 23);
      for (final r in receiptRows) {
        _addReceipt(points[hourOf(r.createdAt)], r);
      }
      for (final e in dated) {
        points[hourOf(e.createdDate!)].expenses += e.amount;
      }
      return GeneralReportTrend(
        interval: interval,
        points: points,
      );
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

    final byStart = <DateTime, GeneralReportTrendPoint>{};
    final last = bucketOf(range.end);
    for (
      var d = bucketOf(range.start);
      !d.isAfter(last);
      d = next(d)
    ) {
      final p = GeneralReportTrendPoint(
        d,
        profitVisible: profitVisible,
      );
      points.add(p);
      byStart[d] = p;
    }
    GeneralReportTrendPoint? pointOf(DateTime createdAt) =>
        byStart[bucketOf(
          ReceiptsTrendBuilder.businessDate(
            createdAt,
            closingTime: closingTime,
          ),
        )];
    for (final r in receiptRows) {
      final p = pointOf(r.createdAt);
      if (p != null) _addReceipt(p, r);
    }
    for (final e in dated) {
      pointOf(e.createdDate!)?.expenses += e.amount;
    }
    return GeneralReportTrend(
      interval: interval,
      points: points,
    );
  }

  static void _addReceipt(
    GeneralReportTrendPoint p,
    ReceiptsReportRow r,
  ) {
    p.revenue += r.revenue;
    p._grossProfit += r.profit ?? 0;
  }
}
