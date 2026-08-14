import 'package:hive/hive.dart';

part 'productions_cart_item.g.dart';

@HiveType(typeId: 118)
class ProductionsCartItem extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  String? itemUuid;

  @HiveField(2)
  String name;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double? costPrice;

  @HiveField(5)
  double? customPrice;

  @HiveField(6)
  bool setCustomPrice;

  @HiveField(7)
  bool addToStock;

  @HiveField(8)
  bool? useGroupQuantity;

  @HiveField(9)
  String? unit;

  @HiveField(10)
  String? groupUnit;

  @HiveField(11)
  double? qttyPerGroup;

  @HiveField(12)
  double? originalCostPerItem;

  @HiveField(13)
  bool? originalUseGroupQuantity;

  ProductionsCartItem({
    required this.uuid,
    required this.itemUuid,
    required this.name,
    required this.quantity,
    this.customPrice,
    this.setCustomPrice = false,
    required this.addToStock,
    required this.useGroupQuantity,
    this.costPrice,
    this.groupUnit,
    this.qttyPerGroup,
    this.unit,
    required this.originalCostPerItem,
    required this.originalUseGroupQuantity,
  });

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'item_uuid': itemUuid,
    'name': name,
    'quantity': quantity,
    'custom_price': customPrice,
    'set_custom_price': setCustomPrice,
    'add_to_stock': addToStock,
    'sell_group': useGroupQuantity,
    'unit': unit,
    'qtty_per_group': qttyPerGroup,
    'group_unit': groupUnit,
    'cost_price': costPrice,
    'original_cost_per_item': originalCostPerItem,
    'original_use_group_quantity': originalUseGroupQuantity,
  };

  factory ProductionsCartItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductionsCartItem(
      uuid: json['uuid'],
      itemUuid: json['item_uuid'],
      name: json['name'],
      costPrice: json['cost_price'],
      groupUnit: json['group_unit'],
      qttyPerGroup: json['qtty_per_group'],
      unit: json['unit'],
      quantity: json['quantity'],
      customPrice: json['custom_price'],
      setCustomPrice: json['set_custom_price'],
      addToStock: json['add_to_stock'],
      useGroupQuantity: json['sell_group'],
      originalCostPerItem: json['original_cost_per)_item'],
      originalUseGroupQuantity:
          json['original_use_group_quantity'],
    );
  }

  double getCostPrice() {
    if (setCustomPrice) {
      return (customPrice ?? 0);
    } else {
      return (costPrice ?? 0) * getRealQuantity();
    }
  }

  // double getConvertedCostPriceForCartItem() {
  //   if (setCustomPrice) {
  //     return (customPrice ?? 0);
  //   } else {
  //     return (costPrice ?? 0) *
  //         getConvertedQuantityForCartItem();
  //   }
  // }

  double getQttyPerGroup() {
    return qttyPerGroup ?? 1;
  }

  // double getConvertedQuantityForCartItem() {
  //   if (useGroupQuantity == true) {
  //     return quantity / getQttyPerGroup();
  //   } else {
  //     return quantity;
  //   }
  // }

  double groupToUnitQuantity() {
    return quantity * getQttyPerGroup();
  }

  double getRealQuantity() {
    if (useGroupQuantity == true) {
      return quantity * getQttyPerGroup();
    } else {
      return quantity;
    }
  }

  double getRealQuantityForSales({
    required double qtty,
    required bool useGroup,
  }) {
    if (useGroup == true) {
      return (qtty) * (qttyPerGroup ?? 1);
    } else {
      return qtty;
    }
  }

  double getRealCostForSales({
    required double qtty,
    required bool useGroup,
  }) {
    return (originalCostPerItem ?? 0) *
        getRealQuantityForSales(
          qtty: qtty,
          useGroup: useGroup,
        );
  }

  String getUnit() {
    if (useGroupQuantity == true) {
      if (groupUnit == 'Others' || groupUnit == null) {
        return "Group(s)";
      } else {
        return groupUnit ?? 'Group(s)';
      }
    } else {
      if (unit == 'Others') {
        return "Unit(s)";
      } else {
        return unit ?? 'Unit(s)';
      }
    }
  }

  String getUnitForSales({required bool? useGroup}) {
    if (useGroup == true) {
      if (groupUnit == 'Others' || groupUnit == null) {
        return "Group(s)";
      } else {
        return groupUnit ?? 'Group(s)';
      }
    } else {
      if (unit == 'Others') {
        return "Unit(s)";
      } else {
        return unit ?? 'Unit(s)';
      }
    }
  }

  ProductionsCartItem copyWith({
    double? quantity,
    double? customPrice,
    bool? setCustomPrice,
    bool? addToStock,
    double? qttyPerGroup,
    String? itemUuid,
    String? uuid,
    bool? useGroupQuantity,
    String? name,
    double? costPrice,
    String? groupUnit,
    String? unit,
    double? originalCostPerItem,
    bool? originalUseGroupQuantity,
  }) {
    return ProductionsCartItem(
      uuid: uuid ?? this.uuid,
      itemUuid: itemUuid ?? this.itemUuid,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      setCustomPrice: setCustomPrice ?? this.setCustomPrice,
      addToStock: addToStock ?? this.addToStock,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      costPrice: costPrice ?? this.costPrice,
      groupUnit: groupUnit ?? this.groupUnit,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      unit: unit ?? this.unit,
      originalCostPerItem:
          originalCostPerItem ?? this.originalCostPerItem,
      originalUseGroupQuantity:
          originalUseGroupQuantity ??
          this.originalUseGroupQuantity,
    );
  }
}
