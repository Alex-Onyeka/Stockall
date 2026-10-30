import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

part 'temp_storage_products.g.dart';

@HiveType(typeId: 66)
class TempStorageProducts {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String name;

  @HiveField(4)
  String? desc;

  @HiveField(5)
  double? quantity;

  @HiveField(6)
  String? unit;

  @HiveField(7)
  String? groupUnit;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9)
  double? qttyPerGroup;

  @HiveField(10)
  double? costPrice;

  @HiveField(11)
  double? sellingPrice;

  @HiveField(12)
  bool? useGroupUnit;

  @HiveField(13)
  List<ProductUnitsClass>? unitsList;

  // 2D items, as on sales items: 1 or null = 1D, 2 = 2D. For 2D
  // items quantity is a sheet count of width × height.
  @HiveField(14)
  int? quantityType;

  @HiveField(15)
  double? widthDimension;

  @HiveField(16)
  double? heightDimension;

  @HiveField(17)
  String? dimensionUnit;

  @HiveField(18)
  double? dimensionUnitConversion;

  TempStorageProducts({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.name,
    this.desc,
    this.quantity,
    this.unit,
    this.groupUnit,
    this.updatedAt,
    this.qttyPerGroup,
    required this.costPrice,
    required this.sellingPrice,
    required this.useGroupUnit,
    required this.unitsList,
    this.quantityType = 1,
    this.widthDimension,
    this.heightDimension,
    this.dimensionUnit,
    this.dimensionUnitConversion,
  });

  factory TempStorageProducts.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempStorageProducts(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String?,
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      unit: json['single_unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      qttyPerGroup:
          json['qtty_per_group'] != null
              ? (json['qtty_per_group'] as num).toDouble()
              : null,
      costPrice:
          json['cost_price'] != null
              ? (json['cost_price'] as num).toDouble()
              : null,
      sellingPrice:
          json['selling_price'] != null
              ? (json['selling_price'] as num).toDouble()
              : null,
      useGroupUnit: json['use_group_unit'] as bool?,
      unitsList:
          (json['units_list'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    item is ProductUnitsClass
                        ? item
                        : ProductUnitsClass.fromJson(
                          item as Map<String, dynamic>,
                        ),
              )
              .toList(),
      quantityType: json['quantity_type'] as int? ?? 1,
      widthDimension:
          (json['width_dimension'] as num?)?.toDouble(),
      heightDimension:
          (json['height_dimension'] as num?)?.toDouble(),
      dimensionUnit: json['dimension_unit'] as String?,
      dimensionUnitConversion:
          (json['dimension_unit_conversion'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': desc,
      'quantity': quantity,
      'single_unit': unit,
      'group_unit': groupUnit,
      'updated_at': updatedAt?.toIso8601String(),
      'qtty_per_group': qttyPerGroup,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'use_group_unit': useGroupUnit,
      'units_list': ProductUnitsClass.getUnitList(
        tempUnitList: unitsList,
        productUuid: uuid,
        dimensionType:
            quantityType == 2
                ? (ProductUnitsClass.isAreaUnitName(unit)
                    ? ProductUnitsClass.areaUnit
                    : ProductUnitsClass.sheetUnit)
                : null,
      ),
      'quantity_type': quantityType ?? 1,
      'width_dimension': widthDimension,
      'height_dimension': heightDimension,
      'dimension_unit': dimensionUnit,
      'dimension_unit_conversion': dimensionUnitConversion,
    };
  }

  TempStorageProducts copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? name,
    String? desc,
    double? quantity,
    String? unit,
    String? groupUnit,
    DateTime? updatedAt,
    double? qttyPerGroup,
    double? costPrice,
    double? sellingPrice,
    bool? useGroupUnit,
    List<ProductUnitsClass>? unitsList,
    int? quantityType,
    double? widthDimension,
    double? heightDimension,
    String? dimensionUnit,
    double? dimensionUnitConversion,
  }) {
    return TempStorageProducts(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      groupUnit: groupUnit ?? this.groupUnit,
      updatedAt: updatedAt ?? this.updatedAt,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      useGroupUnit: useGroupUnit ?? this.useGroupUnit,
      unitsList: unitsList ?? this.unitsList,
      quantityType: quantityType ?? this.quantityType,
      widthDimension: widthDimension ?? this.widthDimension,
      heightDimension:
          heightDimension ?? this.heightDimension,
      dimensionUnit: dimensionUnit ?? this.dimensionUnit,
      dimensionUnitConversion:
          dimensionUnitConversion ?? this.dimensionUnitConversion,
    );
  }

  void replaceWith({required TempStorageProducts newItem}) {
    name = newItem.name;
    shopId = newItem.shopId;
    createdAt = newItem.createdAt;
    unit = newItem.unit;
    desc = newItem.desc;
    costPrice = newItem.costPrice;
    sellingPrice = newItem.sellingPrice;
    updatedAt = newItem.updatedAt;
    uuid = newItem.uuid;
    groupUnit = newItem.groupUnit;
    qttyPerGroup = newItem.qttyPerGroup;
    quantity = newItem.quantity;
    useGroupUnit = newItem.useGroupUnit;
    unitsList = newItem.unitsList;
    quantityType = newItem.quantityType;
    widthDimension = newItem.widthDimension;
    heightDimension = newItem.heightDimension;
    dimensionUnit = newItem.dimensionUnit;
    dimensionUnitConversion = newItem.dimensionUnitConversion;
  }

  //
  //
  // 2D, mirroring TempProductClass (same names: the unit
  // conversions with index 4 call these on storage items).

  bool isDimensional() => quantityType == 2;

  double? getActualQuantity() {
    if (quantityType == 2) {
      return (quantity ?? 0) * dimensionArea();
    } else {
      return quantity;
    }
  }

  bool get hasDimensions =>
      (widthDimension != null && widthDimension! > 0) &&
      (heightDimension != null && heightDimension! > 0);

  // Area of one stock unit (sheet) for 2D items, 1 otherwise.
  // Converts area back to the stored sheet count.
  double dimensionArea() {
    if (quantityType == 2) {
      if (!hasDimensions) return 1.0;
      final area =
          (widthDimension ?? 1) * (heightDimension ?? 1);
      final conv = (dimensionUnitConversion != null &&
              dimensionUnitConversion! > 0)
          ? dimensionUnitConversion!
          : 1.0;
      final converted = area / conv;
      return converted > 0 ? converted : 1;
    } else {
      return 1;
    }
  }

  // Stored quantity left after removing [removedQuantity]
  // (in getActualQuantity units, i.e. area for 2D items).
  double quantityAfterRemoving(double removedQuantity) {
    return ((getActualQuantity() ?? 0) - removedQuantity) /
        dimensionArea();
  }

  // [quantity] of [unit] in getActualQuantity units: area for
  // 2D items (area units as they are, sheet units × sheet area).
  double actualFromUnit(
    ProductUnitsClass unit,
    double quantity, {
    double? customWidth,
    double? customHeight,
  }) {
    if (quantityType == 2 && !unit.isAreaUnit) {
      if (customWidth != null && customHeight != null) {
        final conv = (dimensionUnitConversion != null &&
                dimensionUnitConversion! > 0)
            ? dimensionUnitConversion!
            : 1.0;
        return quantity * unit.conversion * ((customWidth * customHeight) / conv);
      }
      return quantity * unit.conversion * dimensionArea();
    }
    return quantity * unit.conversion;
  }

  // getActualQuantity units back to [unit].
  double unitFromActual(
    ProductUnitsClass unit,
    double actual,
  ) {
    final perUnit = actualFromUnit(unit, 1);
    if (!perUnit.isFinite || perUnit <= 0) {
      return 0;
    }
    return actual / perUnit;
  }

  List<ProductUnitsClass> getUnitListFinal() {
    return getUnitsList()
        .map((item) => item.copyWith())
        .toList();
  }

  String getQuantityText({
    BuildContext? context,
    required int index,
  }) {
    if (!authorization(
      authorized: Authorizations().viewItemQuantity,
    )) {
      return '****';
    } else {
      if (quantity == null || quantity == 0) {
        return 'Stock Out';
      } else {
        return formatLargeNumberDouble(
          getPrimaryUnitQuantity(
            context: context,
            index: index,
          ),
        );
      }
    }
  }

  double getPrimaryUnitQuantity({
    BuildContext? context,
    required int index,
  }) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return (quantity ?? 0);
    } else {
      var items = unitsList!.where(
        (item) => item.isPrimary,
      );
      if (items.isEmpty) {
        return (quantity ?? 0);
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: index,
          context: context,
        );
      }
    }
  }

  String getSelectedUnitForProductEdit(
    BuildContext context,
  ) {
    var selectedUnits =
        returnData(context: context).tempUnitsList;
    if (selectedUnits.isEmpty) {
      return 'Unit Not Set';
    } else {
      return "${selectedUnits.firstWhere((item) => item.isPrimary).name} and (${selectedUnits.length - 1}) More";
    }
  }

  ProductUnitsClass getProductUnit({String? unitUuid}) {
    var items =
        unitsList?.where((item) => item.uuid == unitUuid) ??
        [];
    if (unitUuid == null || items.isEmpty) {
      return getPrimaryUnit();
    } else {
      return getUnitsList().firstWhere(
        (item) => item.uuid == unitUuid,
      );
    }
  }

  ProductUnitsClass getPrimaryUnit() {
    final list = getUnitsList();
    final primaries = list.where(
      (item) => item.isPrimary == true,
    );
    if (list.isEmpty || primaries.isEmpty) {
      return ProductUnitsClass(
        uuid: '${uuid ?? ''}_primary_unit',
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: 1,
        name:
            unit == 'Others'
                ? 'Unit(s)'
                : unit ?? 'Unit(s)',
        isPrimary: true,
        productUuid: uuid ?? '',
        dimensionType:
            quantityType == 2
                ? (ProductUnitsClass.isAreaUnitName(unit)
                    ? ProductUnitsClass.areaUnit
                    : ProductUnitsClass.sheetUnit)
                : null,
      );
    } else {
      return primaries.first;
    }
  }

  List<ProductUnitsClass> getUnitsList() {
    String? safeStaffUuid() {
      try {
        return currentUser().userId;
      } catch (_) {
        return null;
      }
    }

    String? safeStaffName() {
      try {
        return currentUser().name;
      } catch (_) {
        return null;
      }
    }

    List<ProductUnitsClass> buildList() {
      if (unitsList == null || unitsList?.isEmpty == true) {
        final isArea =
            quantityType == 2 && ProductUnitsClass.isAreaUnitName(unit);
        List<ProductUnitsClass> tempList = [
          ProductUnitsClass(
            uuid: '${uuid ?? ''}_primary_unit',
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: 1,
            name:
                unit == 'Others'
                    ? 'Unit(s)'
                    : unit ?? 'Unit(s)',
            isPrimary: true,
            productUuid: uuid ?? '',
            dimensionType:
                quantityType == 2
                    ? (isArea
                        ? ProductUnitsClass.areaUnit
                        : ProductUnitsClass.sheetUnit)
                    : null,
          ),
        ];
        if (useGroupUnit == true &&
            (qttyPerGroup ?? 0) > 0) {
          ProductUnitsClass newItem = ProductUnitsClass(
            uuid: '${uuid ?? ''}_group_unit',
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: qttyPerGroup ?? 1,
            name:
                groupUnit == 'Others' || groupUnit == null
                    ? 'Group(s)'
                    : groupUnit ?? '',
            isPrimary: false,
            productUuid: uuid ?? '',
          );
          tempList.add(newItem);
        }
        if (quantityType == 2) {
          final hasArea = tempList.any((u) => u.isAreaUnit);
          final hasWhole = tempList.any((u) => !u.isAreaUnit);
          if (hasArea && !hasWhole) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_sheet_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Sheet',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.sheetUnit,
              ),
            );
          } else if (hasWhole && !hasArea) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_area_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Square Meter',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.areaUnit,
              ),
            );
          }
        }
        return tempList;
      } else {
        List<ProductUnitsClass> tempList = [
          ...(unitsList ?? []),
        ];
        if (useGroupUnit == true &&
            (qttyPerGroup ?? 0) > 0 &&
            tempList.every((item) => item.isPrimary)) {
          tempList.add(
            ProductUnitsClass(
              uuid: '${uuid ?? ''}_group_unit',
              staffUuid: currentUser().userId,
              createdAt: DateTime.now(),
              staffName: currentUser().name,
              conversion: qttyPerGroup ?? 1,
              name:
                  groupUnit == 'Others' || groupUnit == null
                      ? 'Group(s)'
                      : groupUnit ?? '',
              isPrimary: false,
              productUuid: uuid ?? '',
            ),
          );
        }
        if (quantityType == 2) {
          final hasArea = tempList.any((u) => u.isAreaUnit);
          final hasWhole = tempList.any((u) => !u.isAreaUnit);
          if (hasArea && !hasWhole) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_sheet_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Sheet',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.sheetUnit,
              ),
            );
          } else if (hasWhole && !hasArea) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_area_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Square Meter',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.areaUnit,
              ),
            );
          }
        }
        return tempList;
      }
    }

    final resolved = buildList();
    if (resolved.length < 2) {
      return resolved;
    } else {
      final primaries = resolved.where(
        (item) => item.isPrimary,
      );
      return [
        if (primaries.isNotEmpty) primaries.first,
        ...resolved.where((item) => !item.isPrimary),
      ];
    }
  }
}
