import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_analysis_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'materials_widgets_kit.dart';
import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(materialsDay2);

Widget page(bool isDesktop, ProductionStockEnv env) => StockAnalysisView(
  key: UniqueKey(),
  isDesktop: isDesktop,
  kind: ProductionStockKind.material,
  initialPeriod: day2,
  env: env,
);

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';
    final opened = <(ProductionStockFilters, ReceiptsReportPeriod)>[];
    ProductionStockEnv env({bool departments = true}) => fakeStockEnv(
      kind: ProductionStockKind.material,
      departmentsEnabled: departments,
      openTable: (_, f, p) async => opened.add((f, p)),
    );

    testWidgets('rows open the Materials table with filters and period '
        '($width)', (tester) async {
      opened.clear();
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, env()),
        tapView: false,
        mobileHeight: 1800,
      );
      await tapStart(tester, byKey('analysis-row-usedQuantity-flour'));
      expect(opened.last.$1.itemKey, 'flour');
      expect(opened.last.$2.start, materialsDay2);
      await tapStart(tester, byKey('analysis-tab-unused'));
      await tapStart(tester, byKey('analysis-row-unused-yeast'));
      expect(opened.last.$1.itemKey, 'yeast');
      await tapStart(tester, byKey('analysis-tab-departments'));
      await tapStart(tester, byKey('analysis-row-departments-$deptKitchen'));
      expect(opened.last.$1.departmentKey, deptKitchen);
      await tapStart(tester, byKey('analysis-kpi-lowStock'));
      expect(opened.last.$1.activeCount, 0);
    });

    testWidgets('Departments only with departments on ($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, env(departments: false)),
        tapView: false,
        mobileHeight: 1800,
      );
      expect(byKey('analysis-tab-departments'), findsNothing);
      expect(byKey('analysis-tab-costChanges'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpPage(
        tester,
        isDesktop: isDesktop,
        page: page(isDesktop, env()),
        tapView: false,
        mobileHeight: 1800,
      );
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('the material cards', (tester) async {
    await pumpPage(
      tester,
      isDesktop: true,
      page: page(true, fakeStockEnv(kind: ProductionStockKind.material)),
      tapView: false,
    );
    for (final title in ['Materials', 'Low Stock', 'Usage Cost', 'Used']) {
      expect(find.text(title), findsWidgets, reason: title);
    }
    expect(find.text('N17250.0'), findsOneWidget);
    expect(find.textContaining('Cost changes come from usage records'), findsOneWidget);
  });
}
