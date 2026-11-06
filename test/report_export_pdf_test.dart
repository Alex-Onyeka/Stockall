import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/pages/report/components/export/report_document_parts.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';

import 'report_export_fixtures.dart';

void main() {
  final fonts = loadTestFonts();

  Future<List<PdfPage>> pagesOf(ResolvedExport r) async {
    final doc = buildReportPdfDocument(r, fonts: fonts);
    await doc.save();
    return doc.document.pdfPageList.pages;
  }

  group('page orientation and font size', () {
    test('portrait up to 8 PDF columns, landscape above', () {
      expect(reportPdfLandscape(8), isFalse);
      expect(reportPdfLandscape(9), isTrue);
    });

    test('body font steps down above 10 columns, not below 6.5pt', () {
      expect(reportPdfBodySize(6), 7.5);
      expect(reportPdfBodySize(10), 7.5);
      expect(reportPdfBodySize(11), 7.25);
      expect(reportPdfBodySize(12), 7.0);
      expect(reportPdfBodySize(14), 6.5);
      expect(reportPdfBodySize(30), DocStyle.report.minBodySize);
    });

    test('Excel-only columns are not counted', () async {
      // 7 columns, one of them Excel-only: 6 in the PDF.
      final r = resolveExport(itemsSpec(sampleItems), testContext);
      expect(reportPdfMaxColumns(r), 6);
      final pages = await pagesOf(r);
      final format = pages.first.pageFormat;
      expect(format.width, lessThan(format.height));
      expect(format.width, closeTo(PdfPageFormat.a4.width, 0.01));
    });

    test('9 PDF columns turn the page landscape', () async {
      final r = resolveExport(
        itemsSpec(sampleItems, extraColumns: wideColumns(3)),
        testContext,
      );
      expect(reportPdfMaxColumns(r), 9);
      final format = (await pagesOf(r)).first.pageFormat;
      expect(format.width, greaterThan(format.height));
    });
  });

  group('long reports', () {
    test('more than 20 pages do not throw (maxPages is set)', () async {
      expect(reportPdfMaxPages, greaterThan(20));
      final rows = [
        for (var i = 0; i < 1500; i++)
          TItem(id: '$i', name: 'Item $i', qty: i.toDouble(), price: 10, total: 10.0 * i),
      ];
      final pages = await pagesOf(resolveExport(itemsSpec(rows), testContext));
      expect(pages.length, greaterThan(20));
    });

    test('the table header row repeats on every page', () {
      final table = docTable(
        DocStyle.report,
        fonts,
        columns: const [
          DocTableColumn(label: 'Name'),
          DocTableColumn(label: 'Total'),
        ],
        rows: const [
          ['Coke', '₦1.00'],
          ['Pie', '₦2.00'],
        ],
        totals: const ['TOTAL', '₦3.00'],
      );
      expect(table.children.first.repeat, isTrue);
      expect(table.children.skip(1).every((r) => !r.repeat), isTrue);
      expect(table.children.length, 4);
    });
  });

  group('content', () {
    test('the bundled font has the Naira sign', () {
      for (final bytes in [regularFontBytes(), boldFontBytes()]) {
        final parser = TtfParser(bytes);
        expect(parser.charToGlyphIndexMap[0x20A6], isNotNull);
        expect(parser.charToGlyphIndexMap[0x20A6], isNot(0));
      }
    });

    test('money cells carry ₦ and the PDF builds', () async {
      final r = resolveExport(itemsSpec(sampleItems), testContext);
      expect(r.tables.single.rows.first[3].text, '₦1,500.00');
      final bytes = await buildReportPdf(r, fonts: fonts);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('long text wraps instead of failing', () async {
      final rows = [
        TItem(
          id: '1',
          name: List.filled(200, 'Very long item name').join(' '),
          qty: 1,
          price: 1,
          total: 1,
        ),
        TItem(id: '2', name: 'X' * 400, qty: 1, price: 1, total: 1),
      ];
      final pages = await pagesOf(resolveExport(itemsSpec(rows), testContext));
      expect(pages, isNotEmpty);
    });

    test('very long cells are cut for the PDF only, ending with "…"', () {
      expect(reportPdfCellMaxChars, 300);

      // A 400-character item name: the resolved row keeps it whole
      // (Excel uses that), and the PDF cell is cut to 300 with "…".
      final name = 'y' * 400;
      final r = resolveExport(
        itemsSpec([TItem(id: '1', name: name, qty: 1, price: 1, total: 1)]),
        testContext,
      );
      final full = r.tables.single.rows.single.first.text;
      expect(full.length, 400);
      final cut = reportPdfCellText(full);
      expect(cut.length, 300);
      expect(cut, endsWith('…'));
      expect(cut, '${'y' * 299}…');

      // Trailing spaces before the cut are dropped, so "…" follows a word.
      final words = reportPdfCellText('word ' * 200);
      expect(words.length, lessThanOrEqualTo(300));
      expect(words, endsWith('word…'));

      // Short and exactly-300 texts are left alone.
      expect(reportPdfCellText('Coke'), 'Coke');
      final exact = 'x' * reportPdfCellMaxChars;
      expect(reportPdfCellText(exact), exact);
    });

    test('an empty report still builds one page', () async {
      final pages = await pagesOf(
        resolveExport(itemsSpec(const []), testContext),
      );
      expect(pages.length, 1);
    });

    test('summary sections build', () async {
      final summary = ExportSummarySection(
        title: 'Money In',
        metrics: const [
          ExportMetric(
            label: 'Total Revenue',
            value: 2500000000,
            note: '+10% vs previous period',
          ),
        ],
      );
      final pages = await pagesOf(
        resolveExport(
          itemsSpec(sampleItems, extraSections: [summary]),
          testContext,
        ),
      );
      expect(pages.length, 1);
    });
  });

  group('info box and footer', () {
    test('info entries cover the brief', () {
      final entries = reportPdfInfoEntries(
        resolveExport(itemsSpec(sampleItems), testContext),
      );
      final map = {for (final e in entries) e.$1: e.$2};
      expect(map['Report'], 'Items Report');
      expect(map['Period'], 'Oct 1, 2026 - Oct 31, 2026');
      expect(map['Filters Applied'], 'Stock level: In Stock; Search: co');
      expect(map['Sorted By'], 'Item Name (A-Z)');
      expect(map['Records'], '4');
      expect(map['Generated By'], 'Ada Obi');
      expect(map['Generated At'], 'Nov 4, 2026 | 02:05 PM');
      expect(map['Note'], contains('Excel export only'));
    });

    test('no filters reads "None", no Excel-only note without such columns', () {
      const spec = ReportExportSpec(
        reportName: 'General Report',
        fileSlug: 'general',
        sections: [],
      );
      final map = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testContext)))
          e.$1: e.$2,
      };
      expect(map['Filters Applied'], 'None');
      expect(map['Period'], 'All time');
      expect(map.containsKey('Note'), isFalse);
    });

    test('notes get a Notes row, one line each; none without notes', () {
      final with_ = {
        for (final e in reportPdfInfoEntries(
          resolveExport(itemsSpec(sampleItems, notes: sampleNotes), testContext),
        ))
          e.$1: e.$2,
      };
      expect(with_['Notes'], sampleNotes.join('\n'));
      final without = {
        for (final e in reportPdfInfoEntries(
          resolveExport(itemsSpec(sampleItems), testContext),
        ))
          e.$1: e.$2,
      };
      expect(without.containsKey('Notes'), isFalse);
      // Blank notes are dropped.
      final blank = resolveExport(
        itemsSpec(sampleItems, notes: const ['  ']),
        testContext,
      );
      expect(blank.meta.notes, isEmpty);
    });

    test('roll-only columns stay out of the PDF and its Excel note', () {
      final spec = ReportExportSpec(
        reportName: 'Plain',
        fileSlug: 'plain',
        sections: [
          ExportTableSection<TItem>(
            title: 'Items',
            rows: sampleItems,
            columns: [
              ExportColumn<TItem>(id: 'name', label: 'Item Name', value: (r) => r.name),
              rollOnlyColumn,
            ],
            roll: const RollLayout(cols58: ['nameQty'], cols80: ['nameQty']),
          ),
        ],
      );
      final r = resolveExport(spec, testContext);
      final t = r.tables.single;
      expect(t.pdfColumnIndexes, [0]);
      expect(t.excelColumnIndexes, [0]);
      expect(r.hasExcelOnlyColumns, isFalse);
      final map = {for (final e in reportPdfInfoEntries(r)) e.$1: e.$2};
      expect(map.containsKey('Note'), isFalse);
    });

    test('footer shows the page count and generated time only', () {
      final labels = docFooterLabels(
        generatedAt: 'Nov 4, 2026 | 02:05 PM',
        page: 2,
        pages: 5,
      );
      expect(labels.left, 'Generated: Nov 4, 2026 | 02:05 PM');
      expect(labels.right, 'Page 2 of 5');
      expect('${labels.left}${labels.right}', isNot(contains('Stockall')));
    });
  });

  group('white page background (dark-mode viewers)', () {
    test('the page theme paints a full-page box in the style colour', () {
      final theme = docPageTheme(
        DocStyle.report,
        format: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
      );
      expect(theme.buildBackground, isNotNull);
      expect(DocStyle.report.pageBackground, PdfColors.white);
      final bg = docPageBackground(DocStyle.report);
      expect(bg, isA<pw.FullPage>());
      expect((bg as pw.FullPage).ignoreMargins, isTrue);
    });

    test('every A4 page starts with a white fill over the whole page', () async {
      final rows = [
        for (var i = 0; i < 200; i++)
          TItem(id: '$i', name: 'Item $i', qty: 1, price: 1, total: 1),
      ];
      for (final spec in [
        itemsSpec(rows),
        itemsSpec(rows, extraColumns: wideColumns(3)),
      ]) {
        final doc = buildReportPdfDocument(
          resolveExport(spec, testContext),
          fonts: fonts,
          compress: false,
        );
        final text = String.fromCharCodes(await doc.save());
        final pages = doc.document.pdfPageList.pages;
        expect(pages.length, greaterThan(1));
        final format = pages.first.pageFormat;
        final fills = whitePageFills(text, format);
        expect(
          fills.length,
          pages.length,
          reason: 'one white full-page fill per page',
        );
        // Painted before any text, so it sits underneath.
        expect(fills.first.start, lessThan(text.indexOf(' BT ')));
      }
    });
  });

  test('document parts are plain widgets', () {
    final s = DocStyle.report;
    expect(docBand(s, fonts, 'Items'), isA<pw.Widget>());
    expect(
      docInfoBox(s, fonts, title: 'Info', entries: const [('A', 'B'), ('C', 'D'), ('E', 'F')]),
      isA<pw.Widget>(),
    );
    expect(DocStyle.reportDarkBands.bandText, isNot(DocStyle.report.bandText));
  });
}
