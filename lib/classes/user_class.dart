class UserClass {
  final String userId;
  final DateTime createdAt;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? image;
  final int shopId;

  UserClass({
    required this.userId,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.image,
    required this.shopId,
  });

  factory UserClass.fromJson(Map<String, dynamic> json) {
    return UserClass(
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      image: json['image'],
      shopId: json['shop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'image': image,
      'shop_id': shopId,
    };
  }
}
