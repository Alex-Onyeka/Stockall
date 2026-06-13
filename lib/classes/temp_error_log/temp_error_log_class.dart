import 'package:hive/hive.dart';

part 'temp_error_log_class.g.dart';

@HiveType(typeId: 94)
class TempErrorLogClass {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  final int shopId;

  @HiveField(3)
  final String tableName;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String error;

  @HiveField(6)
  final String? message;

  @HiveField(7)
  final double? amount;

  @HiveField(8)
  final String? itemName;

  @HiveField(9)
  final String? staffName;

  @HiveField(10)
  String? departmentUuid;

  @HiveField(11)
  String? departmentName;

  TempErrorLogClass({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.tableName,
    required this.title,
    required this.error,
    this.message,
    this.amount,
    this.staffName,
    this.itemName,
    required this.departmentUuid,
    required this.departmentName,
  });

  factory TempErrorLogClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempErrorLogClass(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      tableName: json['table'] as String,
      title: json['title'] as String,
      error: json['error'] as String,
      message: json['message'] as String?,
      amount:
          json['amount'] != null
              ? (json['amount'] as num).toDouble()
              : null,
      staffName: json['staff_name'] as String?,
      itemName: json['item_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'table': tableName,
      'title': title,
      'error': error,
      'message': message,
      'amount': amount,
      'staff_name': staffName,
      'item_name': itemName,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
    };
  }
}
