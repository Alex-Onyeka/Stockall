// Export spec of the Purchase Report table, grouping-aware: the purchase
// rows (the full filtered and sorted list, not the page) when Group by
// is off, or the group table the user sees when it is on. Totals are
// the screen's own (PurchaseReportPage / PurchaseGroupPage).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// The notes the Purchase table and Purchase summary show under their
/// toolbar. The views draw these and the export carries them, so they
/// always match.
List<String> purchaseReportNotes({required ReceiptsReportPeriod period}) => [
  if (period.isAllTime) 'All time covers the purchases loaded on this device.',
];

/// The Notes column: the overpaid flag and the custom-total indicator
/// the screen shows as icons with tooltips.
String purchaseRowNote(PurchaseReportRow r, ExportFormatter f) {
  final parts = <String>[
    if (r.overpaid) 'Overpaid by ${f.money(r.overpaidBy)}',
    if (r.hasAdjustment && r.lineTotal != null && r.adjustment != null)
      'Custom total (lines ${f.money(r.lineTotal!)}, '
          '${r.adjustment! > 0 ? '+' : '-'}${f.money(r.adjustment!.abs())})',
  ];
  return parts.isEmpty ? _dash : parts.join('; ');
}

const Map<PurchasesSortField, String> purchaseSortLabels = {
  PurchasesSortField.createdAt: 'Date',
  PurchasesSortField.supplier: 'Supplier',
  PurchasesSortField.staff: 'Staff',
  PurchasesSortField.items: 'Items',
  PurchasesSortField.total: 'Total',
  PurchasesSortField.paid: 'Paid',
  PurchasesSortField.balance: 'Balance',
};

String _dir(bool ascending) => ascending ? 'ascending' : 'descending';

String purchaseSortLabel(PurchasesSortField field, bool ascending) =>
    '${purchaseSortLabels[field] ?? field.name} (${_dir(ascending)})';

String purchaseGroupSortLabel(
  PurchaseGroupSortField field,
  bool ascending,
  PurchaseGroupBy groupBy,
) {
  final label = switch (field) {
    PurchaseGroupSortField.name => groupBy.label,
    PurchaseGroupSortField.count => 'Purchases',
    PurchaseGroupSortField.items => 'Items',
    PurchaseGroupSortField.total => 'Total',
    PurchaseGroupSortField.paid => 'Paid',
    PurchaseGroupSortField.balance => 'Balance',
  };
  return '$label (${_dir(ascending)})';
}

/// The table's filters with their values, worded and ordered like
/// `PurchaseReportFilterChips` (with the search box first).
List<ExportFilter> purchaseExportFilters({
  required PurchaseReportFilters filters,
  required PurchaseFilterChoices choices,
  required bool departmentsEnabled,
  required ExportFormatter f,
}) {
  String range(double? min, double? max) =>
      '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}';
  final out = <ExportFilter>[];
  void key(String title, String? k, List<PurchaseFilterOption> options) {
    if (k == null) return;
    out.add(ExportFilter(title, PurchaseFilterChoices.labelFor(options, k, title)));
  }

  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  key('Supplier', filters.supplierKey, choices.suppliers);
  key('Staff', filters.staffKey, choices.staff);
  if (departmentsEnabled) {
    key('Department', filters.departmentKey, choices.departments);
  }
  key('Channel', filters.channelKey, PurchaseReportOptions.channels());
  if (filters.status != null) out.add(ExportFilter('Status', filters.status!.label));
  if (filters.totalMin != null || filters.totalMax != null) {
    out.add(ExportFilter('Total', range(filters.totalMin, filters.totalMax)));
  }
  if (filters.balanceMin != null || filters.balanceMax != null) {
    out.add(ExportFilter('Balance', range(filters.balanceMin, filters.balanceMax)));
  }
  return out;
}

/// The screen's totals row (PurchaseReportPage) by column id. The
/// Line Total sum (Excel only) is the page's own `totalLineTotal`.
Map<String, Object?> purchaseTotals(
  List<PurchaseReportRow> rows, {
  required ExportFormatter f,
}) {
  final page = PurchaseReportQuery.paginate(rows, 1);
  return {
    'id': '${f.integer(rows.length)} ${rows.length == 1 ? 'purchase' : 'purchases'}',
    'items': page.totalItems,
    'total': page.total,
    'paid': page.totalPaid,
    'balance': page.totalBalance,
    'lineTotal': page.totalLineTotal,
  };
}

ExportTableSection<PurchaseReportRow> purchaseTableSection({
  required List<PurchaseReportRow> rows,
  required ExportFormatter f,
  required bool departmentsEnabled,
}) {
  return ExportTableSection<PurchaseReportRow>(
    title: 'Purchases',
    rows: rows,
    columns: [
      ExportColumn(id: 'id', label: 'ID', value: (r) => r.displayId, width: 1.4),
      ExportColumn(
        id: 'supplier',
        label: 'Supplier',
        value: (r) => r.supplierLabel,
        width: 1.5,
      ),
      ExportColumn(id: 'staff', label: 'Staff', value: (r) => r.staffLabel, width: 1.2),
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
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(id: 'status', label: 'Status', value: (r) => r.status.label),
      ExportColumn(id: 'channel', label: 'Channel', value: (r) => r.channelLabel),
      ExportColumn(
        id: 'lines',
        label: 'Lines',
        format: ExportFormat.integer,
        value: (r) => r.lineCount,
        display: (r) => r.lineCount == null ? _dash : f.integer(r.lineCount!),
        width: 0.6,
      ),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.quantity,
        value: (r) => r.items,
        display: (r) => r.items == null ? _dash : f.quantity(r.items!),
        width: 0.7,
      ),
      ExportColumn(
        id: 'total',
        label: 'Total',
        format: ExportFormat.money,
        value: (r) => r.total,
        width: 1.3,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Paid',
        format: ExportFormat.money,
        value: (r) => r.paid,
        width: 1.3,
      ),
      // Never below 0: an overpaid purchase owes nothing (see Notes).
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (r) => r.balance,
        width: 1.3,
      ),
      ExportColumn(
        id: 'notes',
        label: 'Notes',
        value: (r) => purchaseRowNote(r, f),
        width: 1.8,
      ),
      ExportColumn(
        id: 'lineTotal',
        label: 'Line Total',
        format: ExportFormat.money,
        value: (r) => r.lineTotal,
        display: (r) => r.lineTotal == null ? _dash : f.money(r.lineTotal!),
        inPdf: false,
      ),
    ],
    totalsFor: (rs) => purchaseTotals(rs, f: f),
    splits: [
      supplierSplit<PurchaseReportRow>(
        rows: rows,
        supplierId: (r) => r.supplierKey,
        supplierName: (r) => r.supplierName,
      ),
      staffSplit<PurchaseReportRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
      statusSplit<PurchaseReportRow>(status: (r) => r.status.label),
    ],
    // 58mm: 15 / 16 characters. 80mm: 19 / 13 / 14 after the gaps, so
    // "₦1,250,000.00" fits Paid and Total. The ID and date go on the
    // sub-line on both papers.
    roll: const RollLayout(
      cols58: ['supplier', 'total'],
      cols80: ['supplier', 'paid', 'total'],
      sub58: ['id', 'date'],
      sub80: ['id', 'date'],
      flex58: [1, 1],
      flex80: [20, 14, 14],
    ),
    emptyMessage: 'No purchase matches the selected period and filters.',
  );
}

ExportTableSection<PurchaseGroupRow> purchaseGroupSection({
  required List<PurchaseGroupRow> groups,
  required PurchaseGroupBy groupBy,
  required ExportFormatter f,
}) {
  return ExportTableSection<PurchaseGroupRow>(
    title: 'Purchases by ${groupBy.label}',
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: groupBy.label, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'purchases',
        label: 'Purchases',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.quantity,
        value: (g) => g.items,
        display: (g) => g.items == null ? _dash : f.quantity(g.items!),
        width: 0.8,
      ),
      ExportColumn(
        id: 'total',
        label: 'Total',
        format: ExportFormat.money,
        value: (g) => g.total,
        width: 1.2,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Paid',
        format: ExportFormat.money,
        value: (g) => g.paid,
        width: 1.2,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (g) => g.balance,
        width: 1.2,
      ),
    ],
    // The screen's PurchaseGroupPage totals.
    totalsFor: (gs) {
      final page = PurchaseGrouping.paginate(gs, 1);
      return {
        'name': '${f.integer(gs.length)} ${groupBy.pagerLabel}',
        'purchases': page.totalPurchases,
        'items': page.totalItems ?? _dash,
        'total': page.total,
        'paid': page.totalPaid,
        'balance': page.totalBalance,
      };
    },
    // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
    roll: const RollLayout(
      cols58: ['name', 'total'],
      cols80: ['name', 'purchases', 'total'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No purchase matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted purchase list; [groups] the
/// full sorted group list (used when grouped).
ReportExportSpec purchaseReportExportSpec({
  required List<PurchaseReportRow> rows,
  required List<PurchaseGroupRow> groups,
  required PurchaseReportTableState state,
  required PurchaseFilterChoices choices,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = state.grouped;
  return ReportExportSpec(
    reportName: 'Purchase Report',
    fileSlug: 'purchase_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: purchaseExportFilters(
      filters: state.filters,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      f: f,
    ),
    sortedBy: grouped
        ? purchaseGroupSortLabel(
          state.groupSortField,
          state.groupAscending,
          state.groupBy,
        )
        : purchaseSortLabel(state.sortField, state.ascending),
    groupedBy: grouped ? state.groupBy.label : null,
    notes: purchaseReportNotes(period: period),
    sections: [
      if (grouped)
        purchaseGroupSection(groups: groups, groupBy: state.groupBy, f: f)
      else
        purchaseTableSection(
          rows: rows,
          f: f,
          departmentsEnabled: departmentsEnabled,
        ),
    ],
  );
}
