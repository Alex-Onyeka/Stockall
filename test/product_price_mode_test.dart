import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

void main() {
  final bottleUnit = ProductUnitsClass(
    uuid: 'unit-bottle',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Bottle',
    isPrimary: true,
    productUuid: 'product-1',
  );
  final crateUnit = ProductUnitsClass(
    uuid: 'unit-crate',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 10,
    name: 'Crate',
    isPrimary: false,
    productUuid: 'product-1',
  );
  final dynamicPrice = ProductPricesClass(
    uuid: 'price-dynamic',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: 200,
    name: 'Bottle',
    isPrimary: true,
    itemUuid: 'product-1',
  );
  final fixedPrice = ProductPricesClass(
    uuid: 'price-fixed',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: 1200,
    name: 'Crate',
    isPrimary: false,
    itemUuid: 'product-1',
    isFixed: true,
    priceType: 2,
  );

  TempCartItem buildCartItem({
    required ProductPricesClass price,
    required double quantity,
  }) {
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
      unitsList: [bottleUnit, crateUnit],
      pricesList: [dynamicPrice, fixedPrice],
      uuid: 'product-1',
      widthDimension: null,
      heightDimension: null,
    );

    return TempCartItem(
      item: product,
      itemUuid: product.uuid,
      quantity: quantity,
      discount: null,
      addToStock: false,
      setTotalPrice: false,
      useWholeSalePrice: false,
      useGroupQuantity: false,
      qttyPerGroup: null,
      isVoid: false,
      uuid: 'cart-item-1',
      unitUuid: crateUnit.uuid,
      priceUuid: price.uuid,
      widthDimension: null,
      heightDimension: null,
      quantityType: null,
    );
  }

  test('legacy price JSON defaults to dynamic', () {
    final price = ProductPricesClass.fromJson({
      'uuid': 'legacy-price',
      'created_at': DateTime.utc(2026).toIso8601String(),
      'staff_name': null,
      'staff_uuid': null,
      'price_value': 200,
      'name': 'Bottle',
      'is_primary': true,
      'item_uuid': 'product-1',
    });

    expect(price.isFixed, isFalse);
  });

  test('fixed price mode is preserved in JSON and copies', () {
    final restored = ProductPricesClass.fromJson(fixedPrice.toJson());

    expect(restored.isFixed, isTrue);
    expect(fixedPrice.copyWith().isFixed, isTrue);
    expect(dynamicPrice.copyWith(isFixed: true).isFixed, isTrue);
  });

  test('dynamic price applies selected unit conversion', () {
    expect(buildCartItem(price: dynamicPrice, quantity: 2).totalCost(), 4000);
  });

  test('fixed price ignores selected unit conversion', () {
    expect(buildCartItem(price: fixedPrice, quantity: 2).totalCost(), 2400);
  });
}
