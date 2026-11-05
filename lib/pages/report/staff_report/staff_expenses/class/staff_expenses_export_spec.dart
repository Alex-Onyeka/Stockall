// Export spec of one staff's Expenses table: every filtered, sorted
// expense (not just the page), with the screen's totals
// (StaffExpensesTotals).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

const String _dash = '—';

/// The Quantity cell: "2 Bags", "1.5", or null when not set. The view
/// and the export both use it.
String? staffExpenseQuantityLabel(StaffExpenseRow r) {
  final q = r.quantity;
  if (q == null) return null;
  final n = q == q.roundToDouble() ? q.toStringAsFixed(0) : '$q';
  final unit = r.unit;
  return unit == null ? n : '$n $unit';
}

const Map<StaffExpensesSortField, String> staffExpensesSortLabels = {
  StaffExpensesSortField.createdAt: 'Date',
  StaffExpensesSortField.title: 'Name',
  StaffExpensesSortField.description: 'Description',
  StaffExpensesSortField.quantity: 'Quantity',
  StaffExpensesSortField.amount: 'Amount',
  StaffExpensesSortField.department: 'Department',
};

/// The screen's totals row (StaffExpensesTotals) by column id.
Map<String, Object?> staffExpensesTotals(
  List<StaffExpenseRow> rows, {
  required ExportFormatter f,
}) {
  final t = StaffExpensesTable.paginate(rows, 1).totals;
  return {
    'title': '${f.integer(t.count)} expense${t.count == 1 ? '' : 's'}',
    'amount': t.amount,
  };
}

ExportTableSection<StaffExpenseRow> staffExpensesSection({
  required List<StaffExpenseRow> rows,
  required bool departmentsEnabled,
  required ExportFormatter f,
}) {
  return ExportTableSection<StaffExpenseRow>(
    title: 'Expenses',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'date',
        label: 'Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.date(r.createdAt!),
      ),
      ExportColumn(
        id: 'time',
        label: 'Time',
        format: ExportFormat.time,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.time(r.createdAt!),
        width: 0.8,
      ),
      ExportColumn(id: 'title', label: 'Name', value: (r) => r.title, width: 1.5),
      ExportColumn(
        id: 'description',
        label: 'Description',
        value: (r) => r.description ?? _dash,
        width: 2,
      ),
      ExportColumn(
        id: 'quantity',
        label: 'Quantity',
        format: ExportFormat.quantity,
        value: (r) => r.quantity,
        display: (r) => staffExpenseQuantityLabel(r) ?? _dash,
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (r) => r.amount,
        width: 1.2,
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentName ?? _dash,
          width: 1.3,
        ),
    ],
    totalsFor: (rs) => staffExpensesTotals(rs, f: f),
    splits: [
      if (departmentsEnabled)
        fieldSplit<StaffExpenseRow>(
          id: 'department',
          label: 'Department',
          noneLabel: 'No Department',
          rows: rows,
          key: (r) => r.departmentKey,
          name: (r) => r.departmentName,
        ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 15 / 17 / 14, so "₦1,250,000.00"
    // stays on one line; the date goes underneath.
    roll: const RollLayout(
      cols58: ['title', 'amount'],
      cols80: ['title', 'description', 'amount'],
      sub58: ['date'],
      sub80: ['date'],
      flex58: [1, 1],
      flex80: [16, 18, 14],
    ),
    emptyMessage: 'No expenses in this period.',
  );
}

/// [rows] is the full filtered and sorted list of [staffName]'s
/// expenses.
ReportExportSpec staffExpensesExportSpec({
  required String staffName,
  required List<StaffExpenseRow> rows,
  required StaffExpensesFilters filters,
  required StaffExpensesSortField sortField,
  required bool ascending,
  required bool departmentsEnabled,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final search = filters.search.trim();
  final min = filters.amountMin;
  final max = filters.amountMax;
  return ReportExportSpec(
    reportName: 'Staff Expenses',
    fileSlug: 'staff_expenses',
    period: staffExportPeriod(period),
    filters: [
      ExportFilter('Staff', staffName),
      if (search.isNotEmpty) ExportFilter('Search', search),
      if (min != null || max != null)
        ExportFilter(
          'Amount',
          '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}',
        ),
    ],
    sortedBy: '${staffExpensesSortLabels[sortField] ?? sortField.name} '
        '(${ascending ? 'ascending' : 'descending'})',
    notes: staffReportNotes(period: period),
    sections: [
      staffExpensesSection(rows: rows, departmentsEnabled: departmentsEnabled, f: f),
    ],
  );
}
