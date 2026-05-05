import 'package:hive/hive.dart';

part 'temp_item_purchase_record.g.dart';

@HiveType(typeId: 77)
class TempItemPurchaseRecord {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? departmentId;

  @HiveField(4)
  String? itemId;

  @HiveField(5)
  String? staffId;

  @HiveField(6)
  String? supplierId;

  @HiveField(7)
  double? quantity;

  @HiveField(8)
  double? total;

  @HiveField(9)
  String? purchaseId;

  @HiveField(10)
  String? itemName;

  @HiveField(11)
  double? originalPrice;

  @HiveField(12)
  double? customPrice;

  @HiveField(13)
  String? storageItemId;

  @HiveField(14)
  bool? isGroup;

  @HiveField(15)
  double? qttyPerGroup;

  TempItemPurchaseRecord({
    required this.createdAt,
    required this.shopId,
    required this.staffId,
    this.quantity,
    this.uuid,
    this.departmentId,
    this.itemId,
    this.supplierId,
    this.total,
    this.purchaseId,
    this.itemName,
    required this.originalPrice,
    required this.customPrice,
    required this.storageItemId,
    required this.isGroup,
    required this.qttyPerGroup,
  });

  factory TempItemPurchaseRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempItemPurchaseRecord(
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      shopId: json['shop_id'] as int,
      staffId: json['staff_id'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      uuid: json['uuid'] as String?,
      departmentId: json['department_id'] as String?,
      itemId: json['item_id'] as String?,
      purchaseId: json['purchase_id'] as String?,
      supplierId: json['supplier_id'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      itemName: json['item_name'] as String?,
      originalPrice:
          (json['original_price'] as num?)?.toDouble(),
      customPrice:
          (json['custom_price'] as num?)?.toDouble(),
      storageItemId: json['storage_item_uuid'] as String?,
      isGroup: json['is_group'] as bool?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'uuid': uuid,
      'quantity': quantity,
      'department_id': departmentId,
      'item_id': itemId,
      'purchase_id': purchaseId,
      'supplier_id': supplierId,
      'total': total,
      'item_name': itemName,
      'original_price': originalPrice,
      'custom_price': customPrice,
      'storage_item_uuid': storageItemId,
      'is_group': isGroup,
      'qtty_per_group': qttyPerGroup,
    };
  }

  TempItemPurchaseRecord copy({
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    double? quantity,
    double? total,
    String? departmentId,
    String? uuid,
    String? purchaseId,
    String? supplierId,
    String? itemId,
    double? originalPrice,
    double? customPrice,
    String? storageItemId,
    String? itemName,
    bool? isGroup,
    double? qttyPerGroup,
  }) {
    return TempItemPurchaseRecord(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      supplierId: supplierId ?? this.supplierId,
      itemId: itemId ?? this.itemId,
      purchaseId: purchaseId ?? this.purchaseId,
      departmentId: departmentId ?? this.departmentId,
      customPrice: customPrice ?? this.customPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      storageItemId: storageItemId ?? this.storageItemId,
      itemName: itemName ?? this.itemName,
      isGroup: isGroup ?? this.isGroup,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
    );
  }
}
