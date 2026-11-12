import 'package:flutter/material.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_trend_buckets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

/// Statistic cards of the summary.
class ProductionSummaryStats {
  final int runs;
  final double recordedCost;
  final double materialCost;
  final double variance;
  final int distinctOutputs;
  final int distinctMaterials;
  final int distinctStaff;
  final int customCostCount;

  const ProductionSummaryStats({
    required this.runs,
    required this.recordedCost,
    required this.materialCost,
    required this.variance,
    required this.distinctOutputs,
    required this.distinctMaterials,
    required this.distinctStaff,
    required this.customCostCount,
  });

  /// Recorded cost per run; 0 without runs.
  double get averageCostPerRun => runs == 0 ? 0 : recordedCost / runs;

  static ProductionSummaryStats of(List<ProductionRecordRow> rows) {
    final outputs = <String>{};
    final materials = <String>{};
    final staff = <String>{};
    double recorded = 0;
    double material = 0;
    double variance = 0;
    int custom = 0;
    for (final r in rows) {
      recorded += r.recordedCost;
      material += r.materialCost;
      variance += r.variance;
      if (r.costSource == ProductionCostSource.custom) custom++;
      if (r.outputKey != null) outputs.add(r.outputKey!);
      materials.addAll(r.materialKeys);
      if (r.staffKey != null) staff.add(r.staffKey!);
    }
    return ProductionSummaryStats(
      runs: rows.length,
      recordedCost: recorded,
      materialCost: material,
      variance: variance,
      distinctOutputs: outputs.length,
      distinctMaterials: materials.length,
      distinctStaff: staff.length,
      customCostCount: custom,
    );
  }
}

/// Change of each card against the previous period of the same
/// length. Every field is null for all time.
class ProductionSummaryChanges {
  final GeneralReportChange? runs;
  final GeneralReportChange? recordedCost;
  final GeneralReportChange? materialCost;
  final GeneralReportChange? averageCostPerRun;
  final GeneralReportChange? distinctOutputs;

  const ProductionSummaryChanges({
    this.runs,
    this.recordedCost,
    this.materialCost,
    this.averageCostPerRun,
    this.distinctOutputs,
  });

  static const none = ProductionSummaryChanges();

  static ProductionSummaryChanges compare(
    ProductionSummaryStats current,
    ProductionSummaryStats? previous,
  ) {
    if (previous == null) return none;
    GeneralReportChange? c(double a, double b) =>
        GeneralReportChange.compare(current: a, previous: b);
    return ProductionSummaryChanges(
      runs: c(current.runs.toDouble(), previous.runs.toDouble()),
      recordedCost: c(current.recordedCost, previous.recordedCost),
      materialCost: c(current.materialCost, previous.materialCost),
      averageCostPerRun: c(
        current.averageCostPerRun,
        previous.averageCostPerRun,
      ),
      distinctOutputs: c(
        current.distinctOutputs.toDouble(),
        previous.distinctOutputs.toDouble(),
      ),
    );
  }
}

/// One bucket of the trend chart.
class ProductionTrendPoint {
  final DateTime start;
  int runs = 0;
  double recordedCost = 0;
  double materialCost = 0;

  ProductionTrendPoint(this.start);
}

/// Trend buckets for production rows ([ProductionTrendBuckets]).
class ProductionTrendBuilder {
  static DateTimeRange? span({
    required List<ProductionRecordRow> rows,
    required ReceiptsReportPeriod period,
    required DateTime now,
    TimeOfDay? closingTime,
  }) => ProductionTrendBuckets.span(
    dates: rows.map((r) => r.createdAt),
    period: period,
    now: now,
    closingTime: closingTime,
  );

  /// Buckets from the start to the end of the period, empty ones
  /// included (as 0). [rows] must already be in the period.
  static List<ProductionTrendPoint> build({
    required List<ProductionRecordRow> rows,
    required ReceiptsReportPeriod period,
    DateTime? now,
    TimeOfDay? closingTime,
  }) => ProductionTrendBuckets.build<ProductionTrendPoint, ProductionRecordRow>(
    rows: rows,
    dateOf: (r) => r.createdAt,
    newPoint: ProductionTrendPoint.new,
    add: _add,
    period: period,
    now: now,
    closingTime: closingTime,
  );

  static void _add(ProductionTrendPoint p, ProductionRecordRow r) {
    p.runs++;
    p.recordedCost += r.recordedCost;
    p.materialCost += r.materialCost;
  }
}

enum ProductionBreakdownTab { outputItems, materials, yield, staff, departments }

extension ProductionBreakdownTabLabel on ProductionBreakdownTab {
  String get label {
    switch (this) {
      case ProductionBreakdownTab.outputItems:
        return 'Output Items';
      case ProductionBreakdownTab.materials:
        return 'Materials';
      case ProductionBreakdownTab.yield:
        return 'Yield';
      case ProductionBreakdownTab.staff:
        return 'Staff';
      case ProductionBreakdownTab.departments:
        return 'Departments';
    }
  }
}

/// The tabs the summary offers: Departments only with departments on;
/// Yield only with the quantity permission (it is all quantities).
List<ProductionBreakdownTab> productionBreakdownTabs({
  required bool departmentsEnabled,
  required bool canSeeQuantity,
}) => [
  ProductionBreakdownTab.outputItems,
  ProductionBreakdownTab.materials,
  if (canSeeQuantity) ProductionBreakdownTab.yield,
  ProductionBreakdownTab.staff,
  if (departmentsEnabled) ProductionBreakdownTab.departments,
];

/// A breakdown column, also its sort field.
enum ProductionBreakdownField {
  name,
  sublabel,
  count,
  quantity,
  materialQuantity,
  ratio,
  recordedCost,
  materialCost,
  variance,
  costPerUnit,
  minCostPerUnit,
  maxCostPerUnit,
  lastDate,
  share,
}

enum ProductionBreakdownKind { text, count, quantity, money, ratio, date, percent }

class ProductionBreakdownColumn {
  final ProductionBreakdownField field;
  final String label;
  final ProductionBreakdownKind kind;
  final double width;

  const ProductionBreakdownColumn(this.field, this.label, this.kind, this.width);
}

/// The columns of [tab], with the cost and quantity permissions
/// applied. The screen and the export both use this list.
List<ProductionBreakdownColumn> productionBreakdownColumns(
  ProductionBreakdownTab tab, {
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  ProductionBreakdownColumn col(
    ProductionBreakdownField field,
    String label,
    ProductionBreakdownKind kind, [
    double width = 130,
  ]) => ProductionBreakdownColumn(field, label, kind, width);
  const k = (
    text: ProductionBreakdownKind.text,
    count: ProductionBreakdownKind.count,
    qty: ProductionBreakdownKind.quantity,
    money: ProductionBreakdownKind.money,
    ratio: ProductionBreakdownKind.ratio,
    date: ProductionBreakdownKind.date,
    pct: ProductionBreakdownKind.percent,
  );
  switch (tab) {
    case ProductionBreakdownTab.outputItems:
      return [
        col(ProductionBreakdownField.name, 'Output Item', k.text, 200),
        col(ProductionBreakdownField.count, 'Runs', k.count, 90),
        if (canSeeQuantity)
          col(ProductionBreakdownField.quantity, 'Qty Produced', k.qty, 150),
        if (canSeeCost) ...[
          col(ProductionBreakdownField.recordedCost, 'Recorded Cost', k.money, 150),
          col(ProductionBreakdownField.materialCost, 'Material Cost', k.money, 150),
        ],
        if (canSeeCost && canSeeQuantity) ...[
          col(ProductionBreakdownField.costPerUnit, 'Avg Cost / Unit', k.money, 140),
          col(ProductionBreakdownField.minCostPerUnit, 'Min / Unit', k.money),
          col(ProductionBreakdownField.maxCostPerUnit, 'Max / Unit', k.money),
        ],
        col(ProductionBreakdownField.lastDate, 'Last Production', k.date, 140),
        col(ProductionBreakdownField.share, 'Share', k.pct, 100),
      ];
    case ProductionBreakdownTab.materials:
      return [
        col(ProductionBreakdownField.name, 'Material', k.text, 200),
        col(ProductionBreakdownField.count, 'Productions', k.count, 110),
        if (canSeeQuantity)
          col(ProductionBreakdownField.quantity, 'Qty Used', k.qty, 150),
        if (canSeeCost)
          col(ProductionBreakdownField.materialCost, 'Cost', k.money, 150),
        col(ProductionBreakdownField.lastDate, 'Last Used', k.date, 140),
        col(ProductionBreakdownField.share, 'Share', k.pct, 100),
      ];
    case ProductionBreakdownTab.yield:
      return [
        col(ProductionBreakdownField.name, 'Output Item', k.text, 180),
        col(ProductionBreakdownField.sublabel, 'Material', k.text, 160),
        col(ProductionBreakdownField.count, 'Runs', k.count, 80),
        col(ProductionBreakdownField.quantity, 'Output Qty', k.qty, 140),
        col(ProductionBreakdownField.materialQuantity, 'Material Qty', k.qty, 140),
        col(ProductionBreakdownField.ratio, 'Material / Output Unit', k.ratio, 170),
        if (canSeeCost)
          col(ProductionBreakdownField.costPerUnit, 'Material Cost / Unit', k.money, 160),
      ];
    case ProductionBreakdownTab.staff:
    case ProductionBreakdownTab.departments:
      return [
        col(
          ProductionBreakdownField.name,
          tab == ProductionBreakdownTab.staff ? 'Staff' : 'Department',
          k.text,
          200,
        ),
        col(ProductionBreakdownField.count, 'Runs', k.count, 90),
        if (canSeeCost) ...[
          col(ProductionBreakdownField.recordedCost, 'Recorded Cost', k.money, 150),
          col(ProductionBreakdownField.materialCost, 'Material Cost', k.money, 150),
          col(ProductionBreakdownField.variance, 'Variance', k.money, 140),
        ],
        col(ProductionBreakdownField.lastDate, 'Last Production', k.date, 140),
        col(ProductionBreakdownField.share, 'Share', k.pct, 100),
      ];
  }
}

/// One row of a breakdown table. [filters] open the table on exactly
/// its records. Fields a tab doesn't use are null.
class ProductionBreakdownRow {
  /// Unique within the page: tab and key.
  final String id;
  final String key;
  final String label;

  /// Yield: the material.
  final String? sublabel;

  /// The none row ("No staff", "No materials"…), always last.
  final bool isNone;
  final int count;
  final double? quantity;
  final String? unit;
  final double? materialQuantity;
  final String? materialUnit;
  final double? ratio;
  final double? recordedCost;
  final double? materialCost;
  final double? variance;
  final double? costPerUnit;
  final double? minCostPerUnit;
  final double? maxCostPerUnit;
  final DateTime? lastDate;

  /// Share of the cost (with the cost permission) or of the runs.
  final double? share;
  final ProductionRecordsFilters filters;

  const ProductionBreakdownRow({
    required this.id,
    required this.key,
    required this.label,
    this.sublabel,
    required this.isNone,
    required this.count,
    this.quantity,
    this.unit,
    this.materialQuantity,
    this.materialUnit,
    this.ratio,
    this.recordedCost,
    this.materialCost,
    this.variance,
    this.costPerUnit,
    this.minCostPerUnit,
    this.maxCostPerUnit,
    this.lastDate,
    this.share,
    required this.filters,
  });

  /// The raw value of [field] (for sorting and the export).
  Object? valueOf(ProductionBreakdownField field) {
    switch (field) {
      case ProductionBreakdownField.name:
        return label;
      case ProductionBreakdownField.sublabel:
        return sublabel;
      case ProductionBreakdownField.count:
        return count;
      case ProductionBreakdownField.quantity:
        return quantity;
      case ProductionBreakdownField.materialQuantity:
        return materialQuantity;
      case ProductionBreakdownField.ratio:
        return ratio;
      case ProductionBreakdownField.recordedCost:
        return recordedCost;
      case ProductionBreakdownField.materialCost:
        return materialCost;
      case ProductionBreakdownField.variance:
        return variance;
      case ProductionBreakdownField.costPerUnit:
        return costPerUnit;
      case ProductionBreakdownField.minCostPerUnit:
        return minCostPerUnit;
      case ProductionBreakdownField.maxCostPerUnit:
        return maxCostPerUnit;
      case ProductionBreakdownField.lastDate:
        return lastDate;
      case ProductionBreakdownField.share:
        return share;
    }
  }

  /// The unit shown after a quantity column, if any.
  String? unitOf(ProductionBreakdownField field) {
    if (field == ProductionBreakdownField.quantity) return unit;
    if (field == ProductionBreakdownField.materialQuantity) return materialUnit;
    if (field == ProductionBreakdownField.ratio) {
      if (materialUnit == null || unit == null) return null;
      return '$materialUnit / $unit';
    }
    return null;
  }
}

/// Everything the summary page shows for one period.
class ProductionSummaryResult {
  /// Rows in the period.
  final List<ProductionRecordRow> rows;
  final ProductionSummaryStats stats;

  /// Null for all time.
  final ProductionSummaryStats? previous;
  final ProductionSummaryChanges changes;
  final List<ProductionTrendPoint> trend;

  /// Null without a chart (all time with no records).
  final ReceiptsTrendInterval? interval;
  final Map<ProductionBreakdownTab, List<ProductionBreakdownRow>> breakdowns;

  const ProductionSummaryResult({
    required this.rows,
    required this.stats,
    required this.previous,
    required this.changes,
    required this.trend,
    required this.interval,
    required this.breakdowns,
  });
}

class _Acc {
  final String key;
  final bool isNone;
  String? name;
  String? sublabel;
  int count = 0;
  double? quantity;
  String? unit;
  double? materialQuantity;
  String? materialUnit;
  double recordedCost = 0;
  double materialCost = 0;
  double variance = 0;
  double? minPerUnit;
  double? maxPerUnit;
  DateTime? lastDate;

  _Acc(this.key, this.isNone);

  void seen(DateTime d) {
    if (lastDate == null || d.isAfter(lastDate!)) lastDate = d;
  }

  void perUnit(double? v) {
    if (v == null) return;
    if (minPerUnit == null || v < minPerUnit!) minPerUnit = v;
    if (maxPerUnit == null || v > maxPerUnit!) maxPerUnit = v;
  }
}

class ProductionSummaryBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  /// The summary's filters with one or more keys set, for opening the
  /// table on exactly the records of a summary row.
  static ProductionRecordsFilters handoff(
    ProductionRecordsFilters base, {
    String? outputKey,
    String? materialKey,
    String? staffKey,
    String? departmentKey,
  }) {
    final f = base.copy();
    if (outputKey != null) f.outputKey = outputKey;
    if (materialKey != null) f.materialKey = materialKey;
    if (staffKey != null) f.staffKey = staffKey;
    if (departmentKey != null) f.departmentKey = departmentKey;
    return f;
  }

  static String _labelOf(_Acc a, String noneLabel) =>
      a.isNone ? noneLabel : (a.name ?? 'Not Set');

  /// Built order: share (cost, or runs) largest first; ties: label,
  /// then key; the none row last.
  static List<ProductionBreakdownRow> _ordered(List<ProductionBreakdownRow> rows) {
    return List<ProductionBreakdownRow>.from(rows)..sort((a, b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      final c = (b.share ?? -1).compareTo(a.share ?? -1);
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      if (n != 0) return n;
      final s = (a.sublabel ?? '').toLowerCase().compareTo(
        (b.sublabel ?? '').toLowerCase(),
      );
      return s != 0 ? s : a.key.compareTo(b.key);
    });
  }

  static List<ProductionBreakdownRow> _keyed({
    required ProductionBreakdownTab tab,
    required List<ProductionRecordRow> rows,
    required String? Function(ProductionRecordRow) key,
    required String? Function(ProductionRecordRow) name,
    required String noneLabel,
    required ProductionRecordsFilters Function(String key) filters,
    required bool canSeeCost,
    bool withQuantity = false,
  }) {
    final newestFirst = List<ProductionRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final accs = <String, _Acc>{};
    double totalCost = 0;
    for (final r in newestFirst) {
      final k = key(r);
      final a = accs.putIfAbsent(
        k ?? productionReportNoneKey,
        () => _Acc(k ?? productionReportNoneKey, k == null),
      );
      a.name ??= name(r);
      a.count++;
      a.recordedCost += r.recordedCost;
      a.materialCost += r.materialCost;
      a.variance += r.variance;
      a.seen(r.createdAt);
      if (withQuantity) {
        a.quantity = (a.quantity ?? 0) + r.primaryQty;
        a.unit ??= r.primaryUnit;
        a.perUnit(r.costPerUnit);
      }
      totalCost += r.recordedCost;
    }
    return _ordered([
      for (final a in accs.values)
        ProductionBreakdownRow(
          id: '${tab.name}-${a.key}',
          key: a.key,
          label: _labelOf(a, noneLabel),
          isNone: a.isNone,
          count: a.count,
          quantity: a.quantity,
          unit: a.unit,
          recordedCost: a.recordedCost,
          materialCost: a.materialCost,
          variance: a.variance,
          costPerUnit:
              withQuantity && !a.isNone && (a.quantity ?? 0) > 0
                  ? a.recordedCost / a.quantity!
                  : null,
          minCostPerUnit: withQuantity ? a.minPerUnit : null,
          maxCostPerUnit: withQuantity ? a.maxPerUnit : null,
          lastDate: a.lastDate,
          share:
              canSeeCost
                  ? _share(a.recordedCost, totalCost)
                  : _share(a.count.toDouble(), rows.length.toDouble()),
          filters: filters(a.key),
        ),
    ]);
  }

  static List<ProductionBreakdownRow> materials(
    List<ProductionRecordRow> rows, {
    required bool canSeeCost,
    ProductionRecordsFilters? base,
  }) {
    final b = base ?? ProductionRecordsFilters();
    final newestFirst = List<ProductionRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final accs = <String, _Acc>{};
    double totalCost = 0;
    int totalUses = 0;
    for (final r in newestFirst) {
      if (r.lines.isEmpty) {
        final a = accs.putIfAbsent(
          productionReportNoneKey,
          () => _Acc(productionReportNoneKey, true),
        );
        a.count++;
        a.seen(r.createdAt);
        totalUses++;
        continue;
      }
      final seenHere = <String>{};
      for (final l in r.lines) {
        final k = l.key ?? productionReportNoneKey;
        final a = accs.putIfAbsent(k, () => _Acc(k, l.key == null));
        a.name ??= l.name;
        a.unit ??= l.unit;
        a.quantity = (a.quantity ?? 0) + l.quantity;
        a.materialCost += l.cost;
        totalCost += l.cost;
        a.seen(r.createdAt);
        if (seenHere.add(k)) {
          a.count++;
          totalUses++;
        }
      }
    }
    return _ordered([
      for (final a in accs.values)
        ProductionBreakdownRow(
          id: '${ProductionBreakdownTab.materials.name}-${a.key}',
          key: a.key,
          label: _labelOf(a, productionNoMaterialsLabel),
          isNone: a.isNone,
          count: a.count,
          quantity: a.quantity,
          unit: a.unit,
          materialCost: a.materialCost,
          lastDate: a.lastDate,
          share:
              canSeeCost
                  ? _share(a.materialCost, totalCost)
                  : _share(a.count.toDouble(), totalUses.toDouble()),
          filters: handoff(b, materialKey: a.key),
        ),
    ]);
  }

  /// Output item × material: how much of the material one unit of the
  /// output took. Only real items and materials.
  static List<ProductionBreakdownRow> yields(
    List<ProductionRecordRow> rows, {
    ProductionRecordsFilters? base,
  }) {
    final b = base ?? ProductionRecordsFilters();
    final newestFirst = List<ProductionRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final accs = <String, _Acc>{};
    final outputs = <String, String>{};
    final materialsOf = <String, String>{};
    for (final r in newestFirst) {
      final out = r.outputKey;
      if (out == null) continue;
      final seenHere = <String>{};
      for (final l in r.lines) {
        final m = l.key;
        if (m == null) continue;
        final k = '$out|$m';
        outputs[k] = out;
        materialsOf[k] = m;
        final a = accs.putIfAbsent(k, () => _Acc(k, false));
        a.name ??= r.outputName;
        a.sublabel ??= l.name;
        a.unit ??= r.primaryUnit;
        a.materialUnit ??= l.unit;
        a.materialQuantity = (a.materialQuantity ?? 0) + l.quantity;
        a.materialCost += l.cost;
        a.seen(r.createdAt);
        if (seenHere.add(k)) {
          a.count++;
          a.quantity = (a.quantity ?? 0) + r.primaryQty;
        }
      }
    }
    final out = [
      for (final a in accs.values)
        ProductionBreakdownRow(
          id: '${ProductionBreakdownTab.yield.name}-${a.key}',
          key: a.key,
          label: a.name ?? 'Not Set',
          sublabel: a.sublabel,
          isNone: false,
          count: a.count,
          quantity: a.quantity,
          unit: a.unit,
          materialQuantity: a.materialQuantity,
          materialUnit: a.materialUnit,
          ratio:
              (a.quantity ?? 0) > 0
                  ? (a.materialQuantity ?? 0) / a.quantity!
                  : null,
          materialCost: a.materialCost,
          costPerUnit:
              (a.quantity ?? 0) > 0 ? a.materialCost / a.quantity! : null,
          lastDate: a.lastDate,
          filters: handoff(
            b,
            outputKey: outputs[a.key],
            materialKey: materialsOf[a.key],
          ),
        ),
    ];
    // Output, then material, A-Z.
    out.sort((a, b) {
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      if (n != 0) return n;
      final s = (a.sublabel ?? '').toLowerCase().compareTo(
        (b.sublabel ?? '').toLowerCase(),
      );
      return s != 0 ? s : a.key.compareTo(b.key);
    });
    return out;
  }

  static Map<ProductionBreakdownTab, List<ProductionBreakdownRow>> _breakdowns(
    List<ProductionRecordRow> rows, {
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) {
    final b = ProductionRecordsFilters();
    return {
      ProductionBreakdownTab.outputItems: _keyed(
        tab: ProductionBreakdownTab.outputItems,
        rows: rows,
        key: (r) => r.outputKey,
        name: (r) => r.outputName,
        noneLabel: productionNoOutputLabel,
        filters: (k) => handoff(b, outputKey: k),
        canSeeCost: canSeeCost,
        withQuantity: true,
      ),
      ProductionBreakdownTab.materials: materials(
        rows,
        canSeeCost: canSeeCost,
        base: b,
      ),
      if (canSeeQuantity) ProductionBreakdownTab.yield: yields(rows, base: b),
      ProductionBreakdownTab.staff: _keyed(
        tab: ProductionBreakdownTab.staff,
        rows: rows,
        key: (r) => r.staffKey,
        name: (r) => r.staffName,
        noneLabel: productionNoStaffLabel,
        filters: (k) => handoff(b, staffKey: k),
        canSeeCost: canSeeCost,
      ),
      if (departmentsEnabled)
        ProductionBreakdownTab.departments: _keyed(
          tab: ProductionBreakdownTab.departments,
          rows: rows,
          key: (r) => r.departmentKey,
          name: (r) => r.departmentName,
          noneLabel: productionNoDepartmentLabel,
          filters: (k) => handoff(b, departmentKey: k),
          canSeeCost: canSeeCost,
        ),
    };
  }

  static List<ProductionRecordRow> _inPeriod(
    List<ProductionRecordRow> rows,
    ReceiptsReportPeriod period, {
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
  }) => ProductionRecordsQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: ProductionRecordsFilters(),
    sortField: ProductionRecordsSortField.createdAt,
    ascending: false,
    departmentsEnabled: departmentsEnabled,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
    closingTime: closingTime,
  );

  /// Rows in [period] (the summary has no other filter), and the
  /// period before it for the comparison.
  static ProductionSummaryResult build({
    required List<ProductionRecordRow> rows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
    DateTime? now,
  }) {
    final inPeriod = _inPeriod(
      rows,
      period,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      closingTime: closingTime,
    );
    final previousPeriod = GeneralReportPeriods.previous(period);
    final previous =
        previousPeriod == null
            ? null
            : ProductionSummaryStats.of(
              _inPeriod(
                rows,
                previousPeriod,
                departmentsEnabled: departmentsEnabled,
                canSeeCost: canSeeCost,
                canSeeQuantity: canSeeQuantity,
                closingTime: closingTime,
              ),
            );
    final stats = ProductionSummaryStats.of(inPeriod);
    final range = ProductionTrendBuilder.span(
      rows: inPeriod,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    return ProductionSummaryResult(
      rows: inPeriod,
      stats: stats,
      previous: previous,
      changes: ProductionSummaryChanges.compare(stats, previous),
      trend: ProductionTrendBuilder.build(
        rows: inPeriod,
        period: period,
        now: now,
        closingTime: closingTime,
      ),
      interval:
          range == null
              ? null
              : ReceiptsTrendBuilder.intervalFor(range.start, range.end),
      breakdowns: _breakdowns(
        inPeriod,
        departmentsEnabled: departmentsEnabled,
        canSeeCost: canSeeCost,
        canSeeQuantity: canSeeQuantity,
      ),
    );
  }

  /// Rows of [tab] in their built order.
  static List<ProductionBreakdownRow> breakdown(
    ProductionSummaryResult result,
    ProductionBreakdownTab tab,
  ) => result.breakdowns[tab] ?? const [];

  /// Sorted copy. A null [field] keeps the built order. The none row is
  /// always last; nulls sink to the bottom; ties: label, then key.
  static List<ProductionBreakdownRow> sortBreakdown(
    List<ProductionBreakdownRow> rows, {
    required ProductionBreakdownField? field,
    required bool ascending,
  }) {
    if (field == null) return List<ProductionBreakdownRow>.from(rows);
    int compare(ProductionBreakdownRow a, ProductionBreakdownRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      Comparable? v(ProductionBreakdownRow r) {
        final x = r.valueOf(field);
        if (x is String) return x.toLowerCase();
        return x as Comparable?;
      }

      final c = ProductionRecordsQuery.cmp(v(a), v(b), ascending);
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<ProductionBreakdownRow>.from(rows)..sort(compare);
  }
}

/// A yield ratio: up to three decimals from 1 up, three significant
/// digits below 1, so 1 bag per 300 donuts reads 0.00333, not 0.003.
String productionRatioText(double v, String Function(num v) number) {
  if (v.isNaN || v.isInfinite) return '';
  if (v.abs() >= 1 || v == 0) return number(v);
  var s = v.toStringAsPrecision(3);
  if (s.contains('e')) s = v.toStringAsFixed(8);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// One statistic card. The screen and the export both build their
/// cards from [productionSummaryCards].
class ProductionSummaryCard {
  final String id;
  final String title;
  final double value;
  final bool isMoney;
  final String subtitle;

  /// Null without a previous period (all time) or for figures that
  /// aren't compared.
  final GeneralReportChange? change;

  const ProductionSummaryCard({
    required this.id,
    required this.title,
    required this.value,
    required this.isMoney,
    required this.subtitle,
    this.change,
  });
}

/// The cards, with the cost cards only for [canSeeCost].
List<ProductionSummaryCard> productionSummaryCards(
  ProductionSummaryResult r, {
  required bool canSeeCost,
}) {
  final s = r.stats;
  final c = r.changes;
  return [
    ProductionSummaryCard(
      id: 'runs',
      title: 'Production Runs',
      value: s.runs.toDouble(),
      isMoney: false,
      subtitle: 'Records in this period',
      change: c.runs,
    ),
    if (canSeeCost) ...[
      ProductionSummaryCard(
        id: 'recordedCost',
        title: 'Recorded Cost',
        value: s.recordedCost,
        isMoney: true,
        subtitle: 'Cost saved on the records',
        change: c.recordedCost,
      ),
      ProductionSummaryCard(
        id: 'materialCost',
        title: 'Material Cost',
        value: s.materialCost,
        isMoney: true,
        subtitle: 'Cost of the materials used',
        change: c.materialCost,
      ),
      ProductionSummaryCard(
        id: 'averageCost',
        title: 'Average Cost per Run',
        value: s.averageCostPerRun,
        isMoney: true,
        subtitle: 'Recorded cost per record',
        change: c.averageCostPerRun,
      ),
      ProductionSummaryCard(
        id: 'variance',
        title: 'Cost Variance',
        value: s.variance,
        isMoney: true,
        subtitle: 'Recorded minus material cost',
      ),
    ],
    ProductionSummaryCard(
      id: 'outputs',
      title: 'Items Produced',
      value: s.distinctOutputs.toDouble(),
      isMoney: false,
      subtitle: 'Distinct output items',
      change: c.distinctOutputs,
    ),
    ProductionSummaryCard(
      id: 'materials',
      title: 'Materials Used',
      value: s.distinctMaterials.toDouble(),
      isMoney: false,
      subtitle: 'Distinct materials',
    ),
    ProductionSummaryCard(
      id: 'staff',
      title: 'Staff Involved',
      value: s.distinctStaff.toDouble(),
      isMoney: false,
      subtitle: 'Distinct staff',
    ),
  ];
}
