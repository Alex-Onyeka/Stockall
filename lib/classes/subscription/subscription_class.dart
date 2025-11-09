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

  SubscriptionClass({
    this.subscriptionId,
    this.createdAt,
    this.userId,
    this.nextPayment,
    this.plan,
    this.lastPayment,
    this.userName,
  });

  factory SubscriptionClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubscriptionClass(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
      'next_payment': nextPayment?.toIso8601String(),
      'plan': plan,
      'last_payment': lastPayment?.toIso8601String(),
      'user_name': userName,
    };
  }
}
