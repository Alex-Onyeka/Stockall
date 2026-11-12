import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/production_report/usage_summary/components/usage_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

class _Opened {
  final UsageRecordsFilters filters;
  final ReceiptsReportPeriod period;

  _Opened(this.filters, this.period);
}

Future<void> pumpUsageSummary(
  WidgetTester tester, {
  required bool isDesktop,
  required UsageRecordsEnv env,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1400) : const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: UsageSummaryView(
          key: UniqueKey(),
          isDesktop: isDesktop,
          initialPeriod: day2,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into view and taps near its leading edge: the
/// breakdown rows can be wider than a phone screen.
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

    UsageRecordsEnv env(List<_Opened> opened, {bool departments = true}) =>
        fakeUsageEnv(
          usages: sampleUsages(),
          departmentsEnabled: departments,
          openTable: (_, f, p) async => opened.add(_Opened(f, p)),
        );

    void expectDay2(ReceiptsReportPeriod p) {
      expect(p.start, DateTime(2026, 10, 2));
      expect(p.end, DateTime(2026, 10, 2));
    }

    testWidgets('a material row opens the table with its key and period '
        '($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpUsageSummary(tester, isDesktop: isDesktop, env: env(opened));

      await tapStart(tester, byKey('usage-row-materials-flour'));
      final o = opened.single;
      expect(o.filters.materialKey, 'flour');
      expect(o.filters.activeCount, 1);
      expectDay2(o.period);
    });

    testWidgets('a source row hands off the source ($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpUsageSummary(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('usage-tab-source'));

      await tapStart(tester, byKey('usage-row-source-manual'));
      expect(opened.single.filters.source, UsageSource.manual);
      expectDay2(opened.single.period);
    });

    testWidgets('staff (with the none row) and department rows ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpUsageSummary(tester, isDesktop: isDesktop, env: env(opened));

      await tapStart(tester, byKey('usage-tab-staff'));
      await tapStart(tester, byKey('usage-row-staff-$staffBen'));
      expect(opened.last.filters.staffKey, staffBen);
      await tapStart(
        tester,
        byKey('usage-row-staff-$productionReportNoneKey'),
      );
      expect(opened.last.filters.staffKey, productionReportNoneKey);

      await tapStart(tester, byKey('usage-tab-departments'));
      await tapStart(tester, byKey('usage-row-departments-$deptKitchen'));
      expect(opened.last.filters.departmentKey, deptKitchen);
      expectDay2(opened.last.period);
    });

    testWidgets('a KPI opens the table unfiltered ($width)', (tester) async {
      final opened = <_Opened>[];
      await pumpUsageSummary(tester, isDesktop: isDesktop, env: env(opened));
      await tapStart(tester, byKey('usage-kpi-records'));
      expect(opened.single.filters.activeCount, 0);
      expectDay2(opened.single.period);
    });

    testWidgets('the Departments tab only with departments on ($width)', (
      tester,
    ) async {
      await pumpUsageSummary(
        tester,
        isDesktop: isDesktop,
        env: env([], departments: false),
      );
      expect(byKey('usage-tab-departments'), findsNothing);
      expect(byKey('usage-tab-staff'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpUsageSummary(tester, isDesktop: isDesktop, env: env([]));
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('cost KPIs follow the permission; the trend shows records', (
    tester,
  ) async {
    await pumpUsageSummary(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(usages: sampleUsages(), canSeeCost: false),
    );
    expect(byKey('usage-kpi-records'), findsOneWidget);
    expect(byKey('usage-kpi-production'), findsOneWidget);
    expect(byKey('usage-kpi-cost'), findsNothing);
    expect(find.text('Usage Records Trend'), findsOneWidget);
  });

  testWidgets('KPIs show the change against the previous day', (
    tester,
  ) async {
    await pumpUsageSummary(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(
        usages: [
          ...sampleUsages(),
          usageRecord(
            uuid: 'usage-0',
            createdAt: oct(1, 10),
            quantity: 0.2,
            units: flourUnits(),
            totalCost: 1000,
          ),
        ],
      ),
    );
    expect(find.text('▲ 400.0% vs previous period'), findsOneWidget);
  });

  testWidgets('the earlier-productions note', (tester) async {
    await pumpUsageSummary(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(
        usages: sampleUsages(),
        records: [...sampleRecords(), legacyRecord()],
      ),
    );
    expect(
      find.textContaining('1 earlier production has no usage records'),
      findsOneWidget,
    );
  });
}
