class TempUserClass {
  String? userId;

  DateTime? createdAt;

  String password;

  String name;

  String? lastName;

  String email;

  String? phone;

  String role;

  String? authUserId;

  String? departmentName;

  int? departmentId;

  String? pin;

  TempUserClass({
    this.userId,
    this.createdAt,
    required this.password,
    required this.name,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.authUserId,
    this.departmentName,
    this.departmentId,
    this.pin,
  });

  factory TempUserClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempUserClass(
      userId: json['user_id'],
      createdAt: DateTime.tryParse(
        json['created_at'] ?? '',
      ),
      name: json['name'],
      lastName: json['last_name'] as String?,
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      authUserId: json['auth_user_id'],
      password: json['password'] ?? '',
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      pin: json['pin'],
    );
  }

  Map<String, dynamic> toJson({bool includeUserId = true}) {
    final map = {
      'name': name,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
      'auth_user_id': authUserId,
      'department_id': departmentId,
      'department_name': departmentName,
      'pin': pin,
    };

    if (includeUserId && userId != null) {
      map['user_id'] = userId;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }
}
