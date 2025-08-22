class TempShopClass {
  final int? shopId;
  final DateTime createdAt;
  final String userId;
  String email;
  String name;
  String? state;
  String? country;
  String? city;
  String? shopAddress;
  List<String>? categories;
  List<String>? colors;
  String? phoneNumber;
  String? activeEmployee;
  List<String>? employees;
  String? refCode;
  String currency;
  int? updateNumber;
  bool isVerified;
  int? printType;
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
      shopId: json['shop_id'],
      country: json['country'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      state: json['state'],
      city: json['city'],
      shopAddress: json['shop_address'],
      categories:
          (json['categories'] as List?)?.cast<String>(),
      colors: (json['colors'] as List?)?.cast<String>(),
      activeEmployee: json['active_employee'],
      phoneNumber: json['phone_number'],
      employees:
          (json['employees'] as List?)?.cast<String>(),
      refCode: json['ref_code'] as String?,
      currency: json['currency'],
      updateNumber: json['update_number'] as int?,
      isVerified: json['is_verified'] as bool,
      printType: json['print_type'] as int?,
      language: json['language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
