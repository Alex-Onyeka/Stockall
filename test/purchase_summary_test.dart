import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/components/purchase_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'purchase_report_fixtures.dart';

final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

/// Acme paid in full, Bolt partly paid, one with no supplier or
/// staff and nothing paid. All on 17 Oct 2026.
List<TempPurchase> summaryPurchases() => [
  purchase(
    uuid: uuidN(1),
    supplierId: 'sup-a',
    supplierName: 'Acme',
    staffId: 'staff-a',
    staffName: 'Ada',
    total: 100,
    payments: [payment(100)],
    createdAt: DateTime(2026, 10, 17, 9),
  ),
  purchase(
    uuid: uuidN(2),
    supplierId: 'sup-b',
    supplierName: 'Bolt',
    staffId: 'staff-b',
    staffName: 'Ben',
    total: 300,
    payments: [payment(50)],
    createdAt: DateTime(2026, 10, 17, 10),
  ),
  purchase(
    uuid: uuidN(3),
    supplierId: null,
    supplierName: null,
    staffId: null,
    staffName: null,
    total: 50,
    createdAt: DateTime(2026, 10, 17, 11),
  ),
];

TempPurchase overpaidPurchase() => purchase(
  uuid: uuidN(4),
  supplierId: 'sup-a',
  supplierName: 'Acme',
  total: 40,
  payments: [payment(60)],
  createdAt: DateTime(2026, 10, 17, 12),
);

class _Opened {
  final PurchaseReportFilters filters;
  final ReceiptsReportPeriod period;

  _Opened(this.filters, this.period);
}

Future<void> pumpSummary(
  WidgetTester tester, {
  required bool isDesktop,
  required PurchaseReportEnv env,
  ReceiptsReportPeriod? period,
}) async {
  // Mobile is below mobileScreen (650); not narrower, for the same
  // test-font reason as the table tests.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1400) : const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: PurchaseSummaryView(
          // A new key per pump, so a second pump starts fresh.
          key: UniqueKey(),
          isDesktop: isDesktop,
          initialPeriod: period ?? day17,
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

    testWidgets(
      'a supplier row opens the table with its key and period ($width)',
      (tester) async {
        final opened = <_Opened>[];
        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          env: fakeEnv(
            purchases: summaryPurchases(),
            openTable: (_, f, p) async => opened.add(_Opened(f, p)),
          ),
        );

        await tapStart(tester, byKey('purchase-row-suppliers-sup-b'));
        final o = opened.single;
        expect(o.filters.supplierKey, 'sup-b');
        expect(o.filters.activeCount, 1);
        expect(o.period.start, DateTime(2026, 10, 17));
        expect(o.period.end, DateTime(2026, 10, 17));

        // The none row hands off the none key.
        await tapStart(
          tester,
          byKey('purchase-row-suppliers-$purchaseReportNoneKey'),
        );
        expect(opened.last.filters.supplierKey, purchaseReportNoneKey);
      },
    );

    testWidgets('a top supplier opens that supplier ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: fakeEnv(
          purchases: summaryPurchases(),
          openTable: (_, f, p) async => opened.add(_Opened(f, p)),
        ),
      );
      // The none group is never ranked.
      expect(
        byKey('purchase-top-supplier-$purchaseReportNoneKey'),
        findsNothing,
      );

      await tapStart(tester, byKey('purchase-top-supplier-sup-b'));
      expect(opened.single.filters.supplierKey, 'sup-b');
      expect(opened.single.period.start, DateTime(2026, 10, 17));
    });

    testWidgets('a status KPI opens that status ($width)', (
      tester,
    ) async {
      final opened = <_Opened>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: fakeEnv(
          purchases: summaryPurchases(),
          openTable: (_, f, p) async => opened.add(_Opened(f, p)),
        ),
      );

      await tapStart(tester, byKey('purchase-kpi-status-partlyPaid'));
      expect(opened.single.filters.status, PurchaseStatus.partlyPaid);
      expect(opened.single.filters.activeCount, 1);
      expect(opened.single.period.start, DateTime(2026, 10, 17));

      // Outstanding spans two statuses: no filter.
      await tapStart(tester, byKey('purchase-kpi-outstanding'));
      expect(opened.last.filters.activeCount, 0);
    });

    testWidgets('the Overpaid KPI only shows when needed ($width)', (
      tester,
    ) async {
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: fakeEnv(purchases: summaryPurchases()),
      );
      expect(byKey('purchase-kpi-overpaid'), findsNothing);

      final opened = <_Opened>[];
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: fakeEnv(
          purchases: [...summaryPurchases(), overpaidPurchase()],
          openTable: (_, f, p) async => opened.add(_Opened(f, p)),
        ),
      );
      final overpaid = byKey('purchase-kpi-overpaid');
      expect(overpaid, findsOneWidget);
      expect(
        find.descendant(of: overpaid, matching: find.text('1')),
        findsOneWidget,
      );

      await tapStart(tester, overpaid);
      expect(opened.single.filters.activeCount, 0);
      expect(opened.single.filters.status, isNull);
    });

    testWidgets('back from the table rebuilds ($width)', (
      tester,
    ) async {
      final purchases = summaryPurchases();
      await pumpSummary(
        tester,
        isDesktop: isDesktop,
        env: fakeEnv(
          purchases: purchases,
          // Stands in for a purchase added while the table was open.
          openTable:
              (_, f, p) async => purchases.add(overpaidPurchase()),
        ),
      );
      final kpi = byKey('purchase-kpi-purchases');
      expect(
        find.descendant(of: kpi, matching: find.text('3')),
        findsOneWidget,
      );

      await tapStart(tester, kpi);

      expect(
        find.descendant(of: kpi, matching: find.text('4')),
        findsOneWidget,
      );
      expect(byKey('purchase-kpi-overpaid'), findsOneWidget);
    });
  }

  testWidgets('sorting a breakdown column keeps the none row last', (
    tester,
  ) async {
    await pumpSummary(
      tester,
      isDesktop: true,
      env: fakeEnv(purchases: summaryPurchases()),
    );
    double y(String id) =>
        tester.getTopLeft(byKey('purchase-row-suppliers-$id')).dy;

    // Built order: spend, largest first.
    expect(y('sup-b'), lessThan(y('sup-a')));
    expect(y(purchaseReportNoneKey), greaterThan(y('sup-a')));

    // Spend, largest first (first tap), then smallest first.
    await tapStart(tester, byKey('purchase-sort-spend'));
    expect(y('sup-b'), lessThan(y('sup-a')));
    expect(y(purchaseReportNoneKey), greaterThan(y('sup-a')));
    await tapStart(tester, byKey('purchase-sort-spend'));
    expect(y('sup-a'), lessThan(y('sup-b')));
    expect(y(purchaseReportNoneKey), greaterThan(y('sup-b')));

    // Status rows have no none row; Channel's Unpaid stays last.
    await tapStart(tester, byKey('purchase-tab-channel'));
    await tapStart(tester, byKey('purchase-sort-count'));
    double cy(String key) =>
        tester.getTopLeft(byKey('purchase-row-channel-$key')).dy;
    for (final key in ['cash', 'bank', 'split']) {
      expect(cy(purchaseReportNoneKey), greaterThan(cy(key)));
    }
  });

  testWidgets('the Departments tab only shows when departments are on', (
    tester,
  ) async {
    await pumpSummary(
      tester,
      isDesktop: true,
      env: fakeEnv(purchases: summaryPurchases()),
    );
    expect(byKey('purchase-tab-departments'), findsNothing);

    await pumpSummary(
      tester,
      isDesktop: true,
      env: fakeEnv(
        purchases: summaryPurchases(),
        departmentsEnabled: true,
      ),
    );
    expect(byKey('purchase-tab-departments'), findsOneWidget);
  });

  testWidgets('All time shows the loaded-data note', (tester) async {
    await pumpSummary(
      tester,
      isDesktop: true,
      period: const ReceiptsReportPeriod.allTime(),
      env: fakeEnv(purchases: summaryPurchases()),
    );
    expect(
      find.text('All time covers the purchases loaded on this device.'),
      findsOneWidget,
    );
    expect(find.text('Purchase Summary and Analysis'), findsOneWidget);
  });
}
