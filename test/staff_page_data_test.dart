import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_data.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';

import 'item_history_export_fixtures.dart' show testCtx;
import 'purchase_report_fixtures.dart' show uuidN;
import 'staff_report_fixtures.dart';

// The staff page's data: today's business day of one staff, as the
// Staff Report shows it on Today filtered to that staff.

const closing = TimeOfDay(hour: 4, minute: 0);

/// 03:45 on the 18th is still the 17th's business day.
final beforeClose = DateTime(2026, 10, 18, 3, 45);
final afterClose = DateTime(2026, 10, 18, 4, 30);
final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
final day18 = ReceiptsReportPeriod.day(DateTime(2026, 10, 18));

final staff = [
  testUser(name: 'Ada', email: 'ada@example.com'),
  testUser(userId: 'staff-b', name: 'Bayo'),
];

/// Ada on the 17th's business day: 7 receipts (6 in the day, one at
/// 03:30 on the 18th, before closing), an invoice, an order, a
/// purchase and an expense. Outside it: records after closing on
/// the 18th and on older days, and Bayo's receipt.
List<TempMainReceipt> receipts() => [
  for (var i = 1; i <= 6; i++)
    testReceipt(
      uuid: 'r-100000000000$i',
      cash: 100.0 * i,
      createdAt: DateTime(2026, 10, 17, 10 + i),
    ),
  testReceipt(
    uuid: 'r-1000000000007',
    cash: 1,
    createdAt: DateTime(2026, 10, 18, 3, 30),
  ),
  testReceipt(
    uuid: 'r-1000000000008',
    cash: 1000,
    createdAt: DateTime(2026, 10, 18, 4, 30),
  ),
  testReceipt(
    uuid: 'r-1000000000009',
    cash: 5000,
    createdAt: DateTime(2026, 10, 10, 12),
  ),
  testReceipt(
    uuid: 'r-1000000000010',
    cash: 7,
    staffId: 'staff-b',
    createdAt: DateTime(2026, 10, 17, 12),
  ),
];

StaffReportBase baseFor(StaffReportAccess access) => buildStaffBase(
  staff: staff,
  receipts: receipts(),
  // The Invoice Report query always uses the shop's closing time
  // (none in tests), so invoices stay away from midnight.
  invoices: [
    testInvoice(
      uuid: 'i-2000000000001',
      total: 300,
      createdAt: DateTime(2026, 10, 17, 12),
    ),
    testInvoice(
      uuid: 'i-2000000000002',
      total: 999,
      createdAt: DateTime(2026, 10, 16, 12),
    ),
  ],
  orders: [
    staffOrder(
      uuid: 'o-3000000000001',
      total: 80,
      createdAt: DateTime(2026, 10, 18, 3, 30),
    ),
    staffOrder(
      uuid: 'o-3000000000002',
      total: 800,
      createdAt: DateTime(2026, 10, 18, 4, 30),
    ),
  ],
  purchases: [
    purchase(
      uuid: uuidN(1),
      total: 40,
      createdAt: DateTime(2026, 10, 17, 12),
    ),
    purchase(uuid: uuidN(2), total: 400, createdAt: afterClose),
  ],
  expenses: [
    testExpense(
      uuid: 'e-1',
      amount: 25,
      description: 'Generator diesel',
      createdAt: DateTime(2026, 10, 18, 3, 30),
    ),
    testExpense(uuid: 'e-2', amount: 250, createdAt: afterClose),
  ],
  access: access,
);

StaffPageData dataFor({
  StaffReportAccess? access,
  String key = 'staff-a',
  DateTime? now,
}) => StaffPageData.build(
  base: baseFor(access ?? staffAccess()),
  staffKey: key,
  now: now ?? beforeClose,
  closingTime: closing,
);

/// Every figure of the card.
Map<String, num> figures(StaffReportRow r) => {
  'receiptSales': r.receiptSales,
  'receiptCount': r.receiptCount,
  'invoiceSales': r.invoiceSales,
  'invoiceCount': r.invoiceCount,
  'orderTotal': r.orderTotal,
  'orderCount': r.orderCount,
  'purchaseTotal': r.purchaseTotal,
  'purchaseCount': r.purchaseCount,
  'expenseTotal': r.expenseTotal,
  'expenseCount': r.expenseCount,
};

/// The Staff Report's row of [key] on its "today" (the table without
/// View Date) at [now].
StaffReportRow reportTodayRow(
  StaffReportAccess access,
  DateTime now, {
  String key = 'staff-a',
}) {
  final today = staffAccess(
    canPickDate: false,
  ).initialPeriod(now: now, closingTime: closing);
  return staffRowFor(baseFor(access), key, period: today, closingTime: closing);
}

ResolvedTable table(ReportExportSpec s, String prefix) => resolveExport(
  s,
  testCtx,
).tables.firstWhere((t) => t.title.startsWith(prefix));

List<String> records(ResolvedTable t) => [
  for (final r in t.rows) r[t.indexOf('record')].text,
];

List<String> titles(ReportExportSpec s) => [
  for (final x in s.sections) x.title.split(' (').first,
];

Map<String, ResolvedMetric> statistics(ReportExportSpec s) => {
  for (final m
      in resolveExport(s, testCtx).sections
          .whereType<ResolvedSummary>()
          .firstWhere((x) => x.title == 'Statistics')
          .metrics)
    m.label: m,
};

/// [env] with a signature the test changes.
StaffReportEnv withSignature(StaffReportEnv e, String Function() sig) =>
    StaffReportEnv(
      access: e.access,
      source: e.source,
      load: e.load,
      signature: (_) => sig(),
      listen: e.listen,
      money: e.money,
      openAnalysis: e.openAnalysis,
      openReceipt: e.openReceipt,
      openInvoice: e.openInvoice,
      openOrder: e.openOrder,
      openPurchase: e.openPurchase,
      openExpense: e.openExpense,
      openReceiptsTable: e.openReceiptsTable,
      openInvoiceTable: e.openInvoiceTable,
      openOrderTable: e.openOrderTable,
      openPurchaseTable: e.openPurchaseTable,
      openExpensesTable: e.openExpensesTable,
    );

void main() {
  group('the card is the Staff Report Today row', () {
    test('a business day runs to the closing time', () {
      final data = dataFor();
      expect(data.period.start, DateTime(2026, 10, 17));
      expect(data.period.end, DateTime(2026, 10, 17));
      expect(data.isPeriod(day17), isTrue);
      expect(data.canSeeRecords, isTrue);
      expect(
        figures(data.summary),
        figures(reportTodayRow(staffAccess(), beforeClose)),
      );
      // 03:30 on the 18th is in; 04:30 on the 18th, the 10th and
      // Bayo's receipt are not.
      expect(figures(data.summary), {
        'receiptSales': 2101,
        'receiptCount': 7,
        'invoiceSales': 300,
        'invoiceCount': 1,
        'orderTotal': 80,
        'orderCount': 1,
        'purchaseTotal': 40,
        'purchaseCount': 1,
        'expenseTotal': 25,
        'expenseCount': 1,
      });
      expect(data.summary.name, 'Ada');
    });

    test('after closing time, today is the next business day', () {
      final data = dataFor(now: afterClose);
      expect(data.isPeriod(day18), isTrue);
      expect(
        figures(data.summary),
        figures(reportTodayRow(staffAccess(), afterClose)),
      );
      expect(data.summary.receiptSales, 1000);
      expect(data.summary.orderTotal, 800);
      expect(data.summary.purchaseTotal, 400);
      expect(data.summary.expenseTotal, 250);
      expect(data.summary.invoiceSales, 0);
    });

    test('the sections hold the latest 5, newest first', () {
      final a = dataFor().analysis;
      expect(a.recentReceipts.map((r) => r.uuid), [
        'r-1000000000007',
        'r-1000000000006',
        'r-1000000000005',
        'r-1000000000004',
        'r-1000000000003',
      ]);
      expect(a.recentInvoices.single.uuid, 'i-2000000000001');
      expect(a.recentOrders.single.uuid, 'o-3000000000001');
      expect(a.recentPurchases.single.uuid, uuidN(1));
      expect(a.recentExpenses.single.uuid, 'e-1');
    });
  });

  group('gates', () {
    test('orders, purchases and expenses each hide their figures', () {
      final noOrders = dataFor(access: staffAccess(showOrders: false));
      expect(noOrders.showOrders, isFalse);
      expect(noOrders.summary.orderTotal, 0);
      expect(noOrders.summary.orderCount, 0);
      expect(noOrders.analysis.recentOrders, isEmpty);
      expect(noOrders.printAnalysis.recentOrders, isEmpty);
      expect(noOrders.summary.receiptSales, 2101);

      final noPurchases = dataFor(access: staffAccess(showPurchases: false));
      expect(noPurchases.showPurchases, isFalse);
      expect(noPurchases.summary.purchaseTotal, 0);
      expect(noPurchases.summary.purchaseCount, 0);
      expect(noPurchases.analysis.recentPurchases, isEmpty);
      expect(noPurchases.printAnalysis.recentPurchases, isEmpty);

      final noExpenses = dataFor(access: staffAccess(showExpenses: false));
      expect(noExpenses.showExpenses, isFalse);
      expect(noExpenses.summary.expenseTotal, 0);
      expect(noExpenses.summary.expenseCount, 0);
      expect(noExpenses.analysis.recentExpenses, isEmpty);
      expect(noExpenses.printAnalysis.recentExpenses, isEmpty);
    });

    test('hidden kinds are left out of the print', () {
      final all = dataFor().printSpec(currency: '₦');
      expect(titles(all), [
        'Contact Details',
        'Statistics',
        'Receipts',
        'Invoices',
        'Orders',
        'Purchases',
        'Expenses',
      ]);
      final none = dataFor(
        access: staffAccess(
          showOrders: false,
          showPurchases: false,
          showExpenses: false,
        ),
      ).printSpec(currency: '₦');
      expect(titles(none), [
        'Contact Details',
        'Statistics',
        'Receipts',
        'Invoices',
      ]);
      final m = statistics(none);
      expect(m.containsKey('Orders'), isFalse);
      expect(m.containsKey('Purchases'), isFalse);
      expect(m.containsKey('Expenses'), isFalse);
    });
  });

  group('without View All Transaction Records', () {
    test('another staff\'s page has no records', () {
      final data = dataFor(
        access: staffAccess(
          canViewAllTransactions: false,
          currentUserId: 'staff-b',
        ),
      );
      expect(data.canSeeRecords, isFalse);
      expect(figures(data.summary).values, everyElement(0));
      final a = data.analysis;
      expect(a.recentReceipts, isEmpty);
      expect(a.recentInvoices, isEmpty);
      expect(a.recentOrders, isEmpty);
      expect(a.recentPurchases, isEmpty);
      expect(a.recentExpenses, isEmpty);
    });

    test('the staff\'s own page shows their records', () {
      final own = staffAccess(
        canViewAllTransactions: false,
        currentUserId: 'staff-a',
      );
      final data = dataFor(access: own);
      expect(data.canSeeRecords, isTrue);
      expect(
        figures(data.summary),
        figures(reportTodayRow(own, beforeClose)),
      );
      expect(data.summary.receiptSales, 2101);
    });
  });

  group('print spec', () {
    final data = dataFor();
    final spec = data.printSpec(currency: '₦');

    test('the Staff Analysis report of this staff, today', () {
      expect(spec.reportName, 'Staff Analysis');
      expect(spec.period!.start, DateTime(2026, 10, 17));
      expect(spec.period!.end, DateTime(2026, 10, 17));
      expect(spec.period!.label, receiptsPeriodLabel(data.period));
      expect({for (final f in spec.filters) f.label: f.value}, {
        'Staff': 'Ada',
      });
      expect(spec.notes, isEmpty);
      expect(statistics(spec)['Receipt Sales']!.raw, 2101);
      expect(statistics(spec)['Receipt Sales']!.note, '7 receipts');
    });

    test('every record of today, none of other days', () {
      final r = table(spec, 'Receipts');
      // All 7, not the screen's 5.
      expect(r.title, 'Receipts (7 of 7 in this period)');
      expect(records(r), [
        for (final x in data.slice.receiptsOf('staff-a')) x.displayId,
      ]);
      expect(data.analysis.recentReceipts, hasLength(5));

      expect(records(table(spec, 'Invoices')), [
        data.slice.invoicesOf('staff-a').single.displayId,
      ]);
      expect(records(table(spec, 'Orders')), [
        data.slice.ordersOf('staff-a').single.displayId,
      ]);
      expect(records(table(spec, 'Purchases')), [
        data.slice.purchasesOf('staff-a').single.displayId,
      ]);
      expect(records(table(spec, 'Expenses')), ['Fuel']);

      final ids = {
        for (final x in data.slice.receiptsOf('staff-a')) x.uuid,
      };
      expect(ids, hasLength(7));
      expect(ids.contains('r-1000000000008'), isFalse);
      expect(ids.contains('r-1000000000009'), isFalse);
      expect(ids.contains('r-1000000000010'), isFalse);
    });
  });

  group('StaffPageController', () {
    testWidgets('loads, then rebuilds on data changes and at closing', (
      tester,
    ) async {
      var now = beforeClose;
      var signature = 'v1';
      final list = [
        testReceipt(
          uuid: 'r-1000000000001',
          cash: 100,
          createdAt: DateTime(2026, 10, 17, 12),
        ),
      ];
      final controller = StaffPageController(
        staffKey: 'staff-a',
        env: withSignature(
          fakeStaffEnv(staff: staff, receipts: list),
          () => signature,
        ),
        clock: () => now,
        closingTime: closing,
      );
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);

      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );

      expect(controller.loading, isTrue);
      expect(controller.data, isNull);
      // Nothing to rebuild before the first load.
      controller.sync(context);
      expect(controller.data, isNull);

      await controller.load(context);
      expect(controller.loading, isFalse);
      expect(controller.error, isNull);
      expect(notified, 2);
      expect(controller.data!.isPeriod(day17), isTrue);
      expect(controller.data!.summary.receiptSales, 100);

      // A new sale: rebuilt once the providers' signature changes.
      list.add(
        testReceipt(
          uuid: 'r-1000000000002',
          cash: 50,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
      );
      controller.sync(context);
      expect(controller.data!.summary.receiptSales, 100);
      signature = 'v2';
      controller.sync(context);
      expect(controller.data!.summary.receiptSales, 150);
      expect(controller.data!.summary.receiptCount, 2);

      // Past closing time the page moves to the next business day.
      now = afterClose;
      controller.sync(context);
      expect(controller.data!.isPeriod(day18), isTrue);
      expect(controller.data!.summary.receiptSales, 0);
      // sync runs during build: it never notifies.
      expect(notified, 2);
    });

    testWidgets('a failed load is an error, not data', (tester) async {
      final base = fakeStaffEnv(staff: staff);
      final controller = StaffPageController(
        staffKey: 'staff-a',
        env: StaffReportEnv(
          access: base.access,
          source: () => throw StateError('no data'),
          load: base.load,
          signature: base.signature,
          listen: base.listen,
          money: base.money,
          openAnalysis: base.openAnalysis,
          openReceipt: base.openReceipt,
          openInvoice: base.openInvoice,
          openOrder: base.openOrder,
          openPurchase: base.openPurchase,
          openExpense: base.openExpense,
          openReceiptsTable: base.openReceiptsTable,
          openInvoiceTable: base.openInvoiceTable,
          openOrderTable: base.openOrderTable,
          openPurchaseTable: base.openPurchaseTable,
          openExpensesTable: base.openExpensesTable,
        ),
        clock: () => beforeClose,
        closingTime: closing,
      );
      addTearDown(controller.dispose);

      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      await controller.load(context);
      expect(controller.loading, isFalse);
      expect(controller.error, contains('no data'));
      expect(controller.data, isNull);
    });
  });
}
