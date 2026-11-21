import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_export_spec.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'expenses_report_fixtures.dart';
import 'item_history_export_fixtures.dart' show testCtx;

const allTime = ReceiptsReportPeriod.allTime();

const tabsNoDepartments = [
  ExpensesBreakdownTab.category,
  ExpensesBreakdownTab.salary,
  ExpensesBreakdownTab.staff,
  ExpensesBreakdownTab.channel,
];

ReportExportSpec specFor({
  ReceiptsReportPeriod period = allTime,
  List<ExpensesBreakdownTab> tabs = tabsNoDepartments,
  ExpensesBreakdownTab activeTab = ExpensesBreakdownTab.category,
  ExpensesBreakdownSortField? sortField,
  bool ascending = false,
}) {
  final result = ExpensesSummaryBuilder.build(
    rows: sampleRows(),
    period: period,
    departmentsEnabled: tabs.contains(ExpensesBreakdownTab.department),
    closingTime: midnight,
    now: day(20),
  );
  return expensesSummaryExportSpec(
    result: result,
    period: period,
    tabs: tabs,
    activeTab: activeTab,
    sortField: sortField,
    ascending: ascending,
    currency: '₦',
  );
}

ResolvedTable tableTitled(ReportExportSpec spec, String title) =>
    resolveExport(spec, testCtx).tables.firstWhere((t) => t.title == title);

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  test('sections: statistics, top lists, one table per tab', () {
    expect(specFor().sections.map((s) => s.title), [
      'Statistics',
      'Top Expenses',
      'Top Sub-expenses',
      'Breakdown by Category',
      'Breakdown by Staff Salary',
      'Breakdown by Created by',
      'Breakdown by Channel',
    ]);
    expect(
      specFor(
        tabs: [...tabsNoDepartments, ExpensesBreakdownTab.department],
      ).sections.last.title,
      'Breakdown by Departments',
    );
  });

  test('statistics are the KPI cards; stock purchases apart', () {
    final s = resolveExport(specFor(), testCtx).sections.first as ResolvedSummary;
    final byLabel = {for (final m in s.metrics) m.label: m.raw};
    expect(byLabel['Total Expenses'], 4070);
    expect(byLabel['Number of Expenses'], 6);
    expect(byLabel['Largest Expense'], 1500);
    expect(byLabel['Staff Salaries'], 2500);
    expect(byLabel['With Sub-expenses'], 2);
    expect(byLabel['Categories Used'], 4);
    expect(byLabel['Stock Purchase Payments'], 5000);
  });

  test('category breakdown: stock purchase last, no share, not in total', () {
    final t = tableTitled(specFor(), 'Breakdown by Category');
    expect(col(t, 'name'), [
      'Staff Salary',
      'Simple Expenses',
      'Welfare',
      'Gifts',
      'Stock Purchase (not in total)',
    ]);
    expect(col(t, 'share').last, '—');
    expect(t.totals![t.indexOf('amount')].raw, 4070);
    expect(t.totals![t.indexOf('expenses')].raw, 6);
  });

  test('the active tab keeps the screen sort, the others their order', () {
    final spec = specFor(
      activeTab: ExpensesBreakdownTab.staff,
      sortField: ExpensesBreakdownSortField.name,
      ascending: true,
    );
    expect(col(tableTitled(spec, 'Breakdown by Created by'), 'name'), [
      'Ada',
      'Bayo',
      'Owner',
    ]);
    expect(col(tableTitled(spec, 'Breakdown by Category'), 'name').first, 'Staff Salary');
  });

  test('top expenses and top sub-expenses', () {
    final spec = specFor();
    expect(col(tableTitled(spec, 'Top Expenses'), 'name'), [
      'Salary - Ada',
      'Salary - Bayo',
      'NEPA Bill',
      'Fuel',
      'Staff party',
    ]);
    final lines = tableTitled(spec, 'Top Sub-expenses');
    expect(col(lines, 'name'), ['Token', 'transportation', 'Drinks']);
    expect(col(lines, 'expenses')[1], '2');
  });

  test('notes match the screen', () {
    expect(specFor().notes, hasLength(2));
    expect(
      specFor(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 18))).notes,
      isEmpty,
    );
  });

  test('the roll fits 58mm and 80mm', () {
    for (final paper in [RollPaper.mm58, RollPaper.mm80]) {
      final out =
          renderRollEscPos(
            buildRollLines(specFor(), testCtx, paper: paper),
            paper,
          ).preview.split('\n');
      expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
