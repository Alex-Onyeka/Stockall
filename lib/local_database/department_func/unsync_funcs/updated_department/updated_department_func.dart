import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/updated/updated_departments.dart';
import 'package:stockall/main.dart';

class UpdatedDepartmentFunc {
  static final UpdatedDepartmentFunc instance =
      UpdatedDepartmentFunc._internal();
  factory UpdatedDepartmentFunc() => instance;
  UpdatedDepartmentFunc._internal();

  Box<UpdatedDepartments>? _updatedDepartmentsBox;
  final String updatedDepartmentsBoxName =
      'updatedDepartmentsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedDepartmentsAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedDepartmentsAdapter());
      await mainLocalLog(
        'Updated Departments Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedDepartmentsBoxName)) {
      _updatedDepartmentsBox =
          await Hive.openBox<UpdatedDepartments>(
            updatedDepartmentsBoxName,
          );
      await mainLocalLog(
        'Updated Departments Box opened ✅',
      );
    } else {
      _updatedDepartmentsBox = Hive.box<UpdatedDepartments>(
        updatedDepartmentsBoxName,
      );
      await mainLocalLog(
        'Updated Departments Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedDepartments> get updatedDepartmentsBox {
    if (_updatedDepartmentsBox == null) {
      throw Exception(
        "Updated Departments Func not initialized. Call await updated Departments Func.instance.init() first.",
      );
    }
    return _updatedDepartmentsBox!;
  }

  List<UpdatedDepartments> getDepartments() {
    return updatedDepartmentsBox.values.toList();
  }

  Future<int> createUpdatedDepartment(
    UpdatedDepartments updatedDepartment,
  ) async {
    try {
      updatedDepartment
          .department
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedDepartmentsBox.put(
        updatedDepartment.department.uuid,
        updatedDepartment,
      );
      await mainLocalLog(
        'Offline updated Department inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Department insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedDepartment(String uuid) async {
    try {
      await mainLocalLog(
        updatedDepartmentsBox.containsKey(uuid).toString(),
      );
      await updatedDepartmentsBox.delete(uuid);
      await mainLocalLog('Updated Department Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Department Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearupdatedDepartments() async {
    try {
      await updatedDepartmentsBox.clear();
      await mainLocalLog(
        'All updated Departments cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Departments ❌: $e',
      );
      return 0;
    }
  }
}
