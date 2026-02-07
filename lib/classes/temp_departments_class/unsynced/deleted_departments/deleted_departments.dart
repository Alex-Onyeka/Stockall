import 'package:hive/hive.dart';
part 'deleted_departments.g.dart';

@HiveType(typeId: 41)
class DeletedDepartments extends HiveObject {
  @HiveField(0)
  final String departmentUuid;

  @HiveField(1)
  final int shopId;

  DeletedDepartments({
    required this.departmentUuid,
    required this.shopId,
  });
}
