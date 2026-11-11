import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_items_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

Future<void> pumpItems(
  WidgetTester tester, {
  required bool isDesktop,
  required ProductionStockEnv env,
  ProductionStockFilters? filters,
  ReceiptsReportPeriod? period,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StockItemsView(
          key: UniqueKey(),
          isDesktop: isDesktop,
          kind: ProductionStockKind.producedItem,
          initialFilters: filters,
          initialPeriod: period ?? const ReceiptsReportPeriod.allTime(),
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

/// Taps near the leading edge: rows are wider than a phone screen.
Future<void> tapStart(WidgetTester tester, Finder finder) async {
  await tester.tapAt(tester.getTopLeft(finder) + const Offset(16, 16));
  await tester.pumpAndSettle();
}

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('an item hand-off, then Reset All keeps the sort and period '
        '($width)', (tester) async {
      await pumpItems(
        tester,
        isDesktop: isDesktop,
        env: fakeStockEnv(),
        filters: ProductionStockFilters(itemKey: 'donut'),
      );
      expect(find.text('Produced Item: Donut'), findsOneWidget);
      expect(byKey('stock-row-donut'), findsOneWidget);
      expect(byKey('stock-row-cake'), findsNothing);

      // Stock, largest first.
      await tester.tap(find.text('Stock').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Produced Item: Donut'), findsNothing);
      expect(find.text('Date: All time'), findsOneWidget);
      expect(byKey('stock-row-cake'), findsOneWidget);
      expect(
        tester.getTopLeft(byKey('stock-row-donut')).dy,
        lessThan(tester.getTopLeft(byKey('stock-row-cake')).dy),
      );
    });

    testWidgets('a row opens the item; back rebuilds ($width)', (tester) async {
      final items = sampleProducedItems();
      final opened = <String>[];
      await pumpItems(
        tester,
        isDesktop: isDesktop,
        env: fakeStockEnv(
          items: items,
          openedItems: opened,
          // Deleted on the item's page.
          onOpenItem: (uuid) => items.removeWhere((i) => i.uuid == uuid),
        ),
      );
      await tapStart(tester, byKey('stock-row-cake'));
      expect(opened, ['cake']);
      expect(byKey('stock-row-cake'), findsNothing);
      expect(byKey('stock-row-donut'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpItems(tester, isDesktop: isDesktop, env: fakeStockEnv());
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('totals: items and stock value', (tester) async {
    await pumpItems(tester, isDesktop: true, env: fakeStockEnv());
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    // The donuts' value is the only one: the cake has none left.
    expect(find.text('N3000.0'), findsNWidgets(2));
  });

  testWidgets('quantities show **** without the permission', (tester) async {
    await pumpItems(
      tester,
      isDesktop: true,
      env: fakeStockEnv(canSeeQuantity: false),
    );
    expect(find.text('15 Pcs'), findsNothing);
    expect(find.text('****'), findsWidgets);
    expect(find.text('Stock'), findsOneWidget);
  });

  testWidgets('cost columns need the cost permission', (tester) async {
    await pumpItems(tester, isDesktop: true, env: fakeStockEnv(canSeeCost: false));
    expect(find.text('Cost Price'), findsNothing);
    expect(find.text('Stock Value'), findsNothing);
  });

  testWidgets('the movement of the period needs history access', (tester) async {
    await pumpItems(tester, isDesktop: true, env: fakeStockEnv(), period: day2);
    expect(find.text('Opening'), findsOneWidget);
    expect(find.text('Produced'), findsOneWidget);
    await pumpItems(
      tester,
      isDesktop: true,
      env: fakeStockEnv(historyAllowed: false),
      period: day2,
    );
    expect(find.text('Opening'), findsNothing);
    expect(
      find.textContaining('Period movement needs access to item history.'),
      findsOneWidget,
    );
  });

  testWidgets('the department column only with departments on', (tester) async {
    await pumpItems(
      tester,
      isDesktop: true,
      env: fakeStockEnv(departmentsEnabled: true),
    );
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
  });
}
