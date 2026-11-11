import 'package:flutter/material.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_trend_buckets.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

/// Statistic cards of the usage summary.
class UsageSummaryStats {
  final int records;
  final double cost;
  final int productionRecords;
  final double productionCost;
  final int manualRecords;
  final double manualCost;
  final int distinctMaterials;
  final int distinctStaff;

  const UsageSummaryStats({
    required this.records,
    required this.cost,
    required this.productionRecords,
    required this.productionCost,
    required this.manualRecords,
    required this.manualCost,
    required this.distinctMaterials,
    required this.distinctStaff,
  });

  static UsageSummaryStats of(List<UsageRecordRow> rows) {
    final materials = <String>{};
    final staff = <String>{};
    double cost = 0;
    double productionCost = 0;
    int production = 0;
    for (final r in rows) {
      cost += r.cost;
      if (r.source == UsageSource.production) {
        production++;
        productionCost += r.cost;
      }
      materials.add(r.materialKey);
      if (r.staffKey != null) staff.add(r.staffKey!);
    }
    return UsageSummaryStats(
      records: rows.length,
      cost: cost,
      productionRecords: production,
      productionCost: productionCost,
      manualRecords: rows.length - production,
      manualCost: cost - productionCost,
      distinctMaterials: materials.length,
      distinctStaff: staff.length,
    );
  }
}

/// Change of each card against the previous period of the same
/// length. Every field is null for all time.
class UsageSummaryChanges {
  final GeneralReportChange? records;
  final GeneralReportChange? cost;
  final GeneralReportChange? productionRecords;
  final GeneralReportChange? productionCost;
  final GeneralReportChange? manualRecords;
  final GeneralReportChange? manualCost;
  final GeneralReportChange? distinctMaterials;

  const UsageSummaryChanges({
    this.records,
    this.cost,
    this.productionRecords,
    this.productionCost,
    this.manualRecords,
    this.manualCost,
    this.distinctMaterials,
  });

  static const none = UsageSummaryChanges();

  static UsageSummaryChanges compare(
    UsageSummaryStats current,
    UsageSummaryStats? previous,
  ) {
    if (previous == null) return none;
    GeneralReportChange? c(num a, num b) => GeneralReportChange.compare(
      current: a.toDouble(),
      previous: b.toDouble(),
    );
    return UsageSummaryChanges(
      records: c(current.records, previous.records),
      cost: c(current.cost, previous.cost),
      productionRecords: c(
        current.productionRecords,
        previous.productionRecords,
      ),
      productionCost: c(current.productionCost, previous.productionCost),
      manualRecords: c(current.manualRecords, previous.manualRecords),
      manualCost: c(current.manualCost, previous.manualCost),
      distinctMaterials: c(
        current.distinctMaterials,
        previous.distinctMaterials,
      ),
    );
  }
}

/// One bucket of the trend chart: production and manual usage.
class UsageTrendPoint {
  final DateTime start;
  int productionRecords = 0;
  int manualRecords = 0;
  double productionCost = 0;
  double manualCost = 0;

  UsageTrendPoint(this.start);

  int get records => productionRecords + manualRecords;
  double get cost => productionCost + manualCost;
}

class UsageTrendBuilder {
  static List<UsageTrendPoint> build({
    required List<UsageRecordRow> rows,
    required ReceiptsReportPeriod period,
    DateTime? now,
    TimeOfDay? closingTime,
  }) => ProductionTrendBuckets.build<UsageTrendPoint, UsageRecordRow>(
    rows: rows,
    dateOf: (r) => r.createdAt,
    newPoint: UsageTrendPoint.new,
    add: (p, r) {
      if (r.source == UsageSource.production) {
        p.productionRecords++;
        p.productionCost += r.cost;
      } else {
        p.manualRecords++;
        p.manualCost += r.cost;
      }
    },
    period: period,
    now: now,
    closingTime: closingTime,
  );
}

enum UsageBreakdownTab { materials, source, staff, departments }

extension UsageBreakdownTabLabel on UsageBreakdownTab {
  String get label {
    switch (this) {
      case UsageBreakdownTab.materials:
        return 'Materials';
      case UsageBreakdownTab.source:
        return 'Source';
      case UsageBreakdownTab.staff:
        return 'Staff';
      case UsageBreakdownTab.departments:
        return 'Departments';
    }
  }
}

/// The tabs the summary offers: Departments only with departments on.
List<UsageBreakdownTab> usageBreakdownTabs({required bool departmentsEnabled}) => [
  UsageBreakdownTab.materials,
  UsageBreakdownTab.source,
  UsageBreakdownTab.staff,
  if (departmentsEnabled) UsageBreakdownTab.departments,
];

/// A breakdown column, also its sort field.
enum UsageBreakdownField { name, count, quantity, cost, unitCost, lastDate, share }

class UsageBreakdownColumn {
  final UsageBreakdownField field;
  final String label;
  final ProductionBreakdownKind kind;
  final double width;

  const UsageBreakdownColumn(this.field, this.label, this.kind, this.width);
}

/// The columns of [tab], with the cost and quantity permissions
/// applied. The screen and the export both use this list. The average
/// unit cost needs both (cost ÷ unit cost gives the quantity).
List<UsageBreakdownColumn> usageBreakdownColumns(
  UsageBreakdownTab tab, {
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  UsageBreakdownColumn col(
    UsageBreakdownField field,
    String label,
    ProductionBreakdownKind kind, [
    double width = 130,
  ]) => UsageBreakdownColumn(field, label, kind, width);
  const k = (
    text: ProductionBreakdownKind.text,
    count: ProductionBreakdownKind.count,
    qty: ProductionBreakdownKind.quantity,
    money: ProductionBreakdownKind.money,
    date: ProductionBreakdownKind.date,
    pct: ProductionBreakdownKind.percent,
  );
  final name = switch (tab) {
    UsageBreakdownTab.materials => 'Material',
    UsageBreakdownTab.source => 'Source',
    UsageBreakdownTab.staff => 'Staff',
    UsageBreakdownTab.departments => 'Department',
  };
  final materials = tab == UsageBreakdownTab.materials;
  return [
    col(UsageBreakdownField.name, name, k.text, 200),
    col(UsageBreakdownField.count, 'Records', k.count, 100),
    if (materials && canSeeQuantity)
      col(UsageBreakdownField.quantity, 'Qty Used', k.qty, 150),
    if (canSeeCost) col(UsageBreakdownField.cost, 'Cost', k.money, 150),
    if (materials && canSeeCost && canSeeQuantity)
      col(UsageBreakdownField.unitCost, 'Avg Unit Cost', k.money, 150),
    col(UsageBreakdownField.lastDate, 'Last Used', k.date, 140),
    col(UsageBreakdownField.share, 'Share', k.pct, 100),
  ];
}

/// One row of a breakdown table. [filters] open the table on exactly
/// its records. Fields a tab doesn't use are null.
class UsageBreakdownRow {
  /// Unique within the page: tab and key.
  final String id;
  final String key;
  final String label;

  /// The none row ("No staff", "No Department"), always last.
  final bool isNone;
  final int count;

  /// Materials only: quantity in the primary unit, and the average cost
  /// of one unit.
  final double? quantity;
  final String? unit;
  final double? unitCost;

  final double cost;
  final DateTime? lastDate;

  /// Share of the cost (with the cost permission) or of the records.
  final double? share;
  final UsageRecordsFilters filters;

  const UsageBreakdownRow({
    required this.id,
    required this.key,
    required this.label,
    required this.isNone,
    required this.count,
    this.quantity,
    this.unit,
    this.unitCost,
    required this.cost,
    this.lastDate,
    this.share,
    required this.filters,
  });

  /// The raw value of [field] (for sorting and the export).
  Object? valueOf(UsageBreakdownField field) {
    switch (field) {
      case UsageBreakdownField.name:
        return label;
      case UsageBreakdownField.count:
        return count;
      case UsageBreakdownField.quantity:
        return quantity;
      case UsageBreakdownField.cost:
        return cost;
      case UsageBreakdownField.unitCost:
        return unitCost;
      case UsageBreakdownField.lastDate:
        return lastDate;
      case UsageBreakdownField.share:
        return share;
    }
  }

  /// The unit shown after a quantity column, if any.
  String? unitOf(UsageBreakdownField field) =>
      field == UsageBreakdownField.quantity ? unit : null;
}

/// Everything the usage summary page shows for one period.
class UsageSummaryResult {
  /// Rows in the period.
  final List<UsageRecordRow> rows;
  final UsageSummaryStats stats;

  /// Null for all time.
  final UsageSummaryStats? previous;
  final UsageSummaryChanges changes;
  final List<UsageTrendPoint> trend;

  /// Null without a chart (all time with no records).
  final ReceiptsTrendInterval? interval;
  final Map<UsageBreakdownTab, List<UsageBreakdownRow>> breakdowns;

  const UsageSummaryResult({
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
  int count = 0;
  double cost = 0;
  double? quantity;
  String? unit;
  DateTime? lastDate;

  _Acc(this.key, this.isNone);
}

class UsageSummaryBuilder {
  static double? _share(double part, double total) =>
      total > 0 ? part / total * 100 : null;

  /// The summary's filters with one key set, for opening the table on
  /// exactly the records of a summary row.
  static UsageRecordsFilters handoff(
    UsageRecordsFilters base, {
    String? materialKey,
    UsageSource? source,
    String? staffKey,
    String? departmentKey,
  }) {
    final f = base.copy();
    if (materialKey != null) f.materialKey = materialKey;
    if (source != null) f.source = source;
    if (staffKey != null) f.staffKey = staffKey;
    if (departmentKey != null) f.departmentKey = departmentKey;
    return f;
  }

  static List<UsageBreakdownRow> _keyed({
    required UsageBreakdownTab tab,
    required List<UsageRecordRow> rows,
    required (String?, String?) Function(UsageRecordRow) key,
    required String noneLabel,
    required UsageRecordsFilters Function(String key) filters,
    required bool canSeeCost,
    bool withQuantity = false,
  }) {
    final newestFirst = List<UsageRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final accs = <String, _Acc>{};
    double totalCost = 0;
    for (final r in newestFirst) {
      final (k, name) = key(r);
      final a = accs.putIfAbsent(
        k ?? productionReportNoneKey,
        () => _Acc(k ?? productionReportNoneKey, k == null),
      );
      a.name ??= name;
      a.count++;
      a.cost += r.cost;
      a.lastDate ??= r.createdAt;
      if (withQuantity) {
        a.quantity = (a.quantity ?? 0) + r.primaryQty;
        a.unit ??= r.primaryUnit;
      }
      totalCost += r.cost;
    }
    final out = [
      for (final a in accs.values)
        UsageBreakdownRow(
          id: '${tab.name}-${a.key}',
          key: a.key,
          label: a.isNone ? noneLabel : (a.name ?? 'Not Set'),
          isNone: a.isNone,
          count: a.count,
          quantity: a.quantity,
          unit: a.unit,
          unitCost:
              withQuantity && (a.quantity ?? 0) > 0 ? a.cost / a.quantity! : null,
          cost: a.cost,
          lastDate: a.lastDate,
          share:
              canSeeCost
                  ? _share(a.cost, totalCost)
                  : _share(a.count.toDouble(), rows.length.toDouble()),
          filters: filters(a.key),
        ),
    ];
    // Built order: share largest first; ties: label, then key; the
    // none row last.
    out.sort((a, b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      final c = (b.share ?? -1).compareTo(a.share ?? -1);
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    });
    return out;
  }

  static Map<UsageBreakdownTab, List<UsageBreakdownRow>> _breakdowns(
    List<UsageRecordRow> rows, {
    required bool departmentsEnabled,
    required bool canSeeCost,
  }) {
    final b = UsageRecordsFilters();
    return {
      UsageBreakdownTab.materials: _keyed(
        tab: UsageBreakdownTab.materials,
        rows: rows,
        key: (r) => (r.materialKey, r.materialName),
        noneLabel: '',
        filters: (k) => handoff(b, materialKey: k),
        canSeeCost: canSeeCost,
        withQuantity: true,
      ),
      UsageBreakdownTab.source: _keyed(
        tab: UsageBreakdownTab.source,
        rows: rows,
        key: (r) => (r.source.key, r.source.label),
        noneLabel: '',
        filters: (k) => handoff(b, source: UsageSource.values.byName(k)),
        canSeeCost: canSeeCost,
      ),
      UsageBreakdownTab.staff: _keyed(
        tab: UsageBreakdownTab.staff,
        rows: rows,
        key: (r) => (r.staffKey, r.staffName),
        noneLabel: productionNoStaffLabel,
        filters: (k) => handoff(b, staffKey: k),
        canSeeCost: canSeeCost,
      ),
      if (departmentsEnabled)
        UsageBreakdownTab.departments: _keyed(
          tab: UsageBreakdownTab.departments,
          rows: rows,
          key: (r) => (r.departmentKey, r.departmentName),
          noneLabel: productionNoDepartmentLabel,
          filters: (k) => handoff(b, departmentKey: k),
          canSeeCost: canSeeCost,
        ),
    };
  }

  static List<UsageRecordRow> _inPeriod(
    List<UsageRecordRow> rows,
    ReceiptsReportPeriod period, {
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
  }) => UsageRecordsQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: UsageRecordsFilters(),
    sortField: UsageRecordsSortField.createdAt,
    ascending: false,
    departmentsEnabled: departmentsEnabled,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
    closingTime: closingTime,
  );

  /// Rows in [period] (the summary has no other filter), and the
  /// period before it for the comparison.
  static UsageSummaryResult build({
    required List<UsageRecordRow> rows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
    DateTime? now,
  }) {
    List<UsageRecordRow> inPeriod(ReceiptsReportPeriod p) => _inPeriod(
      rows,
      p,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      closingTime: closingTime,
    );
    final current = inPeriod(period);
    final previousPeriod = GeneralReportPeriods.previous(period);
    final previous =
        previousPeriod == null
            ? null
            : UsageSummaryStats.of(inPeriod(previousPeriod));
    final stats = UsageSummaryStats.of(current);
    final range = ProductionTrendBuckets.span(
      dates: current.map((r) => r.createdAt),
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    return UsageSummaryResult(
      rows: current,
      stats: stats,
      previous: previous,
      changes: UsageSummaryChanges.compare(stats, previous),
      trend: UsageTrendBuilder.build(
        rows: current,
        period: period,
        now: now,
        closingTime: closingTime,
      ),
      interval:
          range == null
              ? null
              : ReceiptsTrendBuilder.intervalFor(range.start, range.end),
      breakdowns: _breakdowns(
        current,
        departmentsEnabled: departmentsEnabled,
        canSeeCost: canSeeCost,
      ),
    );
  }

  /// Rows of [tab] in their built order.
  static List<UsageBreakdownRow> breakdown(
    UsageSummaryResult result,
    UsageBreakdownTab tab,
  ) => result.breakdowns[tab] ?? const [];

  /// Sorted copy. A null [field] keeps the built order. The none row is
  /// always last; nulls sink to the bottom; ties: label, then key.
  static List<UsageBreakdownRow> sortBreakdown(
    List<UsageBreakdownRow> rows, {
    required UsageBreakdownField? field,
    required bool ascending,
  }) {
    if (field == null) return List<UsageBreakdownRow>.from(rows);
    int compare(UsageBreakdownRow a, UsageBreakdownRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      Comparable? v(UsageBreakdownRow r) {
        final x = r.valueOf(field);
        if (x is String) return x.toLowerCase();
        return x as Comparable?;
      }

      final c = ProductionRecordsQuery.cmp(v(a), v(b), ascending);
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<UsageBreakdownRow>.from(rows)..sort(compare);
  }
}

/// The cards, with the cost cards only for [canSeeCost]. The split
/// cards show cost with the cost permission, else records. The screen
/// and the export both build their cards from this.
List<ProductionSummaryCard> usageSummaryCards(
  UsageSummaryResult r, {
  required bool canSeeCost,
}) {
  final s = r.stats;
  final c = r.changes;
  return [
    if (canSeeCost)
      ProductionSummaryCard(
        id: 'cost',
        title: 'Usage Cost',
        value: s.cost,
        isMoney: true,
        subtitle: 'Cost of the materials used',
        change: c.cost,
      ),
    ProductionSummaryCard(
      id: 'records',
      title: 'Usage Records',
      value: s.records.toDouble(),
      isMoney: false,
      subtitle: 'Records in this period',
      change: c.records,
    ),
    if (canSeeCost) ...[
      ProductionSummaryCard(
        id: 'production',
        title: 'Production Usage',
        value: s.productionCost,
        isMoney: true,
        subtitle: '${s.productionRecords} from productions',
        change: c.productionCost,
      ),
      ProductionSummaryCard(
        id: 'manual',
        title: 'Manual Usage',
        value: s.manualCost,
        isMoney: true,
        subtitle: '${s.manualRecords} entered by hand',
        change: c.manualCost,
      ),
    ] else ...[
      ProductionSummaryCard(
        id: 'production',
        title: 'Production Usage',
        value: s.productionRecords.toDouble(),
        isMoney: false,
        subtitle: 'Records from productions',
        change: c.productionRecords,
      ),
      ProductionSummaryCard(
        id: 'manual',
        title: 'Manual Usage',
        value: s.manualRecords.toDouble(),
        isMoney: false,
        subtitle: 'Records entered by hand',
        change: c.manualRecords,
      ),
    ],
    ProductionSummaryCard(
      id: 'materials',
      title: 'Materials Used',
      value: s.distinctMaterials.toDouble(),
      isMoney: false,
      subtitle: 'Distinct materials',
      change: c.distinctMaterials,
    ),
  ];
}
