import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'purchase_report_fixtures.dart';

Future<void> pumpTable(
  WidgetTester tester, {
  required bool isDesktop,
  required PurchaseReportEnv env,
  PurchaseReportFilters? filters,
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View". Not narrower: the test font draws every glyph 1em
  // wide, which pushes the shared ReportPager row past 400 px.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: PurchaseReportTableView(
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
    // Below mobileScreen the toolbar sits behind "View".
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}

String idOf(TempPurchase p) =>
    PurchaseReportRowBuilder.displayId(p);

void main() {
  List<TempPurchase> sample() => [
    purchase(
      uuid: uuidN(1),
      supplierId: 'sup-a',
      supplierName: 'Acme',
      staffId: 'staff-a',
      staffName: 'Ada',
      total: 100,
      payments: [payment(100)],
    ),
    purchase(
      uuid: uuidN(2),
      supplierId: 'sup-b',
      supplierName: 'Bolt',
      staffId: 'staff-b',
      staffName: 'Ben',
      total: 200,
    ),
    purchase(
      uuid: uuidN(3),
      supplierId: null,
      supplierName: null,
      staffId: null,
      staffName: null,
      total: 50,
    ),
  ];

  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('Reset All keeps Group by and the period ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeEnv(purchases: sample()),
        filters: PurchaseReportFilters(supplierKey: 'sup-a'),
      );
      expect(find.text('Reset All Filters'), findsOneWidget);

      await tester.tap(find.text('Group by'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PopupMenuItem<PurchaseGroupBy>),
          matching: find.text('Staff'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Group by: Staff'), findsOneWidget);
      // Only Acme's purchase passes the filter.
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Ben'), findsNothing);
      expect(find.text(purchasesNoStaffLabel), findsNothing);

      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Reset All Filters'), findsNothing);
      expect(find.text('Supplier: Acme'), findsNothing);
      expect(find.text('Group by: Staff'), findsOneWidget);
      expect(find.text('Date: All time'), findsOneWidget);
      // Still grouped, now over every purchase, none row last.
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Ben'), findsOneWidget);
      expect(find.text(purchasesNoStaffLabel), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(purchasesNoStaffLabel)).dy,
        greaterThan(tester.getTopLeft(find.text('Ben')).dy),
      );
    });

    testWidgets(
      'a supplier key shows only that supplier ($width)',
      (tester) async {
        final purchases = sample();
        await pumpTable(
          tester,
          isDesktop: isDesktop,
          env: fakeEnv(purchases: purchases),
          filters: PurchaseReportFilters(supplierKey: 'sup-a'),
        );
        expect(find.text('Supplier: Acme'), findsOneWidget);
        expect(find.text(idOf(purchases[0])), findsOneWidget);
        expect(find.text(idOf(purchases[1])), findsNothing);
        expect(find.text(idOf(purchases[2])), findsNothing);
        expect(find.text('Bolt'), findsNothing);
        expect(find.text(purchasesNoSupplierLabel), findsNothing);
      },
    );

    testWidgets(
      'tapping a row opens the purchase; back rebuilds ($width)',
      (tester) async {
        final purchases = sample();
        final opened = <TempPurchase>[];
        await pumpTable(
          tester,
          isDesktop: isDesktop,
          env: fakeEnv(
            purchases: purchases,
            opened: opened,
            // Deleted on the purchase page.
            onOpen: (p) => purchases.remove(p),
          ),
        );
        final id = idOf(purchases[1]);
        expect(find.text(id), findsOneWidget);

        await tester.tap(find.text(id));
        await tester.pumpAndSettle();

        expect(opened.map((p) => p.uuid), [uuidN(2)]);
        expect(find.text(id), findsNothing);
        expect(find.text(idOf(purchases[0])), findsOneWidget);
      },
    );
  }

  testWidgets('totals cover the filtered set; overpaid is flagged', (
    tester,
  ) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeEnv(
        purchases: [
          purchase(uuid: uuidN(1), total: 100),
          purchase(
            uuid: uuidN(2),
            total: 100,
            payments: [payment(130)],
          ),
        ],
      ),
    );
    expect(find.text('TOTAL'), findsOneWidget);
    // Total 200, paid 130, balance 100 + 0 (not 100 - 30).
    expect(find.text('N200.0'), findsOneWidget);
    expect(find.text('N130.0'), findsNWidgets(2));
    expect(find.text('N100.0'), findsNWidgets(4));
    expect(
      find.byTooltip('Overpaid by N30.0'),
      findsOneWidget,
    );
  });

  testWidgets('custom totals show the adjustment', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeEnv(
        purchases: [
          purchase(
            uuid: uuidN(1),
            total: 90,
            isCustomPriceSet: true,
            items: [line(total: 100, purchaseId: uuidN(1))],
          ),
        ],
      ),
    );
    expect(
      find.byTooltip('Custom total. Lines: N100.0 (-N10.0)'),
      findsOneWidget,
    );
  });

  testWidgets('All time shows the loaded-data note', (tester) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeEnv(purchases: sample()),
    );
    expect(
      find.text(
        'All time covers the purchases loaded on this device.',
      ),
      findsOneWidget,
    );
  });
}
