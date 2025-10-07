import 'package:hive/hive.dart';

part 'temp_customers_class.g.dart';

@HiveType(typeId: 1)
class TempCustomersClass extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  DateTime dateAdded;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? country;

  @HiveField(4)
  String name;

  @HiveField(5)
  String email;

  @HiveField(6)
  String phone;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? city;

  @HiveField(9)
  String? state;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  int? departmentId;

  @HiveField(12)
  String? uuid;

  @HiveField(13)
  DateTime? updatedAt;

  TempCustomersClass({
    this.country,
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.dateAdded,
    required this.shopId,
    this.departmentName,
    this.departmentId,
    this.uuid,
    this.updatedAt,
  });

  factory TempCustomersClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempCustomersClass(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      dateAdded: DateTime.parse(json['date_added']),
      shopId: json['shop_id'] as int,
      country: json['country'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      departmentId: json['department_id'] as int?,
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
      'date_added': dateAdded.toIso8601String(),
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
