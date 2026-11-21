import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'expenses_report_fixtures.dart';

Future<void> pumpTable(
  WidgetTester tester, {
  required bool isDesktop,
  required ExpensesReportEnv env,
  ExpensesReportFilters? filters,
  ReceiptsReportPeriod? period = const ReceiptsReportPeriod.allTime(),
  bool? includeStockPurchases,
}) async {
  // As the purchase table test: mobile is below mobileScreen (650),
  // so the toolbar sits behind "View".
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: ExpensesReportTableView(
          isDesktop: isDesktop,
          initialFilters: filters,
          initialPeriod: period,
          initialIncludeStockPurchases: includeStockPurchases,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (!isDesktop) {
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}

Finder stockNote() => find.textContaining('Stock purchase payments (1)');

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('one row per expense; Total Expenses without stock ($width)', (
      tester,
    ) async {
      await pumpTable(tester, isDesktop: isDesktop, env: sampleEnv());
      for (final name in [
        'Fuel',
        'Salary - Ada',
        'Salary - Bayo',
        'Stock Purchase (Acme)',
        'NEPA Bill',
        'Staff party',
        'Gift',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('N4070.0'), findsOneWidget);
      expect(stockNote(), findsOneWidget);
      expect(find.textContaining('All time covers'), findsOneWidget);
      // Category, staff paid and channel cells.
      expect(find.text('Welfare'), findsOneWidget);
      expect(find.text('Ada Obi'), findsOneWidget);
      expect(find.text('GTBank (1234)'), findsOneWidget);
      expect(find.text('Split'), findsOneWidget);
    });

    testWidgets('Include stock purchases off hides them ($width)', (
      tester,
    ) async {
      await pumpTable(tester, isDesktop: isDesktop, env: sampleEnv());
      await tester.tap(find.text('Include stock purchases'));
      await tester.pumpAndSettle();
      expect(find.text('Stock Purchase (Acme)'), findsNothing);
      expect(stockNote(), findsNothing);
      expect(find.text('N4070.0'), findsOneWidget);
    });

    testWidgets('sub-expense lines expand under their expense ($width)', (
      tester,
    ) async {
      await pumpTable(tester, isDesktop: isDesktop, env: sampleEnv());
      expect(find.text('2 sub-expenses'), findsNWidgets(2));
      expect(find.text('↳ Token'), findsNothing);

      await tester.tap(find.byTooltip('Show sub-expenses').first);
      await tester.pumpAndSettle();
      expect(find.text('↳ Drinks'), findsOneWidget);
      expect(find.text('↳ Token'), findsNothing);
      // Lines never change the total.
      expect(find.text('N4070.0'), findsOneWidget);

      await tester.tap(find.text('Expand all'));
      await tester.pumpAndSettle();
      expect(find.text('↳ Token'), findsOneWidget);
      expect(find.text('↳ Transportation'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('↳ Token')).dy,
        greaterThan(tester.getTopLeft(find.text('NEPA Bill')).dy),
      );

      await tester.tap(find.text('Collapse all'));
      await tester.pumpAndSettle();
      expect(find.text('↳ Token'), findsNothing);
      expect(find.text('↳ Drinks'), findsNothing);
    });

    testWidgets('an analysis handoff opens on exactly its set ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(),
        filters: ExpensesReportFilters(staffKey: 'staff-a'),
        includeStockPurchases: false,
      );
      expect(find.text('Staff: Ada'), findsOneWidget);
      expect(find.text('Fuel'), findsOneWidget);
      expect(find.text('NEPA Bill'), findsOneWidget);
      expect(find.text('Stock Purchase (Acme)'), findsNothing);
      expect(find.text('Gift'), findsNothing);
      expect(find.text('N1300.0'), findsOneWidget);
    });

    testWidgets('Reset All keeps Group by and the stock option ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(),
        filters: ExpensesReportFilters(categoryKey: 'custom:c-welfare'),
        includeStockPurchases: false,
      );
      expect(find.text('Category: Welfare'), findsOneWidget);
      await tester.tap(find.text('Group by'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PopupMenuItem<ExpensesGroupBy>),
          matching: find.text('Category'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Group by: Category'), findsOneWidget);

      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Category: Welfare'), findsNothing);
      expect(find.text('Group by: Category'), findsOneWidget);
      expect(find.text('Date: All time'), findsOneWidget);
      // Stock purchases still hidden: no Stock Purchase group.
      expect(find.text('Stock Purchase'), findsNothing);
      expect(find.text('Staff Salary'), findsOneWidget);
      expect(find.text('N4070.0'), findsOneWidget);
    });

    testWidgets('a row opens the expense ($width)', (tester) async {
      final opened = <TempExpensesClass>[];
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(opened: opened),
      );
      await tester.tap(find.text('Gift'));
      await tester.pumpAndSettle();
      expect(opened.map((e) => e.uuid), ['e-gift']);
    });

    testWidgets('without View Date the period is today ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: sampleEnv(scope: access(canPickDate: false)),
        period: null,
      );
      expect(find.textContaining('Date: Today'), findsOneWidget);
      expect(find.byTooltip('You can only view today'), findsOneWidget);
      // The sample is in October 2026, before today.
      expect(find.text('Empty List'), findsOneWidget);
    });
  }

  testWidgets('grouped by category: stock purchase marked, not in total', (
    tester,
  ) async {
    await pumpTable(tester, isDesktop: true, env: sampleEnv());
    await tester.tap(find.text('Group by'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(PopupMenuItem<ExpensesGroupBy>),
        matching: find.text('Category'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stock Purchase'), findsOneWidget);
    expect(find.text('N5000.0'), findsOneWidget);
    expect(
      find.byTooltip(
        'Includes N5000.0 of stock purchases, not counted in Total Expenses',
      ),
      findsOneWidget,
    );
    expect(find.text('N4070.0'), findsOneWidget);
  });

  testWidgets('no department column by default', (tester) async {
    await pumpTable(tester, isDesktop: true, env: sampleEnv());
    expect(find.text('Department'), findsNothing);
  });

  testWidgets('department column with departments', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: sampleEnv(scope: access(departmentsEnabled: true)),
    );
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Bar'), findsOneWidget);
  });

  testWidgets('search finds an expense by a sub-expense name', (tester) async {
    await pumpTable(tester, isDesktop: true, env: sampleEnv());
    await tester.enterText(find.byType(TextField), 'drinks');
    await tester.pumpAndSettle();
    expect(find.text('Staff party'), findsOneWidget);
    expect(find.text('NEPA Bill'), findsNothing);
    expect(find.text('N200.0'), findsNWidgets(2));
  });
}
