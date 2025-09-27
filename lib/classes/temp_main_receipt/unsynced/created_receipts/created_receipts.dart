import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
part 'created_receipts.g.dart';

@HiveType(typeId: 23)
class CreatedReceipts extends HiveObject {
  @HiveField(0)
  final TempMainReceipt receipt;

  CreatedReceipts({required this.receipt});
}
