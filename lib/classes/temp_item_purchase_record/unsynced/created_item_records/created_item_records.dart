import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
part 'created_item_records.g.dart';

@HiveType(typeId: 78)
class CreatedItemRecords extends HiveObject {
  @HiveField(0)
  final TempItemPurchaseRecord record;

  CreatedItemRecords({required this.record});
}
