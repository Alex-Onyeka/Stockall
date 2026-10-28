import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

import 'customer_report_fixtures.dart';

void main() {
  // Seven of each record for cust-1, one per day from the 11th to
  // the 17th, plus one of each for cust-2.
  final customer = testCustomer(balance: 40, cashReward: 6);
  final other = testCustomer(uuid: 'cust-2', name: 'Chidi');
  DateTime day(int d) => DateTime(2026, 10, d, 12);
  final receipts = [
    for (var d = 11; d <= 17; d++)
      testReceipt(uuid: 'r-$d', cash: d.toDouble(), createdAt: day(d)),
    testReceipt(uuid: 'r-other', customerUuid: 'cust-2', cash: 999),
  ];
  final invoices = [
    for (var d = 11; d <= 17; d++)
      testInvoice(uuid: 'i-$d', total: 10, createdAt: day(d)),
    testInvoice(uuid: 'i-other', customerUuid: 'cust-2'),
  ];
  final orders = [
    for (var d = 11; d <= 17; d++)
      customerOrder(uuid: 'o-$d', total: 5, createdAt: day(d)),
    customerOrder(uuid: 'o-other', customerId: 'cust-2'),
  ];
  final ledger = [
    for (var d = 11; d <= 17; d++) ...[
      ledgerEntry(
        uuid: 'rew-$d',
        isBalance: false,
        isAdd: d != 17,
        amount: 2,
        createdAt: day(d),
      ),
      ledgerEntry(uuid: 'acc-$d', isAdd: d.isOdd, amount: 3, createdAt: day(d)),
    ],
    ledgerEntry(uuid: 'acc-other', customerUuid: 'cust-2'),
  ];

  CustomerReportBase base({CustomerReportAccess? access}) => buildBase(
    customers: [customer, other],
    receipts: receipts,
    invoices: invoices,
    orders: orders,
    ledger: ledger,
    access: access,
  );

  CustomerAnalysis analysis({
    ReceiptsReportPeriod period = allTime,
    CustomerReportAccess? access,
  }) => CustomerAnalysis.build(
    customer: customer,
    slice: sliceOf(base(access: access), period: period),
  );

  group('KPIs', () {
    test('the same numbers as the customer table row', () {
      final b = base();
      final a = CustomerAnalysis.build(customer: customer, slice: sliceOf(b));
      final row = rowFor(b, 'cust-1');
      expect(a.summary.revenue, row.revenue);
      expect(a.summary.receiptPurchases, row.receiptPurchases);
      expect(a.summary.invoicePurchases, row.invoicePurchases);
      expect(a.summary.credit, row.credit);
      expect(a.summary.totalBalance, row.totalBalance);
      expect(a.summary.receiptCount, 7);
      expect(a.summary.invoiceCount, 7);
      expect(a.summary.orderCount, 7);
      expect(a.summary.firstPurchase, day(11));
      expect(a.summary.lastPurchase, day(17));
      expect(a.customerUuid, 'cust-1');
    });

    test('ledger totals cover the whole period', () {
      final a = analysis();
      expect(a.rewardTotals.count, 7);
      expect(a.rewardTotals.added, 12);
      expect(a.rewardTotals.deducted, 2);
      expect(a.rewardTotals.net, 10);
      expect(a.accountTotals.count, 7);
      // Odd days 11, 13, 15, 17 credit; 12, 14, 16 debit.
      expect(a.accountTotals.added, 12);
      expect(a.accountTotals.deducted, 9);
      expect(a.accountTotals.net, 3);
    });
  });

  group('Recent records', () {
    test('5 most recent of each, newest first', () {
      final a = analysis();
      final expected = [17, 16, 15, 14, 13];
      expect(a.recentReceipts.map((r) => r.uuid), expected.map((d) => 'r-$d'));
      expect(a.recentInvoices.map((r) => r.uuid), expected.map((d) => 'i-$d'));
      expect(a.recentOrders.map((r) => r.uuid), expected.map((d) => 'o-$d'));
      expect(a.recentRewards.map((r) => r.uuid), expected.map((d) => 'rew-$d'));
      expect(
        a.recentAccountTransactions.map((r) => r.uuid),
        expected.map((d) => 'acc-$d'),
      );
    });

    test('only records in the period', () {
      final a = analysis(
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 11),
          DateTime(2026, 10, 12),
        ),
      );
      expect(a.recentReceipts.map((r) => r.uuid), ['r-12', 'r-11']);
      expect(a.recentInvoices.map((r) => r.uuid), ['i-12', 'i-11']);
      expect(a.recentOrders.map((r) => r.uuid), ['o-12', 'o-11']);
      expect(a.recentRewards.length, 2);
      expect(a.recentAccountTransactions.length, 2);
      expect(a.summary.receiptCount, 2);
      expect(a.rewardTotals.count, 2);
    });

    test('fewer than 5 shows them all', () {
      final a = CustomerAnalysis.build(customer: other, slice: sliceOf(base()));
      expect(a.recentReceipts.map((r) => r.uuid), ['r-other']);
      expect(a.recentAccountTransactions.map((r) => r.uuid), ['acc-other']);
      expect(a.recentRewards, isEmpty);
    });
  });

  group('Sections follow the settings', () {
    test('reward off: no reward section, account stays', () {
      final a = analysis(access: testAccess(manageCustomerReward: false));
      expect(a.showReward, isFalse);
      expect(a.showAccount, isTrue);
      expect(a.recentRewards, isEmpty);
      expect(a.rewardTotals.count, 0);
      expect(a.recentAccountTransactions.length, 5);
    });

    test('account off: no account section, reward stays', () {
      final a = analysis(access: testAccess(manageCustomerAccount: false));
      expect(a.showAccount, isFalse);
      expect(a.recentAccountTransactions, isEmpty);
      expect(a.accountTotals.count, 0);
      expect(a.recentRewards.length, 5);
      expect(a.summary.totalBalance, 6);
    });

    test('no View Customers Account: neither', () {
      final a = analysis(access: testAccess(canViewCustomersAccount: false));
      expect(a.showAccount, isFalse);
      expect(a.showReward, isFalse);
      expect(a.recentRewards, isEmpty);
      expect(a.recentAccountTransactions, isEmpty);
      expect(a.summary.totalBalance, 0);
    });
  });

  group('See all', () {
    test('period as the invoice table takes it', () {
      expect(customerReportDateRange(allTime), isNull);
      final one =
          customerReportDateRange(
            ReceiptsReportPeriod.day(DateTime(2026, 10, 17, 15)),
          )!;
      expect(one.start, DateTime(2026, 10, 17));
      expect(one.end, DateTime(2026, 10, 17));
      final range =
          customerReportDateRange(
            ReceiptsReportPeriod.range(
              DateTime(2026, 10, 18),
              DateTime(2026, 10, 11),
            ),
          )!;
      expect(range.start, DateTime(2026, 10, 11));
      expect(range.end, DateTime(2026, 10, 18));
    });

    test('filters carry the customer only', () {
      final r = CustomerSeeAll.receiptsFilters('cust-1');
      expect(r.customerKey, 'cust-1');
      expect(r.activeCount, 1);
      final o = CustomerSeeAll.orderFilters('cust-1');
      expect(o.customerKey, 'cust-1');
      expect(o.activeCount, 1);
      final i = CustomerSeeAll.invoiceFilters('cust-1', allTime);
      expect(i.customerUuid, 'cust-1');
      expect(i.dateRange, isNull);
      expect(i.activeCount, 1);
    });

    test('each table shows exactly the customer\'s records', () {
      final period = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 13),
        DateTime(2026, 10, 16),
      );
      final b = base();
      final a = CustomerAnalysis.build(
        customer: customer,
        slice: sliceOf(b, period: period),
      );

      final receiptRows = ReceiptsReportQuery.filterAndSort(
        rows: ReceiptsReportRowBuilder.buildAll(
          receipts: receipts,
          legacySales: const [],
        ),
        period: period,
        filters: CustomerSeeAll.receiptsFilters('cust-1'),
        sortField: ReceiptsSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
      );
      expect(receiptRows.length, a.summary.receiptCount);
      expect(
        receiptRows.take(5).map((r) => r.uuid),
        a.recentReceipts.map((r) => r.uuid),
      );

      final invoiceRows = InvoiceReportQuery.filterAndSort(
        rows: InvoiceReportRowBuilder.buildAll(
          invoices: invoices,
          allReceipts: receipts,
          allProductSales: const [],
          customerMap: const {},
        ),
        filters: CustomerSeeAll.invoiceFilters('cust-1', period),
        sortField: InvoiceSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        bulkSaleEnabled: true,
        costFilterAllowed: true,
      );
      expect(invoiceRows.length, a.summary.invoiceCount);
      expect(
        invoiceRows.take(5).map((r) => r.uuid),
        a.recentInvoices.map((r) => r.uuid),
      );

      final orderRows = OrderReportQuery.filterAndSort(
        rows: OrderReportRowBuilder.buildAll(
          orders: orders,
          allReceipts: receipts,
        ),
        period: period,
        filters: CustomerSeeAll.orderFilters('cust-1'),
        sortField: OrderSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
      );
      expect(orderRows.length, a.summary.orderCount);
      expect(
        orderRows.take(5).map((r) => r.uuid),
        a.recentOrders.map((r) => r.uuid),
      );
      expect(a.summary.receiptCount, 4);
    });
  });

  group('Analysis screen', () {
    // Money shows as 'N<value>' (fakeCustomerEnv). The lists are
    // copied so a test can add to them.
    final range = ReceiptsReportPeriod.range(
      DateTime(2026, 10, 13),
      DateTime(2026, 10, 16),
    );
    final day17Period = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

    CustomerReportEnv env({
      CustomerReportAccess? access,
      CustomerEnvLog? log,
      List<TempMainReceipt>? receiptList,
      List<Orders>? orderList,
      VoidCallback? onOpen,
    }) => fakeCustomerEnv(
      customers: [customer, other],
      receipts: receiptList ?? [...receipts],
      invoices: [...invoices],
      orders: orderList ?? [...orders],
      ledger: [...ledger],
      access: access,
      log: log,
      onOpen: onOpen,
    );

    Finder kpi(String id, String value) => find.descendant(
      of: find.byKey(ValueKey('customer-kpi-$id')),
      matching: find.text(value),
    );

    Finder inSection(String id, Finder f) => find.descendant(
      of: find.byKey(ValueKey('customer-section-$id')),
      matching: f,
    );

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      for (final p in {'one day': day17Period, 'a range': range}.entries) {
        testWidgets('KPIs equal the table row, ${p.key} ($width)', (
          tester,
        ) async {
          await pumpCustomerAnalysis(
            tester,
            isDesktop: isDesktop,
            env: env(),
            customer: customer,
            period: p.value,
          );
          final row = rowFor(base(), 'cust-1', period: p.value);
          final expected = <String, String>{
            'receipt-purchases': 'N${row.receiptPurchases}',
            'invoice-purchases': 'N${row.invoicePurchases}',
            'revenue': 'N${row.revenue}',
            'credit': 'N${row.credit}',
            'account-balance': 'N${row.accountBalance}',
            'reward-earnings': 'N${row.rewardEarnings}',
            'total-balance': 'N${row.totalBalance}',
            'receipts': '${row.receiptCount}',
            'invoices': '${row.invoiceCount}',
            'orders': '${row.orderCount}',
            'order-total': 'N${row.orderTotal}',
            'order-paid': 'N${row.orderPaid}',
            'order-balance': 'N${row.orderBalance}',
            'first-purchase': formatDateTime(row.firstPurchase!),
            'last-purchase': formatDateTime(row.lastPurchase!),
          };
          for (final e in expected.entries) {
            expect(kpi(e.key, e.value), findsOneWidget, reason: e.key);
          }
          expect(find.text('Bola'), findsWidgets);
        });
      }

      testWidgets('See all opens each table on the customer and period '
          '($width)', (tester) async {
        final log = CustomerEnvLog();
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
          customer: customer,
          period: range,
        );
        Future<void> seeAll(String id) async {
          await tester.tap(find.byKey(ValueKey('customer-see-all-$id')));
          await tester.pumpAndSettle();
        }

        await seeAll('receipts');
        expect(log.receiptsFilters!.customerKey, 'cust-1');
        expect(log.receiptsFilters!.activeCount, 1);
        expect(log.receiptsPeriod!.start, range.start);
        expect(log.receiptsPeriod!.end, range.end);

        await seeAll('invoices');
        expect(log.invoiceFilters!.customerUuid, 'cust-1');
        expect(log.invoiceFilters!.dateRange!.start, range.start);
        expect(log.invoiceFilters!.dateRange!.end, range.end);

        await seeAll('orders');
        expect(log.orderFilters!.customerKey, 'cust-1');
        expect(log.orderPeriod!.start, range.start);
        expect(log.orderPeriod!.end, range.end);

        await seeAll('rewards');
        await seeAll('account');
        expect(log.ledgerTables.map((t) => t.$2), [
          CustomerLedgerKind.reward,
          CustomerLedgerKind.account,
        ]);
        for (final t in log.ledgerTables) {
          expect(t.$1.uuid, 'cust-1');
          expect(t.$3.start, range.start);
          expect(t.$3.end, range.end);
        }
        expect(log.calls, [
          'receiptsTable',
          'invoiceTable',
          'orderTable',
          'ledgerTable',
          'ledgerTable',
        ]);
      });

      testWidgets('All time: the invoice table gets no date range '
          '($width)', (tester) async {
        final log = CustomerEnvLog();
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
          customer: customer,
        );
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const ValueKey('customer-see-all-invoices')),
        );
        await tester.pumpAndSettle();
        expect(log.invoiceFilters!.customerUuid, 'cust-1');
        expect(log.invoiceFilters!.dateRange, isNull);
        await tester.tap(
          find.byKey(const ValueKey('customer-see-all-receipts')),
        );
        await tester.pumpAndSettle();
        expect(log.receiptsPeriod!.isAllTime, isTrue);
      });

      final gating = <String, (CustomerReportAccess, bool, bool)>{
        'account off': (testAccess(manageCustomerAccount: false), false, true),
        'reward off': (testAccess(manageCustomerReward: false), true, false),
        'no View Customers Account': (
          testAccess(canViewCustomersAccount: false),
          false,
          false,
        ),
      };
      for (final g in gating.entries) {
        final (access, account, reward) = g.value;
        testWidgets('ledger KPIs and sections, ${g.key} ($width)', (
          tester,
        ) async {
          await pumpCustomerAnalysis(
            tester,
            isDesktop: isDesktop,
            env: env(access: access),
            customer: customer,
          );
          Matcher shown(bool v) => v ? findsOneWidget : findsNothing;
          expect(
            find.byKey(const ValueKey('customer-kpi-account-balance')),
            shown(account),
          );
          expect(
            find.byKey(const ValueKey('customer-section-account')),
            shown(account),
          );
          expect(
            find.byKey(const ValueKey('customer-kpi-reward-earnings')),
            shown(reward),
          );
          expect(
            find.byKey(const ValueKey('customer-section-rewards')),
            shown(reward),
          );
          expect(
            find.byKey(const ValueKey('customer-kpi-total-balance')),
            shown(account || reward),
          );
          expect(
            find.byKey(const ValueKey('customer-section-receipts')),
            findsOneWidget,
          );
        });
      }

      testWidgets('only the 5 most recent of each ($width)', (tester) async {
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(),
          customer: customer,
        );
        for (final kind in [
          ('receipt', 'r', 'receipts'),
          ('invoice', 'i', 'invoices'),
          ('order', 'o', 'orders'),
          ('reward', 'rew', 'rewards'),
          ('account', 'acc', 'account'),
        ]) {
          for (var d = 11; d <= 17; d++) {
            expect(
              find.byKey(ValueKey('customer-${kind.$1}-${kind.$2}-$d')),
              d >= 13 ? findsOneWidget : findsNothing,
              reason: '${kind.$1} $d',
            );
          }
          expect(
            inSection(kind.$3, find.text('7 in this period')),
            findsOneWidget,
          );
        }
      });

      testWidgets('an empty section has no See all ($width)', (tester) async {
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(orderList: []),
          customer: customer,
        );
        expect(
          inSection('orders', find.text('No orders in this period.')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('customer-see-all-orders')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('customer-see-all-receipts')),
          findsOneWidget,
        );
      });

      testWidgets('tapping a record opens it ($width)', (tester) async {
        final log = CustomerEnvLog();
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
          customer: customer,
        );
        for (final key in [
          'customer-receipt-r-17',
          'customer-invoice-i-17',
          'customer-order-o-17',
          'customer-reward-rew-17',
          'customer-account-acc-17',
        ]) {
          await tester.tap(find.byKey(ValueKey(key)));
          await tester.pumpAndSettle();
        }
        expect(log.calls, [
          'receipt',
          'invoice',
          'order',
          'ledgerEntry',
          'ledgerEntry',
        ]);
        expect((log.records[0] as TempMainReceipt).uuid, 'r-17');
        expect((log.records[1] as TempInvoice).uuid, 'i-17');
        expect((log.records[2] as Orders).uuid, 'o-17');
        expect((log.records[3] as CustomerAccountReceipts).uuid, 'rew-17');
        expect((log.records[4] as CustomerAccountReceipts).uuid, 'acc-17');
      });

      testWidgets('back from a record rebuilds the analysis ($width)', (
        tester,
      ) async {
        final list = [...receipts];
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(
            receiptList: list,
            onOpen:
                () => list.add(
                  testReceipt(uuid: 'r-new', cash: 100, createdAt: day(17)),
                ),
          ),
          customer: customer,
        );
        // 11 + 12 + ... + 17.
        expect(kpi('revenue', 'N98.0'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('customer-receipt-r-17')));
        await tester.pumpAndSettle();

        expect(kpi('revenue', 'N198.0'), findsOneWidget);
        expect(kpi('receipts', '8'), findsOneWidget);
      });

      testWidgets('without View Date the period is today ($width)', (
        tester,
      ) async {
        await pumpCustomerAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(access: testAccess(canPickDate: false)),
          customer: customer,
        );
        expect(
          find.text(
            'Date: ${receiptsPeriodLabel(ReceiptsReportPeriod.today())}',
          ),
          findsOneWidget,
        );
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsNothing,
        );
        expect(
          tester
              .widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>))
              .enabled,
          isFalse,
        );
      });
    }
  });
}
