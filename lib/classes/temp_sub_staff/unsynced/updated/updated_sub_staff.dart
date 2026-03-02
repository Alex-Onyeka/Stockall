import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
part 'updated_sub_staff.g.dart';

@HiveType(typeId: 59)
class UpdatedSubStaff extends HiveObject {
  @HiveField(0)
  TempSubStaff subStaff;

  UpdatedSubStaff({required this.subStaff});
}
