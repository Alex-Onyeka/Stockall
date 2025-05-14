class TempUserClass {
  String? userId;
  DateTime? createdAt;
  String name;
  String email;
  String phone;
  String role;

  TempUserClass({
    this.userId,
    this.createdAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory TempUserClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempUserClass(
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': createdAt!.toIso8601String(),
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
