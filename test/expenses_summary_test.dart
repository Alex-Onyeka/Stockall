import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/components/expenses_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'expenses_report_fixtures.dart';

Future<void> pumpSummary(
  WidgetTester tester, {
  required bool isDesktop,
  required ExpensesReportEnv env,
  ReceiptsReportPeriod? period = const ReceiptsReportPeriod.allTime(),
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1200) : const Size(500, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: ExpensesSummaryView(
          isDesktop: isDesktop,
          initialPeriod: period,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

String kpiValue(WidgetTester tester, String id) {
  final texts = tester.widgetList<Text>(
    find.descendant(
      of: find.byKey(ValueKey('expenses-kpi-$id')),
      matching: find.byType(Text),
    ),
  );
  // Title, then value.
  return texts.elementAt(1).data!;
}

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('KPIs leave stock purchases out of the total ($width)', (
      tester,
    ) async {
      await pumpSummary(tester, isDesktop: isDesktop, env: sampleEnv());
      expect(kpiValue(tester, 'total'), 'N4070.0');
      expect(kpiValue(tester, 'count'), '6');
      expect(kpiValue(tester, 'largest'), 'N1500.0');
      expect(kpiValue(tester, 'salary'), 'N2500.0');
      expect(kpiValue(tester, 'lines'), '2');
      expect(kpiValue(tester, 'categories'), '4');
      expect(kpiValue(tester, 'stock'), 'N5000.0');
      expect(
        find.textContaining('Stock purchase payments (1)'),
        findsOneWidget,
      );
      expect(find.text('Expenses Trend'), findsOneWidget);
    });

    testWidgets('category breakdown: stock purchase last, not shared ($width)', (
      tester,
    ) async {
      await pumpSummary(tester, isDesktop: isDesktop, env: sampleEnv());
      final salary = find.byKey(
        const ValueKey('expenses-row-category-staff_salary'),
      );
      final stock = find.byKey(
        const ValueKey('expenses-row-category-stock_purchase'),
      );
      expect(
        find.descendant(of: stock, matching: find.text('Not in Total Expenses')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: stock, matching: find.text('—')),
        findsOneWidget,
      );
      expect(salary, findsOneWidget);
      expect(
        tester.getTopLeft(stock).dy,
        greaterThan(tester.getTopLeft(salary).dy),
      );
    });

    testWidgets('a breakdown row hands off its filters ($width)', (
      tester,
    ) async {
      final opened = <(ExpensesTableHandoff, ReceiptsReportPeriod)>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(openedTables: opened),
      );
      await tapKey(tester, 'expenses-tab-salary');
      await tapKey(tester, 'expenses-row-salary-staff-b');
      expect(opened.length, 1);
      final (handoff, period) = opened.single;
      expect(handoff.filters.categoryKey, ExpenseType.staffSalary);
      expect(handoff.filters.paidStaffKey, 'staff-b');
      expect(handoff.includeStockPurchases, isFalse);
      expect(period.isAllTime, isTrue);
    });

    testWidgets('KPIs and top sub-expenses open the table ($width)', (
      tester,
    ) async {
      final opened = <(ExpensesTableHandoff, ReceiptsReportPeriod)>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(openedTables: opened),
      );
      await tapKey(tester, 'expenses-kpi-stock');
      expect(opened.last.$1.filters.categoryKey, ExpenseType.stockPurchase);
      await tapKey(tester, 'expenses-kpi-lines');
      expect(opened.last.$1.filters.hasLines, isTrue);
      await tapKey(tester, 'expenses-line-token');
      expect(opened.last.$1.filters.search, 'Token');
    });

    testWidgets('a top expense opens the expense ($width)', (tester) async {
      final opened = <TempExpensesClass>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(opened: opened),
      );
      await tapKey(tester, 'expenses-top-e-salary-ada');
      expect(opened.map((e) => e.uuid), ['e-salary-ada']);
    });

    testWidgets('without View Date the period is today ($width)', (
      tester,
    ) async {
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(scope: access(canPickDate: false)),
        period: null,
      );
      expect(find.textContaining('Date: Today'), findsOneWidget);
      expect(kpiValue(tester, 'total'), 'N0.0');
      expect(find.text('No expenses in this period.'), findsWidgets);
    });
  }

  testWidgets('the handoff opens the table on exactly the row', (
    tester,
  ) async {
    final opened = <(ExpensesTableHandoff, ReceiptsReportPeriod)>[];
    await pumpSummary(
      tester,
      isDesktop: true,
      env: sampleEnv(openedTables: opened),
    );
    await tapKey(tester, 'expenses-tab-staff');
    await tapKey(tester, 'expenses-row-staff-staff-a');
    final (handoff, period) = opened.single;

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: ExpensesReportTableView(
            isDesktop: true,
            initialFilters: handoff.filters,
            initialPeriod: period,
            initialIncludeStockPurchases: handoff.includeStockPurchases,
            env: sampleEnv(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fuel'), findsOneWidget);
    expect(find.text('NEPA Bill'), findsOneWidget);
    expect(find.text('Stock Purchase (Acme)'), findsNothing);
    expect(find.text('N1300.0'), findsOneWidget);
  });

  testWidgets('Departments tab only with departments', (tester) async {
    await pumpSummary(tester, isDesktop: true, env: sampleEnv());
    expect(find.byKey(const ValueKey('expenses-tab-department')), findsNothing);
  });

  testWidgets('Departments tab with departments', (tester) async {
    await pumpSummary(
      tester,
      isDesktop: true,
      env: sampleEnv(scope: access(departmentsEnabled: true)),
    );
    await tapKey(tester, 'expenses-tab-department');
    expect(find.text('Bar'), findsOneWidget);
  });
}
