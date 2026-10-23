import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

/// Totals for one item, category, staff member, customer,
/// sub-staff member or department. [key] is the filter key the
/// table opens on: [receiptsReportNoneKey] for lines without one,
/// [itemSalesDeletedItemKey] for deleted items.
///
/// Revenue is line revenue, every receipt type included (as the
/// table's Revenue).
class ItemSalesSummaryGroup {
  final String key;
  final String label;
  int lineCount = 0;
  final Set<ReceiptsReportRow> _receipts = {};
  double revenue = 0;

  /// revenue - cost, missing costs counted as 0.
  double profit = 0;
  int costMissingCount = 0;
  DateTime? lastDate;

  /// revenue / total revenue * 100; null when the total is not
  /// above 0.
  double? revenueShare;

  ItemSalesSummaryGroup(this.key, this.label);

  /// "No item ID", "No Category", "Unknown (deleted item)", "No
  /// Customer" and the like: listed last, never ranked.
  bool get isNone =>
      key == receiptsReportNoneKey ||
      key == itemSalesDeletedItemKey;

  int get receiptCount => _receipts.length;

  /// profit / revenue * 100. Null when revenue is not above 0.
  double? get margin =>
      revenue > 0 ? (profit / revenue) * 100 : null;

  void add(ItemSalesRow r) {
    lineCount++;
    _receipts.add(r.parent);
    revenue += r.revenue;
    profit += r.profit;
    if (r.costMissing) costMissingCount++;
    if (lastDate == null || r.createdAt.isAfter(lastDate!)) {
      lastDate = r.createdAt;
    }
  }
}

/// Statistic cards.
class ItemSalesSummaryStats {
  final int totalLines;
  final int distinctItems;
  final int noItemIdLines;
  final int receiptCount;
  final int distinctCategories;
  final Map<ReceiptType, int> linesByType;
  final double totalRevenue;
  final double totalProfit;
  final int costMissingCount;
  final double totalDiscount;
  final int customPriceLines;
  final int wholesaleLines;
  final int voidLines;
  final int distinctCustomers;
  final int walkInReceipts;
  final int distinctStaff;
  final int noStaffReceipts;

  const ItemSalesSummaryStats({
    required this.totalLines,
    required this.distinctItems,
    required this.noItemIdLines,
    required this.receiptCount,
    required this.distinctCategories,
    required this.linesByType,
    required this.totalRevenue,
    required this.totalProfit,
    required this.costMissingCount,
    required this.totalDiscount,
    required this.customPriceLines,
    required this.wholesaleLines,
    required this.voidLines,
    required this.distinctCustomers,
    required this.walkInReceipts,
    required this.distinctStaff,
    required this.noStaffReceipts,
  });

  /// profit / revenue * 100. Null when revenue is not above 0.
  double? get margin =>
      totalRevenue > 0
          ? (totalProfit / totalRevenue) * 100
          : null;

  /// Revenue per item record; 0 without any.
  double get averageLineRevenue =>
      totalLines == 0 ? 0 : totalRevenue / totalLines;

  int typeCount(ReceiptType t) => linesByType[t] ?? 0;
}

/// One row of the payment channel summary, by the receipt's
/// channel. Channels are exclusive, so a line counts once.
class ItemSalesChannelSummary {
  final ReceiptChannel channel;
  final int lineCount;
  final double value;
  final double? valueShare;

  const ItemSalesChannelSummary({
    required this.channel,
    required this.lineCount,
    required this.value,
    required this.valueShare,
  });
}

/// One row of the transaction type summary, by the receipt's type.
class ItemSalesTypeSummary {
  final ReceiptType type;
  final int lineCount;
  final double value;
  final double profit;
  final int costMissingCount;

  const ItemSalesTypeSummary({
    required this.type,
    required this.lineCount,
    required this.value,
    required this.profit,
    required this.costMissingCount,
  });
}

enum ItemSalesGroupSortField {
  lineCount,
  revenue,
  profit,
  margin,
  lastDate,
}

/// Aggregates rows that already passed the period and filters
/// (`ItemSalesQuery.filterAndSort`).
class ItemSalesAnalysisBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  static ItemSalesSummaryStats stats(List<ItemSalesRow> rows) {
    final items = <String>{};
    final receipts = <ReceiptsReportRow>{};
    final categories = <String>{};
    final byType = <ReceiptType, int>{};
    int noItemId = 0;
    double revenue = 0;
    double profit = 0;
    int costMissing = 0;
    double discount = 0;
    int custom = 0;
    int wholesale = 0;
    int voids = 0;

    for (final r in rows) {
      final k = r.productKey;
      if (k == null) {
        noItemId++;
      } else {
        items.add(k);
      }
      receipts.add(r.parent);
      categories.addAll(r.categoryUuids);
      byType[r.type] = (byType[r.type] ?? 0) + 1;
      revenue += r.revenue;
      profit += r.profit;
      if (r.costMissing) costMissing++;
      discount += r.discount ?? 0;
      if (r.customPrice) custom++;
      if (r.wholesale == true) wholesale++;
      if (r.isVoid) voids++;
    }

    final customers = <String>{};
    final staff = <String>{};
    int walkIns = 0;
    int noStaff = 0;
    for (final p in receipts) {
      final c = p.customerKey;
      if (c == null) {
        walkIns++;
      } else {
        customers.add(c);
      }
      final s = p.staffKey;
      if (s == null) {
        noStaff++;
      } else {
        staff.add(s);
      }
    }

    return ItemSalesSummaryStats(
      totalLines: rows.length,
      distinctItems: items.length,
      noItemIdLines: noItemId,
      receiptCount: receipts.length,
      distinctCategories: categories.length,
      linesByType: byType,
      totalRevenue: revenue,
      totalProfit: profit,
      costMissingCount: costMissing,
      totalDiscount: discount,
      customPriceLines: custom,
      wholesaleLines: wholesale,
      voidLines: voids,
      distinctCustomers: customers.length,
      walkInReceipts: walkIns,
      distinctStaff: staff.length,
      noStaffReceipts: noStaff,
    );
  }

  /// Puts each row in the groups [entries] returns, as (key,
  /// label); the label is taken from the most recent row. Shares
  /// are of the total revenue of [rows], so with a row in several
  /// groups they can add up to more than 100. Sorted by revenue,
  /// largest first, with the none groups last.
  static List<ItemSalesSummaryGroup> _collect(
    List<ItemSalesRow> rows,
    List<(String, String)> Function(ItemSalesRow) entries,
  ) {
    final newestFirst = List<ItemSalesRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, ItemSalesSummaryGroup>{};
    double total = 0;
    for (final r in newestFirst) {
      for (final (k, label) in entries(r)) {
        groups
            .putIfAbsent(
              k,
              () => ItemSalesSummaryGroup(k, label),
            )
            .add(r);
      }
      total += r.revenue;
    }
    for (final g in groups.values) {
      g.revenueShare = _share(g.revenue, total);
    }
    return sortGroups(
      groups.values.toList(),
      field: ItemSalesGroupSortField.revenue,
      ascending: false,
    );
  }

  /// Groups by [key]. Each group shows its most recent name. The
  /// "none" group (if any) is labelled [noneLabel].
  static List<ItemSalesSummaryGroup> groupBy(
    List<ItemSalesRow> rows, {
    required String? Function(ItemSalesRow) key,
    required String? Function(ItemSalesRow) name,
    required String fallbackName,
    required String noneLabel,
  }) => _collect(rows, (r) {
    final k = key(r);
    return [
      k == null
          ? (receiptsReportNoneKey, noneLabel)
          : (k, name(r) ?? fallbackName),
    ];
  });

  static List<ItemSalesSummaryGroup> items(
    List<ItemSalesRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.productKey,
    name: (r) => r.itemName,
    fallbackName: 'Not Set',
    noneLabel: 'No item ID',
  );

  /// A line counts in every category of its item, so category
  /// totals can add up to more than the overall total.
  static List<ItemSalesSummaryGroup> categories(
    List<ItemSalesRow> rows,
  ) => _collect(rows, (r) {
    if (!r.productExists) {
      return [
        (itemSalesDeletedItemKey, itemSalesDeletedItemLabel),
      ];
    }
    if (r.categoryUuids.isEmpty) {
      return [
        (receiptsReportNoneKey, itemSalesNoCategoryLabel),
      ];
    }
    return [
      for (var i = 0; i < r.categoryUuids.length; i++)
        (r.categoryUuids[i], r.categoryNames[i]),
    ];
  });

  static List<ItemSalesSummaryGroup> customers(
    List<ItemSalesRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.parent.customerKey,
    name: (r) => r.parent.customerName,
    fallbackName: 'Not Set',
    noneLabel: 'No Customer',
  );

  static List<ItemSalesSummaryGroup> staff(
    List<ItemSalesRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.parent.staffKey,
    name: (r) => r.parent.staffName,
    fallbackName: 'Not Set',
    noneLabel: 'No Staff',
  );

  static List<ItemSalesSummaryGroup> subStaff(
    List<ItemSalesRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.parent.subStaffKey,
    name: (r) => r.parent.subStaffName,
    fallbackName: 'Not Set',
    noneLabel: 'No Sub-Staff',
  );

  static List<ItemSalesSummaryGroup> departments(
    List<ItemSalesRow> rows,
  ) => groupBy(
    rows,
    key: (r) => r.parent.departmentKey,
    name: (r) => r.parent.departmentName,
    fallbackName: 'Others',
    noneLabel: 'Others',
  );

  static int _tieBreak(
    ItemSalesSummaryGroup a,
    ItemSalesSummaryGroup b,
  ) {
    final n = a.label.toLowerCase().compareTo(
      b.label.toLowerCase(),
    );
    return n != 0 ? n : a.key.compareTo(b.key);
  }

  /// Highest revenue first; ties: more lines, then name, then key.
  /// None groups are never ranked.
  static List<ItemSalesSummaryGroup> top3(
    List<ItemSalesSummaryGroup> groups,
  ) {
    final ranked =
        groups.where((g) => !g.isNone).toList()..sort((a, b) {
          final c = b.revenue.compareTo(a.revenue);
          if (c != 0) return c;
          final n = b.lineCount.compareTo(a.lineCount);
          return n != 0 ? n : _tieBreak(a, b);
        });
    return ranked.take(3).toList();
  }

  /// Lowest revenue first, among groups with at least one line in
  /// the period; ties: fewer lines, then name, then key.
  static List<ItemSalesSummaryGroup> least3(
    List<ItemSalesSummaryGroup> groups,
  ) {
    final ranked =
        groups
            .where((g) => !g.isNone && g.lineCount > 0)
            .toList()
          ..sort((a, b) {
            final c = a.revenue.compareTo(b.revenue);
            if (c != 0) return c;
            final n = a.lineCount.compareTo(b.lineCount);
            return n != 0 ? n : _tieBreak(a, b);
          });
    return ranked.take(3).toList();
  }

  /// Sorted copy; none groups always stay last.
  static List<ItemSalesSummaryGroup> sortGroups(
    List<ItemSalesSummaryGroup> groups, {
    required ItemSalesGroupSortField field,
    required bool ascending,
  }) {
    int nullable<T extends Comparable>(T? x, T? y) {
      if (x == null && y == null) return 0;
      if (x == null) return -1;
      if (y == null) return 1;
      return x.compareTo(y);
    }

    int value(
      ItemSalesSummaryGroup a,
      ItemSalesSummaryGroup b,
    ) {
      switch (field) {
        case ItemSalesGroupSortField.lineCount:
          return a.lineCount.compareTo(b.lineCount);
        case ItemSalesGroupSortField.revenue:
          return a.revenue.compareTo(b.revenue);
        case ItemSalesGroupSortField.profit:
          return a.profit.compareTo(b.profit);
        case ItemSalesGroupSortField.margin:
          return nullable(a.margin, b.margin);
        case ItemSalesGroupSortField.lastDate:
          return nullable(a.lastDate, b.lastDate);
      }
    }

    return List<ItemSalesSummaryGroup>.from(groups)
      ..sort((a, b) {
        if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
        final c = value(a, b);
        if (c != 0) return ascending ? c : -c;
        return _tieBreak(a, b);
      });
  }

  /// Cash, Bank, Customer Account, Split, always in that order.
  static List<ItemSalesChannelSummary> channels(
    List<ItemSalesRow> rows,
  ) {
    final count = <ReceiptChannel, int>{};
    final value = <ReceiptChannel, double>{};
    double total = 0;
    for (final r in rows) {
      final c = r.parent.channel;
      count[c] = (count[c] ?? 0) + 1;
      value[c] = (value[c] ?? 0) + r.revenue;
      total += r.revenue;
    }
    return ReceiptChannel.values.map((c) {
      final v = value[c] ?? 0;
      return ItemSalesChannelSummary(
        channel: c,
        lineCount: count[c] ?? 0,
        value: v,
        valueShare: _share(v, total),
      );
    }).toList();
  }

  /// Sales, Invoice Payment and Order Delivery always; Unknown
  /// only when there is one.
  static List<ItemSalesTypeSummary> types(
    List<ItemSalesRow> rows,
  ) {
    final out = <ItemSalesTypeSummary>[];
    for (final t in ReceiptType.values) {
      final of = rows.where((r) => r.type == t).toList();
      if (t == ReceiptType.unknown && of.isEmpty) continue;
      double value = 0;
      double profit = 0;
      int missing = 0;
      for (final r in of) {
        value += r.revenue;
        profit += r.profit;
        if (r.costMissing) missing++;
      }
      out.add(
        ItemSalesTypeSummary(
          type: t,
          lineCount: of.length,
          value: value,
          profit: profit,
          costMissingCount: missing,
        ),
      );
    }
    return out;
  }

  /// The analysis's filters with one more key set, for opening the
  /// table on exactly the lines of an analysis row.
  static ItemSalesFilters handoff(
    ItemSalesFilters base, {
    String? productKey,
    String? categoryKey,
    String? staffKey,
    String? customerKey,
    String? subStaffKey,
    String? departmentKey,
    ReceiptChannel? channel,
    ReceiptType? type,
  }) {
    final f = base.copy();
    if (productKey != null) f.productKey = productKey;
    if (categoryKey != null) f.categoryKey = categoryKey;
    final r = f.receipt;
    if (staffKey != null) r.staffKey = staffKey;
    if (customerKey != null) r.customerKey = customerKey;
    if (subStaffKey != null) r.subStaffKey = subStaffKey;
    if (departmentKey != null) r.departmentKey = departmentKey;
    if (channel != null) r.channel = channel;
    if (type != null) r.type = type;
    return f;
  }
}

/// One bucket of the trend and activity charts.
class ItemSalesTrendPoint {
  final DateTime start;
  double revenue = 0;
  double profit = 0;
  int sales = 0;
  int invoicePayments = 0;
  int orderDeliveries = 0;
  int unknown = 0;

  ItemSalesTrendPoint(this.start);

  int get lineCount =>
      sales + invoicePayments + orderDeliveries + unknown;
}

/// Trend buckets by business date, the same buckets as the receipt
/// summary's (`ReceiptsTrendBuilder`).
class ItemSalesTrendBuilder {
  static List<ReceiptsReportRow> _receipts(
    List<ItemSalesRow> rows,
  ) => {for (final r in rows) r.parent}.toList();

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  /// First and last business day the chart covers; see
  /// [ReceiptsTrendBuilder.span].
  static DateTimeRange? span({
    required List<ItemSalesRow> rows,
    required ReceiptsReportPeriod period,
    required DateTime now,
    TimeOfDay? closingTime,
  }) => ReceiptsTrendBuilder.span(
    rows: _receipts(rows),
    period: period,
    now: now,
    closingTime: closingTime,
  );

  /// Buckets from the start to the end of the period, empty ones
  /// included (as 0). [rows] must already be in the period.
  static List<ItemSalesTrendPoint> build({
    required List<ItemSalesRow> rows,
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

    final points = <ItemSalesTrendPoint>[];
    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      for (var h = 0; h < 24; h++) {
        points.add(
          ItemSalesTrendPoint(
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

    final byStart = <DateTime, ItemSalesTrendPoint>{};
    final last = bucketOf(range.end);
    for (
      var d = bucketOf(range.start);
      !d.isAfter(last);
      d = next(d)
    ) {
      final p = ItemSalesTrendPoint(d);
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

  static void _add(ItemSalesTrendPoint p, ItemSalesRow r) {
    p.revenue += r.revenue;
    p.profit += r.profit;
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
