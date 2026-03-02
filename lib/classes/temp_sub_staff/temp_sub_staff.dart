import 'package:hive/hive.dart';

part 'temp_sub_staff.g.dart';

@HiveType(typeId: 56)
class TempSubStaff extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? staffName;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? departmentName;

  @HiveField(6)
  String? departmentUuid;

  @HiveField(7)
  DateTime? updatedAt;

  TempSubStaff({
    this.uuid,
    required this.phone,
    required this.createdAt,
    required this.shopId,
    this.staffName,
    this.departmentName,
    this.departmentUuid,
    this.updatedAt,
  });

  factory TempSubStaff.fromJson(Map<String, dynamic> json) {
    return TempSubStaff(
      uuid: json['uuid'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      shopId: json['shop_id'] as int,
      staffName: json['staff_name'] as String,
      phone: json['phone'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_name': staffName,
      'phone': phone,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'uuid': uuid,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
