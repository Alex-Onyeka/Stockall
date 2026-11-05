import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'purchase_report_fixtures.dart';
import 'purchase_summary_test.dart'
    show day17, overpaidPurchase, pumpSummary, summaryPurchases;

const _tabs = [
  PurchaseBreakdownTab.suppliers,
  PurchaseBreakdownTab.staff,
  PurchaseBreakdownTab.status,
  PurchaseBreakdownTab.channel,
];

PurchaseSummaryResult summarize(List<TempPurchase> purchases, {ReceiptsReportPeriod? period}) =>
    PurchaseSummaryBuilder.build(
      rows: rows(purchases),
      period: period ?? day17,
      departmentsEnabled: false,
      closingTime: midnight,
      now: DateTime(2026, 10, 17, 15),
    );

ReportExportSpec specFor(
  List<TempPurchase> purchases, {
  ReceiptsReportPeriod? period,
  List<PurchaseBreakdownTab> tabs = _tabs,
  PurchaseBreakdownTab activeTab = PurchaseBreakdownTab.suppliers,
  PurchaseBreakdownSortField? sortField,
  bool ascending = false,
}) {
  return purchaseSummaryExportSpec(
    result: summarize(purchases, period: period),
    period: period ?? day17,
    tabs: tabs,
    activeTab: activeTab,
    sortField: sortField,
    ascending: ascending,
    currency: '₦',
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
    test('cards, rankings and breakdowns as on screen; no charts, no splits', () {
      final spec = specFor(summaryPurchases());
      expect(spec.sections.map((s) => s.title), [
        'Statistics',
        'Top 3 Suppliers',
        'Least 3 Suppliers',
        'Suppliers',
        'Staff',
        'Status',
        'Channel',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(spec.fileSlug, 'purchase_summary');
      final withDepts = specFor(
        summaryPurchases(),
        tabs: [..._tabs.take(2), PurchaseBreakdownTab.departments, ..._tabs.skip(2)],
      );
      expect(withDepts.sections.map((s) => s.title), contains('Departments'));
    });
  });

  group('figures', () {
    test('the screen stats, with the card subtitles as notes', () {
      final s = summarize(summaryPurchases()).stats;
      final m = statsOf(specFor(summaryPurchases()));
      expect(m['Total Purchases']!.raw, s.totalPurchases);
      expect(m['Total Spend']!.raw, s.totalSpend);
      expect(m['Total Paid']!.raw, s.totalPaid);
      expect(m['Outstanding Balance']!.raw, s.totalOutstanding);
      expect(m['Average Purchase Value']!.raw, s.averagePurchaseValue);
      expect(m['Items Purchased']!.raw, s.totalItems);
      expect(m['Suppliers Used']!.raw, s.distinctSuppliers);
      expect(m['Suppliers Used']!.note, '+1 with no supplier');
      expect(m['Staff Involved']!.note, '+1 with no staff');
      for (final st in PurchaseStatus.values) {
        expect(m[st.label]!.raw, s.statusCount(st), reason: st.label);
      }
      // Overpaid only when above 0, as on screen.
      expect(m.containsKey('Overpaid'), isFalse);
      final over = statsOf(specFor([...summaryPurchases(), overpaidPurchase()]));
      expect(over['Overpaid']!.raw, 1);
    });
  });

  group('tables', () {
    test('rankings and breakdowns are the screen rows', () {
      final r = summarize(summaryPurchases());
      final spec = specFor(summaryPurchases());
      expect(col(table(spec, 'Top 3 Suppliers'), 'name'), [for (final g in r.topSuppliers) g.label]);
      expect(col(table(spec, 'Least 3 Suppliers'), 'name'), [for (final g in r.leastSuppliers) g.label]);
      expect(
        col(table(spec, 'Suppliers'), 'name'),
        [for (final b in PurchaseSummaryBuilder.breakdown(r, PurchaseBreakdownTab.suppliers)) b.label],
      );
      expect(col(table(spec, 'Suppliers'), 'name').last, 'No supplier');
      expect(table(spec, 'Suppliers').indexOf('lastDate'), greaterThan(0));
      expect(table(spec, 'Status').indexOf('lastDate'), -1);
      expect(col(table(spec, 'Status'), 'name'), [for (final s in r.statuses) s.status.label]);
    });

    test('the open tab keeps the screen sort; the others their built order', () {
      final r = summarize(summaryPurchases());
      final spec = specFor(
        summaryPurchases(),
        activeTab: PurchaseBreakdownTab.suppliers,
        sortField: PurchaseBreakdownSortField.name,
        ascending: false,
      );
      final sorted = PurchaseSummaryBuilder.sortBreakdown(
        PurchaseSummaryBuilder.breakdown(r, PurchaseBreakdownTab.suppliers),
        field: PurchaseBreakdownSortField.name,
        ascending: false,
      );
      expect(col(table(spec, 'Suppliers'), 'name'), [for (final b in sorted) b.label]);
      expect(col(table(spec, 'Suppliers'), 'name'), ['Bolt', 'Acme', 'No supplier']);
      expect(
        col(table(spec, 'Staff'), 'name'),
        [for (final b in PurchaseSummaryBuilder.breakdown(r, PurchaseBreakdownTab.staff)) b.label],
      );
    });
  });

  group('info box and notes', () {
    test('the period and the All time note exactly as on screen', () {
      expect(specFor(summaryPurchases()).notes, isEmpty);
      expect(specFor(summaryPurchases()).period!.label, 'Oct 17, 2026');
      final all = specFor(summaryPurchases(), period: const ReceiptsReportPeriod.allTime());
      expect(all.notes, ['All time covers the purchases loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolved(all))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: Metric · Value pairs, amounts on one line', () {
        final text = renderRollEscPos(
          buildRollLines(specFor(summaryPurchases()), testCtx, paper: paper),
          paper,
        ).preview;
        final out = text.split('\n');
        expect(out.firstWhere((l) => l.startsWith('Total Spend')), endsWith('N450.00'));
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        expect(
          out.where((l) => l.contains('.00')).every((l) => l.length <= paper.chars),
          isTrue,
        );
      });
    }
  });

  group('Purchase Summary screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpSummary(
          tester,
          isDesktop: desktop,
          env: fakeEnv(purchases: summaryPurchases()),
        );
        // Beside the period button at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
