import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

class TempCartItem {
  final TempProductClass item;
  double? discount;
  double quantity;
  double? customPrice;
  bool setCustomPrice;
  bool setTotalPrice;
  bool addToStock;
  String? salesRecordId;

  TempCartItem({
    required this.item,
    required this.quantity,
    required this.discount,
    this.customPrice,
    this.setCustomPrice = true,
    required this.addToStock,
    required this.setTotalPrice,
    this.salesRecordId,
  });

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'discount': discount,
    'quantity': quantity,
    'customPrice': customPrice,
    'setCustomPrice': setCustomPrice,
    'setTotalPrice': setTotalPrice,
    'addToStock': addToStock,
    'salesRecordId': salesRecordId,
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
    );
  }

  double? returnDiscount() {
    return discount ?? item.discount;
  }

  double discountCost() {
    if (returnDiscount() != null) {
      return (totalCost() *
          ((returnDiscount() ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double totalCost() {
    if (customPrice != null) {
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

  double revenue(BuildContext context) {
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

  double profitOrLoss() {
    return item.costPrice == 0
        ? 0
        : totalCost() - (costPrice() ?? 0);
  }
}
