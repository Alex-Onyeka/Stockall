import 'package:hive/hive.dart';
part 'deleted_customer_account_receipts.g.dart';

@HiveType(typeId: 129)
class DeletedCustomerAccountReceipts extends HiveObject {
  @HiveField(0)
  final String customerAccountReceiptUuid;

  DeletedCustomerAccountReceipts({
    required this.customerAccountReceiptUuid,
  });
}
