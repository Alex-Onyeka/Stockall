import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/main.dart';

class PurchaseListItem {
  String itemName;
  String? itemUuid;
  String? storageItemUuid;
  double? totalPrice;
  double quantity;
  double? customPrice;
  double? originalPrice;
  bool isGroup;
  String? unit;
  double? qttyPerGroup;
  List<ProductUnitsClass>? unitsList;
  String? unitUuid;
  double? widthDimension;
  double? heightDimension;

  PurchaseListItem({
    required this.itemName,
    required this.itemUuid,
    required this.totalPrice,
    required this.quantity,
    required this.unit,
    required this.customPrice,
    required this.originalPrice,
    required this.storageItemUuid,
    required this.isGroup,
    required this.qttyPerGroup,
    required this.unitsList,
    required this.unitUuid,
    this.widthDimension,
    this.heightDimension,
  });

  PurchaseListItem copyWith({
    String? itemUuid,
    String? itemName,
    double? totalPrice,
    double? quantity,
    double? customPrice,
    double? originalPrice,
    String? storageItemUuid,
    bool? isGroup,
    double? qttyPerGroup,
    String? unit,
    List<ProductUnitsClass>? unitsList,
    String? unitUuid,
    double? widthDimension,
    double? heightDimension,
  }) {
    return PurchaseListItem(
      itemName: itemName ?? this.itemName,
      itemUuid: itemUuid ?? this.itemUuid,
      totalPrice: totalPrice ?? this.totalPrice,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      storageItemUuid:
          storageItemUuid ?? this.storageItemUuid,
      isGroup: isGroup ?? this.isGroup,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      unit: unit ?? this.unit,
      unitsList: unitsList ?? this.unitsList,
      unitUuid: unitUuid ?? this.unitUuid,
      widthDimension: widthDimension ?? this.widthDimension,
      heightDimension: heightDimension ?? this.heightDimension,
    );
  }

  List<ProductUnitsClass> getUnitListFinal() {
    return getUnitsList()
        .map((item) => item.copyWith())
        .toList();
  }

  double getSelectedUnitQuantity({BuildContext? context}) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return quantity;
    } else {
      var items = unitsList!.where(
        (item) => item.uuid == unitUuid,
      );
      if (items.isEmpty) {
        return quantity;
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: 1,
          context: context,
          newQuantity: quantity,
        );
      }
    }
  }

  double getSelectedUnitQuantityMultiplied({
    BuildContext? context,
  }) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return quantity;
    } else {
      var items = unitsList!.where(
        (item) => item.uuid == unitUuid,
      );
      if (items.isEmpty) {
        return quantity;
      } else {
        var item = items.first;
        return item.getQuantityEquivMultiplied(
          index: 1,
          newQuantity: quantity,
          context: context,
        );
      }
    }
  }

  ProductUnitsClass getSelectedUnit({String? unitUuidNew}) {
    final list = getUnitsList();
    final targetUnitUuid = unitUuidNew ?? unitUuid;
    if (targetUnitUuid != null) {
      final items = list.where(
        (item) => item.uuid == targetUnitUuid,
      );
      if (items.isNotEmpty) {
        return items.first;
      }
    }
    if (isGroup == true) {
      final groupItems = list.where(
        (item) => !item.isPrimary,
      );
      if (groupItems.isNotEmpty) {
        return groupItems.first;
      }
    }
    if (unit != null && unit!.isNotEmpty) {
      final byName = list.where(
        (item) =>
            item.name.toLowerCase() == unit!.toLowerCase(),
      );
      if (byName.isNotEmpty) {
        return byName.first;
      }
    }
    return getPrimaryUnit();
  }

  ProductUnitsClass getPrimaryUnit() {
    final targetProductUuid =
        itemUuid ?? storageItemUuid ?? '';
    final list = getUnitsList();
    final primaries = list.where(
      (item) => item.isPrimary == true,
    );
    if (list.isEmpty || primaries.isEmpty) {
      return ProductUnitsClass(
        uuid: '${targetProductUuid}_primary_unit',
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: 1,
        name:
            unit == 'Others'
                ? 'Unit(s)'
                : unit ?? 'Unit(s)',
        isPrimary: true,
        productUuid: targetProductUuid,
      );
    } else {
      return primaries.first;
    }
  }

  List<ProductUnitsClass> getUnitsList() {
    final targetProductUuid =
        itemUuid ?? storageItemUuid ?? '';
    List<ProductUnitsClass> buildList() {
      if (unitsList == null || unitsList?.isEmpty == true) {
        List<ProductUnitsClass> tempList = [
          ProductUnitsClass(
            uuid: '${targetProductUuid}_primary_unit',
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: 1,
            name:
                unit == 'Others'
                    ? 'Unit(s)'
                    : unit ?? 'Unit(s)',
            isPrimary: true,
            productUuid: targetProductUuid,
          ),
        ];
        if (isGroup == true) {
          var newItem = ProductUnitsClass(
            uuid: '${targetProductUuid}_group_unit',
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: qttyPerGroup ?? 1,
            name:
                unit == 'Others' || unit == null
                    ? 'Group(s)'
                    : unit!,
            isPrimary: false,
            productUuid: targetProductUuid,
          );
          tempList.add(newItem);
        }
        return tempList;
      } else {
        List<ProductUnitsClass> tempList = [
          ...(unitsList ?? []),
        ];
        if (isGroup == true &&
            (qttyPerGroup ?? 0) > 0 &&
            tempList.every((item) => item.isPrimary)) {
          tempList.add(
            ProductUnitsClass(
              uuid: '${targetProductUuid}_group_unit',
              staffUuid: currentUser().userId,
              createdAt: DateTime.now(),
              staffName: currentUser().name,
              conversion: qttyPerGroup ?? 1,
              name:
                  unit == 'Others' || unit == null
                      ? 'Group(s)'
                      : unit!,
              isPrimary: false,
              productUuid: targetProductUuid,
            ),
          );
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

  double getPrice() {
    // if (isGroup) {
    //   return (totalPrice ) * quantity;
    // } else {
    return totalPrice ?? 0;
    // }
  }
}
