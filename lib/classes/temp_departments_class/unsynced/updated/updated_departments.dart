import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
part 'updated_departments.g.dart';

@HiveType(typeId: 42)
class UpdatedDepartments extends HiveObject {
  @HiveField(0)
  DepartmentClass department;

  UpdatedDepartments({required this.department});
}
