import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

void main() {
  ProductPricesClass price({
    required String uuid,
    required double value,
    required bool isPrimary,
    String name = 'Price',
    int priceType = 1,
  }) {
    return ProductPricesClass(
      uuid: uuid,
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      priceValue: value,
      name: name,
      isPrimary: isPrimary,
      itemUuid: 'product-1',
      isFixed: priceType == 2,
      priceType: priceType,
    );
  }

  ProductUnitsClass unit({
    required String uuid,
    required String name,
    required double conversion,
    required bool isPrimary,
    int? dimensionType,
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
      dimensionType: dimensionType,
    );
  }

  ProductPricesClass newPrice() =>
      price(uuid: 'price-new', value: 0, isPrimary: true);
  ProductUnitsClass newUnit() => unit(
    uuid: 'unit-new',
    name: 'Unit(s)',
    conversion: 1,
    isPrimary: true,
  );

  final retail = price(
    uuid: 'price-retail',
    value: 200,
    isPrimary: true,
    name: 'Retail',
  );
  final crate = price(
    uuid: 'price-crate',
    value: 1200,
    isPrimary: false,
    name: 'Crate',
    priceType: 2,
  );
  final bottleUnit = unit(
    uuid: 'unit-bottle',
    name: 'Bottle',
    conversion: 1,
    isPrimary: true,
  );
  final crateUnit = unit(
    uuid: 'unit-crate',
    name: 'Crate',
    conversion: 10,
    isPrimary: false,
  );

  group('hasMultiple (toggle state is derived)', () {
    test('prices: 0 and 1 are single, 2 is multiple', () {
      expect(ProductPricesClass.hasMultiple(null), isFalse);
      expect(ProductPricesClass.hasMultiple([]), isFalse);
      expect(ProductPricesClass.hasMultiple([retail]), isFalse);
      expect(
        ProductPricesClass.hasMultiple([retail, crate]),
        isTrue,
      );
    });

    test('units: 0 and 1 are single, 2 is multiple', () {
      expect(ProductUnitsClass.hasMultiple(null), isFalse);
      expect(ProductUnitsClass.hasMultiple([bottleUnit]), isFalse);
      expect(
        ProductUnitsClass.hasMultiple([bottleUnit, crateUnit]),
        isTrue,
      );
    });
  });

  group('singlePriceList', () {
    test('keeps only the primary, same uuid/name/type, new value', () {
      final result = ProductPricesClass.singlePriceList(
        prices: [crate, retail],
        priceValue: 250,
        newPrice: newPrice,
      );

      expect(result, hasLength(1));
      expect(result.single.uuid, 'price-retail');
      expect(result.single.name, 'Retail');
      expect(result.single.priceType, 1);
      expect(result.single.priceValue, 250);
      expect(result.single.isPrimary, isTrue);
    });

    test('uses the first price when none is primary', () {
      final first = price(uuid: 'a', value: 10, isPrimary: false);
      final second = price(uuid: 'b', value: 20, isPrimary: false);

      final result = ProductPricesClass.singlePriceList(
        prices: [first, second],
        priceValue: 15,
        newPrice: newPrice,
      );

      expect(result.single.uuid, 'a');
      expect(result.single.isPrimary, isTrue);
    });

    test('empty list and no value stays empty', () {
      expect(
        ProductPricesClass.singlePriceList(
          prices: [],
          priceValue: null,
          newPrice: newPrice,
        ),
        isEmpty,
      );
    });

    test('empty list with a value creates one primary price', () {
      final result = ProductPricesClass.singlePriceList(
        prices: [],
        priceValue: 500,
        newPrice: newPrice,
      );

      expect(result.single.uuid, 'price-new');
      expect(result.single.priceValue, 500);
      expect(result.single.isPrimary, isTrue);
    });

    test('does not change the input list', () {
      final prices = [retail, crate];
      ProductPricesClass.singlePriceList(
        prices: prices,
        priceValue: 999,
        newPrice: newPrice,
      );

      expect(prices, hasLength(2));
      expect(retail.priceValue, 200);
    });
  });

  test('withPrimaryValue updates the primary and keeps the others', () {
    final result = ProductPricesClass.withPrimaryValue(
      prices: [retail, crate],
      priceValue: 300,
      newPrice: newPrice,
    );

    expect(result, hasLength(2));
    expect(
      result.firstWhere((p) => p.uuid == 'price-retail').priceValue,
      300,
    );
    expect(
      result.firstWhere((p) => p.uuid == 'price-crate').priceValue,
      1200,
    );
  });

  group('single unit', () {
    test('singleUnitList keeps the primary uuid/conversion/type', () {
      final boxUnit = unit(
        uuid: 'unit-box',
        name: 'Box',
        conversion: 12,
        isPrimary: true,
        dimensionType: ProductUnitsClass.sheetUnit,
      );

      final result = ProductUnitsClass.singleUnitList([
        bottleUnit.copyWith(isPrimary: false),
        boxUnit,
      ]);

      expect(result, hasLength(1));
      expect(result.single.uuid, 'unit-box');
      expect(result.single.conversion, 12);
      expect(
        result.single.dimensionType,
        ProductUnitsClass.sheetUnit,
      );
    });

    test('withPrimaryName renames only the primary', () {
      final result = ProductUnitsClass.withPrimaryName(
        units: [bottleUnit, crateUnit],
        name: 'Can',
        newUnit: newUnit,
      );

      expect(result, hasLength(2));
      expect(result.firstWhere((u) => u.isPrimary).name, 'Can');
      expect(result.firstWhere((u) => u.isPrimary).conversion, 1);
      expect(
        result.firstWhere((u) => u.uuid == 'unit-crate').name,
        'Crate',
      );
    });

    test('picking Bottle(s) then Kg(s) leaves one unit, same uuid', () {
      final afterBottle = ProductUnitsClass.withPrimaryName(
        units: [],
        name: 'Bottle(s)',
        newUnit: newUnit,
      );
      final afterKg = ProductUnitsClass.withPrimaryName(
        units: afterBottle,
        name: 'Kg(s)',
        newUnit: newUnit,
      );

      expect(afterBottle, hasLength(1));
      expect(afterKg, hasLength(1));
      expect(afterKg.single.uuid, afterBottle.single.uuid);
      expect(afterKg.single.name, 'Kg(s)');
      expect(afterKg.single.isPrimary, isTrue);
      expect(ProductUnitsClass.singleUnitList(afterKg), hasLength(1));
    });
  });

  test('cart total after collapsing to a single price', () {
    final singlePrices = ProductPricesClass.singlePriceList(
      prices: [retail, crate],
      priceValue: 250,
      newPrice: newPrice,
    );
    final product = TempProductClass(
      name: 'Coke',
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
      unitsList: ProductUnitsClass.singleUnitList([
        bottleUnit,
        crateUnit,
      ]),
      pricesList: singlePrices,
      uuid: 'product-1',
      widthDimension: null,
      heightDimension: null,
      manageSalesWastage: false,
    );
    final cartItem = TempCartItem(
      item: product,
      itemUuid: product.uuid,
      quantity: 3,
      discount: null,
      addToStock: false,
      setTotalPrice: false,
      useWholeSalePrice: false,
      useGroupQuantity: false,
      qttyPerGroup: null,
      isVoid: false,
      uuid: 'cart-item-1',
      unitUuid: bottleUnit.uuid,
      priceUuid: retail.uuid,
      widthDimension: null,
      heightDimension: null,
      quantityType: null,
      manageSalesWastage: null,
      isPercentageWastage: null,
      wastageAmount: null,
    );

    expect(cartItem.totalCost(), 750);
  });
}
