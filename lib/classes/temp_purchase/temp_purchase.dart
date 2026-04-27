import 'package:hive/hive.dart';

part 'temp_purchase.g.dart';

@HiveType(typeId: 73)
class TempPurchase extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? staffId;

  @HiveField(4)
  String? staffName;

  @HiveField(5)
  String? supplierId;

  @HiveField(6)
  String? departmentUuid;

  @HiveField(7)
  String? departmentName;

  @HiveField(8)
  double? total;

  TempPurchase({
    required this.createdAt,
    required this.shopId,
    this.staffId,
    this.staffName,
    this.departmentName,
    this.departmentUuid,
    this.uuid,
    this.total,
    this.supplierId,
  });

  factory TempPurchase.fromJson(Map<String, dynamic> json) {
    return TempPurchase(
      createdAt:
          DateTime.parse(json['created_at']).toLocal(),
      shopId: json['shop_id'],
      staffId: json['staff_id'] as String?,
      staffName: json['staff_name'] as String?,
      departmentUuid: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      uuid: json['uuid'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      supplierId: json['supplier'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'department_id': departmentUuid,
      'department_name': departmentName,
      'uuid': uuid,
      'supplier_id': supplierId,
      'total': total,
    };
  }
}
