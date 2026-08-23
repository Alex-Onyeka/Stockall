import 'package:hive/hive.dart';
part 'customer_account_update.g.dart';

@HiveType(typeId: 131)
class CustomerAccountUpdate extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  double amount;

  @HiveField(3)
  final String customerUuid;

  @HiveField(4)
  bool isIncrement;

  @HiveField(5)
  bool isBalance;

  // @HiveField(5)
  // final String? otherUuid;

  CustomerAccountUpdate({
    this.uuid,
    this.createdAt,
    required this.amount,
    required this.customerUuid,
    required this.isIncrement,
    required this.isBalance,
    // required this.otherUuid,
  });
}
