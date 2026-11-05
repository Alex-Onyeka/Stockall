import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

SalesDocument _receipt({
  required receipt,
  required records,
  shop,
  String? footerText,
}) => receiptDocument(
  receipt: receipt,
  records: records,
  staffName: 'Ada Obi',
  shop: shop ?? docShopFrom(shopOf()),
  fmt: naira,
  footerText: footerText,
);

void main() {
  group('receipt with mixed lines, discount, VAT and split payment', () {
    // 2 Crates of soda ₦12,000 + glass cut to size ₦6,600 + glass by
    // the M² ₦4,000 = ₦22,600. 10% off (₦2,260), VAT 7.5% on the
    // subtotal (₦1,695): ₦22,035, paid cash + bank + account.
    late SalesDocument doc;

    setUp(() {
      doc = _receipt(
        receipt: receiptOf(
          cash: 10000,
          bank: 7035,
          account: 5000,
          originalCost: 22600,
          vat: 7.5,
          generalDiscount: 10,
          customerName: 'Bola Stores',
          subStaffName: 'Musa',
          cartName: 'Table 4',
          departmentName: 'Front shop',
          comment: 'Thanks for coming',
        ),
        records: [sodaCrates(), glassSheets(), glassByArea()],
        footerText: 'Goods sold are not returnable',
      );
    });

    test('is a sales receipt numbered like the current prints', () {
      expect(doc.type, DocType.receipt);
      expect(doc.title, 'SALES RECEIPT');
      expect(doc.number, matches(RegExp(r'^\d{13}$')));
      expect(pw.Barcode.ean13().isValid(doc.number), isTrue);
      expect(doc.barcode, doc.number);
      expect(doc.footerText, 'Goods sold are not returnable');
      expect(doc.notes, 'Thanks for coming');
    });

    test('lists the information fields that are set', () {
      expect(doc.info.map((f) => f.label), [
        'Receipt No',
        'Date',
        'Staff',
        'Customer',
        'Waiter',
        'Cart',
        'Department',
      ]);
      expect(doc.infoValue('Staff'), 'Ada Obi');
      expect(doc.infoValue('Customer'), 'Bola Stores');
      expect(doc.infoValue('Date'), '10 Oct 2026, 02:30 PM');
    });

    test('a multi-unit line is in the unit sold, with its name', () {
      final soda = doc.lines[0];
      expect(soda.name, 'Soda');
      expect(soda.quantity, 2);
      expect(soda.unit, 'Crate');
      expect(soda.unitPrice, 6000);
      expect(soda.amount, 12000);
      expect(soda.notes, ['= 24 Each']);
    });

    test('a sized line shows its size, area and wastage', () {
      final glass = doc.lines[1];
      expect(glass.name, 'Glass (2m x 1.5m)');
      expect(glass.quantity, closeTo(6.6, 1e-9));
      expect(glass.unit, 'M²');
      expect(glass.unitPrice, closeTo(1000, 1e-9));
      expect(glass.amount, 6600);
      expect(glass.notes, ['incl. 0.6 M² wastage']);
    });

    test('an area line is in M², without a size', () {
      final offcut = doc.lines[2];
      expect(offcut.name, 'Glass offcut');
      expect(offcut.quantity, 4);
      expect(offcut.unit, 'M²');
      expect(offcut.unitPrice, 1000);
      expect(offcut.notes, isEmpty);
    });

    test('totals: discount, VAT on the subtotal, and the saved total', () {
      final t = doc.totals;
      expect(t.subtotal, 22600);
      expect(t.discount, closeTo(2260, 1e-9));
      expect(t.discountLabel, 'Discount (10%)');
      expect(t.vatRate, 7.5);
      expect(t.vat, closeTo(1695, 1e-9));
      expect(t.total, 22035);
      expect(t.subtotal - t.discount + t.vat, closeTo(t.total, 0.005));
      expect(t.paid, isNull);
      expect(t.balance, isNull);
    });

    test('split payment: one row per channel', () {
      expect(
        doc.payments.map((p) => '${p.method} ${p.amount}'),
        ['Cash 10000.0', 'Bank 7035.0', 'Account 5000.0'],
      );
    });

    test('layout rows and totals as printed', () {
      final layout = salesDocumentLayout(doc, naira);
      final items = layout.sectionsOf<DocTableSection>().first;
      expect(items.columns.map((c) => c.title), [
        '#',
        'Item',
        'Qty',
        'Unit price',
        'Amount',
      ]);
      expect(items.rows[0].cells, [
        '1',
        'Soda',
        '2 Crate',
        '₦6,000.00',
        '₦12,000.00',
      ]);
      expect(items.rows[0].notes, ['= 24 Each']);
      expect(items.rows[1].cells[2], '6.6 M²');

      final totals = layout.sectionsOf<DocTotalsSection>().single.rows;
      expect(totals.map((r) => '${r.label}: ${r.value}'), [
        'Subtotal: ₦22,600.00',
        'Discount (10%): -₦2,260.00',
        'VAT (7.5%): ₦1,695.00',
        'Total: ₦22,035.00',
      ]);
      expect(totals.last.emphasize, isTrue);

      final payments = layout.sectionsOf<DocTableSection>().elementAt(1);
      expect(payments.columns.map((c) => c.title), ['Method', 'Amount']);
      expect(payments.rows.map((r) => r.cells), [
        ['Cash', '₦10,000.00'],
        ['Bank', '₦7,035.00'],
        ['Account', '₦5,000.00'],
      ]);
    });
  });

  group('line discounts', () {
    // Soda: 10% off its ₦12,000 (₦1,200). Biscuits: ₦100 off ₦1,500.
    final biscuitPack = unit(
      'u-pack',
      'Pack',
      primary: true,
      productUuid: 'biscuit',
    );
    final biscuits = saleLine(
      name: 'Biscuits',
      quantity: 3,
      originalCost: 1500,
      units: [biscuitPack],
      unitUuid: 'u-pack',
      fixedDiscount: 100,
      discountedAmount: 100,
    );

    test('"per 1" is the unit price, not the line total', () {
      final doc = _receipt(
        receipt: receiptOf(cash: 12200, originalCost: 13500),
        records: [
          sodaCrates(discount: 10, discountedAmount: 1200),
          biscuits,
        ],
      );
      final soda = doc.lines[0];
      // The current print showed ₦10,800 (the line total) as "per 1".
      expect(soda.unitPrice, 6000);
      expect(soda.amount, 12000);
      expect(soda.discount, 1200);
      expect(soda.discountRate, 10);

      final biscuit = doc.lines[1];
      expect(biscuit.unitPrice, 500);
      expect(biscuit.discount, 100);
      expect(biscuit.discountRate, isNull);

      expect(doc.totals.itemDiscounts, 1300);
      expect(doc.totals.discount, 0);
      expect(
        doc.totals.subtotal - doc.totals.itemDiscounts,
        closeTo(doc.totals.total, 0.005),
      );

      final rows = salesDocumentLayout(
        doc,
        naira,
      ).sectionsOf<DocTableSection>().first.rows;
      expect(rows[0].cells[3], '₦6,000.00');
      expect(rows[0].notes, [
        '= 24 Each',
        'Less 10% discount: -₦1,200.00',
      ]);
      expect(rows[1].notes, ['Less discount: -₦100.00']);
    });

    test('a receipt discount replaces the lines\' own discounts', () {
      final doc = _receipt(
        receipt: receiptOf(
          cash: 13000,
          originalCost: 13500,
          fixedDiscount: 500,
        ),
        records: [
          sodaCrates(discount: 10, discountedAmount: 1200),
          biscuits,
        ],
      );
      expect(doc.lines.map((l) => l.discount), [0, 0]);
      expect(doc.totals.itemDiscounts, 0);
      expect(doc.totals.discount, 500);
      expect(doc.totals.discountLabel, 'Discount');
      expect(doc.totals.total, 13000);
    });
  });

  group('empty optional fields', () {
    // A legacy line saved without a units list, no customer, waiter,
    // cart, department, comment, VAT, footer or shop contacts.
    late SalesDocument doc;

    setUp(() {
      doc = _receipt(
        receipt: receiptOf(cash: 1500, originalCost: 1500),
        records: [
          saleLine(
            name: 'Bread',
            quantity: 3,
            originalCost: 1500,
            unitName: 'Others',
          ),
        ],
        shop: docShopFrom(
          shopOf(email: null, phone: null, address: null),
        ),
      );
    });

    test('only the fields that have a value', () {
      expect(doc.info.map((f) => f.label), [
        'Receipt No',
        'Date',
        'Staff',
      ]);
      expect(doc.notes, isNull);
      expect(doc.footerText, isNull);
      expect(doc.shop.contactLines, isEmpty);
      expect(doc.totals.vatRate, isNull);
    });

    test('a line without units uses its saved quantity and unit', () {
      final bread = doc.lines.single;
      expect(bread.quantity, 3);
      expect(bread.unit, 'Unit(s)');
      expect(bread.unitPrice, 500);
      expect(bread.notes, isEmpty);
    });

    test('no notes band, no VAT or discount rows', () {
      final layout = salesDocumentLayout(doc, naira);
      expect(
        layout.sectionsOf<DocBandSection>().map((b) => b.text),
        ['Items', 'Payments'],
      );
      expect(layout.sectionsOf<DocTextSection>(), isEmpty);
      expect(
        layout
            .sectionsOf<DocTotalsSection>()
            .single
            .rows
            .map((r) => r.label),
        ['Subtotal', 'Total'],
      );
      expect(layout.footer.message, isNull);
    });
  });

  test('a saved receipt balance prints as before', () {
    final doc = _receipt(
      receipt: receiptOf(cash: 1000, originalCost: 1500, balance: 500),
      records: [
        saleLine(
          name: 'Bread',
          quantity: 3,
          originalCost: 1500,
          unitName: 'Loaf',
        ),
      ],
    );
    expect(doc.totals.receiptBalance, 500);
    final totals = salesDocumentLayout(
      doc,
      naira,
    ).sectionsOf<DocTotalsSection>().single.rows;
    expect(totals.last.label, 'Balance');
    expect(totals.last.value, '₦500.00');
  });

  group('shop header', () {
    test('contact lines follow the receipt settings', () {
      final shop = docShopFrom(
        shopOf(showPhone: false),
        reference: '00007',
      );
      expect(shop.name, 'Mama Put Supermarket');
      expect(shop.contactLines, [
        '12 Allen Avenue, Ikeja, Lagos',
        'hello@mamaput.ng',
      ]);
      expect(shop.reference, 'Shop ID: 00007');
      expect(shop.logo, isNull);
    });
  });

  group('formatting', () {
    test('Naira amounts with two decimals and a minus sign', () {
      expect(naira.money(1234567.5), '₦1,234,567.50');
      expect(naira.money(0.001), '₦0.00');
      expect(naira.minus(500), '-₦500.00');
      expect(naira.quantity(6.6, 'M²'), '6.6 M²');
      expect(naira.rate(7.5), '7.5%');
    });

    test('letter currencies get a space; the dirham is written AED', () {
      expect(DocFormat(currency: 'KSh').money(10), 'KSh 10.00');
      expect(DocFormat(currency: 'د.إ').money(10), 'AED 10.00');
      expect(DocFormat(currency: r'$').money(10), r'$10.00');
    });
  });
}
