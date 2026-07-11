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

  @HiveField(11)
  double? qttyPerGroup;

  @HiveField(12)
  bool? isVoid;

  @HiveField(13)
  String? itemUuid;

  @HiveField(14)
  String? uuid;

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
    );
  }

  TempProductClass? getItem() {
    List<TempProductClass> products =
        returnData().productListMain
            .where(
              (pro) =>
                  pro.uuid == itemUuid ||
                  pro.uuid == item.uuid,
            )
            .toList();
    if (products.isNotEmpty) {
      return products.first;
    } else {
      return item;
    }
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

  double discountCostForAltScreen() {
    if (returnDiscount() != null) {
      return (totalCostForAltScreen() *
          ((returnDiscount() ?? 0) / 100));
    } else if (returnFixedDiscount() != null) {
      return returnFixedDiscount() ?? 0;
    } else if (item.discount != null) {
      return (totalCostForAltScreen() *
          ((item.discount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double totalCost() {
    if (useGroupQuantity == true) {
      if (useWholeSalePrice) {
        return getItem()?.wholeSalePrice != null
            ? (getItem()?.wholeSalePrice ?? 0) *
                (quantity * getQttyPerGroup())
            : 0;
      } else if (customPrice != null) {
        if (setTotalPrice) {
          return customPrice!;
        } else {
          return customPrice! *
              (quantity * getQttyPerGroup());
        }
      } else {
        return getItem()?.sellingPrice != null
            ? (getItem()?.sellingPrice ?? 0) *
                (quantity * getQttyPerGroup())
            : 0;
      }
    } else {
      if (useWholeSalePrice) {
        return getItem()?.wholeSalePrice != null
            ? (getItem()?.wholeSalePrice ?? 0) * quantity
            : 0;
      } else if (customPrice != null) {
        if (setTotalPrice) {
          return customPrice!;
        } else {
          return customPrice! * quantity;
        }
      } else {
        return getItem()?.sellingPrice != null
            ? (getItem()?.sellingPrice ?? 0) * quantity
            : 0;
      }
    }
  }

  double totalCostForAltScreen() {
    if (useGroupQuantity == true) {
      if (useWholeSalePrice) {
        return item.wholeSalePrice != null
            ? (item.wholeSalePrice ?? 0) *
                (quantity * getQttyPerGroup())
            : 0;
      } else if (customPrice != null) {
        if (setTotalPrice) {
          return customPrice!;
        } else {
          return customPrice! *
              (quantity * getQttyPerGroup());
        }
      } else {
        return item.sellingPrice != null
            ? (item.sellingPrice ?? 0) *
                (quantity * getQttyPerGroup())
            : 0;
      }
    } else {
      if (useWholeSalePrice) {
        return item.wholeSalePrice != null
            ? (item.wholeSalePrice ?? 0) * quantity
            : 0;
      } else if (customPrice != null) {
        if (setTotalPrice) {
          return customPrice!;
        } else {
          return customPrice! * quantity;
        }
      } else {
        return item.sellingPrice != null
            ? (item.sellingPrice ?? 0) * quantity
            : 0;
      }
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

  double revenueForAltScreen() {
    if (returnShopProvider().userShop()!.applyVAT!) {
      return (totalCostForAltScreen() -
              discountCostForAltScreen()) +
          (totalCostForAltScreen() * (vat / 100));
    } else {
      return totalCostForAltScreen() -
          discountCostForAltScreen();
    }
  }

  double? costPrice() {
    if (useGroupQuantity == true) {
      return (getItem()?.costPrice ?? 0) == 0
          ? null
          : (getItem()?.costPrice ?? 0) *
              (quantity * getQttyPerGroup());
    } else {
      return (getItem()?.costPrice ?? 0) == 0
          ? null
          : (getItem()?.costPrice ?? 0) * quantity;
    }
  }

  double? costPriceForAltScreen() {
    if (useGroupQuantity == true) {
      return (item.costPrice) == 0
          ? null
          : (item.costPrice) *
              (quantity * getQttyPerGroupForAltScreen());
    } else {
      return (item.costPrice) == 0
          ? null
          : (item.costPrice) * quantity;
    }
  }

  double getItemDiscountedRemainingCost() {
    if (useGroupQuantity == true) {
      if (getItem()?.discount != null) {
        if (useWholeSalePrice) {
          return (((getItem()?.wholeSalePrice ?? 0) -
                  ((getItem()?.wholeSalePrice ?? 0) *
                      (getItem()?.discount ?? 0) /
                      100)) *
              (quantity * getQttyPerGroup()));
        } else {
          return (((getItem()?.sellingPrice ?? 0) -
                  ((getItem()?.sellingPrice ?? 0) *
                      (getItem()?.discount ?? 0) /
                      100)) *
              (quantity * getQttyPerGroup()));
        }
      } else {
        return totalCost();
      }
    } else {
      if (getItem()?.discount != null) {
        if (useWholeSalePrice) {
          return (((getItem()?.wholeSalePrice ?? 0) -
                  ((getItem()?.wholeSalePrice ?? 0) *
                      (getItem()?.discount ?? 0) /
                      100)) *
              quantity);
        } else {
          return (((getItem()?.sellingPrice ?? 0) -
                  ((getItem()?.sellingPrice ?? 0) *
                      (getItem()?.discount ?? 0) /
                      100)) *
              quantity);
        }
      } else {
        return totalCost();
      }
    }
  }

  double getItemDiscountedRemainingCostForAltScreen() {
    if (useGroupQuantity == true) {
      if (item.discount != null) {
        if (useWholeSalePrice) {
          return (((item.wholeSalePrice ?? 0) -
                  ((item.wholeSalePrice ?? 0) *
                      (item.discount ?? 0) /
                      100)) *
              (quantity * getQttyPerGroupForAltScreen()));
        } else {
          return (((item.sellingPrice ?? 0) -
                  ((item.sellingPrice ?? 0) *
                      (item.discount ?? 0) /
                      100)) *
              (quantity * getQttyPerGroupForAltScreen()));
        }
      } else {
        return totalCostForAltScreen();
      }
    } else {
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
        return totalCostForAltScreen();
      }
    }
  }

  double getQttyPerGroup() {
    return getItem()?.qttyPerGroup ?? 1;
  }

  double getQttyPerGroupForAltScreen() {
    return item.qttyPerGroup ?? 1;
  }

  double unitTogetQttyPerGroup() {
    return quantity / getQttyPerGroup();
  }

  double unitTogetQttyPerGroupForAltScreen() {
    return quantity / getQttyPerGroupForAltScreen();
  }

  double groupToUnitQuantity() {
    return quantity * getQttyPerGroup();
  }

  double groupToUnitQuantityForAltScreen() {
    return quantity * getQttyPerGroupForAltScreen();
  }

  double getRealQuantity() {
    if (useGroupQuantity == true) {
      return quantity * getQttyPerGroup();
    } else {
      return quantity;
    }
  }

  double getRealQuantityForAltScreen() {
    if (useGroupQuantity == true) {
      return quantity * getQttyPerGroupForAltScreen();
    } else {
      return quantity;
    }
  }

  String getUnit() {
    if (useGroupQuantity == true) {
      if (getItem()?.groupUnit == 'Others' ||
          getItem()?.groupUnit == null) {
        return "Group(s)";
      } else {
        return getItem()?.groupUnit ?? 'Group(s)';
      }
    } else {
      if (getItem()?.unit == 'Others') {
        return "Unit(s)";
      } else {
        return getItem()?.unit ?? 'Unit(s)';
      }
    }
  }

  String getUnitForAltScreen() {
    if (useGroupQuantity == true) {
      if (item.groupUnit == 'Others' ||
          item.groupUnit == null) {
        return "Group(s)";
      } else {
        return item.groupUnit ?? 'Group(s)';
      }
    } else {
      if (item.unit == 'Others') {
        return "Unit(s)";
      } else {
        return item.unit;
      }
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
    double? qttyPerGroup,
    bool? isVoid,
    String? itemUuid,
    String? uuid,
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
    );
  }

  // double profitOrLoss() {
  //   return item.costPrice == 0
  //       ? 0
  //       : totalCost() - (costPrice() ?? 0);
  // }
}
