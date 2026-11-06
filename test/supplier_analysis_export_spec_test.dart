import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/class/supplier_analysis_export_spec.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/class/supplier_analysis_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'supplier_analysis_test.dart' show pumpAnalysis;
import 'supplier_report_fixtures.dart';

final acme = supplier(
  'sup-a',
  name: 'Acme',
  phone: '08010000000',
  address: '1 Market Road',
  city: 'Lagos',
  country: 'Nigeria',
);

/// Seven Acme purchases (so the screen's 5 are a part), one without
/// line data and one with a custom total.
List<TempPurchase> acmePurchases({bool withNotes = true}) => [
  for (var i = 1; i <= 5; i++)
    bought(
      i,
      supplierId: 'sup-a',
      day: 10 + i,
      total: 100.0 * i,
      paid: 50,
      items: [
        namedLine(
          purchaseId: uuidN(i),
          itemId: 'product-$i',
          itemName: 'Item $i',
          total: 100.0 * i,
        ),
      ],
    ),
  bought(
    6,
    supplierId: 'sup-a',
    day: 9,
    total: 1250000,
    noItems: withNotes,
    items: withNotes ? null : [namedLine(purchaseId: uuidN(6), total: 1250000)],
  ),
  bought(
    7,
    supplierId: 'sup-a',
    day: 8,
    total: withNotes ? 900 : 800,
    isCustomPriceSet: withNotes,
    items: [namedLine(purchaseId: uuidN(7), itemId: 'product-7', itemName: 'Item 7', total: 800)],
  ),
];

SupplierAnalysisResult analyse(List<TempPurchase> purchases, {ReceiptsReportPeriod? period}) =>
    SupplierAnalysisBuilder.build(
      supplierKey: 'sup-a',
      purchaseRows: rows(purchases),
      suppliers: [acme],
      allSuppliers: [acme],
      period: period ?? const ReceiptsReportPeriod.allTime(),
      departmentsEnabled: false,
      closingTime: midnight,
      now: DateTime(2026, 10, 20),
    );

ReportExportSpec specFor(SupplierAnalysisResult r, {ReceiptsReportPeriod? period}) =>
    supplierAnalysisExportSpec(
      result: r,
      period: period ?? const ReceiptsReportPeriod.allTime(),
    );

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

Map<String, ResolvedMetric> metrics(ReportExportSpec s, String title) => {
  for (final m in resolved(s)
      .sections
      .whereType<ResolvedSummary>()
      .firstWhere((x) => x.title == title)
      .metrics)
    m.label: m,
};

ResolvedTable table(ReportExportSpec s, String prefix) =>
    resolved(s).tables.firstWhere((t) => t.title.startsWith(prefix));

void main() {
  group('sections', () {
    test('contact, KPIs, top items and recent purchases; no charts, no splits', () {
      final spec = specFor(analyse(acmePurchases()));
      expect(spec.sections.map((s) => s.title.split(' (').first), [
        'Contact Details',
        'Statistics',
        'Top Items',
        'Recent Purchases',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect({for (final f in spec.filters) f.label: f.value}, {'Supplier': 'Acme'});
    });
  });

  group('figures', () {
    test('contact details, blanks "—"', () {
      final m = metrics(specFor(analyse(acmePurchases())), 'Contact Details');
      expect(m['Phone']!.text, '08010000000');
      expect(m['Email']!.text, '—');
      expect(m['Address']!.text, '1 Market Road, Lagos, Nigeria');
      expect(m.containsKey('Status'), isFalse);
    });

    test('the KPIs are the supplier row the screen shows', () {
      final r = analyse(acmePurchases());
      final m = metrics(specFor(r), 'Statistics');
      final s = r.supplier;
      expect(m['Purchases']!.raw, s.purchaseCount);
      expect(m['Total Spend']!.raw, s.spend);
      expect(m['Total Paid']!.raw, s.paid);
      expect(m['Balance Owed']!.raw, s.balance);
      expect(m['Average Purchase']!.raw, s.average);
      expect(m['First Purchase']!.raw, s.firstPurchase);
      expect(m['Last Purchase']!.raw, s.lastPurchase);
      expect(m['Total Spend']!.note, 'Total of the purchases');
    });
  });

  group('tables', () {
    test('the screen\'s 5 recent purchases and top items', () {
      final r = analyse(acmePurchases());
      final spec = specFor(r);
      final recent = table(spec, 'Recent Purchases');
      expect(recent.title, 'Recent Purchases (5 of 7 purchases in this period)');
      expect(
        [for (final row in recent.rows) row[recent.indexOf('id')].text],
        [for (final p in r.recent) p.displayId],
      );
      final top = table(spec, 'Top Items');
      expect([for (final row in top.rows) row[top.indexOf('name')].text], [
        for (final i in r.topItems) i.name,
      ]);
      expect(top.rows, hasLength(5));
    });
  });

  group('notes', () {
    test('the footnotes exactly when the screen shows them', () {
      final r = analyse(acmePurchases());
      expect(supplierTopItemsFootnotes(r), [
        '1 purchase without item details',
        'Some purchases have a custom total, so item spend can differ from '
            'total spend.',
      ]);
      final spec = specFor(r);
      expect(spec.notes, [
        'All time covers the purchases loaded on this device.',
        ...supplierTopItemsFootnotes(r),
      ]);
      final info = {
        for (final e in reportPdfInfoEntries(resolved(spec))) e.$1: e.$2,
      };
      expect(info['Notes'], spec.notes.join('\n'));
      // Neither footnote, and not all time: no notes.
      final clean = analyse(
        acmePurchases(withNotes: false),
        period: ReceiptsReportPeriod.range(DateTime(2026, 10, 1), DateTime(2026, 10, 20)),
      );
      expect(supplierTopItemsFootnotes(clean), isEmpty);
      expect(
        specFor(
          clean,
          period: ReceiptsReportPeriod.range(DateTime(2026, 10, 1), DateTime(2026, 10, 20)),
        ).notes,
        isEmpty,
      );
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: pairs and tables fit', () {
        final out = renderRollEscPos(
          buildRollLines(specFor(analyse(acmePurchases())), testCtx, paper: paper),
          paper,
        ).preview.split('\n');
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        // Total Spend: 1,500 + 1,250,000 + 900, on one line.
        final spend = out.where((l) => l.contains('N1,252,400.00')).toList();
        expect(spend, isNotEmpty);
        expect(spend.every((l) => l.length <= paper.chars), isTrue);
      });
    }
  });

  group('Supplier Analysis screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpAnalysis(
          tester,
          isDesktop: desktop,
          env: fakeSupplierEnv(purchases: acmePurchases(), suppliers: [acme]),
          period: const ReceiptsReportPeriod.allTime(),
        );
        // Beside the period button at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
