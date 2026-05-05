import 'package:hive/hive.dart';

part 'suppliers_class.g.dart';

@HiveType(typeId: 79)
class SuppliersClass extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? country;

  @HiveField(4)
  String name;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? phone;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? city;

  @HiveField(9)
  String? state;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  String? departmentId;

  @HiveField(12)
  DateTime? updatedAt;

  SuppliersClass({
    this.country,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    required this.createdAt,
    required this.shopId,
    this.departmentName,
    this.departmentId,
    this.uuid,
    this.updatedAt,
  });

  factory SuppliersClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return SuppliersClass(
      uuid: json['uuid'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      shopId: json['shop_id'] as int,
      country: json['country'] as String?,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'country': country,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'department_id': departmentId,
      'department_name': departmentName,
      'uuid': uuid,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
