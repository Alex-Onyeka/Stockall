import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';

/// Totals for one staff member, customer, sub-staff member or
/// department. [key] is the row key the table filters on, or
/// [receiptsReportNoneKey] for receipts without one.
///
/// Revenue counts every receipt type (as the table's Total
/// Revenue); the average is per Sales receipt.
class ReceiptsSummaryGroup {
  final String key;
  final String label;
  int receiptCount = 0;
  double revenue = 0;

  /// Sum of known profit (missing cost counted as 0).
  double knownProfit = 0;
  int profitKnownCount = 0;
  int profitUnknownCount = 0;
  int costMissingCount = 0;
  int salesCount = 0;
  double salesRevenue = 0;
  DateTime? lastDate;

  /// revenue / total revenue * 100; null when the total is not
  /// above 0.
  double? revenueShare;

  ReceiptsSummaryGroup(this.key, this.label);

  bool get isNone => key == receiptsReportNoneKey;

  /// Per Sales receipt; 0 without Sales receipts.
  double get average =>
      salesCount == 0 ? 0 : salesRevenue / salesCount;

  void add(ReceiptsReportRow r) {
    receiptCount++;
    revenue += r.revenue;
    if (r.profit != null) {
      knownProfit += r.profit!;
      profitKnownCount++;
      if (r.costMissing) costMissingCount++;
    } else {
      profitUnknownCount++;
    }
    if (r.type == ReceiptType.sales) {
      salesCount++;
      salesRevenue += r.revenue;
    }
    if (lastDate == null ||
        r.createdAt.isAfter(lastDate!)) {
      lastDate = r.createdAt;
    }
  }
}

/// Statistic cards (spec 4.2).
class ReceiptsSummaryStats {
  final int totalReceipts;
  final Map<ReceiptType, int> countByType;
  final Map<ReceiptChannel, int> countByChannel;
  final double totalRevenue;
  final double knownProfit;
  final int profitKnownCount;
  final int profitUnknownCount;
  final int costMissingCount;
  final int salesCount;
  final double salesRevenue;
  final double totalDiscount;
  final double totalVat;
  final double totalItems;
  final int distinctCustomers;
  final int walkInReceipts;
  final int distinctStaff;
  final int noStaffReceipts;

  /// Amounts actually paid by each method (stored allocations).
  final double collectedCash;
  final double collectedBank;
  final double collectedAccount;

  const ReceiptsSummaryStats({
    required this.totalReceipts,
    required this.countByType,
    required this.countByChannel,
    required this.totalRevenue,
    required this.knownProfit,
    required this.profitKnownCount,
    required this.profitUnknownCount,
    required this.costMissingCount,
    required this.salesCount,
    required this.salesRevenue,
    required this.totalDiscount,
    required this.totalVat,
    required this.totalItems,
    required this.distinctCustomers,
    required this.walkInReceipts,
    required this.distinctStaff,
    required this.noStaffReceipts,
    required this.collectedCash,
    required this.collectedBank,
    required this.collectedAccount,
  });

  /// Revenue of Sales receipts per Sales receipt; 0 without any.
  double get averageReceiptValue =>
      salesCount == 0 ? 0 : salesRevenue / salesCount;

  int typeCount(ReceiptType t) => countByType[t] ?? 0;
  int channelCount(ReceiptChannel c) =>
      countByChannel[c] ?? 0;
}

/// One row of the payment channel summary (spec 4.10). Channels
/// are exclusive, so a Split receipt is counted once.
class ReceiptsChannelSummary {
  final ReceiptChannel channel;
  final int receiptCount;
  final double value;
  final double? countShare;
  final double? valueShare;

  const ReceiptsChannelSummary({
    required this.channel,
    required this.receiptCount,
    required this.value,
    required this.countShare,
    required this.valueShare,
  });
}

/// One row of the transaction type summary (spec 4.11).
class ReceiptsTypeSummary {
  final ReceiptType type;
  final int receiptCount;
  final double value;
  final double knownProfit;
  final int profitKnownCount;

  const ReceiptsTypeSummary({
    required this.type,
    required this.receiptCount,
    required this.value,
    required this.knownProfit,
    required this.profitKnownCount,
  });
}

enum ReceiptsGroupSortField {
  receiptCount,
  revenue,
  profit,
  lastDate,
}

/// Aggregates rows that already passed the period and filters
/// (`ReceiptsReportQuery.filterAndSort`). Every receipt is counted
/// once per section.
class ReceiptsSummaryBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  static ReceiptsSummaryStats stats(
    List<ReceiptsReportRow> rows,
  ) {
    final byType = <ReceiptType, int>{};
    final byChannel = <ReceiptChannel, int>{};
    final customers = <String>{};
    final staff = <String>{};
    double revenue = 0;
    double profit = 0;
    int known = 0;
    int unknown = 0;
    int costMissing = 0;
    int sales = 0;
    double salesRevenue = 0;
    double discount = 0;
    double vat = 0;
    double items = 0;
    int walkIns = 0;
    int noStaff = 0;
    double cash = 0;
    double bank = 0;
    double account = 0;

    for (final r in rows) {
      byType[r.type] = (byType[r.type] ?? 0) + 1;
      byChannel[r.channel] =
          (byChannel[r.channel] ?? 0) + 1;
      revenue += r.revenue;
      if (r.profit != null) {
        profit += r.profit!;
        known++;
        if (r.costMissing) costMissing++;
      } else {
        unknown++;
      }
      if (r.type == ReceiptType.sales) {
        sales++;
        salesRevenue += r.revenue;
      }
      discount += r.discount ?? 0;
      vat += r.vat ?? 0;
      items += r.items ?? 0;
      final c = r.customerKey;
      if (c == null) {
        walkIns++;
      } else {
        customers.add(c);
      }
      final s = r.staffKey;
      if (s == null) {
        noStaff++;
      } else {
        staff.add(s);
      }
      cash += r.receipt.cashAlt;
      bank += r.receipt.bank;
      account += r.receipt.customerAccount ?? 0;
    }

    return ReceiptsSummaryStats(
      totalReceipts: rows.length,
      countByType: byType,
      countByChannel: byChannel,
      totalRevenue: revenue,
      knownProfit: profit,
      profitKnownCount: known,
      profitUnknownCount: unknown,
      costMissingCount: costMissing,
      salesCount: sales,
      salesRevenue: salesRevenue,
      totalDiscount: discount,
      totalVat: vat,
      totalItems: items,
      distinctCustomers: customers.length,
      walkInReceipts: walkIns,
      distinctStaff: staff.length,
      noStaffReceipts: noStaff,
      collectedCash: cash,
      collectedBank: bank,
      collectedAccount: account,
    );
  }

  /// Groups by [key]. Each group shows its most recent name. The
  /// "none" group (if any) is labelled [noneLabel]. Sorted by
  /// revenue, largest first, with the none group last.
  static List<ReceiptsSummaryGroup> groupBy(
    List<ReceiptsReportRow> rows, {
    required String? Function(ReceiptsReportRow) key,
    required String? Function(ReceiptsReportRow) name,
    required String fallbackName,
    required String noneLabel,
  }) {
    final newestFirst = List<ReceiptsReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, ReceiptsSummaryGroup>{};
    double total = 0;
    for (final r in newestFirst) {
      final k = key(r) ?? receiptsReportNoneKey;
      final g = groups.putIfAbsent(
        k,
        () => ReceiptsSummaryGroup(
          k,
          k == receiptsReportNoneKey
              ? noneLabel
              : name(r) ?? fallbackName,
        ),
      );
      g.add(r);
      total += r.revenue;
    }
    for (final g in groups.values) {
      g.revenueShare = _share(g.revenue, total);
    }
    return sortGroups(
      groups.values.toList(),
      field: ReceiptsGroupSortField.revenue,
      ascending: false,
    );
  }

  static List<ReceiptsSummaryGroup> customers(
    List<ReceiptsReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.customerKey,
    name: (r) => r.customerName,
    fallbackName: 'Not Set',
    noneLabel: 'No Customer',
  );

  static List<ReceiptsSummaryGroup> staff(
    List<ReceiptsReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.staffKey,
    name: (r) => r.staffName,
    fallbackName: 'Not Set',
    noneLabel: 'No Staff',
  );

  static List<ReceiptsSummaryGroup> subStaff(
    List<ReceiptsReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.subStaffKey,
    name: (r) => r.subStaffName,
    fallbackName: 'Not Set',
    noneLabel: 'No Sub-Staff',
  );

  static List<ReceiptsSummaryGroup> departments(
    List<ReceiptsReportRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    fallbackName: 'Others',
    noneLabel: 'Others',
  );

  static int _tieBreak(
    ReceiptsSummaryGroup a,
    ReceiptsSummaryGroup b,
  ) {
    final n = a.label.toLowerCase().compareTo(
      b.label.toLowerCase(),
    );
    return n != 0 ? n : a.key.compareTo(b.key);
  }

  /// Highest revenue first; ties: more receipts, then name, then
  /// key. The none group is never ranked.
  static List<ReceiptsSummaryGroup> top3(
    List<ReceiptsSummaryGroup> groups,
  ) {
    final ranked =
        groups.where((g) => !g.isNone).toList()
          ..sort((a, b) {
            final c = b.revenue.compareTo(a.revenue);
            if (c != 0) return c;
            final n = b.receiptCount.compareTo(
              a.receiptCount,
            );
            return n != 0 ? n : _tieBreak(a, b);
          });
    return ranked.take(3).toList();
  }

  /// Lowest revenue first, among groups with at least one receipt
  /// in the period; ties: fewer receipts, then name, then key.
  static List<ReceiptsSummaryGroup> least3(
    List<ReceiptsSummaryGroup> groups,
  ) {
    final ranked =
        groups
            .where((g) => !g.isNone && g.receiptCount > 0)
            .toList()
          ..sort((a, b) {
            final c = a.revenue.compareTo(b.revenue);
            if (c != 0) return c;
            final n = a.receiptCount.compareTo(
              b.receiptCount,
            );
            return n != 0 ? n : _tieBreak(a, b);
          });
    return ranked.take(3).toList();
  }

  /// Sorted copy; the none group always stays last.
  static List<ReceiptsSummaryGroup> sortGroups(
    List<ReceiptsSummaryGroup> groups, {
    required ReceiptsGroupSortField field,
    required bool ascending,
  }) {
    int value(
      ReceiptsSummaryGroup a,
      ReceiptsSummaryGroup b,
    ) {
      switch (field) {
        case ReceiptsGroupSortField.receiptCount:
          return a.receiptCount.compareTo(b.receiptCount);
        case ReceiptsGroupSortField.revenue:
          return a.revenue.compareTo(b.revenue);
        case ReceiptsGroupSortField.profit:
          return a.knownProfit.compareTo(b.knownProfit);
        case ReceiptsGroupSortField.lastDate:
          final x = a.lastDate;
          final y = b.lastDate;
          if (x == null && y == null) return 0;
          if (x == null) return -1;
          if (y == null) return 1;
          return x.compareTo(y);
      }
    }

    return List<ReceiptsSummaryGroup>.from(groups)
      ..sort((a, b) {
        if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
        final c = value(a, b);
        if (c != 0) return ascending ? c : -c;
        return _tieBreak(a, b);
      });
  }

  /// Cash, Bank, Customer Account, Split, always in that order.
  static List<ReceiptsChannelSummary> channels(
    List<ReceiptsReportRow> rows,
  ) {
    final count = <ReceiptChannel, int>{};
    final value = <ReceiptChannel, double>{};
    double total = 0;
    for (final r in rows) {
      count[r.channel] = (count[r.channel] ?? 0) + 1;
      value[r.channel] =
          (value[r.channel] ?? 0) + r.revenue;
      total += r.revenue;
    }
    return ReceiptChannel.values.map((c) {
      final n = count[c] ?? 0;
      final v = value[c] ?? 0;
      return ReceiptsChannelSummary(
        channel: c,
        receiptCount: n,
        value: v,
        countShare:
            rows.isEmpty ? null : n / rows.length * 100,
        valueShare: _share(v, total),
      );
    }).toList();
  }

  /// Sales, Invoice Payment and Order Delivery always; Unknown
  /// only when there is one.
  static List<ReceiptsTypeSummary> types(
    List<ReceiptsReportRow> rows,
  ) {
    final out = <ReceiptsTypeSummary>[];
    for (final t in ReceiptType.values) {
      final of = rows.where((r) => r.type == t).toList();
      if (t == ReceiptType.unknown && of.isEmpty) continue;
      double value = 0;
      double profit = 0;
      int known = 0;
      for (final r in of) {
        value += r.revenue;
        if (r.profit != null) {
          profit += r.profit!;
          known++;
        }
      }
      out.add(
        ReceiptsTypeSummary(
          type: t,
          receiptCount: of.length,
          value: value,
          knownProfit: profit,
          profitKnownCount: known,
        ),
      );
    }
    return out;
  }

  /// The summary's filters with one more key set, for opening the
  /// table on exactly the receipts of a summary row.
  static ReceiptsReportFilters handoff(
    ReceiptsReportFilters base, {
    String? staffKey,
    String? customerKey,
    String? subStaffKey,
    String? departmentKey,
    ReceiptChannel? channel,
    ReceiptType? type,
  }) {
    final f = base.copy();
    if (staffKey != null) f.staffKey = staffKey;
    if (customerKey != null) f.customerKey = customerKey;
    if (subStaffKey != null) f.subStaffKey = subStaffKey;
    if (departmentKey != null) {
      f.departmentKey = departmentKey;
    }
    if (channel != null) f.channel = channel;
    if (type != null) f.type = type;
    return f;
  }
}

enum ReceiptsTrendInterval {
  hourly,
  daily,
  weekly,
  monthly,
}

/// One bucket of the trend and activity charts.
class ReceiptsTrendPoint {
  final DateTime start;
  double revenue = 0;
  double knownProfit = 0;
  int sales = 0;
  int invoicePayments = 0;
  int orderDeliveries = 0;
  int unknown = 0;

  ReceiptsTrendPoint(this.start);

  int get receiptCount =>
      sales + invoicePayments + orderDeliveries + unknown;
}

/// Trend buckets by business date, using the same closing time as
/// the report period.
class ReceiptsTrendBuilder {
  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// Business day a receipt belongs to.
  static DateTime businessDate(
    DateTime createdAt, {
    TimeOfDay? closingTime,
  }) {
    return _dateOnly(
      resolveBusinessDate(
        createdAt.toLocal(),
        customClosingTime: closingTime,
      ),
    );
  }

  /// One day: hourly. Up to 31 days: daily. Up to 26 weeks:
  /// weekly. Longer: monthly.
  static ReceiptsTrendInterval intervalFor(
    DateTime start,
    DateTime end,
  ) {
    final days =
        _dateOnly(end).difference(_dateOnly(start)).inDays +
        1;
    if (days <= 1) return ReceiptsTrendInterval.hourly;
    if (days <= 31) return ReceiptsTrendInterval.daily;
    if (days <= 26 * 7) return ReceiptsTrendInterval.weekly;
    return ReceiptsTrendInterval.monthly;
  }

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  /// First and last business day the chart covers. All time runs
  /// from the earliest receipt to today. Null without receipts in
  /// an all-time period.
  static DateTimeRange? span({
    required List<ReceiptsReportRow> rows,
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
    var first = businessDate(
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
      final d = businessDate(
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
  static List<ReceiptsTrendPoint> build({
    required List<ReceiptsReportRow> rows,
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
    final interval = intervalFor(range.start, range.end);

    final points = <ReceiptsTrendPoint>[];
    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      for (var h = 0; h < 24; h++) {
        points.add(
          ReceiptsTrendPoint(
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

    final byStart = <DateTime, ReceiptsTrendPoint>{};
    final last = bucketOf(range.end);
    for (
      var d = bucketOf(range.start);
      !d.isAfter(last);
      d = next(d)
    ) {
      final p = ReceiptsTrendPoint(d);
      points.add(p);
      byStart[d] = p;
    }
    for (final r in rows) {
      final d = bucketOf(
        businessDate(r.createdAt, closingTime: closingTime),
      );
      final p = byStart[d];
      if (p != null) _add(p, r);
    }
    return points;
  }

  static void _add(
    ReceiptsTrendPoint p,
    ReceiptsReportRow r,
  ) {
    p.revenue += r.revenue;
    p.knownProfit += r.profit ?? 0;
    switch (r.type) {
      case ReceiptType.sales:
        p.sales++;
        break;
      case ReceiptType.invoicePayment:
        p.invoicePayments++;
        break;
      case ReceiptType.orderDelivery:
        p.orderDeliveries++;
        break;
      case ReceiptType.unknown:
        p.unknown++;
        break;
    }
  }
}
