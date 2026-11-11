// Export spec of the Production Records table, grouping-aware: the
// record rows (the full filtered and sorted list, not the page) when
// Group by is off, or the group table the user sees when it is on.
// Totals are the screen's own (ProductionRecordsPage /
// ProductionGroupPage). Cost columns need the cost permission and
// quantity columns the quantity permission, as on screen.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// The Quantity cell: "30 Pcs", or "3 Box (36 Pcs)" when the record
/// was made in another unit. The screen and the export both use it.
String productionRecordQuantityText(
  ProductionRecordRow r,
  String Function(num v) number,
) {
  final recorded = '${number(r.quantity)} ${r.unitLabel}';
  if (r.unitLabel == r.primaryUnit &&
      (r.quantity - r.primaryQty).abs() < 0.0000001) {
    return recorded;
  }
  return '$recorded (${number(r.primaryQty)} ${r.primaryUnit})';
}

const Map<ProductionRecordsSortField, String> productionSortLabels = {
  ProductionRecordsSortField.createdAt: 'Date',
  ProductionRecordsSortField.output: 'Output',
  ProductionRecordsSortField.staff: 'Staff',
  ProductionRecordsSortField.quantity: 'Quantity',
  ProductionRecordsSortField.materialCost: 'Material Cost',
  ProductionRecordsSortField.recordedCost: 'Recorded Cost',
  ProductionRecordsSortField.variance: 'Variance',
  ProductionRecordsSortField.costPerUnit: 'Cost / Unit',
};

String _dir(bool ascending) => ascending ? 'ascending' : 'descending';

String productionSortLabel(ProductionRecordsSortField field, bool ascending) =>
    '${productionSortLabels[field] ?? field.name} (${_dir(ascending)})';

String productionGroupSortLabel(
  ProductionGroupSortField field,
  bool ascending,
  ProductionGroupBy groupBy,
) {
  final label = switch (field) {
    ProductionGroupSortField.name => groupBy.label,
    ProductionGroupSortField.count => 'Records',
    ProductionGroupSortField.quantity => 'Quantity',
    ProductionGroupSortField.materialCost => 'Material Cost',
    ProductionGroupSortField.recordedCost => 'Recorded Cost',
    ProductionGroupSortField.variance => 'Variance',
    ProductionGroupSortField.costPerUnit => 'Cost / Unit',
  };
  return '$label (${_dir(ascending)})';
}

/// The table's filters with their values, worded and ordered like the
/// chips (with the search box first).
List<ExportFilter> productionExportFilters({
  required ProductionRecordsFilters filters,
  required ProductionRecordsFilterChoices choices,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required ExportFormatter f,
}) {
  return [
    for (final (label, value, _) in productionFilterEntries(
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
/// ProductionRecordsPage. Quantity and Cost / Unit only for
/// [singleOutputKey].
Map<String, Object?> productionRecordsTotals(
  List<ProductionRecordRow> rows, {
  required ExportFormatter f,
  required String? singleOutputKey,
}) {
  final page = ProductionRecordsQuery.paginate(
    rows,
    1,
    singleOutputKey: singleOutputKey,
  );
  return {
    'id': _records(f, rows.length),
    'quantity': page.totalQuantity ?? _dash,
    'materialCost': page.totalMaterialCost,
    'recordedCost': page.totalRecordedCost,
    'variance': page.totalVariance,
    'costPerUnit': page.totalCostPerUnit ?? _dash,
  };
}

/// The output key when every row has the same one (a split sheet of
/// one output item), else null.
String? _sharedOutput(List<ProductionRecordRow> rows) {
  if (rows.isEmpty) return null;
  final k = rows.first.outputKey;
  if (k == null) return null;
  return rows.every((r) => r.outputKey == k) ? k : null;
}

RollLayout _tableRoll({required bool canSeeCost, required bool canSeeQuantity}) {
  // 58mm: 15 / 16 characters. 80mm: 19 / 13 / 14 after the gaps, so
  // "₦1,250,000.00" and "1,250 Pcs" stay on one line. The ID and date
  // go on the sub-line on both papers.
  if (canSeeCost) {
    return RollLayout(
      cols58: const ['output', 'recordedCost'],
      cols80: [
        'output',
        canSeeQuantity ? 'qtyRoll' : 'materialCost',
        'recordedCost',
      ],
      sub58: const ['id', 'date'],
      sub80: const ['id', 'date'],
      flex58: const [1, 1],
      flex80: const [20, 14, 14],
    );
  }
  if (canSeeQuantity) {
    return const RollLayout(
      cols58: ['output', 'qtyRoll'],
      cols80: ['output', 'staff', 'qtyRoll'],
      sub58: ['id', 'date'],
      sub80: ['id', 'date'],
      flex58: [1, 1],
      flex80: [20, 14, 14],
    );
  }
  return const RollLayout(
    cols58: ['output', 'staff'],
    cols80: ['output', 'staff', 'lines'],
    sub58: ['id', 'date'],
    sub80: ['id', 'date'],
    flex58: [1, 1],
    flex80: [20, 20, 8],
  );
}

ExportTableSection<ProductionRecordRow> productionRecordsTableSection({
  required List<ProductionRecordRow> rows,
  required ExportFormatter f,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required String? singleOutputKey,
}) {
  final departmentNames = <String, String>{
    for (final r in rows)
      if (r.departmentKey != null) r.departmentKey!: r.departmentLabel,
  };
  return ExportTableSection<ProductionRecordRow>(
    title: 'Production Records',
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
        id: 'output',
        label: 'Output',
        value: (r) => r.outputName,
        width: 1.6,
      ),
      ExportColumn(
        id: 'type',
        label: 'Type',
        value: (r) => r.outputType.label,
      ),
      if (canSeeQuantity) ...[
        // Excel stores the quantity in the primary unit (next column).
        ExportColumn(
          id: 'quantity',
          label: 'Quantity',
          format: ExportFormat.quantity,
          value: (r) => r.primaryQty,
          display: (r) => productionRecordQuantityText(r, f.quantity),
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
      ExportColumn(
        id: 'materials',
        label: 'Materials',
        value: (r) => r.materialsLabel,
        width: 1.6,
      ),
      ExportColumn(
        id: 'lines',
        label: 'Lines',
        format: ExportFormat.integer,
        value: (r) => r.lines.length,
        width: 0.6,
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
      if (canSeeCost) ...[
        ExportColumn(
          id: 'materialCost',
          label: 'Material Cost',
          format: ExportFormat.money,
          value: (r) => r.materialCost,
          width: 1.3,
        ),
        ExportColumn(
          id: 'recordedCost',
          label: 'Recorded Cost',
          format: ExportFormat.money,
          value: (r) => r.recordedCost,
          width: 1.3,
        ),
        ExportColumn(
          id: 'costSource',
          label: 'Cost Source',
          value: (r) => r.costSource.label,
        ),
        ExportColumn(
          id: 'variance',
          label: 'Variance',
          format: ExportFormat.money,
          value: (r) => r.variance,
          width: 1.2,
        ),
        if (canSeeQuantity)
          ExportColumn(
            id: 'costPerUnit',
            label: 'Cost / Unit',
            format: ExportFormat.money,
            value: (r) => r.costPerUnit,
            display: (r) => r.costPerUnit == null ? _dash : f.money(r.costPerUnit!),
            width: 1.2,
          ),
      ],
      ExportColumn(
        id: 'comment',
        label: 'Comment',
        value: (r) => r.comment ?? '',
        inPdf: false,
      ),
    ],
    totals: productionRecordsTotals(
      rows,
      f: f,
      singleOutputKey: singleOutputKey,
    ),
    // A split sheet of one output item totals its quantity, as a
    // per-item group does on screen.
    totalsFor:
        (rs) => productionRecordsTotals(
          rs,
          f: f,
          singleOutputKey: _sharedOutput(rs),
        ),
    splits: [
      fieldSplit<ProductionRecordRow>(
        id: 'output',
        label: 'Output Item',
        noneLabel: 'No Output Item',
        rows: rows,
        key: (r) => r.outputKey,
        name: (r) => r.outputName,
      ),
      staffSplit<ProductionRecordRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
      if (departmentsEnabled)
        departmentSplit<ProductionRecordRow>(
          departmentId: (r) => r.departmentKey,
          names: departmentNames,
        ),
    ],
    roll: _tableRoll(canSeeCost: canSeeCost, canSeeQuantity: canSeeQuantity),
    emptyMessage:
        'No production record matches the selected period and filters.',
  );
}

ExportTableSection<ProductionGroupRow> productionGroupSection({
  required List<ProductionGroupRow> groups,
  required ProductionGroupBy groupBy,
  required int recordCount,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  final byOutput = groupBy == ProductionGroupBy.outputItem;
  final byMaterial = groupBy == ProductionGroupBy.material;
  final showQty = canSeeQuantity && (byOutput || byMaterial);
  final showRecorded = canSeeCost && !byMaterial;
  final page = ProductionGrouping.paginate(groups, 1, recordCount: recordCount);

  final String costId = byMaterial ? 'materialCost' : 'recordedCost';
  final RollLayout roll;
  if (canSeeCost) {
    roll = RollLayout(
      cols58: ['name', costId],
      cols80: ['name', 'records', costId],
      flex58: const [1, 1],
      flex80: const [4, 1, 3],
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

  return ExportTableSection<ProductionGroupRow>(
    title: 'Production Records by ${groupBy.label}',
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
          label: byMaterial ? 'Qty Used' : 'Qty Produced',
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
          id: 'materialCost',
          label: 'Material Cost',
          format: ExportFormat.money,
          value: (g) => g.materialCost,
          width: 1.2,
        ),
      if (showRecorded) ...[
        ExportColumn(
          id: 'recordedCost',
          label: 'Recorded Cost',
          format: ExportFormat.money,
          value: (g) => g.recordedCost,
          width: 1.2,
        ),
        ExportColumn(
          id: 'variance',
          label: 'Variance',
          format: ExportFormat.money,
          value: (g) => g.variance,
          width: 1.2,
        ),
      ],
      if (byOutput && canSeeCost && canSeeQuantity)
        ExportColumn(
          id: 'costPerUnit',
          label: 'Cost / Unit',
          format: ExportFormat.money,
          value: (g) => g.costPerUnit,
          display: (g) => g.costPerUnit == null ? _dash : f.money(g.costPerUnit!),
          width: 1.2,
        ),
    ],
    totals: {
      'name': '${f.integer(groups.length)} ${groupBy.pagerLabel}',
      'records': page.totalRecords,
      'quantity': _dash,
      'materialCost': page.totalMaterialCost,
      'recordedCost': page.totalRecordedCost ?? _dash,
      'variance': page.totalVariance ?? _dash,
      'costPerUnit': _dash,
    },
    roll: roll,
    emptyMessage:
        'No production record matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted record list; [groups] the
/// full sorted group list (used when grouped); [periodRows] the records
/// in the period, for the notes.
ReportExportSpec productionRecordsExportSpec({
  required List<ProductionRecordRow> rows,
  required List<ProductionGroupRow> groups,
  required List<ProductionRecordRow> periodRows,
  required ProductionRecordsTableState state,
  required ProductionRecordsFilterChoices choices,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = state.grouped;
  return ReportExportSpec(
    reportName: 'Production Records',
    fileSlug: 'production_records',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: productionExportFilters(
      filters: state.filters,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      f: f,
    ),
    sortedBy:
        grouped
            ? productionGroupSortLabel(
              state.groupSortField,
              state.groupAscending,
              state.groupBy,
            )
            : productionSortLabel(state.sortField, state.ascending),
    groupedBy: grouped ? state.groupBy.label : null,
    notes: productionRecordsNotes(
      period: period,
      rows: periodRows,
      canSeeCost: canSeeCost,
    ),
    sections: [
      if (grouped)
        productionGroupSection(
          groups: groups,
          groupBy: state.groupBy,
          recordCount: rows.length,
          f: f,
          canSeeCost: canSeeCost,
          canSeeQuantity: canSeeQuantity,
        )
      else
        productionRecordsTableSection(
          rows: rows,
          f: f,
          departmentsEnabled: departmentsEnabled,
          canSeeCost: canSeeCost,
          canSeeQuantity: canSeeQuantity,
          singleOutputKey: state.filters.singleOutputKey,
        ),
    ],
  );
}
