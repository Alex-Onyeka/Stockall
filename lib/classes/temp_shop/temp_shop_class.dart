import 'package:hive/hive.dart';

part 'temp_shop_class.g.dart';

@HiveType(typeId: 7)
class TempShopClass {
  @HiveField(0)
  final int? shopId;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  String email;

  @HiveField(4)
  String name;

  @HiveField(5)
  String? state;

  @HiveField(6)
  String? country;

  @HiveField(7)
  String? city;

  @HiveField(8)
  String? shopAddress;

  @HiveField(9)
  List<String>? categories;

  @HiveField(10)
  List<String>? colors;

  @HiveField(11)
  String? phoneNumber;

  @HiveField(12)
  String? activeEmployee;

  @HiveField(13)
  List<String>? employees;

  @HiveField(14)
  String? refCode;

  @HiveField(15)
  String currency;

  @HiveField(16)
  int? updateNumber;

  @HiveField(17)
  bool isVerified;

  @HiveField(18)
  int? printType;

  @HiveField(19)
  String? language;

  TempShopClass({
    this.shopId,
    required this.createdAt,
    required this.userId,
    required this.email,
    required this.name,
    this.state,
    this.city,
    this.shopAddress,
    this.categories,
    this.colors,
    this.country,
    this.activeEmployee,
    this.phoneNumber,
    this.employees,
    this.refCode,
    required this.currency,
    this.updateNumber,
    required this.isVerified,
    this.printType,
    this.language,
  });

  factory TempShopClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempShopClass(
      shopId: json['shop_id'] as int?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      userId: json['user_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      state: json['state'] as String?,
      city: json['city'] as String?,
      shopAddress: json['shop_address'] as String?,
      categories:
          (json['categories'] as List?)?.cast<String>(),
      colors: (json['colors'] as List?)?.cast<String>(),
      activeEmployee: json['active_employee'] as String?,
      phoneNumber: json['phone_number'] as String?,
      employees:
          (json['employees'] as List?)?.cast<String>(),
      refCode: json['ref_code'] as String?,
      currency: json['currency'] as String,
      updateNumber: json['update_number'] as int?,
      isVerified: json['is_verified'] as bool,
      printType: json['print_type'] as int?,
      language: json['language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'email': email,
      'name': name,
      'state': state,
      'city': city,
      'country': country,
      'shop_address': shopAddress,
      'categories': categories,
      'colors': colors,
      'phone_number': phoneNumber,
      'employees': employees,
      'ref_code': refCode,
      'currency': currency,
      'update_number': updateNumber,
      'is_verified': isVerified,
      'print_type': printType,
      'language': language,
    };
  }
}
