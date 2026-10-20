import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';

/// Bucket key for storage items that supply no sales item.
const String storageAnalysisUnlinkedKey = '__unlinked__';

/// Bucket key for linked sales items that have no department.
const String storageAnalysisNoDepartmentKey = '__none__';

enum StoragePerformanceMetric {
  transferredOut,
  restocked,
  returnedFromSales,
  movementCount,
}

extension StoragePerformanceMetricExt on StoragePerformanceMetric {
  String get label {
    switch (this) {
      case StoragePerformanceMetric.transferredOut:
        return 'Transferred Out';
      case StoragePerformanceMetric.restocked:
        return 'Restocked';
      case StoragePerformanceMetric.returnedFromSales:
        return 'Returned From Sales';
      case StoragePerformanceMetric.movementCount:
        return 'Movement Count';
    }
  }
}

/// Current stock position of storage (not period based).
class StorageReportAnalysisSummary {
  final int totalDistinctItems;
  final int inStockCount;
  final int outOfStockCount;
  final double totalStockCostValue;

  /// Items without a cost price; they are left out of the cost value.
  final int itemsWithoutCostCount;
  final int oneDimensionalCount;
  final int twoDimensionalCount;
  final int linkedCount;
  final int unlinkedCount;
  final int linkedSalesItemsCount;

  /// Storage quantity grouped by primary unit (e.g. {'Pcs': 1200}).
  final Map<String, double> stockByPrimaryUnit;

  /// Quantity held by linked sales items, in the storage primary units.
  final Map<String, double> quantityInSalesByUnit;

  const StorageReportAnalysisSummary({
    required this.totalDistinctItems,
    required this.inStockCount,
    required this.outOfStockCount,
    required this.totalStockCostValue,
    required this.itemsWithoutCostCount,
    required this.oneDimensionalCount,
    required this.twoDimensionalCount,
    required this.linkedCount,
    required this.unlinkedCount,
    required this.linkedSalesItemsCount,
    required this.stockByPrimaryUnit,
    required this.quantityInSalesByUnit,
  });

  bool get hasSingleCompatibleUnit => stockByPrimaryUnit.length <= 1;

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

/// A storage item's movements during a period, in its primary unit.
class StoragePerformanceRecord {
  final String uuid;
  final String name;
  final String primaryUnit;
  final double? currentQuantity;
  final double transferredOut;
  final double restocked;
  final double returnedFromSales;
  final int movementCount;

  const StoragePerformanceRecord({
    required this.uuid,
    required this.name,
    required this.primaryUnit,
    required this.currentQuantity,
    required this.transferredOut,
    required this.restocked,
    required this.returnedFromSales,
    required this.movementCount,
  });

  bool get isIdle => movementCount == 0;

  double valueForMetric(StoragePerformanceMetric metric) {
    switch (metric) {
      case StoragePerformanceMetric.transferredOut:
        return transferredOut;
      case StoragePerformanceMetric.restocked:
        return restocked;
      case StoragePerformanceMetric.returnedFromSales:
        return returnedFromSales;
      case StoragePerformanceMetric.movementCount:
        return movementCount.toDouble();
    }
  }

  String formattedMetricValue(StoragePerformanceMetric metric) {
    if (metric == StoragePerformanceMetric.movementCount) {
      return '$movementCount ${movementCount == 1 ? 'movement' : 'movements'}';
    }
    return '${formatLargeNumberDouble(valueForMetric(metric))} $primaryUnit';
  }
}

/// Entry of the department and quantity type distribution tables.
class StorageDistributionItem {
  final int index;
  final String key;
  final String label;
  final int itemCount;
  final double percentage;

  const StorageDistributionItem({
    required this.index,
    required this.key,
    required this.label,
    required this.itemCount,
    required this.percentage,
  });
}

/// Main computation engine for Storage Report Analysis.
class StorageReportAnalysisBuilder {
  static StorageReportAnalysisSummary buildSummary(
    List<StorageReportRow> rows,
  ) {
    int inStock = 0;
    int outOfStock = 0;
    double totalCost = 0;
    int withoutCost = 0;
    int twoD = 0;
    int linked = 0;
    int linkedSales = 0;
    final Map<String, double> unitMap = {};
    final Map<String, double> inSalesMap = {};

    for (final r in rows) {
      final qty = r.quantity ?? 0;
      if (qty > 0) {
        inStock++;
        unitMap[r.primaryUnit] = (unitMap[r.primaryUnit] ?? 0) + qty;
      } else {
        outOfStock++;
      }

      if (r.costPrice == null) {
        withoutCost++;
      } else if (r.totalCostValue != null && r.totalCostValue! > 0) {
        totalCost += r.totalCostValue!;
      }

      if (r.isTwoDimensional) twoD++;

      if (r.salesCount > 0) {
        linked++;
        linkedSales += r.salesCount;
      }
      if (r.quantityInSales > 0) {
        inSalesMap[r.primaryUnit] =
            (inSalesMap[r.primaryUnit] ?? 0) + r.quantityInSales;
      }
    }

    return StorageReportAnalysisSummary(
      totalDistinctItems: rows.length,
      inStockCount: inStock,
      outOfStockCount: outOfStock,
      totalStockCostValue: totalCost,
      itemsWithoutCostCount: withoutCost,
      oneDimensionalCount: rows.length - twoD,
      twoDimensionalCount: twoD,
      linkedCount: linked,
      unlinkedCount: rows.length - linked,
      linkedSalesItemsCount: linkedSales,
      stockByPrimaryUnit: unitMap,
      quantityInSalesByUnit: inSalesMap,
    );
  }

  /// Movements of every current storage item during the period.
  ///
  /// [histories] must already be scoped to the shop and department.
  static List<StoragePerformanceRecord> computePerformance({
    required List<StorageReportRow> rows,
    required List<TempStorageProducts> storageProducts,
    required List<StorageItemHistory> histories,
    required StorageHistoryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final range = StorageHistorySummaryBuilder.resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    );
    final contexts = StorageHistorySummaryBuilder.unitContexts(
      storageProducts: storageProducts,
      histories: const [],
    );
    final totals = StorageHistorySummaryBuilder.aggregateByItem(
      histories: histories
          .where(
            (h) => StorageHistorySummaryBuilder.isInPeriod(
              h,
              period: period,
              range: range,
            ),
          )
          .toList(),
      contexts: contexts,
    );

    return rows.map((r) {
      final t = totals[r.uuid] ?? StorageMovementTotals();
      return StoragePerformanceRecord(
        uuid: r.uuid,
        name: r.name,
        primaryUnit: r.primaryUnit,
        currentQuantity: r.quantity,
        transferredOut: t.of(StorageMovementKind.transferredOut),
        restocked: t.restocked,
        returnedFromSales: t.of(StorageMovementKind.returned),
        movementCount: t.movementCount,
      );
    }).toList();
  }

  static List<StoragePerformanceRecord> _ranked(
    List<StoragePerformanceRecord> records,
    StoragePerformanceMetric metric, {
    required bool descending,
  }) {
    final copy = List<StoragePerformanceRecord>.from(records)
      ..sort((a, b) {
        final valA = a.valueForMetric(metric);
        final valB = b.valueForMetric(metric);
        final cmp = descending ? valB.compareTo(valA) : valA.compareTo(valB);
        if (cmp != 0) return cmp;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return copy.take(3).toList();
  }

  /// Best 3 items for [metric].
  static List<StoragePerformanceRecord> getBest3({
    required List<StoragePerformanceRecord> records,
    required StoragePerformanceMetric metric,
  }) =>
      _ranked(records, metric, descending: true);

  /// Least 3 items for [metric].
  static List<StoragePerformanceRecord> getLeast3({
    required List<StoragePerformanceRecord> records,
    required StoragePerformanceMetric metric,
  }) =>
      _ranked(records, metric, descending: false);

  /// Items with no stock movement in the period, by name.
  static List<StoragePerformanceRecord> getIdleItems(
    List<StoragePerformanceRecord> records,
  ) =>
      records.where((r) => r.isIdle).toList()
        ..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

  /// Storage items per department they supply. A storage item counts
  /// once in each department of its linked sales items, so percentages
  /// (of all storage items) can add up to more than 100.
  static List<StorageDistributionItem> computeDepartmentDistribution({
    required List<StorageReportRow> rows,
    required List<DepartmentClass> departments,
  }) {
    final nameByUuid = {for (final d in departments) d.uuid: d.name};
    final Map<String, int> counts = {};
    final Map<String, String> labels = {};

    for (final r in rows) {
      if (r.salesProducts.isEmpty) {
        counts[storageAnalysisUnlinkedKey] =
            (counts[storageAnalysisUnlinkedKey] ?? 0) + 1;
        continue;
      }
      final keys = <String>{};
      for (final p in r.salesProducts) {
        final dept = p.departmentUuid;
        if (dept == null || dept.isEmpty) {
          keys.add(storageAnalysisNoDepartmentKey);
        } else {
          keys.add(dept);
          labels[dept] ??=
              nameByUuid[dept] ?? p.departmentName ?? 'Department';
        }
      }
      for (final k in keys) {
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }

    final total = rows.length;
    final known = counts.entries
        .where(
          (e) =>
              e.key != storageAnalysisUnlinkedKey &&
              e.key != storageAnalysisNoDepartmentKey,
        )
        .toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        if (c != 0) return c;
        return (labels[a.key] ?? '').toLowerCase().compareTo(
              (labels[b.key] ?? '').toLowerCase(),
            );
      });

    final list = <StorageDistributionItem>[];
    int idx = 1;
    void add(String key, String label, int count) {
      list.add(
        StorageDistributionItem(
          index: idx++,
          key: key,
          label: label,
          itemCount: count,
          percentage: total > 0 ? (count / total) * 100 : 0.0,
        ),
      );
    }

    for (final e in known) {
      add(e.key, labels[e.key] ?? 'Department', e.value);
    }
    final noDept = counts[storageAnalysisNoDepartmentKey] ?? 0;
    if (noDept > 0) {
      add(storageAnalysisNoDepartmentKey, 'No Department', noDept);
    }
    final unlinked = counts[storageAnalysisUnlinkedKey] ?? 0;
    if (unlinked > 0 || list.isEmpty) {
      add(storageAnalysisUnlinkedKey, 'Unlinked', unlinked);
    }
    return list;
  }

  /// Simple (1D) and 2-Dimensional storage items.
  static List<StorageDistributionItem> computeQuantityTypeDistribution(
    List<StorageReportRow> rows,
  ) {
    final total = rows.length;
    final twoD = rows.where((r) => r.isTwoDimensional).length;
    final oneD = total - twoD;
    double pct(int c) => total > 0 ? (c / total) * 100 : 0.0;
    return [
      StorageDistributionItem(
        index: 1,
        key: 'simple',
        label: 'Simple',
        itemCount: oneD,
        percentage: pct(oneD),
      ),
      StorageDistributionItem(
        index: 2,
        key: 'two_dimensional',
        label: '2-Dimensional',
        itemCount: twoD,
        percentage: pct(twoD),
      ),
    ];
  }

  /// Newly created storage items, newest first.
  static List<StorageReportRow> getNewlyCreatedItems(
    List<StorageReportRow> rows, {
    int limit = 10,
  }) {
    final copy = List<StorageReportRow>.from(rows)
      ..sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
    return copy.take(limit).toList();
  }
}
