import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/functions/create_production_functions.dart';

part 'production_record.g.dart';

@HiveType(typeId: 100)
class ProductionRecord {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int? shopId;

  @HiveField(3)
  String? staffId;

  @HiveField(4)
  String? staffName;

  @HiveField(5)
  String? departmentId;

  @HiveField(6)
  String? departmentName;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  List<ProductionRecordMaterials> materials;

  @HiveField(9)
  double? quantity;

  @HiveField(10)
  String? itemName;

  @HiveField(11)
  String? itemUuid;

  // @HiveField(12)
  // bool? isGroup;

  @HiveField(13)
  double? qttyPerGroup;

  @HiveField(14)
  String? unit;

  @HiveField(15)
  double? totalCost;

  @HiveField(16)
  double? customCost;

  @HiveField(17)
  String? comment;

  @HiveField(18)
  int? selectedCostPriceOption;

  @HiveField(19)
  bool? useGroupQuantity;

  @HiveField(20)
  bool? originalUseGroupQuantity;

  @HiveField(21)
  double? originalCostPerItem;

  @HiveField(22)
  String? groupUnit;

  ProductionRecord({
    required this.uuid,
    required this.createdAt,
    required this.shopId,
    this.staffId,
    this.staffName,
    this.departmentId,
    this.departmentName,
    this.updatedAt,
    required this.materials,
    required this.itemName,
    required this.itemUuid,
    required this.quantity,
    required this.unit,
    required this.qttyPerGroup,
    required this.totalCost,
    required this.customCost,
    required this.comment,
    required this.selectedCostPriceOption,
    required this.originalCostPerItem,
    required this.originalUseGroupQuantity,
    required this.useGroupQuantity,
    required this.groupUnit,
  });

  /// FROM JSON
  factory ProductionRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductionRecord(
      uuid: json['uuid'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      staffId: json['staff_id'] as String?,
      staffName: json['staff_name'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      materials:
          (json['materials'] as List<dynamic>? ?? [])
              .map(
                (e) => ProductionRecordMaterials.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      itemName: json['item_name'] as String?,
      itemUuid: json['item_uuid'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      // isGroup: json['is_group'] as bool?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      customCost: (json['custom_cost'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      selectedCostPriceOption:
          json['selected_cost_price_option'] as int?,
      originalCostPerItem:
          (json['original_cost_per_item'] as num?)
              ?.toDouble(),
      originalUseGroupQuantity:
          json['original_use_group_quantity'] as bool?,
      useGroupQuantity: json['use_group_quantity'] as bool?,
      groupUnit: json['group_unit'] as String?,
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'department_id': departmentId,
      'department_name': departmentName,
      'updated_at': updatedAt?.toIso8601String(),
      'materials':
          materials.map((e) => e.toJson()).toList(),
      'item_uuid': itemUuid,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'qtty_per_group': qttyPerGroup,
      // 'is_group': isGroup,
      'total_cost': totalCost,
      'custom_cost': customCost,
      'comment': comment,
      'selected_cost_price_option': selectedCostPriceOption,
      'original_cost_per_item': originalCostPerItem,
      'original_use_group_quantity':
          originalUseGroupQuantity,
      'use_group_quantity': useGroupQuantity,
      'group_unit': groupUnit,
    };
  }

  factory ProductionRecord.fromCart({
    required ProductionsCart cartItem,
    required int shopIdd,
  }) {
    return ProductionRecord(
      uuid: cartItem.uuid,
      createdAt: cartItem.createdDate,
      shopId: shopIdd,
      materials:
          ProductionRecordMaterials.fromCartMaterialItem(
            items: cartItem.materialsCartItems,
          ),
      itemName:
          cartItem.productionsCartItem?.name ?? 'Not Set',
      itemUuid: cartItem.productionsCartItem?.itemUuid,
      quantity: cartItem.productionsCartItem?.quantity,
      unit: cartItem.productionsCartItem?.unit,
      qttyPerGroup:
          cartItem.productionsCartItem?.qttyPerGroup,
      totalCost: cartItem.getCostPrice(),
      customCost: cartItem.customPrice,
      comment: cartItem.comment,
      departmentId: currentDepartment()?.uuid,
      departmentName: currentDepartment()?.name,
      staffId: currentUser().userId,
      staffName: currentUser().name,
      selectedCostPriceOption:
          cartItem.selectCostPriceToUse,
      originalCostPerItem: cartItem.originalCostPerItem,
      originalUseGroupQuantity:
          cartItem.originalUseGroupQuantity,
      useGroupQuantity:
          cartItem.productionsCartItem?.useGroupQuantity,
      groupUnit: cartItem.productionsCartItem?.groupUnit,
    );
  }

  ProductionsCart toCart() {
    return ProductionsCart(
      productionsCartItem: ProductionsCartItem(
        uuid: uuid,
        itemUuid: itemUuid,
        name: itemName ?? 'Not Set',
        quantity: quantity ?? 0,
        addToStock: false,
        useGroupQuantity: useGroupQuantity ?? false,
        originalCostPerItem: originalCostPerItem,
        originalUseGroupQuantity:
            originalUseGroupQuantity ?? false,
      ),
      staffName: staffName,
      staffId: staffId,
      departmentName: departmentName,
      departmentUuid: departmentId,
      customDate: null,
      timeOfDay: null,
      comment: comment,
      materialsCartItems:
          ProductionRecordMaterials.toCartMaterialsItem(
            items: materials,
          ),
      createdDate: createdAt,
      customPrice: customCost,
      isEdit: true,
      productionUuidEdit: uuid,
      selectCostPriceToUse: selectedCostPriceOption ?? 1,
      uuid: uuid,
      originalCostPerItem: originalCostPerItem,
      originalUseGroupQuantity: originalUseGroupQuantity,
    );
  }

  /// COPY WITH
  ProductionRecord copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    String? staffName,
    String? departmentId,
    String? departmentName,
    DateTime? updatedAt,
    List<ProductionRecordMaterials>? materials,
    double? quantity,
    String? itemName,
    String? itemUuid,
    double? qttyPerGroup,
    String? unit,
    double? totalCost,
    double? customCost,
    String? comment,
    int? selectedCostPriceOption,
    double? originalCostPerItem,
    bool? originalUseGroupQuantity,
    bool? useGroupQuantity,
    String? groupUnit,
  }) {
    return ProductionRecord(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      updatedAt: updatedAt ?? this.updatedAt,
      materials: materials ?? this.materials,
      itemName: itemName ?? this.itemName,
      itemUuid: itemUuid ?? this.itemUuid,
      quantity: quantity ?? this.quantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      unit: unit ?? this.unit,
      totalCost: totalCost ?? this.totalCost,
      customCost: customCost ?? this.customCost,
      comment: comment ?? this.comment,
      selectedCostPriceOption:
          selectedCostPriceOption ??
          this.selectedCostPriceOption,
      originalCostPerItem:
          originalCostPerItem ?? this.originalCostPerItem,
      originalUseGroupQuantity:
          originalUseGroupQuantity ??
          this.originalUseGroupQuantity,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      groupUnit: groupUnit ?? this.groupUnit,
    );
  }

  double getTotalCost() {
    return customCost ?? ((totalCost ?? 0));
  }

  double getQuantity() {
    return quantityConversion(
      isGroup: useGroupQuantity ?? false,
      quantity: quantity ?? 0,
      qttyPerItem: qttyPerGroup,
    );
  }

  String getUnit() {
    if (useGroupQuantity == true) {
      return groupUnit == 'Others'
          ? 'Group(s)'
          : groupUnit ?? 'Group(s)';
    } else {
      return unit == 'Others'
          ? 'Unit(s)'
          : unit ?? 'Unit(s)';
    }
  }
}
