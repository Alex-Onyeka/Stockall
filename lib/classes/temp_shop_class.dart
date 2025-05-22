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
  String? activeEmployee;

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
    };
  }
}
