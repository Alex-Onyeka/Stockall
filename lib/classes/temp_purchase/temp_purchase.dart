import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/main.dart';

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

  @HiveField(9)
  bool isCustomPriceSet;

  @HiveField(10)
  List<PurchasePayments> purchasePayments;

  @HiveField(11)
  String? supplierName;

  @HiveField(12)
  DateTime? updatedAt;

  // Lines bought on this purchase, also written to
  // item_purchase_records. Null or empty on purchases saved before
  // this field existed.
  @HiveField(13)
  List<TempItemPurchaseRecord>? items;

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
    required this.supplierName,
    required this.isCustomPriceSet,
    required this.purchasePayments,
    required this.updatedAt,
    this.items,
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
      supplierId: json['supplier_id'] as String?,
      supplierName: json['supplier_name'] as String?,
      isCustomPriceSet: json['is_custom_price_set'] as bool,
      purchasePayments:
          (json['payments'] as List<dynamic>? ?? [])
              .map(
                (e) => PurchasePayments.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      items: TempItemPurchaseRecord.itemsFromJson(
        json['items'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'department_id': departmentUuid,
      'department_name': departmentName,
      'uuid': uuid,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'total': total,
      'is_custom_price_set': isCustomPriceSet,
      'payments':
          purchasePayments.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt?.toIso8601String(),
      // Left out when empty so an upsert never clears stored items.
      if (items?.isNotEmpty == true)
        'items': TempItemPurchaseRecord.itemsToJson(items!),
    };
  }

  TempPurchase copyWith({
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    String? staffName,
    String? departmentName,
    String? departmentUuid,
    String? uuid,
    double? total,
    String? supplierId,
    String? supplierName,
    bool? isCustomPriceSet,
    List<PurchasePayments>? purchasePayments,
    DateTime? updatedAt,
    List<TempItemPurchaseRecord>? items,
  }) {
    return TempPurchase(
      createdAt: createdAt ?? this.createdAt,
      isCustomPriceSet:
          isCustomPriceSet ?? this.isCustomPriceSet,
      purchasePayments:
          purchasePayments ?? this.purchasePayments,
      shopId: shopId ?? this.shopId,
      supplierName: supplierName ?? this.supplierName,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      supplierId: supplierId ?? this.supplierId,
      total: total ?? this.total,
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  List<TempItemPurchaseRecord> getItems({
    BuildContext? context,
  }) {
    if (items == null || items!.isEmpty) {
      return returnPurchaseProvider(context: context)
          .getItemPurchaseReceipts
          .where((item) => item.purchaseId == uuid)
          .toList();
    } else {
      return items ?? [];
    }
  }
}
