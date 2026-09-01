import 'package:hive/hive.dart';

part 'subscription_class.g.dart';

@HiveType(typeId: 31)
class SubscriptionClass extends HiveObject {
  @HiveField(0)
  String? subscriptionId;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  String? userId;

  @HiveField(3)
  DateTime? nextPayment;

  @HiveField(4)
  int? plan;

  @HiveField(5)
  DateTime? lastPayment;

  @HiveField(6)
  String? userName;

  @HiveField(7)
  double? amount;

  @HiveField(8)
  String? email;

  @HiveField(9)
  int? oldPlan;

  SubscriptionClass({
    this.subscriptionId,
    this.createdAt,
    this.userId,
    this.nextPayment,
    this.plan,
    required this.oldPlan,
    this.lastPayment,
    this.userName,
    this.amount,
    required this.email,
  });

  factory SubscriptionClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubscriptionClass(
      oldPlan:
          json['old_plan'] != null
              ? json['old_plan'] as int
              : 0,
      subscriptionId: json['subscription_id'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      userId: json['user_id'] as String?,
      nextPayment:
          json['next_payment'] != null
              ? DateTime.parse(json['next_payment'])
              : null,
      plan: json['plan'] != null ? json['plan'] as int : 0,
      lastPayment:
          json['last_payment'] != null
              ? DateTime.parse(json['last_payment'])
              : null,
      userName: json['user_name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
      'next_payment': nextPayment?.toIso8601String(),
      'plan': plan,
      'old_plan': oldPlan,
      'last_payment': lastPayment?.toIso8601String(),
      'user_name': userName,
      'amount': amount,
      'email': email,
    };
  }

  String getPlanName() {
    if (plan == 1) {
      return 'Basic';
    } else if (plan == 2) {
      return 'Standard';
    } else if (plan == 3) {
      return 'Premium';
    } else if (plan == 4) {
      return 'Silver';
    } else if (plan == 5) {
      return 'Gold';
    } else {
      return 'Free';
    }
  }
}
