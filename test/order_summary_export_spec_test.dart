import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_summary/class/order_summary_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'order_report_fixtures.dart';
import 'order_summary_test.dart'
    show allTime, pumpSummary, summarize, summaryOrders, summaryReceipts;

List<OrderReportRow> rowsOf(List<Orders> orders) => OrderReportRowBuilder.buildAll(
  orders: orders,
  allReceipts: summaryReceipts(),
  allProductSales: const [],
);

/// summaryOrders() plus one whose unit conversion fails (Unknown).
List<Orders> withUnknown() => [
  ...summaryOrders(),
  testOrder(
    uuid: 'bad',
    lines: [orderLine(units: [testUnit('bad', conversion: 0)], unitUuid: 'bad')],
    total: 10,
  ),
];

ReportExportSpec specFor(
  List<Orders> orders, {
  ReceiptsReportPeriod period = allTime,
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
}) {
  return orderSummaryExportSpec(
    result: summarize(
      rowsOf(orders),
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: canSeeCost,
    ),
    period: period,
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
  );
}

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

Map<String, ResolvedMetric> metrics(ReportExportSpec s, String title) => {
  for (final m in resolved(s)
      .sections
      .whereType<ResolvedSummary>()
      .firstWhere((x) => x.title == title)
      .metrics)
    m.label: m,
};

ResolvedTable table(ReportExportSpec s, String title) =>
    resolved(s).tables.firstWhere((t) => t.title == title);

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  group('sections', () {
    test('cards, delivery status and tables as on screen; no charts, no splits', () {
      final spec = specFor(summaryOrders());
      expect(spec.sections.map((s) => s.title), [
        'Statistics',
        'Delivery Status',
        'Top Customers by Undelivered Value',
        'Customers',
        'Staff',
        'Departments',
        'Sub-Staff',
        'Status',
        'Channel',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(spec.fileSlug, 'order_summary');
      final off = specFor(summaryOrders(), departmentsEnabled: false, subStaffEnabled: false);
      expect(off.sections.map((s) => s.title), isNot(contains('Departments')));
      expect(off.sections.map((s) => s.title), isNot(contains('Sub-Staff')));
    });
  });

  group('figures', () {
    test('the screen stats', () {
      final s = summarize(rowsOf(summaryOrders())).stats;
      final m = metrics(specFor(summaryOrders()), 'Statistics');
      expect(m['Orders']!.raw, s.orderCount);
      expect(
        m['Orders']!.note,
        '${s.fullyDelivered} full · ${s.partiallyDelivered} partial · '
        '${s.undelivered} undelivered',
      );
      expect(m['Order Value']!.raw, s.totalValue);
      expect(m['Delivered Value']!.raw, s.deliveredValue);
      expect(m['Undelivered Value']!.raw, s.undeliveredValue);
      expect(m['Paid']!.raw, s.paid);
      expect(m['Balance']!.raw, s.balance);
      expect(m['Records Disagree']!.raw, s.recordsDisagree);
      final profit = s.profitIsEstimate ? 'Est. Profit' : 'Profit';
      expect(m[profit]!.raw, s.profit);
      expect(metrics(specFor(summaryOrders(), canSeeCost: false), 'Statistics')
          .containsKey(profit), isFalse);
    });

    test('Delivery Status: the Unknown count only when the screen shows it', () {
      final none = metrics(specFor(summaryOrders()), 'Delivery Status');
      expect(none.keys, ['Fully Delivered', 'Partially Delivered', 'Undelivered']);
      final s = summarize(rowsOf(withUnknown())).stats;
      expect(s.unavailable, 1);
      final m = metrics(specFor(withUnknown()), 'Delivery Status');
      expect(m['Unknown']!.raw, 1);
      expect(m['Unknown']!.note, '20%');
      expect(m['Fully Delivered']!.raw, s.fullyDelivered);
    });
  });

  group('tables', () {
    test('breakdowns are the screen groups; Status lists every status', () {
      final r = summarize(rowsOf(withUnknown()));
      final spec = specFor(withUnknown());
      expect(col(table(spec, 'Customers'), 'name'), [for (final g in r.customers) g.label]);
      expect(col(table(spec, 'Channel'), 'name'), [for (final g in r.channels) g.label]);
      expect(col(table(spec, 'Status'), 'name'), [
        'Fully Delivered',
        'Partially Delivered',
        'Undelivered',
        'Unknown',
      ]);
      expect(table(spec, 'Status').indexOf('lastOrder'), -1);
      expect(table(spec, 'Customers').indexOf('lastOrder'), greaterThan(0));
      expect(
        col(table(spec, 'Top Customers by Undelivered Value'), 'name'),
        [for (final g in r.topUndeliveredCustomers) g.label],
      );
      // Unknown is listed only when needed.
      expect(col(table(specFor(summaryOrders()), 'Status'), 'name'), hasLength(3));
    });

    test('Profit only with cost access', () {
      for (final t in resolved(specFor(summaryOrders(), canSeeCost: false)).tables) {
        expect(t.indexOf('profit'), -1, reason: t.title);
      }
      expect(table(specFor(summaryOrders()), 'Staff').indexOf('profit'), greaterThan(0));
    });
  });

  group('info box and notes', () {
    test('the period and the All time note exactly as on screen', () {
      final spec = specFor(summaryOrders());
      expect(spec.notes, ['All time covers the orders loaded on this device.']);
      expect(spec.period!.label, 'All time');
      final info = {
        for (final e in reportPdfInfoEntries(resolved(spec))) e.$1: e.$2,
      };
      expect(info['Notes'], spec.notes.single);
      final day = specFor(summaryOrders(), period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(day.notes, isEmpty);
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: Metric · Value pairs, tables fit', () {
        final text = renderRollEscPos(
          buildRollLines(specFor(withUnknown()), testCtx, paper: paper),
          paper,
        ).preview;
        final out = text.split('\n');
        expect(out.firstWhere((l) => l.startsWith('Orders')), endsWith('5'));
        expect(text, contains('Unknown'));
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        expect(
          out.where((l) => l.contains('.00')).every((l) => l.length <= paper.chars),
          isTrue,
        );
      });
    }
  });

  group('Order Summary screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpSummary(
          tester,
          isDesktop: desktop,
          period: allTime,
          env: fakeEnv(orders: summaryOrders(), receipts: summaryReceipts()),
        );
        // Beside the period button at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
