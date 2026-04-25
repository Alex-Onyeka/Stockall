import 'package:hive/hive.dart';

part 'temp_inventory_update_class.g.dart';

@HiveType(typeId: 52)
class TempInventoryUpdateClass {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String title;

  @HiveField(4)
  String? itemName;

  @HiveField(5)
  String? oldValue;

  @HiveField(6)
  String? newValue;

  @HiveField(7)
  String? staffName;

  @HiveField(8)
  String? staffId;

  @HiveField(9)
  String? departmentUuid;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  String? itemUuid;

  @HiveField(12)
  String? staffNameTwo;

  @HiveField(13)
  String? staffIdTwo;

  @HiveField(14)
  String? departmentUuidTwo;

  @HiveField(15)
  String? departmentNameTwo;

  @HiveField(16)
  String? itemTwoOldValue;

  @HiveField(17)
  String? itemTwoNewValue;

  @HiveField(18)
  String? itemTwoUuid;

  TempInventoryUpdateClass({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.title,
    this.itemName,
    this.departmentName,
    this.departmentUuid,
    this.staffId,
    this.staffName,
    this.newValue,
    this.oldValue,
    this.itemUuid,
    this.staffIdTwo,
    this.staffNameTwo,
    this.departmentNameTwo,
    this.departmentUuidTwo,
    this.itemTwoNewValue,
    this.itemTwoOldValue,
    required this.itemTwoUuid,
  });

  factory TempInventoryUpdateClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempInventoryUpdateClass(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      title: json['title'] as String,
      newValue: json['new_value'] as String?,
      itemName: json['item_name'] as String?,
      itemUuid: json['storage_product_id'] as String?,
      oldValue: json['old_value'] as String?,
      staffName: json['staff_name'] as String?,
      staffId: json['staff_id'] as String?,
      departmentName: json['department_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentNameTwo:
          json['department_name_two'] as String?,
      departmentUuidTwo:
          json['department_id_two'] as String?,
      staffNameTwo: json['staff_name_two'] as String?,
      staffIdTwo: json['staff_id_two'] as String?,
      itemTwoNewValue:
          json['item_two_new_value'] as String?,
      itemTwoOldValue:
          json['item_two_old_value'] as String?,
      itemTwoUuid: json['product_uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'old_value': oldValue,
      'new_value': newValue,
      'title': title,
      'item_name': itemName,
      'storage_product_id': itemUuid,
      'staff_name': staffName,
      'staff_id': staffId,
      'department_name': departmentName,
      'department_id': departmentUuid,
      'department_name_two': departmentNameTwo,
      'department_id_two': departmentUuidTwo,
      'staff_name_two': staffNameTwo,
      'staff_id_two': staffIdTwo,
      'item_two_old_value': itemTwoOldValue,
      'item_two_new_value': itemTwoNewValue,
      'product_uuid': itemTwoUuid,
    };
  }
}
