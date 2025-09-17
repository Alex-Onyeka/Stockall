import 'package:hive/hive.dart';

part 'temp_notification.g.dart';

@HiveType(typeId: 4)
class TempNotification {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String notifId;

  @HiveField(2)
  final int shopId;

  @HiveField(3)
  final int? productId;

  @HiveField(4)
  final String? itemName;

  @HiveField(5)
  final int? expenseId;

  @HiveField(6)
  final String title;

  @HiveField(7)
  final String text;

  @HiveField(8)
  final DateTime date;

  @HiveField(9)
  final String category;

  @HiveField(10)
  bool isViewed;

  @HiveField(11)
  String? departmentName;

  @HiveField(12)
  int? departmentId;

  TempNotification({
    this.id,
    required this.shopId,
    required this.notifId,
    this.productId,
    this.expenseId,
    required this.title,
    required this.text,
    required this.date,
    required this.isViewed,
    required this.category,
    this.itemName,
    this.departmentName,
    this.departmentId,
  });

  factory TempNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempNotification(
      id: json['id'],
      notifId: json['notif_id'],
      shopId: json['shop_id'],
      productId: json['product_id'],
      expenseId: json['expense_id'],
      title: json['title'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      isViewed: json['is_viewed'],
      category: json['category'],
      itemName: json['item_name'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notif_id': notifId,
      'shop_id': shopId,
      'product_id': productId,
      'expense_id': expenseId,
      'title': title,
      'text': text,
      'date': date.toIso8601String(),
      'is_viewed': isViewed,
      'category': category,
      'item_name': itemName,
      'department_id': departmentId,
      'department_name': departmentName,
    };
  }
}
