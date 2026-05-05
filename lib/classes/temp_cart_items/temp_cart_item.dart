import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
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

  TempCartItem({
    required this.item,
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
  });

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
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
  };

  factory TempCartItem.fromJson(Map<String, dynamic> json) {
    return TempCartItem(
      item: TempProductClass.fromJson(json['item']),
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
    );
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
    } else if (item.discount != null) {
      return (totalCost() * ((item.discount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double totalCost() {
    if (useWholeSalePrice) {
      return item.wholeSalePrice != null
          ? item.wholeSalePrice! * quantity
          : 0;
    } else if (customPrice != null) {
      if (setTotalPrice) {
        return customPrice!;
      } else {
        return customPrice! * quantity;
      }
    } else {
      return item.sellingPrice != null
          ? item.sellingPrice! * quantity
          : 0;
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

  double? costPrice() {
    return item.costPrice == 0
        ? null
        : item.costPrice * quantity;
  }

  double getItemDiscountedRemainingCost() {
    if (item.discount != null) {
      if (useWholeSalePrice) {
        return (((item.wholeSalePrice ?? 0) -
                ((item.wholeSalePrice ?? 0) *
                    (item.discount ?? 0) /
                    100)) *
            quantity);
      } else {
        return (((item.sellingPrice ?? 0) -
                ((item.sellingPrice ?? 0) *
                    (item.discount ?? 0) /
                    100)) *
            quantity);
      }
    } else {
      return totalCost();
    }
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
    );
  }

  // double profitOrLoss() {
  //   return item.costPrice == 0
  //       ? 0
  //       : totalCost() - (costPrice() ?? 0);
  // }
}
