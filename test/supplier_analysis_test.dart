import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/components/supplier_analysis_view.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/platforms/supplier_analysis_desktop.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/platforms/supplier_analysis_mobile.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';

import 'supplier_report_fixtures.dart';

Finder byKey(String key) => find.byKey(ValueKey(key));

Finder inKpi(String id, String text) => find.descendant(
  of: byKey('supplier-kpi-$id'),
  matching: find.text(text),
);

final Finder recentRows = find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key as ValueKey<String>).value.startsWith(
        'supplier-recent-',
      ),
);

Future<void> pumpAnalysis(
  WidgetTester tester, {
  required bool isDesktop,
  required SupplierReportEnv env,
  String supplierKey = 'sup-a',
  ReceiptsReportPeriod? period,
}) => pumpReport(
  tester,
  isDesktop: isDesktop,
  openToolbar: false,
  child: SupplierAnalysisView(
    isDesktop: isDesktop,
    supplierKey: supplierKey,
    initialPeriod: period,
    env: env,
  ),
);

/// Taps [finder] after scrolling it into view.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  List<SuppliersClass> suppliers() => [
    supplier(
      'sup-a',
      name: 'Acme',
      phone: '0801',
      email: 'sales@acme.ng',
      address: '12 Allen Avenue',
      city: 'Ikeja',
      country: 'Nigeria',
    ),
    supplier('sup-b', name: 'Bolt'),
    supplier('sup-c', name: 'Cobalt'),
  ];

  List<TempPurchase> purchases() => [
    bought(1, supplierId: 'sup-a', day: 2, total: 100, paid: 100),
    bought(2, supplierId: 'sup-a', day: 9, total: 300, paid: 50),
    // Overpaid: owes 0, not -40.
    bought(3, supplierId: 'sup-a', day: 9, total: 80, paid: 120),
    bought(4, supplierId: 'sup-b', day: 9, total: 999),
    bought(5, supplierId: null, day: 9, total: 999),
  ];

  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    for (final period in [
      const ReceiptsReportPeriod.allTime(),
      // A single day keeps the mobile period label narrow in the
      // test font.
      ReceiptsReportPeriod.day(DateTime(2026, 10, 9)),
    ]) {
      final name = period.isAllTime ? 'all time' : 'a day';

      testWidgets('KPIs equal the table row ($name, $width)', (
        tester,
      ) async {
        final data = purchases();
        await pumpAnalysis(
          tester,
          isDesktop: isDesktop,
          period: period,
          env: fakeSupplierEnv(
            purchases: data,
            suppliers: suppliers(),
          ),
        );
        final row = rowOf(
          supplierRows(
            suppliers: suppliers(),
            purchases: data,
            period: period,
          ),
          'sup-a',
        );
        expect(row.purchaseCount, period.isAllTime ? 3 : 2);
        expect(
          inKpi('purchases', '${row.purchaseCount}'),
          findsOneWidget,
        );
        expect(inKpi('spend', 'N${row.spend}'), findsOneWidget);
        expect(inKpi('paid', 'N${row.paid}'), findsOneWidget);
        expect(inKpi('balance', 'N${row.balance}'), findsOneWidget);
        expect(inKpi('average', 'N${row.average}'), findsOneWidget);
        expect(
          inKpi('first', formatDateTime(row.firstPurchase!)),
          findsOneWidget,
        );
        expect(
          inKpi('last', formatDateTime(row.lastPurchase!)),
          findsOneWidget,
        );
        expect(
          find.text(
            'All time covers the purchases loaded on this device.',
          ),
          period.isAllTime ? findsOneWidget : findsNothing,
        );
        // Header: the name and contact details.
        expect(find.text('Acme'), findsOneWidget);
        expect(find.text('0801'), findsOneWidget);
        expect(
          find.text('12 Allen Avenue, Ikeja, Nigeria'),
          findsOneWidget,
        );
        expect(find.text(supplierDeletedLabel), findsNothing);
      });
    }

    testWidgets('"See all" passes the supplier and period ($width)', (
      tester,
    ) async {
      final tables = <OpenedTable>[];
      final period = ReceiptsReportPeriod.day(DateTime(2026, 10, 9));
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        period: period,
        env: fakeSupplierEnv(
          purchases: purchases(),
          suppliers: suppliers(),
          openedTables: tables,
        ),
      );
      await tapVisible(tester, byKey('supplier-see-all'));

      final opened = tables.single;
      expect(opened.filters.supplierKey, 'sup-a');
      expect(opened.filters.activeCount, 1);
      expect(opened.filters.search, isEmpty);
      expect(opened.period, same(period));
    });

    testWidgets('tapping a recent purchase opens it ($width)', (
      tester,
    ) async {
      final opened = <TempPurchase>[];
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: purchases(),
          suppliers: suppliers(),
          openedPurchases: opened,
        ),
      );
      await tapVisible(tester, byKey('supplier-recent-${uuidN(2)}'));
      expect(opened.map((p) => p.uuid), [uuidN(2)]);
    });

    testWidgets('only the 5 newest purchases show ($width)', (
      tester,
    ) async {
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: [
            for (var i = 1; i <= 7; i++)
              bought(i, supplierId: 'sup-a', day: i),
          ],
          suppliers: suppliers(),
        ),
      );
      expect(recentRows, findsNWidgets(5));
      final ys = [
        for (final n in [7, 6, 5, 4, 3])
          tester.getTopLeft(byKey('supplier-recent-${uuidN(n)}')).dy,
      ];
      expect(ys, List.of(ys)..sort());
      expect(byKey('supplier-recent-${uuidN(2)}'), findsNothing);
      expect(find.text('Newest first · 7 purchases in this period'),
          findsOneWidget);
      expect(byKey('supplier-see-all'), findsOneWidget);
    });

    testWidgets('top items, with the missing details and custom '
        'total notes ($width)', (tester) async {
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: [
            bought(
              1,
              supplierId: 'sup-a',
              total: 500,
              items: [
                namedLine(
                  purchaseId: uuidN(1),
                  itemId: 'rice',
                  itemName: 'Rice',
                  quantity: 2,
                  total: 200,
                ),
                namedLine(
                  purchaseId: uuidN(1),
                  itemId: 'oil',
                  itemName: 'Oil',
                  quantity: 3,
                  total: 300,
                ),
              ],
            ),
            bought(2, supplierId: 'sup-a', noItems: true),
            bought(
              3,
              supplierId: 'sup-a',
              total: 90,
              isCustomPriceSet: true,
              items: [
                namedLine(
                  purchaseId: uuidN(3),
                  itemId: 'rice',
                  itemName: 'Rice',
                  total: 100,
                ),
              ],
            ),
          ],
          suppliers: suppliers(),
        ),
      );
      final oil = byKey('supplier-top-item-oil');
      final rice = byKey('supplier-top-item-rice');
      expect(oil, findsOneWidget);
      expect(rice, findsOneWidget);
      // Both spent 300 (rice 200 + 100) on 3 items: by name.
      expect(
        tester.getTopLeft(oil).dy,
        lessThan(tester.getTopLeft(rice).dy),
      );
      expect(
        find.descendant(of: rice, matching: find.text('N300.0')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rice,
          matching: find.text('2 purchases · 3 items'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('1 purchase without item details'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Some purchases have a custom total, so item spend '
          'can differ from total spend.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a deleted supplier is marked in the header '
        '($width)', (tester) async {
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        supplierKey: 'gone',
        env: fakeSupplierEnv(
          purchases: [
            bought(
              1,
              supplierId: 'gone',
              supplierName: 'Gone Ltd',
              total: 50,
            ),
          ],
          suppliers: suppliers(),
        ),
      );
      expect(find.text('Gone Ltd'), findsOneWidget);
      expect(find.text(supplierDeletedLabel), findsOneWidget);
      expect(
        find.descendant(
          of: byKey('supplier-contact'),
          matching: find.text('—'),
        ),
        findsNWidgets(3),
      );
      expect(inKpi('spend', 'N50.0'), findsOneWidget);
    });

    testWidgets('back from a purchase rebuilds ($width)', (
      tester,
    ) async {
      final data = [
        bought(1, supplierId: 'sup-a', total: 300),
      ];
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: data,
          suppliers: suppliers(),
          // A payment recorded on the purchase page.
          onOpenPurchase:
              (p) => p.purchasePayments.add(
                payment(120, uuid: 'pay-late'),
              ),
        ),
      );
      expect(inKpi('paid', 'N0.0'), findsOneWidget);
      expect(inKpi('balance', 'N300.0'), findsOneWidget);

      await tapVisible(tester, byKey('supplier-recent-${uuidN(1)}'));

      expect(inKpi('paid', 'N120.0'), findsOneWidget);
      expect(inKpi('balance', 'N180.0'), findsOneWidget);
    });

    testWidgets('no purchases in the period ($width)', (
      tester,
    ) async {
      await pumpAnalysis(
        tester,
        isDesktop: isDesktop,
        supplierKey: 'sup-c',
        env: fakeSupplierEnv(
          purchases: purchases(),
          suppliers: suppliers(),
        ),
      );
      expect(find.text('Cobalt'), findsOneWidget);
      expect(find.text('No purchases in this period'), findsOneWidget);
      expect(find.text('No items in this period.'), findsOneWidget);
      expect(byKey('supplier-see-all'), findsNothing);
      expect(recentRows, findsNothing);
      expect(inKpi('purchases', '0'), findsOneWidget);
      expect(inKpi('first', '—'), findsOneWidget);
    });

    testWidgets('a table row opens this page with the table\'s '
        'period; back returns ($width)', (tester) async {
      final period = ReceiptsReportPeriod.day(DateTime(2026, 10, 9));
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        // No openAnalysis hook: the table pushes the page.
        child: SupplierReportTableView(
          isDesktop: isDesktop,
          initialPeriod: period,
          env: fakeSupplierEnv(
            purchases: purchases(),
            suppliers: suppliers(),
          ),
        ),
      );
      await tester.tap(
        find.descendant(
          of: byKey('supplier-row-sup-a'),
          matching: find.text('Acme'),
        ),
      );
      await tester.pumpAndSettle();

      final view = tester.widget<SupplierAnalysisView>(
        find.byType(SupplierAnalysisView),
      );
      expect(view.supplierKey, 'sup-a');
      expect(view.initialPeriod, same(period));
      expect(
        find.byType(
          isDesktop ? SupplierAnalysisDesktop : SupplierAnalysisMobile,
        ),
        findsOneWidget,
      );
      // Acme on the 9th: 300 + 80.
      expect(inKpi('spend', 'N380.0'), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SupplierAnalysisView), findsNothing);
      expect(byKey('supplier-row-sup-a'), findsOneWidget);
    });
  }

  testWidgets('without View Date: today, and the period is locked', (
    tester,
  ) async {
    await pumpAnalysis(
      tester,
      isDesktop: true,
      period: const ReceiptsReportPeriod.allTime(),
      env: fakeSupplierEnv(
        purchases: purchases(),
        suppliers: suppliers(),
        canPickDate: false,
      ),
    );
    expect(find.textContaining('Date: Today'), findsOneWidget);
    expect(
      tester
          .widget<PopupMenuButton<int>>(
            find.byType(PopupMenuButton<int>),
          )
          .enabled,
      isFalse,
    );
    expect(
      find.text(
        'All time covers the purchases loaded on this device.',
      ),
      findsNothing,
    );
  });
}
