import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/documents/document_downloads.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

// The download buttons' pure parts: which mapper each one uses, the
// shop's details on the page, file names, and the order download
// producing a real PDF.

final _logo = Uint8List.fromList([1, 2, 3]);
final _assets = DocShopAssets(
  logo: _logo,
  logoIsWide: true,
  reference: '00007',
);
final _shop = shopOf(bottomText: 'No refunds after 7 days');

// The body of a top-level function in a source file, up to the next
// line that closes it.
String _function(String path, String signature) {
  final source = File(path).readAsStringSync();
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature in $path');
  final end = source.indexOf('\n}\n', start);
  return source.substring(start, end);
}

// Lines that aren't comments.
List<String> _code(String path) => File(path)
    .readAsLinesSync()
    .where((line) => !line.trimLeft().startsWith('//'))
    .toList();

void main() {
  group('each download uses its own mapper', () {
    test('receipt', () {
      final doc = receiptDownloadDocument(
        receipt: receiptOf(cash: 12000, originalCost: 12000),
        records: [sodaCrates()],
        staffName: 'Ada',
        shop: _shop,
        assets: _assets,
      );
      expect(doc.type, DocType.receipt);
      expect(doc.lines.single.unit, 'Crate');
      expect(doc.infoValue('Staff'), 'Ada');
    });

    test('invoice, paid from its own payments', () {
      final doc = invoiceDownloadDocument(
        invoice: invoiceOf(total: 12000, originalCost: 12000),
        records: [sodaCrates()],
        receipts: [receiptOf(cash: 2000, invoiceUuid: invoiceUuid)],
        staffName: 'Ada',
        shop: _shop,
        assets: _assets,
      );
      expect(doc.type, DocType.invoice);
      expect(doc.totals.paid, 2000);
      expect(doc.status, DocPaymentStatus.partPaid);
    });

    test('order, with the items passed and its receipts', () {
      final soda = orderLine(
        name: 'Soda',
        quantity: 3,
        remaining: 1,
        originalCostPerBase: 500,
        units: [each, crate],
        unitUuid: 'u-crate',
      );
      final doc = orderDownloadDocument(
        order: orderOf(items: [], total: 18000, originalCost: 18000),
        items: [soda],
        receipts: [receiptOf(cash: 6000, orderUuid: orderUuid)],
        shop: _shop,
        assets: _assets,
      );
      expect(doc.type, DocType.order);
      expect(doc.lines.single.delivered, 2);
      expect(doc.totals.paid, 6000);
    });

    test('purchase', () {
      final doc = purchaseDownloadDocument(
        purchase: purchaseOf(total: 2000, payments: []),
        items: [
          purchaseLine(
            name: 'Plywood',
            quantity: 1,
            total: 2000,
            unitName: 'Sheet',
          ),
        ],
        shop: _shop,
        assets: _assets,
      );
      expect(doc.type, DocType.purchase);
      expect(doc.infoValue('Supplier'), 'Delta Wholesale');
    });
  });

  test('the page shows the shop, its logo, reference and footer', () {
    final doc = receiptDownloadDocument(
      receipt: receiptOf(cash: 12000, originalCost: 12000),
      records: [sodaCrates()],
      staffName: 'Ada',
      shop: _shop,
      assets: _assets,
    );
    expect(doc.shop.name, 'Mama Put Supermarket');
    expect(doc.shop.logo, _logo);
    expect(doc.shop.logoIsWide, isTrue);
    expect(doc.shop.reference, 'Shop ID: 00007');
    expect(doc.footerText, 'No refunds after 7 days');
  });

  test('amounts are in the shop\'s currency', () {
    final shop = shopOf(currency: r'$');
    final doc = receiptDownloadDocument(
      receipt: receiptOf(cash: 12000, originalCost: 12000),
      records: [sodaCrates()],
      staffName: 'Ada',
      shop: shop,
      assets: const DocShopAssets(),
    );
    final totals = salesDocumentLayout(
      doc,
      docFormatFor(shop),
    ).sectionsOf<DocTotalsSection>().single.rows;
    expect(totals.last.value, r'$12,000.00');
  });

  group('file names', () {
    final at = DateTime.fromMillisecondsSinceEpoch(1730000000000);

    test('order: downloaded_order_<first 5 of id>.<time>', () {
      expect(
        documentDownloadName(DocType.order, orderUuid, at),
        'downloaded_order_31112.1730000000000',
      );
      expect(
        documentWebDownloadName(DocType.order, at),
        'downloaded_order_1730000000000.pdf',
      );
    });

    test('receipt keeps the name it had', () {
      // The name generateAndPreviewPdf built before.
      final before =
          'downloaded_receipt_${receiptUuid.substring(0, 5)}.${at.millisecondsSinceEpoch}';
      expect(documentDownloadName(DocType.receipt, receiptUuid, at), before);
      expect(
        documentWebDownloadName(DocType.receipt, at),
        'downloaded_receipt_1730000000000.pdf',
      );
    });

    test('a missing or short id does not throw', () {
      expect(
        documentDownloadName(DocType.order, null, at),
        'downloaded_order_.1730000000000',
      );
      expect(
        documentDownloadName(DocType.order, 'ab', at),
        'downloaded_order_ab.1730000000000',
      );
    });
  });

  test('the order download produces an A4 PDF', () async {
    final shop = shopOf();
    final bytes = await salesDocumentA4Pdf(
      orderDownloadDocument(
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
        receipts: const [],
        shop: shop,
        assets: const DocShopAssets(),
      ),
      shop,
      fonts: appFonts(),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });

  // The wiring in the app files: each A4 builder now calls the shared
  // builder through its own mapper, and the order buttons call the
  // order download instead of commented-out code.
  group('wiring', () {
    test('receipt, invoice and purchase builders use their mappers', () {
      final builders = {
        'lib/constants/functions.dart': (
          'Future<Uint8List> _buildPdf(',
          'receiptDownloadDocument(',
        ),
        'lib/constants/invoice_print_and_download.dart': (
          'Future<Uint8List> _buildPdfInvoice(',
          'invoiceDownloadDocument(',
        ),
        'lib/constants/purchase_print_and_download.dart': (
          'Future<Uint8List> _buildPdfPurchase(',
          'purchaseDownloadDocument(',
        ),
        'lib/constants/order_print_and_download.dart': (
          'Future<Uint8List> _buildPdfOrder(',
          'orderDownloadDocument(',
        ),
      };
      builders.forEach((path, pair) {
        final body = _function(path, pair.$1);
        expect(body, contains(pair.$2), reason: path);
        expect(body, contains('salesDocumentA4Pdf('), reason: path);
        expect(body, isNot(contains('PdfPageFormat.a5')), reason: path);
      });
    });

    test('order Download buttons call the order download', () {
      for (final path in [
        'lib/pages/orders/order_page/order_page_desktop.dart',
        'lib/pages/orders/order_page/order_page_mobile.dart',
      ]) {
        final code = _code(path);
        expect(
          code.where((l) => l.contains('await generateAndPreviewPdfOrder(')),
          hasLength(1),
          reason: path,
        );
        expect(
          code.where((l) => l.contains('await downloadPdfWebOrder(')),
          hasLength(1),
          reason: path,
        );
      }
    });

    test('the receipt download checks for web before Platform', () {
      final body = _function(
        'lib/constants/functions.dart',
        'Future<void> generateAndPreviewPdf({',
      );
      expect(
        body.indexOf('if (kIsWeb)'),
        lessThan(body.indexOf('Platform.isAndroid')),
      );
      expect(body, contains('finally'));
    });
  });
}
