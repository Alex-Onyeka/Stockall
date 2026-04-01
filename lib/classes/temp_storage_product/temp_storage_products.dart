import 'package:hive/hive.dart';

part 'temp_storage_products.g.dart';

@HiveType(typeId: 66)
class TempStorageProducts {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  final int shopId;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String? desc;

  @HiveField(5)
  final double? quantity;

  @HiveField(6)
  final String? unit;

  @HiveField(7)
  final String? groupUnit;

  @HiveField(8)
  DateTime? updatedAt;

  TempStorageProducts({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.name,
    this.desc,
    this.quantity,
    this.unit,
    this.groupUnit,
    this.updatedAt,
  });

  factory TempStorageProducts.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempStorageProducts(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String?,
      quantity: json['quantity'] as double?,
      unit: json['unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': desc,
      'quantity': quantity,
      'unit': unit,
      'group_unit': groupUnit,
      'updated_at': updatedAt,
    };
  }
}
