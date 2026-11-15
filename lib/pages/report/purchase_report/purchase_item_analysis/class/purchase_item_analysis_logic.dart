import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

enum PurchaseItemAnalysisTab {
  items,
  suppliers,
  staff,
  departments,
  channels,
  itemTypes,
}

extension PurchaseItemAnalysisTabLabel
    on PurchaseItemAnalysisTab {
  String get label {
    switch (this) {
      case PurchaseItemAnalysisTab.items:
        return 'Items';
      case PurchaseItemAnalysisTab.suppliers:
        return 'Suppliers';
      case PurchaseItemAnalysisTab.staff:
        return 'Staff';
      case PurchaseItemAnalysisTab.departments:
        return 'Departments';
      case PurchaseItemAnalysisTab.channels:
        return 'Channels';
      case PurchaseItemAnalysisTab.itemTypes:
        return 'Item Types';
    }
  }
}

enum PurchaseItemBreakdownSortField {
  name,
  lines,
  qty,
  spend,
  share,
}

class PurchaseItemGroup {
  final String key;
  final String label;
  final Set<String> _purchaseIds = {};
  int lineCount = 0;
  double quantity = 0;
  double spend = 0;
  DateTime? lastDate;
  double? spendShare;

  PurchaseItemGroup(this.key, this.label);

  int get purchaseCount => _purchaseIds.length;
  bool get isNone => key == purchaseReportNoneKey;
  double get averageUnitCost =>
      quantity == 0 ? 0 : spend / quantity;

  void add(PurchaseItemRow r) {
    lineCount++;
    _purchaseIds.add(r.parent.uuid);
    quantity += r.quantity;
    spend += r.lineTotal;
    if (lastDate == null ||
        r.createdAt.isAfter(lastDate!)) {
      lastDate = r.createdAt;
    }
  }
}

class PurchaseItemAnalysisStats {
  final int lineCount;
  final int distinctItems;
  final int purchaseCount;
  final double totalQuantity;
  final double totalSpend;
  final int salesItemLines;
  final double salesItemSpend;
  final int storageItemLines;
  final double storageItemSpend;
  final int customPriceLines;
  final int distinctSuppliers;

  const PurchaseItemAnalysisStats({
    required this.lineCount,
    required this.distinctItems,
    required this.purchaseCount,
    required this.totalQuantity,
    required this.totalSpend,
    required this.salesItemLines,
    required this.salesItemSpend,
    required this.storageItemLines,
    required this.storageItemSpend,
    required this.customPriceLines,
    required this.distinctSuppliers,
  });

  double get averageLineValue =>
      lineCount == 0 ? 0 : totalSpend / lineCount;
  double get averageUnitCost =>
      totalQuantity == 0 ? 0 : totalSpend / totalQuantity;
}

class PurchaseItemTrendPoint {
  final DateTime start;
  final double spend;
  final double quantity;
  final int lineCount;

  const PurchaseItemTrendPoint({
    required this.start,
    required this.spend,
    required this.quantity,
    required this.lineCount,
  });
}

class PurchaseItemBreakdownRow {
  final String id;
  final String key;
  final String label;
  final bool isNone;
  final int lineCount;
  final int purchaseCount;
  final double quantity;
  final double spend;
  final double? spendShare;
  final DateTime? lastDate;
  final PurchaseItemFilters filters;

  const PurchaseItemBreakdownRow({
    required this.id,
    required this.key,
    required this.label,
    required this.isNone,
    required this.lineCount,
    required this.purchaseCount,
    required this.quantity,
    required this.spend,
    required this.spendShare,
    required this.lastDate,
    required this.filters,
  });

  double get averageUnitCost =>
      quantity == 0 ? 0 : spend / quantity;
}

class PurchaseItemAnalysisResult {
  final PurchaseItemAnalysisStats stats;
  final List<PurchaseItemGroup> items;
  final List<PurchaseItemGroup> suppliers;
  final List<PurchaseItemGroup> staff;
  final List<PurchaseItemGroup> departments;
  final List<PurchaseItemGroup> channels;
  final List<PurchaseItemGroup> itemTypes;
  final List<PurchaseItemTrendPoint> trend;
  final ReceiptsTrendInterval? interval;

  const PurchaseItemAnalysisResult({
    required this.stats,
    required this.items,
    required this.suppliers,
    required this.staff,
    required this.departments,
    required this.channels,
    required this.itemTypes,
    required this.trend,
    required this.interval,
  });
}

class PurchaseItemAnalysisBuilder {
  static double? _share(double part, double total) =>
      total <= 0 ? null : part / total * 100;

  static PurchaseItemAnalysisResult build({
    required List<PurchaseItemRow> allRows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    PurchaseItemFilters? filters,
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    final periodRows = PurchaseItemFilterBuilder.inPeriod(
      allRows,
      period,
      closingTime: closingTime,
    );
    final inPeriod =
        filters == null
            ? periodRows
            : PurchaseItemFilterBuilder.filter(
              periodRows,
              filters,
              departmentsEnabled: departmentsEnabled,
            );
    final range = _trendSpan(
      inPeriod,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );

    final itemKeys = <String>{};
    final purchaseIds = <String>{};
    final supplierKeys = <String>{};
    double totalQty = 0;
    double totalSpend = 0;
    int salesLines = 0;
    double salesSpend = 0;
    int storageLines = 0;
    double storageSpend = 0;
    int customPriceLines = 0;

    for (final r in inPeriod) {
      if (r.itemKey != null) itemKeys.add(r.itemKey!);
      purchaseIds.add(r.parent.uuid);
      if (r.effectiveSupplierKey != null) {
        supplierKeys.add(r.effectiveSupplierKey!);
      }
      totalQty += r.quantity;
      totalSpend += r.lineTotal;
      if (r.isStorageItem) {
        storageLines++;
        storageSpend += r.lineTotal;
      } else {
        salesLines++;
        salesSpend += r.lineTotal;
      }
      if (r.customPrice != null) customPriceLines++;
    }

    final stats = PurchaseItemAnalysisStats(
      lineCount: inPeriod.length,
      distinctItems: itemKeys.length,
      purchaseCount: purchaseIds.length,
      totalQuantity: totalQty,
      totalSpend: totalSpend,
      salesItemLines: salesLines,
      salesItemSpend: salesSpend,
      storageItemLines: storageLines,
      storageItemSpend: storageSpend,
      customPriceLines: customPriceLines,
      distinctSuppliers: supplierKeys.length,
    );

    List<PurchaseItemGroup> groupBy(
      String? Function(PurchaseItemRow) keyOf,
      String Function(PurchaseItemRow) labelOf,
      String noneLabel,
    ) {
      final map = <String, PurchaseItemGroup>{};
      for (final r in inPeriod) {
        final k = keyOf(r) ?? purchaseReportNoneKey;
        final label =
            k == purchaseReportNoneKey
                ? noneLabel
                : labelOf(r);
        map
            .putIfAbsent(
              k,
              () => PurchaseItemGroup(k, label),
            )
            .add(r);
      }
      final list = map.values.toList();
      for (final g in list) {
        g.spendShare = _share(g.spend, totalSpend);
      }
      list.sort((a, b) {
        final cmp = b.spend.compareTo(a.spend);
        if (cmp != 0) return cmp;
        return a.label.toLowerCase().compareTo(
          b.label.toLowerCase(),
        );
      });
      return list;
    }

    final items = groupBy(
      (r) => r.itemKey,
      (r) => r.itemName,
      'Unknown Item',
    );
    final suppliers = groupBy(
      (r) => r.effectiveSupplierKey,
      (r) => r.effectiveSupplierLabel,
      purchasesNoSupplierLabel,
    );
    final staff = groupBy(
      (r) => r.staffKey,
      (r) => r.staffLabel,
      purchasesNoStaffLabel,
    );
    final departments =
        departmentsEnabled
            ? groupBy(
              (r) => r.departmentKey,
              (r) => r.departmentLabel,
              'No Department',
            )
            : const <PurchaseItemGroup>[];
    final channels = groupBy(
      (r) => r.channelKey,
      (r) => r.channelLabel,
      'Cash',
    );
    final itemTypes = groupBy(
      (r) => r.isStorageItem ? 'storage' : 'sales',
      (r) => r.itemTypeLabel,
      'Sales Item',
    );

    final trend = _buildTrend(
      inPeriod,
      period: period,
      range: range,
      now: now,
      closingTime: closingTime,
    );

    return PurchaseItemAnalysisResult(
      stats: stats,
      items: items,
      suppliers: suppliers,
      staff: staff,
      departments: departments,
      channels: channels,
      itemTypes: itemTypes,
      trend: trend,
      interval:
          range == null
              ? null
              : ReceiptsTrendBuilder.intervalFor(
                range.start,
                range.end,
              ),
    );
  }

  static DateTimeRange? _trendSpan(
    List<PurchaseItemRow> rows, {
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
    var last = first;
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

  static List<PurchaseItemTrendPoint> _buildTrend(
    List<PurchaseItemRow> rows, {
    required ReceiptsReportPeriod period,
    required DateTimeRange? range,
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    if (range == null || rows.isEmpty) return const [];
    final interval = ReceiptsTrendBuilder.intervalFor(
      range.start,
      range.end,
    );

    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      final spend = List<double>.filled(24, 0);
      final qty = List<double>.filled(24, 0);
      final count = List<int>.filled(24, 0);
      for (final r in rows) {
        final i = r.createdAt
            .toLocal()
            .difference(dayStart)
            .inHours
            .clamp(0, 23);
        spend[i] += r.lineTotal;
        qty[i] += r.quantity;
        count[i] += 1;
      }
      return [
        for (var h = 0; h < 24; h++)
          PurchaseItemTrendPoint(
            start: dayStart.add(Duration(hours: h)),
            spend: spend[h],
            quantity: qty[h],
            lineCount: count[h],
          ),
      ];
    }

    DateTime bucketOf(DateTime d) {
      switch (interval) {
        case ReceiptsTrendInterval.hourly:
        case ReceiptsTrendInterval.daily:
          return DateTime(d.year, d.month, d.day);
        case ReceiptsTrendInterval.weekly:
          final day = DateTime(d.year, d.month, d.day);
          return day.subtract(
            Duration(days: day.weekday - 1),
          );
        case ReceiptsTrendInterval.monthly:
          return DateTime(d.year, d.month, 1);
      }
    }

    DateTime nextBucket(DateTime b) {
      switch (interval) {
        case ReceiptsTrendInterval.hourly:
        case ReceiptsTrendInterval.daily:
          return DateTime(b.year, b.month, b.day + 1);
        case ReceiptsTrendInterval.weekly:
          return DateTime(b.year, b.month, b.day + 7);
        case ReceiptsTrendInterval.monthly:
          return DateTime(b.year, b.month + 1, 1);
      }
    }

    final starts = <DateTime>[];
    var cur = bucketOf(range.start);
    final lastBucket = bucketOf(range.end);
    while (!cur.isAfter(lastBucket)) {
      starts.add(cur);
      cur = nextBucket(cur);
    }
    if (starts.isEmpty) return const [];

    final idxByStart = <DateTime, int>{
      for (var i = 0; i < starts.length; i++) starts[i]: i,
    };
    final spendByIdx = List<double>.filled(
      starts.length,
      0,
    );
    final qtyByIdx = List<double>.filled(starts.length, 0);
    final countByIdx = List<int>.filled(starts.length, 0);

    for (final r in rows) {
      final bDate = ReceiptsTrendBuilder.businessDate(
        r.createdAt,
        closingTime: closingTime,
      );
      final idx = idxByStart[bucketOf(bDate)];
      if (idx == null) continue;
      spendByIdx[idx] += r.lineTotal;
      qtyByIdx[idx] += r.quantity;
      countByIdx[idx] += 1;
    }

    return [
      for (int i = 0; i < starts.length; i++)
        PurchaseItemTrendPoint(
          start: starts[i],
          spend: spendByIdx[i],
          quantity: qtyByIdx[i],
          lineCount: countByIdx[i],
        ),
    ];
  }

  static List<PurchaseItemGroup> top3(
    List<PurchaseItemGroup> groups,
  ) {
    final named = groups.where((g) => !g.isNone).toList();
    return named.take(3).toList();
  }

  static List<PurchaseItemGroup> least3(
    List<PurchaseItemGroup> groups,
  ) {
    final named = groups.where((g) => !g.isNone).toList();
    if (named.length <= 3) return named.reversed.toList();
    return named
        .sublist(named.length - 3)
        .reversed
        .toList();
  }

  static List<PurchaseItemBreakdownRow> breakdown(
    PurchaseItemAnalysisResult result,
    PurchaseItemAnalysisTab tab, {
    PurchaseItemFilters? base,
  }) {
    final b = base ?? PurchaseItemFilters();
    PurchaseItemFilters filtersFor(String key) {
      final f = b.copy();
      switch (tab) {
        case PurchaseItemAnalysisTab.items:
          f.itemKey = key;
          break;
        case PurchaseItemAnalysisTab.suppliers:
          f.supplierKey = key;
          break;
        case PurchaseItemAnalysisTab.staff:
          f.staffKey = key;
          break;
        case PurchaseItemAnalysisTab.departments:
          f.departmentKey = key;
          break;
        case PurchaseItemAnalysisTab.channels:
          f.channelKey = key;
          break;
        case PurchaseItemAnalysisTab.itemTypes:
          f.itemType =
              key == 'storage'
                  ? PurchaseItemTypeFilter.storage
                  : PurchaseItemTypeFilter.sales;
          break;
      }
      return f;
    }

    final List<PurchaseItemGroup> source;
    switch (tab) {
      case PurchaseItemAnalysisTab.items:
        source = result.items;
        break;
      case PurchaseItemAnalysisTab.suppliers:
        source = result.suppliers;
        break;
      case PurchaseItemAnalysisTab.staff:
        source = result.staff;
        break;
      case PurchaseItemAnalysisTab.departments:
        source = result.departments;
        break;
      case PurchaseItemAnalysisTab.channels:
        source = result.channels;
        break;
      case PurchaseItemAnalysisTab.itemTypes:
        source = result.itemTypes;
        break;
    }

    return [
      for (final g in source)
        PurchaseItemBreakdownRow(
          id: '${tab.name}-${g.key}',
          key: g.key,
          label: g.label,
          isNone: g.isNone,
          lineCount: g.lineCount,
          purchaseCount: g.purchaseCount,
          quantity: g.quantity,
          spend: g.spend,
          spendShare: g.spendShare,
          lastDate: g.lastDate,
          filters: filtersFor(g.key),
        ),
    ];
  }

  static List<PurchaseItemBreakdownRow> sortBreakdown(
    List<PurchaseItemBreakdownRow> rows,
    PurchaseItemBreakdownSortField field,
    bool ascending,
  ) {
    final out = List<PurchaseItemBreakdownRow>.from(rows);
    out.sort((a, b) {
      int cmp;
      switch (field) {
        case PurchaseItemBreakdownSortField.name:
          cmp = a.label.toLowerCase().compareTo(
            b.label.toLowerCase(),
          );
          break;
        case PurchaseItemBreakdownSortField.lines:
          cmp = a.lineCount.compareTo(b.lineCount);
          break;
        case PurchaseItemBreakdownSortField.qty:
          cmp = a.quantity.compareTo(b.quantity);
          break;
        case PurchaseItemBreakdownSortField.spend:
          cmp = a.spend.compareTo(b.spend);
          break;
        case PurchaseItemBreakdownSortField.share:
          cmp = (a.spendShare ?? 0).compareTo(
            b.spendShare ?? 0,
          );
          break;
      }
      if (cmp == 0) {
        cmp = a.label.toLowerCase().compareTo(
          b.label.toLowerCase(),
        );
      }
      return ascending ? cmp : -cmp;
    });
    return out;
  }
}
