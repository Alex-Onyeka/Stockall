import 'package:hive/hive.dart';

part 'expense_category.g.dart';

@HiveType(typeId: 155)
class ExpenseCategory extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  int shopId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? departmentUuid;

  @HiveField(4)
  String? departmentName;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  ExpenseCategory({
    required this.uuid,
    required this.shopId,
    required this.name,
    this.departmentUuid,
    this.departmentName,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      uuid: json['uuid'] as String,
      shopId: (json['shop_id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString()).toLocal()
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString()).toLocal()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'shop_id': shopId,
      'name': name,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }
}
