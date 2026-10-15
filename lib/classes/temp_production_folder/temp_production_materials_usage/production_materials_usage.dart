import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/production_unit_snapshot.dart';

part 'production_materials_usage.g.dart';

@HiveType(typeId: 121)
class ProductionMaterialsUsage extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  int shopId;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String materialUuid;

  @HiveField(4)
  String materialName;

  @HiveField(5)
  bool? isGroup;

  @HiveField(6)
  double? qttyPerGroup;

  @HiveField(7)
  double? totalCost;

  @HiveField(8)
  DateTime? createdAt;

  @HiveField(9)
  String? staffUuid;

  @HiveField(10)
  String? staffName;

  @HiveField(11)
  String? departmentUuid;

  @HiveField(12)
  String? departmentName;

  @HiveField(14)
  String? unit;

  @HiveField(15)
  double? customCost;

  @HiveField(16)
  DateTime? updatedAt;

  @HiveField(17)
  double? originalCostPerItem;

  @HiveField(18)
  String? customUnit;

  @HiveField(19)
  bool? originalUseGroupQuantity;

  @HiveField(20)
  String? groupUnit;

  @HiveField(21)
  int? selectedCostInt;

  @HiveField(22)
  bool? isManaged;

  @HiveField(23)
  String? unitUuid;

  @HiveField(24)
  List<ProductUnitsClass>? unitsList;

  @HiveField(25)
  String? productionRecordUuid;

  ProductionMaterialsUsage({
    required this.uuid,
    required this.shopId,
    required this.quantity,
    required this.materialName,
    required this.materialUuid,
    required this.isGroup,
    this.qttyPerGroup,
    required this.totalCost,
    required this.createdAt,
    required this.departmentName,
    required this.departmentUuid,
    required this.staffName,
    required this.staffUuid,
    required this.unit,
    required this.customCost,
    required this.updatedAt,
    required this.customUnit,
    required this.groupUnit,
    required this.originalCostPerItem,
    required this.originalUseGroupQuantity,
    required this.selectedCostInt,
    required this.isManaged,
    this.unitUuid,
    this.unitsList,
    this.productionRecordUuid,
  });

  factory ProductionMaterialsUsage.fromJson(Map<String, dynamic> json) {
    return ProductionMaterialsUsage(
      uuid: json['uuid'],
      quantity: (json['quantity'] as num).toDouble(),
      shopId: json['shop_id'] as int,
      materialName: json['material_name'] as String,
      materialUuid: json['material_uuid'] as String,
      isGroup: json['is_group'],
      qttyPerGroup: (json['qtty_per_group'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      staffName: json['staff_name'] as String?,
      staffUuid: json['staff_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      unit: json['unit'] as String?,
      customCost: (json['custom_cost'] as num?)?.toDouble(),
      customUnit: json['custom_unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      originalCostPerItem: (json['original_cost_per_item'] as num?)?.toDouble(),
      originalUseGroupQuantity: json['original_use_group_quantity'] as bool?,
      selectedCostInt: json['selected_cost_int'] as int?,
      isManaged: json['is_managed'] as bool?,
      unitUuid: json['unit_uuid'] as String?,
      unitsList:
          (json['units_list'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ProductUnitsClass.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      productionRecordUuid: json['production_record_uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'shop_id': shopId,
      'quantity': quantity,
      'material_name': materialName,
      'material_uuid': materialUuid,
      'is_group': isGroup,
      'qtty_per_group': qttyPerGroup,
      'total_cost': totalCost,
      'created_at': createdAt?.toIso8601String(),
      'staff_name': staffName,
      'staff_uuid': staffUuid,
      'department_name': departmentName,
      'department_uuid': departmentUuid,
      'unit': unit,
      'custom_cost': customCost,
      'updated_at': updatedAt?.toIso8601String(),
      'custom_unit': customUnit,
      'group_unit': groupUnit,
      'original_use_group_quantity': originalUseGroupQuantity,
      'original_cost_per_item': originalCostPerItem,
      'selected_cost_int': selectedCostInt,
      'is_managed': isManaged,
      'unit_uuid': unitUuid,
      'units_list': unitsList?.map((item) => item.toJson()).toList(),
      'production_record_uuid': productionRecordUuid,
    };
  }

  ProductionMaterialsUsage copyWith({
    String? uuid,
    double? quantity,
    int? shopId,
    String? materialName,
    String? materialUuid,
    bool? isGroup,
    double? qttyPerGroup,
    double? totalCost,
    DateTime? createdAt,
    String? staffName,
    String? staffUuid,
    String? departmentName,
    String? departmentUuid,
    String? unit,
    double? customCost,
    DateTime? updatedAt,
    String? customUnit,
    String? groupUnit,
    double? originalCostPerItem,
    bool? originalUseGroupQuantity,
    int? selectedCostInt,
    bool? isManaged,
    String? unitUuid,
    List<ProductUnitsClass>? unitsList,
    String? productionRecordUuid,
  }) {
    return ProductionMaterialsUsage(
      uuid: uuid ?? this.uuid,
      shopId: shopId ?? this.shopId,
      isGroup: isGroup ?? this.isGroup,
      materialName: materialName ?? this.materialName,
      materialUuid: materialUuid ?? this.materialUuid,
      quantity: quantity ?? this.quantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
      staffName: staffName ?? this.staffName,
      staffUuid: staffUuid ?? this.staffUuid,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      unit: unit ?? this.unit,
      customCost: customCost ?? this.customCost,
      updatedAt: updatedAt ?? this.updatedAt,
      customUnit: customUnit ?? this.customUnit,
      groupUnit: groupUnit ?? this.groupUnit,
      originalCostPerItem: originalCostPerItem ?? this.originalCostPerItem,
      originalUseGroupQuantity:
          originalUseGroupQuantity ?? this.originalUseGroupQuantity,
      selectedCostInt: selectedCostInt ?? this.selectedCostInt,
      isManaged: isManaged ?? this.isManaged,
      unitUuid: unitUuid ?? this.unitUuid,
      unitsList: copyProductionUnitSnapshot(unitsList ?? this.unitsList),
      productionRecordUuid: productionRecordUuid ?? this.productionRecordUuid,
    );
  }

  double getQuantity() {
    return quantity *
        productionUnitConversion(
          unitUuid: unitUuid,
          unitsList: unitsList,
          useGroupQuantity: isGroup,
          qttyPerGroup: qttyPerGroup,
          groupUnitName: groupUnit,
        );
  }

  String getUnit() {
    if (customUnit != null) return customUnit!;
    return productionUnitName(
      unitUuid: unitUuid,
      unitsList: unitsList,
      useGroupQuantity: isGroup,
      unit: unit,
      groupUnit: groupUnit,
      qttyPerGroup: qttyPerGroup,
    );
  }

  double getTotalCost() {
    return customCost ?? (totalCost ?? 0);
  }
}
