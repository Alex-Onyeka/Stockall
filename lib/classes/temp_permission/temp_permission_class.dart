import 'package:hive/hive.dart';

part 'temp_permission_class.g.dart';

@HiveType(typeId: 60)
class PermissionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final List<String> access;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int? permitNumber;

  PermissionModel({
    required this.id,
    required this.role,
    required this.access,
    required this.createdAt,
    this.permitNumber,
  });

  // ------------------------
  // FROM SUPABASE (JSON)
  // ------------------------
  factory PermissionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PermissionModel(
      id: json['id'],
      role: json['role'],
      access: List<String>.from(json['access'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      permitNumber: json['permit_number'] as int,
    );
  }

  // ------------------------
  // TO JSON (optional)
  // ------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'access': access,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
