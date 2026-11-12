import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

Future<void> pumpHistory(
  WidgetTester tester, {
  required bool isDesktop,
  required ProductionStockEnv env,
  ProductionHistoryFilters? filters,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StockHistoryView(
          key: UniqueKey(),
          isDesktop: isDesktop,
          kind: ProductionStockKind.producedItem,
          initialFilters: filters,
          initialPeriod: day2,
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

Finder byKey(String key) => find.byKey(ValueKey(key));

Future<void> tapStart(WidgetTester tester, Finder finder) async {
  await tester.tapAt(tester.getTopLeft(finder) + const Offset(16, 16));
  await tester.pumpAndSettle();
}

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('an item hand-off, then Reset All keeps the period ($width)', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        isDesktop: isDesktop,
        env: fakeStockEnv(),
        filters: ProductionHistoryFilters(itemKey: 'cake'),
      );
      expect(find.text('Produced Item: Cake'), findsOneWidget);
      expect(byKey('history-row-ch-1'), findsOneWidget);
      expect(byKey('history-row-ph-1'), findsNothing);

      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Produced Item: Cake'), findsNothing);
      expect(byKey('history-row-ph-1'), findsOneWidget);
      expect(find.text('Date: Oct 2, 2026'), findsOneWidget);
    });

    testWidgets('a row opens its item; a deleted item opens nothing ($width)', (
      tester,
    ) async {
      final opened = <String>[];
      await pumpHistory(
        tester,
        isDesktop: isDesktop,
        env: fakeStockEnv(openedItems: opened),
      );
      await tapStart(tester, byKey('history-row-ph-2'));
      expect(opened, ['donut']);
      await tapStart(tester, byKey('history-row-mh-gone'));
      expect(opened, ['donut']);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpHistory(tester, isDesktop: isDesktop, env: fakeStockEnv());
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('the change and the balance; masked without the permission', (
    tester,
  ) async {
    await pumpHistory(tester, isDesktop: true, env: fakeStockEnv());
    expect(find.text('-15.0 Pcs'), findsOneWidget);
    expect(find.text('30.0 → 15.0'), findsOneWidget);
    expect(find.text('6 records'), findsOneWidget);
    await pumpHistory(
      tester,
      isDesktop: true,
      env: fakeStockEnv(canSeeQuantity: false),
    );
    expect(find.text('-15.0 Pcs'), findsNothing);
    expect(find.text('****'), findsWidgets);
  });
}
