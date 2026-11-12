import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_items_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'materials_widgets_kit.dart';
import 'production_report_fixtures.dart';

Widget page(bool isDesktop, ProductionStockEnv env, {ProductionStockFilters? filters}) =>
    StockItemsView(
      key: UniqueKey(),
      isDesktop: isDesktop,
      kind: ProductionStockKind.material,
      initialFilters: filters,
      initialPeriod: ReceiptsReportPeriod.day(materialsDay2),
      env: env,
    );

ProductionStockEnv env({
  bool canSeeQuantity = true,
  List<String>? opened,
}) => fakeStockEnv(
  kind: ProductionStockKind.material,
  canSeeQuantity: canSeeQuantity,
  openedItems: opened,
);

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('a material hand-off, then Reset All ($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, env(), filters: ProductionStockFilters(itemKey: 'flour')),
      );
      expect(find.text('Material: Flour'), findsOneWidget);
      expect(byKey('stock-row-flour'), findsOneWidget);
      expect(byKey('stock-row-sugar'), findsNothing);
      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();
      expect(byKey('stock-row-sugar'), findsOneWidget);
      expect(find.text('Date: Oct 2, 2026'), findsOneWidget);
    });

    testWidgets('a row opens the material ($width)', (tester) async {
      final opened = <String>[];
      await pumpPage(tester, isDesktop: isDesktop, page: page(isDesktop, env(opened: opened)));
      await tapStart(tester, byKey('stock-row-sugar'));
      expect(opened, ['sugar']);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpPage(tester, isDesktop: isDesktop, page: page(isDesktop, env()));
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('low stock, production vs manual use, usage cost', (tester) async {
    await pumpPage(tester, isDesktop: true, page: page(true, env()));
    for (final label in ['Low Stock Qty', 'Used in Production', 'Used Manually', 'Usage Cost']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Total usage cost of the day: ₦16,250 of flour and ₦1,000 of sugar.
    expect(find.text('N17250.0'), findsOneWidget);
    expect(
      find.textContaining('Use in production comes from the production records'),
      findsOneWidget,
    );
  });

  testWidgets('quantities masked without the permission', (tester) async {
    await pumpPage(tester, isDesktop: true, page: page(true, env(canSeeQuantity: false)));
    expect(find.text('1.0 Bag'), findsNothing);
    expect(find.text('****'), findsWidgets);
    expect(find.text('N17250.0'), findsOneWidget);
  });
}
