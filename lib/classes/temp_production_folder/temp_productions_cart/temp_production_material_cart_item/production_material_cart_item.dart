import 'package:hive/hive.dart';

part 'production_material_cart_item.g.dart';

@HiveType(typeId: 120)
class ProductionMaterialCartItem extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  String? materialItemUuid;

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
  String? customUnit;

  @HiveField(14)
  bool? originalUseGroupQuantity;

  @HiveField(15)
  String? productionItemName;

  @HiveField(16)
  String? productionItemId;

  @HiveField(17)
  bool? isManaged;

  ProductionMaterialCartItem({
    required this.uuid,
    required this.materialItemUuid,
    required this.name,
    required this.quantity,
    this.customPrice,
    this.setCustomPrice = true,
    required this.addToStock,
    required this.useGroupQuantity,
    this.costPrice,
    this.groupUnit,
    this.qttyPerGroup,
    this.unit,
    required this.originalCostPerItem,
    required this.customUnit,
    required this.originalUseGroupQuantity,
    required this.productionItemId,
    required this.productionItemName,
    required this.isManaged,
  });

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'material_item_uuid': materialItemUuid,
    'name': name,
    'quantity': quantity,
    'custom_price': customPrice,
    'set_custom_price': setCustomPrice,
    'add_to_stock': addToStock,
    'use_group': useGroupQuantity,
    'unit': unit,
    'qtty_per_group': qttyPerGroup,
    'group_unit': groupUnit,
    'cost_price': costPrice,
    'original_cost_per_item': originalCostPerItem,
    'custom_unit': customUnit,
    'original_use_group_quantity': originalUseGroupQuantity,
    'production_item_name': productionItemName,
    'production_item_uuid': productionItemId,
    'is_managed': isManaged,
  };

  factory ProductionMaterialCartItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductionMaterialCartItem(
      uuid: json['uuid'],
      materialItemUuid: json['materiel_item_uuid'],
      name: json['name'],
      costPrice: json['cost_price'],
      groupUnit: json['group_unit'],
      qttyPerGroup: json['qtty_per_group'],
      unit: json['unit'],
      quantity: json['quantity'],
      customPrice: json['custom_price'],
      setCustomPrice: json['set_custom_price'],
      addToStock: json['add_to_stock'],
      useGroupQuantity: json['use_group'],
      originalCostPerItem: json['original_cost_per_item'],
      customUnit: json['custom_unit'],
      originalUseGroupQuantity:
          json['original_use_group_quantity'],
      productionItemId: json['production_item_uuid'],
      productionItemName: json['production_item_name'],
      isManaged: json['is_managed'],
    );
  }

  double getCostPrice() {
    if (setCustomPrice) {
      return (customPrice ?? 0);
    } else {
      return (costPrice ?? 0) * getRealQuantity();
    }
  }

  double getQttyPerGroup() {
    return qttyPerGroup ?? 1;
  }

  double unitTogetQttyPerGroup() {
    return quantity / getQttyPerGroup();
  }

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

  String getUnit() {
    if (customUnit != null) {
      return customUnit ?? 'Unit(s)';
    } else {
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

  ProductionMaterialCartItem copyWith({
    double? quantity,
    double? customPrice,
    bool? setCustomPrice,
    bool? addToStock,
    double? qttyPerGroup,
    String? materialItemUuid,
    String? uuid,
    bool? useGroupQuantity,
    String? name,
    double? costPrice,
    String? groupUnit,
    String? unit,
    double? originalCostPerItem,
    String? customUnit,
    bool? originalUseGroupQuantity,
    String? productionItemName,
    String? productionItemId,
    bool? isManaged,
  }) {
    return ProductionMaterialCartItem(
      uuid: uuid ?? this.uuid,
      materialItemUuid:
          materialItemUuid ?? this.materialItemUuid,
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
      customUnit: customUnit ?? this.customUnit,
      originalUseGroupQuantity:
          originalUseGroupQuantity ??
          this.originalUseGroupQuantity,
      productionItemId:
          productionItemId ?? this.productionItemId,
      productionItemName:
          productionItemName ?? this.productionItemName,
      isManaged: isManaged ?? this.isManaged,
    );
  }
}
