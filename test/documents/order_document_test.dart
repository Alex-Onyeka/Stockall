import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

import 'document_fixtures.dart';

SalesDocument _order(
  Orders order, {
  List<TempMainReceipt> receipts = const [],
}) => orderDocument(
  order: order,
  receipts: receipts,
  shop: docShopFrom(shopOf()),
  fmt: naira,
);

final _pack = unit(
  'u-pack',
  'Pack',
  primary: true,
  productUuid: 'biscuit',
);

// 3 Crates of soda at ₦500 an Each (₦18,000), 2 crates delivered.
OrderItems _soda({double? remaining = 1}) => orderLine(
  name: 'Soda',
  quantity: 3,
  remaining: remaining,
  originalCostPerBase: 500,
  units: [each, crate],
  unitUuid: 'u-crate',
);

// 2 Sheets of glass cut at 2m x 1.5m with 10% wastage, at ₦1,000 per
// M² (₦6,000), none delivered.
OrderItems _glass({double? remaining = 2}) => orderLine(
  name: 'Glass',
  quantity: 2,
  remaining: remaining,
  originalCostPerBase: 1000,
  units: [squareMetre, sheet],
  unitUuid: 'u-sheet',
  quantityType: 2,
  width: 2,
  height: 1.5,
  manageSalesWastage: true,
  isPercentageWastage: true,
  wastageAmount: 10,
);

// 4 Packs of biscuits at ₦250 (₦1,000), all delivered.
OrderItems _biscuits({double? remaining = 0}) => orderLine(
  name: 'Biscuits',
  quantity: 4,
  remaining: remaining,
  originalCostPerBase: 250,
  units: [_pack],
  unitUuid: 'u-pack',
);

void main() {
  group('part-delivered, part-paid order', () {
    late SalesDocument doc;

    setUp(() {
      doc = _order(
        orderOf(
          items: [_soda(), _glass(), _biscuits()],
          total: 25000,
          originalCost: 25000,
        ),
        receipts: [
          receiptOf(cash: 10000, orderUuid: orderUuid),
          // Another order's receipt: ignored.
          receiptOf(cash: 999, orderUuid: 'other-order'),
        ],
      );
    });

    test('delivered and outstanding per line, in the unit ordered', () {
      final soda = doc.lines[0];
      expect(soda.quantity, 3);
      expect(soda.unit, 'Crate');
      expect(soda.delivered, 2);
      expect(soda.outstanding, 1);
      expect(soda.amount, 18000);
      expect(soda.unitPrice, 6000);
      expect(soda.notes, ['= 36 Each']);

      final glass = doc.lines[1];
      expect(glass.name, 'Glass (2m x 1.5m)');
      expect(glass.unit, 'Sheet');
      expect(glass.delivered, 0);
      expect(glass.outstanding, 2);
      expect(glass.amount, 6000);
      expect(glass.notes, ['= 6.6 M²', 'incl. 0.6 M² wastage']);

      final biscuits = doc.lines[2];
      expect(biscuits.delivered, 4);
      expect(biscuits.outstanding, 0);
    });

    test('paid, balance and statuses', () {
      expect(doc.title, 'SALES ORDER');
      expect(doc.totals.total, 25000);
      expect(doc.totals.paid, 10000);
      expect(doc.totals.balance, 15000);
      expect(doc.status, DocPaymentStatus.partPaid);
      expect(doc.infoValue('Payment'), 'Part-paid');
      expect(doc.infoValue('Delivery'), 'Partly delivered');
      expect(doc.infoValue('Cart'), 'Table 4');
      expect(doc.infoValue('Department'), 'Kitchen');
    });

    test('layout: delivery columns', () {
      final layout = salesDocumentLayout(doc, naira);
      final items = layout.sectionsOf<DocTableSection>().first;
      expect(items.columns.map((c) => c.title), [
        '#',
        'Item',
        'Ordered',
        'Delivered',
        'Outstanding',
        'Unit price',
        'Amount',
      ]);
      expect(items.rows[0].cells, [
        '1',
        'Soda',
        '3 Crate',
        '2 Crate',
        '1 Crate',
        '₦6,000.00',
        '₦18,000.00',
      ]);
      expect(items.rows[1].cells.sublist(2, 5), [
        '2 Sheet',
        '0 Sheet',
        '2 Sheet',
      ]);
      final payments = layout.sectionsOf<DocTableSection>().elementAt(1);
      expect(payments.rows.single.cells.last, '₦10,000.00');
    });
  });

  test('fully delivered and nothing delivered', () {
    final delivered = _order(
      orderOf(
        items: [_soda(remaining: 0), _biscuits()],
        total: 19000,
        originalCost: 19000,
      ),
    );
    expect(delivered.infoValue('Delivery'), 'Delivered');
    expect(delivered.status, DocPaymentStatus.unpaid);

    final waiting = _order(
      orderOf(
        items: [_soda(remaining: 3), _glass()],
        total: 24000,
        originalCost: 24000,
      ),
    );
    expect(waiting.infoValue('Delivery'), 'Not delivered');
  });

  test('a line without a saved remaining quantity is undelivered', () {
    final doc = _order(
      orderOf(
        items: [_biscuits(remaining: null)],
        total: 1000,
        originalCost: 1000,
      ),
    );
    expect(doc.lines.single.delivered, 0);
    expect(doc.lines.single.outstanding, 4);
  });

  test('VAT and discount as the current order print', () {
    // ₦25,000, 10% off, VAT 7.5% on the subtotal.
    final doc = _order(
      orderOf(
        items: [_soda(), _glass(), _biscuits()],
        total: 24375,
        originalCost: 25000,
        vat: 7.5,
        generalDiscount: 10,
      ),
    );
    expect(doc.totals.discount, closeTo(2500, 1e-9));
    expect(doc.totals.vat, closeTo(1875, 1e-9));
    expect(doc.totals.total, 24375);
  });
}
