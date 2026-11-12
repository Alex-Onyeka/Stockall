// The analysis page of the Produced Items and Materials pages (I2 /
// M2): headline cards, movement rankings, distribution by department
// and category, and (produced items) the recorded cost per unit of the
// production runs against the item's cost price. Pure Dart.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Expiring: expired, or expiring within this many days.
const int productionExpiringDays = 30;

/// The movement that adds stock for [kind] (produced / used) and the
/// one that moves it on (to sales / to a department).
ProductionMovementKind productionMainMovement(ProductionStockKind kind) =>
    kind == ProductionStockKind.producedItem
        ? ProductionMovementKind.produced
        : ProductionMovementKind.used;

ProductionMovementKind productionOutMovement(ProductionStockKind kind) =>
    kind == ProductionStockKind.producedItem
        ? ProductionMovementKind.transferredToSales
        : ProductionMovementKind.transferredToDepartment;

/// Quantity by primary unit of [kind] over [rows].
Map<String, double> productionByUnit(
  Iterable<({String unit, double qty})> values,
) {
  final out = <String, double>{};
  for (final v in values) {
    out[v.unit] = (out[v.unit] ?? 0) + v.qty;
  }
  return out;
}

/// The change between two per-unit totals, only when both use one and
/// the same unit (or one side is empty). Null otherwise.
GeneralReportChange? productionUnitChange(
  Map<String, double> current,
  Map<String, double>? previous,
) {
  if (previous == null) return null;
  final units = {
    ...current.entries.where((e) => e.value != 0).map((e) => e.key),
    ...previous.entries.where((e) => e.value != 0).map((e) => e.key),
  };
  if (units.length > 1) return null;
  final u = units.isEmpty ? null : units.first;
  return GeneralReportChange.compare(
    current: u == null ? 0 : current[u] ?? 0,
    previous: u == null ? 0 : previous[u] ?? 0,
  );
}

/// A whole count with thousands separators ("1,250").
String productionCountText(int n) {
  final digits = n.abs().toString();
  final out = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// How a card's value reads.
enum ProductionStockCardKind { count, money, quantities, percent }

/// One headline card. The screen and the export word it from the same
/// values.
class ProductionStockCard {
  final String id;
  final String title;
  final ProductionStockCardKind kind;
  final double? amount;
  final Map<String, double>? byUnit;
  final String subtitle;

  /// Null without a comparison.
  final GeneralReportChange? change;

  /// The values are quantities and the user can't see them.
  final bool masked;

  const ProductionStockCard({
    required this.id,
    required this.title,
    required this.kind,
    this.amount,
    this.byUnit,
    required this.subtitle,
    this.change,
    this.masked = false,
  });

  String valueText(String Function(num) money, String Function(num) number) {
    if (masked) return '****';
    switch (kind) {
      case ProductionStockCardKind.count:
        return productionCountText((amount ?? 0).round());
      case ProductionStockCardKind.money:
        return money(amount ?? 0);
      case ProductionStockCardKind.quantities:
        return productionQuantitiesByUnit(byUnit ?? const {}, number);
      case ProductionStockCardKind.percent:
        return amount == null ? '—' : '${number(amount!)}%';
    }
  }
}

enum ProductionStockAnalysisTab {
  produced,
  transferred,
  net,
  departments,
  categories,
  costPerUnit,

  /// Materials: most used by quantity, by cost, unused in the period,
  /// and unit cost changes.
  usedQuantity,
  usedCost,
  unused,
  costChanges,
}

String productionStockAnalysisTabLabel(
  ProductionStockAnalysisTab tab,
  ProductionStockKind kind,
) {
  switch (tab) {
    case ProductionStockAnalysisTab.produced:
      return productionMainMovement(kind).label;
    case ProductionStockAnalysisTab.transferred:
      return productionOutMovement(kind).label;
    case ProductionStockAnalysisTab.net:
      return 'Net Movement';
    case ProductionStockAnalysisTab.departments:
      return 'Departments';
    case ProductionStockAnalysisTab.categories:
      return 'Categories';
    case ProductionStockAnalysisTab.costPerUnit:
      return 'Cost per Unit';
    case ProductionStockAnalysisTab.usedQuantity:
      return 'Most Used (Qty)';
    case ProductionStockAnalysisTab.usedCost:
      return 'Most Used (Cost)';
    case ProductionStockAnalysisTab.unused:
      return 'Unused';
    case ProductionStockAnalysisTab.costChanges:
      return 'Cost Changes';
  }
}

/// The tabs the page offers: rankings need history and quantity
/// access; Departments only with departments on; Cost per Unit only
/// for produced items with cost access.
List<ProductionStockAnalysisTab> productionStockAnalysisTabs({
  required ProductionStockKind kind,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyAllowed,
}) {
  if (kind == ProductionStockKind.material) {
    // Materials' use comes from production and usage records, not the
    // history, so these tabs don't need history access.
    return [
      if (canSeeQuantity) ProductionStockAnalysisTab.usedQuantity,
      if (canSeeCost) ProductionStockAnalysisTab.usedCost,
      ProductionStockAnalysisTab.unused,
      if (departmentsEnabled) ProductionStockAnalysisTab.departments,
      ProductionStockAnalysisTab.categories,
      if (canSeeCost) ProductionStockAnalysisTab.costChanges,
    ];
  }
  return [
    if (historyAllowed && canSeeQuantity) ...[
      ProductionStockAnalysisTab.produced,
      ProductionStockAnalysisTab.transferred,
      ProductionStockAnalysisTab.net,
    ],
    if (departmentsEnabled) ProductionStockAnalysisTab.departments,
    ProductionStockAnalysisTab.categories,
    if (canSeeCost) ProductionStockAnalysisTab.costPerUnit,
  ];
}

enum ProductionStockAnalysisField {
  name,
  main,
  out,
  rate,
  opening,
  additions,
  reductions,
  net,
  closing,
  items,
  managed,
  stockValue,
  share,
  runs,
  recordedCostPerUnit,
  costPrice,
  difference,
  differencePercent,

  /// Materials.
  usedProduction,
  usedManual,
  usedTotal,
  productionCost,
  manualCost,
  usageCost,
  stock,
  lastUsed,
  firstUnitCost,
  lastUnitCost,
  costChange,
  costChangePercent,
}

class ProductionStockAnalysisColumn {
  final ProductionStockAnalysisField field;
  final String label;
  final ProductionBreakdownKind kind;
  final double width;

  const ProductionStockAnalysisColumn(this.field, this.label, this.kind, this.width);
}

/// The columns of [tab]. The screen and the export both use this list.
List<ProductionStockAnalysisColumn> productionStockAnalysisColumns(
  ProductionStockAnalysisTab tab, {
  required ProductionStockKind kind,
  required bool canSeeCost,
  bool canSeeQuantity = true,
}) {
  ProductionStockAnalysisColumn col(
    ProductionStockAnalysisField f,
    String label,
    ProductionBreakdownKind k, [
    double width = 130,
  ]) => ProductionStockAnalysisColumn(f, label, k, width);
  const text = ProductionBreakdownKind.text;
  const qty = ProductionBreakdownKind.quantity;
  const count = ProductionBreakdownKind.count;
  const money = ProductionBreakdownKind.money;
  const pct = ProductionBreakdownKind.percent;
  const date = ProductionBreakdownKind.date;
  final main = productionMainMovement(kind).label;
  final out = productionOutMovement(kind).label;
  final rate = kind == ProductionStockKind.producedItem
      ? 'Transfer Rate (approx.)'
      : 'Share Moved';
  final itemLabel = kind.singular;
  switch (tab) {
    case ProductionStockAnalysisTab.produced:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.main, main, qty, 140),
        col(ProductionStockAnalysisField.out, out, qty, 170),
        col(ProductionStockAnalysisField.rate, rate, pct, 170),
        col(ProductionStockAnalysisField.net, 'Net', qty, 130),
      ];
    case ProductionStockAnalysisTab.transferred:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.out, out, qty, 170),
        col(ProductionStockAnalysisField.main, main, qty, 140),
        col(ProductionStockAnalysisField.rate, rate, pct, 170),
      ];
    case ProductionStockAnalysisTab.net:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.opening, 'Opening', qty),
        col(ProductionStockAnalysisField.additions, 'Additions', qty),
        col(ProductionStockAnalysisField.reductions, 'Reductions', qty),
        col(ProductionStockAnalysisField.net, 'Net', qty),
        col(ProductionStockAnalysisField.closing, 'Closing', qty),
      ];
    case ProductionStockAnalysisTab.departments:
    case ProductionStockAnalysisTab.categories:
      return [
        col(
          ProductionStockAnalysisField.name,
          tab == ProductionStockAnalysisTab.departments ? 'Department' : 'Category',
          text,
          200,
        ),
        col(ProductionStockAnalysisField.items, kind.plural, count, 130),
        col(ProductionStockAnalysisField.managed, 'Managed', count, 110),
        if (canSeeCost && canSeeQuantity)
          col(ProductionStockAnalysisField.stockValue, 'Stock Value', money, 150),
        col(ProductionStockAnalysisField.share, 'Share', pct, 100),
      ];
    case ProductionStockAnalysisTab.costPerUnit:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.runs, 'Runs', count, 90),
        col(
          ProductionStockAnalysisField.recordedCostPerUnit,
          'Recorded Cost / Unit',
          money,
          170,
        ),
        col(ProductionStockAnalysisField.costPrice, 'Cost Price', money, 140),
        col(ProductionStockAnalysisField.difference, 'Difference', money, 140),
        col(ProductionStockAnalysisField.differencePercent, 'Difference %', pct, 130),
      ];
    case ProductionStockAnalysisTab.usedQuantity:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.usedProduction, 'Used in Production', qty, 160),
        col(ProductionStockAnalysisField.usedManual, 'Used Manually', qty, 150),
        col(ProductionStockAnalysisField.usedTotal, 'Total Used', qty, 140),
        col(ProductionStockAnalysisField.runs, 'Records', count, 100),
      ];
    case ProductionStockAnalysisTab.usedCost:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.productionCost, 'Production Cost', money, 150),
        col(ProductionStockAnalysisField.manualCost, 'Manual Cost', money, 150),
        col(ProductionStockAnalysisField.usageCost, 'Usage Cost', money, 150),
        col(ProductionStockAnalysisField.share, 'Share', pct, 100),
      ];
    case ProductionStockAnalysisTab.unused:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        if (canSeeQuantity) col(ProductionStockAnalysisField.stock, 'Stock', qty, 140),
        if (canSeeCost && canSeeQuantity)
          col(ProductionStockAnalysisField.stockValue, 'Stock Value', money, 150),
        col(ProductionStockAnalysisField.lastUsed, 'Last Used', date, 140),
      ];
    case ProductionStockAnalysisTab.costChanges:
      return [
        col(ProductionStockAnalysisField.name, itemLabel, text, 200),
        col(ProductionStockAnalysisField.firstUnitCost, 'First Unit Cost', money, 150),
        col(ProductionStockAnalysisField.lastUnitCost, 'Last Unit Cost', money, 150),
        col(ProductionStockAnalysisField.costChange, 'Change', money, 130),
        col(ProductionStockAnalysisField.costChangePercent, 'Change %', pct, 110),
        col(ProductionStockAnalysisField.runs, 'Records', count, 100),
      ];
  }
}

/// One row of a tab. [filters] open the stock table on it.
class ProductionStockAnalysisRow {
  final String id;
  final String key;
  final String label;
  final bool isNone;

  /// The primary unit of the quantity columns.
  final String? unit;
  final Map<ProductionStockAnalysisField, Object?> values;
  final ProductionStockFilters filters;

  const ProductionStockAnalysisRow({
    required this.id,
    required this.key,
    required this.label,
    required this.isNone,
    this.unit,
    required this.values,
    required this.filters,
  });

  Object? valueOf(ProductionStockAnalysisField f) =>
      f == ProductionStockAnalysisField.name ? label : values[f];

  String? unitOf(ProductionStockAnalysisField f) {
    switch (f) {
      case ProductionStockAnalysisField.main:
      case ProductionStockAnalysisField.out:
      case ProductionStockAnalysisField.opening:
      case ProductionStockAnalysisField.additions:
      case ProductionStockAnalysisField.reductions:
      case ProductionStockAnalysisField.net:
      case ProductionStockAnalysisField.closing:
      case ProductionStockAnalysisField.usedProduction:
      case ProductionStockAnalysisField.usedManual:
      case ProductionStockAnalysisField.usedTotal:
      case ProductionStockAnalysisField.stock:
        return unit;
      default:
        return null;
    }
  }
}

/// Everything the analysis page shows for one period.
class ProductionStockAnalysis {
  final ProductionStockKind kind;
  final List<ProductionStockRow> rows;
  final int items;
  final int managed;
  final double stockValue;
  final int outOfStock;
  final int lowStock;
  final int expired;

  /// Expired or expiring within [productionExpiringDays] days.
  final int expiring;

  /// Main movement (produced / used) and out movement, per unit.
  final Map<String, double> main;
  final Map<String, double> out;

  /// Null for all time.
  final Map<String, double>? previousMain;
  final Map<String, double>? previousOut;

  /// Out ÷ main × 100 when both use one unit; null otherwise.
  final double? rate;

  /// Materials: usage cost of the period and of the one before (null
  /// for all time).
  final double usageCost;
  final double? previousUsageCost;
  final int notNormalised;
  final Map<ProductionStockAnalysisTab, List<ProductionStockAnalysisRow>> tabs;

  const ProductionStockAnalysis({
    required this.kind,
    required this.rows,
    required this.items,
    required this.managed,
    required this.stockValue,
    required this.outOfStock,
    required this.lowStock,
    required this.expired,
    required this.expiring,
    required this.main,
    required this.out,
    required this.previousMain,
    required this.previousOut,
    required this.rate,
    this.usageCost = 0,
    this.previousUsageCost,
    required this.notNormalised,
    required this.tabs,
  });
}

class ProductionStockAnalysisBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  static ProductionStockFilters _filters({
    String? itemKey,
    String? departmentKey,
    String? categoryKey,
  }) => ProductionStockFilters(
    itemKey: itemKey,
    departmentKey: departmentKey,
    categoryKey: categoryKey,
  );

  static int _order(ProductionStockAnalysisRow a, ProductionStockAnalysisRow b) {
    if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
    final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
    return n != 0 ? n : a.key.compareTo(b.key);
  }

  static List<ProductionStockAnalysisRow> _ranking(
    ProductionStockAnalysisTab tab,
    List<ProductionStockRow> rows,
    ProductionStockKind kind,
  ) {
    final mainK = productionMainMovement(kind);
    final outK = productionOutMovement(kind);
    final list = <ProductionStockAnalysisRow>[];
    for (final r in rows) {
      final m = r.movement;
      final main = m.of(mainK);
      final out = m.of(outK);
      final include = switch (tab) {
        ProductionStockAnalysisTab.produced => main > 0,
        ProductionStockAnalysisTab.transferred => out > 0,
        _ => m.hasMovement,
      };
      if (!include) continue;
      list.add(
        ProductionStockAnalysisRow(
          id: '${tab.name}-${r.uuid}',
          key: r.uuid,
          label: r.name,
          isNone: false,
          unit: r.primaryUnit,
          values: {
            ProductionStockAnalysisField.main: main,
            ProductionStockAnalysisField.out: out,
            ProductionStockAnalysisField.rate: main > 0 ? out / main * 100 : null,
            ProductionStockAnalysisField.opening: r.balance.opening,
            ProductionStockAnalysisField.additions: m.additions,
            ProductionStockAnalysisField.reductions: m.reductions,
            ProductionStockAnalysisField.net: m.net,
            ProductionStockAnalysisField.closing: r.balance.closing,
          },
          filters: _filters(itemKey: r.uuid),
        ),
      );
    }
    final f = switch (tab) {
      ProductionStockAnalysisTab.produced => ProductionStockAnalysisField.main,
      ProductionStockAnalysisTab.transferred => ProductionStockAnalysisField.out,
      _ => ProductionStockAnalysisField.net,
    };
    list.sort((a, b) {
      final c = ((b.values[f] as double?) ?? 0).compareTo(
        (a.values[f] as double?) ?? 0,
      );
      return c != 0 ? c : _order(a, b);
    });
    return list;
  }

  static List<ProductionStockAnalysisRow> _distribution(
    ProductionStockAnalysisTab tab,
    List<ProductionStockRow> rows, {
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) {
    final byDepartment = tab == ProductionStockAnalysisTab.departments;
    final groups = <String, ({String label, List<ProductionStockRow> rows})>{};
    void add(String? key, String label, ProductionStockRow r) {
      final k = key ?? productionReportNoneKey;
      groups.putIfAbsent(k, () => (label: label, rows: [])).rows.add(r);
    }

    for (final r in rows) {
      if (byDepartment) {
        add(r.departmentKey, r.departmentLabel, r);
      } else if (r.categoryKeys.isEmpty) {
        add(null, productionNoCategoryLabel, r);
      } else {
        for (var i = 0; i < r.categoryKeys.length; i++) {
          add(r.categoryKeys[i], r.categoryNames[i], r);
        }
      }
    }
    final totalValue = rows.fold<double>(0, (s, r) => s + (r.stockValue ?? 0));
    final out = <ProductionStockAnalysisRow>[];
    groups.forEach((key, g) {
      final value = g.rows.fold<double>(0, (s, r) => s + (r.stockValue ?? 0));
      out.add(
        ProductionStockAnalysisRow(
          id: '${tab.name}-$key',
          key: key,
          label: g.label,
          isNone: key == productionReportNoneKey,
          values: {
            ProductionStockAnalysisField.items: g.rows.length,
            ProductionStockAnalysisField.managed:
                g.rows.where((r) => r.isManaged).length,
            ProductionStockAnalysisField.stockValue: value,
            ProductionStockAnalysisField.share:
                // Stock value is cost × quantity: it needs both.
                canSeeCost && canSeeQuantity && totalValue > 0
                    ? _share(value, totalValue)
                    : _share(g.rows.length.toDouble(), rows.length.toDouble()),
          },
          filters:
              byDepartment
                  ? _filters(departmentKey: key)
                  : _filters(categoryKey: key),
        ),
      );
    });
    out.sort((a, b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      final c = ((b.values[ProductionStockAnalysisField.share] as double?) ?? -1)
          .compareTo((a.values[ProductionStockAnalysisField.share] as double?) ?? -1);
      return c != 0 ? c : _order(a, b);
    });
    return out;
  }

  /// Produced items with runs in the period: recorded cost per unit
  /// (Σ recorded cost ÷ Σ quantity in the primary unit) against the
  /// item's cost price.
  static List<ProductionStockAnalysisRow> costPerUnit(
    List<ProductionStockRow> rows,
    List<ProductionRecordRow> recordsInPeriod,
  ) {
    final byUuid = {for (final r in rows) r.uuid: r};
    final acc = <String, ({int runs, double cost, double qty})>{};
    for (final rec in recordsInPeriod) {
      if (rec.outputType != ProductionOutputType.producedItem) continue;
      final key = rec.outputKey;
      if (key == null || !byUuid.containsKey(key)) continue;
      final a = acc[key] ?? (runs: 0, cost: 0.0, qty: 0.0);
      acc[key] = (
        runs: a.runs + 1,
        cost: a.cost + rec.recordedCost,
        qty: a.qty + rec.primaryQty,
      );
    }
    final out = <ProductionStockAnalysisRow>[];
    acc.forEach((key, a) {
      final row = byUuid[key]!;
      final perUnit = a.qty > 0 ? a.cost / a.qty : null;
      final price = row.costPrice;
      final diff = perUnit == null ? null : perUnit - price;
      out.add(
        ProductionStockAnalysisRow(
          id: 'costPerUnit-$key',
          key: key,
          label: row.name,
          isNone: false,
          unit: row.primaryUnit,
          values: {
            ProductionStockAnalysisField.runs: a.runs,
            ProductionStockAnalysisField.recordedCostPerUnit: perUnit,
            ProductionStockAnalysisField.costPrice: price,
            ProductionStockAnalysisField.difference: diff,
            ProductionStockAnalysisField.differencePercent:
                diff == null || price <= 0 ? null : diff / price * 100,
          },
          filters: _filters(itemKey: key),
        ),
      );
    });
    out.sort(_order);
    return out;
  }

  /// Materials: most used by quantity or by cost.
  static List<ProductionStockAnalysisRow> _materialUse(
    ProductionStockAnalysisTab tab,
    List<ProductionStockRow> rows,
  ) {
    final byCost = tab == ProductionStockAnalysisTab.usedCost;
    final total = rows.fold<double>(
      0,
      (s, r) => s + (r.materialUsage?.totalCost ?? 0),
    );
    final out = <ProductionStockAnalysisRow>[];
    for (final r in rows) {
      final u = r.materialUsage;
      if (u == null || !u.used) continue;
      if (byCost && u.totalCost <= 0) continue;
      out.add(
        ProductionStockAnalysisRow(
          id: '${tab.name}-${r.uuid}',
          key: r.uuid,
          label: r.name,
          isNone: false,
          unit: r.primaryUnit,
          values: {
            ProductionStockAnalysisField.usedProduction: u.productionQty,
            ProductionStockAnalysisField.usedManual: u.manualQty,
            ProductionStockAnalysisField.usedTotal: u.totalQty,
            ProductionStockAnalysisField.runs: u.records,
            ProductionStockAnalysisField.productionCost: u.productionCost,
            ProductionStockAnalysisField.manualCost: u.manualCost,
            ProductionStockAnalysisField.usageCost: u.totalCost,
            ProductionStockAnalysisField.share: _share(u.totalCost, total),
          },
          filters: _filters(itemKey: r.uuid),
        ),
      );
    }
    final f =
        byCost
            ? ProductionStockAnalysisField.usageCost
            : ProductionStockAnalysisField.usedTotal;
    out.sort((a, b) {
      final c = ((b.values[f] as double?) ?? 0).compareTo((a.values[f] as double?) ?? 0);
      return c != 0 ? c : _order(a, b);
    });
    return out;
  }

  /// Materials with no use in the period; [allTime] gives the last use.
  static List<ProductionStockAnalysisRow> _unused(
    List<ProductionStockRow> rows,
    Map<String, ProductionMaterialUsage> allTime,
  ) {
    final out = [
      for (final r in rows)
        if (!(r.materialUsage?.used ?? false))
          ProductionStockAnalysisRow(
            id: 'unused-${r.uuid}',
            key: r.uuid,
            label: r.name,
            isNone: false,
            unit: r.primaryUnit,
            values: {
              ProductionStockAnalysisField.stock: r.quantity,
              ProductionStockAnalysisField.stockValue: r.stockValue,
              ProductionStockAnalysisField.lastUsed: allTime[r.uuid]?.lastUsed,
            },
            filters: _filters(itemKey: r.uuid),
          ),
    ]..sort(_order);
    return out;
  }

  /// Materials whose unit cost changed between their first and last
  /// usage record of the period.
  static List<ProductionStockAnalysisRow> _costChanges(
    List<ProductionStockRow> rows,
  ) {
    final byUuid = {for (final r in rows) r.uuid: r};
    final changes = ProductionMaterialUsageBuilder.costChanges({
      for (final r in rows)
        if (r.materialUsage != null) r.uuid: r.materialUsage!,
    });
    final out = [
      for (final c in changes)
        ProductionStockAnalysisRow(
          id: 'costChanges-${c.key}',
          key: c.key,
          label: byUuid[c.key]!.name,
          isNone: false,
          unit: byUuid[c.key]!.primaryUnit,
          values: {
            ProductionStockAnalysisField.firstUnitCost: c.first,
            ProductionStockAnalysisField.lastUnitCost: c.last,
            ProductionStockAnalysisField.costChange: c.change,
            ProductionStockAnalysisField.costChangePercent: c.changePercent,
            ProductionStockAnalysisField.runs: c.records,
          },
          filters: _filters(itemKey: c.key),
        ),
    ]..sort(_order);
    return out;
  }

  /// Materials' use per unit (records, not history).
  static Map<String, double> _usedByUnit(List<ProductionStockRow> rows) =>
      productionByUnit(
        rows.map(
          (r) => (unit: r.primaryUnit, qty: r.materialUsage?.totalQty ?? 0),
        ),
      );

  static double _usageCost(List<ProductionStockRow> rows) =>
      rows.fold(0, (s, r) => s + (r.materialUsage?.totalCost ?? 0));

  static ({Map<String, double> main, Map<String, double> out, int notNormalised})
  _movement(List<ProductionStockRow> rows, ProductionStockKind kind) {
    final mainK = productionMainMovement(kind);
    final outK = productionOutMovement(kind);
    return (
      main: productionByUnit(
        rows.map((r) => (unit: r.primaryUnit, qty: r.movement.of(mainK))),
      ),
      out: productionByUnit(
        rows.map((r) => (unit: r.primaryUnit, qty: r.movement.of(outK))),
      ),
      notNormalised: productionStockNotNormalised(rows),
    );
  }

  /// [rows] are the scoped stock rows built for [period];
  /// [previousRows] the same items built for the period before (null
  /// for all time); [records] the production record rows (any period).
  static ProductionStockAnalysis build({
    required ProductionStockKind kind,
    required List<ProductionStockRow> rows,
    required List<ProductionStockRow>? previousRows,
    required List<ProductionRecordRow> records,
    required ReceiptsReportPeriod period,
    required DateTime businessNow,
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    required bool historyAllowed,
    TimeOfDay? closingTime,
    Map<String, ProductionMaterialUsage> allTimeUsage = const {},
  }) {
    final material = kind == ProductionStockKind.material;
    var cur = _movement(rows, kind);
    var prev = previousRows == null ? null : _movement(previousRows, kind);
    if (material) {
      // Materials' use comes from production and usage records (rows
      // built with their usage), split in M1; the history can't tell
      // production use from manual use.
      cur = (main: _usedByUnit(rows), out: const {}, notNormalised: cur.notNormalised);
      prev =
          previousRows == null
              ? null
              : (main: _usedByUnit(previousRows), out: const {}, notNormalised: 0);
    }
    final today = DateTime(businessNow.year, businessNow.month, businessNow.day);
    final soon = today.add(const Duration(days: productionExpiringDays));
    var expired = 0;
    var expiring = 0;
    for (final r in rows) {
      final e = r.expiryDate;
      if (e == null) continue;
      if (r.isExpired) expired++;
      if (!DateTime(e.year, e.month, e.day).isAfter(soon)) expiring++;
    }
    final mainOne = cur.main.entries.where((e) => e.value != 0).toList();
    final outOne = cur.out.entries.where((e) => e.value != 0).toList();
    final units = {...mainOne.map((e) => e.key), ...outOne.map((e) => e.key)};
    final double? rate =
        !material && units.length == 1 && (cur.main[units.first] ?? 0) > 0
            ? (cur.out[units.first] ?? 0) / cur.main[units.first]! * 100
            : null;

    final tabs = productionStockAnalysisTabs(
      kind: kind,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      historyAllowed: historyAllowed,
    );
    final recordsInPeriod = [
      for (final r in records)
        if (period.contains(r.createdAt, closingTime: closingTime)) r,
    ];
    return ProductionStockAnalysis(
      kind: kind,
      rows: rows,
      items: rows.length,
      managed: rows.where((r) => r.isManaged).length,
      stockValue: rows.fold(0, (s, r) => s + (r.stockValue ?? 0)),
      outOfStock:
          rows.where((r) => r.stockLevel == ProductionStockLevel.out).length,
      lowStock:
          rows.where((r) => r.stockLevel == ProductionStockLevel.low).length,
      expired: expired,
      expiring: expiring,
      main: cur.main,
      out: cur.out,
      previousMain: prev?.main,
      previousOut: prev?.out,
      rate: rate,
      usageCost: _usageCost(rows),
      previousUsageCost: previousRows == null ? null : _usageCost(previousRows),
      notNormalised: cur.notNormalised,
      tabs: {
        for (final t in tabs)
          t: switch (t) {
            ProductionStockAnalysisTab.produced ||
            ProductionStockAnalysisTab.transferred ||
            ProductionStockAnalysisTab.net => _ranking(t, rows, kind),
            ProductionStockAnalysisTab.departments ||
            ProductionStockAnalysisTab.categories => _distribution(
              t,
              rows,
              canSeeCost: canSeeCost,
              canSeeQuantity: canSeeQuantity,
            ),
            ProductionStockAnalysisTab.costPerUnit => costPerUnit(
              rows,
              recordsInPeriod,
            ),
            ProductionStockAnalysisTab.usedQuantity ||
            ProductionStockAnalysisTab.usedCost => _materialUse(t, rows),
            ProductionStockAnalysisTab.unused => _unused(rows, allTimeUsage),
            ProductionStockAnalysisTab.costChanges => _costChanges(rows),
          },
      },
    );
  }

  /// Sorted copy of a tab. A null [field] keeps the built order; the
  /// none row stays last; nulls sink.
  static List<ProductionStockAnalysisRow> sortTab(
    List<ProductionStockAnalysisRow> rows, {
    required ProductionStockAnalysisField? field,
    required bool ascending,
  }) {
    if (field == null) return List.of(rows);
    return List.of(rows)..sort((a, b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      Comparable? v(ProductionStockAnalysisRow r) {
        final x = r.valueOf(field);
        if (x is String) return x.toLowerCase();
        return x as Comparable?;
      }

      final c = ProductionRecordsQuery.cmp(v(a), v(b), ascending);
      return c != 0 ? c : _order(a, b);
    });
  }
}

/// The headline cards. Stock cards are current values; the movement
/// cards compare with the previous period when both use one unit.
List<ProductionStockCard> productionStockAnalysisCards(
  ProductionStockAnalysis a, {
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyAllowed,
}) {
  final kind = a.kind;
  String movementNote(Map<String, double> cur, Map<String, double>? prev) {
    if (prev == null) return 'In this period';
    return productionUnitChange(cur, prev) == null
        ? 'Mixed units: no comparison'
        : 'In this period';
  }

  if (kind == ProductionStockKind.material) {
    return [
      ProductionStockCard(
        id: 'items',
        title: kind.plural,
        kind: ProductionStockCardKind.count,
        amount: a.items.toDouble(),
        subtitle: '${a.managed} managed',
      ),
      if (canSeeCost)
        ProductionStockCard(
          id: 'stockValue',
          title: 'Stock Value',
          kind: ProductionStockCardKind.money,
          amount: a.stockValue,
          subtitle: 'Current stock at cost',
          masked: !canSeeQuantity,
        ),
      ProductionStockCard(
        id: 'lowStock',
        title: 'Low Stock',
        kind: ProductionStockCardKind.count,
        amount: a.lowStock.toDouble(),
        subtitle: 'At or below the low quantity',
        masked: !canSeeQuantity,
      ),
      ProductionStockCard(
        id: 'outOfStock',
        title: 'Out of Stock',
        kind: ProductionStockCardKind.count,
        amount: a.outOfStock.toDouble(),
        subtitle: 'Current stock',
        masked: !canSeeQuantity,
      ),
      ProductionStockCard(
        id: 'expiring',
        title: 'Expired or Expiring',
        kind: ProductionStockCardKind.count,
        amount: a.expiring.toDouble(),
        subtitle: '${a.expired} expired, $productionExpiringDays-day window',
      ),
      ProductionStockCard(
        id: 'main',
        title: 'Used',
        kind: ProductionStockCardKind.quantities,
        byUnit: a.main,
        subtitle: movementNote(a.main, a.previousMain),
        change: productionUnitChange(a.main, a.previousMain),
        masked: !canSeeQuantity,
      ),
      if (canSeeCost)
        ProductionStockCard(
          id: 'usageCost',
          title: 'Usage Cost',
          kind: ProductionStockCardKind.money,
          amount: a.usageCost,
          subtitle: 'Production and manual use',
          change: GeneralReportChange.compare(
            current: a.usageCost,
            previous: a.previousUsageCost,
          ),
        ),
    ];
  }

  return [
    ProductionStockCard(
      id: 'items',
      title: kind.plural,
      kind: ProductionStockCardKind.count,
      amount: a.items.toDouble(),
      subtitle: '${a.managed} managed',
    ),
    if (canSeeCost)
      ProductionStockCard(
        id: 'stockValue',
        title: 'Stock Value',
        kind: ProductionStockCardKind.money,
        amount: a.stockValue,
        subtitle: 'Current stock at cost',
        masked: !canSeeQuantity,
      ),
    ProductionStockCard(
      id: 'outOfStock',
      title: 'Out of Stock',
      kind: ProductionStockCardKind.count,
      amount: a.outOfStock.toDouble(),
      subtitle:
          kind == ProductionStockKind.material
              ? '${a.lowStock} low on stock'
              : 'Current stock',
      masked: !canSeeQuantity,
    ),
    ProductionStockCard(
      id: 'expiring',
      title: 'Expired or Expiring',
      kind: ProductionStockCardKind.count,
      amount: a.expiring.toDouble(),
      subtitle: '${a.expired} expired, $productionExpiringDays-day window',
    ),
    if (historyAllowed) ...[
      ProductionStockCard(
        id: 'main',
        title: productionMainMovement(kind).label,
        kind: ProductionStockCardKind.quantities,
        byUnit: a.main,
        subtitle: movementNote(a.main, a.previousMain),
        change: productionUnitChange(a.main, a.previousMain),
        masked: !canSeeQuantity,
      ),
      ProductionStockCard(
        id: 'out',
        title: productionOutMovement(kind).label,
        kind: ProductionStockCardKind.quantities,
        byUnit: a.out,
        subtitle: movementNote(a.out, a.previousOut),
        change: productionUnitChange(a.out, a.previousOut),
        masked: !canSeeQuantity,
      ),
      if (kind == ProductionStockKind.producedItem)
        ProductionStockCard(
          id: 'rate',
          title: 'Transfer-to-Sales Rate (approx.)',
          kind: ProductionStockCardKind.percent,
          amount: a.rate,
          subtitle:
              a.rate == null
                  ? 'Needs production in one unit'
                  : 'Transferred ÷ produced',
          masked: !canSeeQuantity,
        ),
    ],
  ];
}
