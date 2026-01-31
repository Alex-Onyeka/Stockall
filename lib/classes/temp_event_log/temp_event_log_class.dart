import 'package:hive/hive.dart';

part 'temp_event_log_class.g.dart';

@HiveType(typeId: 34)
class TempEventLogClass {
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
  final String event;

  @HiveField(6)
  final String? message;

  @HiveField(7)
  final double? amount;

  @HiveField(8)
  final String? itemName;

  @HiveField(9)
  final String? staffName;

  TempEventLogClass({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.tableName,
    required this.title,
    required this.event,
    this.message,
    this.amount,
    this.staffName,
    this.itemName,
  });

  factory TempEventLogClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempEventLogClass(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      tableName: json['table'] as String,
      title: json['title'] as String,
      event: json['event'] as String,
      message: json['message'] as String?,
      amount:
          json['amount'] != null
              ? (json['amount'] as num).toDouble()
              : null,
      staffName: json['staff_name'] as String?,
      itemName: json['item_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'table': tableName,
      'title': title,
      'event': event,
      'message': message,
      'amount': amount,
      'staff_name': staffName,
      'item_name': itemName,
    };
  }
}
