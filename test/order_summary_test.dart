import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/components/order_report_table_view.dart';
import 'package:stockall/pages/report/order_report/order_summary/class/order_summary_logic.dart';
import 'package:stockall/pages/report/order_report/order_summary/components/order_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'order_report_fixtures.dart';

const allTime = ReceiptsReportPeriod.allTime();

OrderSummaryResult summarize(
  List<OrderReportRow> rows, {
  OrderReportFilters? filters,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
  bool profitVisible = true,
}) {
  return OrderSummaryBuilder.build(
    rows: rows,
    period: allTime,
    filters: filters,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
    profitVisible: profitVisible,
  );
}

List<OrderReportRow> table(OrderReportFilters filters, List<OrderReportRow> rows) {
  return OrderReportQuery.filterAndSort(
    rows: rows,
    period: allTime,
    filters: filters,
    sortField: OrderSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    subStaffEnabled: true,
    profitVisible: true,
  );
}

// full: Ada / Bola / dept-1 / cash 50 (paid in full)
// partial: Ada / Chidi / dept-2 / account 70 (overpaid by 20)
// mismatch: Zed / Bola / no dept / unpaid, stored 4, no lines
// undelivered: no staff / no customer / bank 10
// All created on 17 Oct 2026, 12:00.
List<Orders> summaryOrders() => [
  testOrder(
    uuid: 'full',
    lines: [orderLine(remaining: 0)],
    departmentUuid: 'dept-1',
    departmentName: 'Front',
    subStaffUuid: 'ss-1',
    subStaffName: 'Kemi',
  ),
  testOrder(
    uuid: 'partial',
    lines: [orderLine(remaining: 6)],
    customerId: 'cust-2',
    customerName: 'Chidi',
    departmentUuid: 'dept-2',
    departmentName: 'Back',
  ),
  testOrder(
    uuid: 'mismatch',
    lines: [orderLine(remaining: 6)],
    staffId: 'staff-2',
    staffName: 'Zed',
  ),
  testOrder(
    uuid: 'undelivered',
    staffId: null,
    staffName: null,
    customerId: null,
    customerName: null,
  ),
];

List<TempMainReceipt> summaryReceipts() => [
  deliveryReceipt(
    uuid: 'r-full',
    orderUuid: 'full',
    cash: 50,
    items: [deliveredLine(quantity: 10)],
  ),
  deliveryReceipt(
    uuid: 'r-partial',
    orderUuid: 'partial',
    account: 70,
    items: [deliveredLine(quantity: 4)],
  ),
  deliveryReceipt(
    uuid: 'r-undelivered',
    orderUuid: 'undelivered',
    bank: 10,
  ),
];

void main() {
  final rows = OrderReportRowBuilder.buildAll(
    orders: summaryOrders(),
    allReceipts: summaryReceipts(),
  );

  group('Stats', () {
    test('counts and values', () {
      final s = summarize(rows).stats;
      expect(s.orderCount, 4);
      expect(s.totalValue, 200);
      expect(s.fullyDelivered, 1);
      expect(s.partiallyDelivered, 2);
      expect(s.undelivered, 1);
      expect(s.unavailable, 0);
      expect(s.recordsDisagree, 1);
      expect(s.deliveredValue, closeTo(50 + 20 + 20, 1e-9));
      expect(s.undeliveredValue, closeTo(0 + 30 + 30 + 50, 1e-9));
      expect(s.orderedItems, 40);
      expect(s.deliveredItems, 18);
      expect(s.customers, 2);
      expect(s.staff, 2);
    });

    test('overpaid orders add 0 to the balance', () {
      final s = summarize(rows).stats;
      expect(s.paid, 130);
      // full 0, partial 0 (overpaid), mismatch 50, undelivered 40
      expect(s.balance, 90);
    });

    test('Est. profit is total minus cost', () {
      final s = summarize(rows).stats;
      expect(s.cost, 80);
      expect(s.profit, 120);
      expect(s.profitIsEstimate, isTrue);
      expect(s.margin, closeTo(60, 1e-9));
    });

    test('not an estimate when every order is Fully Delivered', () {
      final s =
          summarize(
            rows,
            filters: OrderReportFilters(
              deliveryStatus: OrderDeliveryStatus.full,
            ),
          ).stats;
      expect(s.profit, 30);
      expect(s.profitIsEstimate, isFalse);
    });

    test('analysis rows are the table rows', () {
      final f = OrderReportFilters(staffKey: 'staff-1');
      expect(
        summarize(rows, filters: f).rows.map((r) => r.uuid),
        table(f, rows).map((r) => r.uuid),
      );
    });
  });

  group('Breakdowns', () {
    test('every status is listed', () {
      final only = summarize(
        rows,
        filters: OrderReportFilters(
          deliveryStatus: OrderDeliveryStatus.full,
        ),
      );
      expect(
        only.statusSummaries.map((s) => s.status),
        OrderDeliveryStatus.values,
      );
      expect(
        only.statusSummaries.map((s) => s.count),
        [0, 0, 1],
      );
    });

    test('largest total first, none row last', () {
      final res = summarize(rows);
      expect(res.customers.last.isNone, isTrue);
      expect(res.customers.last.label, orderNoCustomerLabel);
      expect(res.customers.first.label, 'Bola');
      expect(res.staff.last.label, orderNoStaffLabel);
      expect(res.departments.last.label, orderNoDepartmentLabel);
      expect(res.subStaff.last.label, orderNoSubStaffLabel);
    });

    test('channels include Account, Unpaid last', () {
      final labels =
          summarize(rows).channels.map((g) => g.label).toList();
      expect(labels.toSet(), {'Cash', 'Account', 'Unpaid', 'Bank'});
      expect(labels.last, 'Unpaid');
    });

    test('top undelivered customers skip No customer', () {
      final top = summarize(rows).topUndeliveredCustomers;
      expect(top.map((g) => g.label), ['Bola', 'Chidi']);
      expect(top.first.undeliveredValue, closeTo(30, 1e-9));
    });

    test('departments and sub-staff are empty when off', () {
      final res = summarize(
        rows,
        departmentsEnabled: false,
        subStaffEnabled: false,
      );
      expect(res.departments, isEmpty);
      expect(res.subStaff, isEmpty);
    });
  });

  group('Drill-down', () {
    final res = summarize(rows);
    final base = OrderReportFilters();

    test('each breakdown row opens the table with its orders', () {
      final dims = {
        OrderSummaryDimension.customer: res.customers,
        OrderSummaryDimension.staff: res.staff,
        OrderSummaryDimension.department: res.departments,
        OrderSummaryDimension.subStaff: res.subStaff,
        OrderSummaryDimension.channel: res.channels,
      };
      dims.forEach((dim, groups) {
        for (final g in groups) {
          final f = OrderSummaryBuilder.filtersForGroup(
            base: base,
            dimension: dim,
            group: g,
          );
          expect(
            table(f, rows).length,
            g.count,
            reason: '${dim.name} ${g.label}',
          );
        }
      });
    });

    test('Unpaid channel opens the Unpaid filter', () {
      final unpaid = res.channels.last;
      final f = OrderSummaryBuilder.filtersForGroup(
        base: base,
        dimension: OrderSummaryDimension.channel,
        group: unpaid,
      );
      expect(f.channel, OrderPaymentChannel.unpaid);
    });

    test('status and records disagree', () {
      for (final s in res.statusSummaries) {
        final f = OrderSummaryBuilder.filtersForStatus(
          base: base,
          status: s.status,
        );
        expect(table(f, rows).length, s.count);
      }
      final f = OrderSummaryBuilder.filtersForRecordsDisagree(
        base: base,
      );
      expect(f.recordsDisagree, isTrue);
      expect(
        table(f, rows).length,
        res.stats.recordsDisagree,
      );
    });

    test('the analysis filters are kept', () {
      final withStaff = OrderReportFilters(staffKey: 'staff-1');
      final f = OrderSummaryBuilder.filtersForStatus(
        base: withStaff,
        status: OrderDeliveryStatus.partial,
      );
      expect(f.staffKey, 'staff-1');
      expect(withStaff.deliveryStatus, isNull);
    });
  });

  group('Analysis screen', () {
    final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      testWidgets('a breakdown row opens the filtered table ($width)', (
        tester,
      ) async {
        final opened = <_Opened>[];
        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: summaryOrders(),
            receipts: summaryReceipts(),
            openTable: (_, f, p) async => opened.add(_Opened(f, p)),
          ),
        );

        await tapStart(
          tester,
          find.byKey(const ValueKey('order-row-customer-cust-2')),
        );
        final customer = opened.single;
        expect(customer.filters.customerKey, 'cust-2');
        expect(customer.filters.activeCount, 1);
        expect(customer.period.start, DateTime(2026, 10, 17));
        expect(customer.period.end, DateTime(2026, 10, 17));

        await tapStart(
          tester,
          find.byKey(const ValueKey('order-tab-status')),
        );
        await tapStart(
          tester,
          find.byKey(const ValueKey('order-row-status-partial')),
        );
        expect(opened.length, 2);
        expect(
          opened.last.filters.deliveryStatus,
          OrderDeliveryStatus.partial,
        );
        expect(opened.last.filters.activeCount, 1);
        expect(opened.last.period.start, DateTime(2026, 10, 17));
      });

      testWidgets('Records disagree KPI opens that filter ($width)', (
        tester,
      ) async {
        final opened = <_Opened>[];
        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: summaryOrders(),
            receipts: summaryReceipts(),
            openTable: (_, f, p) async => opened.add(_Opened(f, p)),
          ),
        );

        await tapStart(
          tester,
          find.byKey(const ValueKey('order-kpi-disagree')),
        );
        final o = opened.single;
        expect(o.filters.recordsDisagree, isTrue);
        expect(o.filters.activeCount, 1);
        expect(o.period.start, DateTime(2026, 10, 17));
        expect(o.period.end, DateTime(2026, 10, 17));
      });

      testWidgets('Est. Profit needs manageCostPrice ($width)', (
        tester,
      ) async {
        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: summaryOrders(),
            receipts: summaryReceipts(),
            canSeeCost: false,
          ),
        );
        expect(
          find.byKey(const ValueKey('order-kpi-profit')),
          findsNothing,
        );
        expect(find.textContaining('Profit'), findsNothing);

        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: summaryOrders(),
            receipts: summaryReceipts(),
          ),
        );
        expect(
          find.byKey(const ValueKey('order-kpi-profit')),
          findsOneWidget,
        );
        expect(find.text('Est. Profit'), findsOneWidget);
      });

      testWidgets('Unknown slice only when needed ($width)', (
        tester,
      ) async {
        int sections() =>
            tester
                .widget<PieChart>(find.byType(PieChart))
                .data
                .sections
                .length;

        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: summaryOrders(),
            receipts: summaryReceipts(),
          ),
        );
        expect(find.text('Unknown'), findsNothing);
        expect(sections(), 3);

        final withUnknown = [
          ...summaryOrders(),
          testOrder(
            uuid: 'bad',
            lines: [
              orderLine(
                units: [testUnit('bad', conversion: 0)],
                unitUuid: 'bad',
              ),
            ],
            total: 10,
          ),
        ];
        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: withUnknown,
            receipts: summaryReceipts(),
          ),
        );
        expect(find.text('Unknown'), findsOneWidget);
        expect(sections(), 4);
      });

      testWidgets('back from the table rebuilds ($width)', (
        tester,
      ) async {
        final orders = summaryOrders();
        await pumpSummary(
          tester,
          isDesktop: isDesktop,
          period: day17,
          env: fakeEnv(
            orders: orders,
            receipts: summaryReceipts(),
            // Stands in for an order added while the table was open.
            openTable:
                (_, f, p) async => orders.add(testOrder(uuid: 'new')),
          ),
        );
        final ordersKpi = find.byKey(const ValueKey('order-kpi-orders'));
        expect(
          find.descendant(of: ordersKpi, matching: find.text('4')),
          findsOneWidget,
        );

        await tapStart(tester, ordersKpi);

        expect(
          find.descendant(of: ordersKpi, matching: find.text('5')),
          findsOneWidget,
        );
      });
    }
  });
}

class _Opened {
  final OrderReportFilters filters;
  final ReceiptsReportPeriod period;

  _Opened(this.filters, this.period);
}

Future<void> pumpSummary(
  WidgetTester tester, {
  required bool isDesktop,
  required ReceiptsReportPeriod period,
  required OrderReportTableEnv env,
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
        home: OrderSummaryView(
          // A new key per pump, so a second pump starts fresh.
          key: UniqueKey(),
          isDesktop: isDesktop,
          initialPeriod: period,
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
