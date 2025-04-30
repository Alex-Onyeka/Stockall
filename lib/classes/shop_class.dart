class ShopClass {
  final int shopId;
  final DateTime createdAt;
  final String userId;
  final String email;
  final String name;
  final String? state;
  final String? city;
  final String? shopAddress;
  final List<String>? categories;
  final String? industry;
  final List<Map<String, dynamic>>? units;
  final List<String>? colors;
  final List<String>? expenseType;
  final List<String>? staffs;

  ShopClass({
    required this.shopId,
    required this.createdAt,
    required this.userId,
    required this.email,
    required this.name,
    this.state,
    this.city,
    this.shopAddress,
    this.categories,
    this.industry,
    this.units,
    this.colors,
    this.expenseType,
    this.staffs,
  });

  factory ShopClass.fromJson(Map<String, dynamic> json) {
    return ShopClass(
      shopId: json['shop_id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      state: json['state'],
      city: json['city'],
      shopAddress: json['shop_address'],
      categories:
          (json['categories'] as List?)?.cast<String>(),
      industry: json['industry'],
      units:
          (json['units'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList(),
      colors: (json['colors'] as List?)?.cast<String>(),
      expenseType:
          (json['expense_type'] as List?)?.cast<String>(),
      staffs: (json['staffs'] as List?)?.cast<String>(),
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
      'shop_address': shopAddress,
      'categories': categories,
      'industry': industry,
      'units': units,
      'colors': colors,
      'expense_type': expenseType,
      'staffs': staffs,
    };
  }
}
