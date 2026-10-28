import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

/// Totals for one supplier, staff member or department. [key] is
/// the row key the table filters on, or [purchaseReportNoneKey]
/// for purchases without one.
class PurchaseSummaryGroup {
  final String key;
  final String label;
  int purchaseCount = 0;
  double spend = 0;
  double paid = 0;

  /// Still owed, as the table's grouped Balance column: overpaid
  /// purchases count as 0.
  double balance = 0;
  DateTime? lastDate;

  /// spend / total spend * 100; null when the total is not
  /// above 0.
  double? spendShare;

  PurchaseSummaryGroup(this.key, this.label);

  bool get isNone => key == purchaseReportNoneKey;

  double get average =>
      purchaseCount == 0 ? 0 : spend / purchaseCount;

  void add(PurchaseReportRow r) {
    purchaseCount++;
    spend += r.total;
    paid += r.paid;
    balance += r.balance;
    if (lastDate == null ||
        r.createdAt.isAfter(lastDate!)) {
      lastDate = r.createdAt;
    }
  }
}

/// Statistic cards.
class PurchaseSummaryStats {
  final int totalPurchases;
  final Map<PurchaseStatus, int> countByStatus;

  /// By [PurchaseReportRow.channelKey].
  final Map<String, int> countByChannel;
  final double totalSpend;
  final double totalPaid;

  /// Still owed to suppliers: the sum of the rows' Balance, so it
  /// equals the table's Balance total. Overpaid purchases count
  /// as 0.
  final double totalOutstanding;
  final int overpaidCount;
  final int adjustedCount;

  /// Sum of the known item counts; [itemsUnknownCount] purchases
  /// have no line data.
  final double totalItems;
  final int itemsUnknownCount;
  final int distinctSuppliers;
  final int noSupplierPurchases;
  final int distinctStaff;
  final int noStaffPurchases;

  const PurchaseSummaryStats({
    required this.totalPurchases,
    required this.countByStatus,
    required this.countByChannel,
    required this.totalSpend,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.overpaidCount,
    required this.adjustedCount,
    required this.totalItems,
    required this.itemsUnknownCount,
    required this.distinctSuppliers,
    required this.noSupplierPurchases,
    required this.distinctStaff,
    required this.noStaffPurchases,
  });

  /// Spend per purchase; 0 without purchases.
  double get averagePurchaseValue =>
      totalPurchases == 0 ? 0 : totalSpend / totalPurchases;

  int statusCount(PurchaseStatus s) => countByStatus[s] ?? 0;
  int channelCount(String key) => countByChannel[key] ?? 0;
}

/// One row of the payment status summary.
class PurchaseStatusSummary {
  final PurchaseStatus status;
  final int purchaseCount;
  final double value;
  final double paid;
  final double outstanding;
  final double? countShare;
  final double? valueShare;

  const PurchaseStatusSummary({
    required this.status,
    required this.purchaseCount,
    required this.value,
    required this.paid,
    required this.outstanding,
    required this.countShare,
    required this.valueShare,
  });
}

/// One row of the payment channel summary. Channels are exclusive,
/// so a Split purchase is counted once. [key] is the table's
/// channel filter key.
class PurchaseChannelSummary {
  final String key;
  final String label;
  final int purchaseCount;
  final double value;
  final double paid;

  /// Still owed, as the table's Balance.
  final double balance;
  final double? countShare;
  final double? valueShare;

  const PurchaseChannelSummary({
    required this.key,
    required this.label,
    required this.purchaseCount,
    required this.value,
    required this.paid,
    required this.balance,
    required this.countShare,
    required this.valueShare,
  });

  bool get isNone => key == purchaseReportNoneKey;
}

enum PurchaseSummarySortField {
  purchaseCount,
  spend,
  balance,
  lastDate,
}

/// Aggregates rows that already passed the period and filters
/// (`PurchaseReportQuery.filterAndSort`). Every purchase is counted
/// once per section.
class PurchaseSummaryBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  static PurchaseSummaryStats stats(
    List<PurchaseReportRow> rows,
  ) {
    final byStatus = <PurchaseStatus, int>{};
    final byChannel = <String, int>{};
    final suppliers = <String>{};
    final staff = <String>{};
    double spend = 0;
    double paid = 0;
    double outstanding = 0;
    int overpaid = 0;
    int adjusted = 0;
    double items = 0;
    int itemsUnknown = 0;
    int noSupplier = 0;
    int noStaff = 0;

    for (final r in rows) {
      byStatus[r.status] = (byStatus[r.status] ?? 0) + 1;
      byChannel[r.channelKey] =
          (byChannel[r.channelKey] ?? 0) + 1;
      spend += r.total;
      paid += r.paid;
      outstanding += r.balance;
      if (r.overpaid) overpaid++;
      if (r.hasAdjustment) adjusted++;
      if (r.items == null) {
        itemsUnknown++;
      } else {
        items += r.items!;
      }
      final sup = r.supplierKey;
      if (sup == null) {
        noSupplier++;
      } else {
        suppliers.add(sup);
      }
      final s = r.staffKey;
      if (s == null) {
        noStaff++;
      } else {
        staff.add(s);
      }
    }

    return PurchaseSummaryStats(
      totalPurchases: rows.length,
      countByStatus: byStatus,
      countByChannel: byChannel,
      totalSpend: spend,
      totalPaid: paid,
      totalOutstanding: outstanding,
      overpaidCount: overpaid,
      adjustedCount: adjusted,
      totalItems: items,
      itemsUnknownCount: itemsUnknown,
      distinctSuppliers: suppliers.length,
      noSupplierPurchases: noSupplier,
      distinctStaff: staff.length,
      noStaffPurchases: noStaff,
    );
  }

  /// Groups by [key]. Each group shows its most recent name. The
  /// "none" group (if any) is labelled [noneLabel]. Sorted by
  /// spend, largest first, with the none group last.
  static List<PurchaseSummaryGroup> groupBy(
    List<PurchaseReportRow> rows, {
    required String? Function(PurchaseReportRow) key,
    required String? Function(PurchaseReportRow) name,
    required String fallbackName,
    required String noneLabel,
  }) {
    final newestFirst = List<PurchaseReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, PurchaseSummaryGroup>{};
    double total = 0;
    for (final r in newestFirst) {
      final k = key(r) ?? purchaseReportNoneKey;
      final g = groups.putIfAbsent(
        k,
        () => PurchaseSummaryGroup(
          k,
          k == purchaseReportNoneKey
              ? noneLabel
              : name(r) ?? fallbackName,
        ),
      );
      g.add(r);
      total += r.total;
    }
    for (final g in groups.values) {
      g.spendShare = _share(g.spend, total);
    }
    return sortGroups(
      groups.values.toList(),
      field: PurchaseSummarySortField.spend,
      ascending: false,
    );
  }

  static List<PurchaseSummaryGroup> suppliers(
    List<PurchaseReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.supplierKey,
    name: (r) => r.supplierName,
    fallbackName: 'Not Set',
    noneLabel: purchasesNoSupplierLabel,
  );

  static List<PurchaseSummaryGroup> staff(
    List<PurchaseReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.staffKey,
    name: (r) => r.staffName,
    fallbackName: 'Not Set',
    noneLabel: purchasesNoStaffLabel,
  );

  static List<PurchaseSummaryGroup> departments(
    List<PurchaseReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    fallbackName: 'No Department',
    noneLabel: 'No Department',
  );

  static int _tieBreak(
    PurchaseSummaryGroup a,
    PurchaseSummaryGroup b,
  ) {
    final n = a.label.toLowerCase().compareTo(
      b.label.toLowerCase(),
    );
    return n != 0 ? n : a.key.compareTo(b.key);
  }

  /// Highest spend first; ties: more purchases, then name, then
  /// key. The none group is never ranked.
  static List<PurchaseSummaryGroup> top3(
    List<PurchaseSummaryGroup> groups,
  ) {
    final ranked =
        groups.where((g) => !g.isNone).toList()
          ..sort((a, b) {
            final c = b.spend.compareTo(a.spend);
            if (c != 0) return c;
            final n = b.purchaseCount.compareTo(
              a.purchaseCount,
            );
            return n != 0 ? n : _tieBreak(a, b);
          });
    return ranked.take(3).toList();
  }

  /// Lowest spend first, among groups with at least one purchase
  /// in the period; ties: fewer purchases, then name, then key.
  static List<PurchaseSummaryGroup> least3(
    List<PurchaseSummaryGroup> groups,
  ) {
    final ranked =
        groups
            .where((g) => !g.isNone && g.purchaseCount > 0)
            .toList()
          ..sort((a, b) {
            final c = a.spend.compareTo(b.spend);
            if (c != 0) return c;
            final n = a.purchaseCount.compareTo(
              b.purchaseCount,
            );
            return n != 0 ? n : _tieBreak(a, b);
          });
    return ranked.take(3).toList();
  }

  /// Sorted copy; the none group always stays last.
  static List<PurchaseSummaryGroup> sortGroups(
    List<PurchaseSummaryGroup> groups, {
    required PurchaseSummarySortField field,
    required bool ascending,
  }) {
    int value(
      PurchaseSummaryGroup a,
      PurchaseSummaryGroup b,
    ) {
      switch (field) {
        case PurchaseSummarySortField.purchaseCount:
          return a.purchaseCount.compareTo(b.purchaseCount);
        case PurchaseSummarySortField.spend:
          return a.spend.compareTo(b.spend);
        case PurchaseSummarySortField.balance:
          return a.balance.compareTo(b.balance);
        case PurchaseSummarySortField.lastDate:
          final x = a.lastDate;
          final y = b.lastDate;
          if (x == null && y == null) return 0;
          if (x == null) return -1;
          if (y == null) return 1;
          return x.compareTo(y);
      }
    }

    return List<PurchaseSummaryGroup>.from(groups)
      ..sort((a, b) {
        if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
        final c = value(a, b);
        if (c != 0) return ascending ? c : -c;
        return _tieBreak(a, b);
      });
  }

  /// Paid, Partly Paid, Unpaid, always in that order.
  static List<PurchaseStatusSummary> statuses(
    List<PurchaseReportRow> rows,
  ) {
    double total = 0;
    for (final r in rows) {
      total += r.total;
    }
    return PurchaseStatus.values.map((s) {
      final of = rows.where((r) => r.status == s);
      double value = 0;
      double paid = 0;
      double outstanding = 0;
      int n = 0;
      for (final r in of) {
        n++;
        value += r.total;
        paid += r.paid;
        outstanding += r.balance;
      }
      return PurchaseStatusSummary(
        status: s,
        purchaseCount: n,
        value: value,
        paid: paid,
        outstanding: outstanding,
        countShare:
            rows.isEmpty ? null : n / rows.length * 100,
        valueShare: _share(value, total),
      );
    }).toList();
  }

  /// Cash, Bank, Split, then Unpaid, always in that order.
  static List<PurchaseChannelSummary> channels(
    List<PurchaseReportRow> rows,
  ) {
    final count = <String, int>{};
    final value = <String, double>{};
    final paid = <String, double>{};
    final balance = <String, double>{};
    double total = 0;
    for (final r in rows) {
      final k = r.channelKey;
      count[k] = (count[k] ?? 0) + 1;
      value[k] = (value[k] ?? 0) + r.total;
      paid[k] = (paid[k] ?? 0) + r.paid;
      balance[k] = (balance[k] ?? 0) + r.balance;
      total += r.total;
    }
    return PurchaseReportOptions.channels().map((o) {
      final n = count[o.key] ?? 0;
      final v = value[o.key] ?? 0;
      return PurchaseChannelSummary(
        key: o.key,
        label: o.label,
        purchaseCount: n,
        value: v,
        paid: paid[o.key] ?? 0,
        balance: balance[o.key] ?? 0,
        countShare:
            rows.isEmpty ? null : n / rows.length * 100,
        valueShare: _share(v, total),
      );
    }).toList();
  }

  /// The analysis's filters with one more key set, for opening the
  /// table on exactly the purchases of an analysis row.
  static PurchaseReportFilters handoff(
    PurchaseReportFilters base, {
    String? staffKey,
    String? supplierKey,
    String? departmentKey,
    String? channelKey,
    PurchaseStatus? status,
  }) {
    final f = base.copy();
    if (staffKey != null) f.staffKey = staffKey;
    if (supplierKey != null) f.supplierKey = supplierKey;
    if (departmentKey != null) {
      f.departmentKey = departmentKey;
    }
    if (channelKey != null) f.channelKey = channelKey;
    if (status != null) f.status = status;
    return f;
  }

  /// Rows in [period] (no other filter: the analysis has none).
  static PurchaseSummaryResult build({
    required List<PurchaseReportRow> rows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    TimeOfDay? closingTime,
    DateTime? now,
  }) {
    final inPeriod = PurchaseReportQuery.filterAndSort(
      rows: rows,
      period: period,
      filters: PurchaseReportFilters(),
      sortField: PurchasesSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      closingTime: closingTime,
    );
    final suppliers = PurchaseSummaryBuilder.suppliers(inPeriod);
    final range = PurchaseTrendBuilder.span(
      rows: inPeriod,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    return PurchaseSummaryResult(
      rows: inPeriod,
      stats: PurchaseSummaryBuilder.stats(inPeriod),
      suppliers: suppliers,
      staff: PurchaseSummaryBuilder.staff(inPeriod),
      departments:
          departmentsEnabled
              ? PurchaseSummaryBuilder.departments(inPeriod)
              : const [],
      statuses: PurchaseSummaryBuilder.statuses(inPeriod),
      channels: PurchaseSummaryBuilder.channels(inPeriod),
      topSuppliers: PurchaseSummaryBuilder.top3(suppliers),
      leastSuppliers: PurchaseSummaryBuilder.least3(suppliers),
      trend: PurchaseTrendBuilder.build(
        rows: inPeriod,
        period: period,
        now: now,
        closingTime: closingTime,
      ),
      interval:
          range == null
              ? null
              : ReceiptsTrendBuilder.intervalFor(
                range.start,
                range.end,
              ),
    );
  }

  /// Rows of [tab], in their built order: spend, largest first,
  /// for groups; the fixed order for Status and Channel.
  static List<PurchaseBreakdownRow> breakdown(
    PurchaseSummaryResult result,
    PurchaseBreakdownTab tab, {
    PurchaseReportFilters? base,
  }) {
    final b = base ?? PurchaseReportFilters();
    PurchaseBreakdownRow group(
      PurchaseSummaryGroup g,
      PurchaseReportFilters filters,
    ) => PurchaseBreakdownRow(
      id: '${tab.name}-${g.key}',
      key: g.key,
      label: g.label,
      isNone: g.isNone,
      count: g.purchaseCount,
      spend: g.spend,
      paid: g.paid,
      balance: g.balance,
      lastDate: g.lastDate,
      share: g.spendShare,
      filters: filters,
    );

    switch (tab) {
      case PurchaseBreakdownTab.suppliers:
        return [
          for (final g in result.suppliers)
            group(
              g,
              PurchaseSummaryBuilder.handoff(b, supplierKey: g.key),
            ),
        ];
      case PurchaseBreakdownTab.staff:
        return [
          for (final g in result.staff)
            group(
              g,
              PurchaseSummaryBuilder.handoff(b, staffKey: g.key),
            ),
        ];
      case PurchaseBreakdownTab.departments:
        return [
          for (final g in result.departments)
            group(
              g,
              PurchaseSummaryBuilder.handoff(
                b,
                departmentKey: g.key,
              ),
            ),
        ];
      case PurchaseBreakdownTab.status:
        return [
          for (final s in result.statuses)
            PurchaseBreakdownRow(
              id: '${tab.name}-${s.status.name}',
              key: s.status.name,
              label: s.status.label,
              isNone: false,
              count: s.purchaseCount,
              spend: s.value,
              paid: s.paid,
              balance: s.outstanding,
              lastDate: null,
              share: s.valueShare,
              filters: PurchaseSummaryBuilder.handoff(
                b,
                status: s.status,
              ),
            ),
        ];
      case PurchaseBreakdownTab.channel:
        return [
          for (final c in result.channels)
            PurchaseBreakdownRow(
              id: '${tab.name}-${c.key}',
              key: c.key,
              label: c.label,
              isNone: c.isNone,
              count: c.purchaseCount,
              spend: c.value,
              paid: c.paid,
              balance: c.balance,
              lastDate: null,
              share: c.valueShare,
              filters: PurchaseSummaryBuilder.handoff(
                b,
                channelKey: c.key,
              ),
            ),
        ];
    }
  }

  /// Sorted copy. A null [field] keeps the built order. The none
  /// row is always last; nulls sink to the bottom; ties: label,
  /// then key.
  static List<PurchaseBreakdownRow> sortBreakdown(
    List<PurchaseBreakdownRow> rows, {
    required PurchaseBreakdownSortField? field,
    required bool ascending,
  }) {
    final order = {
      for (var i = 0; i < rows.length; i++) rows[i].id: i,
    };
    int compare(PurchaseBreakdownRow a, PurchaseBreakdownRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case null:
          return order[a.id]!.compareTo(order[b.id]!);
        case PurchaseBreakdownSortField.name:
          c = PurchaseReportQuery.cmp(
            a.label.toLowerCase(),
            b.label.toLowerCase(),
            ascending,
          );
          break;
        case PurchaseBreakdownSortField.count:
          c = PurchaseReportQuery.cmp(a.count, b.count, ascending);
          break;
        case PurchaseBreakdownSortField.spend:
          c = PurchaseReportQuery.cmp(a.spend, b.spend, ascending);
          break;
        case PurchaseBreakdownSortField.paid:
          c = PurchaseReportQuery.cmp(a.paid, b.paid, ascending);
          break;
        case PurchaseBreakdownSortField.balance:
          c = PurchaseReportQuery.cmp(
            a.balance,
            b.balance,
            ascending,
          );
          break;
        case PurchaseBreakdownSortField.lastDate:
          c = PurchaseReportQuery.cmp(
            a.lastDate,
            b.lastDate,
            ascending,
          );
          break;
        case PurchaseBreakdownSortField.share:
          c = PurchaseReportQuery.cmp(a.share, b.share, ascending);
          break;
      }
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(
        b.label.toLowerCase(),
      );
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<PurchaseBreakdownRow>.from(rows)..sort(compare);
  }
}

/// One bucket of the spend trend and activity charts.
class PurchaseTrendPoint {
  final DateTime start;
  double spend = 0;
  double paid = 0;
  int paidCount = 0;
  int partlyPaidCount = 0;
  int unpaidCount = 0;

  PurchaseTrendPoint(this.start);

  int get purchaseCount =>
      paidCount + partlyPaidCount + unpaidCount;
}

/// Trend buckets by business date, using the same closing time as
/// the report period. Intervals as the receipts trend.
class PurchaseTrendBuilder {
  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  /// First and last business day the chart covers. All time runs
  /// from the earliest purchase to today. Null without purchases
  /// in an all-time period.
  static DateTimeRange? span({
    required List<PurchaseReportRow> rows,
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
    if (rows.isEmpty) return null;
    var first = ReceiptsTrendBuilder.businessDate(
      rows.first.createdAt,
      closingTime: closingTime,
    );
    var last = _dateOnly(
      resolveBusinessDate(
        now,
        customClosingTime: closingTime,
      ),
    );
    for (final r in rows) {
      final d = ReceiptsTrendBuilder.businessDate(
        r.createdAt,
        closingTime: closingTime,
      );
      if (d.isBefore(first)) first = d;
      if (d.isAfter(last)) last = d;
    }
    return DateTimeRange(start: first, end: last);
  }

  /// Buckets from the start to the end of the period, empty ones
  /// included (as 0). [rows] must already be in the period.
  static List<PurchaseTrendPoint> build({
    required List<PurchaseReportRow> rows,
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
    final interval = ReceiptsTrendBuilder.intervalFor(
      range.start,
      range.end,
    );

    final points = <PurchaseTrendPoint>[];
    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      for (var h = 0; h < 24; h++) {
        points.add(
          PurchaseTrendPoint(
            dayStart.add(Duration(hours: h)),
          ),
        );
      }
      for (final r in rows) {
        final i = r.createdAt
            .toLocal()
            .difference(dayStart)
            .inHours
            .clamp(0, 23);
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

    final byStart = <DateTime, PurchaseTrendPoint>{};
    final last = bucketOf(range.end);
    for (
      var d = bucketOf(range.start);
      !d.isAfter(last);
      d = next(d)
    ) {
      final p = PurchaseTrendPoint(d);
      points.add(p);
      byStart[d] = p;
    }
    for (final r in rows) {
      final d = bucketOf(
        ReceiptsTrendBuilder.businessDate(
          r.createdAt,
          closingTime: closingTime,
        ),
      );
      final p = byStart[d];
      if (p != null) _add(p, r);
    }
    return points;
  }

  static void _add(
    PurchaseTrendPoint p,
    PurchaseReportRow r,
  ) {
    p.spend += r.total;
    p.paid += r.paid;
    switch (r.status) {
      case PurchaseStatus.paid:
        p.paidCount++;
        break;
      case PurchaseStatus.partlyPaid:
        p.partlyPaidCount++;
        break;
      case PurchaseStatus.unpaid:
        p.unpaidCount++;
        break;
    }
  }
}

/// Everything the analysis page shows for one period.
class PurchaseSummaryResult {
  /// Rows in the period.
  final List<PurchaseReportRow> rows;
  final PurchaseSummaryStats stats;
  final List<PurchaseSummaryGroup> suppliers;
  final List<PurchaseSummaryGroup> staff;

  /// Empty when departments are off.
  final List<PurchaseSummaryGroup> departments;
  final List<PurchaseStatusSummary> statuses;
  final List<PurchaseChannelSummary> channels;
  final List<PurchaseSummaryGroup> topSuppliers;
  final List<PurchaseSummaryGroup> leastSuppliers;
  final List<PurchaseTrendPoint> trend;

  /// Null without a chart (all time with no purchases).
  final ReceiptsTrendInterval? interval;

  const PurchaseSummaryResult({
    required this.rows,
    required this.stats,
    required this.suppliers,
    required this.staff,
    required this.departments,
    required this.statuses,
    required this.channels,
    required this.topSuppliers,
    required this.leastSuppliers,
    required this.trend,
    required this.interval,
  });
}

enum PurchaseBreakdownTab {
  suppliers,
  staff,
  departments,
  status,
  channel,
}

extension PurchaseBreakdownTabLabel on PurchaseBreakdownTab {
  String get label {
    switch (this) {
      case PurchaseBreakdownTab.suppliers:
        return 'Suppliers';
      case PurchaseBreakdownTab.staff:
        return 'Staff';
      case PurchaseBreakdownTab.departments:
        return 'Departments';
      case PurchaseBreakdownTab.status:
        return 'Status';
      case PurchaseBreakdownTab.channel:
        return 'Channel';
    }
  }

  /// Supplier / staff / department rows have a last purchase.
  bool get isGroupTab =>
      this == PurchaseBreakdownTab.suppliers ||
      this == PurchaseBreakdownTab.staff ||
      this == PurchaseBreakdownTab.departments;
}

/// One row of a breakdown table. [filters] open the table on
/// exactly its purchases.
class PurchaseBreakdownRow {
  /// Unique within the page: tab and key.
  final String id;
  final String key;
  final String label;

  /// The "No supplier" / "No staff" / "Unpaid" row, always last.
  final bool isNone;
  final int count;
  final double spend;
  final double paid;
  final double balance;
  final DateTime? lastDate;

  /// Spend / total spend * 100.
  final double? share;
  final PurchaseReportFilters filters;

  const PurchaseBreakdownRow({
    required this.id,
    required this.key,
    required this.label,
    required this.isNone,
    required this.count,
    required this.spend,
    required this.paid,
    required this.balance,
    required this.lastDate,
    required this.share,
    required this.filters,
  });
}

enum PurchaseBreakdownSortField {
  name,
  count,
  spend,
  paid,
  balance,
  lastDate,
  share,
}
