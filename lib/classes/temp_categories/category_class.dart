import 'package:hive/hive.dart';

part 'category_class.g.dart';

@HiveType(typeId: 61)
class CategoryClass extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String name;

  @HiveField(4)
  DateTime? updatedAt;

  @HiveField(5)
  String? departmentId;

  @HiveField(6)
  String? departmentName;

  CategoryClass({
    required this.name,
    required this.shopId,
    required this.uuid,
    this.createdAt,
    this.updatedAt,
    required this.departmentId,
    required this.departmentName,
  });

  factory CategoryClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryClass(
      uuid: json['uuid'] as String,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'],
      name: json['name'],
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'uuid': uuid,
      'updated_at': updatedAt?.toIso8601String(),
      'department_id': departmentId,
      'department_name': departmentName,
    };
  }
}
