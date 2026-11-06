import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/constants/generate_barcode.dart' show returnOnlyDigits;
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

// Every document must add up: Subtotal - item discounts - discount +
// VAT = the saved total. The saved totals here come from the cart rule
// (SalesProvider.calcFinalTotal), so this checks the documents show the
// same discount and VAT the cart charged.

class _Line {
  final double value;
  final double ownDiscount;

  const _Line(this.value, [this.ownDiscount = 0]);
}

class _Case {
  final String name;
  final List<_Line> lines;
  final double? percent;
  final double? fixed;
  final double? vat;

  const _Case(this.name, this.lines, {this.percent, this.fixed, this.vat});

  double get subtotal => lines.fold(0, (a, l) => a + l.value);

  // SalesProvider.calcDiscountMain: the document discount, else the
  // lines' own.
  double get cartDiscount =>
      fixed ??
      (percent != null
          ? subtotal * percent! / 100
          : lines.fold(0, (a, l) => a + l.ownDiscount));

  // SalesProvider.calcVatAmount: on each line less its own discount.
  double get cartVat =>
      vat == null
          ? 0
          : lines.fold(0, (a, l) => a + (l.value - l.ownDiscount) * vat! / 100);

  // SalesProvider.calcFinalTotal.
  double get cartTotal =>
      math.max(0.0, subtotal - cartDiscount + cartVat);
}

// Soda ₦12,000 (own discount 10%: ₦1,200) and biscuits ₦1,500 (own
// discount ₦100).
const _soda = _Line(12000);
const _sodaDiscounted = _Line(12000, 1200);
const _biscuits = _Line(1500);
const _biscuitsDiscounted = _Line(1500, 100);

final _cases = [
  for (final vat in [null, 7.5]) ...[
    _Case('single line', [_soda], vat: vat),
    _Case(
      'lines with their own discount',
      [_sodaDiscounted, _biscuitsDiscounted],
      vat: vat,
    ),
    _Case('10% discount', [_soda, _biscuits], percent: 10, vat: vat),
    _Case('fixed ₦500 discount', [_soda, _biscuits], fixed: 500, vat: vat),
    _Case(
      '10% discount over lines with their own discount',
      [_sodaDiscounted, _biscuits],
      percent: 10,
      vat: vat,
    ),
  ],
];

String _label(_Case c) => '${c.name}, VAT ${c.vat == null ? 'off' : 'on'}';

void _expectAddsUp(DocTotals t, double savedTotal) {
  expect(t.total, closeTo(savedTotal, 1e-9));
  expect(
    t.subtotal - t.itemDiscounts - t.discount + t.vat + (t.adjustment ?? 0),
    closeTo(t.total, 0.005),
  );
}

final _pack = unit('u-pack', 'Pack', primary: true, productUuid: 'biscuit');

void main() {
  group('receipt', () {
    for (final c in _cases) {
      test(_label(c), () {
        final records = [
          sodaCrates(discountedAmount: c.lines[0].ownDiscount),
          if (c.lines.length > 1)
            saleLine(
              name: 'Biscuits',
              quantity: 3,
              originalCost: c.lines[1].value,
              units: [_pack],
              unitUuid: 'u-pack',
              discountedAmount: c.lines[1].ownDiscount,
            ),
        ];
        final doc = receiptDocument(
          receipt: receiptOf(
            cash: c.cartTotal,
            originalCost: c.subtotal,
            vat: c.vat,
            generalDiscount: c.percent,
            fixedDiscount: c.fixed,
          ),
          records: records,
          staffName: 'Ada',
          shop: docShopFrom(shopOf()),
          fmt: naira,
        );
        _expectAddsUp(doc.totals, c.cartTotal);
        expect(doc.totals.vat, closeTo(c.cartVat, 1e-9));
      });
    }
  });

  group('invoice', () {
    for (final c in _cases) {
      test(_label(c), () {
        final doc = invoiceDocument(
          invoice: invoiceOf(
            total: c.cartTotal,
            originalCost: c.subtotal,
            vat: c.vat,
            generalDiscount: c.percent,
            fixedDiscount: c.fixed,
          ),
          records: [
            for (final (i, line) in c.lines.indexed)
              saleLine(
                name: 'Line $i',
                quantity: 1,
                originalCost: line.value,
                units: [_pack],
                unitUuid: 'u-pack',
                discountedAmount: line.ownDiscount,
              ),
          ],
          receipts: const [],
          shop: docShopFrom(shopOf()),
          fmt: naira,
        );
        _expectAddsUp(doc.totals, c.cartTotal);
        expect(doc.totals.vat, closeTo(c.cartVat, 1e-9));
      });
    }
  });

  group('order', () {
    for (final c in _cases) {
      test(_label(c), () {
        final doc = orderDocument(
          order: orderOf(
            items: [
              // 2 Crates at ₦500 an Each = ₦12,000.
              orderLine(
                name: 'Soda',
                quantity: 2,
                remaining: 2,
                originalCostPerBase: 500,
                units: [each, crate],
                unitUuid: 'u-crate',
                discountedAmount: c.lines[0].ownDiscount,
              ),
              if (c.lines.length > 1)
                // 3 Packs at ₦500 = ₦1,500.
                orderLine(
                  name: 'Biscuits',
                  quantity: 3,
                  remaining: 3,
                  originalCostPerBase: 500,
                  units: [_pack],
                  unitUuid: 'u-pack',
                  discountedAmount: c.lines[1].ownDiscount,
                ),
            ],
            total: c.cartTotal,
            originalCost: c.subtotal,
            vat: c.vat,
            generalDiscount: c.percent,
            fixedDiscount: c.fixed,
          ),
          receipts: const [],
          shop: docShopFrom(shopOf()),
          fmt: naira,
        );
        expect(
          doc.lines.fold<double>(0, (a, l) => a + l.amount),
          closeTo(c.subtotal, 1e-9),
        );
        _expectAddsUp(doc.totals, c.cartTotal);
        expect(doc.totals.vat, closeTo(c.cartVat, 1e-9));
      });
    }
  });

  // Purchases have no discount or VAT: the lines, plus any price
  // adjustment, are the saved total.
  group('purchase', () {
    for (final savedTotal in [32000.0, 30000.0, 35000.0]) {
      test('saved total ₦$savedTotal', () {
        final doc = purchaseDocument(
          purchase: purchaseOf(total: savedTotal, payments: []),
          items: [
            purchaseLine(
              name: 'Noodles',
              quantity: 5,
              total: 30000,
              unitName: 'Carton',
            ),
            purchaseLine(
              name: 'Plywood',
              quantity: 1,
              total: 2000,
              unitName: 'Sheet',
            ),
          ],
          shop: docShopFrom(shopOf()),
          fmt: naira,
        );
        expect(doc.totals.itemDiscounts, 0);
        expect(doc.totals.discount, 0);
        expect(doc.totals.vat, 0);
        _expectAddsUp(doc.totals, savedTotal);
      });
    }
  });

  // Payment and delivery receipts keep the invoice's or order's
  // subtotal, discount and VAT, but their saved total is only what was
  // paid on them. The page shows the payment and what is left instead.
  group('payment and delivery receipts', () {
    List<String> totalRows(SalesDocument doc) => [
      for (final row in salesDocumentLayout(
        doc,
        naira,
      ).sectionsOf<DocTotalsSection>().single.rows)
        '${row.label}: ${row.value}',
    ];

    test('a payment on an invoice', () {
      final doc = receiptDocument(
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
        records: [sodaCrates(), glassByArea()],
        staffName: 'Ada',
        shop: docShopFrom(shopOf()),
        fmt: naira,
      );
      final invoiceNo = returnOnlyDigits(invoiceUuid);
      expect(doc.receiptKind, DocReceiptKind.invoicePayment);
      expect(doc.titleLine, 'Payment for Invoice #$invoiceNo');
      expect(doc.infoValue('Invoice No'), invoiceNo);
      expect(doc.lines, hasLength(2));
      _expectAddsUp(doc.totals, 5000);
      expect(totalRows(doc), [
        'Amount paid: ₦5,000.00',
        'Invoice balance: ₦10,600.00',
      ]);
      expect(
        doc.payments.map((p) => '${p.method} ${p.amount}'),
        ['Cash 3000.0', 'Bank 2000.0'],
      );
    });

    test('a delivery on an order', () {
      final doc = receiptDocument(
        receipt: receiptOf(
          cash: 10000,
          originalCost: 25000,
          vat: 7.5,
          orderUuid: orderUuid,
          balance: 15000,
          salesTypeIndex: 3,
        ),
        records: [sodaCrates()],
        staffName: 'Ada',
        shop: docShopFrom(shopOf()),
        fmt: naira,
      );
      expect(doc.receiptKind, DocReceiptKind.orderDelivery);
      expect(
        doc.titleLine,
        'Delivery for Order #${returnOnlyDigits(orderUuid)}',
      );
      _expectAddsUp(doc.totals, 10000);
      expect(totalRows(doc), [
        'Amount paid: ₦10,000.00',
        'Order balance: ₦15,000.00',
      ]);
    });

    test('without its invoice it is printed as a sale', () {
      final doc = receiptDocument(
        receipt: receiptOf(cash: 12000, originalCost: 12000, salesTypeIndex: 2),
        records: [sodaCrates()],
        staffName: 'Ada',
        shop: docShopFrom(shopOf()),
        fmt: naira,
      );
      expect(doc.receiptKind, DocReceiptKind.sale);
      expect(doc.titleLine, isNull);
      _expectAddsUp(doc.totals, 12000);
    });
  });
}
