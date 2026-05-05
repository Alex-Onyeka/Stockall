import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
part 'updated_waybills.g.dart';

@HiveType(typeId: 89)
class UpdatedWaybills extends HiveObject {
  @HiveField(0)
  final TempWayBills waybill;

  UpdatedWaybills({required this.waybill});
}
