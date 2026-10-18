import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';

const midnight = TimeOfDay(hour: 0, minute: 0);

const categoryNames = {
  'c-drinks': 'Drinks',
  'c-snacks': 'Snacks',
};

TempMainReceipt receipt({
  String uuid = 'r-0000000000001',
  String? barcode = '111',
  DateTime? createdAt,
  int? salesTypeIndex = 1,
  double cash = 0,
  double bank = 0,
  String? staffId = 'staff-a',
  String? staffName = 'Ada',
  String? customerUuid,
  String? customerName,
  String? subStaffUuid,
  String? subStaffName,
  String? departmentUuid,
  String? departmentName,
  String? invoiceUuid,
  List<TempProductSaleRecord>? items,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: barcode,
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: staffName,
    customerUuid: customerUuid,
    customerName: customerName,
    paymentMethod: 'Cash',
    bank: bank,
    cashAlt: cash,
    customerAccount: null,
    departmentName: departmentName,
    departmentUuidNew: departmentUuid,
    isInvoice: invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    generalDiscount: null,
    fixedDiscount: null,
    vat: null,
    originalCost: null,
    balance: null,
    subStaffUuid: subStaffUuid,
    subStaffName: subStaffName,
    cartName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

ProductUnitsClass unit(
  String uuid, {
  String? name,
  bool isPrimary = true,
  double conversion = 1,
  int? dimensionType,
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: name ?? uuid,
    isPrimary: isPrimary,
    productUuid: 'p-1',
    dimensionType: dimensionType,
  );
}

TempProductSaleRecord line({
  String? uuid = 'line-0001',
  int? productRecordId,
  String? productUuid = 'p-1',
  String productName = 'Cola',
  double quantity = 1,
  double revenue = 0,
  double? originalCost,
  double? costPrice,
  double? discount,
  double? discountedAmount,
  double? fixedDiscount,
  bool customPriceSet = false,
  bool? setTotalPrice,
  bool? useWholeSalePrice,
  bool? isProductManaged = true,
  bool isVoid = false,
  String? receiptUuid,
  String? unitText,
  int? quantityType,
  List<ProductUnitsClass>? unitsList,
  String? unitUuid,
  bool useGroupQuantity = false,
  double? qttyPerGroup,
  double? width,
  double? height,
  bool? manageSalesWastage,
  bool? isPercentageWastage,
  double? wastageAmount,
  String? wastageUnitUuid,
}) {
  return TempProductSaleRecord(
    productRecordId: productRecordId,
    createdAt: DateTime(2026, 10, 17, 12),
    productId: 0,
    productName: productName,
    shopId: 1,
    staffId: 'staff-a',
    staffName: 'Ada',
    recepitId: 0,
    quantity: quantity,
    revenue: revenue,
    discountedAmount: discountedAmount,
    originalCost: originalCost ?? revenue,
    discount: discount,
    fixedDiscount: fixedDiscount,
    costPrice: costPrice,
    customPriceSet: customPriceSet,
    setTotalPrice: setTotalPrice,
    useWholeSalePrice: useWholeSalePrice,
    departmentName: null,
    departmentUuid: null,
    uuid: uuid,
    productUuid: productUuid,
    receiptUuid: receiptUuid,
    isProductManaged: isProductManaged,
    unit: unitText,
    useGroupQuantity: useGroupQuantity,
    qttyPerGroup: qttyPerGroup,
    isVoid: isVoid,
    unitsList: unitsList,
    unitUuid: unitUuid,
    pricesList: null,
    priceUuid: null,
    widthDimension: width,
    heightDimension: height,
    quantityType: quantityType,
    manageSalesWastage: manageSalesWastage,
    isPercentageWastage: isPercentageWastage,
    wastageAmount: wastageAmount,
    wastageUnitUuid: wastageUnitUuid,
  );
}

TempProductClass product(
  String uuid, {
  List<String>? categories,
  String? categoryUuid,
}) {
  return TempProductClass(
    uuid: uuid,
    name: uuid,
    unit: 'Unit(s)',
    isRefundable: false,
    costPrice: 0,
    shopId: 1,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    categoryUuid: categoryUuid,
    wholeSalePrice: null,
    storageUuid: null,
    categories: categories,
    useGroupUnit: false,
    unitsList: null,
    pricesList: null,
    widthDimension: null,
    heightDimension: null,
    manageSalesWastage: null,
  );
}

List<ItemSalesRow> build(
  List<TempMainReceipt> receipts, {
  List<TempProductSaleRecord> legacy = const [],
  List<TempProductClass>? products,
}) {
  return ItemSalesRowBuilder.buildAll(
    receipts: receipts,
    legacySales: legacy,
    productsByUuid: {
      for (final p
          in products ??
              [
                product('p-1', categories: ['c-drinks']),
              ])
        p.uuid!: p,
    },
    categoryNameByUuid: categoryNames,
  );
}

/// The row of a single line on a sales receipt.
ItemSalesRow one(
  TempProductSaleRecord l, {
  int? salesTypeIndex = 1,
  List<TempProductClass>? products,
}) {
  return build(
    [
      receipt(salesTypeIndex: salesTypeIndex, items: [l]),
    ],
    products: products,
  ).single;
}

List<ItemSalesRow> run(
  List<ItemSalesRow> rows, {
  ItemSalesFilters? filters,
  ReceiptsReportPeriod period =
      const ReceiptsReportPeriod.allTime(),
  ItemSalesSortField sortField = ItemSalesSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
  bool profitVisible = true,
}) {
  return ItemSalesQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: filters ?? ItemSalesFilters(),
    sortField: sortField,
    ascending: ascending,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
    profitVisible: profitVisible,
    closingTime: midnight,
  );
}

List<String?> uuids(List<ItemSalesRow> rows) =>
    rows.map((r) => r.line.uuid).toList();

void main() {
  group('rows', () {
    test('one row per line, not per receipt', () {
      final rows = build([
        receipt(
          uuid: 'r-0000000000001',
          items: [line(uuid: 'a'), line(uuid: 'b')],
        ),
        receipt(
          uuid: 'r-0000000000002',
          barcode: '222',
          items: [line(uuid: 'c')],
        ),
      ]);
      expect(rows.length, 3);
      expect(
        rows.map((r) => r.receiptId).toList(),
        ['#111', '#111', '#222'],
      );
      expect(rows.map((r) => r.lineIndex).toList(), [0, 1, 0]);
    });

    test('lines of the same product stay separate rows', () {
      final rows = build([
        receipt(
          items: [
            line(uuid: 'a', quantity: 1),
            line(uuid: 'b', quantity: 2),
          ],
        ),
      ]);
      expect(rows.length, 2);
      expect(rows.map((r) => r.quantity).toList(), [1, 2]);
    });

    test('falls back to product_sales lines of the receipt', () {
      final rows = build(
        [receipt(uuid: 'r-0000000000001')],
        legacy: [
          line(
            uuid: 'old-1',
            productRecordId: 42,
            receiptUuid: 'r-0000000000001',
          ),
          line(uuid: 'other', receiptUuid: 'r-0000000000009'),
        ],
      );
      expect(rows.length, 1);
      expect(rows.single.recordId, '42');
      expect(
        rows.single.parent.lineSource,
        ReceiptLineSource.legacy,
      );
    });

    test('embedded lines win, so no line appears twice', () {
      final rows = build(
        [
          receipt(
            uuid: 'r-0000000000001',
            items: [line(uuid: 'new')],
          ),
        ],
        legacy: [
          line(uuid: 'old', receiptUuid: 'r-0000000000001'),
        ],
      );
      expect(uuids(rows), ['new']);
    });

    test('a receipt without lines has no rows', () {
      expect(build([receipt()]), isEmpty);
    });

    test('void lines are built and flagged', () {
      final rows = build([
        receipt(items: [line(isVoid: true)]),
      ]);
      expect(rows.single.isVoid, isTrue);
    });
  });

  group('identity', () {
    test('record ID is the line uuid, shortened for the table', () {
      final r = one(line(uuid: 'abcdef123456'));
      expect(r.recordId, 'abcdef123456');
      expect(r.recordLabel, 'abcdef12…');
    });

    test('old lines use the product_sales record id', () {
      final rows = build(
        [receipt(uuid: 'r-0000000000001')],
        legacy: [
          line(
            uuid: null,
            productRecordId: 7,
            receiptUuid: 'r-0000000000001',
          ),
        ],
      );
      expect(rows.single.recordId, '7');
    });

    test('no id at all stays null, nothing is invented', () {
      final r = one(line(uuid: null));
      expect(r.recordId, isNull);
      expect(r.recordLabel, isNull);
    });

    test('blank product uuid and name are missing', () {
      final r = one(line(productUuid: '  ', productName: ' '));
      expect(r.productKey, isNull);
      expect(r.itemName, isNull);
      expect(r.itemLabel, 'Not Set');
      expect(r.productExists, isFalse);
    });

    test('staff and customer come from the receipt', () {
      final r =
          build([
            receipt(
              staffId: 'staff-b',
              staffName: 'Bo',
              customerUuid: 'cust-1',
              customerName: 'Cy',
              items: [line()],
            ),
          ]).single;
      expect(r.parent.staffKey, 'staff-b');
      expect(r.parent.staffLabel, 'Bo');
      expect(r.parent.customerLabel, 'Cy');
    });
  });

  group('categories', () {
    test('the Items Report rule: list plus the older single uuid', () {
      final result = ItemSalesCategories.known(
        product: product(
          'p-1',
          categories: ['c-snacks'],
          categoryUuid: 'c-drinks',
        ),
        nameByUuid: categoryNames,
      );
      expect(result.uuids, ['c-snacks', 'c-drinks']);
      expect(result.names, ['Snacks', 'Drinks']);
    });

    test('duplicates and deleted categories are dropped', () {
      final result = ItemSalesCategories.known(
        product: product(
          'p-1',
          categories: ['c-drinks', 'c-gone', ''],
          categoryUuid: 'c-drinks',
        ),
        nameByUuid: categoryNames,
      );
      expect(result.uuids, ['c-drinks']);
    });

    test('several categories show as one label', () {
      final r = one(
        line(),
        products: [
          product('p-1', categories: ['c-drinks', 'c-snacks']),
        ],
      );
      expect(r.categoryLabel, 'Drinks, Snacks');
    });

    test('an item without categories is No Category', () {
      final r = one(line(), products: [product('p-1')]);
      expect(r.categoryUuids, isEmpty);
      expect(r.categoryLabel, 'No Category');
    });

    test('a deleted item has its own unknown category', () {
      final r = one(line(), products: []);
      expect(r.productExists, isFalse);
      expect(r.categoryUuids, isEmpty);
      expect(r.categoryLabel, 'Unknown (deleted item)');
    });

    test('a line without a product id is unknown too', () {
      final r = one(line(productUuid: null));
      expect(r.categoryLabel, 'Unknown (deleted item)');
    });
  });

  group('money', () {
    test('gross value is originalCost', () {
      expect(one(line(originalCost: 500)).grossValue, 500);
    });

    test('a percentage discount shows its rate', () {
      final r = one(
        line(
          originalCost: 1000,
          discount: 10,
          discountedAmount: 100,
        ),
      );
      expect(r.discount, 100);
      expect(r.discountPercent, 10);
    });

    test('a fixed discount has no rate, even with an item rate', () {
      final r = one(
        line(
          originalCost: 1000,
          discount: 10,
          fixedDiscount: 50,
          discountedAmount: 50,
        ),
      );
      expect(r.discount, 50);
      expect(r.discountPercent, isNull);
    });

    test('no discount data is unknown, not 0', () {
      final r = one(line(discountedAmount: null));
      expect(r.discount, isNull);
      expect(r.discountPercent, isNull);
    });

    test('selling price is gross value per sale unit', () {
      expect(
        one(line(quantity: 4, originalCost: 1000)).sellingPrice,
        250,
      );
    });

    test('a custom total divides by the sale quantity', () {
      final r = one(
        line(
          quantity: 4,
          originalCost: 900,
          customPriceSet: true,
          setTotalPrice: true,
        ),
      );
      expect(r.sellingPrice, 225);
      expect(r.customPrice, isTrue);
      expect(r.customTotal, isTrue);
    });

    test('zero quantity has no selling price', () {
      expect(
        one(line(quantity: 0, originalCost: 10)).sellingPrice,
        isNull,
      );
    });

    test('profit is revenue minus cost, margin over revenue', () {
      final r = one(line(revenue: 1000, costPrice: 600));
      expect(r.revenue, 1000);
      expect(r.cost, 600);
      expect(r.profit, 400);
      expect(r.margin, 40);
      expect(r.costMissing, isFalse);
    });

    test('missing or 0 cost counts as 0 and is flagged', () {
      for (final cost in [null, 0.0]) {
        final r = one(line(revenue: 100, costPrice: cost));
        expect(r.cost, isNull);
        expect(r.profit, 100);
        expect(r.costMissing, isTrue);
      }
    });

    test('a loss is negative', () {
      final r = one(line(revenue: 100, costPrice: 150));
      expect(r.profit, -50);
      expect(r.margin, -50);
    });

    test('margin is null without positive revenue', () {
      expect(one(line(revenue: 0, costPrice: 5)).margin, isNull);
      expect(one(line(revenue: -10, costPrice: 5)).margin, isNull);
    });
  });

  group('units and quantity', () {
    test('unit name comes from the line unit list', () {
      final r = one(
        line(
          unitsList: [unit('u-1', name: 'Bottle')],
          unitUuid: 'u-1',
        ),
      );
      expect(r.unitName, 'Bottle');
    });

    test('"Others" shows as Unit(s)', () {
      final r = one(
        line(
          unitsList: [unit('u-1', name: 'Others')],
          unitUuid: 'u-1',
        ),
      );
      expect(r.unitName, 'Unit(s)');
    });

    test('falls back to the recorded unit text', () {
      expect(one(line(unitText: 'Kg ')).unitName, 'Kg');
      expect(one(line()).unitName, isNull);
    });

    test('2D pieces show their cut size, area units do not', () {
      final sheet = one(
        line(
          quantityType: 2,
          unitsList: [
            unit(
              'u-slab',
              name: 'Slab',
              dimensionType: ProductUnitsClass.sheetUnit,
            ),
          ],
          unitUuid: 'u-slab',
          width: 2,
          height: 3,
        ),
      );
      expect(sheet.unitName, 'Slab (2 x 3)');
      final area = one(
        line(
          quantityType: 2,
          unitsList: [
            unit(
              'u-m2',
              name: 'm²',
              dimensionType: ProductUnitsClass.areaUnit,
            ),
          ],
          unitUuid: 'u-m2',
          width: 2,
          height: 3,
        ),
      );
      expect(area.unitName, 'm²');
    });

    test('the quantity is never converted', () {
      final r = one(
        line(
          quantity: 2,
          useGroupQuantity: true,
          qttyPerGroup: 12,
        ),
      );
      expect(r.quantity, 2);
      expect(r.baseQuantity, 24);
    });

    test('base quantity uses the sale unit conversion', () {
      final r = one(
        line(
          quantity: 3,
          unitsList: [
            unit('u-pc'),
            unit('u-ctn', isPrimary: false, conversion: 12),
          ],
          unitUuid: 'u-ctn',
        ),
      );
      expect(r.quantity, 3);
      expect(r.baseQuantity, 36);
    });

    test('2D base quantity is area', () {
      final sheet = one(
        line(
          quantity: 2,
          quantityType: 2,
          unitsList: [
            unit(
              'u-slab',
              dimensionType: ProductUnitsClass.sheetUnit,
            ),
          ],
          unitUuid: 'u-slab',
          width: 2,
          height: 3,
        ),
      );
      expect(sheet.baseQuantity, 12);
      final area = one(
        line(
          quantity: 6,
          quantityType: 2,
          unitsList: [
            unit(
              'u-m2',
              dimensionType: ProductUnitsClass.areaUnit,
            ),
          ],
          unitUuid: 'u-m2',
        ),
      );
      expect(area.baseQuantity, 6);
    });

    test('an unresolvable unit gives an unknown base quantity', () {
      expect(
        one(
          line(
            unitsList: [unit('u-1')],
            unitUuid: 'u-gone',
          ),
        ).baseQuantity,
        isNull,
      );
      expect(
        one(line(quantityType: 2)).baseQuantity,
        isNull,
      );
    });
  });

  group('wastage', () {
    // 1 slab of 2 x 3 = 6 m².
    final units = [
      unit(
        'u-m2',
        name: 'm²',
        dimensionType: ProductUnitsClass.areaUnit,
      ),
      unit(
        'u-slab',
        name: 'Slab',
        isPrimary: false,
        dimensionType: ProductUnitsClass.sheetUnit,
      ),
    ];

    TempProductSaleRecord slab({
      bool? manage = true,
      bool? percent,
      double? amount,
      String? wastageUnit,
      List<ProductUnitsClass>? list,
      double originalCost = 1100,
    }) => line(
      quantity: 1,
      originalCost: originalCost,
      quantityType: 2,
      unitsList: list ?? units,
      unitUuid: 'u-slab',
      width: 2,
      height: 3,
      manageSalesWastage: manage,
      isPercentageWastage: percent,
      wastageAmount: amount,
      wastageUnitUuid: wastageUnit,
    );

    test('lines without wastage have 0', () {
      final r = one(line());
      expect(r.wastage, 0);
      expect(r.wastageSetting, isNull);
    });

    test('older 2D lines (null setting) never applied it', () {
      final r = one(slab(manage: null, amount: 10));
      expect(r.wastage, 0);
      expect(r.wastageSetting, isNull);
    });

    test('a percentage is shown in the sale unit', () {
      final r = one(slab(percent: true, amount: 10));
      expect(r.wastage, closeTo(0.1, 1e-9));
      expect(r.wastageSetting, '10%');
    });

    test('a fixed amount uses the unit it was entered in', () {
      final r = one(
        slab(percent: false, amount: 0.6, wastageUnit: 'u-m2'),
      );
      expect(r.wastage, closeTo(0.1, 1e-9));
      expect(r.wastageSetting, '0.6 m²');
    });

    test('a fixed amount without a unit is base area', () {
      final r = one(slab(percent: false, amount: 1.2));
      expect(r.wastage, closeTo(0.2, 1e-9));
      expect(r.wastageSetting, '1.2 m²');
    });

    test('selling price divides by the quantity with wastage', () {
      final r = one(slab(percent: true, amount: 10));
      expect(r.sellingPrice, closeTo(1000, 1e-9));
    });

    test('a custom total ignores wastage', () {
      final l = slab(percent: true, amount: 10, originalCost: 900)
        ..customPriceSet = true
        ..setTotalPrice = true;
      expect(one(l).sellingPrice, 900);
    });

    test('no unit list: unknown, never a crash', () {
      final r = one(slab(percent: true, amount: 10, list: []));
      expect(r.wastage, isNull);
      expect(r.sellingPrice, isNull);
      expect(r.wastageSetting, '10%');
    });
  });

  group('flags', () {
    test('wholesale and managed keep unknown apart from No', () {
      expect(one(line(useWholeSalePrice: true)).wholesale, true);
      expect(one(line(useWholeSalePrice: false)).wholesale, false);
      expect(one(line()).wholesale, isNull);
      expect(one(line(isProductManaged: null)).managed, isNull);
      expect(one(line(isProductManaged: false)).managed, false);
    });

    test('a custom unit price is not a custom total', () {
      final r = one(line(customPriceSet: true));
      expect(r.customPrice, isTrue);
      expect(r.customTotal, isFalse);
    });
  });

  group('transaction types', () {
    test('part payments keep prorated amounts, no unit price', () {
      final r = one(
        line(quantity: 4, revenue: 250, originalCost: 250),
        salesTypeIndex: 2,
      );
      expect(r.type, ReceiptType.invoicePayment);
      expect(r.isPartPayment, isTrue);
      expect(r.quantity, 4);
      expect(r.revenue, 250);
      expect(r.sellingPrice, isNull);
    });

    test('older invoice receipts are part payments too', () {
      final r =
          build([
            receipt(
              salesTypeIndex: null,
              invoiceUuid: 'inv-1',
              items: [line()],
            ),
          ]).single;
      expect(r.isPartPayment, isTrue);
    });

    test('order deliveries are rows with their own revenue', () {
      final r = one(
        line(quantity: 2, revenue: 300, discountedAmount: null),
        salesTypeIndex: 3,
      );
      expect(r.type, ReceiptType.orderDelivery);
      expect(r.isPartPayment, isFalse);
      expect(r.revenue, 300);
      expect(r.sellingPrice, 150);
      expect(r.discount, isNull);
    });
  });

  group('filters', () {
    late List<ItemSalesRow> rows;

    setUp(() {
      rows = build(
        [
          receipt(
            uuid: 'r-0000000000001',
            barcode: '111',
            staffId: 'staff-a',
            staffName: 'Ada',
            customerUuid: 'cust-1',
            customerName: 'Cy',
            subStaffUuid: 'sub-1',
            subStaffName: 'Sam',
            departmentUuid: 'dep-1',
            departmentName: 'Bar',
            cash: 100,
            items: [
              line(
                uuid: 'cola',
                productUuid: 'p-1',
                productName: 'Cola',
                revenue: 100,
                costPrice: 60,
                customPriceSet: true,
                useWholeSalePrice: true,
              ),
              line(
                uuid: 'void',
                productUuid: 'p-1',
                productName: 'Cola',
                revenue: 100,
                costPrice: 60,
                isVoid: true,
              ),
            ],
          ),
          receipt(
            uuid: 'r-0000000000002',
            barcode: '222',
            staffId: 'staff-b',
            staffName: 'Bo',
            bank: 50,
            items: [
              line(
                uuid: 'chips',
                productUuid: 'p-2',
                productName: 'Chips',
                quantity: 3,
                revenue: 50,
                costPrice: 80,
                useWholeSalePrice: false,
              ),
              line(
                uuid: 'nocost',
                productUuid: 'p-3',
                productName: 'Cola',
                revenue: 20,
                costPrice: null,
              ),
            ],
          ),
          receipt(
            uuid: 'r-0000000000003',
            barcode: '333',
            salesTypeIndex: 2,
            invoiceUuid: 'inv-1',
            items: [
              line(
                uuid: 'part',
                productUuid: 'p-2',
                productName: 'Chips',
                quantity: 3,
                revenue: 25,
                costPrice: 40,
              ),
              line(
                uuid: 'noid',
                productUuid: null,
                productName: 'Loose',
                revenue: 5,
                costPrice: 1,
              ),
            ],
          ),
        ],
        products: [
          product('p-1', categories: ['c-drinks']),
          product('p-2', categories: ['c-snacks', 'c-drinks']),
          product('p-3'),
        ],
      );
    });

    List<String?> ids({
      ItemSalesFilters? filters,
      bool departmentsEnabled = true,
      bool subStaffEnabled = true,
      bool profitVisible = true,
    }) =>
        uuids(
          run(
            rows,
            filters: filters,
            departmentsEnabled: departmentsEnabled,
            subStaffEnabled: subStaffEnabled,
            profitVisible: profitVisible,
          ),
        )..sort();

    test('void lines are hidden by default', () {
      expect(
        ids(),
        ['chips', 'cola', 'nocost', 'noid', 'part'],
      );
      expect(
        ids(
          filters: ItemSalesFilters(
            voidFilter: ItemSalesVoidFilter.voidOnly,
          ),
        ),
        ['void'],
      );
      expect(
        ids(
          filters: ItemSalesFilters(
            voidFilter: ItemSalesVoidFilter.all,
          ),
        ).length,
        6,
      );
    });

    test('search covers item, receipt, category, people, IDs', () {
      List<String?> find(String q, {bool deps = true}) => ids(
        filters: ItemSalesFilters()..search = q,
        departmentsEnabled: deps,
      );
      expect(find('CHIPS'), ['chips', 'part']);
      expect(find('#222'), ['chips', 'nocost']);
      expect(find('snacks'), ['chips', 'part']);
      expect(find('bo'), ['chips', 'nocost']);
      expect(find('cy'), ['cola']);
      expect(find('p-3'), ['nocost']);
      expect(find('loose'), ['noid']);
      expect(find('noco'), ['nocost']);
      expect(find('bar'), ['cola']);
      expect(find('bar', deps: false), isEmpty);
    });

    test('staff and customer use the receipt keys', () {
      final f = ItemSalesFilters();
      f.receipt.staffKey = 'staff-b';
      expect(ids(filters: f), ['chips', 'nocost']);
      final none = ItemSalesFilters();
      none.receipt.customerKey = receiptsReportNoneKey;
      expect(ids(filters: none), ['chips', 'nocost', 'noid', 'part']);
    });

    test('hidden sub-staff and department filters do nothing', () {
      final f = ItemSalesFilters();
      f.receipt.subStaffKey = 'sub-1';
      f.receipt.departmentKey = 'dep-1';
      expect(ids(filters: f), ['cola']);
      expect(
        ids(
          filters: f,
          subStaffEnabled: false,
          departmentsEnabled: false,
        ).length,
        5,
      );
    });

    test('type and channel come from the receipt', () {
      final type = ItemSalesFilters();
      type.receipt.type = ReceiptType.invoicePayment;
      expect(ids(filters: type), ['noid', 'part']);
      final channel = ItemSalesFilters();
      channel.receipt.channel = ReceiptChannel.bank;
      expect(ids(filters: channel), ['chips', 'nocost']);
    });

    test('category matches any of the item categories', () {
      expect(
        ids(filters: ItemSalesFilters(categoryKey: 'c-drinks')),
        ['chips', 'cola', 'part'],
      );
      expect(
        ids(filters: ItemSalesFilters(categoryKey: 'c-snacks')),
        ['chips', 'part'],
      );
    });

    test('No Category and deleted items are separate buckets', () {
      expect(
        ids(
          filters: ItemSalesFilters(
            categoryKey: receiptsReportNoneKey,
          ),
        ),
        ['nocost'],
      );
      expect(
        ids(
          filters: ItemSalesFilters(
            categoryKey: itemSalesDeletedItemKey,
          ),
        ),
        ['noid'],
      );
      expect(
        ItemSalesOptions.categories(
          categoryNames,
          rows,
        ).map((o) => o.label).toList(),
        [
          'Drinks',
          'Snacks',
          'No Category',
          'Unknown (deleted item)',
        ],
      );
    });

    test('choosing the deleted bucket clears a live item', () {
      final f = ItemSalesFilters(productKey: 'p-1');
      f.setCategory(itemSalesDeletedItemKey, rows);
      expect(f.productKey, isNull);
      f.productKey = receiptsReportNoneKey;
      f.setCategory(itemSalesDeletedItemKey, rows);
      expect(f.productKey, receiptsReportNoneKey);
    });

    test('item matches the product uuid, not the name', () {
      expect(
        ids(filters: ItemSalesFilters(productKey: 'p-1')),
        ['cola'],
      );
      expect(
        ids(
          filters: ItemSalesFilters(
            productKey: receiptsReportNoneKey,
          ),
        ),
        ['noid'],
      );
    });

    test('custom price and wholesale; unknown matches neither', () {
      expect(
        ids(filters: ItemSalesFilters(customPrice: true)),
        ['cola'],
      );
      expect(
        ids(filters: ItemSalesFilters(wholesale: true)),
        ['cola'],
      );
      expect(
        ids(filters: ItemSalesFilters(wholesale: false)),
        ['chips'],
      );
    });

    test('revenue range uses line revenue', () {
      final f = ItemSalesFilters();
      f.receipt.revenueMin = 20;
      f.receipt.revenueMax = 50;
      expect(ids(filters: f), ['chips', 'nocost', 'part']);
    });

    test('an invalid range is not applied', () {
      final f = ItemSalesFilters();
      f.receipt.revenueMin = 50;
      f.receipt.revenueMax = 20;
      expect(f.receipt.revenueRangeError, isNotNull);
      expect(ids(filters: f).length, 5);
    });

    test('a negative profit range finds losses', () {
      final f = ItemSalesFilters();
      f.receipt.profitMax = -1;
      expect(ids(filters: f), ['chips', 'part']);
    });

    test('unknown profit is left out and counted', () {
      final f = ItemSalesFilters();
      f.receipt.profitMin = 0;
      expect(ids(filters: f), ['cola', 'noid']);
      expect(
        ItemSalesQuery.profitExcludedCount(
          rows: rows,
          period: const ReceiptsReportPeriod.allTime(),
          filters: f,
          departmentsEnabled: true,
          subStaffEnabled: true,
          profitVisible: true,
          closingTime: midnight,
        ),
        1,
      );
    });

    test('the profit range is off when profit is hidden', () {
      final f = ItemSalesFilters();
      f.receipt.profitMax = -1;
      expect(ids(filters: f, profitVisible: false).length, 5);
    });

    test('the quantity range needs one item', () {
      final f = ItemSalesFilters(quantityMin: 2);
      expect(f.quantityNeedsItem, isTrue);
      expect(f.quantityRangeActive, isFalse);
      expect(ids(filters: f).length, 5);
    });

    test('quantity range leaves out part payments', () {
      final f = ItemSalesFilters(
        productKey: 'p-2',
        quantityMin: 2,
      );
      expect(f.quantityRangeActive, isTrue);
      expect(ids(filters: f), ['chips']);
      expect(
        ItemSalesQuery.quantityExcludedCount(
          rows: rows,
          period: const ReceiptsReportPeriod.allTime(),
          filters: f,
          departmentsEnabled: true,
          subStaffEnabled: true,
          profitVisible: true,
          closingTime: midnight,
        ),
        1,
      );
      f.quantityMin = 4;
      expect(ids(filters: f), isEmpty);
    });

    test('filters combine', () {
      final f = ItemSalesFilters(
        categoryKey: 'c-drinks',
        productKey: 'p-2',
      );
      f.receipt.type = ReceiptType.sales;
      f.receipt.staffKey = 'staff-b';
      f.receipt.profitMax = 0;
      expect(ids(filters: f), ['chips']);
    });

    test('a new category clears an item outside it', () {
      final f = ItemSalesFilters(productKey: 'p-1');
      f.setCategory('c-drinks', rows);
      expect(f.productKey, 'p-1');
      f.setCategory('c-snacks', rows);
      expect(f.categoryKey, 'c-snacks');
      expect(f.productKey, isNull);
      f.productKey = 'p-2';
      f.setCategory(null, rows);
      expect(f.productKey, 'p-2');
    });

    test('period limits the rows', () {
      final dated = build([
        receipt(
          uuid: 'r-0000000000001',
          createdAt: DateTime(2026, 10, 16, 12),
          items: [line(uuid: 'old')],
        ),
        receipt(
          uuid: 'r-0000000000002',
          createdAt: DateTime(2026, 10, 17, 9),
          items: [line(uuid: 'new')],
        ),
      ]);
      expect(
        uuids(
          run(
            dated,
            period: ReceiptsReportPeriod.day(
              DateTime(2026, 10, 17),
            ),
          ),
        ),
        ['new'],
      );
    });

    test('counts, reset and copy', () {
      final f = ItemSalesFilters(
        categoryKey: 'c-drinks',
        voidFilter: ItemSalesVoidFilter.all,
        quantityMax: 3,
      );
      f.receipt.staffKey = 'staff-a';
      f.search = 'x';
      expect(f.activeCount, 4);
      expect(f.hasAnything, isTrue);

      final copy = f.copy();
      f.clearAll();
      expect(f.activeCount, 0);
      expect(f.search, '');
      expect(f.voidFilter, ItemSalesVoidFilter.notVoid);
      expect(f.hasAnything, isFalse);
      expect(copy.categoryKey, 'c-drinks');
      expect(copy.receipt.staffKey, 'staff-a');
      expect(copy.search, 'x');
    });
  });

  group('options', () {
    final rows = build(
      [
        receipt(
          uuid: 'r-0000000000001',
          createdAt: DateTime(2026, 10, 16),
          items: [
            line(productUuid: 'p-1', productName: 'Old Cola'),
            line(productUuid: 'p-9abcdefgh', productName: 'Cola'),
          ],
        ),
        receipt(
          uuid: 'r-0000000000002',
          createdAt: DateTime(2026, 10, 17),
          items: [
            line(productUuid: 'p-1', productName: 'Cola'),
            line(productUuid: 'p-2', productName: 'Chips'),
            line(productUuid: null, productName: 'Loose'),
          ],
        ),
      ],
      products: [
        product('p-1', categories: ['c-drinks']),
        product('p-2', categories: ['c-snacks']),
      ],
    );

    test('items use the latest name and tell twins apart', () {
      final options = ItemSalesOptions.items(rows);
      expect(options.map((o) => o.label).toList(), [
        'Chips',
        'Cola (p-1)',
        'Cola (p-9abcde)',
        'No item ID',
      ]);
      expect(options.last.key, receiptsReportNoneKey);
    });

    test('items narrow to the selected category', () {
      final options = ItemSalesOptions.items(
        rows,
        categoryOf: ItemSalesFilters(categoryKey: 'c-snacks'),
      );
      expect(options.map((o) => o.key).toList(), ['p-2']);
    });

    test('categories: No Category only when an item has none', () {
      final options = ItemSalesOptions.categories(
        categoryNames,
        rows,
      );
      expect(options.map((o) => o.label).toList(), [
        'Drinks',
        'Snacks',
        'Unknown (deleted item)',
      ]);
    });
  });

  group('sorting', () {
    ItemSalesRow sortRow(
      String id, {
      String? name,
      List<String>? categories,
      String barcode = '1',
      String? staffName,
      String? customerName,
      DateTime? createdAt,
      double quantity = 1,
      double? originalCost,
      double revenue = 0,
      double? costPrice,
    }) {
      return build(
        [
          receipt(
            uuid: 'r-$id-0000000000',
            barcode: barcode,
            staffName: staffName,
            customerUuid: customerName,
            customerName: customerName,
            createdAt: createdAt,
            items: [
              line(
                uuid: id,
                productUuid: 'p-$id',
                productName: name ?? '',
                quantity: quantity,
                originalCost: originalCost,
                revenue: revenue,
                costPrice: costPrice,
              ),
            ],
          ),
        ],
        products: [product('p-$id', categories: categories)],
      ).single;
    }

    void check(
      ItemSalesSortField field,
      List<ItemSalesRow> rows,
      List<String> ascending,
      List<String> descending,
    ) {
      expect(
        uuids(run(rows, sortField: field, ascending: true)),
        ascending,
        reason: '$field ascending',
      );
      expect(
        uuids(run(rows, sortField: field, ascending: false)),
        descending,
        reason: '$field descending',
      );
    }

    test('names are case-insensitive, missing names last', () {
      check(
        ItemSalesSortField.item,
        [
          sortRow('a', name: 'beta'),
          sortRow('b', name: 'Alpha'),
          sortRow('c'),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
      check(
        ItemSalesSortField.staff,
        [
          sortRow('a', staffName: 'bo'),
          sortRow('b', staffName: 'Ada'),
          sortRow('c', staffName: null),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
      check(
        ItemSalesSortField.customer,
        [
          sortRow('a', customerName: 'Zed'),
          sortRow('b', customerName: 'amy'),
          sortRow('c'),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
    });

    test('category uses the joined label, none last', () {
      check(
        ItemSalesSortField.category,
        [
          sortRow('a', categories: ['c-snacks']),
          sortRow('b', categories: ['c-drinks', 'c-snacks']),
          sortRow('c'),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
    });

    test('receipt ID', () {
      check(
        ItemSalesSortField.receiptId,
        [
          sortRow('a', barcode: '2'),
          sortRow('b', barcode: '1'),
        ],
        ['b', 'a'],
        ['a', 'b'],
      );
    });

    test('date is chronological', () {
      check(
        ItemSalesSortField.createdAt,
        [
          sortRow('a', createdAt: DateTime(2026, 10, 17, 9)),
          sortRow('b', createdAt: DateTime(2026, 10, 17, 8)),
        ],
        ['b', 'a'],
        ['a', 'b'],
      );
    });

    test('numbers compare as numbers, unknown last', () {
      check(
        ItemSalesSortField.quantity,
        [
          sortRow('a', quantity: 10),
          sortRow('b', quantity: 9),
        ],
        ['b', 'a'],
        ['a', 'b'],
      );
      check(
        ItemSalesSortField.sellingPrice,
        [
          sortRow('a', quantity: 1, originalCost: 10),
          sortRow('b', quantity: 1, originalCost: 9),
          sortRow('c', quantity: 0, originalCost: 5),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
      check(
        ItemSalesSortField.cost,
        [
          sortRow('a', costPrice: 10),
          sortRow('b', costPrice: 9),
          sortRow('c'),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
      check(
        ItemSalesSortField.revenue,
        [
          sortRow('a', revenue: 100),
          sortRow('b', revenue: 20),
        ],
        ['b', 'a'],
        ['a', 'b'],
      );
      check(
        ItemSalesSortField.profit,
        [
          sortRow('a', revenue: 100, costPrice: 50),
          sortRow('b', revenue: 10, costPrice: 30),
        ],
        ['b', 'a'],
        ['a', 'b'],
      );
      check(
        ItemSalesSortField.margin,
        [
          sortRow('a', revenue: 100, costPrice: 50),
          sortRow('b', revenue: 100, costPrice: 90),
          sortRow('c', revenue: 0, costPrice: 1),
        ],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
      );
    });

    test('ties keep receipt and line order', () {
      final rows = build([
        receipt(
          uuid: 'r-0000000000002',
          items: [line(uuid: 'r2-0'), line(uuid: 'r2-1')],
        ),
        receipt(
          uuid: 'r-0000000000001',
          items: [line(uuid: 'r1-0')],
        ),
      ]);
      expect(
        uuids(
          run(
            rows,
            sortField: ItemSalesSortField.revenue,
          ),
        ),
        ['r1-0', 'r2-0', 'r2-1'],
      );
    });

    test('sorting keeps the filters', () {
      final rows = [
        sortRow('a', name: 'Cola', revenue: 1),
        sortRow('b', name: 'Cola', revenue: 2),
        sortRow('c', name: 'Chips', revenue: 3),
      ];
      final f = ItemSalesFilters()..search = 'cola';
      expect(
        uuids(
          run(
            rows,
            filters: f,
            sortField: ItemSalesSortField.revenue,
          ),
        ),
        ['b', 'a'],
      );
    });
  });

  group('pagination', () {
    final rows = build([
      receipt(
        items: [
          for (var i = 0; i < 250; i++)
            line(uuid: 'l-${i.toString().padLeft(3, '0')}'),
        ],
      ),
    ]);

    test('pages of 100, sorted before paging', () {
      final sorted = run(rows);
      final page3 = ItemSalesQuery.paginate(sorted, 3);
      expect(page3.totalPages, 3);
      expect(page3.rows.length, 50);
      expect(page3.firstIndex, 201);
      expect(page3.lastIndex, 250);
      expect(page3.rows.first.line.uuid, 'l-200');
    });

    test('an out-of-range page is clamped', () {
      final sorted = run(rows);
      expect(ItemSalesQuery.paginate(sorted, 99).page, 3);
      expect(ItemSalesQuery.paginate(sorted, 0).page, 1);
    });

    test('no rows is page 1 of 1', () {
      final empty = ItemSalesQuery.paginate(const [], 4);
      expect(empty.page, 1);
      expect(empty.totalPages, 1);
      expect(empty.firstIndex, 0);
      expect(empty.lastIndex, 0);
    });

    test('a filter recalculates the pages', () {
      final f = ItemSalesFilters()..search = 'l-0';
      final page = ItemSalesQuery.paginate(
        run(rows, filters: f),
        3,
      );
      expect(page.totalCount, 100);
      expect(page.totalPages, 1);
      expect(page.page, 1);
    });
  });

  group('columns', () {
    test('all 25 in order when everything is on', () {
      final cols = ItemSalesColumnInfo.visible(
        departmentsEnabled: true,
        subStaffEnabled: true,
        costVisible: true,
      );
      expect(cols.length, 25);
      expect(cols, ItemSalesColumn.values);
      expect(
        ItemSalesColumn.grossValue.label,
        'Gross Value',
      );
    });

    test('settings and cost permission hide columns', () {
      final cols = ItemSalesColumnInfo.visible(
        departmentsEnabled: false,
        subStaffEnabled: false,
        costVisible: false,
      );
      expect(cols, isNot(contains(ItemSalesColumn.subStaff)));
      expect(cols, isNot(contains(ItemSalesColumn.department)));
      expect(cols, isNot(contains(ItemSalesColumn.costPrice)));
      expect(cols, isNot(contains(ItemSalesColumn.profit)));
      expect(cols, isNot(contains(ItemSalesColumn.margin)));
      expect(cols, contains(ItemSalesColumn.grossValue));
      expect(cols.length, 20);
    });
  });
}
