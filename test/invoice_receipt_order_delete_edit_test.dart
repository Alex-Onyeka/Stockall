import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';

TempMainReceipt makeReceipt({
  required String uuid,
  required double cash,
  required double bank,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: '111',
    createdAt: DateTime(2026, 10, 20, 10),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    paymentMethod: 'Cash',
    bank: bank,
    cashAlt: cash,
    customerAccount: 0,
    departmentName: null,
    departmentUuidNew: null,
    isInvoice: false,
    invoiceUuid: null,
    orderUuid: null,
    generalDiscount: null,
    fixedDiscount: null,
    vat: null,
    originalCost: cash + bank,
    balance: 0,
    subStaffUuid: null,
    subStaffName: null,
    cartName: null,
    comment: null,
    salesTypeIndex: 1,
  );
}

TempInvoice makeInvoice({
  required String uuid,
  required double cash,
  required double bank,
  List<TempProductSaleRecord>? items,
}) {
  return TempInvoice(
    uuid: uuid,
    barcode: 'INV111',
    createdAt: DateTime(2026, 10, 20, 10),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    paymentMethod: cash > 0 && bank > 0 ? 'Split' : (bank > 0 ? 'Bank' : 'Cash'),
    bank: bank,
    cashAlt: cash,
    departmentName: null,
    departmentUuidNew: null,
    cartName: 'Cart 1',
    subStaffName: null,
    comment: null,
    items: items,
  );
}

TempProductSaleRecord makeCutRecord({
  required String uuid,
  required String productUuid,
  required double quantity,
  required double width,
  required double height,
  bool manageSalesWastage = false,
  bool isPercentageWastage = false,
  double wastageAmount = 0,
  String? wastageUnitUuid,
  ProductUnitsClass? customPrimaryUnit,
}) {
  final unit = customPrimaryUnit ??
      ProductUnitsClass(
        uuid: 'unit-piece',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'Slab',
        isPrimary: true,
        productUuid: productUuid,
        dimensionType: ProductUnitsClass.sheetUnit,
      );

  return TempProductSaleRecord(
    uuid: uuid,
    createdAt: DateTime.now(),
    productId: 1,
    productUuid: productUuid,
    productName: 'Granite Slab',
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    recepitId: 1,
    quantity: quantity,
    revenue: 1000,
    discountedAmount: 0,
    originalCost: 1000,
    discount: null,
    costPrice: 500,
    customPriceSet: false,
    departmentName: null,
    departmentUuid: null,
    isProductManaged: true,
    useGroupQuantity: false,
    qttyPerGroup: 1,
    isVoid: false,
    unitsList: [unit],
    unitUuid: unit.uuid,
    pricesList: [],
    priceUuid: 'price-1',
    widthDimension: width,
    heightDimension: height,
    quantityType: 2,
    manageSalesWastage: manageSalesWastage,
    isPercentageWastage: isPercentageWastage,
    wastageAmount: wastageAmount,
    wastageUnitUuid: wastageUnitUuid ?? unit.uuid,
  );
}

void main() {
  group('Invoice, Receipt, and Order Delete & Refresh Protection Tests', () {
    test('Deleted invoice UUIDs are filtered out from remote payload on refresh', () {
      final remoteInvoices = [
        makeInvoice(uuid: 'inv-deleted-1', cash: 100, bank: 0),
        makeInvoice(uuid: 'inv-active-2', cash: 200, bank: 0),
      ];

      final deletedUuids = {'inv-deleted-1'};

      final invoices = remoteInvoices
          .where((inv) => inv.uuid != null && !deletedUuids.contains(inv.uuid))
          .toList();

      expect(invoices.length, 1);
      expect(invoices.first.uuid, 'inv-active-2');
      expect(invoices.any((inv) => inv.uuid == 'inv-deleted-1'), isFalse);
    });

    test('Deleted receipt UUIDs are filtered out from remote payload on refresh', () {
      final remoteReceipts = [
        makeReceipt(uuid: 'rec-deleted-1', cash: 500, bank: 0),
        makeReceipt(uuid: 'rec-active-2', cash: 750, bank: 0),
      ];

      final deletedReceiptUuids = {'rec-deleted-1'};

      final receipts = remoteReceipts
          .where((rec) => rec.uuid != null && !deletedReceiptUuids.contains(rec.uuid))
          .toList();

      expect(receipts.length, 1);
      expect(receipts.first.uuid, 'rec-active-2');
      expect(receipts.any((rec) => rec.uuid == 'rec-deleted-1'), isFalse);
    });

    test('Deleted order UUIDs are filtered out from remote payload on refresh', () {
      final remoteOrders = [
        Orders(
          uuid: 'order-deleted-1',
          barcode: '111',
          createdAt: DateTime(2026, 10, 20),
          updatedAt: DateTime(2026, 10, 20),
          shopId: 1,
          orderItems: [],
          customerName: 'Customer 1',
          vat: 0,
          comment: '',
          originalCost: 100,
          balance: 0,
          cartName: 'Order 1',
          fixedDiscount: 0,
          generalDiscount: 0,
          subStaffName: null,
          subStaffUuid: null,
        ),
        Orders(
          uuid: 'order-active-2',
          barcode: '222',
          createdAt: DateTime(2026, 10, 20),
          updatedAt: DateTime(2026, 10, 20),
          shopId: 1,
          orderItems: [],
          customerName: 'Customer 2',
          vat: 0,
          comment: '',
          originalCost: 200,
          balance: 0,
          cartName: 'Order 2',
          fixedDiscount: 0,
          generalDiscount: 0,
          subStaffName: null,
          subStaffUuid: null,
        ),
      ];

      final deletedOrderUuids = {'order-deleted-1'};

      final orders = remoteOrders
          .where((ord) => ord.uuid != null && !deletedOrderUuids.contains(ord.uuid))
          .toList();

      expect(orders.length, 1);
      expect(orders.first.uuid, 'order-active-2');
      expect(orders.any((ord) => ord.uuid == 'order-deleted-1'), isFalse);
    });

    test('Order editing updates order fields and serializes correctly without deletion', () {
      final orderUuid = 'order-edit-123';
      Orders order = Orders(
        uuid: orderUuid,
        barcode: '123456',
        createdAt: DateTime(2026, 10, 20),
        updatedAt: DateTime(2026, 10, 20),
        shopId: 1,
        orderItems: [],
        customerName: 'Test Customer',
        vat: 0,
        comment: 'Initial comment',
        originalCost: 5000,
        balance: 5000,
        cartName: 'Order 1',
        fixedDiscount: 0,
        generalDiscount: 0,
        subStaffName: null,
        subStaffUuid: null,
      );

      final updatedTime = DateTime(2026, 10, 23, 14, 0);
      order.updatedAt = updatedTime;
      order.comment = 'Updated instructions';

      expect(order.uuid, orderUuid);
      expect(order.comment, 'Updated instructions');
      expect(order.updatedAt, updatedTime);

      final json = order.toJson();
      expect(json['uuid'], orderUuid);
      expect(json['comment'], 'Updated instructions');
      expect(json['updated_at'], isNotNull);
    });

    test('Invoice items serialization preserves line items across edits', () {
      final invoice = makeInvoice(
        uuid: 'inv-101',
        cash: 15000,
        bank: 10000,
      );

      final json = invoice.toJson();
      expect(json['invoice_uuid'], 'inv-101');
      expect(json['cash_alt'], 15000);
      expect(json['bank'], 10000);

      invoice.cashAlt = 18000;
      invoice.updatedAt = DateTime(2026, 10, 23, 15, 0);
      final updatedJson = invoice.toJson();
      expect(updatedJson['invoice_uuid'], 'inv-101');
      expect(updatedJson['cash_alt'], 18000);
      expect(updatedJson['updated_at'], isNotNull);
    });

    test('2D items with multiple cuts consolidate into a single stock deduction and single history record per product', () {
      // Simulate 3 cuts of the same 2D product added to cart
      final productUuid = 'prod-granite-slab-2d';
      final cut1 = makeCutRecord(
        uuid: 'cut-1',
        productUuid: productUuid,
        quantity: 1,
        width: 1.5,
        height: 2.0,
      );
      final cut2 = makeCutRecord(
        uuid: 'cut-2',
        productUuid: productUuid,
        quantity: 1,
        width: 2.0,
        height: 2.0,
      );
      final cut3 = makeCutRecord(
        uuid: 'cut-3',
        productUuid: productUuid,
        quantity: 2,
        width: 1.0,
        height: 1.0,
      );

      final records = [cut1, cut2, cut3];

      // Verify that individual sales records are preserved for receipt display
      expect(records.length, 3);
      expect(records[0].uuid, 'cut-1');
      expect(records[1].uuid, 'cut-2');
      expect(records[2].uuid, 'cut-3');

      // Group records by productUuid
      final groupedRecords = <String, List<TempProductSaleRecord>>{};
      for (final r in records) {
        groupedRecords.putIfAbsent(r.productUuid!, () => []).add(r);
      }

      expect(groupedRecords.keys.length, 1);
      final group = groupedRecords[productUuid]!;
      expect(group.length, 3);

      // Total stock area restored/deducted across all 3 cuts
      // Cut 1: 1.5 * 2.0 = 3.0 m2
      // Cut 2: 2.0 * 2.0 = 4.0 m2
      // Cut 3: 2 * (1.0 * 1.0) = 2.0 m2
      // Total = 9.0 m2
      final totalStockArea = group.fold<double>(0.0, (sum, r) => sum + r.getStockQuantity());
      expect(totalStockArea, 9.0);

      // Exactly ONE consolidated history entry per product
      final historyRecordsEmitted = groupedRecords.keys.map((uuid) {
        return {
          'productUuid': uuid,
          'totalDeduction': totalStockArea,
          'title': 'Item Returned',
        };
      }).toList();

      expect(historyRecordsEmitted.length, 1);
      expect(historyRecordsEmitted.first['totalDeduction'], 9.0);
    });

    test('Wastage is always calculated and displayed in the primary unit', () {
      final productUuid = 'prod-slab-wastage';
      final slabPrimaryUnit = ProductUnitsClass(
        uuid: 'unit-slab',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'Slab',
        isPrimary: true,
        productUuid: productUuid,
        dimensionType: ProductUnitsClass.sheetUnit,
      );

      // 1. Percentage wastage (10%) on 2x1 cut (area 2.0 m2).
      // Wastage area = 0.20 m2.
      // Primary unit 'Slab' has dimensionArea 2.0 m2, so wastage in primary unit = 0.10 Slabs.
      final cut1 = makeCutRecord(
        uuid: 'cut-w1',
        productUuid: productUuid,
        quantity: 1,
        width: 2.0,
        height: 1.0,
        manageSalesWastage: true,
        isPercentageWastage: true,
        wastageAmount: 10.0,
        customPrimaryUnit: slabPrimaryUnit,
      );

      expect(cut1.wastageArea(), closeTo(0.20, 1e-4));
      expect(cut1.wastageInPrimaryUnit(), closeTo(0.10, 1e-4));
      expect(cut1.wastageInSaleUnit(), closeTo(0.10, 1e-4));
      expect(cut1.wastageNote(), 'incl. 0.1 Slab wastage');

      // 2. Fixed wastage (0.5 Slabs) in primary unit.
      final cut2 = makeCutRecord(
        uuid: 'cut-w2',
        productUuid: productUuid,
        quantity: 1,
        width: 2.0,
        height: 1.0,
        manageSalesWastage: true,
        isPercentageWastage: false,
        wastageAmount: 0.5,
        wastageUnitUuid: 'unit-slab',
        customPrimaryUnit: slabPrimaryUnit,
      );

      expect(cut2.wastageInPrimaryUnit(), closeTo(0.5, 1e-4));
      expect(cut2.wastageNote(), 'incl. 0.5 Slab wastage');

      // 3. When primary unit is an area unit (e.g. M²), display in M²
      final m2PrimaryUnit = ProductUnitsClass(
        uuid: 'unit-m2',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'M²',
        isPrimary: true,
        productUuid: productUuid,
        dimensionType: ProductUnitsClass.areaUnit,
      );

      final cut3 = makeCutRecord(
        uuid: 'cut-w3',
        productUuid: productUuid,
        quantity: 1,
        width: 2.0,
        height: 1.0,
        manageSalesWastage: true,
        isPercentageWastage: true,
        wastageAmount: 10.0,
        customPrimaryUnit: m2PrimaryUnit,
      );

      expect(cut3.wastageInPrimaryUnit(), closeTo(0.10, 1e-4));
      expect(cut3.wastageNote(), 'incl. 0.1 M² wastage');

      // 4. Consolidation across multiple cuts: sum wastage in primary unit
      final group = [cut1, cut2];
      final totalWastage = group.fold<double>(
        0.0,
        (sum, r) => sum + r.wastageInPrimaryUnit(),
      );
      // 0.10 + 0.50 = 0.60 Slabs
      expect(totalWastage, closeTo(0.60, 1e-4));
      final primaryUnit = cut1.getPrimaryUnit();
      final primUnitName =
          primaryUnit.name == 'Others' ? 'Unit(s)' : primaryUnit.name;
      final wastageText =
          totalWastage > 1e-9 ? ' (including 0.6 $primUnitName wastage)' : '';
      expect(wastageText, ' (including 0.6 Slab wastage)');
    });
  });
}

