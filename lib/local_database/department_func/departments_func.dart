import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/created_departments/created_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/deleted_department/deleted_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/updated_department/updated_department_func.dart';
import 'package:stockall/main.dart';

class DepartmentsFunc {
  static final DepartmentsFunc instance =
      DepartmentsFunc._internal();
  factory DepartmentsFunc() => instance;
  DepartmentsFunc._internal();
  late Box<DepartmentClass> departmentBox;
  final String departmentBoxName = 'departmentBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(DepartmentClassAdapter());
    departmentBox = await Hive.openBox(departmentBoxName);
    await CreatedDepartmentsFunc().init();
    await DeletedDepartmentsFunc().init();
    await UpdatedDepartmentFunc().init();
    print('Department Box Initialized');
  }

  List<DepartmentClass> getDepartment() {
    List<DepartmentClass> depts =
        departmentBox.values.toList();
    depts.sort((a, b) => a.name.compareTo(b.name));
    return depts;
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
        print('Offline Departments Insert Success');
        return 1;
      }
    } catch (e) {
      print(
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
      print('Offline Department Created');
      return 1;
    } catch (e) {
      print(
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
      print('Offline Department Updated');
      return 1;
    } catch (e) {
      print(
        'Offline Department Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteDepartment(String uuid) async {
    try {
      await departmentBox.delete(uuid);
      print('Offline Department Deleted');
      return 1;
    } catch (e) {
      print(
        'Offline Department Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearDepartment() async {
    try {
      await departmentBox.clear();
      print('Offline Department Cleared');
      return 1;
    } catch (e) {
      print('Department Clear Failed: ${e.toString()}');
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
