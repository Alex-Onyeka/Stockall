import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/main.dart';

part 'temp_item_purchase_record.g.dart';

@HiveType(typeId: 77)
class TempItemPurchaseRecord {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? departmentId;

  @HiveField(4)
  String? itemId;

  @HiveField(5)
  String? staffId;

  @HiveField(6)
  String? supplierId;

  @HiveField(7)
  double? quantity;

  @HiveField(8)
  double? total;

  @HiveField(9)
  String? purchaseId;

  @HiveField(10)
  String? itemName;

  @HiveField(11)
  double? originalPrice;

  @HiveField(12)
  double? customPrice;

  @HiveField(13)
  String? storageItemId;

  @HiveField(14)
  bool? isGroup;

  @HiveField(15)
  double? qttyPerGroup;

  @HiveField(16)
  String? unit;

  @HiveField(17)
  List<ProductUnitsClass>? unitsList;

  @HiveField(18)
  String? unitUuid;

  TempItemPurchaseRecord({
    required this.createdAt,
    required this.shopId,
    required this.staffId,
    this.quantity,
    this.uuid,
    this.departmentId,
    this.itemId,
    this.supplierId,
    this.total,
    this.purchaseId,
    this.itemName,
    required this.originalPrice,
    required this.customPrice,
    required this.storageItemId,
    required this.isGroup,
    required this.qttyPerGroup,
    required this.unit,
    required this.unitsList,
    required this.unitUuid,
  });

  factory TempItemPurchaseRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempItemPurchaseRecord(
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      shopId: json['shop_id'] as int,
      staffId: json['staff_id'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      uuid: json['uuid'] as String?,
      departmentId: json['department_id'] as String?,
      itemId: json['item_id'] as String?,
      purchaseId: json['purchase_id'] as String?,
      supplierId: json['supplier_id'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      itemName: json['item_name'] as String?,
      originalPrice:
          (json['original_price'] as num?)?.toDouble(),
      customPrice:
          (json['custom_price'] as num?)?.toDouble(),
      storageItemId: json['storage_item_uuid'] as String?,
      isGroup: json['is_group'] as bool?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      unitsList:
          (json['units_list'] as List<dynamic>? ?? [])
              .map(
                (item) => ProductUnitsClass.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      unitUuid: json['unit_uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'uuid': uuid,
      'quantity': quantity,
      'department_id': departmentId,
      'item_id': itemId,
      'purchase_id': purchaseId,
      'supplier_id': supplierId,
      'total': total,
      'item_name': itemName,
      'original_price': originalPrice,
      'custom_price': customPrice,
      'storage_item_uuid': storageItemId,
      'is_group': isGroup,
      'qtty_per_group': qttyPerGroup,
      'unit': unit,
      'units_list': ProductUnitsClass.getUnitList(
        tempUnitList: unitsList,
        productUuid: itemId ?? storageItemId,
      ),
      'unit_uuid': unitUuid,
    };
  }

  // Lines stored in a purchase's `items` column. created_at is
  // written in UTC so the stored string keeps its offset.
  static List<Map<String, dynamic>> itemsToJson(
    List<TempItemPurchaseRecord> items,
  ) {
    return items
        .map(
          (item) => {
            ...item.toJson(),
            'created_at':
                item.createdAt.toUtc().toIso8601String(),
          },
        )
        .toList();
  }

  // Null when missing, empty or unreadable, so the purchase is treated
  // like one saved before items existed.
  static List<TempItemPurchaseRecord>? itemsFromJson(
    dynamic json,
  ) {
    if (json is! List || json.isEmpty) {
      return null;
    }
    try {
      return json.map((item) {
        final record = TempItemPurchaseRecord.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        record.createdAt = record.createdAt.toLocal();
        return record;
      }).toList();
    } catch (_) {
      return null;
    }
  }

  TempItemPurchaseRecord copy({
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    double? quantity,
    double? total,
    String? departmentId,
    String? uuid,
    String? purchaseId,
    String? supplierId,
    String? itemId,
    double? originalPrice,
    double? customPrice,
    String? storageItemId,
    String? itemName,
    bool? isGroup,
    double? qttyPerGroup,
    String? unit,
    List<ProductUnitsClass>? unitsList,
    String? unitUuid,
  }) {
    return TempItemPurchaseRecord(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      supplierId: supplierId ?? this.supplierId,
      itemId: itemId ?? this.itemId,
      purchaseId: purchaseId ?? this.purchaseId,
      departmentId: departmentId ?? this.departmentId,
      customPrice: customPrice ?? this.customPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      storageItemId: storageItemId ?? this.storageItemId,
      itemName: itemName ?? this.itemName,
      isGroup: isGroup ?? this.isGroup,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      unit: unit ?? this.unit,
      unitsList: unitsList ?? this.unitsList,
      unitUuid: unitUuid ?? this.unitUuid,
    );
  }

  List<ProductUnitsClass> getUnitListFinal() {
    return getUnitsList()
        .map((item) => item.copyWith())
        .toList();
  }

  double getSelectedUnitQuantity({BuildContext? context}) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return quantity ?? 0;
    } else {
      var items = unitsList!.where(
        (item) => item.uuid == unitUuid,
      );
      if (items.isEmpty) {
        return quantity ?? 0;
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: 1,
          context: context,
          newQuantity: quantity ?? 0,
        );
      }
    }
  }

  double getSelectedUnitQuantityMultiplied({
    BuildContext? context,
  }) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return quantity ?? 0;
    } else {
      var items = unitsList!.where(
        (item) => item.uuid == unitUuid,
      );
      if (items.isEmpty) {
        return quantity ?? 0;
      } else {
        var item = items.first;
        return item.getQuantityEquivMultiplied(
          index: 1,
          newQuantity: quantity ?? 0,
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
        itemId ?? storageItemId ?? uuid ?? '';
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
        itemId ?? storageItemId ?? uuid ?? '';
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
}
