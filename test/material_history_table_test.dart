import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'materials_widgets_kit.dart';
import 'production_report_fixtures.dart';

Widget page(bool isDesktop, ProductionStockEnv env, {ProductionHistoryFilters? filters}) =>
    StockHistoryView(
      key: UniqueKey(),
      isDesktop: isDesktop,
      kind: ProductionStockKind.material,
      initialFilters: filters,
      initialPeriod: ReceiptsReportPeriod.day(materialsDay2),
      env: env,
    );

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('a material hand-off, then Reset All ($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(
          isDesktop,
          fakeStockEnv(kind: ProductionStockKind.material),
          filters: ProductionHistoryFilters(itemKey: 'sugar'),
        ),
      );
      expect(find.text('Material: Sugar'), findsOneWidget);
      expect(byKey('history-row-sh-1'), findsOneWidget);
      expect(byKey('history-row-mh-2'), findsNothing);
      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();
      expect(byKey('history-row-mh-2'), findsOneWidget);
    });

    testWidgets('a row opens its material ($width)', (tester) async {
      final opened = <String>[];
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(
          isDesktop,
          fakeStockEnv(kind: ProductionStockKind.material, openedItems: opened),
        ),
      );
      await tapStart(tester, byKey('history-row-mh-2'));
      expect(opened, ['flour']);
    });

    testWidgets('the note and the Export pill ($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, fakeStockEnv(kind: ProductionStockKind.material)),
      );
      expect(find.text('Export'), findsOneWidget);
      expect(
        find.textContaining("can't tell production use from manual use"),
        findsOneWidget,
      );
    });
  }
}
