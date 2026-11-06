import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

SalesDocument _invoice(
  TempInvoice invoice,
  List<TempProductSaleRecord> records, {
  List<TempMainReceipt> receipts = const [],
}) => invoiceDocument(
  invoice: invoice,
  records: records,
  receipts: receipts,
  shop: docShopFrom(shopOf()),
  fmt: naira,
);

TempMainReceipt _payment({
  double cash = 0,
  double bank = 0,
  double account = 0,
  required int day,
  String? invoice = invoiceUuid,
}) => receiptOf(
  cash: cash,
  bank: bank,
  account: account,
  invoiceUuid: invoice,
  createdAt: soldAt.add(Duration(days: day)),
  uuid: '9${day}112222-3333-4444-5555-666677778888',
  staffName: 'Musa',
);

void main() {
  // 2 Crates of soda ₦12,000 + 4 M² of glass ₦4,000 = ₦16,000.
  // 10% off (₦1,600), VAT 7.5% as the cart charged it (₦1,200):
  // ₦15,600.
  final records = [sodaCrates(), glassByArea()];
  final invoice = invoiceOf(
    total: 15600,
    originalCost: 16000,
    vat: 7.5,
    generalDiscount: 10,
  );

  group('VAT with a percentage discount', () {
    test('is the VAT the cart charged, so the totals add up', () {
      final doc = _invoice(invoice, records);
      final t = doc.totals;
      expect(t.subtotal, 16000);
      expect(t.discount, closeTo(1600, 1e-9));
      expect(t.discountLabel, 'Discount (10%)');
      expect(t.vat, closeTo(1200, 1e-9));
      expect(t.total, 15600);
      expect(t.subtotal - t.discount + t.vat, closeTo(t.total, 0.005));
    });

    test('no longer takes the 10% off as ₦10', () {
      // What the current invoice print shows: (₦16,000 - ₦10) x 7.5%.
      expect(invoice.getVATInvoice(), closeTo(1199.25, 1e-9));
      expect(_invoice(invoice, records).totals.vat, isNot(1199.25));
    });

    test('with a fixed discount', () {
      final fixed = invoiceOf(
        total: 15700,
        originalCost: 16000,
        vat: 7.5,
        fixedDiscount: 1500,
      );
      final t = _invoice(fixed, records).totals;
      expect(t.discount, 1500);
      expect(t.discountLabel, 'Discount');
      expect(t.vat, closeTo(1200, 1e-9));
      expect(t.subtotal - t.discount + t.vat, closeTo(t.total, 0.005));
    });

    test('lines with their own discount: VAT on what they cost', () {
      // ₦12,000 less 10% = ₦10,800, VAT 7.5% = ₦810: ₦11,610.
      final doc = _invoice(
        invoiceOf(total: 11610, originalCost: 12000, vat: 7.5),
        [sodaCrates(discount: 10, discountedAmount: 1200)],
      );
      final t = doc.totals;
      expect(doc.lines.single.unitPrice, 6000);
      expect(doc.lines.single.discount, 1200);
      expect(t.itemDiscounts, 1200);
      expect(t.discount, 0);
      expect(t.vat, closeTo(810, 1e-9));
      expect(
        t.subtotal - t.itemDiscounts - t.discount + t.vat,
        closeTo(t.total, 0.005),
      );
    });
  });

  group('part-paid invoice', () {
    late SalesDocument doc;

    setUp(() {
      doc = _invoice(
        invoice,
        records,
        receipts: [
          _payment(bank: 2000, account: 1000, day: 2),
          _payment(cash: 5000, day: 1),
          // Another invoice's payment: ignored.
          _payment(cash: 9999, day: 3, invoice: 'other-invoice'),
        ],
      );
    });

    test('paid and balance come from its own payments', () {
      expect(doc.totals.paid, 8000);
      expect(doc.totals.balance, 7600);
      expect(doc.status, DocPaymentStatus.partPaid);
      expect(doc.infoValue('Status'), 'Part-paid');
    });

    test('payments: one row per channel, oldest first', () {
      expect(
        doc.payments.map((p) => '${p.method} ${p.amount} ${p.date!.day}'),
        ['Cash 5000.0 11', 'Bank 2000.0 12', 'Account 1000.0 12'],
      );
      expect(doc.payments.first.staff, 'Musa');
    });

    test('layout: badge, payments table and balance due', () {
      final layout = salesDocumentLayout(doc, naira);
      final title = layout.sectionsOf<DocTitleSection>().single;
      expect(title.title, 'INVOICE');
      expect(title.badge, 'Part-paid');
      expect(title.badgeTone, DocBadgeTone.warning);

      final totals = layout.sectionsOf<DocTotalsSection>().single.rows;
      expect(totals.map((r) => '${r.label}: ${r.value}'), [
        'Subtotal: ₦16,000.00',
        'Discount (10%): -₦1,600.00',
        'VAT (7.5%): ₦1,200.00',
        'Total: ₦15,600.00',
        'Paid: ₦8,000.00',
        'Balance due: ₦7,600.00',
      ]);
      expect(totals.last.emphasize, isTrue);

      final payments = layout.sectionsOf<DocTableSection>().elementAt(1);
      expect(payments.columns.map((c) => c.title), [
        'Date',
        'Method',
        'Staff',
        'Amount',
      ]);
      expect(payments.rows.first.cells, [
        '11 Oct 2026, 02:30 PM',
        'Cash',
        'Musa',
        '₦5,000.00',
      ]);
      expect(
        layout.sectionsOf<DocBandSection>().map((b) => b.text),
        ['Items', 'Payments', 'Notes'],
      );
    });
  });

  test('unpaid invoice: no payments section', () {
    final doc = _invoice(invoice, records);
    expect(doc.status, DocPaymentStatus.unpaid);
    expect(doc.totals.paid, 0);
    expect(doc.totals.balance, 15600);
    expect(doc.payments, isEmpty);
    final layout = salesDocumentLayout(doc, naira);
    expect(
      layout.sectionsOf<DocBandSection>().map((b) => b.text),
      ['Items', 'Notes'],
    );
    expect(layout.sectionsOf<DocTitleSection>().single.badgeTone,
        DocBadgeTone.alert);
  });

  test('fully paid invoice', () {
    final doc = _invoice(
      invoice,
      records,
      receipts: [
        _payment(cash: 15000, day: 1),
        _payment(bank: 600, day: 2),
      ],
    );
    expect(doc.status, DocPaymentStatus.paid);
    expect(doc.totals.balance, 0);
    final totals = salesDocumentLayout(
      doc,
      naira,
    ).sectionsOf<DocTotalsSection>().single.rows;
    expect(totals.last.label, 'Balance due');
    expect(totals.last.emphasize, isFalse);
  });

  test('information fields', () {
    final doc = _invoice(invoice, records);
    expect(doc.info.map((f) => f.label), [
      'Invoice No',
      'Date',
      'Staff',
      'Customer',
      'Department',
      'Status',
    ]);
    expect(doc.notes, 'Deliver to the back gate');
  });
}
