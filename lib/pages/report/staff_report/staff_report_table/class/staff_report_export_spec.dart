// Export spec of the Staff Report table: every filtered, sorted staff
// (not just the page), with the screen's column gates (orders,
// purchases, expenses) and its own totals (StaffReportTotals).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

const String _dash = '—';

/// The notes the staff pages (table, analysis, expenses) show under
/// their toolbar. The views draw these and the exports carry them, so
/// they always match.
List<String> staffReportNotes({required ReceiptsReportPeriod period}) => [
  if (period.isAllTime) 'All time covers the data loaded on this device.',
];

ExportPeriod staffExportPeriod(ReceiptsReportPeriod period) => ExportPeriod(
  label: receiptsPeriodLabel(period),
  start: period.start,
  end: period.end,
);

/// The Name cell: the "Former staff" badge as text.
String staffNameText(StaffReportRow r) =>
    r.isFormer ? '${r.name} ($staffReportFormerRoleLabel)' : r.name;

const Map<StaffReportSortField, String> staffSortLabels = {
  StaffReportSortField.name: 'Name',
  StaffReportSortField.role: 'Role',
  StaffReportSortField.phone: 'Phone',
  StaffReportSortField.receiptSales: 'Receipt Sales',
  StaffReportSortField.invoiceSales: 'Invoice Sales',
  StaffReportSortField.orderCount: 'Orders',
  StaffReportSortField.orderTotal: 'Order Value',
  StaffReportSortField.purchaseCount: 'Purchases',
  StaffReportSortField.purchaseTotal: 'Purchase Value',
  StaffReportSortField.expenseCount: 'Expenses',
  StaffReportSortField.expenseTotal: 'Expense Value',
  StaffReportSortField.lastActivity: 'Last Activity',
};

/// The sort the table actually uses (a hidden column falls back to
/// name), with its direction.
String staffSortLabel(
  StaffReportSortField field,
  bool ascending,
  StaffReportAccess access,
) {
  final used = StaffReportQuery.visibleSort(field, access);
  return '${staffSortLabels[used] ?? used.name} '
      '(${ascending ? 'ascending' : 'descending'})';
}

/// The screen's totals row (StaffReportTotals) by column id.
Map<String, Object?> staffTotals(
  List<StaffReportRow> rows, {
  required StaffReportAccess access,
  required ExportFormatter f,
}) {
  final t = StaffReportQuery.paginate(rows, 1).totals;
  return {
    'name': '${f.integer(t.count)} staff',
    'receipts': t.receiptCount,
    'receiptSales': t.receiptSales,
    'invoiceSales': t.invoiceSales,
    if (access.showOrders) ...{'orderCount': t.orderCount, 'orderTotal': t.orderTotal},
    if (access.showPurchases) ...{
      'purchaseCount': t.purchaseCount,
      'purchaseTotal': t.purchaseTotal,
    },
    if (access.showExpenses) ...{
      'expenseCount': t.expenseCount,
      'expenseTotal': t.expenseTotal,
    },
  };
}

ExportTableSection<StaffReportRow> staffTableSection({
  required List<StaffReportRow> rows,
  required StaffReportAccess access,
  required ExportFormatter f,
}) {
  ExportColumn<StaffReportRow> money(
    String id,
    String label,
    double Function(StaffReportRow) v,
  ) => ExportColumn(
    id: id,
    label: label,
    format: ExportFormat.money,
    value: v,
    width: 1.2,
  );
  ExportColumn<StaffReportRow> count(
    String id,
    String label,
    int Function(StaffReportRow) v,
  ) => ExportColumn(
    id: id,
    label: label,
    format: ExportFormat.integer,
    value: v,
    width: 0.8,
  );

  return ExportTableSection<StaffReportRow>(
    title: 'Staff',
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: 'Name', value: staffNameText, width: 1.8),
      // Former staff have no role: the name says it.
      ExportColumn(
        id: 'role',
        label: 'Role',
        value: (r) => r.isFormer ? _dash : r.roleLabel,
        width: 1.1,
      ),
      ExportColumn(id: 'phone', label: 'Phone', value: (r) => r.phone ?? _dash, width: 1.2),
      // Roll only: the screen has no Receipts column.
      ExportColumn(
        id: 'receipts',
        label: 'Receipts',
        format: ExportFormat.integer,
        value: (r) => r.receiptCount,
        inPdf: false,
        inExcel: false,
      ),
      money('receiptSales', 'Receipt Sales', (r) => r.receiptSales),
      money('invoiceSales', 'Invoice Sales', (r) => r.invoiceSales),
      if (access.showOrders) ...[
        count('orderCount', 'Orders', (r) => r.orderCount),
        money('orderTotal', 'Order Value', (r) => r.orderTotal),
      ],
      if (access.showPurchases) ...[
        count('purchaseCount', 'Purchases', (r) => r.purchaseCount),
        money('purchaseTotal', 'Purchase Value', (r) => r.purchaseTotal),
      ],
      if (access.showExpenses) ...[
        count('expenseCount', 'Expenses', (r) => r.expenseCount),
        money('expenseTotal', 'Expense Value', (r) => r.expenseTotal),
      ],
      ExportColumn(
        id: 'lastActivity',
        label: 'Last Activity',
        format: ExportFormat.date,
        value: (r) => r.lastActivity,
        display: (r) => r.lastActivity == null ? _dash : f.date(r.lastActivity!),
      ),
    ],
    totalsFor: (rs) => staffTotals(rs, access: access, f: f),
    // By role: "Former staff" is its own sheet; staff without a role
    // go to "No Role", last.
    splits: [
      fieldSplit<StaffReportRow>(
        id: 'role',
        label: 'Role',
        noneLabel: 'No Role',
        rows: rows,
        key: (r) => r.roleKey == staffReportNoRoleKey ? null : r.roleKey,
        name: (r) => r.roleLabel,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 25 / 7 / 14, so "₦1,250,000.00"
    // stays on one line.
    roll: const RollLayout(
      cols58: ['name', 'receiptSales'],
      cols80: ['name', 'receipts', 'receiptSales'],
      flex58: [1, 1],
      flex80: [26, 8, 14],
    ),
    emptyMessage: 'No staff matches your search and filters.',
  );
}

/// [rows] is the full filtered and sorted list; [roleOptions] the
/// table's role choices.
ReportExportSpec staffReportExportSpec({
  required List<StaffReportRow> rows,
  required StaffReportFilters filters,
  required List<StaffReportFilterOption> roleOptions,
  required StaffReportSortField sortField,
  required bool ascending,
  required StaffReportAccess access,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final search = filters.search.trim();
  final role = filters.roleKey;
  return ReportExportSpec(
    reportName: 'Staff Report',
    fileSlug: 'staff_report',
    period: staffExportPeriod(period),
    filters: [
      if (search.isNotEmpty) ExportFilter('Search', search),
      if (role != null)
        ExportFilter('Role', [
          for (final o in roleOptions)
            if (o.key == role) o.label,
        ].firstOrNull ?? role),
    ],
    sortedBy: staffSortLabel(sortField, ascending, access),
    notes: staffReportNotes(period: period),
    sections: [staffTableSection(rows: rows, access: access, f: f)],
  );
}
