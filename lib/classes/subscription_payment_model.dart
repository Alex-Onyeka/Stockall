class SubscriptionPaymentModel {
  final String paymentsId;
  final DateTime createdAt;
  final String userId;
  final int plan;
  final int? oldPlan;
  final DateTime? nextPayment;
  final DateTime? lastPayment;
  final num? amount;
  final String? reference;
  final String? paymentChannel;
  final String status;
  final String? accessCode;
  final String? authorizationUrl;
  final int duration;
  final Map<String, dynamic>? metadata;

  SubscriptionPaymentModel({
    required this.paymentsId,
    required this.createdAt,
    required this.userId,
    required this.plan,
    this.oldPlan,
    this.nextPayment,
    this.lastPayment,
    this.amount,
    this.reference,
    this.paymentChannel,
    required this.status,
    this.accessCode,
    this.authorizationUrl,
    required this.duration,
    this.metadata,
  });

  factory SubscriptionPaymentModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentModel(
      paymentsId: json['payments_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userId: json['user_id']?.toString() ?? '',
      plan: json['plan'] != null ? (json['plan'] as num).toInt() : 0,
      oldPlan:
          json['old_plan'] != null ? (json['old_plan'] as num).toInt() : null,
      nextPayment:
          json['next_payment'] != null
              ? DateTime.tryParse(json['next_payment'])
              : null,
      lastPayment:
          json['last_payment'] != null
              ? DateTime.tryParse(json['last_payment'])
              : null,
      amount: json['amount'] as num?,
      reference: json['reference'] as String?,
      paymentChannel: json['payment_channel'] as String?,
      status: json['status'] as String? ?? 'initialized',
      accessCode: json['access_code'] as String?,
      authorizationUrl: json['authorization_url'] as String?,
      duration:
          json['duration'] != null ? (json['duration'] as num).toInt() : 1,
      metadata:
          json['metadata'] is Map<String, dynamic>
              ? json['metadata'] as Map<String, dynamic>
              : null,
    );
  }

  String getPlanName() {
    if (plan == 1) return 'Basic';
    if (plan == 2) return 'Standard';
    if (plan == 3) return 'Premium';
    if (plan == 4) return 'Silver';
    if (plan == 5) return 'Gold';
    return 'Free';
  }

  String getDurationText() {
    if (duration == 1) return '1 Month';
    if (duration == 6) return '6 Months';
    if (duration == 12) return '1 Year';
    return '$duration Months';
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

