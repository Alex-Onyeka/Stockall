import 'package:hive/hive.dart';

part 'temp_user_class.g.dart';

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
  String? lastName;

  @HiveField(5)
  String email;

  @HiveField(6)
  String? phone;

  @HiveField(7)
  String role;

  @HiveField(8)
  String? authUserId;

  @HiveField(9)
  String? departmentName;

  @HiveField(10)
  String? departmentUuid;

  @HiveField(11)
  String? pin;

  @HiveField(12)
  List<String>? departmentUuids;

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
    this.departmentUuid,
    this.pin,
    this.departmentUuids,
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
      departmentUuid: json['department_uuid'],
      departmentName: json['department_name'],
      pin: json['pin'],
      departmentUuids:
          (json['department_uuids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
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
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'pin': pin,
      'department_uuids': departmentUuids,
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
