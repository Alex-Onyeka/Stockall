import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/deleted_departments/deleted_departments.dart';

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
      print('Deleted Departments Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedDepartmentsBoxName)) {
      _deletedDepartmentsBox =
          await Hive.openBox<DeletedDepartments>(
            deletedDepartmentsBoxName,
          );
      print('Deleted Departments Box opened ✅');
    } else {
      _deletedDepartmentsBox = Hive.box<DeletedDepartments>(
        deletedDepartmentsBoxName,
      );
      print(
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
      print("Offline Deleted Departments inserted ✅");
      return 1;
    } catch (e) {
      print(
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
      print(
        'Offline Deleted Department inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Department insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedDepartments() async {
    try {
      await deletedDepartmentsBox.clear();
      print('All Deleted Departments cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Deleted Departments ❌: $e',
      );
      return 0;
    }
  }
}
