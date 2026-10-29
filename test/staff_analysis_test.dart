import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/components/staff_expenses_view.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';

import 'staff_report_fixtures.dart';

DateTime day(int d, [int hour = 12]) => DateTime(2026, 10, d, hour);

// Seven of each record for staff-a on Oct 10-16 (uuid suffix is
// the day), one of each for staff-b, one receipt for former
// staff-x. Fresh lists on every call, so a test can add to them.
final busyDays = [for (var d = 10; d <= 16; d++) d];

List<TempUserClass> busyStaff() => [
  testUser(email: 'ada@shop.ng'),
  testUser(userId: 'staff-b', name: 'Bayo', role: 'Manager', phone: null),
];

List<TempMainReceipt> busyReceipts() => [
  for (final d in busyDays)
    testReceipt(uuid: 'r-$d', cash: d.toDouble(), createdAt: day(d)),
  testReceipt(uuid: 'r-b', cash: 1, staffId: 'staff-b', createdAt: day(20)),
  testReceipt(
    uuid: 'r-x',
    cash: 3,
    staffId: 'staff-x',
    createdAt: day(12),
  )..staffName = 'Xena',
];

List<TempInvoice> busyInvoices() => [
  for (final d in busyDays)
    testInvoice(uuid: 'i-$d', total: d.toDouble(), createdAt: day(d)),
  testInvoice(uuid: 'i-b', total: 1, staffId: 'staff-b', createdAt: day(20)),
];

List<Orders> busyOrders() => [
  for (final d in busyDays)
    staffOrder(uuid: 'o-$d', total: d.toDouble(), createdAt: day(d)),
  staffOrder(uuid: 'o-b', staffId: 'staff-b', createdAt: day(20)),
];

List<TempPurchase> busyPurchases() => [
  for (final d in busyDays)
    purchase(uuid: 'pu-$d', total: d.toDouble(), createdAt: day(d)),
  purchase(uuid: 'pu-b', staffId: 'staff-b', createdAt: day(20)),
];

List<TempExpensesClass> busyExpenses() => [
  for (final d in busyDays)
    testExpense(uuid: 'e-$d', amount: d.toDouble(), createdAt: day(d)),
  testExpense(uuid: 'e-b', userId: 'staff-b', createdAt: day(20)),
];

StaffReportBase busyBase({StaffReportAccess? access}) => buildStaffBase(
  staff: busyStaff(),
  receipts: busyReceipts(),
  invoices: busyInvoices(),
  orders: busyOrders(),
  purchases: busyPurchases(),
  expenses: busyExpenses(),
  access: access,
);

StaffAnalysis analysisOf(
  StaffReportBase base,
  String staffKey, {
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
}) => StaffAnalysis.build(
  staffKey: staffKey,
  slice: staffSlice(base, period: period),
);

const newestFive = ['16', '15', '14', '13', '12'];

List<String> suffixes(Iterable<String> uuids) =>
    uuids.map((u) => u.split('-').last).toList();

void main() {
  group('KPIs are the table row', () {
    final periods = <String, ReceiptsReportPeriod>{
      'all time': allTime,
      'one day': ReceiptsReportPeriod.day(DateTime(2026, 10, 12)),
      'a range': ReceiptsReportPeriod.range(
        DateTime(2026, 10, 11),
        DateTime(2026, 10, 14),
      ),
      'an empty day': ReceiptsReportPeriod.day(DateTime(2026, 9, 1)),
    };
    for (final p in periods.entries) {
      test(p.key, () {
        final base = busyBase();
        final rows = staffRows(base, period: p.value);
        for (final row in rows) {
          final s = analysisOf(base, row.key, period: p.value).summary;
          expect(s.key, row.key);
          expect(s.name, row.name);
          expect(s.roleLabel, row.roleLabel);
          expect(s.receiptSales, row.receiptSales);
          expect(s.receiptCount, row.receiptCount);
          expect(s.invoiceSales, row.invoiceSales);
          expect(s.invoiceCount, row.invoiceCount);
          expect(s.orderTotal, row.orderTotal);
          expect(s.orderCount, row.orderCount);
          expect(s.purchaseTotal, row.purchaseTotal);
          expect(s.purchaseCount, row.purchaseCount);
          expect(s.expenseTotal, row.expenseTotal);
          expect(s.expenseCount, row.expenseCount);
          expect(s.firstActivity, row.firstActivity);
          expect(s.lastActivity, row.lastActivity);
        }
      });
    }

    test('counts and first / last activity', () {
      final s = analysisOf(busyBase(), 'staff-a').summary;
      expect(s.receiptCount, 7);
      expect(s.invoiceCount, 7);
      expect(s.orderCount, 7);
      expect(s.purchaseCount, 7);
      expect(s.expenseCount, 7);
      expect(s.receiptSales, 91);
      expect(s.firstActivity, day(10));
      expect(s.lastActivity, day(16));
    });

    test('a former staff', () {
      final a = analysisOf(busyBase(), 'staff-x');
      expect(a.summary.isFormer, isTrue);
      expect(a.summary.name, 'Xena');
      expect(a.recentReceipts.map((r) => r.uuid), ['r-x']);
      expect(a.recentInvoices, isEmpty);
    });

    test('a staff with nothing in the period', () {
      final a = analysisOf(
        busyBase(),
        'staff-b',
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 12)),
      );
      expect(a.summary.activityCount, 0);
      expect(a.recentReceipts, isEmpty);
      expect(a.recentExpenses, isEmpty);
    });
  });

  group('Sections: the 5 most recent', () {
    final a = analysisOf(busyBase(), 'staff-a');

    test('newest first, at most 5, the staff own only', () {
      expect(staffAnalysisRecentCount, 5);
      expect(suffixes(a.recentReceipts.map((r) => r.uuid)), newestFive);
      expect(
        suffixes(a.recentInvoices.map((r) => r.invoice.uuid!)),
        newestFive,
      );
      expect(suffixes(a.recentOrders.map((r) => r.uuid)), newestFive);
      expect(suffixes(a.recentPurchases.map((r) => r.uuid)), newestFive);
      expect(suffixes(a.recentExpenses.map((r) => r.uuid)), newestFive);
    });

    test('the period applies to every section', () {
      final p = analysisOf(
        busyBase(),
        'staff-a',
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 10),
          DateTime(2026, 10, 12),
        ),
      );
      const inRange = ['12', '11', '10'];
      expect(suffixes(p.recentReceipts.map((r) => r.uuid)), inRange);
      expect(suffixes(p.recentInvoices.map((r) => r.invoice.uuid!)), inRange);
      expect(suffixes(p.recentOrders.map((r) => r.uuid)), inRange);
      expect(suffixes(p.recentPurchases.map((r) => r.uuid)), inRange);
      expect(suffixes(p.recentExpenses.map((r) => r.uuid)), inRange);
    });

    test('fewer than 5: all of them', () {
      final b = analysisOf(busyBase(), 'staff-b');
      expect(b.recentReceipts.map((r) => r.uuid), ['r-b']);
      expect(b.recentPurchases.map((r) => r.uuid), ['pu-b']);
      expect(b.recentExpenses.map((r) => r.uuid), ['e-b']);
    });
  });

  group('Section gates', () {
    test('everything shown by default', () {
      final a = analysisOf(busyBase(), 'staff-a');
      expect(a.showOrders, isTrue);
      expect(a.showPurchases, isTrue);
      expect(a.showExpenses, isTrue);
    });

    test('orders hidden', () {
      final a = analysisOf(
        busyBase(access: staffAccess(showOrders: false)),
        'staff-a',
      );
      expect(a.showOrders, isFalse);
      expect(a.recentOrders, isEmpty);
      expect(a.summary.orderCount, 0);
      expect(a.recentReceipts, isNotEmpty);
    });

    test('purchases hidden', () {
      final a = analysisOf(
        busyBase(access: staffAccess(showPurchases: false)),
        'staff-a',
      );
      expect(a.showPurchases, isFalse);
      expect(a.recentPurchases, isEmpty);
      expect(a.summary.purchaseTotal, 0);
    });

    test('expenses hidden', () {
      final a = analysisOf(
        busyBase(access: staffAccess(showExpenses: false)),
        'staff-a',
      );
      expect(a.showExpenses, isFalse);
      expect(a.recentExpenses, isEmpty);
      expect(a.summary.expenseTotal, 0);
    });

    test('receipts and invoices are always shown', () {
      final a = analysisOf(
        busyBase(
          access: staffAccess(
            showOrders: false,
            showPurchases: false,
            showExpenses: false,
          ),
        ),
        'staff-a',
      );
      expect(a.recentReceipts.length, 5);
      expect(a.recentInvoices.length, 5);
    });
  });

  group('See all', () {
    test('filters name the staff and nothing else', () {
      final r = StaffSeeAll.receiptsFilters('staff-a');
      expect(r.staffKey, 'staff-a');
      expect(r.customerKey, isNull);
      expect(r.subStaffKey, isNull);
      expect(r.departmentKey, isNull);
      expect(r.type, isNull);

      final i = StaffSeeAll.invoiceFilters('staff-a', allTime);
      expect(i.staffId, 'staff-a');
      expect(i.customerUuid, isNull);
      expect(i.subStaffUuid, isNull);

      final o = StaffSeeAll.orderFilters('staff-a');
      expect(o.staffKey, 'staff-a');
      expect(o.customerKey, isNull);

      final p = StaffSeeAll.purchaseFilters('staff-a');
      expect(p.staffKey, 'staff-a');
      expect(p.supplierKey, isNull);
    });

    test('the invoice table gets the period as its date range', () {
      expect(StaffSeeAll.invoiceFilters('staff-a', allTime).dateRange, isNull);

      final one = StaffSeeAll.invoiceFilters(
        'staff-a',
        ReceiptsReportPeriod.day(DateTime(2026, 10, 12, 15)),
      ).dateRange!;
      expect(one.start, DateTime(2026, 10, 12));
      expect(one.end, DateTime(2026, 10, 12));

      final range = StaffSeeAll.invoiceFilters(
        'staff-a',
        ReceiptsReportPeriod.range(
          DateTime(2026, 10, 14),
          DateTime(2026, 10, 11),
        ),
      ).dateRange!;
      expect(range.start, DateTime(2026, 10, 11));
      expect(range.end, DateTime(2026, 10, 14));
    });

    test('each table, filtered, lists the section from the top', () {
      final base = busyBase();
      final period = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 15),
      );
      final a = analysisOf(base, 'staff-a', period: period);

      final receipts = ReceiptsReportQuery.filterAndSort(
        rows: base.receiptRows,
        period: period,
        filters: StaffSeeAll.receiptsFilters('staff-a'),
        sortField: ReceiptsSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
      );
      expect(receipts.length, a.summary.receiptCount);
      expect(
        receipts.take(5).map((r) => r.uuid),
        a.recentReceipts.map((r) => r.uuid),
      );

      final invoices = InvoiceReportQuery.filterAndSort(
        rows: base.invoiceRows,
        filters: StaffSeeAll.invoiceFilters('staff-a', period),
        sortField: InvoiceSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        bulkSaleEnabled: true,
        costFilterAllowed: true,
      );
      expect(invoices.length, a.summary.invoiceCount);
      expect(
        invoices.take(5).map((r) => r.invoice.uuid),
        a.recentInvoices.map((r) => r.invoice.uuid),
      );

      final orders = OrderReportQuery.filterAndSort(
        rows: base.orderRows,
        period: period,
        filters: StaffSeeAll.orderFilters('staff-a'),
        sortField: OrderSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
      );
      expect(orders.length, a.summary.orderCount);
      expect(
        orders.take(5).map((r) => r.uuid),
        a.recentOrders.map((r) => r.uuid),
      );

      final purchases = PurchaseReportQuery.filterAndSort(
        rows: base.purchaseRows,
        period: period,
        filters: StaffSeeAll.purchaseFilters('staff-a'),
        sortField: PurchasesSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
      );
      expect(purchases.length, a.summary.purchaseCount);
      expect(
        purchases.take(5).map((r) => r.uuid),
        a.recentPurchases.map((r) => r.uuid),
      );
    });
  });

  group('Analysis screen', () {
    // Money shows as 'N<value>' (fakeStaffEnv).
    final range = ReceiptsReportPeriod.range(
      DateTime(2026, 10, 11),
      DateTime(2026, 10, 14),
    );
    final day12 = ReceiptsReportPeriod.day(DateTime(2026, 10, 12));

    StaffReportEnv env({
      StaffReportAccess? access,
      StaffEnvLog? log,
      List<TempMainReceipt>? receiptList,
      List<Orders>? orderList,
      VoidCallback? onOpen,
    }) => fakeStaffEnv(
      staff: busyStaff(),
      receipts: receiptList ?? busyReceipts(),
      invoices: busyInvoices(),
      orders: orderList ?? busyOrders(),
      purchases: busyPurchases(),
      expenses: busyExpenses(),
      access: access,
      log: log,
      onOpen: onOpen,
    );

    Finder kpi(String id, String text) => find.descendant(
      of: find.byKey(ValueKey('staff-kpi-$id')),
      matching: find.text(text),
    );

    Finder inSection(String id, Finder f) => find.descendant(
      of: find.byKey(ValueKey('staff-section-$id')),
      matching: f,
    );

    Finder inHeader(String id, String text) => find.descendant(
      of: find.byKey(ValueKey('staff-header-$id')),
      matching: find.text(text),
    );

    String count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      for (final p in {'one day': day12, 'a range': range}.entries) {
        testWidgets('KPIs equal the table row, ${p.key} ($width)', (
          tester,
        ) async {
          await pumpStaffAnalysis(
            tester,
            isDesktop: isDesktop,
            env: env(),
            period: p.value,
          );
          final row = staffRowFor(busyBase(), 'staff-a', period: p.value);
          final expected = <String, List<String>>{
            'receipt-sales': [
              'N${row.receiptSales}',
              count(row.receiptCount, 'receipt'),
            ],
            'invoice-sales': [
              'N${row.invoiceSales}',
              count(row.invoiceCount, 'invoice'),
            ],
            'orders': ['N${row.orderTotal}', count(row.orderCount, 'order')],
            'purchases': [
              'N${row.purchaseTotal}',
              count(row.purchaseCount, 'purchase'),
            ],
            'expenses': [
              'N${row.expenseTotal}',
              count(row.expenseCount, 'expense'),
            ],
            'first-activity': [formatDateTime(row.firstActivity!)],
            'last-activity': [formatDateTime(row.lastActivity!)],
          };
          for (final e in expected.entries) {
            for (final text in e.value) {
              expect(kpi(e.key, text), findsOneWidget, reason: e.key);
            }
          }
        });
      }

      testWidgets('header: name, role, phone and email ($width)', (
        tester,
      ) async {
        await pumpStaffAnalysis(tester, isDesktop: isDesktop, env: env());
        expect(find.text('Ada'), findsWidgets);
        expect(inHeader('role', 'Cashier'), findsOneWidget);
        expect(inHeader('phone', '0801'), findsOneWidget);
        expect(inHeader('email', 'ada@shop.ng'), findsOneWidget);
        expect(find.byKey(const ValueKey('staff-former-badge')), findsNothing);
      });

      testWidgets('header: blanks are a dash ($width)', (tester) async {
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(),
          staffKey: 'staff-b',
        );
        expect(inHeader('role', 'Manager'), findsOneWidget);
        expect(inHeader('phone', '—'), findsOneWidget);
        expect(inHeader('email', '—'), findsOneWidget);
      });

      testWidgets('former staff header ($width)', (tester) async {
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(),
          staffKey: 'staff-x',
        );
        expect(find.text('Xena'), findsWidgets);
        expect(
          find.byKey(const ValueKey('staff-former-badge')),
          findsOneWidget,
        );
        expect(find.text(staffReportFormerRoleLabel), findsOneWidget);
        expect(inHeader('role', '—'), findsOneWidget);
        expect(kpi('receipt-sales', 'N3.0'), findsOneWidget);
      });

      testWidgets('See all opens each table on the staff and period '
          '($width)', (tester) async {
        final log = StaffEnvLog();
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
          period: range,
        );
        Future<void> seeAll(String id) async {
          await tester.tap(find.byKey(ValueKey('staff-see-all-$id')));
          await tester.pumpAndSettle();
        }

        await seeAll('receipts');
        expect(log.receiptsFilters!.staffKey, 'staff-a');
        expect(log.receiptsFilters!.activeCount, 1);
        expect(log.receiptsPeriod!.start, range.start);
        expect(log.receiptsPeriod!.end, range.end);

        await seeAll('invoices');
        expect(log.invoiceFilters!.staffId, 'staff-a');
        expect(log.invoiceFilters!.customerUuid, isNull);
        expect(log.invoiceFilters!.dateRange!.start, range.start);
        expect(log.invoiceFilters!.dateRange!.end, range.end);

        await seeAll('orders');
        expect(log.orderFilters!.staffKey, 'staff-a');
        expect(log.orderPeriod!.start, range.start);
        expect(log.orderPeriod!.end, range.end);

        await seeAll('purchases');
        expect(log.purchaseFilters!.staffKey, 'staff-a');
        expect(log.purchasePeriod!.start, range.start);
        expect(log.purchasePeriod!.end, range.end);

        await seeAll('expenses');
        expect(log.expensesStaffKey, 'staff-a');
        expect(log.expensesPeriod!.start, range.start);
        expect(log.expensesPeriod!.end, range.end);

        expect(log.calls, [
          'receiptsTable',
          'invoiceTable',
          'orderTable',
          'purchaseTable',
          'expensesTable',
        ]);
      });

      testWidgets('All time: the invoice table gets no date range '
          '($width)', (tester) async {
        final log = StaffEnvLog();
        await pumpStaffAnalysis(tester, isDesktop: isDesktop, env: env(log: log));
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('staff-see-all-invoices')));
        await tester.pumpAndSettle();
        expect(log.invoiceFilters!.staffId, 'staff-a');
        expect(log.invoiceFilters!.dateRange, isNull);
        await tester.tap(find.byKey(const ValueKey('staff-see-all-receipts')));
        await tester.pumpAndSettle();
        expect(log.receiptsPeriod!.isAllTime, isTrue);
      });

      final gates = <String, (StaffReportAccess, String)>{
        'orders': (staffAccess(showOrders: false), 'orders'),
        'purchases': (staffAccess(showPurchases: false), 'purchases'),
        'expenses': (staffAccess(showExpenses: false), 'expenses'),
      };
      for (final g in gates.entries) {
        testWidgets('${g.key} hidden by access ($width)', (tester) async {
          final (access, hidden) = g.value;
          await pumpStaffAnalysis(
            tester,
            isDesktop: isDesktop,
            env: env(access: access),
          );
          for (final id in ['orders', 'purchases', 'expenses']) {
            final shown = id == hidden ? findsNothing : findsOneWidget;
            expect(find.byKey(ValueKey('staff-kpi-$id')), shown, reason: id);
            expect(
              find.byKey(ValueKey('staff-section-$id')),
              shown,
              reason: id,
            );
          }
          for (final id in ['receipts', 'invoices']) {
            expect(find.byKey(ValueKey('staff-section-$id')), findsOneWidget);
          }
        });
      }

      testWidgets('only the 5 most recent of each ($width)', (tester) async {
        await pumpStaffAnalysis(tester, isDesktop: isDesktop, env: env());
        for (final kind in [
          ('receipt', 'r', 'receipts'),
          ('invoice', 'i', 'invoices'),
          ('order', 'o', 'orders'),
          ('purchase', 'pu', 'purchases'),
          ('expense', 'e', 'expenses'),
        ]) {
          for (final d in busyDays) {
            expect(
              find.byKey(ValueKey('staff-${kind.$1}-${kind.$2}-$d')),
              d >= 12 ? findsOneWidget : findsNothing,
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
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(orderList: []),
        );
        expect(
          inSection('orders', find.text('No orders in this period.')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-see-all-orders')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('staff-see-all-receipts')),
          findsOneWidget,
        );
      });

      testWidgets('tapping a record opens it ($width)', (tester) async {
        final log = StaffEnvLog();
        await pumpStaffAnalysis(tester, isDesktop: isDesktop, env: env(log: log));
        for (final key in [
          'staff-receipt-r-16',
          'staff-invoice-i-16',
          'staff-order-o-16',
          'staff-purchase-pu-16',
          'staff-expense-e-16',
        ]) {
          await tester.tap(find.byKey(ValueKey(key)));
          await tester.pumpAndSettle();
        }
        expect(log.calls, [
          'receipt',
          'invoice',
          'order',
          'purchase',
          'expense',
        ]);
        expect((log.records[0] as TempMainReceipt).uuid, 'r-16');
        expect((log.records[1] as TempInvoice).uuid, 'i-16');
        expect((log.records[2] as Orders).uuid, 'o-16');
        expect((log.records[3] as TempPurchase).uuid, 'pu-16');
        expect((log.records[4] as TempExpensesClass).uuid, 'e-16');
      });

      testWidgets('back from a record rebuilds the analysis ($width)', (
        tester,
      ) async {
        final list = busyReceipts();
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(
            receiptList: list,
            onOpen:
                () => list.add(
                  testReceipt(uuid: 'r-new', cash: 100, createdAt: day(16)),
                ),
          ),
        );
        // 10 + 11 + ... + 16.
        expect(kpi('receipt-sales', 'N91.0'), findsOneWidget);
        expect(kpi('receipt-sales', '7 receipts'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('staff-receipt-r-16')));
        await tester.pumpAndSettle();

        expect(kpi('receipt-sales', 'N191.0'), findsOneWidget);
        expect(kpi('receipt-sales', '8 receipts'), findsOneWidget);
      });

      testWidgets('without View Date the period is today ($width)', (
        tester,
      ) async {
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: env(access: staffAccess(canPickDate: false)),
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

      testWidgets('See all opens the real Staff Expenses table ($width)', (
        tester,
      ) async {
        final log = StaffEnvLog();
        await pumpStaffAnalysis(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            staff: busyStaff(),
            expenses: busyExpenses(),
            log: log,
            pushExpensesTable: true,
          ),
          period: range,
        );
        final row = staffRowFor(busyBase(), 'staff-a', period: range);
        // 11 + 12 + 13 + 14.
        expect(row.expenseTotal, 50);
        expect(kpi('expenses', 'N50.0'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('staff-see-all-expenses')));
        await tester.pumpAndSettle();

        expect(log.calls, ['expensesTable']);
        expect(find.byType(StaffExpensesView), findsOneWidget);
        expect(find.text('Ada: Expenses'), findsOneWidget);
        // The analysis period: e-11 to e-14, totals as the KPI.
        for (final d in busyDays) {
          expect(
            find.text('N${d.toDouble()}'),
            d >= 11 && d <= 14 ? findsOneWidget : findsNothing,
            reason: 'e-$d',
          );
        }
        expect(find.text('N50.0'), findsOneWidget);
        expect(find.text('4 expenses'), findsOneWidget);

        // The app bar's own back button (constants/app_bar.dart).
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(StaffExpensesView), findsNothing);
        expect(kpi('expenses', 'N50.0'), findsOneWidget);
      });
    }
  });
}
