import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

class _Opened {
  final ProductionHistoryFilters filters;
  final ReceiptsReportPeriod period;

  _Opened(this.filters, this.period);
}

Future<void> pumpSummary(
  WidgetTester tester, {
  required bool isDesktop,
  required ProductionStockEnv env,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StockHistorySummaryView(
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

String cardText(WidgetTester tester, String id) {
  final texts = tester
      .widgetList<Text>(
        find.descendant(of: byKey('summary-kpi-$id'), matching: find.byType(Text)),
      )
      .map((t) => t.data)
      .toList();
  return texts[1]!;
}

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('the movement filter narrows the table, not the cards '
        '($width)', (tester) async {
      await pumpSummary(tester, isDesktop: isDesktop, env: fakeStockEnv());
      expect(cardText(tester, 'moved'), '3');
      expect(byKey('summary-row-juice-base'), findsOneWidget);
      expect(byKey('summary-row-muffin'), findsOneWidget);

      await tester.tap(byKey('summary-movement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outflow Only').last);
      await tester.pumpAndSettle();

      expect(find.text('Movement: Outflow Only'), findsOneWidget);
      expect(byKey('summary-row-juice-base'), findsNothing);
      expect(byKey('summary-row-muffin'), findsNothing);
      expect(byKey('summary-row-donut'), findsOneWidget);
      expect(cardText(tester, 'moved'), '3');
    });

    testWidgets('a row opens the history on its item and period ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: fakeStockEnv(
          openHistory: (_, f, p) async => opened.add(_Opened(f, p)),
        ),
      );
      await tapStart(tester, byKey('summary-row-donut'));
      expect(opened.single.filters.itemKey, 'donut');
      expect(opened.single.period.start, DateTime(2026, 10, 2));
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpSummary(tester, isDesktop: isDesktop, env: fakeStockEnv());
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('the cards: per unit; masked without the permission', (
    tester,
  ) async {
    await pumpSummary(tester, isDesktop: true, env: fakeStockEnv());
    expect(cardText(tester, 'main'), '47.0 Pcs');
    expect(cardText(tester, 'out'), '15.0 Pcs');
    expect(find.text('Muffin (deleted)'), findsOneWidget);
    await pumpSummary(
      tester,
      isDesktop: true,
      env: fakeStockEnv(canSeeQuantity: false),
    );
    expect(cardText(tester, 'main'), '****');
    expect(cardText(tester, 'events'), '6');
  });
}

