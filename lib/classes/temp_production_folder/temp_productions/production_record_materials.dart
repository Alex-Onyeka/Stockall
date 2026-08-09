import 'package:hive/hive.dart';

part 'production_record_materials.g.dart';

@HiveType(typeId: 99)
class ProductionRecordMaterials extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String? productionRecordId;

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

  @HiveField(13)
  String? productionRecordName;

  @HiveField(14)
  String? unit;

  @HiveField(15)
  double? customCost;

  ProductionRecordMaterials({
    required this.uuid,
    this.productionRecordId,
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
    required this.productionRecordName,
    required this.unit,
    required this.customCost,
  });

  factory ProductionRecordMaterials.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductionRecordMaterials(
      uuid: json['uuid'],
      productionRecordId:
          json['production_record_uuid'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      materialName: json['material_name'] as String,
      materialUuid: json['material_uuid'] as String,
      isGroup: json['is_group'],
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      staffName: json['staff_name'] as String?,
      staffUuid: json['staff_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      productionRecordName:
          json['production_record_name'] as String?,
      unit: json['unit'] as String?,
      customCost: (json['custom_cost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'production_record_id': productionRecordId,
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
      'production_record_name': productionRecordName,
      'unit': unit,
      'custom_cost': customCost,
    };
  }

  ProductionRecordMaterials copyWith({
    String? uuid,
    String? productionRecordId,
    double? quantity,
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
    String? productionRecordName,
    String? unit,
    double? customCost,
  }) {
    return ProductionRecordMaterials(
      uuid: uuid ?? this.uuid,
      productionRecordId:
          productionRecordId ?? this.productionRecordId,
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
      productionRecordName:
          productionRecordName ?? this.productionRecordName,
      unit: unit ?? this.unit,
      customCost: customCost ?? this.customCost,
    );
  }

  double getTotalCost() {
    return customCost ?? ((totalCost ?? 0) * quantity);
  }
}
