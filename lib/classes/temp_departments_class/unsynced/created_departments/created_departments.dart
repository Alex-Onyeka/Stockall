import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
part 'created_departments.g.dart';

@HiveType(typeId: 40)
class CreatedDepartments extends HiveObject {
  @HiveField(0)
  final DepartmentClass department;

  CreatedDepartments({required this.department});
}
