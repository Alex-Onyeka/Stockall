import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/services/documents/a4_document_pdf.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/pdf_document_kit.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

SalesDocument _receipt({
  List<String> names = const ['Soda'],
  DocShop? shop,
}) {
  return receiptDocument(
    receipt: receiptOf(
      cash: 10000,
      bank: 7035,
      account: 5000,
      originalCost: 22600,
      vat: 7.5,
      generalDiscount: 10,
      customerName: 'Bola Stores',
      comment: 'Thanks for coming',
    ),
    records: [
      for (final name in names)
        saleLine(
          name: name,
          quantity: 2,
          originalCost: 12000,
          units: [each, crate],
          unitUuid: 'u-crate',
        ),
      glassSheets(),
    ],
    staffName: 'Ada',
    shop: shop ?? docShopFrom(shopOf(bottomText: 'Thank you')),
    fmt: naira,
  );
}

SalesDocument _invoice() => invoiceDocument(
  invoice: invoiceOf(total: 15600, originalCost: 16000, vat: 7.5),
  records: [sodaCrates(), glassByArea()],
  receipts: [receiptOf(cash: 5000, invoiceUuid: invoiceUuid)],
  shop: docShopFrom(shopOf()),
  fmt: naira,
);

SalesDocument _order() => orderDocument(
  order: orderOf(
    items: [
      orderLine(
        name: 'Soda',
        quantity: 3,
        remaining: 1,
        originalCostPerBase: 500,
        units: [each, crate],
        unitUuid: 'u-crate',
      ),
    ],
    total: 18000,
    originalCost: 18000,
  ),
  receipts: [receiptOf(cash: 6000, orderUuid: orderUuid)],
  shop: docShopFrom(shopOf()),
  fmt: naira,
);

SalesDocument _purchase() => purchaseDocument(
  purchase: purchaseOf(
    total: 20000,
    payments: [purchasePayment(5000, 'Cash', soldAt)],
  ),
  items: [
    purchaseLine(name: 'Plywood', quantity: 10, total: 20000, unitName: 'Sheet'),
  ],
  shop: docShopFrom(shopOf()),
  fmt: naira,
);

// Renders the layout and returns the saved document plus anything the
// pdf package printed: a warning for each glyph a font lacks, and for
// any text left in a built-in font without Unicode support. Pages are
// laid out when added and painted when saved, so both run in the zone.
Future<(pw.Document, List<String>)> _render(
  DocLayout layout,
  DocFonts fonts,
) async {
  final printed = <String>[];
  final document = await runZoned(
    () async {
      final document = buildA4LayoutDocument(layout, fonts: fonts);
      await document.save();
      return document;
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => printed.add(line),
    ),
  );
  return (document, printed);
}

// Height a widget takes at the given width, with the document fonts.
double _heightAt(pw.Widget widget, DocFonts fonts, double width) {
  final context = pw.Context(
    document: PdfDocument(),
  ).inheritFrom(fonts.theme);
  widget.layout(context, pw.BoxConstraints(maxWidth: width));
  expect(widget.box!.width, lessThanOrEqualTo(width + 0.01));
  return widget.box!.height;
}

void main() {
  late DocFonts fonts;

  setUp(() => fonts = appFonts());

  group('every document type is a real A4 PDF', () {
    final docs = {
      'receipt': _receipt,
      'invoice': _invoice,
      'order': _order,
      'purchase': _purchase,
    };
    for (final entry in docs.entries) {
      test(entry.key, () async {
        final doc = entry.value();
        final bytes = await buildA4DocumentPdf(doc, naira, fonts: fonts);
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

        final (document, printed) = await _render(
          salesDocumentLayout(doc, naira),
          appFonts(),
        );
        final pages = document.document.pdfPageList.pages;
        expect(pages, hasLength(1));
        expect(pages.single.pageFormat, PdfPageFormat.a4);
        expect(printed, isEmpty);
      });
    }
  });

  test('sections run in the template order', () {
    final layout = salesDocumentLayout(_invoice(), naira);
    expect(layout.sections.map((s) => s.runtimeType.toString()), [
      'DocHeaderSection',
      'DocTitleSection',
      'DocInfoBoxSection',
      'DocBandSection',
      'DocTableSection',
      'DocTotalsSection',
      'DocBandSection',
      'DocTableSection',
      'DocBandSection',
      'DocTextSection',
    ]);
    expect(
      layout.sectionsOf<DocTotalsSection>().single.barcode,
      _invoice().number,
    );
    expect(
      layout.sectionsOf<DocInfoBoxSection>().single.heading,
      'General Information',
    );
    expect(
      layout.sectionsOf<DocBandSection>().map((b) => b.dark),
      [true, false, false],
    );
    expect(layout.footer.left, 'Invoice No. ${_invoice().number}');
  });

  group('Naira sign', () {
    test('the app font has the glyph, regular and bold', () {
      final context = pw.Context(document: PdfDocument());
      for (final font in [fonts.regular, fonts.bold]) {
        final pdfFont = font.getFont(context);
        expect(pdfFont.isRuneSupported(0x20A6), isTrue);
      }
    });

    test('renders with no missing-glyph warning', () async {
      final layout = salesDocumentLayout(_receipt(), naira);
      final money = layout.sectionsOf<DocTotalsSection>().single.rows;
      expect(money.first.value, startsWith('₦'));

      final (_, printed) = await _render(layout, fonts);
      expect(printed.where((l) => l.contains('Unable to find a font')),
          isEmpty);
    });

    test('the check catches a font without it', () async {
      final (_, printed) = await _render(
        salesDocumentLayout(_receipt(), naira),
        DocFonts(pw.Font.helvetica(), pw.Font.helveticaBold()),
      );
      expect(printed.join('\n'), contains('U+20a6'));
    });
  });

  group('long item names', () {
    final columns = [
      const DocColumn('#', flex: 1),
      const DocColumn('Item', flex: 11),
      const DocColumn('Qty', flex: 4, align: DocAlign.right),
      const DocColumn('Unit price', flex: 4, align: DocAlign.right),
      const DocColumn('Amount', flex: 4, align: DocAlign.right),
    ];
    double tableHeight(String name) => _heightAt(
      docTable(
        DocTableSection(columns, [
          DocRow(['1', name, '2 Crate', '₦6,000.00', '₦12,000.00']),
        ]),
        DocTheme.standard,
      ),
      fonts,
      515, // A4 width less the margins
    );

    // A 9pt line is about 11pt high: two extra lines add over 18pt.
    test('wrap inside the item column instead of overflowing', () {
      final short = tableHeight('Soda');
      final long = tableHeight(
        'Premium Imported Sparkling Orange Soda in Returnable Glass '
        'Bottles, Twelve Pack, Chilled, Limited Holiday Edition',
      );
      expect(long - short, greaterThan(18));
    });

    test('break a single unspaced word too', () {
      final short = tableHeight('Soda');
      final long = tableHeight('X' * 120);
      expect(long - short, greaterThan(18));
    });

    test('a full document with them still builds on one page', () async {
      final (document, printed) = await _render(
        salesDocumentLayout(
          _receipt(names: ['Soda ' * 40, 'Y' * 150]),
          naira,
        ),
        fonts,
      );
      expect(document.document.pdfPageList.pages, hasLength(1));
      expect(printed, isEmpty);
    });
  });

  test('a long item list runs onto more pages', () async {
    final (document, _) = await _render(
      salesDocumentLayout(
        _receipt(names: [for (var i = 1; i <= 80; i++) 'Item $i']),
        naira,
      ),
      fonts,
    );
    final pages = document.document.pdfPageList.pages;
    expect(pages.length, greaterThan(1));
    expect(pages.every((p) => p.pageFormat == PdfPageFormat.a4), isTrue);
  });

  test('a shop logo is drawn in the header', () async {
    final logo = img.encodePng(img.Image(width: 300, height: 100));
    final shop = docShopFrom(shopOf(), logo: logo, logoIsWide: true);
    expect(shop.logo, isNotNull);
    final (document, printed) = await _render(
      salesDocumentLayout(_receipt(shop: shop), naira),
      fonts,
    );
    expect(document.document.pdfPageList.pages, hasLength(1));
    expect(printed, isEmpty);
  });

  test('an invalid number gets no barcode', () {
    final layout = salesDocumentLayout(
      receiptDocument(
        receipt: receiptOf(cash: 100, originalCost: 100, barcode: 'ABC-1'),
        records: [],
        staffName: 'Ada',
        shop: docShopFrom(shopOf()),
        fmt: naira,
      ),
      naira,
    );
    expect(layout.sectionsOf<DocTotalsSection>().single.barcode, isNull);
    final items = layout.sectionsOf<DocTableSection>().first;
    expect(items.rows, isEmpty);
    expect(items.emptyText, 'No items');
  });
}
