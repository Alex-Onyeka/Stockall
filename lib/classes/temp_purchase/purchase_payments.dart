import 'package:hive/hive.dart';

part 'purchase_payments.g.dart';

@HiveType(typeId: 83)
class PurchasePayments extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String purchaseId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String userId;

  @HiveField(5)
  final String paymentMethod;

  @HiveField(6)
  final String staffName;

  PurchasePayments({
    required this.uuid,
    required this.purchaseId,
    required this.createdAt,
    required this.amount,
    required this.userId,
    required this.paymentMethod,
    required this.staffName,
  });

  factory PurchasePayments.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchasePayments(
      uuid: json['uuid'],
      purchaseId: json['purchase_id'],
      createdAt: DateTime.parse(json['created_at']),
      amount: (json['amount'] as num).toDouble(),
      userId: json['user_id'],
      paymentMethod: json['payment_method'],
      staffName: json['staff_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'purchase_id': purchaseId,
      'created_at': createdAt.toIso8601String(),
      'amount': amount,
      'user_id': userId,
      'payment_method': paymentMethod,
      'staff_name': staffName,
    };
  }
}
