import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

Future<void> pumpUsageTable(
  WidgetTester tester, {
  required bool isDesktop,
  required UsageRecordsEnv env,
  UsageRecordsFilters? filters,
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View".
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: UsageRecordsTableView(
          isDesktop: isDesktop,
          initialFilters: filters,
          initialPeriod: const ReceiptsReportPeriod.allTime(),
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

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('Reset All keeps Group by and the period ($width)', (
      tester,
    ) async {
      await pumpUsageTable(
        tester,
        isDesktop: isDesktop,
        env: fakeUsageEnv(usages: sampleUsages()),
        filters: UsageRecordsFilters(staffKey: staffAda),
      );
      expect(find.text('Reset All Filters'), findsOneWidget);

      await tester.tap(find.text('Group by'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PopupMenuItem<UsageGroupBy>),
          matching: find.text('Staff'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Group by: Staff'), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Ben'), findsNothing);

      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Reset All Filters'), findsNothing);
      expect(find.text('Staff: Ada'), findsNothing);
      expect(find.text('Group by: Staff'), findsOneWidget);
      expect(find.text('Date: All time'), findsOneWidget);
      // Still grouped, now over every usage, none row last.
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Ben'), findsOneWidget);
      expect(find.text(productionNoStaffLabel), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(productionNoStaffLabel)).dy,
        greaterThan(tester.getTopLeft(find.text('Ben')).dy),
      );
    });

    testWidgets('a material key shows only that material ($width)', (
      tester,
    ) async {
      await pumpUsageTable(
        tester,
        isDesktop: isDesktop,
        env: fakeUsageEnv(usages: sampleUsages()),
        filters: UsageRecordsFilters(materialKey: 'sugar'),
      );
      expect(find.text('Material: Sugar'), findsOneWidget);
      expect(find.text('#usage-3'), findsOneWidget);
      expect(find.text('#usage-4'), findsOneWidget);
      expect(find.text('#usage-1'), findsNothing);
    });

    testWidgets('a production usage opens its production; a manual one '
        'its details; back rebuilds ($width)', (tester) async {
      final usages = sampleUsages();
      final productions = <String>[];
      final opened = <ProductionMaterialsUsage>[];
      await pumpUsageTable(
        tester,
        isDesktop: isDesktop,
        env: fakeUsageEnv(
          usages: usages,
          openedProductions: productions,
          openedUsages: opened,
          // Deleted from the usage dialog.
          onOpenUsage: (u) => usages.remove(u),
        ),
      );

      await tester.tap(find.text('#usage-1'));
      await tester.pumpAndSettle();
      expect(productions, ['prod-1']);
      expect(opened, isEmpty);

      await tester.tap(find.text('#usage-4'));
      await tester.pumpAndSettle();
      expect(opened.map((u) => u.uuid), ['usage-4']);
      expect(find.text('#usage-4'), findsNothing);
      expect(find.text('#usage-5'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpUsageTable(
        tester,
        isDesktop: isDesktop,
        env: fakeUsageEnv(usages: sampleUsages()),
      );
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('a production usage whose record is not loaded opens the '
      'usage details', (tester) async {
    final productions = <String>[];
    final opened = <ProductionMaterialsUsage>[];
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(
        usages: [AlexExample().usage],
        records: const [],
        openedProductions: productions,
        openedUsages: opened,
      ),
    );
    expect(find.text('Not loaded'), findsOneWidget);
    await tester.tap(find.text('#usage-1'));
    await tester.pumpAndSettle();
    expect(productions, isEmpty);
    expect(opened.single.uuid, 'usage-1');
  });

  testWidgets('totals cover the filtered set', (tester) async {
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(usages: sampleUsages()),
    );
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('N12250.0'), findsOneWidget);
    // Mixed materials: no quantity total.
    expect(find.text('2.25 Bag'), findsNothing);
  });

  testWidgets('one material: the quantity total and unit cost', (
    tester,
  ) async {
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(usages: sampleUsages()),
      filters: UsageRecordsFilters(materialKey: 'flour'),
    );
    expect(find.text('2.25 Bag'), findsOneWidget);
    expect(find.text('N11250.0'), findsOneWidget);
    // ₦5,000 a bag: three unit costs, two ₦5,000 costs and the
    // average unit cost in the totals row.
    expect(find.text('N5000.0'), findsNWidgets(6));
  });

  testWidgets('cost columns need the cost permission', (tester) async {
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(usages: sampleUsages(), canSeeCost: false),
    );
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Cost'), findsNothing);
    expect(find.text('Unit Cost'), findsNothing);
    expect(find.text('N12250.0'), findsNothing);
  });

  testWidgets('quantity columns need the quantity permission', (
    tester,
  ) async {
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(usages: sampleUsages(), canSeeQuantity: false),
    );
    expect(find.text('Quantity'), findsNothing);
    expect(find.text('Unit Cost'), findsNothing);
    expect(find.text('Cost'), findsOneWidget);
  });

  testWidgets('the department column only with departments on', (
    tester,
  ) async {
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(usages: sampleUsages(), departmentsEnabled: true),
    );
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
  });

  testWidgets('the notes: All time and earlier productions', (tester) async {
    await pumpUsageTable(
      tester,
      isDesktop: true,
      env: fakeUsageEnv(
        usages: sampleUsages(),
        records: [...sampleRecords(), legacyRecord()],
      ),
    );
    expect(
      find.textContaining(
        'All time covers the usage records loaded on this device.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('1 earlier production has no usage records'),
      findsOneWidget,
    );
  });
}
