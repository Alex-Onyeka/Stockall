// class TempUserClass {
//   String? userId;
//   DateTime? createdAt;
//   String password;
//   String name;
//   String email;
//   String? phone;
//   String role;
//   String? authUserId;

//   TempUserClass({
//     this.userId,
//     this.createdAt,
//     required this.password,
//     required this.name,
//     required this.email,
//     this.phone,
//     required this.role,
//     this.authUserId,
//   });

//   factory TempUserClass.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return TempUserClass(
//       userId: json['user_id'] as String,
//       createdAt: DateTime.parse(json['created_at']),
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       role: json['role'] ?? '',
//       authUserId: json['auth_user_id'] ?? '',
//       password: json['password'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson({bool includeUserId = true}) {
//     final map = {
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'role': role,
//       'password': password,
//       'auth_user_id': authUserId,
//     };

//     if (includeUserId && userId != null) {
//       map['user_id'] = userId;
//     }
//     if (createdAt != null) {
//       map['created_at'] = createdAt!.toIso8601String();
//     }

//     return map;
//   }
// }

import 'package:hive/hive.dart';

part 'temp_user_class.g.dart'; // needed for code generation

@HiveType(typeId: 0)
class TempUserClass extends HiveObject {
  @HiveField(0)
  String? userId;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  String password;

  @HiveField(3)
  String name;

  @HiveField(4)
  String email;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  String role;

  @HiveField(7)
  String? authUserId;

  @HiveField(8)
  String? departmentName;

  @HiveField(9)
  int? departmentId;

  TempUserClass({
    this.userId,
    this.createdAt,
    required this.password,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.authUserId,
    this.departmentName,
    this.departmentId,
  });

  factory TempUserClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempUserClass(
      userId: json['user_id'],
      createdAt: DateTime.tryParse(
        json['created_at'] ?? '',
      ),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      authUserId: json['auth_user_id'],
      password: json['password'] ?? '',
      departmentId: json['department_id'],
      departmentName: json['department_name'],
    );
  }

  Map<String, dynamic> toJson({bool includeUserId = true}) {
    final map = {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
      'auth_user_id': authUserId,
      'department_id': departmentId,
      'department_name': departmentName,
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
