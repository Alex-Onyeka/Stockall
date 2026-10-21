import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';

enum ItemPerformanceMetric {
  salesRevenue,
  unitsSold,
  realizedProfit,
}

extension ItemPerformanceMetricExt
    on ItemPerformanceMetric {
  String get label {
    switch (this) {
      case ItemPerformanceMetric.salesRevenue:
        return 'Sales Revenue';
      case ItemPerformanceMetric.unitsSold:
        return 'Units Sold';
      case ItemPerformanceMetric.realizedProfit:
        return 'Realized Profit';
    }
  }
}

enum ItemAnalysisPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
  custom,
}

extension ItemAnalysisPeriodExt on ItemAnalysisPeriod {
  String get label {
    switch (this) {
      case ItemAnalysisPeriod.today:
        return 'Today';
      case ItemAnalysisPeriod.thisWeek:
        return 'This Week';
      case ItemAnalysisPeriod.thisMonth:
        return 'This Month';
      case ItemAnalysisPeriod.allTime:
        return 'All Time';
      case ItemAnalysisPeriod.custom:
        return 'Custom Range';
    }
  }
}

/// Aggregated inventory summary statistics according to section 4.2.
class ItemsReportAnalysisSummary {
  final double totalStockSellingValue;
  final double totalStockCostValue;
  final double totalPotentialProfit;
  final double overallMargin;
  final int totalDistinctItems;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int managedCount;
  final int unmanagedCount;
  final int availableStockItemsCount;

  /// Quantity grouped by primary unit (e.g. {'Pcs': 1200, 'Kg': 45.5}).
  final Map<String, double> stockByPrimaryUnit;

  const ItemsReportAnalysisSummary({
    required this.totalStockSellingValue,
    required this.totalStockCostValue,
    required this.totalPotentialProfit,
    required this.overallMargin,
    required this.totalDistinctItems,
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.managedCount,
    required this.unmanagedCount,
    required this.availableStockItemsCount,
    required this.stockByPrimaryUnit,
  });

  /// Check whether all managed in-stock items share the exact same primary unit.
  bool get hasSingleCompatibleUnit =>
      stockByPrimaryUnit.length <= 1;

  /// If single unit, returns formatted aggregate quantity; otherwise returns null.
  String? get singleUnitFormattedQuantity {
    if (stockByPrimaryUnit.isEmpty) return '0';
    if (stockByPrimaryUnit.length == 1) {
      final entry = stockByPrimaryUnit.entries.first;
      return '${formatLargeNumberDouble(entry.value)} ${entry.key}';
    }
    return null;
  }
}

/// Represents an item's sales performance during a period.
class ItemPerformanceRecord {
  final String uuid;
  final String name;
  final String primaryUnit;
  final double sellingPrice;
  final double costPrice;
  final double? currentQuantity;
  final double salesRevenue;
  final double unitsSold;
  final double realizedProfit;
  final int salesCount;

  const ItemPerformanceRecord({
    required this.uuid,
    required this.name,
    required this.primaryUnit,
    required this.sellingPrice,
    required this.costPrice,
    required this.currentQuantity,
    required this.salesRevenue,
    required this.unitsSold,
    required this.realizedProfit,
    required this.salesCount,
  });

  double valueForMetric(ItemPerformanceMetric metric) {
    switch (metric) {
      case ItemPerformanceMetric.salesRevenue:
        return salesRevenue;
      case ItemPerformanceMetric.unitsSold:
        return unitsSold;
      case ItemPerformanceMetric.realizedProfit:
        return realizedProfit;
    }
  }

  String formattedMetricValue({
    required ItemPerformanceMetric metric,
    required String Function(num) formatMoney,
  }) {
    switch (metric) {
      case ItemPerformanceMetric.salesRevenue:
        return formatMoney(salesRevenue);
      case ItemPerformanceMetric.unitsSold:
        return '${formatLargeNumberDouble(unitsSold)} $primaryUnit';
      case ItemPerformanceMetric.realizedProfit:
        return formatMoney(realizedProfit);
    }
  }
}

/// Represents an item's profit margin according to section 4.5 & 4.6.
class ItemProfitMarginRecord {
  final String uuid;
  final String name;
  final String primaryUnit;
  final double sellingPrice;
  final double costPrice;
  final double margin;

  const ItemProfitMarginRecord({
    required this.uuid,
    required this.name,
    required this.primaryUnit,
    required this.sellingPrice,
    required this.costPrice,
    required this.margin,
  });
}

/// Distribution entry for Category summary table.
class CategoryDistributionItem {
  final int index;
  final String? categoryUuid;
  final String categoryName;
  final int itemCount;
  final double percentage;

  const CategoryDistributionItem({
    required this.index,
    required this.categoryUuid,
    required this.categoryName,
    required this.itemCount,
    required this.percentage,
  });

  bool get isOthers =>
      categoryUuid == null ||
      categoryUuid == itemsReportNoneKey;
}

/// Distribution entry for Department summary table.
class DepartmentDistributionItem {
  final int index;
  final String? departmentUuid;
  final String departmentName;
  final int itemCount;
  final double percentage;

  const DepartmentDistributionItem({
    required this.index,
    required this.departmentUuid,
    required this.departmentName,
    required this.itemCount,
    required this.percentage,
  });

  bool get isOthers =>
      departmentUuid == null ||
      departmentUuid == itemsReportNoneKey;
}

/// Main computation engine for Items Report Analysis.
class ItemsReportAnalysisBuilder {
  /// Builds the 4.2 Summary Statistics.
  static ItemsReportAnalysisSummary buildSummary(
    List<ItemsReportRow> rows,
  ) {
    double totalSelling = 0;
    double totalCost = 0;
    int inStock = 0;
    int lowStock = 0;
    int outOfStock = 0;
    int managed = 0;
    int unmanaged = 0;
    int availableStockCount = 0;
    final Map<String, double> unitMap = {};

    for (final r in rows) {
      if (r.isManaged) {
        managed++;
        final qty = r.quantity ?? 0;
        if (qty > 0) {
          unitMap[r.primaryUnit] =
              (unitMap[r.primaryUnit] ?? 0) + qty;
        }
        if (r.stockLevel != StockLevelFilter.outOfStock) {
          availableStockCount++;
        }

        switch (r.stockLevel) {
          case StockLevelFilter.inStock:
            inStock++;
            break;
          case StockLevelFilter.lowStock:
            lowStock++;
            break;
          case StockLevelFilter.outOfStock:
            outOfStock++;
            break;
          case StockLevelFilter.all:
            break;
        }

        if (r.totalSellingValue != null) {
          totalSelling += r.totalSellingValue!;
        }
        if (r.totalCostValue != null) {
          totalCost += r.totalCostValue!;
        }
      } else {
        unmanaged++;
        availableStockCount++;
      }
    }

    final potentialProfit = totalSelling - totalCost;
    final margin =
        totalSelling > 0
            ? (potentialProfit / totalSelling) * 100
            : 0.0;

    return ItemsReportAnalysisSummary(
      totalStockSellingValue: totalSelling,
      totalStockCostValue: totalCost,
      totalPotentialProfit: potentialProfit,
      overallMargin: margin,
      totalDistinctItems: rows.length,
      inStockCount: inStock,
      lowStockCount: lowStock,
      outOfStockCount: outOfStock,
      managedCount: managed,
      unmanagedCount: unmanaged,
      availableStockItemsCount: availableStockCount,
      stockByPrimaryUnit: unitMap,
    );
  }

  /// Date cutoff resolver for the specified period.
  static DateTimeRange resolveDateRange({
    required ItemAnalysisPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final today = DateTime(
      businessNow.year,
      businessNow.month,
      businessNow.day,
    );
    switch (period) {
      case ItemAnalysisPeriod.today:
        return DateTimeRange(start: today, end: today);
      case ItemAnalysisPeriod.thisWeek:
        // Week starting Monday
        final weekday = today.weekday;
        final startOfWeek = today.subtract(
          Duration(days: weekday - 1),
        );
        return DateTimeRange(
          start: startOfWeek,
          end: today,
        );
      case ItemAnalysisPeriod.thisMonth:
        final startOfMonth = DateTime(
          today.year,
          today.month,
          1,
        );
        return DateTimeRange(
          start: startOfMonth,
          end: today,
        );
      case ItemAnalysisPeriod.allTime:
        return DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 1, 1),
        );
      case ItemAnalysisPeriod.custom:
        return customRange ??
            DateTimeRange(start: today, end: today);
    }
  }

  /// Computes performance rankings for all items (Sections 4.3 & 4.4).
  static List<ItemPerformanceRecord> computePerformance({
    required List<ItemsReportRow> rows,
    required List<TempProductSaleRecord> salesRecords,
    required ItemAnalysisPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    DateTimeRange range = resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    );

    final startCutoff =
        period == ItemAnalysisPeriod.allTime
            ? DateTime(2000, 1, 1)
            : fourAm(range.start);
    final endCutoff =
        period == ItemAnalysisPeriod.allTime
            ? DateTime(2100, 1, 1)
            : fourAmNextDay(range.end);

    // Group sales records by item uuid (fallback to name lowercase)
    final Map<String, List<TempProductSaleRecord>>
    salesByItemUuid = {};
    final Map<String, List<TempProductSaleRecord>>
    salesByItemName = {};

    for (final s in salesRecords) {
      if (s.isVoid == true) continue;
      final created = s.createdAt.toLocal();
      if (created.isBefore(startCutoff) ||
          !created.isBefore(endCutoff)) {
        continue;
      }
      final uuid = s.productUuid;
      if (uuid != null && uuid.isNotEmpty) {
        (salesByItemUuid[uuid] ??= []).add(s);
      }
      final nameKey = s.productName.trim().toLowerCase();
      (salesByItemName[nameKey] ??= []).add(s);
    }

    final List<ItemPerformanceRecord> list = [];

    for (final r in rows) {
      List<TempProductSaleRecord>? matches =
          salesByItemUuid[r.uuid];
      if (matches == null || matches.isEmpty) {
        matches =
            salesByItemName[r.name.trim().toLowerCase()];
      }

      double rev = 0;
      double units = 0;
      double profit = 0;
      int count = 0;

      if (matches != null && matches.isNotEmpty) {
        count = matches.length;
        for (final m in matches) {
          rev += m.revenue;
          units += m.quantity;
          final c = m.costPrice ?? 0;
          profit += (m.revenue - c);
        }
      }

      list.add(
        ItemPerformanceRecord(
          uuid: r.uuid,
          name: r.name,
          primaryUnit: r.primaryUnit,
          sellingPrice: r.sellingPrice,
          costPrice: r.costPrice,
          currentQuantity: r.quantity,
          salesRevenue: rev,
          unitsSold: units,
          realizedProfit: profit,
          salesCount: count,
        ),
      );
    }

    return list;
  }

  /// Best 3 performing items (Section 4.3).
  static List<ItemPerformanceRecord> getBest3({
    required List<ItemPerformanceRecord> records,
    required ItemPerformanceMetric metric,
  }) {
    if (records.isEmpty) return [];
    final copy = List<ItemPerformanceRecord>.from(records);
    copy.sort((a, b) {
      final valA = a.valueForMetric(metric);
      final valB = b.valueForMetric(metric);
      final cmp = valB.compareTo(valA);
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
    });
    return copy.take(3).toList();
  }

  /// Least 3 performing items (Section 4.4).
  static List<ItemPerformanceRecord> getLeast3({
    required List<ItemPerformanceRecord> records,
    required ItemPerformanceMetric metric,
  }) {
    if (records.isEmpty) return [];
    final copy = List<ItemPerformanceRecord>.from(records);
    copy.sort((a, b) {
      final valA = a.valueForMetric(metric);
      final valB = b.valueForMetric(metric);
      final cmp = valA.compareTo(valB);
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
    });
    return copy.take(3).toList();
  }

  /// Profit margin items: Top 3 Highest and Least 3 (Sections 4.5 & 4.6).
  static ({
    List<ItemProfitMarginRecord> top3,
    List<ItemProfitMarginRecord> least3,
  })
  computeProfitMargins(List<ItemsReportRow> rows) {
    final valid = <ItemProfitMarginRecord>[];

    for (final r in rows) {
      // Items with zero or invalid selling prices must be excluded from percentage ranking
      if (r.sellingPrice > 0 &&
          r.costPrice >= 0 &&
          r.margin != null &&
          r.margin!.isFinite) {
        valid.add(
          ItemProfitMarginRecord(
            uuid: r.uuid,
            name: r.name,
            primaryUnit: r.primaryUnit,
            sellingPrice: r.sellingPrice,
            costPrice: r.costPrice,
            margin: r.margin!,
          ),
        );
      }
    }

    if (valid.isEmpty) {
      return (
        top3: <ItemProfitMarginRecord>[],
        least3: <ItemProfitMarginRecord>[],
      );
    }

    final desc = List<ItemProfitMarginRecord>.from(valid)
      ..sort((a, b) {
        final cmp = b.margin.compareTo(a.margin);
        if (cmp != 0) return cmp;
        return a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        );
      });

    final asc = List<ItemProfitMarginRecord>.from(valid)
      ..sort((a, b) {
        final cmp = a.margin.compareTo(b.margin);
        if (cmp != 0) return cmp;
        return a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        );
      });

    return (
      top3: desc.take(3).toList(),
      least3: asc.take(3).toList(),
    );
  }

  /// Category summary table (Section 4.7).
  static List<CategoryDistributionItem>
  computeCategoryDistribution({
    required List<ItemsReportRow> rows,
    required List<CategoryClass> categories,
  }) {
    final nameByUuid = {
      for (final c in categories) c.uuid: c.name,
    };
    final Map<String?, int> counts = {};

    for (final r in rows) {
      if (r.categoryUuids.isEmpty) {
        counts[null] = (counts[null] ?? 0) + 1;
      } else {
        // Distinct item count per category
        for (final catUuid in r.categoryUuids) {
          counts[catUuid] = (counts[catUuid] ?? 0) + 1;
        }
      }
    }

    final total = rows.length;
    final List<CategoryDistributionItem> list = [];

    // Distinct assigned categories
    final knownCategories =
        counts.entries.where((e) => e.key != null).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    int idx = 1;
    for (final e in knownCategories) {
      final name = nameByUuid[e.key] ?? 'Category';
      final pct = total > 0 ? (e.value / total) * 100 : 0.0;
      list.add(
        CategoryDistributionItem(
          index: idx++,
          categoryUuid: e.key,
          categoryName: name,
          itemCount: e.value,
          percentage: pct,
        ),
      );
    }

    // Unassigned items grouped under 'Others'
    final unassigned = counts[null] ?? 0;
    if (unassigned > 0 || list.isEmpty) {
      final pct =
          total > 0 ? (unassigned / total) * 100 : 0.0;
      list.add(
        CategoryDistributionItem(
          index: idx++,
          categoryUuid: null,
          categoryName: 'Others',
          itemCount: unassigned,
          percentage: pct,
        ),
      );
    }

    return list;
  }

  /// Department summary table (Section 4.8).
  static List<DepartmentDistributionItem>
  computeDepartmentDistribution({
    required List<ItemsReportRow> rows,
    required List<DepartmentClass> departments,
  }) {
    final nameByUuid = {
      for (final d in departments) d.uuid: d.name,
    };
    final Map<String?, int> counts = {};

    for (final r in rows) {
      final deptUuid = r.departmentUuid;
      if (deptUuid == null || deptUuid.isEmpty) {
        counts[null] = (counts[null] ?? 0) + 1;
      } else {
        counts[deptUuid] = (counts[deptUuid] ?? 0) + 1;
      }
    }

    final total = rows.length;
    final List<DepartmentDistributionItem> list = [];

    final knownDepts =
        counts.entries.where((e) => e.key != null).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    int idx = 1;
    for (final e in knownDepts) {
      final name = nameByUuid[e.key] ?? 'Department';
      final pct = total > 0 ? (e.value / total) * 100 : 0.0;
      list.add(
        DepartmentDistributionItem(
          index: idx++,
          departmentUuid: e.key,
          departmentName: name,
          itemCount: e.value,
          percentage: pct,
        ),
      );
    }

    final unassigned = counts[null] ?? 0;
    if (unassigned > 0 || list.isEmpty) {
      final pct =
          total > 0 ? (unassigned / total) * 100 : 0.0;
      list.add(
        DepartmentDistributionItem(
          index: idx++,
          departmentUuid: null,
          departmentName: 'Others',
          itemCount: unassigned,
          percentage: pct,
        ),
      );
    }

    return list;
  }

  /// Newly created items (Section 4.9).
  /// Only includes items created within a week's time ([within], defaults to 7 days).
  /// If no items were created within the past week, returns an empty list.
  static List<ItemsReportRow> getNewlyCreatedItems(
    List<ItemsReportRow> rows, {
    int limit = 10,
    Duration within = const Duration(days: 7),
  }) {
    final cutoff = DateTime.now().subtract(within);
    final weekItems =
        rows.where((r) {
          final created = r.createdAt;
          return created != null && created.isAfter(cutoff);
        }).toList();

    weekItems.sort((a, b) {
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return weekItems.take(limit).toList();
  }
}
