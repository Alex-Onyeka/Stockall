// Export spec of the Expenses Summary page: its statistic cards, the
// top expenses and top sub-expenses, and the breakdown tables
// (category, staff salary, created by, channel, departments). Charts
// aren't exported. Every input is the screen's own ExpensesSummaryResult.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_export_spec.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const String _dash = '—';

ExportTableSection<ExpensesReportRow> _topExpenses(
  List<ExpensesReportRow> rows,
  ExportFormatter f,
) {
  final no = Map<ExpensesReportRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    no[rows[i]] = i + 1;
  }
  return ExportTableSection<ExpensesReportRow>(
    title: 'Top Expenses',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (r) => no[r],
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: 'Expense', value: (r) => r.name, width: 2),
      ExportColumn(
        id: 'category',
        label: 'Category',
        value: (r) => r.categoryLabel,
        width: 1.3,
      ),
      ExportColumn(
        id: 'date',
        label: 'Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.date(r.createdAt!),
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (r) => r.amount,
        width: 1.2,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'amount'],
      cols80: ['no', 'name', 'amount'],
      sub58: ['category'],
      sub80: ['category'],
      flex58: [1, 1],
      flex80: [2, 20, 14],
    ),
    emptyMessage: 'No expenses in this period.',
  );
}

ExportTableSection<ExpensesLineSummary> _topLines(
  List<ExpensesLineSummary> lines,
) {
  final no = Map<ExpensesLineSummary, int>.identity();
  for (var i = 0; i < lines.length; i++) {
    no[lines[i]] = i + 1;
  }
  return ExportTableSection<ExpensesLineSummary>(
    title: 'Top Sub-expenses',
    rows: lines,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (l) => no[l],
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: 'Sub-expense', value: (l) => l.label, width: 2),
      ExportColumn(
        id: 'lines',
        label: 'Lines',
        format: ExportFormat.integer,
        value: (l) => l.lineCount,
        width: 0.7,
      ),
      ExportColumn(
        id: 'expenses',
        label: 'Expenses',
        format: ExportFormat.integer,
        value: (l) => l.expenseCount,
        width: 0.8,
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (l) => l.amount,
        width: 1.2,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'amount'],
      cols80: ['name', 'lines', 'amount'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No sub-expenses in this period.',
  );
}

ExportTableSection<ExpensesBreakdownRow> _breakdown(
  ExpensesBreakdownTab tab,
  List<ExpensesBreakdownRow> rows,
  ExportFormatter f,
) {
  final counted = rows.where((r) => !r.excluded).toList();
  return ExportTableSection<ExpensesBreakdownRow>(
    title: 'Breakdown by ${tab.label}',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'name',
        label: tab.label,
        value: (r) => r.excluded ? '${r.label} (not in total)' : r.label,
        width: 2,
      ),
      ExportColumn(
        id: 'expenses',
        label: 'Expenses',
        format: ExportFormat.integer,
        value: (r) => r.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (r) => r.amount,
        width: 1.2,
      ),
      ExportColumn(
        id: 'average',
        label: 'Average',
        format: ExportFormat.money,
        value: (r) => r.average,
        width: 1.2,
      ),
      ExportColumn(
        id: 'lastDate',
        label: 'Last Expense',
        format: ExportFormat.date,
        value: (r) => r.lastDate,
        display: (r) => r.lastDate == null ? _dash : f.date(r.lastDate!),
      ),
      ExportColumn(
        id: 'share',
        label: 'Share',
        format: ExportFormat.percent,
        value: (r) => r.share,
        display: (r) => r.share == null ? _dash : f.percent(r.share!),
        width: 0.8,
      ),
    ],
    // The screen has no totals row here; the total leaves out the
    // excluded (Stock Purchase) row, as Total Expenses.
    totals: {
      'name': 'TOTAL',
      'expenses': counted.fold<int>(0, (s, r) => s + r.count),
      'amount': counted.fold<double>(0, (s, r) => s + r.amount),
    },
    roll: const RollLayout(
      cols58: ['name', 'amount'],
      cols80: ['name', 'expenses', 'amount'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage:
        tab == ExpensesBreakdownTab.salary
            ? 'No staff salary in this period.'
            : 'No expenses in this period.',
  );
}

/// [tabs] are the tabs the screen shows; the [activeTab] keeps the
/// screen's sort, the others their built order.
ReportExportSpec expensesSummaryExportSpec({
  required ExpensesSummaryResult result,
  required ReceiptsReportPeriod period,
  required List<ExpensesBreakdownTab> tabs,
  required ExpensesBreakdownTab activeTab,
  required ExpensesBreakdownSortField? sortField,
  required bool ascending,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final s = result.stats;

  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );

  return ReportExportSpec(
    reportName: 'Expenses Summary',
    fileSlug: 'expenses_summary',
    period: expensesExportPeriod(period),
    notes: expensesReportNotes(
      period: period,
      totals: ExpensesReportTotals.of(result.rows),
      money: f.money,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          ExportMetric(
            label: 'Total Expenses',
            value: s.totalExpenses,
            note: 'Without stock purchases',
          ),
          count('Number of Expenses', s.expenseCount, note: 'Recorded in this period'),
          ExportMetric(
            label: 'Average per Expense',
            value: s.average,
            note: 'Total / number of expenses',
          ),
          ExportMetric(
            label: 'Largest Expense',
            value: s.largest?.amount ?? 0,
            note: s.largest?.name ?? 'No expense',
          ),
          ExportMetric(
            label: 'Staff Salaries',
            value: s.salaryTotal,
            note:
                '${s.salaryCount} payment${s.salaryCount == 1 ? '' : 's'}'
                ' · ${s.staffPaidCount} staff',
          ),
          count(
            'With Sub-expenses',
            s.withLinesCount,
            note: '${s.lineCount} line${s.lineCount == 1 ? '' : 's'}',
          ),
          count('Categories Used', s.categoriesUsed, note: 'With an expense in this period'),
          ExportMetric(
            label: 'Stock Purchase Payments',
            value: s.stockPurchaseTotal,
            note: 'Not in Total Expenses',
          ),
        ],
      ),
      _topExpenses(result.topExpenses, f),
      _topLines(result.topLines),
      for (final tab in tabs)
        _breakdown(
          tab,
          ExpensesSummaryBuilder.sortBreakdown(
            result.breakdown(tab),
            field: tab == activeTab ? sortField : null,
            ascending: ascending,
          ),
          f,
        ),
    ],
  );
}
