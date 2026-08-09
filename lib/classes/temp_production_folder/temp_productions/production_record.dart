import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';

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

  @HiveField(12)
  bool? isGroup;

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
    required this.isGroup,
    required this.unit,
    required this.qttyPerGroup,
    required this.totalCost,
    required this.customCost,
    required this.comment,
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
      isGroup: json['is_group'] as bool?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      customCost: (json['custom_cost'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
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
      'is_group': isGroup,
      'total_cost': totalCost,
      'custom_cost': customCost,
      'comment': comment,
    };
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
    bool? isGroup,
    double? totalCost,
    double? customCost,
    String? comment,
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
      isGroup: isGroup ?? this.isGroup,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      unit: unit ?? this.unit,
      totalCost: totalCost ?? this.totalCost,
      customCost: customCost ?? this.customCost,
      comment: comment ?? this.comment,
    );
  }

  double getTotalCost() {
    return customCost ??
        ((totalCost ?? 0) * (quantity ?? 1));
  }
}
