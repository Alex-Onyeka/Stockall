import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

SalesDocument _purchase(
  TempPurchase purchase,
  List<TempItemPurchaseRecord> items,
) => purchaseDocument(
  purchase: purchase,
  items: items,
  shop: docShopFrom(shopOf()),
  fmt: naira,
);

final _noodleEach = unit(
  'u-noodle-each',
  'Each',
  primary: true,
  productUuid: 'noodles',
);
final _carton = unit(
  'u-carton',
  'Carton',
  conversion: 12,
  productUuid: 'noodles',
);

// 5 Cartons of noodles for ₦30,000 and 10 sheets of 8 x 4 plywood
// for ₦20,000.
final _items = [
  purchaseLine(
    name: 'Noodles',
    quantity: 5,
    total: 30000,
    units: [_noodleEach, _carton],
    unitUuid: 'u-carton',
  ),
  purchaseLine(
    name: 'Plywood',
    quantity: 10,
    total: 20000,
    unitName: 'Sheet',
    width: 8,
    height: 4,
  ),
];

void main() {
  group('purchase with supplier and two payments', () {
    late SalesDocument doc;

    setUp(() {
      doc = _purchase(
        purchaseOf(
          total: 50000,
          payments: [
            purchasePayment(10000, 'Cash', soldAt.add(const Duration(days: 2))),
            purchasePayment(20000, 'Bank', soldAt.add(const Duration(days: 1))),
          ],
        ),
        _items,
      );
    });

    test('information: supplier, staff, department, status', () {
      expect(doc.title, 'PURCHASE RECORD');
      expect(doc.info.map((f) => f.label), [
        'Purchase No',
        'Date',
        'Staff',
        'Supplier',
        'Department',
        'Status',
      ]);
      expect(doc.infoValue('Supplier'), 'Delta Wholesale');
      expect(doc.infoValue('Staff'), 'Chidi');
      expect(doc.infoValue('Status'), 'Part-paid');
      expect(doc.number, matches(RegExp(r'^\d{13}$')));
    });

    test('lines in the unit bought, with the unit cost', () {
      final noodles = doc.lines[0];
      expect(noodles.quantity, 5);
      expect(noodles.unit, 'Carton');
      expect(noodles.unitPrice, 6000);
      expect(noodles.amount, 30000);
      expect(noodles.notes, ['= 60 Each']);

      final plywood = doc.lines[1];
      expect(plywood.name, 'Plywood (8 x 4)');
      expect(plywood.unit, 'Sheet');
      expect(plywood.unitPrice, 2000);
      expect(plywood.notes, isEmpty);
    });

    test('totals and payments, oldest first', () {
      final t = doc.totals;
      expect(t.subtotal, 50000);
      expect(t.adjustment, isNull);
      expect(t.vatRate, isNull);
      expect(t.total, 50000);
      expect(t.paid, 30000);
      expect(t.balance, 20000);
      expect(
        doc.payments.map((p) => '${p.method} ${p.amount} ${p.staff}'),
        ['Bank 20000.0 Chidi', 'Cash 10000.0 Chidi'],
      );
    });

    test('layout', () {
      final layout = salesDocumentLayout(doc, naira);
      final items = layout.sectionsOf<DocTableSection>().first;
      expect(items.columns.map((c) => c.title), [
        '#',
        'Item',
        'Qty',
        'Unit cost',
        'Amount',
      ]);
      expect(items.rows[0].cells, [
        '1',
        'Noodles',
        '5 Carton',
        '₦6,000.00',
        '₦30,000.00',
      ]);
      expect(
        layout
            .sectionsOf<DocTotalsSection>()
            .single
            .rows
            .map((r) => '${r.label}: ${r.value}'),
        [
          'Subtotal: ₦50,000.00',
          'Total: ₦50,000.00',
          'Paid: ₦30,000.00',
          'Balance: ₦20,000.00',
        ],
      );
      final payments = layout.sectionsOf<DocTableSection>().elementAt(1);
      expect(payments.rows.first.cells, [
        '11 Oct 2026, 02:30 PM',
        'Bank',
        'Chidi',
        '₦20,000.00',
      ]);
    });
  });

  test('a saved total that differs from the lines shows the adjustment', () {
    final doc = _purchase(
      purchaseOf(total: 48000, payments: []),
      _items,
    );
    expect(doc.totals.adjustment, -2000);
    expect(doc.status, DocPaymentStatus.unpaid);
    final rows = salesDocumentLayout(
      doc,
      naira,
    ).sectionsOf<DocTotalsSection>().single.rows;
    expect(
      rows.map((r) => '${r.label}: ${r.value}'),
      contains('Price adjustment: -₦2,000.00'),
    );
  });

  test('fully paid, no supplier', () {
    final doc = _purchase(
      purchaseOf(
        total: 50000,
        supplierName: null,
        payments: [purchasePayment(50000, 'Cash', soldAt)],
      ),
      _items,
    );
    expect(doc.status, DocPaymentStatus.paid);
    expect(doc.infoValue('Supplier'), isNull);
    expect(doc.totals.balance, 0);
  });
}
