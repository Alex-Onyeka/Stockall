class TempSubPaymentClass {
  final String? paymentsId;
  final DateTime? createdAt;
  final String userId;
  final int? plan;
  final DateTime? nextPayment;
  final int? amount;
  final int duration;

  TempSubPaymentClass({
    this.paymentsId,
    this.createdAt,
    required this.userId,
    this.plan,
    this.nextPayment,
    this.amount,
    required this.duration,
  });

  factory TempSubPaymentClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempSubPaymentClass(
      paymentsId: json['payments_id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'] as String,
      plan: json['plan'],
      nextPayment:
          json['next_payment'] != null
              ? DateTime.parse(json['next_payment'])
              : null,
      amount: json['amount'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'payments_id': paymentsId,
      // 'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'plan': plan,
      'next_payment': nextPayment?.toIso8601String(),
      'amount': amount,
      'duration': duration,
    };
  }
}
