import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:hive/hive.dart';

part 'temp_cart_item.g.dart';

@HiveType(typeId: 72)
class TempCartItem extends HiveObject {
  @HiveField(0)
  TempProductClass item;

  @HiveField(1)
  double? discount;

  @HiveField(2)
  double? fixedDiscount;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double? customPrice;

  @HiveField(5)
  bool setCustomPrice;

  @HiveField(6)
  bool useWholeSalePrice;

  @HiveField(7)
  bool setTotalPrice;

  @HiveField(8)
  bool addToStock;

  @HiveField(9)
  String? salesRecordId;

  @HiveField(10)
  bool? useGroupQuantity;

  @HiveField(11)
  double? qttyPerGroup;

  @HiveField(12)
  bool? isVoid;

  @HiveField(13)
  String? itemUuid;

  @HiveField(14)
  String? uuid;

  @HiveField(15)
  double? remainingQuantity;

  @HiveField(16)
  double? remainingBalance;

  @HiveField(17)
  String? unitUuid;

  @HiveField(18)
  String? priceUuid;

  TempCartItem({
    required this.item,
    required this.itemUuid,
    required this.quantity,
    required this.discount,
    this.fixedDiscount,
    this.customPrice,
    this.setCustomPrice = true,
    required this.addToStock,
    required this.setTotalPrice,
    required this.useWholeSalePrice,
    this.salesRecordId,
    required this.useGroupQuantity,
    required this.qttyPerGroup,
    required this.isVoid,
    required this.uuid,
    this.remainingQuantity,
    this.remainingBalance,
    required this.unitUuid,
    required this.priceUuid,
  });

  Map<String, dynamic> toJson() => {
    'item': item.toJson(isIncludeQuantity: true),
    'item_uuid': itemUuid,
    'discount': discount,
    'fixed_discount': fixedDiscount,
    'quantity': quantity,
    'customPrice': customPrice,
    'setCustomPrice': setCustomPrice,
    'setTotalPrice': setTotalPrice,
    'addToStock': addToStock,
    'salesRecordId': salesRecordId,
    'use_whole_sale_price': useWholeSalePrice,
    'sell_group': useGroupQuantity,
    'qtty_per_group': qttyPerGroup,
    'is_void': isVoid,
    'uuid': uuid,
    'remaining_quantity': remainingQuantity,
    'remaining_balance': remainingBalance,
    'unit_uuid': unitUuid,
    'price_uuid': priceUuid,
  };

  factory TempCartItem.fromJson(Map<String, dynamic> json) {
    return TempCartItem(
      item: TempProductClass.fromJson(json['item']),
      uuid: json['uuid'],
      itemUuid: json['item_uuid'],
      discount: json['discount'],
      quantity: json['quantity'],
      customPrice: json['customPrice'],
      setCustomPrice: json['setCustomPrice'],
      addToStock: json['addToStock'],
      setTotalPrice: json['setTotalPrice'],
      salesRecordId: json['salesRecordId'],
      fixedDiscount: json['fixed_discount'],
      useWholeSalePrice: json['use_whole_sale_price'],
      useGroupQuantity: json['sell_group'],
      qttyPerGroup: json['qtty_per_group'],
      isVoid: json['is_void'],
      remainingBalance: json['remaining_balance'],
      remainingQuantity: json['remaining_quantity'],
      unitUuid: json['unit_uuid'],
      priceUuid: json['price_uuid'],
    );
  }

  TempCartItem copyWith({
    TempProductClass? item,
    double? discount,
    double? fixedDiscount,
    double? quantity,
    double? customPrice,
    bool? setCustomPrice,
    bool? useWholeSalePrice,
    bool? setTotalPrice,
    bool? addToStock,
    String? salesRecordId,
    bool? useGroupQuantity,
    double? qttyPerGroup,
    bool? isVoid,
    String? itemUuid,
    String? uuid,
    double? remainingQuantity,
    double? remainingBalance,
    String? unitUuid,
    String? priceUuid,
  }) {
    return TempCartItem(
      item: item ?? this.item,
      discount: discount ?? this.discount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      setCustomPrice: setCustomPrice ?? this.setCustomPrice,
      useWholeSalePrice:
          useWholeSalePrice ?? this.useWholeSalePrice,
      setTotalPrice: setTotalPrice ?? this.setTotalPrice,
      addToStock: addToStock ?? this.addToStock,
      salesRecordId: salesRecordId ?? this.salesRecordId,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      isVoid: isVoid ?? this.isVoid,
      itemUuid: itemUuid ?? this.itemUuid,
      uuid: uuid ?? this.uuid,
      remainingQuantity:
          remainingQuantity ?? this.remainingQuantity,
      remainingBalance:
          remainingBalance ?? this.remainingBalance,
      unitUuid: unitUuid ?? this.unitUuid,
      priceUuid: priceUuid ?? this.priceUuid,
    );
  }

  //
  //
  //
  //
  //

  List<ProductPricesClass> getPriceListFinal() {
    return getPricesList()
        .map((item) => item.copyWith())
        .toList();
  }

  ProductPricesClass getSelectedPrice({
    String? priceUuidNew,
  }) {
    var items = getPricesList().where(
      (item) => item.uuid == (priceUuidNew ?? priceUuid),
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getPricesList().firstWhere(
        (item) => item.isPrimary,
      );
    }
  }

  ProductPricesClass getPrimaryPrice({
    String? priceUuidNew,
  }) {
    var items = getPricesList().where(
      (item) => item.isPrimary,
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getPricesList()
          .where(
            (item) =>
                item.uuid == (priceUuidNew ?? priceUuid),
          )
          .first;
    }
  }

  ProductPricesClass defaultPrice() {
    return ProductPricesClass(
      uuid: uuidGen(),
      staffUuid: currentUser().userId,
      createdAt: DateTime.now(),
      staffName: currentUser().name,
      priceValue: 0,
      name: 'Price',
      isPrimary: true,
      itemUuid: uuid!,
      priceType: 1,
    );
  }

  List<ProductPricesClass> getPricesList() {
    return item.getPricesList();
  }

  //
  //
  //
  //
  //
  //
  //
  //

  List<ProductUnitsClass> getUnitListFinal() {
    return getUnitsList()
        .map((item) => item.copyWith())
        .toList();
  }

  double getSelectedUnitQuantity({
    BuildContext? context,
    String? unitUuidNew,
  }) {
    if (getUnitsList().isEmpty == true) {
      return quantity;
    } else {
      var items = getUnitsList().where(
        (item) => item.uuid == (unitUuidNew ?? unitUuid),
      );
      if (items.isEmpty == true) {
        return quantity;
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: 1,
          context: context,
        );
      }
    }
  }

  ProductUnitsClass getSelectedUnit({String? unitUuidNew}) {
    var items = getUnitsList().where(
      (item) => item.uuid == (unitUuidNew ?? unitUuid),
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getUnitsList().firstWhere(
        (item) => item.isPrimary,
      );
    }
  }

  ProductUnitsClass getPrimaryUnit({String? unitUuidNew}) {
    var items = getUnitsList().where(
      (item) => item.isPrimary,
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getUnitsList()
          .where(
            (item) =>
                item.uuid == (unitUuidNew ?? unitUuid),
          )
          .first;
    }
  }

  ProductUnitsClass defaultUnit() {
    return ProductUnitsClass(
      uuid: uuidGen(),
      staffUuid: currentUser().userId,
      createdAt: DateTime.now(),
      staffName: currentUser().name,
      conversion: 1,
      name: 'Unit(s)',
      isPrimary: true,
      productUuid: uuid!,
    );
  }

  List<ProductUnitsClass> getUnitsList() {
    return item.getUnitsList();
  }

  TempProductClass? getItem() {
    // List<TempProductClass> products =
    //     returnData().productListMain
    //         .where(
    //           (pro) =>
    //               pro.uuid == itemUuid ||
    //               pro.uuid == item.uuid,
    //         )
    //         .toList();
    // if (products.isNotEmpty) {
    //   var newItem = products.first.copyWith();
    //   return newItem;
    // } else {
    return item;
    // }
  }

  double? returnDiscount() {
    return discount;
  }

  double? returnFixedDiscount() {
    return fixedDiscount;
  }

  double discountCost() {
    if (returnDiscount() != null) {
      return (totalCost() *
          ((returnDiscount() ?? 0) / 100));
    } else if (returnFixedDiscount() != null) {
      return returnFixedDiscount() ?? 0;
    } else if (getItem()?.discount != null) {
      return (totalCost() *
          ((getItem()?.discount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double totalCost() {
    if (customPrice != null) {
      if (setTotalPrice) {
        return customPrice!;
      } else {
        return customPrice! *
            getSelectedUnit().getQuantityEquivMultiplied(
              index: 1,
              product: item,
              newQuantity: quantity,
            );
      }
    } else {
      final selectedPrice = getSelectedPrice();
      if (selectedPrice.priceType == 1) {
        return selectedPrice.priceValue * quantity;
      }
      return selectedPrice.priceValue *
          getSelectedUnit().getQuantityEquivMultiplied(
            index: 1,
            product: item,
            newQuantity: quantity,
          );
    }
  }

  double revenue() {
    if (returnShopProvider().userShop()!.applyVAT!) {
      return (totalCost() - discountCost()) +
          (totalCost() * (vat / 100));
    } else {
      return totalCost() - discountCost();
    }
  }

  double revenuePerItem() {
    return revenue() /
        getSelectedUnit().getQuantityEquivMultiplied(
          index: 1,
          newQuantity: quantity,
        );
  }

  double? costPrice() {
    return (getItem()?.costPrice ?? 0) == 0
        ? null
        : (getItem()?.costPrice ?? 0) *
            getSelectedUnit().getQuantityEquivMultiplied(
              index: 1,
              newQuantity: quantity,
            );
  }

  double getItemDiscountedRemainingCost() {
    if (getItem()?.discount != null) {
      return (((getItem()?.getPrimaryPrice().priceValue ??
                  0) -
              ((getItem()?.getPrimaryPrice().priceValue ??
                      0) *
                  (getItem()?.discount ?? 0) /
                  100)) *
          getSelectedUnit().getQuantityEquivMultiplied(
            index: 1,
            product: item,
            newQuantity: quantity,
          ));
      // }
    } else {
      return totalCost();
    }
  }

  double getRealQuantity() {
    return getSelectedUnit().getQuantityEquivMultiplied(
      index: 1,
      newQuantity: quantity,
    );
  }

  double getRealQuantityDivided() {
    return getSelectedUnit().getQuantityEquivDivided(
      index: 1,
      newQuantity: quantity,
    );
  }

  String getUnit() {
    var priUnit = getSelectedUnit();
    if (priUnit.name == 'Others') {
      return 'Unit(s)';
    } else {
      return priUnit.name;
    }
  }
}
