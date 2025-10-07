import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
part 'created_records.g.dart';

@HiveType(typeId: 20)
class CreatedRecords extends HiveObject {
  @HiveField(0)
  final TempProductSaleRecord record;

  CreatedRecords({required this.record});
}
