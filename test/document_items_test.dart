import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async =>
      _items[key];

  @override
  Future<void> setItem({
    required String key,
    required String value,
  }) async => _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async =>
      _items.remove(key);
}

// What Supabase does to a payload: encode, then decode.
Map<String, dynamic> _overTheWire(Map<String, dynamic> json) {
  return jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
}

void main() {
  final soldAt = DateTime(2026, 10, 10, 14, 30);

  final eachUnit = ProductUnitsClass(
    uuid: 'unit-each',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Each',
    isPrimary: true,
    productUuid: 'soda-1',
  );
  final caseUnit = ProductUnitsClass(
    uuid: 'unit-case',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 12,
    name: 'Case',
    isPrimary: false,
    productUuid: 'soda-1',
  );
  final sodaPrice = ProductPricesClass(
    uuid: 'price-soda',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: 500,
    name: 'Retail',
    isPrimary: true,
    itemUuid: 'soda-1',
  );
  final sqUnit = ProductUnitsClass(
    uuid: 'unit-sq',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Sq Unit',
    isPrimary: true,
    productUuid: 'sheet-1',
  );
  final sheetPrice = ProductPricesClass(
    uuid: 'price-sheet',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: 100,
    name: 'Price',
    isPrimary: true,
    itemUuid: 'sheet-1',
  );

  TempProductSaleRecord saleRecord({
    String uuid = 'line-1',
    String? receiptUuid = 'receipt-1',
    String? invoiceUuid,
  }) {
    return TempProductSaleRecord(
      createdAt: soldAt,
      productId: 0,
      productUuid: 'sheet-1',
      productName: 'Glass',
      shopId: 1,
      staffId: 'staff-1',
      staffName: 'Ada Obi',
      customerUuid: 'customer-1',
      customerName: 'Chidi',
      recepitId: 0,
      receiptUuid: receiptUuid,
      invoiceUuid: invoiceUuid,
      quantity: 2,
      revenue: 540,
      discountedAmount: 60,
      originalCost: 600,
      discount: 10,
      fixedDiscount: null,
      costPrice: 250,
      customPriceSet: false,
      departmentName: 'Front',
      departmentUuid: 'dept-1',
      uuid: uuid,
      isProductManaged: true,
      setTotalPrice: false,
      unit: 'Sq Unit',
      useWholeSalePrice: false,
      useGroupQuantity: false,
      qttyPerGroup: null,
      isVoid: false,
      unitsList: [sqUnit],
      unitUuid: sqUnit.uuid,
      pricesList: [sheetPrice],
      priceUuid: sheetPrice.uuid,
      widthDimension: 2,
      heightDimension: 1.5,
      quantityType: 2,
    );
  }

  TempItemPurchaseRecord purchaseRecord() {
    return TempItemPurchaseRecord(
      uuid: 'pline-1',
      createdAt: soldAt,
      shopId: 1,
      staffId: 'staff-1',
      departmentId: 'dept-1',
      itemId: 'soda-1',
      supplierId: 'supplier-1',
      quantity: 3,
      total: 9000,
      purchaseId: 'purchase-1',
      itemName: 'Soda',
      originalPrice: 3000,
      customPrice: null,
      storageItemId: null,
      isGroup: true,
      qttyPerGroup: 12,
      unit: 'Each',
      unitsList: [eachUnit, caseUnit],
      unitUuid: caseUnit.uuid,
    );
  }

  TempMainReceipt receipt({List<TempProductSaleRecord>? items}) {
    return TempMainReceipt(
      uuid: 'receipt-1',
      barcode: '123',
      createdAt: soldAt,
      shopId: 1,
      staffId: 'staff-1',
      staffName: 'Ada Obi',
      customerName: 'Chidi',
      customerUuid: 'customer-1',
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 540,
      departmentName: 'Front',
      departmentUuidNew: 'dept-1',
      isInvoice: false,
      cartName: 'Cart 1',
      subStaffName: null,
      comment: null,
      customerAccount: 0,
      salesTypeIndex: 1,
      originalCost: 600,
      items: items,
    );
  }

  TempInvoice invoice({List<TempProductSaleRecord>? items}) {
    return TempInvoice(
      uuid: 'invoice-1',
      barcode: '456',
      createdAt: soldAt,
      shopId: 1,
      staffId: 'staff-1',
      staffName: 'Ada Obi',
      customerName: 'Chidi',
      customerUuid: 'customer-1',
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 540,
      departmentName: 'Front',
      departmentUuidNew: 'dept-1',
      cartName: 'Cart 1',
      subStaffName: null,
      comment: null,
      originalCost: 600,
      items: items,
    );
  }

  TempPurchase purchase({List<TempItemPurchaseRecord>? items}) {
    return TempPurchase(
      uuid: 'purchase-1',
      createdAt: soldAt,
      shopId: 1,
      staffId: 'staff-1',
      staffName: 'Ada Obi',
      supplierId: 'supplier-1',
      supplierName: 'Acme',
      total: 9000,
      isCustomPriceSet: false,
      purchasePayments: [
        PurchasePayments(
          uuid: 'pay-1',
          purchaseId: 'purchase-1',
          createdAt: soldAt,
          amount: 4000,
          userId: 'staff-1',
          paymentMethod: 'Cash',
          staffName: 'Ada Obi',
        ),
      ],
      updatedAt: null,
      items: items,
    );
  }

  void expectSameSaleLine(
    TempProductSaleRecord actual,
    TempProductSaleRecord expected,
  ) {
    expect(actual.uuid, expected.uuid);
    expect(actual.productUuid, expected.productUuid);
    expect(actual.productName, expected.productName);
    expect(actual.quantity, expected.quantity);
    expect(actual.unit, expected.unit);
    expect(actual.unitUuid, expected.unitUuid);
    expect(
      actual.unitsList?.map((u) => u.uuid).toList(),
      expected.unitsList?.map((u) => u.uuid).toList(),
    );
    expect(actual.priceUuid, expected.priceUuid);
    expect(
      actual.pricesList?.map((p) => p.priceValue).toList(),
      expected.pricesList?.map((p) => p.priceValue).toList(),
    );
    expect(actual.costPrice, expected.costPrice);
    expect(actual.revenue, expected.revenue);
    expect(actual.originalCost, expected.originalCost);
    expect(actual.discount, expected.discount);
    expect(actual.fixedDiscount, expected.fixedDiscount);
    expect(actual.discountedAmount, expected.discountedAmount);
    expect(actual.widthDimension, expected.widthDimension);
    expect(actual.heightDimension, expected.heightDimension);
    expect(actual.quantityType, expected.quantityType);
    expect(actual.departmentName, expected.departmentName);
    expect(actual.departmentUuid, expected.departmentUuid);
    expect(actual.staffId, expected.staffId);
    expect(actual.staffName, expected.staffName);
    expect(actual.isVoid, expected.isVoid);
    expect(actual.receiptUuid, expected.receiptUuid);
    expect(actual.invoiceUuid, expected.invoiceUuid);
    expect(
      actual.createdAt.isAtSameMomentAs(expected.createdAt),
      isTrue,
    );
  }

  group('round trip', () {
    test('receipt items survive toJson → wire → fromJson', () {
      final line = saleRecord();
      final json = receipt(items: [line]).toJson();
      final items = json['items'] as List;
      expect(items, hasLength(1));
      // Stored with an offset, so the instant is unambiguous.
      expect(
        (items.first as Map)['created_at'],
        soldAt.toUtc().toIso8601String(),
      );

      final back = TempMainReceipt.fromJson(_overTheWire(json));
      expect(back.items, hasLength(1));
      expectSameSaleLine(back.items!.first, line);
      expect(back.items!.first.createdAt.isUtc, isFalse);
      expect(back.uuid, 'receipt-1');
      expect(back.cashAlt, 540);
    });

    test('invoice items survive toJson → wire → fromJson', () {
      final line = saleRecord(
        receiptUuid: null,
        invoiceUuid: 'invoice-1',
      );
      final json = invoice(items: [line]).toJson();
      final back = TempInvoice.fromJson(_overTheWire(json));
      expect(back.uuid, 'invoice-1');
      expect(back.items, hasLength(1));
      expectSameSaleLine(back.items!.first, line);
    });

    test('purchase items survive toJson → wire → fromJson', () {
      final line = purchaseRecord();
      final json = purchase(items: [line]).toJson();
      final back = TempPurchase.fromJson(_overTheWire(json));
      expect(back.items, hasLength(1));
      final item = back.items!.first;
      expect(item.uuid, 'pline-1');
      expect(item.itemId, 'soda-1');
      expect(item.itemName, 'Soda');
      expect(item.quantity, 3);
      expect(item.total, 9000);
      expect(item.originalPrice, 3000);
      expect(item.unit, 'Each');
      expect(item.unitUuid, 'unit-case');
      expect(item.unitsList, hasLength(2));
      expect(item.isGroup, isTrue);
      expect(item.qttyPerGroup, 12);
      expect(item.departmentId, 'dept-1');
      expect(item.staffId, 'staff-1');
      expect(item.purchaseId, 'purchase-1');
      expect(
        item.createdAt.isAtSameMomentAs(soldAt),
        isTrue,
      );
      expect(back.purchasePayments, hasLength(1));
    });

    test('copyWith keeps items (payment edits)', () {
      final r = receipt(items: [saleRecord()]);
      expect(r.copyWith(comment: 'x').items, hasLength(1));
      final p = purchase(items: [purchaseRecord()]);
      expect(p.copyWith(total: 1).items, hasLength(1));
    });
  });

  group('legacy documents (no items)', () {
    test('toJson leaves items out when null or empty', () {
      expect(receipt().toJson().containsKey('items'), isFalse);
      expect(
        receipt(items: []).toJson().containsKey('items'),
        isFalse,
      );
      expect(invoice().toJson().containsKey('items'), isFalse);
      expect(purchase().toJson().containsKey('items'), isFalse);
      expect(
        receipt(items: []).toJson(),
        receipt().toJson(),
      );
    });

    test('fromJson without items or with [] reads as before', () {
      final json = _overTheWire(receipt().toJson());
      final noKey = TempMainReceipt.fromJson(json);
      final empty = TempMainReceipt.fromJson({
        ...json,
        'items': [],
      });
      for (final r in [noKey, empty]) {
        expect(r.items == null || r.items!.isEmpty, isTrue);
        expect(r.toJson(), receipt().toJson());
      }
      final inv = TempInvoice.fromJson({
        ..._overTheWire(invoice().toJson()),
        'items': [],
      });
      expect(inv.items, isNull);
      final pur = TempPurchase.fromJson({
        ..._overTheWire(purchase().toJson()),
        'items': [],
      });
      expect(pur.items, isNull);
    });

    test('malformed items leave the document readable', () {
      final json = _overTheWire(receipt().toJson());
      final bad = TempMainReceipt.fromJson({
        ...json,
        'items': [
          {'bad': 1},
        ],
      });
      expect(bad.items, isNull);
      expect(bad.uuid, 'receipt-1');
      final notAList = TempInvoice.fromJson({
        ..._overTheWire(invoice().toJson()),
        'items': 'oops',
      });
      expect(notAList.items, isNull);
      final badPurchase = TempPurchase.fromJson({
        ..._overTheWire(purchase().toJson()),
        'items': [
          {'created_at': 'not a date', 'shop_id': 1},
        ],
      });
      expect(badPurchase.items, isNull);
    });
  });

  group('backfilled items (to_jsonb of item table rows)', () {
    // Shapes produced by supabase/backfills/*_backfill_items.sql:
    // the full row with snake_case column keys, the row id,
    // timestamptz strings and whole numbers for round doubles.
    Map<String, dynamic> productSalesRow() => {
      'id': 9876,
      'created_at': '2026-10-01T09:30:00.123456+00:00',
      'product_id': 0,
      'product_name': 'Soda',
      'shop_id': 1,
      'staff_id': 'staff-1',
      'customer_id': null,
      'customer_name': 'Chidi',
      'staff_name': 'Ada Obi',
      'recepit_id': 0,
      'discount': 10,
      'quantity': 2,
      'revenue': 900,
      'discounted_amount': 100,
      'original_cost': 1000,
      'cost_price': 600,
      'custom_price_set': false,
      'department_uuid': 'dept-1',
      'department_name': 'Front',
      'uuid': 'ps-1',
      'product_uuid': 'soda-1',
      'receipt_uuid': 'receipt-1',
      'customer_uuid': 'customer-1',
      'is_product_managed': true,
      'set_total_price': false,
      'invoice_uuid': null,
      'fixed_discount': null,
      'unit': 'Each',
      'use_whole_sale_price': false,
      'sell_group': false,
      'qtty_per_group': null,
      'is_void': false,
      'units_list': [jsonDecode(jsonEncode(eachUnit))],
      'unit_uuid': 'unit-each',
      'prices_list': [jsonDecode(jsonEncode(sodaPrice))],
      'price_uuid': 'price-soda',
      'width_dimension': null,
      'height_dimension': null,
      'quantity_type': null,
    };

    Map<String, dynamic> itemPurchaseRow() => {
      'id': 555,
      'created_at': '2026-10-01T09:30:00.123456+00:00',
      'shop_id': 1,
      'staff_id': 'staff-1',
      'uuid': 'ipr-1',
      'quantity': 3,
      'department_id': 'dept-1',
      'item_id': 'soda-1',
      'purchase_id': 'purchase-1',
      'supplier_id': 'supplier-1',
      'total': 9000,
      'item_name': 'Soda',
      'original_price': 3000,
      'custom_price': null,
      'storage_item_uuid': null,
      'is_group': true,
      'qtty_per_group': 12,
      'unit': 'Each',
      'units_list': [
        jsonDecode(jsonEncode(eachUnit)),
        jsonDecode(jsonEncode(caseUnit)),
      ],
      'unit_uuid': 'unit-case',
    };

    final rowInstant = DateTime.utc(2026, 10, 1, 9, 30, 0, 123, 456);

    test('receipt and invoice read product_sales rows', () {
      final r = TempMainReceipt.fromJson({
        ..._overTheWire(receipt().toJson()),
        'items': [productSalesRow()],
      });
      final i = TempInvoice.fromJson({
        ..._overTheWire(invoice().toJson()),
        'items': [productSalesRow()],
      });
      for (final items in [r.items, i.items]) {
        expect(items, hasLength(1));
        final line = items!.first;
        expect(line.uuid, 'ps-1');
        expect(line.productUuid, 'soda-1');
        expect(line.productName, 'Soda');
        expect(line.quantity, 2);
        expect(line.revenue, 900);
        expect(line.costPrice, 600);
        expect(line.originalCost, 1000);
        expect(line.discount, 10);
        expect(line.discountedAmount, 100);
        expect(line.unit, 'Each');
        expect(line.unitsList?.first.uuid, 'unit-each');
        expect(line.pricesList?.first.priceValue, 500);
        expect(line.widthDimension, isNull);
        expect(line.quantityType, isNull);
        expect(line.departmentName, 'Front');
        expect(line.staffName, 'Ada Obi');
        expect(line.isVoid, isFalse);
        expect(line.createdAt.isAtSameMomentAs(rowInstant), isTrue);
      }
    });

    test('purchase reads item_purchase_records rows', () {
      final p = TempPurchase.fromJson({
        ..._overTheWire(purchase().toJson()),
        'items': [itemPurchaseRow()],
      });
      expect(p.items, hasLength(1));
      final line = p.items!.first;
      expect(line.uuid, 'ipr-1');
      expect(line.itemId, 'soda-1');
      expect(line.quantity, 3);
      expect(line.total, 9000);
      expect(line.originalPrice, 3000);
      expect(line.unitUuid, 'unit-case');
      expect(line.unitsList, hasLength(2));
      expect(line.createdAt.isAtSameMomentAs(rowInstant), isTrue);
    });
  });

  group('items built at checkout', () {
    TempProductClass soda() => TempProductClass(
      uuid: 'soda-1',
      name: 'Soda',
      shopId: 1,
      unit: 'Each',
      isRefundable: false,
      costPrice: 300,
      sellingPrice: 500,
      quantity: 50,
      setCustomPrice: false,
      departmentName: null,
      departmentUuid: null,
      isManaged: true,
      groupUnit: null,
      qttyPerGroup: null,
      wholeSalePrice: null,
      storageUuid: null,
      categories: [],
      useGroupUnit: false,
      unitsList: [eachUnit],
      pricesList: [sodaPrice],
      widthDimension: null,
      heightDimension: null,
    );

    // 4 × 3 sheet, ₦100 per square unit.
    TempProductClass sheet() => TempProductClass(
      uuid: 'sheet-1',
      name: 'Glass',
      shopId: 1,
      unit: 'Sq Unit',
      isRefundable: false,
      costPrice: 0,
      sellingPrice: 100,
      quantity: 10,
      setCustomPrice: false,
      departmentName: null,
      departmentUuid: null,
      isManaged: true,
      groupUnit: null,
      qttyPerGroup: null,
      wholeSalePrice: null,
      storageUuid: null,
      categories: [],
      useGroupUnit: false,
      unitsList: [sqUnit],
      pricesList: [sheetPrice],
      widthDimension: 4,
      heightDimension: 3,
      quantityType: 2,
    );

    late TempCartItem sodaLine;
    late TempCartItem sheetLine;

    setUpAll(() async {
      // SalesProvider and DataProvider read Supabase.instance when
      // constructed. Dummy client: no session storage, no network.
      TestWidgetsFlutterBinding.ensureInitialized();
      await Supabase.initialize(
        url: 'http://localhost',
        anonKey: 'test-anon-key',
        authOptions: FlutterAuthClientOptions(
          localStorage: const EmptyLocalStorage(),
          pkceAsyncStorage: _MemoryAsyncStorage(),
          detectSessionInUri: false,
          autoRefreshToken: false,
        ),
      );
      // revenue() reads the current shop's VAT setting from Hive.
      Hive.init(
        Directory.systemTemp
            .createTempSync('stockall_items_test')
            .path,
      );
      Hive.registerAdapter(TempCurrentShopAdapter());
      CurrentShopFunc().currentShopBox =
          await Hive.openBox<TempCurrentShop>('currentShopTest');
      await CurrentShopFunc().currentShopBox.add(
        TempCurrentShop(currentShopId: 1),
      );
      ShopProvider().userShops = [
        TempShopClass(
          shopId: 1,
          createdAt: DateTime.utc(2026),
          userId: 'owner-1',
          name: 'Shop',
          currency: 'NGN',
          isVerified: true,
          applyVAT: false,
          manageInventoryStorage: false,
          wholeSale: false,
          manageDepartments: false,
          printSalesDocket: false,
          closeSaleTimeString: null,
          trackCart: false,
          accessPin: null,
          manageProductions: false,
          manageProductionsStorage: false,
          manageProductionItems: false,
          customerPercentageReward: 0,
          manageCustomerReward: false,
          manageCustomerAccount: false,
        ),
      ];
    });

    tearDownAll(() async {
      await Hive.close();
    });

    setUp(() {
      DataProvider().productListMain = [soda(), sheet()];
      sodaLine = TempCartItem(
        item: soda(),
        itemUuid: 'soda-1',
        quantity: 2,
        discount: 10,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        uuid: 'cart-line-soda',
        unitUuid: eachUnit.uuid,
        priceUuid: sodaPrice.uuid,
        widthDimension: null,
        heightDimension: null,
        quantityType: 1,
      );
      sheetLine = TempCartItem(
        item: sheet(),
        itemUuid: 'sheet-1',
        quantity: 1,
        discount: null,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: true,
        uuid: 'cart-line-sheet',
        unitUuid: sqUnit.uuid,
        priceUuid: sheetPrice.uuid,
        widthDimension: 2,
        heightDimension: 1.5,
        quantityType: 2,
      );
    });

    List<TempProductSaleRecord> build({
      String? receiptUuid,
      String? invoiceUuid,
    }) {
      return SalesProvider().buildSaleRecords(
        cartItems: [sodaLine, sheetLine],
        createdAt: soldAt,
        shopId: 1,
        staffId: 'staff-1',
        staffName: 'Ada Obi',
        customerUuid: 'customer-1',
        customerName: 'Chidi',
        departmentName: 'Front',
        departmentUuid: 'dept-1',
        receiptUuid: receiptUuid,
        invoiceUuid: invoiceUuid,
      );
    }

    test('one line per cart line with the report fields', () {
      final records = build(receiptUuid: 'receipt-1');
      expect(records, hasLength(2));

      final soda = records[0];
      expect(soda.uuid, 'cart-line-soda');
      expect(soda.productUuid, 'soda-1');
      expect(soda.productName, 'Soda');
      expect(soda.quantity, 2);
      expect(soda.unit, 'Each');
      expect(soda.unitUuid, 'unit-each');
      expect(soda.priceUuid, 'price-soda');
      expect(soda.originalCost, 1000);
      expect(soda.discount, 10);
      expect(soda.discountedAmount, 100);
      expect(soda.revenue, 900);
      expect(soda.costPrice, 600);
      expect(soda.isVoid, isFalse);
      expect(soda.widthDimension, isNull);
      expect(soda.departmentName, 'Front');
      expect(soda.departmentUuid, 'dept-1');
      expect(soda.staffId, 'staff-1');
      expect(soda.staffName, 'Ada Obi');
      expect(soda.customerUuid, 'customer-1');
      expect(soda.createdAt, soldAt);

      // 2D custom size: 2 × 1.5 = 3 square units at ₦100.
      final glass = records[1];
      expect(glass.uuid, 'cart-line-sheet');
      expect(glass.widthDimension, 2);
      expect(glass.heightDimension, 1.5);
      expect(glass.quantityType, 2);
      expect(glass.originalCost, 300);
      expect(glass.revenue, 300);
      expect(glass.costPrice, isNull);
      expect(glass.isVoid, isTrue);
      expect(glass.unit, 'Sq Unit');

      // Same values the cart line reports.
      for (final pair in [
        [soda, sodaLine],
        [glass, sheetLine],
      ]) {
        final record = pair[0] as TempProductSaleRecord;
        final line = pair[1] as TempCartItem;
        expect(record.revenue, line.revenue());
        expect(record.originalCost, line.totalCost());
        expect(record.discountedAmount, line.discountCost());
        expect(record.costPrice, line.costPrice());
        expect(record.unit, line.getUnit());
      }
    });

    test('links lines to a receipt or an invoice', () {
      final forReceipt = build(receiptUuid: 'receipt-1');
      expect(
        forReceipt.every(
          (r) =>
              r.receiptUuid == 'receipt-1' &&
              r.invoiceUuid == null,
        ),
        isTrue,
      );
      final forInvoice = build(invoiceUuid: 'invoice-1');
      expect(
        forInvoice.every(
          (r) =>
              r.invoiceUuid == 'invoice-1' &&
              r.receiptUuid == null,
        ),
        isTrue,
      );
    });

    test('checkout items round-trip on the receipt', () {
      final records = build(receiptUuid: 'receipt-1');
      final r = receipt(items: records);
      final back = TempMainReceipt.fromJson(
        _overTheWire(r.toJson()),
      );
      expect(back.items, hasLength(2));
      for (var i = 0; i < records.length; i++) {
        expectSameSaleLine(back.items![i], records[i]);
      }
    });
  });
}
