// Export spec of the stock history table (I3 / M3): the full filtered
// and sorted records, with the screen's columns and masking. Splits:
// Category (the item's), Department and Staff.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _masked = '****';

const Map<ProductionHistorySortField, String> _sortLabels = {
  ProductionHistorySortField.date: 'Date',
  ProductionHistorySortField.item: 'Item',
  ProductionHistorySortField.event: 'Event',
  ProductionHistorySortField.change: 'Change',
  ProductionHistorySortField.staff: 'Staff',
  ProductionHistorySortField.department: 'Department',
};

String productionHistorySortLabel(ProductionHistorySortField f, bool asc) =>
    '${_sortLabels[f]} (${asc ? 'ascending' : 'descending'})';

ExportTableSection<ProductionHistoryRow> productionHistorySection({
  required ProductionStockKind kind,
  required List<ProductionHistoryRow> rows,
  required Map<String, String> categoryNames,
  required ExportFormatter f,
  required bool departmentsEnabled,
  required bool canSeeQuantity,
}) {
  final departmentNames = <String, String>{
    for (final r in rows)
      if (r.departmentKey != null) r.departmentKey!: r.departmentLabel,
  };
  String change(ProductionHistoryRow r) =>
      canSeeQuantity ? productionHistoryChangeText(r, f.quantity) : _masked;
  return ExportTableSection<ProductionHistoryRow>(
    title: '${kind.singular} History',
    rows: rows,
    columns: [
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
      ExportColumn(id: 'item', label: kind.singular, value: (r) => r.itemName, width: 1.8),
      ExportColumn(id: 'event', label: 'Event', value: (r) => r.eventLabel, width: 1.5),
      ExportColumn(
        id: 'title',
        label: 'Title',
        value: (r) => r.entry.title,
        inPdf: false,
      ),
      ExportColumn<ProductionHistoryRow>(
        id: 'change',
        label: 'Change',
        format: ExportFormat.quantity,
        value: (r) => canSeeQuantity ? r.primaryChange : null,
        display: change,
        width: 1.6,
      ),
      ExportColumn(
        id: 'unit',
        label: 'Primary Unit',
        value: (r) => r.primaryUnit,
        inPdf: false,
      ),
      ExportColumn<ProductionHistoryRow>(
        id: 'balance',
        label: 'Old → New',
        value:
            (r) =>
                canSeeQuantity
                    ? productionHistoryBalanceText(r, f.quantity)
                    : _masked,
        width: 1.3,
      ),
      ExportColumn(id: 'source', label: 'Source', value: (r) => r.sourceLabel),
      ExportColumn(
        id: 'destination',
        label: 'Destination',
        value: (r) => r.destinationLabel,
      ),
      ExportColumn(id: 'staff', label: 'Staff', value: (r) => r.staffLabel, width: 1.2),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'description',
        label: 'Description',
        value: (r) => r.entry.desc ?? '',
        inPdf: false,
      ),
      ExportColumn(
        id: 'managed',
        label: 'Managed',
        value: (r) => r.isManaged ? 'Yes' : 'No',
        inPdf: false,
      ),
      // Roll only: the change, short.
      ExportColumn<ProductionHistoryRow>(
        id: 'changeRoll',
        label: 'Change',
        value: change,
        inPdf: false,
        inExcel: false,
      ),
    ],
    totals: {
      'date': '${f.integer(rows.length)} ${rows.length == 1 ? 'record' : 'records'}',
    },
    totalsFor:
        (rs) => {
          'date': '${f.integer(rs.length)} ${rs.length == 1 ? 'record' : 'records'}',
        },
    splits: [
      categorySplit<ProductionHistoryRow>(
        categoryIds: (r) => r.categoryKeys,
        names: categoryNames,
      ),
      if (departmentsEnabled)
        departmentSplit<ProductionHistoryRow>(
          departmentId: (r) => r.departmentKey,
          names: departmentNames,
        ),
      staffSplit<ProductionHistoryRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
    ],
    // 58mm: item · change, date and time underneath (the event names
    // are too long for 32 characters). 80mm: the event on the line
    // too. "+3 Box (36 Pcs)" fits 18 characters.
    roll: const RollLayout(
      cols58: ['item', 'changeRoll'],
      cols80: ['item', 'event', 'changeRoll'],
      sub58: ['date', 'time'],
      sub80: ['date', 'time'],
      flex58: [1, 1],
      flex80: [16, 14, 18],
    ),
    emptyMessage: 'No history record matches the selected period and filters.',
  );
}

ReportExportSpec productionHistoryExportSpec({
  required ProductionStockKind kind,
  required List<ProductionHistoryRow> rows,
  required ProductionHistoryTableState state,
  required ProductionHistoryFilterChoices choices,
  required Map<String, String> categoryNames,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
  required bool canSeeQuantity,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: '${kind.singular} History',
    fileSlug: '${kind.slug}_history',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: [
      for (final (label, value, _) in productionHistoryFilterEntries(
        kind: kind,
        filters: state.filters,
        choices: choices,
        departmentsEnabled: departmentsEnabled,
      ))
        ExportFilter(label, value),
    ],
    sortedBy: productionHistorySortLabel(state.sortField, state.ascending),
    notes: productionStockNotes(
      kind: kind,
      page: ProductionStockReportPage.history,
      period: period,
      historyAllowed: true,
      notNormalised: productionHistoryNotNormalised(rows),
    ),
    sections: [
      productionHistorySection(
        kind: kind,
        rows: rows,
        categoryNames: categoryNames,
        f: f,
        departmentsEnabled: departmentsEnabled,
        canSeeQuantity: canSeeQuantity,
      ),
    ],
  );
}

/// Records that couldn't be converted, over [rows]; the screen's note
/// uses the same count.
int productionHistoryNotNormalised(List<ProductionHistoryRow> rows) => rows
    .where((r) => r.entry.movement.isQuantityEvent && r.primaryChange == null)
    .length;
