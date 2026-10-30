import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

part 'production_item.g.dart';

@HiveType(typeId: 109)
class ProductionItem {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  String name;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  DateTime? createdAt;

  @HiveField(4)
  String? barcode;

  @HiveField(5)
  String unit;

  @HiveField(6)
  String? sizeType;

  @HiveField(7)
  double costPrice;

  @HiveField(8)
  double? quantity;

  @HiveField(9)
  String? departmentName;

  @HiveField(10)
  String? departmentUuid;

  @HiveField(11)
  DateTime? expiryDate;

  @HiveField(12)
  bool isManaged;

  @HiveField(13)
  DateTime? updatedAt;

  @HiveField(14)
  String? groupUnit;

  @HiveField(15)
  double? qttyPerGroup;

  @HiveField(16)
  String? categoryUuid;

  @HiveField(17)
  List<String>? categories;

  @HiveField(18)
  bool? useGroupUnit;

  @HiveField(19)
  List<ProductUnitsClass>? unitsList;

  ProductionItem({
    required this.name,
    this.barcode,
    this.quantity,
    required this.unit,
    this.sizeType,
    required this.costPrice,
    required this.shopId,
    this.createdAt,
    required this.departmentName,
    required this.departmentUuid,
    this.expiryDate,
    required this.isManaged,
    this.updatedAt,
    this.uuid,
    required this.groupUnit,
    required this.qttyPerGroup,
    this.categoryUuid,
    required this.categories,
    required this.useGroupUnit,
    required this.unitsList,
  });

  factory ProductionItem.fromJson(Map<String, dynamic> json) {
    return ProductionItem(
      name: json['name'] as String,
      shopId: json['shop_id'] as int,
      quantity: (json['quantity'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
      unit: json['unit'] as String,
      sizeType: json['size_type'] as String?,
      costPrice: (json['cost_price'] as num).toDouble(),
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.parse(json['expiry_date'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      isManaged: json['is_managed'] as bool,
      uuid: json['uuid'] as String?,
      groupUnit: json['group_unit'] as String?,
      qttyPerGroup: (json['qtty_per_group'] as num?)?.toDouble(),
      categoryUuid: json['category_uuid'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      useGroupUnit: json['use_group_unit'] as bool?,
      unitsList:
          (json['units_list'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    ProductUnitsClass.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson({required bool isIncludeQuantity}) {
    if (isIncludeQuantity) {
      return {
        'name': name,
        'shop_id': shopId,
        'barcode': barcode,
        'unit': unit,
        'size_type': sizeType,
        'cost_price': costPrice,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'quantity': quantity,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'is_managed': isManaged,
        'updated_at': updatedAt?.toIso8601String(),
        'uuid': uuid,
        'group_unit': groupUnit,
        'qtty_per_group': qttyPerGroup,
        'category_uuid': categoryUuid,
        'categories': categories ?? [],
        'use_group_unit': useGroupUnit,
        'units_list': ProductUnitsClass.getUnitList(
          tempUnitList: unitsList,
          productUuid: uuid,
        ),
      };
    } else {
      return {
        'name': name,
        'shop_id': shopId,
        'barcode': barcode,
        'unit': unit,
        'size_type': sizeType,
        'cost_price': costPrice,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'is_managed': isManaged,
        'updated_at': updatedAt?.toIso8601String(),
        'uuid': uuid,
        'group_unit': groupUnit,
        'qtty_per_group': qttyPerGroup,
        'category_uuid': categoryUuid,
        'categories': categories ?? [],
        'use_group_unit': useGroupUnit,
        'units_list': ProductUnitsClass.getUnitList(
          tempUnitList: unitsList,
          productUuid: uuid,
        ),
      };
    }
  }

  ProductionItem copyWith({
    String? name,
    int? shopId,
    DateTime? createdAt,
    String? barcode,
    String? unit,
    String? sizeType,
    double? costPrice,
    double? quantity,
    String? departmentName,
    String? departmentUuid,
    DateTime? expiryDate,
    DateTime? updatedAt,
    String? uuid,
    String? groupUnit,
    double? qttyPerGroup,
    String? categoryUuid,
    bool? isManaged,
    List<String>? categories,
    bool? useGroupUnit,
    List<ProductUnitsClass>? unitsList,
  }) {
    return ProductionItem(
      name: name ?? this.name,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      sizeType: sizeType ?? this.sizeType,
      costPrice: costPrice ?? this.costPrice,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      expiryDate: expiryDate ?? this.expiryDate,
      isManaged: isManaged ?? this.isManaged,
      updatedAt: updatedAt ?? this.updatedAt,
      uuid: uuid ?? this.uuid,
      groupUnit: groupUnit ?? this.groupUnit,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      quantity: quantity ?? this.quantity,
      categories: categories ?? this.categories,
      useGroupUnit: useGroupUnit ?? this.useGroupUnit,
      unitsList: unitsList ?? this.unitsList,
    );
  }

  void replaceWith({required ProductionItem newItem}) {
    name = newItem.name;
    shopId = newItem.shopId;
    createdAt = newItem.createdAt;
    barcode = newItem.barcode;
    unit = newItem.unit;
    sizeType = newItem.sizeType;
    costPrice = newItem.costPrice;
    departmentName = newItem.departmentName;
    departmentUuid = newItem.departmentUuid;
    expiryDate = newItem.expiryDate;
    isManaged = newItem.isManaged;
    updatedAt = newItem.updatedAt;
    uuid = newItem.uuid;
    groupUnit = newItem.groupUnit;
    qttyPerGroup = newItem.qttyPerGroup;
    categoryUuid = newItem.categoryUuid;
    quantity = newItem.quantity;
    categories = newItem.categories;
    useGroupUnit = newItem.useGroupUnit;
    unitsList = newItem.unitsList;
  }

  String getQuantityText({BuildContext? context, required int index}) {
    if (!authorization(authorized: Authorizations().viewItemQuantity)) {
      return '****';
    } else {
      if (quantity == null || quantity == 0) {
        return 'Stock Out';
      } else {
        return "${formatLargeNumberDouble(getPrimaryUnitQuantity(context: context, index: index))} ${cutLongText(getPrimaryUnit().name, 8)}";
      }
    }
  }

  double getPrimaryUnitQuantity({BuildContext? context, required int index}) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return (quantity ?? 0);
    } else {
      var items = unitsList!.where((item) => item.isPrimary);
      if (items.isEmpty) {
        return (quantity ?? 0);
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(index: index, context: context);
      }
    }
  }

  String getSelectedUnitForProductEdit(BuildContext context) {
    var selectedUnits = returnData(context: context, listen: false).tempUnitsList;
    if (selectedUnits.isEmpty) {
      return 'Unit Not Set';
    } else {
      return "${selectedUnits.firstWhere((item) => item.isPrimary).name} and (${selectedUnits.length - 1}) More";
    }
  }

  ProductUnitsClass getProductUnit({String? unitUuid}) {
    var items = unitsList?.where((item) => item.uuid == unitUuid) ?? [];
    if (unitUuid == null || items.isEmpty) {
      return getPrimaryUnit();
    } else {
      return getUnitsList().firstWhere((item) => item.uuid == unitUuid);
    }
  }

  ProductUnitsClass getPrimaryUnit() {
    if (getUnitsList().isEmpty == true ||
        getUnitsList().where((item) => item.isPrimary == true).isEmpty) {
      return ProductUnitsClass(
        uuid: uuidGen(),
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: 1,
        name: unit == 'Others' ? 'Unit(s)' : unit,
        isPrimary: true,
        productUuid: uuid!,
      );
    } else {
      return getUnitsList().where((item) => item.isPrimary == true).first;
    }
  }

  List<ProductUnitsClass> getUnitsList() {
    List<ProductUnitsClass> tempList() {
      if (unitsList == null || unitsList?.isEmpty == true) {
        List<ProductUnitsClass> tempList = [
          ProductUnitsClass(
            uuid: uuidGen(),
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: 1,
            name: unit == 'Others' ? 'Unit(s)' : unit,
            isPrimary: true,
            productUuid: uuid!,
          ),
        ];
        if (useGroupUnit == true) {
          ProductUnitsClass newItem = ProductUnitsClass(
            uuid: uuidGen(),
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: qttyPerGroup ?? 1,
            name:
                groupUnit == 'Others' || groupUnit == null
                    ? 'Group(s)'
                    : groupUnit ?? '',
            isPrimary: false,
            productUuid: uuid!,
          );
          tempList.add(newItem);
        }
        return tempList;
      } else {
        return unitsList ?? [];
      }
    }

    if (tempList().length < 2) {
      return tempList();
    } else {
      return [
        tempList().firstWhere((item) => item.isPrimary),
        ...tempList().where((item) => !item.isPrimary),
      ];
    }
  }

  double getRealQuantity() {
    if (useGroupUnit == true) {
      return (quantity ?? 0) * (qttyPerGroup ?? 1);
    } else {
      return quantity ?? 0;
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

  double getRealCost() {
    return costPrice * getRealQuantity();
  }

  double getRealCostForSales({required double qtty, required bool useGroup}) {
    return costPrice * getRealQuantityForSales(qtty: qtty, useGroup: useGroup);
  }

  String getUnitForSales({required bool useGroup}) {
    if (useGroup == true) {
      return groupUnit ?? 'Group(s)';
    } else {
      return unit == 'Others' ? 'Unit(s)' : unit;
    }
  }

  bool canUpdateQuantity() {
    if (authorization(authorized: Authorizations().updateProduct) &&
        authorization(authorized: Authorizations().updateItemQuantity)) {
      return true;
    } else {
      return false;
    }
  }
}
