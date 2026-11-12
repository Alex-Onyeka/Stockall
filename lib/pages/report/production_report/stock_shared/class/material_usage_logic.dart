// How much of each material was used in a period, split between
// production and manual use, and what it cost. Pure Dart.
//
// - Used in production: the production records' own material lines.
//   That covers productions saved before usage records existed.
// - Used manually: usage records with no production record.
// - Usage records made by a production are skipped: their material is
//   already counted from the production record, so nothing is counted
//   twice.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// One material's use in the period, in its current primary unit.
class ProductionMaterialUsage {
  final String key;
  double productionQty = 0;
  double manualQty = 0;
  double productionCost = 0;
  double manualCost = 0;

  /// Production records that used it (a record counts once).
  int productionRuns = 0;
  int manualRecords = 0;
  DateTime? lastUsed;

  /// Unit cost (one primary unit) of each usage record, by date.
  final List<(DateTime, double)> unitCosts = [];

  ProductionMaterialUsage(this.key);

  double get totalQty => productionQty + manualQty;
  double get totalCost => productionCost + manualCost;
  int get records => productionRuns + manualRecords;
  bool get used => records > 0;

  void _seen(DateTime d) {
    if (lastUsed == null || d.isAfter(lastUsed!)) lastUsed = d;
  }
}

/// A material whose unit cost changed between its first and last usage
/// record of the period.
class ProductionMaterialCostChange {
  final String key;
  final double first;
  final double last;
  final int records;

  const ProductionMaterialCostChange({
    required this.key,
    required this.first,
    required this.last,
    required this.records,
  });

  double get change => last - first;
  double? get changePercent => first > 0 ? change / first * 100 : null;
}

class ProductionMaterialUsageBuilder {
  /// [items] are the materials by uuid, for converting to their current
  /// primary unit; a material not there keeps the unit it was saved in.
  static Map<String, ProductionMaterialUsage> build({
    required List<ProductionRecordRow> records,
    required List<UsageRecordRow> usages,
    required ReceiptsReportPeriod period,
    required Map<String, ProductionStockItem> items,
    TimeOfDay? closingTime,
  }) {
    final out = <String, ProductionMaterialUsage>{};
    ProductionMaterialUsage of(String key) =>
        out.putIfAbsent(key, () => ProductionMaterialUsage(key));

    for (final r in records) {
      if (!period.contains(r.createdAt, closingTime: closingTime)) continue;
      final counted = <String>{};
      for (final line in r.lines) {
        final key = line.key;
        if (key == null) continue;
        final item = items[key];
        final u = of(key);
        u.productionQty +=
            item == null ? line.quantity : line.baseQuantity / item.primaryConversion;
        u.productionCost += line.cost;
        if (counted.add(key)) u.productionRuns++;
        u._seen(r.createdAt);
      }
    }

    for (final r in usages) {
      if (!period.contains(r.createdAt, closingTime: closingTime)) continue;
      final item = items[r.materialKey];
      final base = r.usage.originalCostPerItem;
      final unitCost =
          base == null ? null : (item == null ? r.unitCost : base * item.primaryConversion);
      if (unitCost != null) of(r.materialKey).unitCosts.add((r.createdAt, unitCost));
      // A production's usage record: already counted from the record.
      if (r.source == UsageSource.production) continue;
      final u = of(r.materialKey);
      u.manualQty +=
          item == null ? r.primaryQty : r.usage.getQuantity() / item.primaryConversion;
      u.manualCost += r.cost;
      u.manualRecords++;
      u._seen(r.createdAt);
    }
    for (final u in out.values) {
      u.unitCosts.sort((a, b) => a.$1.compareTo(b.$1));
    }
    return out;
  }

  /// Materials whose unit cost changed in the period: first and last
  /// usage record. Production lines don't carry a unit cost, so only
  /// usage records count.
  static List<ProductionMaterialCostChange> costChanges(
    Map<String, ProductionMaterialUsage> usage,
  ) {
    final out = <ProductionMaterialCostChange>[];
    usage.forEach((key, u) {
      if (u.unitCosts.length < 2) return;
      final first = u.unitCosts.first.$2;
      final last = u.unitCosts.last.$2;
      if ((last - first).abs() < 1e-9) return;
      out.add(
        ProductionMaterialCostChange(
          key: key,
          first: first,
          last: last,
          records: u.unitCosts.length,
        ),
      );
    });
    return out;
  }
}
