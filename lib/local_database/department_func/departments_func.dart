import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/created_departments/created_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/deleted_department/deleted_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/updated_department/updated_department_func.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class DepartmentsFunc {
  static final DepartmentsFunc instance =
      DepartmentsFunc._internal();
  factory DepartmentsFunc() => instance;
  DepartmentsFunc._internal();
  late Box<DepartmentClass> departmentBox;
  final String departmentBoxName = 'departmentBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(DepartmentClassAdapter());
    departmentBox = await openBoxSafely<DepartmentClass>(
      departmentBoxName,
    );
    try {
      await CreatedDepartmentsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CreatedDepartmentsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await DeletedDepartmentsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing DeletedDepartmentsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await UpdatedDepartmentFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing UpdatedDepartmentFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    await mainLocalLog('Department Box Initialized');
  }

  List<DepartmentClass> getDepartment() {
    try {
      List<DepartmentClass> depts =
          departmentBox.values.toList();
      depts.sort((a, b) => a.name.compareTo(b.name));
      return depts;
    } catch (e, s) {
      mainLocalLog(
        'Error reading departments: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<int> insertAllDepartment(
    List<DepartmentClass> department,
  ) async {
    await clearDepartment();
    try {
      if (department.isEmpty) {
        CurrentDepartmentFunc().clearCurrentDepartment();
        return 1;
      } else {
        for (var dept in department) {
          await departmentBox.put(dept.uuid, dept);
        }
        await mainLocalLog(
          'Offline Departments Insert Success',
        );
        return 1;
      }
    } catch (e) {
      await mainLocalLog(
        'Offline Departments Insert Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createDepartment(
    DepartmentClass department,
  ) async {
    try {
      await departmentBox.put(department.uuid, department);
      await mainLocalLog('Offline Department Created');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Department Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateDepartment(
    DepartmentClass department,
  ) async {
    department.updatedAt = DateTime.now().add(
      (Duration(hours: 1)),
    );
    try {
      await departmentBox.put(department.uuid, department);
      await mainLocalLog('Offline Department Updated');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Department Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteDepartment(String uuid) async {
    try {
      await departmentBox.delete(uuid);
      await mainLocalLog('Offline Department Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Department Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearDepartment() async {
    try {
      await departmentBox.clear();
      await mainLocalLog('Offline Department Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Department Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedDepartmentsFunc().getDepartment().isEmpty &&
        UpdatedDepartmentFunc().getDepartments().isEmpty &&
        DeletedDepartmentsFunc()
            .getDepartmentIds()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
