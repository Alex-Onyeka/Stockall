import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/general_report/components/general_report_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'general_report_fixtures.dart';
import 'purchase_report_fixtures.dart' show purchase, uuidN;

final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

List<TempPurchase> samplePurchases() => [
  purchase(uuid: uuidN(1), total: 100),
  purchase(uuid: uuidN(2), total: 250),
  purchase(
    uuid: uuidN(3),
    total: 75,
    createdAt: DateTime(2026, 10, 16, 12),
  ),
];

List<TempExpensesClass> sampleExpenses() => [
  expense(uuid: 'e-1', amount: 40),
  expense(uuid: 'e-2', amount: 25),
  expense(
    uuid: 'e-3',
    amount: 500,
    createdDate: DateTime(2026, 10, 16, 12),
  ),
];

String money(num v) => 'N$v';

/// The page without providers. The lists are read on every
/// rebuild, so a hook can change them.
GeneralReportEnv fakeGeneralEnv({
  List<TempMainReceipt>? receipts,
  List<TempPurchase>? purchases,
  List<TempExpensesClass>? expenses,
  bool canPickDate = true,
  bool canSeeCost = true,
  bool canOpenReceipts = true,
  bool canOpenPurchases = true,
  void Function(ReceiptsReportPeriod period)? onOpenReceipts,
  void Function(ReceiptsReportPeriod period)? onOpenPurchases,
}) {
  final r = receipts ?? sampleReceipts();
  final p = purchases ?? samplePurchases();
  final e = expenses ?? sampleExpenses();
  return GeneralReportEnv(
    canPickDate: () => canPickDate,
    canSeeCost: () => canSeeCost,
    canOpenReceipts: () => canOpenReceipts,
    canOpenPurchases: () => canOpenPurchases,
    receipts: () => r,
    legacySales: () => const [],
    purchases: () => p,
    pendingDeletedPurchaseUuids: () => const {},
    expenses: () => e,
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => money(v),
    openReceipts: (context, period) async {
      onOpenReceipts?.call(period);
    },
    openPurchases: (context, period) async {
      onOpenPurchases?.call(period);
    },
  );
}

/// What the page must show, from the Phase 1 logic.
GeneralReportFigures expectedFigures({
  List<TempMainReceipt>? receipts,
  List<TempExpensesClass>? expenses,
  ReceiptsReportPeriod? period,
  bool profitVisible = true,
}) {
  return GeneralReportFigures.build(
    receiptRows: receiptRowsOf(receipts ?? sampleReceipts()),
    purchaseRows: purchaseRowsOf(samplePurchases()),
    expenses: expenses ?? sampleExpenses(),
    period: period ?? day17,
    profitVisible: profitVisible,
  );
}

Future<void> pumpReport(
  WidgetTester tester, {
  required bool isDesktop,
  required GeneralReportEnv env,
  ReceiptsReportPeriod? period,
}) async {
  // Mobile below mobileScreen (650); not narrower, for the
  // test-font reason given in the purchase report tests.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1400) : const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: GeneralReportView(
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

Finder byKey(String key) => find.byKey(ValueKey(key));

String amountOf(WidgetTester tester, String card) =>
    tester.widget<Text>(byKey('general-card-$card-amount')).data!;

Future<void> tapCard(WidgetTester tester, String card) async {
  final finder = byKey('general-card-$card');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void expectSamePeriod(
  ReceiptsReportPeriod actual,
  ReceiptsReportPeriod expected,
) {
  expect(actual.start, expected.start);
  expect(actual.end, expected.end);
}

void main() {
  for (final isDesktop in [true, false]) {
    final width = isDesktop ? 'desktop' : 'mobile';

    testWidgets('sections show the report figures ($width)', (
      tester,
    ) async {
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(),
      );
      final f = expectedFigures();

      expect(byKey('general-section-money-in'), findsOneWidget);
      expect(byKey('general-section-money-out'), findsOneWidget);
      expect(byKey('general-section-profit'), findsOneWidget);

      expect(amountOf(tester, 'revenue'), money(f.totalRevenue));
      expect(
        amountOf(tester, 'gross-profit'),
        money(f.grossProfit!),
      );
      expect(
        amountOf(tester, 'purchases'),
        money(f.totalPurchases),
      );
      expect(
        amountOf(tester, 'expenses'),
        money(f.totalExpenses),
      );
      expect(
        amountOf(tester, 'profit-gross-profit'),
        money(f.grossProfit!),
      );
      expect(
        amountOf(tester, 'net-profit'),
        money(f.netProfit!),
      );
      // The sample day, worked out by hand.
      expect(amountOf(tester, 'revenue'), 'N720.0');
      expect(amountOf(tester, 'net-profit'), 'N235.0');

      // A day compares with the day before.
      final change =
          tester
              .widget<Text>(byKey('general-card-revenue-change'))
              .data!;
      expect(change, contains('▼'));
      expect(change, contains('%'));
      expect(change, contains('vs previous period'));

      expect(
        find.text(
          'Cost missing on 1 receipt: counted as 0 in gross '
          'profit.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          '1 receipt has no item data: left out of gross profit.',
        ),
        findsOneWidget,
      );
      for (final label in [
        'Revenue',
        'Gross profit',
        'Expenses',
        'Net profit',
      ]) {
        expect(
          find.descendant(
            of: byKey('general-trend'),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('profit hidden without Manage Cost Price ($width)', (
      tester,
    ) async {
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(canSeeCost: false),
      );
      final f = expectedFigures(profitVisible: false);

      expect(byKey('general-section-profit'), findsNothing);
      expect(byKey('general-card-gross-profit'), findsNothing);
      expect(byKey('general-card-net-profit'), findsNothing);
      expect(amountOf(tester, 'revenue'), money(f.totalRevenue));
      expect(
        amountOf(tester, 'purchases'),
        money(f.totalPurchases),
      );
      expect(
        amountOf(tester, 'expenses'),
        money(f.totalExpenses),
      );
      expect(find.textContaining('Cost missing'), findsNothing);
      expect(find.textContaining('no item data'), findsNothing);
      for (final label in ['Gross profit', 'Net profit']) {
        expect(
          find.descendant(
            of: byKey('general-trend'),
            matching: find.text(label),
          ),
          findsNothing,
        );
      }
      expect(
        find.descendant(
          of: byKey('general-trend'),
          matching: find.text('Revenue'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('revenue and gross profit open receipts ($width)', (
      tester,
    ) async {
      final opened = <ReceiptsReportPeriod>[];
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(onOpenReceipts: opened.add),
      );
      for (final card in [
        'revenue',
        'gross-profit',
        'profit-gross-profit',
      ]) {
        expect(byKey('general-card-$card-chevron'), findsOneWidget);
        await tapCard(tester, card);
      }
      expect(opened.length, 3);
      for (final p in opened) {
        expectSamePeriod(p, day17);
      }
    });

    testWidgets('purchases open the purchase table ($width)', (
      tester,
    ) async {
      final opened = <ReceiptsReportPeriod>[];
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(onOpenPurchases: opened.add),
      );
      expect(
        byKey('general-card-purchases-chevron'),
        findsOneWidget,
      );
      await tapCard(tester, 'purchases');
      expect(opened.length, 1);
      expectSamePeriod(opened.single, day17);
    });

    testWidgets('nothing opens without the permissions ($width)', (
      tester,
    ) async {
      final receipts = <ReceiptsReportPeriod>[];
      final purchases = <ReceiptsReportPeriod>[];
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(
          canOpenReceipts: false,
          canOpenPurchases: false,
          onOpenReceipts: receipts.add,
          onOpenPurchases: purchases.add,
        ),
      );
      for (final card in [
        'revenue',
        'gross-profit',
        'profit-gross-profit',
        'purchases',
      ]) {
        expect(byKey('general-card-$card-chevron'), findsNothing);
        expect(
          tester.widget<InkWell>(byKey('general-card-$card')).onTap,
          isNull,
        );
        await tapCard(tester, card);
      }
      expect(receipts, isEmpty);
      expect(purchases, isEmpty);
    });

    testWidgets('expenses and net profit never open ($width)', (
      tester,
    ) async {
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(),
      );
      for (final card in ['expenses', 'net-profit']) {
        expect(byKey('general-card-$card-chevron'), findsNothing);
        expect(
          tester.widget<InkWell>(byKey('general-card-$card')).onTap,
          isNull,
        );
      }
    });

    testWidgets('All time: note and no comparison ($width)', (
      tester,
    ) async {
      const allTime = ReceiptsReportPeriod.allTime();
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(),
        period: allTime,
      );
      expect(
        find.text('All time covers the data loaded on this device.'),
        findsOneWidget,
      );
      expect(find.textContaining('vs previous period'), findsNothing);
      expect(
        amountOf(tester, 'revenue'),
        money(expectedFigures(period: allTime).totalRevenue),
      );
    });

    testWidgets('a negative net profit is red ($width)', (
      tester,
    ) async {
      final expenses = [expense(amount: 400)];
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(expenses: expenses),
      );
      final net = expectedFigures(expenses: expenses).netProfit!;
      expect(net, -100);
      final text = tester.widget<Text>(
        byKey('general-card-net-profit-amount'),
      );
      expect(text.data, money(net));
      expect(text.style!.color, const Color(0xFFDC2626));

      final gross = tester.widget<Text>(
        byKey('general-card-profit-gross-profit-amount'),
      );
      expect(gross.style!.color, isNot(const Color(0xFFDC2626)));
    });

    testWidgets('without View Date the period is today ($width)', (
      tester,
    ) async {
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(canPickDate: false),
        period: day17,
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
        amountOf(tester, 'revenue'),
        money(
          expectedFigures(
            period: ReceiptsReportPeriod.today(),
          ).totalRevenue,
        ),
      );
    });

    testWidgets('back from a report rebuilds ($width)', (
      tester,
    ) async {
      final receipts = sampleReceipts();
      await pumpReport(
        tester,
        isDesktop: isDesktop,
        env: fakeGeneralEnv(
          receipts: receipts,
          // Stands in for a sale made while the report was open.
          onOpenReceipts:
              (_) => receipts.add(
                saleReceipt(uuid: 'r-0000000000099', cash: 80),
              ),
        ),
      );
      expect(amountOf(tester, 'revenue'), 'N720.0');

      await tapCard(tester, 'revenue');

      expect(amountOf(tester, 'revenue'), 'N800.0');
    });
  }
}
