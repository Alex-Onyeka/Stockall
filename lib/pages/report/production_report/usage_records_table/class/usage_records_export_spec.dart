// Export spec of the Usage Records table, grouping-aware: the usage
// rows (the full filtered and sorted list, not the page) when Group by
// is off, or the group table the user sees when it is on. Totals are
// the screen's own (UsageRecordsPage / UsageGroupPage). Cost columns
// need the cost permission and quantity columns the quantity
// permission, as on screen.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// The Quantity cell: "1 Bag", or "500 g (0.5 Kg)" when the usage was
/// saved in another unit. The screen and the export both use it.
String usageRecordQuantityText(
  UsageRecordRow r,
  String Function(num v) number,
) {
  final recorded = '${number(r.quantity)} ${r.unitLabel}';
  if (r.unitLabel == r.primaryUnit &&
      (r.quantity - r.primaryQty).abs() < 0.0000001) {
    return recorded;
  }
  return '$recorded (${number(r.primaryQty)} ${r.primaryUnit})';
}

const Map<UsageRecordsSortField, String> usageSortLabels = {
  UsageRecordsSortField.createdAt: 'Date',
  UsageRecordsSortField.material: 'Material',
  UsageRecordsSortField.quantity: 'Quantity',
  UsageRecordsSortField.unitCost: 'Unit Cost',
  UsageRecordsSortField.cost: 'Cost',
  UsageRecordsSortField.source: 'Source',
  UsageRecordsSortField.staff: 'Staff',
};

String _dir(bool ascending) => ascending ? 'ascending' : 'descending';

String usageSortLabel(UsageRecordsSortField field, bool ascending) =>
    '${usageSortLabels[field] ?? field.name} (${_dir(ascending)})';

String usageGroupSortLabel(
  UsageGroupSortField field,
  bool ascending,
  UsageGroupBy groupBy,
) {
  final label = switch (field) {
    UsageGroupSortField.name => groupBy.label,
    UsageGroupSortField.count => 'Records',
    UsageGroupSortField.quantity => 'Quantity',
    UsageGroupSortField.cost => 'Cost',
    UsageGroupSortField.unitCost => 'Avg Unit Cost',
    UsageGroupSortField.lastDate => 'Last Used',
  };
  return '$label (${_dir(ascending)})';
}

/// The table's filters with their values, worded and ordered like the
/// chips (with the search box first).
List<ExportFilter> usageExportFilters({
  required UsageRecordsFilters filters,
  required UsageRecordsFilterChoices choices,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required ExportFormatter f,
}) {
  return [
    for (final (label, value, _) in usageFilterEntries(
      filters: filters,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      money: f.money,
      number: f.quantity,
    ))
      ExportFilter(label, value),
  ];
}

String _records(ExportFormatter f, int n) =>
    '${f.integer(n)} ${n == 1 ? 'record' : 'records'}';

/// The totals row of [rows] by column id, as the screen's
/// UsageRecordsPage. Quantity and Unit Cost only for
/// [singleMaterialKey].
Map<String, Object?> usageRecordsTotals(
  List<UsageRecordRow> rows, {
  required ExportFormatter f,
  required String? singleMaterialKey,
}) {
  final page = UsageRecordsQuery.paginate(
    rows,
    1,
    singleMaterialKey: singleMaterialKey,
  );
  return {
    'id': _records(f, rows.length),
    'quantity': page.totalQuantity ?? _dash,
    'qtyRoll':
        page.totalQuantity == null
            ? _dash
            : '${f.quantity(page.totalQuantity!)} ${page.quantityUnit ?? ''}'
                .trim(),
    'unitCost': page.averageUnitCost ?? _dash,
    'cost': page.totalCost,
  };
}

/// The material key when every row has the same one (a split sheet of
/// one material), else null.
String? _sharedMaterial(List<UsageRecordRow> rows) {
  if (rows.isEmpty) return null;
  final k = rows.first.materialKey;
  return rows.every((r) => r.materialKey == k) ? k : null;
}

RollLayout _tableRoll({required bool canSeeCost, required bool canSeeQuantity}) {
  // Same widths as the Production Records roll: "₦1,250,000.00" and
  // "1,250 Bag" stay on one line. The ID and date go on the sub-line.
  if (canSeeCost) {
    return RollLayout(
      cols58: const ['material', 'cost'],
      cols80: ['material', canSeeQuantity ? 'qtyRoll' : 'source', 'cost'],
      sub58: const ['id', 'date'],
      sub80: const ['id', 'date'],
      flex58: const [1, 1],
      flex80: const [20, 14, 14],
    );
  }
  if (canSeeQuantity) {
    return const RollLayout(
      cols58: ['material', 'qtyRoll'],
      cols80: ['material', 'source', 'qtyRoll'],
      sub58: ['id', 'date'],
      sub80: ['id', 'date'],
      flex58: [1, 1],
      flex80: [20, 14, 14],
    );
  }
  return const RollLayout(
    cols58: ['material', 'source'],
    cols80: ['material', 'source', 'date'],
    sub58: ['id', 'date'],
    sub80: ['id'],
    flex58: [1, 1],
    flex80: [20, 14, 14],
  );
}

ExportTableSection<UsageRecordRow> usageRecordsTableSection({
  required List<UsageRecordRow> rows,
  required ExportFormatter f,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required String? singleMaterialKey,
}) {
  final departmentNames = <String, String>{
    for (final r in rows)
      if (r.departmentKey != null) r.departmentKey!: r.departmentLabel,
  };
  return ExportTableSection<UsageRecordRow>(
    title: 'Usage Records',
    rows: rows,
    columns: [
      ExportColumn(id: 'id', label: 'ID', value: (r) => r.displayId, width: 1.4),
      ExportColumn(
        id: 'date',
        label: 'Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
      ),
      ExportColumn(
        id: 'time',
        label: 'Time',
        format: ExportFormat.time,
        value: (r) => r.createdAt,
      ),
      ExportColumn(
        id: 'material',
        label: 'Material',
        value: (r) => r.materialName,
        width: 1.6,
      ),
      if (canSeeQuantity) ...[
        // Excel stores the quantity in the primary unit (next column).
        ExportColumn(
          id: 'quantity',
          label: 'Quantity',
          format: ExportFormat.quantity,
          value: (r) => r.primaryQty,
          display: (r) => usageRecordQuantityText(r, f.quantity),
          width: 1.3,
        ),
        ExportColumn(
          id: 'unit',
          label: 'Unit',
          value: (r) => r.primaryUnit,
          inPdf: false,
        ),
        // Roll only: the quantity in the primary unit, short.
        ExportColumn(
          id: 'qtyRoll',
          label: 'Qty',
          value: (r) => '${f.quantity(r.primaryQty)} ${r.primaryUnit}',
          inPdf: false,
          inExcel: false,
        ),
      ],
      if (canSeeCost) ...[
        // Cost ÷ unit cost gives the quantity, so it needs both.
        if (canSeeQuantity)
          ExportColumn(
            id: 'unitCost',
            label: 'Unit Cost',
            format: ExportFormat.money,
            value: (r) => r.unitCost,
            display: (r) => r.unitCost == null ? _dash : f.money(r.unitCost!),
            width: 1.2,
          ),
        ExportColumn(
          id: 'cost',
          label: 'Cost',
          format: ExportFormat.money,
          value: (r) => r.cost,
          width: 1.3,
        ),
      ],
      ExportColumn(id: 'source', label: 'Source', value: (r) => r.source.label),
      ExportColumn(
        id: 'production',
        label: 'Production',
        value: (r) => r.productionLabel ?? _dash,
        width: 1.8,
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'staff',
        label: 'Staff',
        value: (r) => r.staffLabel,
        width: 1.2,
      ),
      ExportColumn(
        id: 'managed',
        label: 'Managed',
        value: (r) => r.managedLabel,
        width: 0.8,
      ),
    ],
    totals: usageRecordsTotals(
      rows,
      f: f,
      singleMaterialKey: singleMaterialKey,
    ),
    // A split sheet of one material totals its quantity, as a material
    // group does on screen.
    totalsFor:
        (rs) => usageRecordsTotals(
          rs,
          f: f,
          singleMaterialKey: _sharedMaterial(rs),
        ),
    splits: [
      fieldSplit<UsageRecordRow>(
        id: 'material',
        label: 'Material',
        noneLabel: 'No Material',
        rows: rows,
        key: (r) => r.materialKey,
        name: (r) => r.materialName,
      ),
      fieldSplit<UsageRecordRow>(
        id: 'source',
        label: 'Source',
        noneLabel: 'No Source',
        rows: rows,
        key: (r) => r.source.key,
        name: (r) => r.source.label,
      ),
      staffSplit<UsageRecordRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
      if (departmentsEnabled)
        departmentSplit<UsageRecordRow>(
          departmentId: (r) => r.departmentKey,
          names: departmentNames,
        ),
    ],
    roll: _tableRoll(canSeeCost: canSeeCost, canSeeQuantity: canSeeQuantity),
    emptyMessage: 'No usage record matches the selected period and filters.',
  );
}

ExportTableSection<UsageGroupRow> usageGroupSection({
  required List<UsageGroupRow> groups,
  required UsageGroupBy groupBy,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  final byMaterial = groupBy == UsageGroupBy.material;
  final showQty = canSeeQuantity && byMaterial;
  final page = UsageGrouping.paginate(groups, 1);

  final RollLayout roll;
  if (canSeeCost) {
    roll = const RollLayout(
      cols58: ['name', 'cost'],
      cols80: ['name', 'records', 'cost'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    );
  } else if (showQty) {
    roll = const RollLayout(
      cols58: ['name', 'quantity'],
      cols80: ['name', 'records', 'quantity'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    );
  } else {
    roll = const RollLayout(
      cols58: ['name', 'records'],
      cols80: ['name', 'records'],
      flex58: [3, 1],
      flex80: [3, 1],
    );
  }

  return ExportTableSection<UsageGroupRow>(
    title: 'Usage Records by ${groupBy.label}',
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: groupBy.label, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'records',
        label: 'Records',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.8,
      ),
      if (showQty)
        ExportColumn(
          id: 'quantity',
          label: 'Qty Used',
          format: ExportFormat.quantity,
          value: (g) => g.quantity,
          display:
              (g) =>
                  g.quantity == null
                      ? _dash
                      : '${f.quantity(g.quantity!)} ${g.unit ?? ''}'.trim(),
          width: 1.2,
        ),
      if (canSeeCost)
        ExportColumn(
          id: 'cost',
          label: 'Cost',
          format: ExportFormat.money,
          value: (g) => g.cost,
          width: 1.2,
        ),
      if (canSeeCost && showQty)
        ExportColumn(
          id: 'unitCost',
          label: 'Avg Unit Cost',
          format: ExportFormat.money,
          value: (g) => g.unitCost,
          display: (g) => g.unitCost == null ? _dash : f.money(g.unitCost!),
          width: 1.2,
        ),
      ExportColumn(
        id: 'lastDate',
        label: 'Last Used',
        format: ExportFormat.date,
        value: (g) => g.lastDate,
      ),
    ],
    totals: {
      'name': '${f.integer(groups.length)} ${groupBy.pagerLabel}',
      'records': page.totalRecords,
      'quantity': _dash,
      'cost': page.totalCost,
      'unitCost': _dash,
      'lastDate': _dash,
    },
    roll: roll,
    emptyMessage: 'No usage record matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted usage list; [groups] the full
/// sorted group list (used when grouped); [allUsages] and [recordRows]
/// every loaded usage and production row, for the notes.
ReportExportSpec usageRecordsExportSpec({
  required List<UsageRecordRow> rows,
  required List<UsageGroupRow> groups,
  required List<UsageRecordRow> allUsages,
  required List<ProductionRecordRow> recordRows,
  required UsageRecordsTableState state,
  required UsageRecordsFilterChoices choices,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  TimeOfDay? closingTime,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = state.grouped;
  return ReportExportSpec(
    reportName: 'Usage Records',
    fileSlug: 'usage_records',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: usageExportFilters(
      filters: state.filters,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      f: f,
    ),
    sortedBy:
        grouped
            ? usageGroupSortLabel(
              state.groupSortField,
              state.groupAscending,
              state.groupBy,
            )
            : usageSortLabel(state.sortField, state.ascending),
    groupedBy: grouped ? state.groupBy.label : null,
    notes: usageRecordsNotes(
      period: period,
      usages: allUsages,
      recordRows: recordRows,
      closingTime: closingTime,
    ),
    sections: [
      if (grouped)
        usageGroupSection(
          groups: groups,
          groupBy: state.groupBy,
          f: f,
          canSeeCost: canSeeCost,
          canSeeQuantity: canSeeQuantity,
        )
      else
        usageRecordsTableSection(
          rows: rows,
          f: f,
          departmentsEnabled: departmentsEnabled,
          canSeeCost: canSeeCost,
          canSeeQuantity: canSeeQuantity,
          singleMaterialKey: state.filters.singleMaterialKey,
        ),
    ],
  );
}
