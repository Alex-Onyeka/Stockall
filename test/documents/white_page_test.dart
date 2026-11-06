import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/pdf_document_kit.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

// Pages must be white, not transparent: PDF viewers in dark mode show a
// transparent page black, with the text unreadable. Each page starts
// with a white fill over its whole MediaBox, margins included.

// Page sizes, and how many pages open with a white fill of exactly that
// size, read from an uncompressed PDF.
(List<(String, String)>, Map<String, int>) _whitePages(String pdf) {
  final sizes = [
    for (final m in RegExp(
      r'/MediaBox\[0 0 ([\d.]+) ([\d.]+)\]',
    ).allMatches(pdf))
      (m.group(1)!, m.group(2)!),
  ];
  final fills = <String, int>{};
  for (final (w, h) in sizes.toSet()) {
    fills['$w x $h'] = '0 0 $w $h re 1 1 1 rg f'.allMatches(pdf).length;
  }
  return (sizes, fills);
}

void _expectAllPagesWhite(String pdf, {required int pages}) {
  final (sizes, fills) = _whitePages(pdf);
  expect(sizes, hasLength(pages));
  for (final (w, h) in sizes) {
    final count = sizes.where((s) => s == (w, h)).length;
    expect(fills['$w x $h'], count, reason: 'white fill on each $w x $h page');
  }
}

Future<String> _a4(SalesDocument doc) async {
  final pdf = buildA4LayoutDocument(
    salesDocumentLayout(doc, naira),
    fonts: appFonts(),
    compress: false,
  );
  return String.fromCharCodes(await pdf.save());
}

String _function(String path, String signature) {
  final source = File(path).readAsStringSync();
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature in $path');
  return source.substring(start, source.indexOf('\n}\n', start));
}

void main() {
  final docs = <String, SalesDocument Function()>{
    'receipt':
        () => receiptDocument(
          receipt: receiptOf(cash: 12000, originalCost: 12000),
          records: [sodaCrates()],
          staffName: 'Ada',
          shop: docShopFrom(shopOf()),
          fmt: naira,
        ),
    'invoice':
        () => invoiceDocument(
          invoice: invoiceOf(total: 12000, originalCost: 12000),
          records: [sodaCrates()],
          receipts: const [],
          shop: docShopFrom(shopOf()),
          fmt: naira,
        ),
    'order':
        () => orderDocument(
          order: orderOf(
            items: [
              orderLine(
                name: 'Soda',
                quantity: 2,
                remaining: 2,
                originalCostPerBase: 500,
                units: [each, crate],
                unitUuid: 'u-crate',
              ),
            ],
            total: 12000,
            originalCost: 12000,
          ),
          receipts: const [],
          shop: docShopFrom(shopOf()),
          fmt: naira,
        ),
    'purchase':
        () => purchaseDocument(
          purchase: purchaseOf(total: 2000, payments: []),
          items: [
            purchaseLine(
              name: 'Plywood',
              quantity: 1,
              total: 2000,
              unitName: 'Sheet',
            ),
          ],
          shop: docShopFrom(shopOf()),
          fmt: naira,
        ),
  };

  group('A4 pages have a full-page white background', () {
    for (final entry in docs.entries) {
      test(entry.key, () async {
        final pdf = await _a4(entry.value());
        expect(pdf, contains('0 0 595.27559 841.88976 re 1 1 1 rg f'));
        _expectAllPagesWhite(pdf, pages: 1);
      });
    }

    test('on every page of a long document', () async {
      final pdf = await _a4(
        receiptDocument(
          receipt: receiptOf(cash: 100, originalCost: 100),
          records: [
            for (var i = 0; i < 80; i++)
              saleLine(
                name: 'Item $i',
                quantity: 1,
                originalCost: 100,
                units: [each],
                unitUuid: 'u-each',
              ),
          ],
          staffName: 'Ada',
          shop: docShopFrom(shopOf()),
          fmt: naira,
        ),
      );
      final (sizes, _) = _whitePages(pdf);
      expect(sizes.length, greaterThan(1));
      _expectAllPagesWhite(pdf, pages: sizes.length);
    });
  });

  group('roll pages have a full-page white background', () {
    for (final format in [PdfPageFormat.roll57, PdfPageFormat.roll80]) {
      test('${format.width.round()}pt roll', () async {
        final pdf = pw.Document(compress: false);
        pdf.addPage(
          pw.Page(
            pageTheme: docPageTheme(
              pageFormat: format,
              margin: const pw.EdgeInsets.only(top: 5, bottom: 10),
              theme: appFonts().theme,
            ),
            build: (context) => pw.Column(
              children: [for (var i = 0; i < 20; i++) pw.Text('Line $i')],
            ),
          ),
        );
        final text = String.fromCharCodes(await pdf.save());
        // The roll is as long as its content; the fill matches it.
        _expectAllPagesWhite(text, pages: 1);
      });
    }

    test('the four roll PDFs use the white page theme', () {
      final builders = {
        'lib/constants/functions.dart': 'Future<Uint8List> _buildPdfRoll(',
        'lib/constants/invoice_print_and_download.dart':
            'Future<Uint8List> _buildPdfRollInvoice({',
        'lib/constants/order_print_and_download.dart':
            'Future<Uint8List> _buildPdfRollOrder({',
        'lib/constants/purchase_print_and_download.dart':
            'Future<Uint8List> _buildPdfRollPurchase({',
      };
      builders.forEach((path, signature) {
        expect(
          _function(path, signature),
          contains('pageTheme: docPageTheme('),
          reason: path,
        );
      });
    });
  });
}
