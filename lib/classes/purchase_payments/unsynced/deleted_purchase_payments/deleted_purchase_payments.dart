import 'package:hive/hive.dart';
part 'deleted_purchase_payments.g.dart';

@HiveType(typeId: 85)
class DeletedPurchasePayments extends HiveObject {
  @HiveField(0)
  final String purchasePaymentUuid;

  DeletedPurchasePayments({
    required this.purchasePaymentUuid,
  });
}
