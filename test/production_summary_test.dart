import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/production_summary/components/production_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

class _Opened {
  final ProductionRecordsFilters filters;
  final ReceiptsReportPeriod period;

  _Opened(this.filters, this.period);
}

Future<void> pumpSummary(
  WidgetTester tester, {
  required bool isDesktop,
  required ProductionRecordsEnv env,
  ReceiptsReportPeriod? period,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1400) : const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: ProductionSummaryView(
          key: UniqueKey(),
          isDesktop: isDesktop,
          initialPeriod: period ?? day2,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into view and taps near its leading edge: the
/// breakdown rows are wider than a phone screen.
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

    ProductionRecordsEnv env(List<_Opened> opened, {bool departments = true}) =>
        fakeRecordsEnv(
          records: sampleRecords(),
          departmentsEnabled: departments,
          openTable: (_, f, p) async => opened.add(_Opened(f, p)),
        );

    void expectDay2(ReceiptsReportPeriod p) {
      expect(p.start, DateTime(2026, 10, 2));
      expect(p.end, DateTime(2026, 10, 2));
    }

    testWidgets('an output item row opens the table with its key and '
        'period ($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpSummary(tester, isDesktop: isDesktop, env: env(opened));

      await tapStart(tester, byKey('production-row-outputItems-donut'));
      final o = opened.single;
      expect(o.filters.outputKey, 'donut');
      expect(o.filters.activeCount, 1);
      expectDay2(o.period);
    });

    testWidgets('a material row, and the none row, hand off their keys '
        '($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpSummary(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('production-tab-materials'));

      await tapStart(tester, byKey('production-row-materials-flour'));
      expect(opened.last.filters.materialKey, 'flour');
      expectDay2(opened.last.period);

      await tapStart(
        tester,
        byKey('production-row-materials-$productionReportNoneKey'),
      );
      expect(opened.last.filters.materialKey, productionReportNoneKey);
    });

    testWidgets('a yield row hands off the output and the material ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpSummary(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('production-tab-yield'));

      await tapStart(tester, byKey('production-row-yield-donut|sugar'));
      final f = opened.single.filters;
      expect(f.outputKey, 'donut');
      expect(f.materialKey, 'sugar');
      expect(f.activeCount, 2);
    });

    testWidgets('staff and department rows ($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpSummary(tester, isDesktop: isDesktop, env: env(opened));

      await tapStart(tester, byKey('production-tab-staff'));
      await tapStart(tester, byKey('production-row-staff-$staffBen'));
      expect(opened.last.filters.staffKey, staffBen);

      await tapStart(tester, byKey('production-tab-departments'));
      await tapStart(tester, byKey('production-row-departments-$deptBakery'));
      expect(opened.last.filters.departmentKey, deptBakery);
      expectDay2(opened.last.period);
    });

    testWidgets('a KPI opens the table unfiltered ($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpSummary(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('production-kpi-runs'));
      expect(opened.single.filters.activeCount, 0);
      expectDay2(opened.single.period);
    });

    testWidgets('the Departments tab only with departments on ($width)', (
      tester,
    ) async {
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: env([], departments: false),
      );
      expect(byKey('production-tab-departments'), findsNothing);
      expect(byKey('production-tab-staff'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpSummary(tester, isDesktop: isDesktop, env: env([]));
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('cost KPIs and the yield tab follow the permissions', (
    tester,
  ) async {
    await pumpSummary(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(
        records: sampleRecords(),
        canSeeCost: false,
        canSeeQuantity: false,
      ),
    );
    expect(byKey('production-kpi-runs'), findsOneWidget);
    expect(byKey('production-kpi-recordedCost'), findsNothing);
    expect(byKey('production-tab-yield'), findsNothing);
    expect(find.text('Production Runs Trend'), findsOneWidget);
  });

  testWidgets('KPIs show the change against the previous day', (tester) async {
    await pumpSummary(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(
        records: [
          ...sampleRecords(),
          productionRecord(
            uuid: 'prod-0',
            createdAt: oct(1, 10),
            quantity: 20,
            units: donutUnits(),
            totalCost: 4000,
          ),
        ],
      ),
    );
    expect(find.text('▲ 200.0% vs previous period'), findsOneWidget);
  });
}
