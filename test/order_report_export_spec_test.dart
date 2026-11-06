import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'order_report_fixtures.dart';
import 'order_report_table_test.dart' show pumpTable, query;

// Fully delivered (Ada, Bola, Front, Kemi), cash 50; part delivered
// with records that disagree (stored 4, receipt 5) for Chidi; Zed's
// ₦1,250,000 order, half delivered, without a cost price; an order with
// no staff or customer, nothing delivered; one whose unit conversion
// fails (status unknown).
List<Orders> sampleOrders() => [
  testOrder(
    uuid: 'o-1',
    barcode: '1000000000001',
    lines: [orderLine(remaining: 0)],
    departmentUuid: 'd-1',
    departmentName: 'Front',
    subStaffUuid: 'ss-1',
    subStaffName: 'Kemi',
    createdAt: DateTime(2026, 10, 17, 9),
  ),
  testOrder(
    uuid: 'o-2',
    barcode: '1000000000002',
    lines: [orderLine(remaining: 6)],
    customerId: 'cust-2',
    customerName: 'Chidi',
    createdAt: DateTime(2026, 10, 17, 10),
  ),
  testOrder(
    uuid: 'o-3',
    barcode: '1000000000003',
    lines: [orderLine(remaining: 5, costPrice: null)],
    total: 1250000,
    staffId: 'staff-2',
    staffName: 'Zed',
    createdAt: DateTime(2026, 10, 17, 11),
  ),
  testOrder(
    uuid: 'o-4',
    barcode: '1000000000004',
    staffId: null,
    staffName: null,
    customerId: null,
    customerName: null,
    createdAt: DateTime(2026, 10, 17, 12),
  ),
  testOrder(
    uuid: 'o-5',
    barcode: '1000000000005',
    lines: [orderLine(units: [testUnit('bad', conversion: 0)], unitUuid: 'bad')],
    total: 10,
    createdAt: DateTime(2026, 10, 17, 13),
  ),
];

List<TempMainReceipt> sampleReceipts() => [
  deliveryReceipt(
    uuid: 'r-1',
    orderUuid: 'o-1',
    cash: 50,
    items: [deliveredLine(quantity: 10)],
  ),
  deliveryReceipt(
    uuid: 'r-2',
    orderUuid: 'o-2',
    account: 20,
    items: [deliveredLine(quantity: 5)],
  ),
];

List<OrderReportRow> buildRows(List<Orders> orders, [List<TempMainReceipt> receipts = const []]) =>
    OrderReportRowBuilder.buildAll(
      orders: orders,
      allReceipts: receipts,
      allProductSales: const [],
    );

final sample = query(buildRows(sampleOrders(), sampleReceipts()), OrderReportFilters());

ReportExportSpec specFor(
  List<OrderReportRow> rows, {
  ReportGroupBy groupBy = ReportGroupBy.off,
  OrderReportFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
}) {
  final groups = OrderReportGrouping.sort(
    OrderReportGrouping.build(rows, groupBy),
    field: OrderGroupSortField.total,
    ascending: false,
  );
  return orderReportExportSpec(
    rows: rows,
    groups: groups,
    groupBy: groupBy,
    filters: filters ?? OrderReportFilters(),
    staffOptions: OrderReportOptions.staff(rows),
    customerOptions: OrderReportOptions.customers(rows),
    subStaffOptions: OrderReportOptions.subStaff(rows),
    departmentOptions: OrderReportOptions.departments(rows),
    period: period,
    sortField: OrderSortField.createdAt,
    ascending: false,
    groupSortField: OrderGroupSortField.total,
    groupAscending: false,
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String id, String columnId) {
  final t = tableOf(spec);
  final r = t.rows.firstWhere((r) => r[t.indexOf('id')].text == id);
  return r[t.indexOf(columnId)];
}

OrderReportRow rowOf(String id) => sample.firstWhere((r) => r.displayId == id);

void main() {
  group('rows are the screen query, every page', () {
    test('150 orders: every row, in the screen order', () {
      final rows = query(
        buildRows([
          for (var i = 0; i < 150; i++)
            testOrder(
              uuid: 'o-$i',
              barcode: '${2000000000000 + i}',
              total: 100.0 + i,
              createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
            ),
        ]),
        OrderReportFilters(),
        sortField: OrderSortField.total,
      );
      final t = tableOf(specFor(rows));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('id')].text], [
        for (final r in rows) r.displayId,
      ]);
    });
  });

  group('columns follow the screen', () {
    test('PDF and Excel-only columns', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) c.label], [
        'ID',
        'Staff',
        'Sub-Staff',
        'Customer',
        'Date',
        'Time',
        'Department',
        'Status',
        'Items',
        'Delivered',
        'Channel',
        'Discount',
        'VAT',
        'Total',
        'Delivered Value',
        'Undelivered Value',
        'Paid',
        'Balance',
        'Cost',
        'Profit/Loss',
        'Margin (%)',
        'Est. Profit',
        'Notes',
        'Comment',
      ]);
      expect(
        [for (final c in t.columns) if (!c.inPdf) c.id],
        ['time', 'discount', 'vat', 'cost', 'estimate', 'comment'],
      );
    });

    test('cost, department and sub-staff conditions', () {
      final t = tableOf(
        specFor(sample, canSeeCost: false, departmentsEnabled: false, subStaffEnabled: false),
      );
      for (final id in ['cost', 'profit', 'margin', 'estimate', 'department', 'subStaff']) {
        expect(t.indexOf(id), -1, reason: id);
      }
    });
  });

  group('cells', () {
    final spec = specFor(sample);
    test('delivery status, delivered and undelivered values', () {
      expect(cellOf(spec, '#1000000000001', 'status').text, 'Fully Delivered');
      expect(cellOf(spec, '#1000000000003', 'status').text, 'Partially Delivered');
      expect(cellOf(spec, '#1000000000004', 'status').text, 'Undelivered');
      expect(cellOf(spec, '#1000000000005', 'status').text, '—');
      expect(cellOf(spec, '#1000000000005', 'deliveredValue').text, '—');
      expect(cellOf(spec, '#1000000000005', 'items').text, '—');
      final big = rowOf('#1000000000003');
      expect(cellOf(spec, '#1000000000003', 'deliveredValue').raw, big.deliveredValue);
      expect(cellOf(spec, '#1000000000003', 'undeliveredValue').raw, big.undeliveredValue);
      expect(cellOf(spec, '#1000000000003', 'total').text, '₦1,250,000.00');
    });

    test('"Est." until Fully Delivered, N/A without a cost', () {
      final partial = rowOf('#1000000000002');
      expect(partial.profitIsEstimate, isTrue);
      expect(
        cellOf(spec, '#1000000000002', 'profit').text,
        'Est. ${ExportFormatter(currency: '₦').money(partial.profit!)}',
      );
      expect(cellOf(spec, '#1000000000002', 'estimate').text, 'Yes');
      expect(cellOf(spec, '#1000000000001', 'profit').text, isNot(startsWith('Est.')));
      expect(cellOf(spec, '#1000000000001', 'estimate').text, 'No');
      expect(cellOf(spec, '#1000000000003', 'profit').text, 'N/A');
      expect(cellOf(spec, '#1000000000003', 'cost').text, 'N/A');
      expect(cellOf(spec, '#1000000000003', 'margin').text, 'N/A');
    });

    test('the Notes column: "Records disagree"', () {
      expect(rowOf('#1000000000002').recordsDisagree, isTrue);
      expect(cellOf(spec, '#1000000000002', 'notes').text, 'Records disagree');
      expect(cellOf(spec, '#1000000000001', 'notes').text, '—');
    });
  });

  group('totals', () {
    test('equal the OrderReportTotals the screen shows', () {
      final t0 = OrderReportQuery.paginate(sample, 1).totals;
      final t = tableOf(specFor(sample));
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![t.indexOf('id')].text, '5 orders');
      expect(total('total'), t0.total);
      expect(total('deliveredValue'), t0.deliveredValue);
      expect(total('undeliveredValue'), t0.undeliveredValue);
      expect(total('paid'), t0.paid);
      expect(total('balance'), t0.balance);
      expect(total('cost'), t0.cost);
      // A counted profit is an estimate, so the total reads "Est. ₦x".
      expect(t0.profitIsEstimate, isTrue);
      expect(
        t.totals![t.indexOf('profit')].text,
        'Est. ${ExportFormatter(currency: '₦').money(t0.profit!)}',
      );
    });
  });

  group('grouped', () {
    test('by Staff: the group table, its totals, "Grouped by: Staff"', () {
      final spec = specFor(sample, groupBy: ReportGroupBy.staff);
      final groups = OrderReportGrouping.sort(
        OrderReportGrouping.build(sample, ReportGroupBy.staff),
        field: OrderGroupSortField.total,
        ascending: false,
      );
      final page = OrderReportGrouping.paginate(groups, sample, 1);
      final t = tableOf(spec);
      expect([for (final r in t.rows) r[0].text], [for (final g in groups) g.label]);
      expect(t.rows.last[0].text, 'No staff');
      expect(t.totals![t.indexOf('orders')].raw, page.totals.count);
      expect(t.totals![t.indexOf('total')].raw, page.totals.total);
      expect(t.totals![t.indexOf('undeliveredValue')].raw, page.totals.undeliveredValue);
      expect(spec.groupedBy, 'Staff');
      expect(spec.sortedBy, 'Total (descending)');
      expect(spec.splitOptions, isEmpty);
      final noCost = tableOf(specFor(sample, groupBy: ReportGroupBy.staff, canSeeCost: false));
      expect(noCost.indexOf('profit'), -1);
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(String id) => [
      for (final g in resolveGroups(specFor(sample).tables.single, id, f)) g.name,
    ];

    test('Staff, Channel, Delivery Status, Department, Customer (opt-in, last)', () {
      expect(specFor(sample).splitOptions.map((s) => s.id), [
        'staff',
        'channel',
        'deliveryStatus',
        'department',
        'customer',
      ]);
    });

    test('"No …" groups come last', () {
      expect(names('staff'), ['Ada', 'Zed', 'No Staff']);
      expect(names('deliveryStatus').last, 'No Status');
      expect(
        names('deliveryStatus'),
        containsAll(['Fully Delivered', 'Partially Delivered', 'Undelivered']),
      );
      expect(names('department'), ['Front', 'No Department']);
      expect(names('customer'), ['Bola', 'Chidi', 'No Customer']);
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips', () {
      final filters = OrderReportFilters(
        deliveryStatus: OrderDeliveryStatus.partial,
        recordsDisagree: true,
        channel: OrderPaymentChannel.cash,
        staffKey: 'staff-1',
        customerKey: orderReportNoneKey,
        totalMin: 100,
        profitMax: 50,
      );
      final spec = specFor(sample, filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Status: Partially Delivered',
        'Records: Records disagree only',
        'Channel: Cash',
        'Staff: Ada',
        'Customer: No customer',
        'Total: ₦100.00 - Any',
        'Profit/Loss: Any - ₦50.00',
      ]);
      final noCost = specFor(sample, filters: filters, canSeeCost: false);
      expect(noCost.filters.map((x) => x.label), isNot(contains('Profit/Loss')));
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor(sample);
      expect(all.notes, ['All time covers the orders loaded on this device.']);
      expect(orderReportNotes(period: const ReceiptsReportPeriod.allTime()), all.notes);
      final day = specFor(sample, period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(day.notes, isEmpty);
      expect(day.period!.label, 'Oct 17, 2026');
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], 'All time covers the orders loaded on this device.');
    });
  });

  group('roll', () {
    String preview(ReportExportSpec spec, RollPaper paper) => renderRollEscPos(
      buildRollLines(spec, testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: ID · Total on one line', () {
      final out = preview(specFor(sample), RollPaper.mm58).split('\n');
      expect(
        out.firstWhere((l) => l.startsWith('#1000000000003')),
        endsWith('N1,250,000.00'),
      );
      expect(out.every((l) => l.length <= 32 || l.startsWith('* ')), isTrue);
    });

    test('80mm: ID · Total · Status, customer | date underneath', () {
      final out = preview(specFor(sample), RollPaper.mm80).split('\n');
      final i = out.indexWhere((l) => l.startsWith('#1000000000003'));
      expect(out[i], contains('N1,250,000.00'));
      expect(out[i], endsWith('Partially Delivered'));
      expect(out[i + 1].trim(), 'Bola | Oct 17, 2026');
      // The note prints small (Font B), so it may run past 48.
      expect(out.every((l) => l.length <= 48 || l.startsWith('* ')), isTrue);
      expect(out.every((l) => l.length <= RollPaper.mm80.dots ~/ fontBDots), isTrue);
    });
  });

  group('Order table screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        // pumpTable opens "View" on mobile, where the toolbar sits.
        await pumpTable(
          tester,
          isDesktop: desktop,
          env: fakeEnv(orders: sampleOrders(), receipts: sampleReceipts()),
        );
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
