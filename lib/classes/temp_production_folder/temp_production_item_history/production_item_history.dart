import 'package:hive/hive.dart';

part 'production_item_history.g.dart';

@HiveType(typeId: 114)
class ProductionItemHistory {
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
  String? itemUuid;

  @HiveField(6)
  String? newValue;

  @HiveField(7)
  String? oldValue;

  @HiveField(8)
  String? staffId;

  @HiveField(9)
  String? staffName;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  String? departmentUuid;

  @HiveField(12)
  double? quantityChange;

  @HiveField(13)
  String? desc;

  @HiveField(14)
  bool? isIncreased;

  ProductionItemHistory({
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
    required this.oldValue,
    this.itemUuid,
    this.quantityChange,
    required this.desc,
    required this.isIncreased,
  });

  factory ProductionItemHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductionItemHistory(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      title: json['title'] as String,
      newValue: json['new_value'] as String?,
      itemName: json['item_name'] as String?,
      itemUuid: json['item_uuid'] as String?,
      oldValue: json['old_value'] as String?,
      staffName: json['staff_name'] as String?,
      staffId: json['staff_id'] as String?,
      departmentName: json['department_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      quantityChange:
          (json["quantity_change"] as num?)?.toDouble(),
      desc: json['desc'] as String?,
      isIncreased: json['is_increased'] as bool,
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
      'item_uuid': itemUuid,
      'staff_name': staffName,
      'staff_id': staffId,
      'department_name': departmentName,
      'department_uuid': departmentUuid,
      'quantity_change': quantityChange,
      'desc': desc,
      'is_increased': isIncreased,
    };
  }
}
