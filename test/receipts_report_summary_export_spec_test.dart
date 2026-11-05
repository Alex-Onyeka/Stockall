import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/components/receipts_report_summary_view.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'receipts_report_main_logic_test.dart' show line, receipt, row, run;
import 'report_export_screen_harness.dart';

final sample = run([
  row(receipt(
    uuid: 'r-1',
    barcode: '1',
    cash: 1000,
    customerUuid: 'c-chidi',
    customerName: 'Chidi',
    departmentUuid: 'd-front',
    departmentName: 'Front Shop',
    subStaffUuid: 'ss-1',
    subStaffName: 'Uche',
    items: [line(quantity: 2, revenue: 1000, costPrice: 300)],
  )),
  row(receipt(
    uuid: 'r-2',
    barcode: '2',
    paymentMethod: 'Bank',
    bank: 2500,
    staffId: 'staff-b',
    staffName: 'Bola',
  )),
  row(receipt(
    uuid: 'r-3',
    barcode: '3',
    salesTypeIndex: 2,
    invoiceUuid: 'inv-1',
    cash: 500,
    customerUuid: 'c-dayo',
    customerName: 'Dayo',
  )),
]);

ReportExportSpec specFor(
  List<ReceiptsReportRow> rows, {
  ReceiptsReportFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
}) {
  return receiptsSummaryExportSpec(
    stats: ReceiptsSummaryBuilder.stats(rows),
    customers: ReceiptsSummaryBuilder.sortGroups(
      ReceiptsSummaryBuilder.customers(rows),
      field: ReceiptsGroupSortField.revenue,
      ascending: false,
    ),
    staff: ReceiptsSummaryBuilder.staff(rows),
    subStaff: ReceiptsSummaryBuilder.subStaff(rows),
    departments: ReceiptsSummaryBuilder.departments(rows),
    channels: ReceiptsSummaryBuilder.channels(rows),
    types: ReceiptsSummaryBuilder.types(rows),
    filters: filters ?? ReceiptsReportFilters(),
    choices: ReceiptsFilterChoices.fromRows(rows),
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
    test('cards and tables as on screen; no charts, no splits', () {
      final spec = specFor(sample);
      expect(spec.sections.map((s) => s.title), [
        'Statistics',
        'Top 3 Customers',
        'Least 3 Customers',
        'Top 3 Staff',
        'Least 3 Staff',
        'Payment Channel Summary',
        'Collected by Method',
        'Transaction Type Summary',
        'Department Summary',
        'Customer Summary',
        'Staff Summary',
        'Sub-Staff Summary',
      ]);
      expect(spec.splitOptions, isEmpty);
      final off = specFor(sample, departmentsEnabled: false, subStaffEnabled: false);
      expect(off.sections.map((s) => s.title), isNot(contains('Department Summary')));
      expect(off.sections.map((s) => s.title), isNot(contains('Sub-Staff Summary')));
    });
  });

  group('figures', () {
    test('the screen stats', () {
      final s = ReceiptsSummaryBuilder.stats(sample);
      final m = metrics(specFor(sample), 'Statistics');
      expect(m['Total Receipts']!.raw, s.totalReceipts);
      expect(m['Sales Receipts']!.raw, s.typeCount(ReceiptType.sales));
      expect(m['Invoice Payments']!.raw, 1);
      expect(m['Total Revenue']!.raw, s.totalRevenue);
      expect(m['Total Profit/Loss']!.raw, s.knownProfit);
      expect(
        m['Total Profit/Loss']!.note,
        'From ${s.profitKnownCount} of ${s.totalReceipts} receipts',
      );
      expect(m['Average Receipt Value']!.raw, s.averageReceiptValue);
      expect(m['Total Customers']!.raw, s.distinctCustomers);
      expect(m['Total Customers']!.note, '+ 1 walk-in receipts');
      expect(m['Bank Transactions']!.raw, 1);
      final c = metrics(specFor(sample), 'Collected by Method');
      expect(c['Cash']!.raw, s.collectedCash);
      expect(c['Bank']!.raw, s.collectedBank);
    });

    test('no cost access: no profit card or profit columns', () {
      final spec = specFor(sample, canSeeCost: false);
      expect(metrics(spec, 'Statistics').containsKey('Total Profit/Loss'), isFalse);
      for (final t in resolved(spec).tables) {
        expect(t.indexOf('profit'), -1, reason: t.title);
      }
    });
  });

  group('tables', () {
    test('rankings, channels and types', () {
      final spec = specFor(sample);
      // Bola's ₦2,500 bank sale outranks Ada's ₦1,500.
      expect(col(table(spec, 'Top 3 Staff'), 'name'), ['Bola', 'Ada']);
      expect(table(spec, 'Top 3 Staff').indexOf('average'), greaterThan(0));
      expect(table(spec, 'Least 3 Staff').indexOf('average'), -1);
      expect(
        col(table(spec, 'Payment Channel Summary'), 'name'),
        ['Cash', 'Bank', 'Customer Account', 'Split'],
      );
      expect(
        col(table(spec, 'Transaction Type Summary'), 'name'),
        ['Sales', 'Invoice Payment', 'Order Delivery'],
      );
      expect(table(spec, 'Staff Summary').indexOf('share'), greaterThan(0));
      expect(table(spec, 'Customer Summary').indexOf('lastDate'), greaterThan(0));
    });

    test('Customer Summary carries every customer, not the 20 preview', () {
      final rows = run([
        for (var i = 0; i < 25; i++)
          row(receipt(
            uuid: 'r-$i',
            barcode: '$i',
            cash: 100.0 + i,
            customerUuid: 'c-$i',
            customerName: 'Customer $i',
          )),
      ]);
      final t = table(specFor(rows), 'Customer Summary');
      expect(t.rows, hasLength(25));
      expect(t.rows.first[t.indexOf('name')].text, 'Customer 24');
    });
  });

  group('info box and notes', () {
    test('period and filters', () {
      final spec = specFor(
        sample,
        filters: ReceiptsReportFilters(staffKey: 'staff-a', type: ReceiptType.sales),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      );
      expect({for (final f in spec.filters) f.label: f.value}, {
        'Staff': 'Ada',
        'Type': 'Sales',
      });
      expect(spec.period!.label, 'Oct 17, 2026');
    });

    test('exactly the screen notes, from the screen conditions', () {
      final s = ReceiptsSummaryBuilder.stats(sample);
      // Bola's receipt has no item data, so profit is partly unknown.
      expect(s.profitUnknownCount, greaterThan(0));
      final spec = specFor(sample);
      expect(spec.notes, [
        'All time covers the receipts loaded on this device.',
        'Revenue counts every receipt type (sales, invoice payments and '
            'order deliveries); the average is per Sales receipt.',
        'Profit is from ${s.profitKnownCount} of ${s.totalReceipts} receipts: '
            '${s.profitUnknownCount} without item data, '
            '${s.costMissingCount} with a missing cost price (counted as 0).',
      ]);
      // One day and no cost access: only the revenue note, as on screen.
      final day = specFor(
        sample,
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        canSeeCost: false,
      );
      expect(day.notes, hasLength(1));
      expect(day.notes.single, startsWith('Revenue counts every receipt type'));
      final info = {
        for (final e in reportPdfInfoEntries(resolved(spec))) e.$1: e.$2,
      };
      expect(info['Notes'], spec.notes.join('\n'));
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: Metric · Value pairs, tables fit', () {
        final text = renderRollEscPos(
          buildRollLines(specFor(sample), testCtx, paper: paper),
          paper,
        ).preview;
        final out = text.split('\n');
        expect(out.firstWhere((l) => l.startsWith('Total Revenue')), endsWith('N4,000.00'));
        expect(out.firstWhere((l) => l.startsWith('Total Receipts')), endsWith('3'));
        expect(text, contains('PAYMENT CHANNEL SUMMARY'));
        // Wrapped note lines are small (Font B, 9 dots wide).
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        expect(
          out.where((l) => l.contains('N')).where((l) => l.contains('.00')).every((l) => l.length <= paper.chars),
          isTrue,
        );
      });
    }
  });

  group('Receipts Summary screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ReceiptsReportSummaryView(isDesktop: desktop),
          desktop: desktop,
        );
        // In the toolbar at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
