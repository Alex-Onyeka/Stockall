import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/deleted_departments/deleted_departments.dart';
import 'package:stockall/main.dart';

class DeletedDepartmentsFunc {
  static final DeletedDepartmentsFunc instance =
      DeletedDepartmentsFunc._internal();
  factory DeletedDepartmentsFunc() => instance;
  DeletedDepartmentsFunc._internal();

  Box<DeletedDepartments>? _deletedDepartmentsBox;
  final String deletedDepartmentsBoxName =
      'deletedDepartmentsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedDepartmentsAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedDepartmentsAdapter());
      await mainLocalLog(
        'Deleted Departments Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedDepartmentsBoxName)) {
      _deletedDepartmentsBox =
          await Hive.openBox<DeletedDepartments>(
            deletedDepartmentsBoxName,
          );
      await mainLocalLog(
        'Deleted Departments Box opened ✅',
      );
    } else {
      _deletedDepartmentsBox = Hive.box<DeletedDepartments>(
        deletedDepartmentsBoxName,
      );
      await mainLocalLog(
        'Deleted Departments Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedDepartments> get deletedDepartmentsBox {
    if (_deletedDepartmentsBox == null) {
      throw Exception(
        "Deleted Departments Func not initialized. Call await Deleted Departments Func.instance.init() first.",
      );
    }
    return _deletedDepartmentsBox!;
  }

  List<DeletedDepartments> getDepartmentIds() {
    return deletedDepartmentsBox.values.toList();
  }

  Future<int> insertAllDeletedDepartments(
    List<DeletedDepartments> deletedDepartments,
  ) async {
    try {
      for (var department in deletedDepartments) {
        await deletedDepartmentsBox.add(department);
      }
      await mainLocalLog(
        "Offline Deleted Departments inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Departments insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedDepartment(
    DeletedDepartments deletedDepartment,
  ) async {
    try {
      await deletedDepartmentsBox.add(deletedDepartment);
      await mainLocalLog(
        'Offline Deleted Department inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Department insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedDepartments() async {
    try {
      await deletedDepartmentsBox.clear();
      await mainLocalLog(
        'All Deleted Departments cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Departments ❌: $e',
      );
      return 0;
    }
  }
}
