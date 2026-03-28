import 'package:hive/hive.dart';

part 'temp_current_department.g.dart';

@HiveType(typeId: 65)
class TempCurrentDepartment {
  @HiveField(0)
  final String? currentDepartmentId;

  TempCurrentDepartment({this.currentDepartmentId});
}
