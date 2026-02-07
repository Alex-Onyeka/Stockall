import 'package:hive/hive.dart';

part 'department_class.g.dart';

@HiveType(typeId: 39)
class DepartmentClass {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime? updatedAt;

  @HiveField(3)
  int shopId;

  @HiveField(4)
  String name;

  @HiveField(5)
  String? description;

  DepartmentClass({
    required this.uuid,
    required this.createdAt,
    this.updatedAt,
    required this.shopId,
    required this.name,
    this.description,
  });

  /// Factory to create from JSON (Supabase row)
  factory DepartmentClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return DepartmentClass(
      uuid: json['uuid'] as String,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      shopId: json['shop_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': description,
    };
  }
}
