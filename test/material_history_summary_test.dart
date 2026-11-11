import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'materials_widgets_kit.dart';
import 'production_report_fixtures.dart';

Widget page(bool isDesktop, ProductionStockEnv env) => StockHistorySummaryView(
  key: UniqueKey(),
  isDesktop: isDesktop,
  kind: ProductionStockKind.material,
  initialPeriod: ReceiptsReportPeriod.day(materialsDay2),
  env: env,
);

String cardText(WidgetTester tester, String id) => tester
    .widgetList<Text>(
      find.descendant(of: byKey('summary-kpi-$id'), matching: find.byType(Text)),
    )
    .map((t) => t.data)
    .toList()[1]!;

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('the movement filter narrows the table, not the cards '
        '($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, fakeStockEnv(kind: ProductionStockKind.material)),
        mobileHeight: 1200,
      );
      expect(cardText(tester, 'moved'), '2');
      expect(byKey('summary-row-yeast'), findsOneWidget);
      await tester.tap(byKey('summary-movement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outflow Only').last);
      await tester.pumpAndSettle();
      expect(byKey('summary-row-yeast'), findsNothing);
      expect(byKey('summary-row-sugar'), findsOneWidget);
      expect(cardText(tester, 'moved'), '2');
    });

    testWidgets('a row opens the Materials history on its material '
        '($width)', (tester) async {
      final opened = <(ProductionHistoryFilters, ReceiptsReportPeriod)>[];
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(
          isDesktop,
          fakeStockEnv(
            kind: ProductionStockKind.material,
            openHistory: (_, f, p) async => opened.add((f, p)),
          ),
        ),
        mobileHeight: 1200,
      );
      await tapStart(tester, byKey('summary-row-sugar'));
      expect(opened.single.$1.itemKey, 'sugar');
      expect(opened.single.$2.start, materialsDay2);
    });

    testWidgets('the note and the Export pill ($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, fakeStockEnv(kind: ProductionStockKind.material)),
        mobileHeight: 1200,
      );
      expect(find.text('Export'), findsOneWidget);
      expect(
        find.textContaining("can't tell production use from manual use"),
        findsOneWidget,
      );
    });
  }
}
