import 'package:hive/hive.dart';
part 'updated_receipts.g.dart';

@HiveType(typeId: 25)
class UpdatedReceipts extends HiveObject {
  @HiveField(0)
  String receiptUuid;

  UpdatedReceipts({required this.receiptUuid});
}
