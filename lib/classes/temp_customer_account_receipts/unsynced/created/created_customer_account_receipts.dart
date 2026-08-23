import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
part 'created_customer_account_receipts.g.dart';

@HiveType(typeId: 128)
class CreatedCustomerAccountReceipts extends HiveObject {
  @HiveField(0)
  final CustomerAccountReceipts
  createdCustomerAccountReceipts;

  CreatedCustomerAccountReceipts({
    required this.createdCustomerAccountReceipts,
  });
}
