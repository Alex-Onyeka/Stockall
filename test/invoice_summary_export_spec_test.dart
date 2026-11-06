import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/class/invoice_summary_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/class/invoice_summary_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/components/invoice_summary_view.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'invoice_report_export_spec_test.dart' show build, inv, pay;
import 'item_history_export_fixtures.dart' show testCtx;
import 'report_export_screen_harness.dart';

final now = DateTime(2026, 10, 17, 15);

final payments = [pay('i-1', 'p-1', cash: 1000), pay('i-2', 'p-2', bank: 500)];

final rows = build([
  inv('i-1', barcode: '1', customerUuid: 'c-chidi', customerName: 'Chidi'),
  inv(
    'i-2',
    barcode: '2',
    staffId: 'staff-b',
    staffName: 'Bola',
    customerUuid: 'c-chidi',
    customerName: 'Chidi',
    total: 2500,
  ),
  inv(
    'i-3',
    barcode: '3',
    customerUuid: 'c-dayo',
    customerName: 'Dayo',
    total: 1250000,
    departmentUuid: 'd-front',
    departmentName: 'Front Shop',
    subStaffUuid: 'sub-1',
    subStaffName: 'Kemi',
  ),
  inv('i-4', barcode: '4', staffId: '', staffName: '', total: 0),
], payments);

InvoiceSummaryResult summarize() => InvoiceSummaryBuilder.build(
  allRows: rows,
  allReceipts: payments,
  period: InvoiceSummaryPeriod.allTime,
  businessNow: now,
  departmentsEnabled: true,
  bulkSaleEnabled: true,
);

ReportExportSpec specFor({
  String search = '',
  InvoiceSummaryPeriod period = InvoiceSummaryPeriod.allTime,
  DateTimeRange? customRange,
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool bulkSaleEnabled = true,
}) {
  final r = summarize();
  return invoiceSummaryExportSpec(
    result: r,
    customers: invoiceSummaryCustomers(r.allCustomerSummaries, search),
    customerSearch: search,
    period: period,
    customRange: customRange,
    resolvedRange: InvoiceSummaryBuilder.resolveDateRange(
      period: period,
      businessNow: now,
      customRange: customRange,
    ),
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    bulkSaleEnabled: bulkSaleEnabled,
  );
}

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

Map<String, ResolvedMetric> statsOf(ReportExportSpec s) => {
  for (final m in resolved(s).sections.whereType<ResolvedSummary>().single.metrics)
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
      expect(specFor().sections.map((s) => s.title), [
        'Statistics',
        'Top Creditors',
        'Least Creditors',
        'Customer Summary',
        'Staff Summary',
        'Department Summary',
        'Sub-Staff Summary',
        'Invoice Status Summary',
      ]);
      expect(specFor().splitOptions, isEmpty);
      expect(specFor().fileSlug, 'invoice_summary');
      final off = specFor(departmentsEnabled: false, bulkSaleEnabled: false);
      expect(off.sections.map((s) => s.title), isNot(contains('Department Summary')));
      expect(off.sections.map((s) => s.title), isNot(contains('Sub-Staff Summary')));
      expect(specFor().notes, isEmpty);
    });
  });

  group('figures', () {
    test('the screen stats, with the card subtitles as notes', () {
      final s = summarize().stats;
      final m = statsOf(specFor());
      expect(m['Total Invoice Value']!.raw, s.totalInvoiceValue);
      expect(m['Total Invoice Value']!.note, '${s.totalInvoices} Qualifying Invoices');
      expect(m['Total Invoices']!.raw, s.totalInvoices);
      expect(
        m['Total Invoices']!.note,
        '${s.fullyPaidInvoices} Paid • ${s.partiallyPaidInvoices} Partial • '
        '${s.unpaidInvoices} Unpaid',
      );
      expect(m['Total Amount Paid']!.raw, s.totalAmountPaid);
      expect(m['Total Outstanding Balance']!.raw, s.totalOutstandingBalance);
      expect(m['Fully Paid Invoices']!.raw, s.fullyPaidInvoices);
      expect(m['Partially Paid Invoices']!.raw, s.partiallyPaidInvoices);
      expect(m['Unpaid Invoices']!.raw, s.unpaidInvoices);
      expect(m['Total Customers']!.raw, s.totalCustomers);
      expect(m['Total Staff Involved']!.raw, s.totalStaffInvolved);
      // Shown only when above 0, as on screen.
      expect(m.containsKey('Unresolved Statuses'), s.unresolvedInvoices > 0);
    });
  });

  group('tables', () {
    test('creditors, staff and statuses as on screen', () {
      final r = summarize();
      final spec = specFor();
      expect(
        col(table(spec, 'Top Creditors'), 'name'),
        [for (final c in r.topCreditors) c.customerName],
      );
      expect(
        col(table(spec, 'Staff Summary'), 'name'),
        [for (final s in r.allStaffSummaries) s.staffName],
      );
      expect(table(spec, 'Staff Summary').indexOf('share'), greaterThan(0));
      expect(
        col(table(spec, 'Invoice Status Summary'), 'name').take(3),
        ['Paid', 'Partial', 'Unpaid'],
      );
    });

    test('Profit/Loss only with cost access', () {
      expect(table(specFor(), 'Customer Summary').indexOf('profit'), greaterThan(0));
      for (final t in resolved(specFor(canSeeCost: false)).tables) {
        expect(t.indexOf('profit'), -1, reason: t.title);
      }
    });

    test('the Customer table search applies, as on screen', () {
      final all = summarize().allCustomerSummaries;
      expect(invoiceSummaryCustomers(all, 'DAY').map((c) => c.customerName), ['Dayo']);
      final spec = specFor(search: 'day');
      expect(col(table(spec, 'Customer Summary'), 'name'), ['Dayo']);
      expect({for (final f in spec.filters) f.label: f.value}, {'Customer search': 'day'});
      expect(table(specFor(), 'Customer Summary').rows, hasLength(all.length));
    });
  });

  group('info box', () {
    test('the period selector text', () {
      expect(specFor().period!.label, 'All Time');
      expect(specFor(period: InvoiceSummaryPeriod.today).period!.label, 'Today');
      final custom = specFor(
        period: InvoiceSummaryPeriod.custom,
        customRange: DateTimeRange(
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 17),
        ),
      );
      expect(custom.period!.label, 'Oct 1, 2026 - Oct 17, 2026');
      expect(custom.period!.start, DateTime(2026, 10, 1));
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: Metric · Value pairs, amounts on one line', () {
        final text = renderRollEscPos(
          buildRollLines(specFor(), testCtx, paper: paper),
          paper,
        ).preview;
        final out = text.split('\n');
        // A long label may take its own line; the amount never wraps.
        final i = out.indexWhere((l) => l.startsWith('Total Invoice Value'));
        expect(
          out[i].endsWith('N1,253,500.00') || out[i + 1].trim() == 'N1,253,500.00',
          isTrue,
        );
        expect(
          out.firstWhere((l) => l.contains('Dayo') && l.contains('N1,250,000.00')),
          endsWith('N1,250,000.00'),
        );
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        expect(
          out.where((l) => l.contains('.00')).every((l) => l.length <= paper.chars),
          isTrue,
        );
      });
    }
  });

  group('Invoice Summary screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          InvoiceSummaryView(isDesktop: desktop),
          desktop: desktop,
        );
        // The load reads invoices, receipts, customers and customer
        // account receipts in turn (real I/O): give it a few more rounds.
        for (var i = 0; i < 4; i++) {
          await settleReportScreen(tester);
        }
        // Beside the period selector at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
