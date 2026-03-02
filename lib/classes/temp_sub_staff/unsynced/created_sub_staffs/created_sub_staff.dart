import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
part 'created_sub_staff.g.dart';

@HiveType(typeId: 57)
class CreatedSubStaff extends HiveObject {
  @HiveField(0)
  final TempSubStaff subStaff;

  CreatedSubStaff({required this.subStaff});
}
