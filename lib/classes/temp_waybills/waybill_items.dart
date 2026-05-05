import 'package:hive/hive.dart';

part 'waybill_items.g.dart';

@HiveType(typeId: 86)
class WaybillItems extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String waybillId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final String itemUuid;

  @HiveField(5)
  final String itemName;

  WaybillItems({
    required this.uuid,
    required this.waybillId,
    required this.quantity,
    required this.amount,
    required this.itemName,
    required this.itemUuid,
  });

  factory WaybillItems.fromJson(Map<String, dynamic> json) {
    return WaybillItems(
      uuid: json['uuid'],
      waybillId: json['waybill_uuid'],
      quantity: (json['quantity'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      itemName: json['item_name'],
      itemUuid: json['item_uuid'],
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
    };
  }
}
