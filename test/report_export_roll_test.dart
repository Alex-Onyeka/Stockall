import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/services/printing/escpos_builder.dart';

import 'report_export_fixtures.dart';

void main() {
  String preview(
    ReportExportSpec spec,
    RollPaper paper, {
    List<String?> groupings = const [null],
  }) {
    final lines = buildRollLines(
      spec,
      testContext,
      paper: paper,
      groupings: groupings,
    );
    return renderRollEscPos(lines, paper).preview;
  }

  List<String> linesOf(String text) => text.split('\n');

  /// Lines a reader sees, in order, without blank lines.
  List<String> visible(String text) =>
      linesOf(text).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  group('paper widths', () {
    test('58mm is 32 characters, 80mm is 48', () {
      expect(RollPaper.mm58.chars, 32);
      expect(RollPaper.mm80.chars, 48);
      expect(RollPaper.mm58.maxColumns, 2);
      expect(RollPaper.mm80.maxColumns, 3);
    });

    for (final paper in RollPaper.values) {
      test('no line is wider than the paper (${paper.name})', () {
        final text = preview(itemsSpec(sampleItems), paper);
        final small = paper.dots ~/ fontBDots;
        for (final line in linesOf(text)) {
          expect(line.length, lessThanOrEqualTo(small), reason: line);
          // Only small sub-lines (indented) may use the Font B width.
          if (!line.startsWith('  ')) {
            expect(line.length, lessThanOrEqualTo(paper.chars), reason: line);
          }
        }
      });
    }
  });

  group('header', () {
    test('shop, title, period, printed by, filters and sort', () {
      final v = visible(preview(itemsSpec(sampleItems), RollPaper.mm80));
      expect(v, containsAllInOrder([
        'Mama Put Stores',
        'ITEMS REPORT',
        'Period: Oct 1, 2026 - Oct 31, 2026',
        'Printed: Nov 4, 2026 | 02:05 PM',
        'By: Ada Obi',
        'Stock level: In Stock',
        'Search: co',
        'Sorted by: Item Name (A-Z)',
      ]));
    });

    test('the shop name prints double width only when it fits', () {
      final lines = buildRollLines(
        itemsSpec(sampleItems),
        testContext,
        paper: RollPaper.mm58,
      );
      expect((lines.first as RollText).large, isTrue);

      final longShop = ExportContext(
        shopName: 'The Very Long Shop Name Limited',
        currencySymbol: '₦',
        generatedBy: 'A',
        generatedAt: DateTime(2026),
      );
      final long = buildRollLines(
        itemsSpec(sampleItems),
        longShop,
        paper: RollPaper.mm58,
      );
      expect((long.first as RollText).large, isFalse);
    });
  });

  group('compact columns', () {
    test('58mm prints name and quantity only', () {
      final text = preview(itemsSpec(sampleItems), RollPaper.mm58);
      final coke = linesOf(text).firstWhere((l) => l.startsWith('Coke'));
      expect(coke, contains('12 Bottles'));
      expect(coke, isNot(contains('N1,500.00')));
      expect(coke.length, lessThanOrEqualTo(32));
    });

    test('80mm adds the total and the date sub-line', () {
      final text = preview(itemsSpec(sampleItems), RollPaper.mm80);
      final lines = linesOf(text);
      final i = lines.indexWhere((l) => l.startsWith('Coke'));
      expect(lines[i], contains('N1,500.00'));
      expect(lines.skip(i).take(3).join('\n'), contains('  Oct 1, 2026'));
    });

    test('80mm caps at 3 columns even if the layout lists more', () {
      final lines = buildRollLines(
        ReportExportSpec(
          reportName: 'Items',
          fileSlug: 'items',
          sections: [
            ExportTableSection<TItem>(
              title: 'Items',
              rows: sampleItems,
              columns: itemsSection(sampleItems).columns,
              roll: const RollLayout(
                cols58: ['name', 'qty', 'price', 'total'],
                cols80: ['name', 'qty', 'price', 'total'],
              ),
            ),
          ],
        ),
        testContext,
        paper: RollPaper.mm80,
      );
      final rows = lines.whereType<RollColumns>().toList();
      expect(rows.every((r) => r.cells.length <= 3), isTrue);
    });

    test('a spec can set its own column widths (else the defaults)', () {
      String cokeLine(RollLayout layout) {
        final spec = ReportExportSpec(
          reportName: 'Items',
          fileSlug: 'items',
          sections: [
            ExportTableSection<TItem>(
              title: 'Items',
              rows: sampleItems,
              columns: itemsSection(sampleItems).columns,
              roll: layout,
            ),
          ],
        );
        return preview(spec, RollPaper.mm80)
            .split('\n')
            .firstWhere((l) => l.startsWith('Coke'));
      }

      // Default 5/2/3: the quantity column is too narrow for "12 Bottles".
      const cols = ['name', 'qty', 'total'];
      expect(
        cokeLine(const RollLayout(cols58: cols, cols80: cols)),
        isNot(contains('12 Bottles')),
      );
      // 4/3/3 fits it on one line.
      final wide = cokeLine(
        const RollLayout(cols58: cols, cols80: cols, flex80: [4, 3, 3]),
      );
      expect(wide, contains('12 Bottles'));
      expect(wide, endsWith('N1,500.00'));
      expect(wide.length, 48);
      // A count that doesn't match the columns falls back to 5/2/3.
      expect(
        cokeLine(const RollLayout(cols58: cols, cols80: cols, flex80: [1, 1])),
        isNot(contains('12 Bottles')),
      );
    });

    test('money: N instead of ₦, sign first, no abbreviation', () {
      final text = preview(itemsSpec(sampleItems), RollPaper.mm80);
      expect(text, isNot(contains('₦')));
      expect(text, contains('-N1,500.00'));
      final big = [
        TItem(id: 'b', name: 'Big', qty: 1, price: 1, total: 1234567890.5),
      ];
      final bigText = preview(itemsSpec(big), RollPaper.mm80);
      expect(bigText, contains('N1,234,567,890.50'));
    });

    test('units and 2D sizes print as shown on screen', () {
      final text = preview(itemsSpec(sampleItems), RollPaper.mm80);
      expect(text, contains('2.5'));
      expect(text, contains('Trays'));
      // Narrow columns wrap the text onto the next line.
      final v = visible(text).join(' ');
      expect(v, contains('Not managed'));
      expect(v, contains('3 Sheets'));
      expect(v, contains('(4 x 2)'));
    });

    test('long names wrap inside their column', () {
      final rows = [
        const TItem(
          id: '1',
          name: 'Super Long Item Name That Keeps Going And Going',
          qty: 1,
          price: 1,
          total: 1,
        ),
      ];
      for (final paper in RollPaper.values) {
        final text = preview(itemsSpec(rows), paper);
        final wrapped = linesOf(text)
            .where((l) => l.contains('Long') || l.contains('Going'))
            .toList();
        expect(wrapped.length, greaterThan(1), reason: paper.name);
        for (final l in wrapped) {
          expect(l.length, lessThanOrEqualTo(paper.chars));
        }
      }
    });
  });

  group('totals', () {
    for (final paper in RollPaper.values) {
      test('every total prints after a heavy divider (${paper.name})', () {
        final text = preview(itemsSpec(sampleItems), paper);
        final lines = linesOf(text);
        final heavy = lines.indexWhere((l) => l.startsWith('===='));
        expect(heavy, greaterThan(0));
        expect(lines[heavy].length, paper.chars);
        final after = lines.skip(heavy).join('\n');
        expect(after, contains('TOTAL'));
        expect(after, contains('4 items'));
        final pair = lines.skip(heavy).firstWhere(
          (l) => l.startsWith('Total Selling Value'),
        );
        expect(pair, endsWith('N2,500.00'));
        expect(pair.length, paper.chars);
        expect(visible(text).last, 'Records: 4');
      });
    }

    test('a total too long for one line moves to its own line', () {
      final big = [
        TItem(id: 'b', name: 'Big', qty: 1, price: 1, total: 1234567890.5),
      ];
      final lines = linesOf(preview(itemsSpec(big), RollPaper.mm58));
      final i = lines.indexWhere((l) => l == 'Total Selling Value');
      expect(i, greaterThan(0));
      expect(lines[i + 1].trim(), 'N1,234,567,890.50');
      expect(lines[i + 1].length, lessThanOrEqualTo(32));
    });
  });

  group('sections', () {
    test('grouped by category: headings, subtotals, then grand totals', () {
      final v = visible(preview(
        itemsSpec(sampleItems),
        RollPaper.mm58,
        groupings: const ['category'],
      ));
      expect(v, containsAllInOrder([
        'ITEMS BY CATEGORY',
        'CATEGORY: BAKERY',
        'Subtotal (1)',
        'CATEGORY: DRINKS',
        'Subtotal (2)',
        'NO CATEGORY',
        'Subtotal (2)',
        'TOTAL',
        '4 items',
        'Records: 4',
      ]));
    });

    test('a group subtotal sums only that group', () {
      final text = preview(
        itemsSpec(sampleItems),
        RollPaper.mm80,
        groupings: const ['category'],
      );
      final lines = linesOf(text);
      final drinks = lines.indexWhere((l) => l.trim() == 'CATEGORY: DRINKS');
      final subtotal = lines.skip(drinks).firstWhere(
        (l) => l.startsWith('Total Selling Value'),
      );
      expect(subtotal, endsWith('N4,000.00'));
    });

    test('full breakdown: all, departments, categories in order', () {
      final v = visible(preview(
        itemsSpec(sampleItems),
        RollPaper.mm80,
        groupings: const [null, 'department', 'category'],
      ));
      expect(v, containsAllInOrder([
        'ITEMS',
        'ITEMS BY DEPARTMENT',
        'DEPARTMENT: BACK STORE',
        'DEPARTMENT: FRONT SHOP',
        'NO DEPARTMENT',
        'ITEMS BY CATEGORY',
        'CATEGORY: BAKERY',
      ]));
    });

    test('a split the table lacks prints the plain table', () {
      final v = visible(preview(
        itemsSpec(sampleItems),
        RollPaper.mm58,
        groupings: const ['supplier'],
      ));
      expect(v, contains('ITEMS'));
      expect(v.where((l) => l.startsWith('CATEGORY')), isEmpty);
    });

    test('summary metrics, with comparisons on 80mm only', () {
      final summary = ExportSummarySection(
        title: 'Money In',
        metrics: const [
          ExportMetric(
            label: 'Total Revenue',
            value: 2500,
            note: '+10% vs previous period',
          ),
        ],
      );
      final spec = itemsSpec(sampleItems, extraSections: [summary]);
      final wide = preview(spec, RollPaper.mm80);
      final narrow = preview(spec, RollPaper.mm58);
      expect(visible(wide), containsAllInOrder(['MONEY IN', '+10% vs previous period']));
      expect(
        linesOf(wide).firstWhere((l) => l.startsWith('Total Revenue')),
        endsWith('N2,500.00'),
      );
      expect(narrow, isNot(contains('vs previous')));
    });
  });

  group('empty data', () {
    for (final paper in RollPaper.values) {
      test('prints the message and zero records (${paper.name})', () {
        final text = preview(itemsSpec(const []), paper);
        expect(visible(text).join(' '), contains('No records match'));
        expect(visible(text).last, 'Records: 0');
      });
    }

    test('grouped and empty', () {
      final text = preview(
        itemsSpec(const []),
        RollPaper.mm58,
        groupings: const ['category'],
      );
      expect(visible(text).join(' '), contains('No records match'));
    });
  });

  group('outputs', () {
    test('ESC/POS without the cut when Printer Settings turns it off', () {
      final lines = buildRollLines(
        itemsSpec(sampleItems),
        testContext,
        paper: RollPaper.mm80,
      );
      final chunks = buildRollEscPos(lines, RollPaper.mm80, cut: false);
      expect(chunks.last, isNot([0x1D, 0x56, 0x01]));
      expect(
        chunks.where((c) => c.length == 3 && c[0] == 0x1D && c[1] == 0x56),
        isEmpty,
      );
    });

    test('ESC/POS ends with a feed and a partial cut', () {
      final lines = buildRollLines(
        itemsSpec(sampleItems),
        testContext,
        paper: RollPaper.mm80,
      );
      final chunks = buildRollEscPos(lines, RollPaper.mm80);
      expect(chunks.last, [0x1D, 0x56, 0x01]);
      expect(chunks.first.take(2), [0x1B, 0x40]);
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(escPosChunkBytes));
      }
    });

    test('the end feed is longer on 80mm', () {
      expect(RollPaper.mm58.endFeed, 3);
      expect(RollPaper.mm80.endFeed, 6);
    });

    for (final paper in RollPaper.values) {
      test('roll PDF builds at the roll width (${paper.name})', () async {
        final fonts = loadTestFonts();
        final lines = buildRollLines(
          itemsSpec(sampleItems),
          testContext,
          paper: paper,
          groupings: const [null, 'category'],
        );
        final doc = buildRollPdfDocument(lines, paper, fonts: fonts);
        final bytes = await doc.save();
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        final width = doc.document.pdfPageList.pages.first.pageFormat.width;
        final expected = paper == RollPaper.mm58
            ? PdfPageFormat.roll57.width
            : PdfPageFormat.roll80.width;
        expect(width, closeTo(expected, 0.01));
      });

      test('roll PDF page has a white background (${paper.name})', () async {
        final lines = buildRollLines(
          itemsSpec(sampleItems),
          testContext,
          paper: paper,
        );
        final doc = buildRollPdfDocument(
          lines,
          paper,
          fonts: loadTestFonts(),
          compress: false,
        );
        final text = String.fromCharCodes(await doc.save());
        final format = doc.document.pdfPageList.pages.single.pageFormat;
        final fills = whitePageFills(text, format);
        expect(fills.length, 1);
        expect(fills.first.start, lessThan(text.indexOf(' BT ')));
      });
    }
  });

  group('notes', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: notes print small under the header, wrapped', () {
        final text = preview(itemsSpec(sampleItems, notes: sampleNotes), paper);
        final lines = visible(text);
        final sort = lines.indexOf('Sorted by: Item Name (A-Z)');
        expect(lines[sort + 1], startsWith('* All time covers'));
        // The long note wraps (small lines use Font B, 9 dots wide).
        final smallWidth = paper.dots ~/ fontBDots;
        expect(text.split('\n').every((l) => l.length <= smallWidth), isTrue);
        final longNote = lines.indexWhere((l) => l.startsWith('* 2 receipts'));
        expect(lines[longNote].length, lessThan(sampleNotes[1].length + 2));
        expect(lines.join(' '), contains('missing cost price.'));
        expect(lines.indexWhere((l) => l.startsWith('* 2 receipts')), greaterThan(sort));
        expect(lines.indexWhere((l) => l == 'ITEMS'), greaterThan(sort + 1));
      });
    }

    test('no notes, no note lines', () {
      final text = preview(itemsSpec(sampleItems), RollPaper.mm80);
      expect(visible(text).where((l) => l.startsWith('* ')), isEmpty);
    });
  });
}
