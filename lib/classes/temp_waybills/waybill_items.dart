import 'package:hive/hive.dart';

part 'waybill_items.g.dart';

@HiveType(typeId: 86)
class WaybillItems extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String? waybillId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  String itemUuid;

  @HiveField(5)
  String itemName;

  @HiveField(6)
  bool? isGroup;

  @HiveField(7)
  double? qttyPerGroup;

  @HiveField(8)
  double? customPrice;

  @HiveField(9)
  double? originalCost;

  WaybillItems({
    required this.uuid,
    this.waybillId,
    required this.quantity,
    required this.amount,
    required this.itemName,
    required this.itemUuid,
    required this.isGroup,
    this.qttyPerGroup,
    this.customPrice,
    required this.originalCost,
  });

  factory WaybillItems.fromJson(Map<String, dynamic> json) {
    return WaybillItems(
      uuid: json['uuid'],
      waybillId: json['waybill_uuid'],
      quantity: (json['quantity'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      itemName: json['item_name'],
      itemUuid: json['item_uuid'],
      isGroup: json['is_group'],
      qttyPerGroup: json['qtty_per_group'],
      customPrice: json['custom_price'],
      originalCost: json['original_cost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'waybill_id': waybillId,
      'quantity': quantity,
      'amount': amount,
      'item_name': itemName,
      'item_uuid': itemUuid,
      'is_group': isGroup,
      'qtty_per_group': qttyPerGroup,
      'custom_price': customPrice,
      'original_cost': originalCost,
    };
  }

  WaybillItems copyWith({
    String? uuid,
    String? waybillId,
    double? quantity,
    double? amount,
    String? itemName,
    String? itemUuid,
    bool? isGroup,
    double? qttyPerGroup,
    double? customPrice,
    double? originalCost,
  }) {
    return WaybillItems(
      uuid: uuid ?? this.uuid,
      waybillId: waybillId ?? this.waybillId,
      amount: amount ?? this.amount,
      isGroup: isGroup ?? this.isGroup,
      itemName: itemName ?? this.itemName,
      itemUuid: itemUuid ?? this.itemUuid,
      originalCost: originalCost ?? this.originalCost,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
    );
  }
}
