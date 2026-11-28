/// Carts and lines for the LAN cart stock hold tests.
library;

import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

import 'lan_fixtures.dart';

/// A 1D line of [item] ([quantity] of its primary unit).
TempCartItem line(
  TempProductClass item,
  double quantity, {
  bool isVoid = false,
  String? uuid,
}) {
  final l = TempCartItem.forProduct(item, quantity: quantity);
  l.isVoid = isVoid;
  if (uuid != null) l.uuid = uuid;
  return l;
}

/// [uuid] with a second unit, "Pack", of [packOf] primary units.
TempProductClass productWithPack(String uuid, {double packOf = 6}) {
  final p = product(uuid);
  p.unitsList = [
    ...p.unitsList!,
    ProductUnitsClass(
      uuid: 'pack-$uuid',
      staffUuid: 's',
      createdAt: t0,
      staffName: 'S',
      conversion: packOf,
      name: 'Pack',
      isPrimary: false,
      productUuid: uuid,
    ),
  ];
  return p;
}

/// A 4 × 3 sheet product (stock counted in area).
TempProductClass sheet(String uuid) {
  final p =
      product(uuid)
        ..quantityType = 2
        ..widthDimension = 4
        ..heightDimension = 3
        ..manageSalesWastage = false;
  return p;
}

TempCart cart(
  String id,
  List<TempCartItem> lines, {
  int type = 1,
  String? receiptEdit,
  List<TempCartItem>? original,
}) {
  return TempCart(
    cartItems: lines,
    tempCartItems: original,
    id: id,
    staffName: 'Staff',
    staffId: 'staff-1',
    departmentName: null,
    departmentUuid: null,
    customDate: null,
    hasPrintedDocket: false,
    subStaffName: null,
    timeOfDay: null,
    comment: null,
    cartItemTypeIndex: type,
    orderUuidEdit: null,
    receiptUuidEdit: receiptEdit,
  );
}
