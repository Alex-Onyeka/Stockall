import 'package:hive/hive.dart';
part 'deleted_sub_staff.g.dart';

@HiveType(typeId: 58)
class DeletedSubStaff extends HiveObject {
  @HiveField(0)
  final String subStaffUuid;

  DeletedSubStaff({required this.subStaffUuid});
}
