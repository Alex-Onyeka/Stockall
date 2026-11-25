import 'package:hive/hive.dart';

part 'storage_item_history.g.dart';

@HiveType(typeId: 143)
class StorageItemHistory {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String title;

  @HiveField(4)
  String? storageItemName;

  @HiveField(5)
  String? storageItemUuid;

  @HiveField(6)
  String? storageItemNewValue;

  @HiveField(7)
  String? storageItemOldValue;

  @HiveField(8)
  String? storageStaffId;

  @HiveField(9)
  String? storageStaffName;

  @HiveField(10)
  String? storageDepartmentName;

  @HiveField(11)
  String? storageDepartmentUuid;

  @HiveField(12)
  double? quantityChange;

  @HiveField(13)
  String? desc;

  @HiveField(14)
  bool? isIncreased;

  @HiveField(15)
  String? storageUnit;

  @HiveField(16)
  String? storagePrimaryUnit;

  @HiveField(17)
  String? salesStaffName;

  @HiveField(18)
  String? salesStaffUuid;

  @HiveField(19)
  String? salesDepartmentUuid;

  @HiveField(20)
  String? salesDepartmentName;

  @HiveField(21)
  String? salesItemOldValue;

  @HiveField(22)
  String? salesItemNewValue;

  @HiveField(23)
  String? salesItemUuid;

  @HiveField(24)
  String? salesUnit;

  @HiveField(25)
  String? salesPrimaryUnit;

  @HiveField(26)
  String? salesItemName;

  @HiveField(27)
  String? event;

  @HiveField(28)
  String? source;

  @HiveField(29)
  String? destination;

  @HiveField(30)
  String? supplierUuid;

  @HiveField(31)
  String? supplierName;

  @HiveField(32)
  String? trackingNumber;

  String? get supplier => supplierName;

  StorageItemHistory({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.title,
    this.storageItemName,
    this.storageDepartmentName,
    this.storageDepartmentUuid,
    this.storageStaffId,
    this.storageStaffName,
    required this.storageItemNewValue,
    required this.storageItemOldValue,
    this.storageItemUuid,
    required this.quantityChange,
    required this.desc,
    required this.isIncreased,
    this.storageUnit,
    this.storagePrimaryUnit,
    this.salesUnit,
    this.salesPrimaryUnit,
    this.salesStaffUuid,
    this.salesStaffName,
    this.salesDepartmentName,
    this.salesDepartmentUuid,
    this.salesItemNewValue,
    this.salesItemOldValue,
    this.salesItemUuid,
    this.salesItemName,
    required this.event,
    required this.source,
    this.destination,
    this.supplierUuid,
    this.supplierName,
    this.trackingNumber,
  });

  factory StorageItemHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return StorageItemHistory(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      title: json['title'] as String,
      storageItemNewValue:
          json['storage_item_new_value'] as String?,
      storageItemName: json['storage_item_name'] as String?,
      storageItemUuid: json['storage_item_uuid'] as String?,
      storageItemOldValue:
          json['storage_item_old_value'] as String?,
      storageStaffName:
          json['storage_staff_name'] as String?,
      storageStaffId:
          (json['storage_staff_uuid'] ??
                  json['storage_staff_id'])
              as String?,
      storageDepartmentName:
          json['storage_department_name'] as String?,
      storageDepartmentUuid:
          json['storage_department_uuid'] as String?,
      quantityChange:
          (json["quantity_change"] as num?)?.toDouble(),
      desc: json['desc'] as String?,
      isIncreased: json['is_increased'] as bool?,
      storageUnit: json['storage_unit'] as String?,
      storagePrimaryUnit:
          json['storage_primary_unit'] as String?,
      salesDepartmentName:
          json['sales_department_name'] as String?,
      salesDepartmentUuid:
          json['sales_department_uuid'] as String?,
      salesStaffName: json['sales_staff_name'] as String?,
      salesStaffUuid: json['sales_staff_uuid'] as String?,
      salesItemNewValue:
          json['sales_item_new_value'] as String?,
      salesItemOldValue:
          json['sales_item_old_value'] as String?,
      salesItemUuid: json['sales_item_uuid'] as String?,
      salesUnit: json['sales_unit'] as String?,
      salesPrimaryUnit:
          json['sales_primary_unit'] as String?,
      salesItemName: json['sales_item_name'] as String?,
      event: json['event'] as String?,
      source: json['source'] as String?,
      destination: json['destination'] as String?,
      supplierUuid: json['supplier_uuid'] as String?,
      supplierName: (json['supplier_name'] ?? json['supplier']) as String?,
      trackingNumber:
          (json['tracking_number'] ??
                  json['tracking_number'])
              as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'title': title,

      'storage_item_name': storageItemName,
      'storage_item_uuid': storageItemUuid,
      'storage_item_new_value': storageItemNewValue,
      'storage_item_old_value': storageItemOldValue,

      'storage_staff_id': storageStaffId,
      'storage_staff_name': storageStaffName,

      'storage_department_name': storageDepartmentName,
      'storage_department_uuid': storageDepartmentUuid,

      'quantity_change': quantityChange,
      'desc': desc,
      'is_increased': isIncreased,

      'storage_unit': storageUnit,
      'storage_primary_unit': storagePrimaryUnit,

      'sales_staff_name': salesStaffName,
      'sales_staff_uuid': salesStaffUuid,

      'sales_department_uuid': salesDepartmentUuid,
      'sales_department_name': salesDepartmentName,

      'sales_item_old_value': salesItemOldValue,
      'sales_item_new_value': salesItemNewValue,
      'sales_item_uuid': salesItemUuid,

      'sales_unit': salesUnit,
      'sales_primary_unit': salesPrimaryUnit,
      'sales_item_name': salesItemName,
      'event': event,
      'source': source,
      'destination': destination,
      'supplier_uuid': supplierUuid,
      'supplier_name': supplierName,
      'tracking_number': trackingNumber,
    };
  }

  StorageItemHistory copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? title,
    String? storageItemName,
    String? storageItemUuid,
    String? storageItemNewValue,
    String? storageItemOldValue,
    String? storageStaffId,
    String? storageStaffName,
    String? storageDepartmentName,
    String? storageDepartmentUuid,
    double? quantityChange,
    String? desc,
    bool? isIncreased,
    String? storageUnit,
    String? storagePrimaryUnit,
    String? salesStaffName,
    String? salesStaffUuid,
    String? salesDepartmentUuid,
    String? salesDepartmentName,
    String? salesItemOldValue,
    String? salesItemNewValue,
    String? salesItemUuid,
    String? salesUnit,
    String? salesPrimaryUnit,
    String? salesItemName,
    String? event,
    String? source,
    String? destination,
    String? supplierUuid,
    String? supplierName,
    String? trackingNumber,
  }) {
    return StorageItemHistory(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,

      storageItemName:
          storageItemName ?? this.storageItemName,
      storageItemUuid:
          storageItemUuid ?? this.storageItemUuid,
      storageItemNewValue:
          storageItemNewValue ?? this.storageItemNewValue,
      storageItemOldValue:
          storageItemOldValue ?? this.storageItemOldValue,

      storageStaffId: storageStaffId ?? this.storageStaffId,
      storageStaffName:
          storageStaffName ?? this.storageStaffName,

      storageDepartmentName:
          storageDepartmentName ??
          this.storageDepartmentName,
      storageDepartmentUuid:
          storageDepartmentUuid ??
          this.storageDepartmentUuid,

      quantityChange: quantityChange ?? this.quantityChange,
      desc: desc ?? this.desc,
      isIncreased: isIncreased ?? this.isIncreased,

      storageUnit: storageUnit ?? this.storageUnit,
      storagePrimaryUnit:
          storagePrimaryUnit ?? this.storagePrimaryUnit,

      salesStaffName: salesStaffName ?? this.salesStaffName,
      salesStaffUuid: salesStaffUuid ?? this.salesStaffUuid,

      salesDepartmentUuid:
          salesDepartmentUuid ?? this.salesDepartmentUuid,
      salesDepartmentName:
          salesDepartmentName ?? this.salesDepartmentName,

      salesItemOldValue:
          salesItemOldValue ?? this.salesItemOldValue,
      salesItemNewValue:
          salesItemNewValue ?? this.salesItemNewValue,
      salesItemUuid: salesItemUuid ?? this.salesItemUuid,

      salesUnit: salesUnit ?? this.salesUnit,
      salesPrimaryUnit:
          salesPrimaryUnit ?? this.salesPrimaryUnit,
      salesItemName: salesItemName ?? this.salesItemName,
      event: event ?? this.event,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      supplierUuid: supplierUuid ?? this.supplierUuid,
      supplierName: supplierName ?? this.supplierName,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }
}
