import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
part 'created_waybills.g.dart';

@HiveType(typeId: 87)
class CreatedWaybills extends HiveObject {
  @HiveField(0)
  final TempWayBills waybill;

  CreatedWaybills({required this.waybill});
}
