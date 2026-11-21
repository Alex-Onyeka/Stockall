import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_export_spec.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_filter_widgets.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/components/expenses_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'expenses_report_fixtures.dart';
import 'item_history_export_fixtures.dart' show testCtx;

const allTime = ReceiptsReportPeriod.allTime();

ReportExportSpec specFor({
  List<ExpensesReportRow>? base,
  ExpensesReportTableState? state,
  ReceiptsReportPeriod period = allTime,
  bool departmentsEnabled = false,
}) {
  final rowsBase = base ?? sampleRows();
  final s = state ?? ExpensesReportTableState();
  final rows = ExpensesReportQuery.filterAndSort(
    rows: rowsBase,
    period: period,
    filters: s.filters,
    sortField: s.sortField,
    ascending: s.ascending,
    departmentsEnabled: departmentsEnabled,
    includeStockPurchases: s.includeStockPurchases,
    closingTime: midnight,
  );
  final groups = ExpensesGrouping.sort(
    ExpensesGrouping.build(rows, s.groupBy),
    field: s.groupSortField,
    ascending: s.groupAscending,
  );
  return expensesReportExportSpec(
    rows: rows,
    groups: groups,
    state: s,
    choices: ExpensesFilterChoices.fromRows(
      rowsBase,
      categories: sampleCategories,
    ),
    period: period,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
  );
}

ResolvedTable tableTitled(ReportExportSpec spec, String title) =>
    resolveExport(spec, testCtx).tables.firstWhere((t) => t.title == title);

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  group('sections', () {
    test('Expenses, then Sub-Expense Lines', () {
      expect(specFor().sections.map((s) => s.title), [
        'Expenses',
        'Sub-Expense Lines',
      ]);
    });

    test('no lines table without sub-expenses', () {
      final spec = specFor(
        base: buildRows([exp(uuid: 'a'), exp(uuid: 'b')]),
      );
      expect(spec.sections.map((s) => s.title), ['Expenses']);
    });

    test('grouped: the group table, then the lines', () {
      final spec = specFor(
        state: ExpensesReportTableState(groupBy: ExpensesGroupBy.category),
      );
      expect(spec.sections.map((s) => s.title), [
        'Expenses by Category',
        'Sub-Expense Lines',
      ]);
      expect(spec.groupedBy, 'Category');
      expect(spec.sortedBy, 'Amount (descending)');
      final t = tableTitled(spec, 'Expenses by Category');
      expect(col(t, 'name').first, 'Stock Purchase');
      expect(t.rows.first[t.indexOf('stockPurchase')].raw, 5000);
      expect(t.totals![t.indexOf('amount')].raw, 4070);
      expect(t.totals![t.indexOf('stockPurchase')].raw, 5000);
      expect(t.totals![t.indexOf('expenses')].raw, 7);
    });
  });

  group('expenses table', () {
    test('every filtered row in the screen order, not just a page', () {
      final base = buildRows([
        for (var i = 0; i < 150; i++)
          exp(
            uuid: 'e-$i',
            amount: 1.0 + i,
            createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
          ),
      ]);
      final t = tableTitled(specFor(base: base), 'Expenses');
      expect(t.rows, hasLength(150));
      expect(t.rows.first[t.indexOf('amount')].raw, 150);
    });

    test('PDF columns; Department only with departments on', () {
      List<String> pdf(ReportExportSpec s) => [
        for (final c in tableTitled(s, 'Expenses').columns)
          if (c.inPdf) c.label,
      ];
      expect(pdf(specFor()), [
        'Date',
        'Time',
        'Name',
        'Category',
        'Description',
        'Quantity',
        'Staff',
        'Staff Paid',
        'Channel',
        'Lines',
        'Amount',
        'Notes',
      ]);
      expect(pdf(specFor(departmentsEnabled: true)), contains('Department'));
    });

    test('categories, staff paid, channel and notes', () {
      final t = tableTitled(specFor(), 'Expenses');
      Map<String, String> rowOf(String name) {
        final r = t.rows.firstWhere((r) => r[t.indexOf('name')].text == name);
        return {for (final c in t.columns) c.id: r[t.indexOf(c.id)].text};
      }

      expect(rowOf('Staff party')['category'], 'Welfare');
      expect(rowOf('Staff party')['lines'], '2');
      expect(rowOf('Gift')['category'], 'Gifts');
      expect(rowOf('Gift')['lines'], '—');
      expect(rowOf('Salary - Ada')['paidStaff'], 'Ada Obi');
      expect(rowOf('Salary - Ada')['channel'], 'GTBank (1234)');
      expect(rowOf('Fuel')['quantity'], '20 litres');
      final stock = rowOf('Stock Purchase (Acme)');
      expect(stock['notes'], 'Stock purchase payment, not in Total Expenses');
      expect(stock['inTotal'], 'No');
      expect(rowOf('Fuel')['inTotal'], 'Yes');
    });

    test('totals are the screen\'s: stock purchases apart', () {
      final t = tableTitled(specFor(), 'Expenses');
      expect(t.totals![t.indexOf('name')].text, '6 expenses (+1 stock purchase)');
      expect(t.totals![t.indexOf('amount')].raw, 4070);
      expect(t.totals![t.indexOf('lines')].raw, 4);
    });

    test('splits: category, staff, channel, then department', () {
      expect(specFor().splitOptions.map((s) => s.id), [
        'category',
        'staff',
        'channel',
      ]);
      expect(
        specFor(departmentsEnabled: true).splitOptions.map((s) => s.id),
        ['category', 'staff', 'channel', 'department'],
      );
      final groups = resolveGroups(
        specFor().tables.first,
        'category',
        ExportFormatter(currency: '₦'),
      );
      final stock = groups.firstWhere((g) => g.name == 'Stock Purchase');
      // A Stock Purchase sheet lists them but totals nothing.
      expect(stock.table.rows, hasLength(1));
      expect(stock.table.totals![stock.table.indexOf('amount')].raw, 0);
    });
  });

  group('sub-expense lines', () {
    test('one row per line with its expense; total of the lines', () {
      final t = tableTitled(specFor(), 'Sub-Expense Lines');
      expect(col(t, 'expense'), [
        'Staff party',
        'Staff party',
        'NEPA Bill',
        'NEPA Bill',
      ]);
      expect(col(t, 'line'), ['transportation', 'Drinks', 'Transportation', 'Token']);
      expect(col(t, 'category'), [
        'Welfare',
        'Welfare',
        'Simple Expenses',
        'Simple Expenses',
      ]);
      expect(col(t, 'channel').last, 'gtbank (1234)');
      expect(t.totals![t.indexOf('amount')].raw, 1200);
      expect(t.totals![t.indexOf('expense')].text, '4 lines');
    });

    test('follow the filters', () {
      final t = tableTitled(
        specFor(
          state: ExpensesReportTableState(
            filters: ExpensesReportFilters(staffKey: 'staff-b'),
          ),
        ),
        'Sub-Expense Lines',
      );
      expect(col(t, 'expense').toSet(), {'Staff party'});
    });
  });

  group('info box and notes', () {
    test('filters, the stock option and sort', () {
      final spec = specFor(
        state: ExpensesReportTableState(
          filters: ExpensesReportFilters(
            search: 'fu',
            categoryKey: ExpenseType.simpleExpense,
            hasLines: false,
            amountMax: 500,
          ),
          includeStockPurchases: false,
          sortField: ExpensesSortField.amount,
        ),
      );
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: fu',
        'Category: Simple Expenses',
        'Sub-expenses: Without',
        'Amount: Any - ₦500.00',
        'Stock purchases: Hidden',
      ]);
      expect(spec.sortedBy, 'Amount (descending)');
    });

    test('the screen\'s notes', () {
      expect(specFor().notes, [
        'All time covers the expenses loaded on this device.',
        'Stock purchase payments (1): ₦5,000.00, shown but not counted in '
            'Total Expenses (they are counted under purchases).',
      ]);
      expect(
        specFor(
          period: ReceiptsReportPeriod.day(DateTime(2026, 10, 18)),
        ).notes,
        isEmpty,
      );
    });
  });

  group('roll', () {
    String preview(RollPaper paper) =>
        renderRollEscPos(
          buildRollLines(specFor(), testCtx, paper: paper),
          paper,
        ).preview;

    test('58mm fits, and the sub-expenses print under their expense', () {
      final out = preview(RollPaper.mm58).split('\n');
      expect(
        out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots),
        isTrue,
      );
      final text = out.join(' ');
      expect(text, contains('Token'));
      expect(text, contains('Drinks'));
    });

    test('80mm fits', () {
      final out = preview(RollPaper.mm80).split('\n');
      expect(
        out.every((l) => l.length <= RollPaper.mm80.dots ~/ fontBDots),
        isTrue,
      );
    });
  });

  group('Excel', () {
    test('a sheet per category', () {
      final wb = resolveWorkbook(specFor(), testCtx, splitId: 'category');
      expect(wb.sheets.map((s) => s.name), containsAll(['Welfare', 'Gifts']));
    });
  });

  group('screens show the Export pill', () {
    Widget app(Widget home) => ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(home: home),
    );

    for (final desktop in [true, false]) {
      final width = desktop ? 'desktop' : 'mobile';
      testWidgets('table ($width)', (tester) async {
        tester.view.physicalSize =
            desktop ? const Size(1800, 1000) : const Size(500, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          app(
            ExpensesReportTableView(
              isDesktop: desktop,
              initialPeriod: allTime,
              env: sampleEnv(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (!desktop) {
          await tester.tap(find.text('View'));
          await tester.pumpAndSettle();
        }
        expect(find.text('Export'), findsOneWidget);
      });

      testWidgets('analysis ($width)', (tester) async {
        tester.view.physicalSize =
            desktop ? const Size(1800, 1000) : const Size(500, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          app(
            ExpensesSummaryView(
              isDesktop: desktop,
              initialPeriod: allTime,
              env: sampleEnv(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
