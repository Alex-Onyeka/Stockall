import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stockall/constants/generate_barcode.dart' show returnOnlyDigits;
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/roll_document_escpos.dart';
import 'package:stockall/services/printing/escpos_builder.dart';

import '../documents/document_fixtures.dart';

// The roll print content as text (EscPosBuilder.preview), for each
// document type at 58mm and 80mm.

final _shop = docShopFrom(shopOf(), reference: '00007');

SalesDocument _receipt() => receiptDocument(
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
  records: [sodaCrates(), glassSheets(), glassByArea()],
  staffName: 'Ada Obi',
  shop: _shop,
  fmt: naira,
  footerText: 'Thank you',
);

SalesDocument _invoice() => invoiceDocument(
  invoice: invoiceOf(total: 15600, originalCost: 16000, vat: 7.5, generalDiscount: 10),
  records: [sodaCrates(), glassByArea()],
  receipts: [
    receiptOf(cash: 5000, invoiceUuid: invoiceUuid, createdAt: soldAt.add(const Duration(days: 1))),
    receiptOf(bank: 2000, account: 1000, invoiceUuid: invoiceUuid, createdAt: soldAt.add(const Duration(days: 2))),
  ],
  shop: _shop,
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
  shop: _shop,
  fmt: naira,
);

SalesDocument _purchase() => purchaseDocument(
  purchase: purchaseOf(
    total: 50000,
    payments: [
      purchasePayment(20000, 'Bank', soldAt),
      purchasePayment(10000, 'Cash', soldAt.add(const Duration(days: 1))),
    ],
  ),
  items: [
    purchaseLine(
      name: 'Noodles',
      quantity: 5,
      total: 30000,
      units: [
        unit('n-each', 'Each', primary: true, productUuid: 'noodles'),
        unit('n-carton', 'Carton', conversion: 12, productUuid: 'noodles'),
      ],
      unitUuid: 'n-carton',
    ),
    purchaseLine(name: 'Plywood', quantity: 10, total: 20000, unitName: 'Sheet'),
  ],
  shop: _shop,
  fmt: naira,
);

SalesDocument _invoicePayment() => receiptDocument(
  receipt: receiptOf(
    cash: 3000,
    bank: 2000,
    originalCost: 16000,
    vat: 7.5,
    generalDiscount: 10,
    invoiceUuid: invoiceUuid,
    balance: 10600,
    salesTypeIndex: 2,
  ),
  records: [sodaCrates()],
  staffName: 'Ada',
  shop: _shop,
  fmt: naira,
);

SalesDocument _orderDelivery() => receiptDocument(
  receipt: receiptOf(
    cash: 6000,
    originalCost: 18000,
    orderUuid: orderUuid,
    balance: 12000,
    salesTypeIndex: 3,
  ),
  records: [sodaCrates()],
  staffName: 'Ada',
  shop: _shop,
  fmt: naira,
);

List<String> _lines(SalesDocument doc, PosPaper paper, {bool cut = false}) =>
    buildRollEscPos(doc, naira, paper: paper, cut: cut).preview.split('\n');

// A line with [left] at the start and [right] at the end.
Matcher _row(String left, String right) => predicate<String>(
  (line) => line.startsWith(left) && line.trimRight().endsWith(right),
  '"$left ... $right"',
);

void main() {
  final docs = {
    'receipt': _receipt,
    'invoice': _invoice,
    'order': _order,
    'purchase': _purchase,
    'invoice payment': _invoicePayment,
    'order delivery': _orderDelivery,
  };

  for (final paper in PosPaper.values) {
    group('${paper.label} roll', () {
      final width = EscPosBuilder(paperDots: paper.dots).charsPerLine();
      final smallWidth = EscPosBuilder(
        paperDots: paper.dots,
      ).charsPerLine(small: true);

      for (final entry in docs.entries) {
        test('${entry.key}: nothing runs past the paper', () {
          final lines = _lines(entry.value(), paper);
          for (final line in lines) {
            expect(line.length, lessThanOrEqualTo(smallWidth), reason: line);
          }
          // Dividers are exactly one line wide.
          expect(lines, contains('-' * width));
          // Plain ASCII only.
          expect(lines.join().runes.every((r) => r < 0x7F), isTrue);
        });
      }

      test('receipt: header, lines, totals and one line per payment', () {
        final lines = _lines(_receipt(), paper);
        expect(lines.first, 'Mama Put Supermarket');
        expect(lines, containsAll(['SALES RECEIPT', 'Shop ID: 00007']));
        expect(lines, contains('No. ${_receipt().number}'));
        expect(lines, contains(_row('Customer:', 'Bola Stores')));
        expect(lines, contains(_row('2 Crate x N6,000.00', 'N12,000.00')));
        expect(lines, contains('  = 24 Each'));
        expect(lines, contains(_row('6.6 M2 x N1,000.00', 'N6,600.00')));
        expect(lines, contains('  incl. 0.6 M2 wastage'));
        expect(lines, contains(_row('Subtotal', 'N22,600.00')));
        expect(lines, contains(_row('Discount (10%)', '-N2,260.00')));
        expect(lines, contains(_row('VAT (7.5%)', 'N1,695.00')));
        expect(lines, contains(_row('Total', 'N22,035.00')));
        // Split payment: every channel, not only cash or bank.
        final payments = lines.sublist(lines.indexOf('Payments') + 1);
        expect(payments.take(3), [
          _row('Cash', 'N10,000.00'),
          _row('Bank', 'N7,035.00'),
          _row('Account', 'N5,000.00'),
        ]);
        expect(lines, containsAll(['Notes', 'Thanks for coming', 'THANK YOU']));
        expect(lines, contains('[EAN-13 ${_receipt().number.substring(0, 12)}]'));
      });

      test('invoice: paid, balance due and each payment with its date', () {
        final lines = _lines(_invoice(), paper);
        expect(lines, contains('INVOICE'));
        expect(lines, contains(_row('Status:', 'Part-paid')));
        expect(lines, contains(_row('VAT (7.5%)', 'N1,200.00')));
        expect(lines, contains(_row('Paid', 'N8,000.00')));
        expect(lines, contains(_row('Balance due', 'N7,600.00')));
        expect(lines, contains(_row('11 Oct 2026 Cash', 'N5,000.00')));
        expect(lines, contains(_row('12 Oct 2026 Bank', 'N2,000.00')));
        expect(lines, contains(_row('12 Oct 2026 Account', 'N1,000.00')));
      });

      test('order: delivered and outstanding per line', () {
        final lines = _lines(_order(), paper);
        expect(lines, contains('SALES ORDER'));
        expect(lines, contains(_row('3 Crate x N6,000.00', 'N18,000.00')));
        expect(
          lines.join(' '),
          contains('Delivered 2 Crate, outstanding 1 Crate'),
        );
        expect(lines, contains(_row('Delivery:', 'Partly delivered')));
        expect(lines, contains(_row('Balance', 'N12,000.00')));
      });

      test('purchase: supplier, unit cost and payments', () {
        final lines = _lines(_purchase(), paper);
        expect(lines, contains('PURCHASE RECORD'));
        expect(lines, contains(_row('Supplier:', 'Delta Wholesale')));
        expect(lines, contains(_row('5 Carton x N6,000.00', 'N30,000.00')));
        expect(lines, contains('  = 60 Each'));
        expect(lines, contains(_row('10 Oct 2026 Bank', 'N20,000.00')));
        expect(lines, contains(_row('Balance', 'N20,000.00')));
      });

      test('a payment on an invoice: amount paid and invoice balance', () {
        final lines = _lines(_invoicePayment(), paper);
        final invoiceNo = returnOnlyDigits(invoiceUuid);
        expect(
          lines.join(' '),
          contains('Payment for Invoice #$invoiceNo'.substring(0, 19)),
        );
        expect(lines.join(''), contains(invoiceNo));
        expect(lines, contains(_row('Amount paid', 'N5,000.00')));
        expect(lines, contains(_row('Invoice balance', 'N10,600.00')));
        for (final label in ['Subtotal', 'VAT', 'Discount', 'Total']) {
          expect(lines.where((l) => l.startsWith(label)), isEmpty, reason: label);
        }
        expect(lines, contains(_row('Cash', 'N3,000.00')));
        expect(lines, contains(_row('Bank', 'N2,000.00')));
      });

      test('a delivery on an order: amount paid and order balance', () {
        final lines = _lines(_orderDelivery(), paper);
        expect(lines.join(' '), contains('Delivery for Order'));
        expect(lines, contains(_row('Amount paid', 'N6,000.00')));
        expect(lines, contains(_row('Order balance', 'N12,000.00')));
        expect(lines.where((l) => l.startsWith('Subtotal')), isEmpty);
      });
    });
  }

  test('80mm keeps more on a line than 58mm', () {
    final narrow = _lines(_receipt(), PosPaper.mm58);
    final wide = _lines(_receipt(), PosPaper.mm80);
    expect(narrow, contains('-' * 32));
    expect(wide, contains('-' * 48));
    expect(wide, contains(_row('Date:', '10 Oct 2026, 02:30 PM')));
  });

  group('cut', () {
    const cutBytes = [0x1D, 0x56, 0x42, 0x00];
    bool hasCut(List<int> bytes) {
      for (var i = 0; i + 4 <= bytes.length; i++) {
        if (bytes[i] == 0x1D &&
            bytes[i + 1] == 0x56 &&
            bytes[i + 2] == 0x42 &&
            bytes[i + 3] == 0x00) {
          return true;
        }
      }
      return false;
    }

    List<int> bytesOf(bool cut) => [
      for (final chunk in buildRollEscPos(
        _receipt(),
        naira,
        paper: PosPaper.mm80,
        cut: cut,
      ).build())
        ...chunk,
    ];

    test('at the end when the printer cuts', () {
      final bytes = bytesOf(true);
      expect(hasCut(bytes), isTrue);
      expect(bytes.sublist(bytes.length - 4), cutBytes);
    });

    test('not otherwise', () {
      expect(hasCut(bytesOf(false)), isFalse);
    });
  });

  group('logo', () {
    test('drawn as raster bands no wider than the paper', () {
      final logo = img.encodePng(img.Image(width: 600, height: 200));
      for (final paper in PosPaper.values) {
        final bands = rollLogoBands(logo, paper);
        expect(bands, isNotNull);
        expect(bands, isNotEmpty);
        final widthBytes = bands!.first[4] | (bands.first[5] << 8);
        expect(widthBytes * 8, lessThanOrEqualTo(paper.dots + 7));
        final lines = buildRollEscPos(
          _receipt(),
          naira,
          paper: paper,
          logo: bands,
        ).preview.split('\n');
        expect(lines.first, '[logo]');
      }
    });

    test('no logo for bytes that aren\'t an image', () {
      expect(rollLogoBands(null, PosPaper.mm58), isNull);
      expect(rollLogoBands(img.encodePng(img.Image(width: 1, height: 1)).sublist(0, 4), PosPaper.mm58), isNull);
    });
  });
}
