import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

void main() {
  final primaryUnit = ProductUnitsClass(
    uuid: 'unit-each',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Each',
    isPrimary: true,
    productUuid: 'product-1',
  );
  final caseUnit = ProductUnitsClass(
    uuid: 'unit-case',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 12,
    name: 'Case',
    isPrimary: false,
    productUuid: 'product-1',
  );
  final dozenUnit = ProductUnitsClass(
    uuid: 'unit-dozen',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 12,
    name: 'Dozen',
    isPrimary: false,
    productUuid: 'product-1',
  );

  OrderItems buildOrderItem({
    required String unitUuid,
    required double quantity,
    required double remainingQuantity,
  }) {
    return OrderItems(
      uuid: 'order-line-1',
      orderId: 'order-1',
      productName: 'Item',
      productUuid: 'product-1',
      createdAt: DateTime.utc(2026),
      staffName: 'Staff',
      staffId: 'staff-1',
      costPrice: 2,
      customerName: null,
      customerUuid: null,
      departmentName: null,
      departmentUuid: null,
      qttyPerGroup: null,
      quantity: quantity,
      revenue: 5,
      unit: 'Each',
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
      remainingQuantity: remainingQuantity,
      originalUseGroupQuantity: false,
      tempUseGroupQuantity: false,
      unitsList: [primaryUnit, caseUnit, dozenUnit],
      unitUuid: unitUuid,
    );
  }

  test('converts order remainder to primary units', () {
    final orderLine = buildOrderItem(
      unitUuid: caseUnit.uuid,
      quantity: 4,
      remainingQuantity: 3,
    );

    expect(orderLine.getActualRemainingQuantity(), 36);
  });

  test(
    'uses entered delivery quantity, not the order remainder',
    () {
      final deliveryLine = buildOrderItem(
        unitUuid: caseUnit.uuid,
        quantity: 1,
        remainingQuantity: 3,
      );

      expect(
        deliveryLine
            .getActualQuantityDuringDeliveryCheckout(),
        12,
      );
    },
  );

  test(
    'converts delivered primary quantity back to order unit',
    () {
      final orderLine = buildOrderItem(
        unitUuid: dozenUnit.uuid,
        quantity: 4,
        remainingQuantity: 3,
      );

      expect(orderLine.getQuantityFromPrimaryUnits(24), 2);
    },
  );

  test('rejects invalid unit conversion values', () {
    final invalidUnit = ProductUnitsClass(
      uuid: 'unit-invalid',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 0,
      name: 'Invalid',
      isPrimary: false,
      productUuid: 'product-1',
    );
    final orderLine = buildOrderItem(
      unitUuid: invalidUnit.uuid,
      quantity: 1,
      remainingQuantity: 1,
    );
    orderLine.unitsList = [primaryUnit, invalidUnit];

    expect(
      () => orderLine.getActualQuantity(),
      throwsStateError,
    );
  });

  test('cost total uses converted quantity', () {
    final deliveryLine = buildOrderItem(
      unitUuid: caseUnit.uuid,
      quantity: 2,
      remainingQuantity: 4,
    );

    expect(deliveryLine.getTotalCostPrice(), 48);
  });

  test(
    'legacy group orders retain their group conversion',
    () {
      final legacyGroupUnit = ProductUnitsClass(
        uuid: 'legacy-group',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 6,
        name: 'Group(s)',
        isPrimary: false,
        productUuid: 'product-1',
      );
      final legacyOrderLine = OrderItems(
        uuid: 'legacy-line',
        orderId: 'legacy-order',
        productName: 'Item',
        productUuid: 'product-1',
        createdAt: DateTime.utc(2026),
        staffName: 'Staff',
        staffId: 'staff-1',
        costPrice: 2,
        customerName: null,
        customerUuid: null,
        departmentName: null,
        departmentUuid: null,
        qttyPerGroup: 6,
        quantity: 4,
        revenue: 5,
        unit: 'Each',
        useGroupQuantity: true,
        useWholeSalePrice: false,
        groupUnit: 'Group(s)',
        addToStock: false,
        customPriceSet: false,
        discount: null,
        discountedAmount: null,
        fixedDiscount: null,
        isProductManaged: true,
        originalCost: null,
        setTotalPrice: false,
        remainingQuantity: 2,
        originalUseGroupQuantity: true,
        tempUseGroupQuantity: true,
        unitsList: [primaryUnit, legacyGroupUnit],
        unitUuid: null,
      );

      expect(
        legacyOrderLine.getActualRemainingQuantity(),
        12,
      );
      expect(legacyOrderLine.getActualQuantity(), 24);
    },
  );
}
