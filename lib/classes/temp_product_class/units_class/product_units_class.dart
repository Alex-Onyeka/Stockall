import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

part 'product_units_class.g.dart';

@HiveType(typeId: 139)
class ProductUnitsClass extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  String? staffName;

  @HiveField(3)
  String? staffUuid;

  @HiveField(4)
  double conversion;

  @HiveField(5)
  String name;

  @HiveField(6)
  bool isPrimary;

  @HiveField(7)
  String productUuid;

  @HiveField(8)
  int? dimensionType;

  ProductUnitsClass({
    required this.uuid,
    required this.staffUuid,
    required this.createdAt,
    required this.staffName,
    required this.conversion,
    required this.name,
    required this.isPrimary,
    required this.productUuid,
    this.dimensionType,
  });

  factory ProductUnitsClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductUnitsClass(
      uuid: json['uuid'] as String,
      createdAt: DateTime.parse(json['created_at']),
      staffName: json['staff_name'] as String?,
      staffUuid: json['staff_uuid'] as String?,
      conversion: (json['conversion'] as num).toDouble(),
      name: json['name'] as String,
      isPrimary: json['is_primary'] as bool,
      productUuid: json['product_uuid'] as String,
      dimensionType: json['dimension_type'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toIso8601String(),
      'staff_name': staffName,
      'staff_uuid': staffUuid,
      'uuid': uuid,
      'conversion': conversion,
      'name': name,
      'is_primary': isPrimary,
      'product_uuid': productUuid,
      'dimension_type': dimensionType,
    };
  }

  ProductUnitsClass copyWith({
    String? uuid,
    String? staffUuid,
    String? staffName,
    DateTime? createdAt,
    double? conversion,
    String? name,
    bool? isPrimary,
    String? productUuid,
    int? dimensionType,
  }) {
    return ProductUnitsClass(
      uuid: uuid ?? this.uuid,
      staffUuid: staffUuid ?? this.staffUuid,
      createdAt: createdAt ?? this.createdAt,
      staffName: staffName ?? this.staffName,
      conversion: conversion ?? this.conversion,
      name: name ?? this.name,
      isPrimary: isPrimary ?? this.isPrimary,
      productUuid: productUuid ?? this.productUuid,
      dimensionType: dimensionType ?? this.dimensionType,
    );
  }

  static const int areaUnit = 1;
  static const int sheetUnit = 2;

  static bool isAreaUnitName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final lower = name.trim().toLowerCase();
    return lower.contains('²') ||
        lower.contains('^2') ||
        lower.contains('mÂ²') ||
        lower.contains('m2') ||
        lower.contains('cm2') ||
        lower.contains('mm2') ||
        lower.contains('km2') ||
        lower.contains('square') ||
        lower.contains('sqm') ||
        lower.contains('sq.m') ||
        lower.contains('sqft') ||
        lower.contains('sq.ft') ||
        lower.contains('sqin') ||
        lower.contains('sq.in') ||
        lower.contains('sqyd') ||
        lower.contains('sq.yd') ||
        lower == 'area' ||
        lower.startsWith('area ');
  }

  bool get isAreaUnit {
    if (dimensionType == areaUnit) return true;
    if (dimensionType == sheetUnit) return false;
    return isAreaUnitName(name);
  }

  static List<ProductUnitsClass> getUnitList({
    required String? productUuid,
    required List<ProductUnitsClass>? tempUnitList,
    int? dimensionType,
  }) {
    if (tempUnitList == null ||
        tempUnitList.isEmpty == true) {
      ProductUnitsClass value = ProductUnitsClass(
        uuid: uuidGen(),
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: 1,
        name: 'Unit(s)',
        isPrimary: true,
        productUuid: productUuid ?? '',
        dimensionType: dimensionType,
      );
      return [value];
    } else {
      return tempUnitList;
    }
  }

  String getUnitName() {
    return name.toUpperCase();
  }

  // Single / multiple units mode. The mode is not stored:
  // an item with more than one unit is in multiple mode.
  static bool hasMultiple(List<ProductUnitsClass>? units) {
    return (units?.length ?? 0) > 1;
  }

  static ProductUnitsClass? primaryOf(
    List<ProductUnitsClass>? units,
  ) {
    if (units == null || units.isEmpty) {
      return null;
    }
    var items = units.where((item) => item.isPrimary);
    return items.isNotEmpty ? items.first : units.first;
  }

  // Renames the primary unit (same uuid) and keeps the other
  // units, so single mode never adds a second unit.
  static List<ProductUnitsClass> withPrimaryName({
    required List<ProductUnitsClass> units,
    required String name,
    int? dimensionType,
    required ProductUnitsClass Function() newUnit,
  }) {
    var primary = primaryOf(units);
    if (primary == null) {
      return [
        newUnit().copyWith(
          name: name,
          isPrimary: true,
          dimensionType:
              dimensionType ??
              (isAreaUnitName(name) ? areaUnit : null),
        ),
      ];
    }
    return units.map((item) {
      if (item.uuid == primary.uuid) {
        return item.copyWith(
          name: name,
          isPrimary: true,
          dimensionType:
              dimensionType ??
              (isAreaUnitName(name)
                  ? areaUnit
                  : item.dimensionType),
        );
      } else {
        return item.copyWith();
      }
    }).toList();
  }

  // Keeps only the primary unit (same uuid, conversion and
  // dimension type), for single unit mode.
  static List<ProductUnitsClass> singleUnitList(
    List<ProductUnitsClass> units,
  ) {
    var primary = primaryOf(units);
    if (primary == null) {
      return [];
    }
    return [primary.copyWith(isPrimary: true)];
  }

  double getQuantityEquivDivided({
    BuildContext? context,
    double? newQuantity,
    required int index,
    OrderItems? orderItem,
    double? quantityTwo,
    TempProductClass? product,
    MaterialClass? material,
  }) {
    List items() {
      if (index == 1) {
        return returnData(context: context, listen: false)
            .productListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else if (index == 2) {
        return returnProductionItemsProvider(
              context: context,
              listen: false,
            ).productionItemListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else if (index == 3) {
        return returnMaterialsProvider(
              context: context,
              listen: false,
            ).materialListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else if (index == 4) {
        return returnStorageProductProvider(
              context: context,
              listen: false,
            ).storageProductListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else {
        return returnData(context: context, listen: false)
            .productListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      }
    }

    if (product?.quantityType == 2) {
      if (!isAreaUnit && !product!.hasDimensions) {
        return 0;
      }
      final productArea = product!.dimensionArea();
      final areaPerUnit =
          isAreaUnit
              ? conversion
              : conversion * productArea;
      if (!areaPerUnit.isFinite || areaPerUnit <= 0) {
        return 0;
      }
      return (newQuantity ??
              product.getActualQuantity() ??
              0) /
          areaPerUnit;
    }

    if (product != null) {
      return (newQuantity ??
              product.getActualQuantity() ??
              0) /
          conversion;
    } else if (material != null) {
      return (newQuantity ?? material.quantity ?? 0) /
          conversion;
    } else if (orderItem != null) {
      if (orderItem.quantityType == 2 &&
          !isAreaUnit &&
          !orderItem.hasDimensions) {
        return 0;
      }
      final areaPerUnit =
          (orderItem.quantityType == 2 && !isAreaUnit)
              ? conversion * orderItem.dimensionArea()
              : conversion;
      return (newQuantity ?? orderItem.quantity) /
          areaPerUnit;
    } else if (quantityTwo != null) {
      return (newQuantity ?? quantityTwo) / conversion;
    } else {
      if (items().isNotEmpty) {
        var item = items().first;
        try {
          if (item?.quantityType == 2) {
            if (!isAreaUnit && !item!.hasDimensions) {
              return 0;
            }
            final productArea = item!.dimensionArea();
            final areaPerUnit =
                isAreaUnit
                    ? conversion
                    : conversion * productArea;
            if (!areaPerUnit.isFinite || areaPerUnit <= 0) {
              return 0;
            }
            return (newQuantity ??
                    item.getActualQuantity() ??
                    0) /
                areaPerUnit;
          } else {
            return (newQuantity ?? item.quantity ?? 0) /
                conversion;
          }
        } catch (e) {
          return (newQuantity ?? item.quantity ?? 0) /
              conversion;
        }
      } else {
        return 0;
      }
    }
  }

  double getQuantityEquivMultiplied({
    BuildContext? context,
    double? newQuantity,
    OrderItems? orderItem,
    double? quantityTwo,
    required int index,
    TempProductClass? product,
    double? customWidth,
    double? customHeight,
  }) {
    if (product?.quantityType == 2) {
      if (newQuantity == null) {
        return product!.getActualQuantity() ?? 0;
      }
      if (customWidth != null && customHeight != null) {
        final conv =
            (product!.dimensionUnitConversion != null &&
                    product.dimensionUnitConversion! > 0)
                ? product.dimensionUnitConversion!
                : 1.0;
        return newQuantity *
            conversion *
            ((customWidth * customHeight) / conv);
      }
      if (isAreaUnit) {
        return newQuantity * conversion;
      }
      if (!isAreaUnit) {
        if (!product!.hasDimensions) {
          return newQuantity * conversion;
        }
        final width = product.widthDimension!;
        final height = product.heightDimension!;
        final conv =
            (product.dimensionUnitConversion != null &&
                    product.dimensionUnitConversion! > 0)
                ? product.dimensionUnitConversion!
                : 1.0;
        return newQuantity *
            conversion *
            ((width * height) / conv);
      }
      return newQuantity * conversion;
    }

    List items() {
      if (index == 1) {
        return returnData(context: context, listen: false)
            .productListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else if (index == 2) {
        return returnProductionItemsProvider(
              context: context,
              listen: false,
            ).productionItemListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else if (index == 3) {
        return returnMaterialsProvider(
              context: context,
              listen: false,
            ).materialListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else if (index == 4) {
        return returnStorageProductProvider(
              context: context,
              listen: false,
            ).storageProductListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      } else {
        return returnData(context: context, listen: false)
            .productListMain
            .where((item) => item.uuid == productUuid)
            .toList();
      }
    }

    if (product != null) {
      return (newQuantity ??
              product.getActualQuantity() ??
              0) *
          conversion;
    } else if (orderItem != null) {
      if (orderItem.quantityType == 2 && !isAreaUnit) {
        return (newQuantity ?? orderItem.quantity) *
            conversion *
            orderItem.dimensionArea();
      }
      return (newQuantity ?? orderItem.quantity) *
          conversion;
    } else if (quantityTwo != null) {
      return (newQuantity ?? quantityTwo) * conversion;
    } else {
      if (items().isNotEmpty) {
        var item = items().first;
        try {
          // return (newQuantity ??
          //         item.getActualQuantity() ??
          //         0) *
          //     conversion;
          if (item?.quantityType == 2) {
            if (newQuantity == null) {
              return item!.getActualQuantity() ?? 0;
            }
            if (customWidth != null &&
                customHeight != null) {
              final conv =
                  (item!.dimensionUnitConversion != null &&
                          item.dimensionUnitConversion! > 0)
                      ? item.dimensionUnitConversion!
                      : 1.0;
              return newQuantity *
                  conversion *
                  ((customWidth * customHeight) / conv);
            }
            if (isAreaUnit) {
              return newQuantity * conversion;
            }
            if (!isAreaUnit) {
              if (item != null && !item.hasDimensions) {
                return newQuantity * conversion;
              }
              final width =
                  customWidth ?? item!.widthDimension ?? 1;
              final height =
                  customHeight ??
                  item!.heightDimension ??
                  1;
              final conv =
                  (item!.dimensionUnitConversion != null &&
                          item.dimensionUnitConversion! > 0)
                      ? item.dimensionUnitConversion!
                      : 1.0;
              return newQuantity *
                  conversion *
                  ((width * height) / conv);
            }
            return newQuantity * conversion;
          } else {
            return (newQuantity ?? item.quantity ?? 0) *
                conversion;
          }
        } catch (e) {
          return (newQuantity ?? item.quantity ?? 0) *
              conversion;
        }
      } else {
        return 0;
      }
    }
  }
}
