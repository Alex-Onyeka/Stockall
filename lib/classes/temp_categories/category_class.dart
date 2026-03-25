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

  CategoryClass({
    required this.name,
    required this.shopId,
    required this.uuid,
    this.createdAt,
    this.updatedAt,
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
    };
  }
}
