import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

Future<void> pumpTable(
  WidgetTester tester, {
  required bool isDesktop,
  required ProductionRecordsEnv env,
  ProductionRecordsFilters? filters,
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View". Not narrower: the test font draws every glyph 1em wide,
  // which pushes the shared ReportPager row past 400 px.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: ProductionRecordsTableView(
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
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeRecordsEnv(records: sampleRecords()),
        filters: ProductionRecordsFilters(staffKey: staffAda),
      );
      expect(find.text('Reset All Filters'), findsOneWidget);

      await tester.tap(find.text('Group by'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PopupMenuItem<ProductionGroupBy>),
          matching: find.text('Staff'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Group by: Staff'), findsOneWidget);
      // Only Ada's record passes the filter.
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Ben'), findsNothing);
      expect(find.text(productionNoStaffLabel), findsNothing);

      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Reset All Filters'), findsNothing);
      expect(find.text('Staff: Ada'), findsNothing);
      expect(find.text('Group by: Staff'), findsOneWidget);
      expect(find.text('Date: All time'), findsOneWidget);
      // Still grouped, now over every record, none row last.
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Ben'), findsOneWidget);
      expect(find.text(productionNoStaffLabel), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(productionNoStaffLabel)).dy,
        greaterThan(tester.getTopLeft(find.text('Ben')).dy),
      );
    });

    testWidgets('an output key shows only that output ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeRecordsEnv(records: sampleRecords()),
        filters: ProductionRecordsFilters(outputKey: 'juice'),
      );
      expect(find.text('Output Item: Juice'), findsOneWidget);
      expect(find.text('#prod-3'), findsOneWidget);
      expect(find.text('#prod-1'), findsNothing);
      expect(find.text('#prod-2'), findsNothing);
    });

    testWidgets('tapping a row opens the record; back rebuilds ($width)', (
      tester,
    ) async {
      final records = sampleRecords();
      final opened = <ProductionRecord>[];
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeRecordsEnv(
          records: records,
          opened: opened,
          // Deleted on the production page.
          onOpen: (r) => records.remove(r),
        ),
      );
      expect(find.text('#prod-2'), findsOneWidget);

      await tester.tap(find.text('#prod-2'));
      await tester.pumpAndSettle();

      expect(opened.map((r) => r.uuid), ['prod-2']);
      expect(find.text('#prod-2'), findsNothing);
      expect(find.text('#prod-1'), findsOneWidget);
    });

    testWidgets('shows the Export pill ($width)', (tester) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeRecordsEnv(records: sampleRecords()),
      );
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('totals cover the filtered set', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(records: sampleRecords()),
    );
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('N13400.0'), findsOneWidget);
    expect(find.text('N10800.0'), findsOneWidget);
    expect(find.text('N2600.0'), findsOneWidget);
    // Mixed items: no quantity total.
    expect(find.text('66.0 Pcs'), findsNothing);
  });

  testWidgets('one output item: the quantity total', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(records: sampleRecords()),
      filters: ProductionRecordsFilters(outputKey: 'donut'),
    );
    expect(find.text('66.0 Pcs'), findsOneWidget);
    expect(find.text('N12200.0'), findsOneWidget);
  });

  testWidgets('cost columns need the cost permission', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(records: sampleRecords(), canSeeCost: false),
    );
    expect(find.text('Quantity'), findsOneWidget);
    for (final label in [
      'Material Cost',
      'Recorded Cost',
      'Cost Source',
      'Variance',
      'Cost / Unit',
    ]) {
      expect(find.text(label), findsNothing, reason: label);
    }
    expect(find.text('N13400.0'), findsNothing);
  });

  testWidgets('quantity columns need the quantity permission', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(records: sampleRecords(), canSeeQuantity: false),
    );
    expect(find.text('Quantity'), findsNothing);
    expect(find.text('Cost / Unit'), findsNothing);
    expect(find.text('Recorded Cost'), findsOneWidget);
  });

  testWidgets('the department column only with departments on', (
    tester,
  ) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(records: sampleRecords(), departmentsEnabled: true),
    );
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Bakery'), findsNWidgets(2));
  });

  testWidgets('All time shows the loaded-data note', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeRecordsEnv(records: sampleRecords()),
    );
    expect(
      find.textContaining(
        'All time covers the production records loaded on this device.',
      ),
      findsOneWidget,
    );
  });
}
