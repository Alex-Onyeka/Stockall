import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_analysis_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

class _Opened {
  final ProductionStockFilters filters;
  final ReceiptsReportPeriod period;

  _Opened(this.filters, this.period);
}

Future<void> pumpAnalysis(
  WidgetTester tester, {
  required bool isDesktop,
  required ProductionStockEnv env,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1400) : const Size(500, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StockAnalysisView(
          key: UniqueKey(),
          isDesktop: isDesktop,
          kind: ProductionStockKind.producedItem,
          initialPeriod: day2,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapStart(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getTopLeft(finder) + const Offset(16, 16));
  await tester.pumpAndSettle();
}

Finder byKey(String key) => find.byKey(ValueKey(key));

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    ProductionStockEnv env(List<_Opened> opened, {bool departments = true}) =>
        fakeStockEnv(
          departmentsEnabled: departments,
          openTable: (_, f, p) async => opened.add(_Opened(f, p)),
        );

    void expectDay2(ReceiptsReportPeriod p) {
      expect(p.start, DateTime(2026, 10, 2));
      expect(p.end, DateTime(2026, 10, 2));
    }

    testWidgets('a ranking row opens the table on its item ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpAnalysis(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('analysis-row-produced-donut'));
      expect(opened.single.filters.itemKey, 'donut');
      expect(opened.single.filters.activeCount, 1);
      expectDay2(opened.single.period);
    });

    testWidgets('department and category rows, none included ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpAnalysis(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('analysis-tab-departments'));
      await tapStart(tester, byKey('analysis-row-departments-$deptKitchen'));
      expect(opened.last.filters.departmentKey, deptKitchen);
      await tapStart(tester, byKey('analysis-tab-categories'));
      await tapStart(
        tester,
        byKey('analysis-row-categories-$productionReportNoneKey'),
      );
      expect(opened.last.filters.categoryKey, productionReportNoneKey);
      expectDay2(opened.last.period);
    });

    testWidgets('a card opens the table unfiltered ($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpAnalysis(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('analysis-kpi-items'));
      expect(opened.single.filters.activeCount, 0);
      expectDay2(opened.single.period);
    });

    testWidgets('Departments only with departments on ($width)', (tester) async {
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        env: env([], departments: false),
      );
      expect(byKey('analysis-tab-departments'), findsNothing);
      expect(byKey('analysis-tab-categories'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpAnalysis(tester, isDesktop: isDesktop, env: env([]));
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('the cards: counts, change, the approximate rate', (tester) async {
    await pumpAnalysis(tester, isDesktop: true, env: fakeStockEnv());
    expect(find.text('Produced Items'), findsOneWidget);
    expect(find.text('35.0 Pcs'), findsOneWidget);
    expect(find.textContaining('vs previous period'), findsWidgets);
    expect(find.text('Transfer-to-Sales Rate (approx.)'), findsOneWidget);
    expect(find.textContaining('approximate'), findsOneWidget);
  });

  testWidgets('without the quantity permission: masked, no rankings', (
    tester,
  ) async {
    await pumpAnalysis(
      tester,
      isDesktop: true,
      env: fakeStockEnv(canSeeQuantity: false),
    );
    expect(find.text('****'), findsWidgets);
    expect(byKey('analysis-tab-produced'), findsNothing);
    expect(byKey('analysis-tab-categories'), findsOneWidget);
  });
}
