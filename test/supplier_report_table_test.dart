import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_filter_widgets.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/platforms/supplier_report_table_desktop.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/platforms/supplier_report_table_mobile.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/supplier_report_table_page.dart';

import 'supplier_report_fixtures.dart';

Finder byKey(String key) => find.byKey(ValueKey(key));
Finder rowOfKey(String key) => byKey('supplier-row-$key');
Finder inTotals(String text) => find.descendant(
  of: byKey('supplier-totals'),
  matching: find.text(text),
);

Future<void> pumpTable(
  WidgetTester tester, {
  required bool isDesktop,
  required SupplierReportEnv env,
  SupplierReportFilters? filters,
  ReceiptsReportPeriod? period,
}) => pumpReport(
  tester,
  isDesktop: isDesktop,
  child: SupplierReportTableView(
    isDesktop: isDesktop,
    initialFilters: filters,
    initialPeriod: period,
    env: env,
  ),
);

/// Taps [finder] after scrolling it into view (mobile tables
/// scroll sideways).
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Row keys from top to bottom.
List<String> order(WidgetTester tester, List<String> keys) {
  final present = keys.where(
    (k) => rowOfKey(k).evaluate().isNotEmpty,
  );
  return present.toList()..sort(
    (a, b) => tester
        .getTopLeft(rowOfKey(a))
        .dy
        .compareTo(tester.getTopLeft(rowOfKey(b)).dy),
  );
}

void main() {
  const keys = ['sup-a', 'sup-b', 'sup-c', 'gone'];

  List<SuppliersClass> sampleSuppliers() => [
    supplier(
      'sup-b',
      name: 'Bolt',
      phone: '0802',
      country: 'Ghana',
    ),
    supplier(
      'sup-a',
      name: 'Acme',
      email: 'sales@acme.ng',
      address: '12 Allen Avenue',
      city: 'Ikeja',
      state: 'Lagos',
      country: 'Nigeria',
    ),
    supplier('sup-c', name: 'Cobalt'),
  ];

  List<TempPurchase> samplePurchases() => [
    bought(1, supplierId: 'sup-a', day: 3, total: 100, paid: 100),
    bought(2, supplierId: 'sup-b', day: 9, total: 300),
    bought(
      3,
      supplierId: 'gone',
      supplierName: 'Gone Ltd',
      day: 5,
      total: 50,
    ),
    // No supplier: not a row, not in the totals.
    bought(4, supplierId: null, day: 5, total: 999),
  ];

  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('opens on Name A-Z over all time ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: samplePurchases(),
          suppliers: sampleSuppliers(),
        ),
      );
      expect(order(tester, keys), [
        'sup-a',
        'sup-b',
        'sup-c',
        'gone',
      ]);
      expect(
        find.descendant(
          of: byKey('supplier-sort-name'),
          matching: find.byIcon(Icons.arrow_upward_rounded),
        ),
        findsOneWidget,
      );
      expect(find.text('Date: All time'), findsOneWidget);
      expect(
        find.text(
          'All time covers the purchases loaded on this device.',
        ),
        findsOneWidget,
      );
      // A supplier without purchases still shows; blanks are "—".
      expect(
        find.descendant(
          of: rowOfKey('sup-c'),
          matching: find.text('—'),
        ),
        findsWidgets,
      );
      expect(
        find.text('12 Allen Avenue, Ikeja, Lagos, Nigeria'),
        findsOneWidget,
      );
      expect(inTotals('TOTAL'), findsOneWidget);
      // Acme + Bolt + Gone: the no-supplier purchase is left out.
      expect(inTotals('N450.0'), findsOneWidget);
      expect(inTotals('N350.0'), findsOneWidget);
    });

    testWidgets('first tap on Spend sorts largest first ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: samplePurchases(),
          suppliers: sampleSuppliers(),
        ),
      );
      await tapVisible(tester, byKey('supplier-sort-spend'));
      expect(order(tester, keys), [
        'sup-b',
        'sup-a',
        'gone',
        'sup-c',
      ]);
      expect(
        find.descendant(
          of: byKey('supplier-sort-spend'),
          matching: find.byIcon(Icons.arrow_downward_rounded),
        ),
        findsOneWidget,
      );

      await tapVisible(tester, byKey('supplier-sort-spend'));
      expect(order(tester, keys), [
        'sup-c',
        'gone',
        'sup-a',
        'sup-b',
      ]);
    });

    testWidgets('Has balance owed keeps owing suppliers ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: samplePurchases(),
          suppliers: sampleSuppliers(),
        ),
      );
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('supplier-has-balance'));
      await tester.pumpAndSettle();

      expect(order(tester, keys), ['sup-b', 'gone']);
      expect(find.text('Filters (1)'), findsOneWidget);
      final chip = find.widgetWithText(
        InputChip,
        supplierHasBalanceLabel,
      );
      expect(chip, findsOneWidget);
      // Totals follow the filter.
      expect(inTotals('N350.0'), findsNWidgets(2));

      await tester.tap(
        find.descendant(
          of: chip,
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();
      expect(order(tester, keys), [
        'sup-a',
        'sup-b',
        'sup-c',
        'gone',
      ]);
      expect(chip, findsNothing);
    });

    testWidgets('Reset All keeps the period and sort ($width)', (
      tester,
    ) async {
      // A single day: a range label is wider than the mobile
      // toolbar in the test font (every glyph is 1em wide).
      final period = ReceiptsReportPeriod.day(DateTime(2026, 10, 9));
      final dateLabel = 'Date: ${receiptsPeriodLabel(period)}';
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        period: period,
        env: fakeSupplierEnv(
          purchases: samplePurchases(),
          suppliers: sampleSuppliers(),
        ),
        filters: SupplierReportFilters(countryKey: 'nigeria'),
      );
      expect(find.text(dateLabel), findsOneWidget);
      expect(find.text('Country: Nigeria'), findsOneWidget);
      expect(order(tester, keys), ['sup-a']);

      await tapVisible(tester, byKey('supplier-sort-spend'));
      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Reset All Filters'), findsNothing);
      expect(find.text('Country: Nigeria'), findsNothing);
      expect(find.text(dateLabel), findsOneWidget);
      // Still by Spend, largest first: only Bolt bought on the 9th;
      // the rest tie at 0, by name. The deleted supplier has no
      // purchase that day, so no row.
      expect(order(tester, keys), ['sup-b', 'sup-a', 'sup-c']);
    });

    testWidgets('totals stay the same across pages ($width)', (
      tester,
    ) async {
      final suppliers = [
        for (var i = 0; i < 150; i++)
          supplier(
            's${i.toString().padLeft(3, '0')}',
            name: 'Supplier ${i.toString().padLeft(3, '0')}',
          ),
      ];
      final purchases = [
        for (var i = 0; i < 150; i++)
          bought(
            i + 1,
            supplierId: 's${i.toString().padLeft(3, '0')}',
            total: 10,
            paid: 4,
          ),
      ];
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: purchases,
          suppliers: suppliers,
        ),
      );
      void expectTotals() {
        expect(inTotals('150'), findsOneWidget);
        expect(inTotals('N1500.0'), findsOneWidget);
        expect(inTotals('N600.0'), findsOneWidget);
        expect(inTotals('N900.0'), findsOneWidget);
      }

      expect(rowOfKey('s000'), findsOneWidget);
      expectTotals();

      await tapVisible(tester, find.text('Next'));

      expect(rowOfKey('s000'), findsNothing);
      expect(rowOfKey('s100'), findsOneWidget);
      expectTotals();
    });

    testWidgets('a deleted supplier is marked ($width)', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        env: fakeSupplierEnv(
          purchases: samplePurchases(),
          suppliers: sampleSuppliers(),
        ),
      );
      expect(find.text(supplierDeletedLabel), findsOneWidget);
      expect(
        find.descendant(
          of: rowOfKey('gone'),
          matching: find.text(supplierDeletedLabel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rowOfKey('gone'),
          matching: find.text('Gone Ltd'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a row opens its analysis with the period; '
        'back rebuilds ($width)', (tester) async {
      final purchases = samplePurchases();
      final opened = <OpenedAnalysis>[];
      // Bolt's purchase day.
      final period = ReceiptsReportPeriod.day(DateTime(2026, 10, 9));
      await pumpTable(
        tester,
        isDesktop: isDesktop,
        period: period,
        env: fakeSupplierEnv(
          purchases: purchases,
          suppliers: sampleSuppliers(),
          opened: opened,
          // A payment made from the analysis.
          onOpenAnalysis:
              (row) => purchases[1].purchasePayments.add(
                payment(120, uuid: 'pay-late'),
              ),
        ),
      );
      // Spend and balance owed.
      expect(inTotals('N300.0'), findsNWidgets(2));

      await tester.tap(
        find.descendant(
          of: rowOfKey('sup-b'),
          matching: find.text('Bolt'),
        ),
      );
      await tester.pumpAndSettle();

      expect(opened.map((o) => o.key), ['sup-b']);
      expect(opened.single.row.label, 'Bolt');
      expect(opened.single.period, same(period));
      // Spend 300, paid 120, owed 180.
      expect(inTotals('N300.0'), findsOneWidget);
      expect(inTotals('N120.0'), findsOneWidget);
      expect(inTotals('N180.0'), findsOneWidget);
    });
  }

  testWidgets('without View Date: today, and the period is locked', (
    tester,
  ) async {
    await pumpTable(
      tester,
      isDesktop: true,
      env: fakeSupplierEnv(
        purchases: samplePurchases(),
        suppliers: sampleSuppliers(),
        canPickDate: false,
      ),
      period: const ReceiptsReportPeriod.allTime(),
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
    // Suppliers still show, with today's (no) purchases.
    expect(rowOfKey('sup-a'), findsOneWidget);
  });

  testWidgets('the page picks mobile or desktop by width', (
    tester,
  ) async {
    final env = fakeSupplierEnv(
      purchases: samplePurchases(),
      suppliers: sampleSuppliers(),
    );
    await pumpReport(
      tester,
      isDesktop: true,
      child: SupplierReportTablePage(env: env),
    );
    expect(find.byType(SupplierReportTableDesktop), findsOneWidget);

    await pumpReport(
      tester,
      isDesktop: false,
      child: SupplierReportTablePage(env: env),
    );
    expect(find.byType(SupplierReportTableMobile), findsOneWidget);
  });
}
