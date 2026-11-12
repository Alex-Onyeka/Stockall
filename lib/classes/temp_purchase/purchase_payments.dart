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
      uuid: json['uuid'] as String? ?? '',
      purchaseId: json['purchase_id'] as String? ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(
                json['created_at'].toString(),
              ).toLocal()
              : DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id'] as String? ?? '',
      paymentMethod:
          json['payment_method'] as String? ?? 'Cash',
      staffName: json['staff_name'] as String? ?? '',
    );
  }

  PurchasePayments copyWith({
    String? uuid,
    String? purchaseId,
    DateTime? createdAt,
    double? amount,
    String? userId,
    String? paymentMethod,
    String? staffName,
  }) {
    return PurchasePayments(
      uuid: uuid ?? this.uuid,
      purchaseId: purchaseId ?? this.purchaseId,
      createdAt: createdAt ?? this.createdAt,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      staffName: staffName ?? this.staffName,
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
