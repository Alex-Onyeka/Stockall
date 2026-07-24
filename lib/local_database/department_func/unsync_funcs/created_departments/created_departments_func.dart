import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/created_departments/created_departments.dart';
import 'package:stockall/main.dart';

class CreatedDepartmentsFunc {
  static final CreatedDepartmentsFunc instance =
      CreatedDepartmentsFunc._internal();
  factory CreatedDepartmentsFunc() => instance;
  CreatedDepartmentsFunc._internal();

  Box<CreatedDepartments>? _createdDepartmentsBox;
  final String createdDepartmentsBoxName =
      'createdDepartmentsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedDepartmentsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedDepartmentsAdapter());
      await mainLocalLog(
        'Created Department Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdDepartmentsBoxName)) {
      _createdDepartmentsBox =
          await Hive.openBox<CreatedDepartments>(
            createdDepartmentsBoxName,
          );
      await mainLocalLog('Created Department Box opened ✅');
    } else {
      _createdDepartmentsBox = Hive.box<CreatedDepartments>(
        createdDepartmentsBoxName,
      );
      await mainLocalLog(
        'Created Department Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedDepartments> get createdDepartmentsBox {
    if (_createdDepartmentsBox == null) {
      throw Exception(
        "Created Department Func not initialized. Call await CreatedDepartmentssFunc.instance.init() first.",
      );
    }
    return _createdDepartmentsBox!;
  }

  List<CreatedDepartments> getDepartment() {
    return createdDepartmentsBox.values.toList();
  }

  Future<int> insertAllDepartment(
    List<CreatedDepartments> createdDepartments,
  ) async {
    try {
      for (var department in createdDepartments) {
        await createdDepartmentsBox.put(
          department.department.uuid,
          department,
        );
      }
      await mainLocalLog(
        "Offline Created Department inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Department insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDepartment(
    CreatedDepartments createdDepartments,
  ) async {
    try {
      await createdDepartmentsBox.put(
        createdDepartments.department.uuid,
        createdDepartments,
      );
      await mainLocalLog(
        'Offline Created Department inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Department insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateDepartment(
    CreatedDepartments createdDepartments,
  ) async {
    try {
      await createdDepartmentsBox.put(
        createdDepartments.department.uuid,
        createdDepartments,
      );
      await mainLocalLog(
        'Offline Created Department inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Department insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteDepartment(String uuid) async {
    try {
      await mainLocalLog(
        createdDepartmentsBox.containsKey(uuid).toString(),
      );
      await createdDepartmentsBox.delete(uuid);
      await mainLocalLog('Department Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Department Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearDepartment() async {
    try {
      await createdDepartmentsBox.clear();
      await mainLocalLog(
        'All Created Department cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Department ❌: $e',
      );
      return 0;
    }
  }
}
