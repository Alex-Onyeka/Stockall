// Export spec of the Expenses Report table, grouping-aware: the expense
// rows (the full filtered and sorted list, not the page) when Group by
// is off, or the group table the user sees when it is on. Either way a
// "Sub-Expense Lines" table follows, one row per line of the exported
// expenses, so the breakdown is never lost. Totals are the screen's own
// (ExpensesReportTotals): Stock Purchase expenses are listed but not in
// Total Expenses.

import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

ExportPeriod expensesExportPeriod(ReceiptsReportPeriod period) => ExportPeriod(
  label: receiptsPeriodLabel(period),
  start: period.start,
  end: period.end,
);

const Map<ExpensesSortField, String> expensesSortLabels = {
  ExpensesSortField.createdAt: 'Date',
  ExpensesSortField.name: 'Name',
  ExpensesSortField.category: 'Category',
  ExpensesSortField.staff: 'Staff',
  ExpensesSortField.paidStaff: 'Staff Paid',
  ExpensesSortField.channel: 'Channel',
  ExpensesSortField.department: 'Department',
  ExpensesSortField.lines: 'Lines',
  ExpensesSortField.amount: 'Amount',
};

String _dir(bool ascending) => ascending ? 'ascending' : 'descending';

String expensesSortLabel(ExpensesSortField field, bool ascending) =>
    '${expensesSortLabels[field] ?? field.name} (${_dir(ascending)})';

String expensesGroupSortLabel(
  ExpensesGroupSortField field,
  bool ascending,
  ExpensesGroupBy groupBy,
) {
  final label = switch (field) {
    ExpensesGroupSortField.name => groupBy.label,
    ExpensesGroupSortField.count => 'Expenses',
    ExpensesGroupSortField.amount => 'Amount',
    ExpensesGroupSortField.lastDate => 'Last Expense',
  };
  return '$label (${_dir(ascending)})';
}

/// The table's filters with their values, worded and ordered like
/// `ExpensesReportFilterChips` (with the search box first), then the
/// stock purchase option when it is off.
List<ExportFilter> expensesExportFilters({
  required ExpensesReportTableState state,
  required ExpensesFilterChoices choices,
  required bool departmentsEnabled,
  required ExportFormatter f,
}) {
  final filters = state.filters;
  final out = <ExportFilter>[];
  void key(String title, String? k, List<ExpensesFilterOption> options) {
    if (k == null) return;
    out.add(ExportFilter(title, ExpensesFilterChoices.labelFor(options, k, title)));
  }

  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  key('Category', filters.categoryKey, choices.categories);
  key('Staff', filters.staffKey, choices.staff);
  key('Staff Paid', filters.paidStaffKey, choices.paidStaff);
  key('Channel', filters.channelKey, choices.channels);
  if (departmentsEnabled) {
    key('Department', filters.departmentKey, choices.departments);
  }
  if (filters.hasLines != null) {
    out.add(ExportFilter('Sub-expenses', filters.hasLines! ? 'With' : 'Without'));
  }
  if (filters.amountMin != null || filters.amountMax != null) {
    final min = filters.amountMin;
    final max = filters.amountMax;
    out.add(
      ExportFilter(
        'Amount',
        '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}',
      ),
    );
  }
  if (!state.includeStockPurchases) {
    out.add(const ExportFilter('Stock purchases', 'Hidden'));
  }
  return out;
}

String _countLabel(ExportFormatter f, ExpensesReportTotals t) {
  final base = '${f.integer(t.countedCount)} '
      '${t.countedCount == 1 ? 'expense' : 'expenses'}';
  if (t.stockPurchaseCount == 0) return base;
  return '$base (+${f.integer(t.stockPurchaseCount)} stock purchase'
      '${t.stockPurchaseCount == 1 ? '' : 's'})';
}

/// The screen's totals row (ExpensesReportTotals) by column id.
Map<String, Object?> expensesTotals(
  List<ExpensesReportRow> rows, {
  required ExportFormatter f,
}) {
  final t = ExpensesReportTotals.of(rows);
  return {
    'name': _countLabel(f, t),
    'lines': t.lineCount,
    'amount': t.total,
    'stockPurchase': t.stockPurchaseTotal,
  };
}

ExportTableSection<ExpensesReportRow> expensesTableSection({
  required List<ExpensesReportRow> rows,
  required ExportFormatter f,
  required bool departmentsEnabled,
}) {
  return ExportTableSection<ExpensesReportRow>(
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
      ExportColumn(id: 'name', label: 'Name', value: (r) => r.name, width: 1.6),
      ExportColumn(
        id: 'category',
        label: 'Category',
        value: (r) => r.categoryLabel,
        width: 1.3,
      ),
      ExportColumn(
        id: 'description',
        label: 'Description',
        value: (r) => r.description ?? _dash,
        width: 1.6,
      ),
      ExportColumn(
        id: 'quantity',
        label: 'Quantity',
        format: ExportFormat.quantity,
        value: (r) => r.quantity,
        display: (r) => r.quantityLabel ?? _dash,
        width: 0.9,
      ),
      ExportColumn(id: 'staff', label: 'Staff', value: (r) => r.staffLabel, width: 1.2),
      ExportColumn(
        id: 'paidStaff',
        label: 'Staff Paid',
        value: (r) => r.paidStaffLabel,
        width: 1.2,
      ),
      ExportColumn(id: 'channel', label: 'Channel', value: (r) => r.channelLabel),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'lines',
        label: 'Lines',
        format: ExportFormat.integer,
        value: (r) => r.hasLines ? r.lineCount : null,
        display: (r) => r.hasLines ? f.integer(r.lineCount) : _dash,
        width: 0.6,
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (r) => r.amount,
        width: 1.3,
      ),
      ExportColumn(
        id: 'notes',
        label: 'Notes',
        value: (r) => expensesRowNote(r, f),
        width: 1.6,
      ),
      // Excel only: lets a sheet be summed the screen's way.
      ExportColumn(
        id: 'inTotal',
        label: 'In Total Expenses',
        value: (r) => r.countsInTotal ? 'Yes' : 'No',
        inPdf: false,
      ),
      // Roll only: the breakdown under each expense.
      ExportColumn(
        id: 'breakdown',
        label: 'Sub-expenses',
        value: (r) => expensesLinesText(r, f),
        inPdf: false,
        inExcel: false,
      ),
    ],
    totalsFor: (rs) => expensesTotals(rs, f: f),
    splits: [
      fieldSplit<ExpensesReportRow>(
        id: 'category',
        label: 'Category',
        noneLabel: 'No Category',
        rows: rows,
        key: (r) => r.categoryKey,
        name: (r) => r.categoryLabel,
      ),
      staffSplit<ExpensesReportRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
      channelSplit<ExpensesReportRow>(channel: (r) => r.channelLabel),
      if (departmentsEnabled)
        fieldSplit<ExpensesReportRow>(
          id: 'department',
          label: 'Department',
          noneLabel: expensesNoDepartmentLabel,
          rows: rows,
          key: (r) => r.departmentKey,
          name: (r) => r.departmentName,
        ),
    ],
    // 58mm: 15 / 16 characters. 80mm: 19 / 13 / 14. Category and date on
    // the sub-line, then the sub-expenses.
    roll: const RollLayout(
      cols58: ['name', 'amount'],
      cols80: ['name', 'category', 'amount'],
      sub58: ['category', 'date', 'breakdown'],
      sub80: ['date', 'breakdown'],
      flex58: [1, 1],
      flex80: [20, 13, 14],
    ),
    emptyMessage: 'No expense matches the selected period and filters.',
  );
}

/// The Notes cell: the stock purchase rule and a breakdown that no
/// longer adds up, which the screen shows as icons.
String expensesRowNote(ExpensesReportRow r, ExportFormatter f) {
  final parts = <String>[
    if (r.isStockPurchase) 'Stock purchase payment, not in Total Expenses',
    if (r.linesMismatch)
      'Sub-expenses add up to ${f.money(r.expense.subExpensesTotal)}',
  ];
  return parts.isEmpty ? _dash : parts.join('; ');
}

/// "Transport 200.00; Token 800.00" for the roll's sub-line.
String expensesLinesText(ExpensesReportRow r, ExportFormatter f) {
  if (!r.hasLines) return '';
  return r.lines
      .map((l) => '${l.name.trim()} ${f.money(l.amount)}')
      .join('; ');
}

ExportTableSection<ExpensesGroupRow> expensesGroupSection({
  required List<ExpensesGroupRow> groups,
  required List<ExpensesReportRow> rows,
  required ExpensesGroupBy groupBy,
  required ExportFormatter f,
}) {
  return ExportTableSection<ExpensesGroupRow>(
    title: 'Expenses by ${groupBy.label}',
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: groupBy.label, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'expenses',
        label: 'Expenses',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'lines',
        label: 'Lines',
        format: ExportFormat.integer,
        value: (g) => g.lineCount,
        width: 0.7,
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (g) => g.amount,
        width: 1.3,
      ),
      ExportColumn(
        id: 'stockPurchase',
        label: 'Of which Stock Purchases',
        format: ExportFormat.money,
        value: (g) => g.stockPurchaseAmount,
        width: 1.3,
      ),
      ExportColumn(
        id: 'lastDate',
        label: 'Last Expense',
        format: ExportFormat.date,
        value: (g) => g.lastDate,
        display: (g) => g.lastDate == null ? _dash : f.date(g.lastDate!),
      ),
    ],
    // The screen's ExpensesGroupPage totals: every grouped expense.
    totals: {
      ...expensesTotals(rows, f: f),
      'name': '${f.integer(groups.length)} ${groupBy.pagerLabel}',
      'expenses': ExpensesReportTotals.of(rows).count,
    },
    roll: const RollLayout(
      cols58: ['name', 'amount'],
      cols80: ['name', 'expenses', 'amount'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No expense matches the selected period and filters.',
  );
}

/// One sub-expense line with its expense.
class ExpensesLineExportRow {
  final ExpensesReportRow expense;
  final SubExpense line;

  const ExpensesLineExportRow(this.expense, this.line);
}

/// One row per line of [rows], in [rows]' order.
List<ExpensesLineExportRow> expensesLineRows(List<ExpensesReportRow> rows) => [
  for (final r in rows)
    for (final l in r.lines) ExpensesLineExportRow(r, l),
];

ExportTableSection<ExpensesLineExportRow> expensesLinesSection({
  required List<ExpensesLineExportRow> lines,
  required ExportFormatter f,
}) {
  return ExportTableSection<ExpensesLineExportRow>(
    title: 'Sub-Expense Lines',
    rows: lines,
    columns: [
      ExportColumn(
        id: 'date',
        label: 'Date',
        format: ExportFormat.date,
        value: (l) => l.expense.createdAt,
        display:
            (l) =>
                l.expense.createdAt == null
                    ? _dash
                    : f.date(l.expense.createdAt!),
      ),
      ExportColumn(
        id: 'expense',
        label: 'Expense',
        value: (l) => l.expense.name,
        width: 1.5,
      ),
      ExportColumn(
        id: 'category',
        label: 'Category',
        value: (l) => l.expense.categoryLabel,
        width: 1.2,
      ),
      ExportColumn(
        id: 'line',
        label: 'Sub-expense',
        value: (l) => l.line.name.trim().isEmpty ? 'Not Set' : l.line.name.trim(),
        width: 1.5,
      ),
      ExportColumn(
        id: 'description',
        label: 'Description',
        value:
            (l) =>
                (l.line.description?.trim().isNotEmpty ?? false)
                    ? l.line.description!.trim()
                    : _dash,
        width: 1.5,
      ),
      ExportColumn(
        id: 'quantity',
        label: 'Quantity',
        format: ExportFormat.quantity,
        value: (l) => l.line.quantity,
        display:
            (l) => expenseQuantityLabel(l.line.quantity, l.line.unit) ?? _dash,
        width: 0.9,
      ),
      ExportColumn(
        id: 'channel',
        label: 'Channel',
        value: (l) => l.line.paymentChannel,
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (l) => l.line.amount,
        width: 1.2,
      ),
    ],
    totalsFor:
        (ls) => {
          'expense': '${f.integer(ls.length)} line${ls.length == 1 ? '' : 's'}',
          'amount': ls.fold<double>(0, (s, l) => s + l.line.amount),
        },
    roll: const RollLayout(
      cols58: ['line', 'amount'],
      cols80: ['line', 'channel', 'amount'],
      sub58: ['expense'],
      sub80: ['expense'],
      flex58: [1, 1],
      flex80: [20, 13, 14],
    ),
    emptyMessage: 'No sub-expenses.',
  );
}

/// [rows] is the full filtered and sorted expense list; [groups] the
/// full sorted group list (used when grouped).
ReportExportSpec expensesReportExportSpec({
  required List<ExpensesReportRow> rows,
  required List<ExpensesGroupRow> groups,
  required ExpensesReportTableState state,
  required ExpensesFilterChoices choices,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = state.grouped;
  final lines = expensesLineRows(rows);
  return ReportExportSpec(
    reportName: 'Expenses Report',
    fileSlug: 'expenses_report',
    period: expensesExportPeriod(period),
    filters: expensesExportFilters(
      state: state,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      f: f,
    ),
    sortedBy:
        grouped
            ? expensesGroupSortLabel(
              state.groupSortField,
              state.groupAscending,
              state.groupBy,
            )
            : expensesSortLabel(state.sortField, state.ascending),
    groupedBy: grouped ? state.groupBy.label : null,
    notes: expensesReportNotes(
      period: period,
      totals: ExpensesReportTotals.of(rows),
      money: f.money,
    ),
    sections: [
      if (grouped)
        expensesGroupSection(
          groups: groups,
          rows: rows,
          groupBy: state.groupBy,
          f: f,
        )
      else
        expensesTableSection(
          rows: rows,
          f: f,
          departmentsEnabled: departmentsEnabled,
        ),
      if (lines.isNotEmpty) expensesLinesSection(lines: lines, f: f),
    ],
  );
}
