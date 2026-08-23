import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
part 'updated_customer_account_receipts.g.dart';

@HiveType(typeId: 130)
class UpdatedCustomerAccountReceipts extends HiveObject {
  @HiveField(0)
  final CustomerAccountReceipts
  updatedCustomerAccountReceipts;

  UpdatedCustomerAccountReceipts({
    required this.updatedCustomerAccountReceipts,
  });
}
