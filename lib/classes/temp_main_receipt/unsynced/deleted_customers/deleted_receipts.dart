import 'package:hive/hive.dart';
part 'deleted_receipts.g.dart';

@HiveType(typeId: 24)
class DeletedReceipts extends HiveObject {
  @HiveField(0)
  final String receiptUuid;

  DeletedReceipts({required this.receiptUuid});
}
