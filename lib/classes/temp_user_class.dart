class TempUserClass {
  String? userId;
  DateTime? createdAt;
  String password;
  String name;
  String email;
  String? phone;
  String role;
  String? authUserId;

  TempUserClass({
    this.userId,
    this.createdAt,
    required this.password,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.authUserId,
  });

  factory TempUserClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempUserClass(
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      authUserId: json['auth_user_id'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
    };
  }
}
