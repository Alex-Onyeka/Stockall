import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_drafts/draft_items.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/providers/drafts_provider.dart';
import 'package:stockall/providers/invoices_provider.dart';
import 'package:stockall/providers/orders_provider.dart';
import 'package:stockall/providers/sales_provider.dart';

// A line saved with 2 Crate, before Crate (unit and price) was
// removed from the item. Reopening it must keep 2 Crate.

ProductUnitsClass unit(
  String uuid,
  String name,
  double conversion, {
  bool isPrimary = false,
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: name,
    isPrimary: isPrimary,
    productUuid: 'product-1',
  );
}

ProductPricesClass price(
  String uuid,
  double value, {
  bool isPrimary = false,
  int priceType = 1,
}) {
  return ProductPricesClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: value,
    name: uuid,
    isPrimary: isPrimary,
    itemUuid: 'product-1',
    isFixed: priceType == 2,
    priceType: priceType,
  );
}

final bottle = unit('unit-bottle', 'Bottle', 1, isPrimary: true);
final crate = unit('unit-crate', 'Crate', 10);
final retail = price('price-retail', 200, isPrimary: true);
final cratePrice = price('price-crate', 1500, priceType: 2);

final snapshotUnits = [bottle, crate];
final snapshotPrices = [retail, cratePrice];

// The item today: Crate unit and Crate price were removed.
TempProductClass liveProduct() {
  return TempProductClass(
    name: 'Soda',
    shopId: 1,
    unit: 'Bottle',
    isRefundable: false,
    costPrice: 0,
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
    unitsList: [bottle],
    pricesList: [retail],
    uuid: 'product-1',
    quantity: 100,
    widthDimension: null,
    heightDimension: null,
    manageSalesWastage: false,
  );
}

TempCartItem cartLine(
  TempProductClass item, {
  required String? unitUuid,
  required String? priceUuid,
  String? wastageUnitUuid,
}) {
  return TempCartItem(
    item: item,
    itemUuid: item.uuid,
    quantity: 2,
    discount: null,
    addToStock: false,
    setTotalPrice: false,
    useWholeSalePrice: false,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: false,
    uuid: 'line-1',
    unitUuid: unitUuid,
    priceUuid: priceUuid,
    widthDimension: null,
    heightDimension: null,
    quantityType: null,
    manageSalesWastage: wastageUnitUuid != null,
    isPercentageWastage: false,
    wastageAmount: null,
    wastageUnitUuid: wastageUnitUuid,
  );
}

DraftItems draftLine({
  required String unitUuid,
  required String priceUuid,
  String? wastageUnitUuid,
}) {
  return DraftItems(
    uuid: 'line-1',
    draftId: 'draft-1',
    createdAt: DateTime.utc(2026),
    productUuid: 'product-1',
    productName: 'Soda',
    quantity: 2,
    customPrice: null,
    setCustomPrice: false,
    setTotalPrice: false,
    useWholeSalePrice: false,
    addToStock: false,
    discount: null,
    fixedDiscount: null,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: false,
    unit: 'Crate',
    groupUnit: null,
    unitUuid: unitUuid,
    unitsList: snapshotUnits,
    priceUuid: priceUuid,
    pricesList: snapshotPrices,
    sellingPrice: null,
    costPrice: 0,
    isProductManaged: true,
    revenue: 3000,
    widthDimension: null,
    heightDimension: null,
    quantityType: null,
    manageSalesWastage: wastageUnitUuid != null,
    isPercentageWastage: false,
    wastageAmount: null,
    wastageUnitUuid: wastageUnitUuid,
  );
}

OrderItems orderLine({
  required String unitUuid,
  required String priceUuid,
}) {
  return OrderItems(
    uuid: 'line-1',
    orderId: 'order-1',
    productName: 'Soda',
    productUuid: 'product-1',
    createdAt: DateTime.utc(2026),
    staffName: 'Staff',
    staffId: 'staff-1',
    costPrice: 0,
    customerName: null,
    customerUuid: null,
    departmentName: null,
    departmentUuid: null,
    qttyPerGroup: null,
    quantity: 2,
    revenue: 3000,
    unit: 'Crate',
    useGroupQuantity: false,
    useWholeSalePrice: false,
    groupUnit: null,
    addToStock: false,
    customPriceSet: false,
    discount: null,
    discountedAmount: null,
    fixedDiscount: null,
    isProductManaged: true,
    originalCost: null,
    setTotalPrice: false,
    remainingQuantity: 2,
    originalUseGroupQuantity: false,
    tempUseGroupQuantity: false,
    unitsList: snapshotUnits,
    unitUuid: unitUuid,
    pricesList: snapshotPrices,
    priceUuid: priceUuid,
    widthDimension: null,
    heightDimension: null,
    quantityType: null,
    manageSalesWastage: null,
    isPercentageWastage: null,
    wastageAmount: null,
  );
}

TempProductSaleRecord saleLine({
  required String unitUuid,
  required String priceUuid,
  String? wastageUnitUuid,
  bool manageSalesWastage = false,
}) {
  return TempProductSaleRecord(
    createdAt: DateTime.utc(2026),
    productId: 0,
    productUuid: 'product-1',
    productName: 'Soda',
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff',
    customerUuid: null,
    customerName: null,
    recepitId: 0,
    receiptUuid: 'receipt-1',
    invoiceUuid: 'invoice-1',
    quantity: 2,
    revenue: 3000,
    discountedAmount: null,
    originalCost: null,
    discount: null,
    fixedDiscount: null,
    costPrice: 0,
    customPriceSet: false,
    departmentName: null,
    departmentUuid: null,
    uuid: 'line-1',
    isProductManaged: true,
    setTotalPrice: false,
    unit: 'Crate',
    useWholeSalePrice: false,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: false,
    unitsList: snapshotUnits,
    unitUuid: unitUuid,
    pricesList: snapshotPrices,
    priceUuid: priceUuid,
    widthDimension: null,
    heightDimension: null,
    quantityType: null,
    manageSalesWastage: manageSalesWastage,
    isPercentageWastage: false,
    wastageAmount: null,
    wastageUnitUuid: wastageUnitUuid,
  );
}

typedef LineProduct =
    TempProductClass Function(
      TempProductClass live, {
      required String unitUuid,
      required String priceUuid,
      String? wastageUnitUuid,
      void Function(String message)? onMissing,
    });

// Each converter, exactly as it builds the line's product.
final Map<String, LineProduct> converters = {
  'DraftsProvider': (
    live, {
    required unitUuid,
    required priceUuid,
    wastageUnitUuid,
    onMissing,
  }) {
    return DraftsProvider.editLineProduct(
      record: draftLine(
        unitUuid: unitUuid,
        priceUuid: priceUuid,
        wastageUnitUuid: wastageUnitUuid,
      ),
      product: live,
      onMissing: onMissing ?? (_) {},
    );
  },
  'OrdersProvider': (
    live, {
    required unitUuid,
    required priceUuid,
    wastageUnitUuid,
    onMissing,
  }) {
    return OrdersProvider.editLineProduct(
      record: orderLine(unitUuid: unitUuid, priceUuid: priceUuid),
      product: live,
      onMissing: onMissing ?? (_) {},
    );
  },
  'InvoicesProvider': (
    live, {
    required unitUuid,
    required priceUuid,
    wastageUnitUuid,
    onMissing,
  }) {
    return InvoicesProvider.editLineProduct(
      record: saleLine(
        unitUuid: unitUuid,
        priceUuid: priceUuid,
        wastageUnitUuid: wastageUnitUuid,
        manageSalesWastage: wastageUnitUuid != null,
      ),
      product: live,
      onMissing: onMissing ?? (_) {},
    );
  },
  // Receipt edit already swaps in the snapshot units first
  // (SalesProvider.convertReceiptToCartItems).
  'SalesProvider (receipt)': (
    live, {
    required unitUuid,
    required priceUuid,
    wastageUnitUuid,
    onMissing,
  }) {
    final record = saleLine(
      unitUuid: unitUuid,
      priceUuid: priceUuid,
      wastageUnitUuid: wastageUnitUuid,
      manageSalesWastage: wastageUnitUuid != null,
    );
    final newProduct = live.copyWith();
    newProduct.unitsList = record.getUnitListFinal();
    return SalesProvider.editLineProduct(
      record: record,
      product: newProduct,
      onMissing: onMissing ?? (_) {},
    );
  },
};

void main() {
  converters.forEach((name, lineProduct) {
    group(name, () {
      test('removed unit is kept for the line', () {
        final live = liveProduct();
        final item = lineProduct(
          live,
          unitUuid: crate.uuid,
          priceUuid: retail.uuid,
        );
        final line = cartLine(
          item,
          unitUuid: crate.uuid,
          priceUuid: retail.uuid,
        );

        expect(line.getSelectedUnit().uuid, crate.uuid);
        expect(line.getSelectedUnit().isPrimary, isFalse);
        expect(line.getPrimaryUnit().uuid, bottle.uuid);
        expect(line.getStockQuantity(), 20);
        expect(line.totalCost(), 4000);
      });

      test('removed price is kept for the line', () {
        final live = liveProduct();
        final item = lineProduct(
          live,
          unitUuid: crate.uuid,
          priceUuid: cratePrice.uuid,
        );
        final line = cartLine(
          item,
          unitUuid: crate.uuid,
          priceUuid: cratePrice.uuid,
        );

        expect(line.getSelectedPrice().uuid, cratePrice.uuid);
        expect(line.getSelectedPrice().isPrimary, isFalse);
        expect(item.getPrimaryPrice().uuid, retail.uuid);
        expect(line.totalCost(), 3000);
      });

      test('existing unit/price behave as today', () {
        final live = liveProduct();
        final item = lineProduct(
          live,
          unitUuid: bottle.uuid,
          priceUuid: retail.uuid,
        );
        final line = cartLine(
          item,
          unitUuid: bottle.uuid,
          priceUuid: retail.uuid,
        );

        if (name.startsWith('SalesProvider')) {
          // Receipt edit already copies the item; no further copy.
          expect(item.pricesList, same(live.pricesList));
        } else {
          expect(item, same(live));
        }
        expect(line.getSelectedUnit().uuid, bottle.uuid);
        expect(line.getSelectedPrice().uuid, retail.uuid);
        expect(line.totalCost(), 400);
      });

      test('missing from the snapshot falls back and logs', () {
        final live = liveProduct();
        final messages = <String>[];
        final item = lineProduct(
          live,
          unitUuid: 'unit-gone',
          priceUuid: 'price-gone',
          onMissing: messages.add,
        );
        final line = cartLine(
          item,
          unitUuid: 'unit-gone',
          priceUuid: 'price-gone',
        );

        expect(line.getSelectedUnit().uuid, bottle.uuid);
        expect(line.getSelectedPrice().uuid, retail.uuid);
        // Receipt units come from the snapshot already, so only
        // the price is checked (and logged) there.
        expect(
          messages,
          hasLength(name.startsWith('SalesProvider') ? 1 : 2),
        );
        expect(
          messages.any((m) => m.contains('price-gone')),
          isTrue,
        );
      });

      test('the item and other lines are not changed', () {
        final live = liveProduct();
        final item = lineProduct(
          live,
          unitUuid: crate.uuid,
          priceUuid: cratePrice.uuid,
        );
        final otherLine = cartLine(
          live,
          unitUuid: crate.uuid,
          priceUuid: cratePrice.uuid,
        );

        expect(item, isNot(same(live)));
        expect(live.unitsList!.map((u) => u.uuid), [bottle.uuid]);
        expect(live.pricesList!.map((p) => p.uuid), [retail.uuid]);
        expect(otherLine.getSelectedUnit().uuid, bottle.uuid);
        expect(otherLine.getSelectedPrice().uuid, retail.uuid);
      });
    });
  });

  test('restored entry never becomes primary', () {
    final primaryCrate = crate.copyWith(isPrimary: true);
    final item = liveProduct().withLineSnapshot(
      unitUuids: [crate.uuid],
      snapshotUnits: [primaryCrate],
    );

    expect(
      item.unitsList!.where((u) => u.isPrimary).map((u) => u.uuid),
      [bottle.uuid],
    );
    expect(primaryCrate.isPrimary, isTrue);
  });

  test('line and wastage unit both missing are restored once each', () {
    final item = liveProduct().withLineSnapshot(
      unitUuids: [crate.uuid, crate.uuid],
      snapshotUnits: snapshotUnits,
    );

    expect(item.unitsList!.map((u) => u.uuid), [
      bottle.uuid,
      crate.uuid,
    ]);
  });

  test('items without stored lists keep today\'s behaviour', () {
    final legacy = liveProduct()..unitsList = [];
    final messages = <String>[];
    final item = legacy.withLineSnapshot(
      unitUuids: [crate.uuid],
      snapshotUnits: snapshotUnits,
      onMissing: messages.add,
    );

    expect(item, same(legacy));
    expect(messages, isEmpty);
  });

  group('wastage unit', () {
    test('draft: removed wastage unit is kept', () {
      final item = DraftsProvider.editLineProduct(
        record: draftLine(
          unitUuid: bottle.uuid,
          priceUuid: retail.uuid,
          wastageUnitUuid: crate.uuid,
        ),
        product: liveProduct(),
        onMissing: (_) {},
      );
      final line = cartLine(
        item,
        unitUuid: bottle.uuid,
        priceUuid: retail.uuid,
        wastageUnitUuid: crate.uuid,
      );

      expect(line.getSelectedUnit().uuid, bottle.uuid);
      expect(line.wastageAreaPerUnit(), 10);
    });

    test('invoice: removed wastage unit is kept', () {
      final item = InvoicesProvider.editLineProduct(
        record: saleLine(
          unitUuid: bottle.uuid,
          priceUuid: retail.uuid,
          wastageUnitUuid: crate.uuid,
          manageSalesWastage: true,
        ),
        product: liveProduct(),
        onMissing: (_) {},
      );
      final line = cartLine(
        item,
        unitUuid: bottle.uuid,
        priceUuid: retail.uuid,
        wastageUnitUuid: crate.uuid,
      );

      expect(line.wastageAreaPerUnit(), 10);
    });

    test('invoice: not restored when wastage is not managed', () {
      final live = liveProduct();
      final item = InvoicesProvider.editLineProduct(
        record: saleLine(
          unitUuid: bottle.uuid,
          priceUuid: retail.uuid,
          wastageUnitUuid: crate.uuid,
          manageSalesWastage: false,
        ),
        product: live,
        onMissing: (_) {},
      );

      expect(item, same(live));
    });
  });
}
