import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_current_department/temp_current_department.dart';

class CurrentDepartmentFunc {
  static final CurrentDepartmentFunc instance =
      CurrentDepartmentFunc._internal();
  factory CurrentDepartmentFunc() => instance;
  CurrentDepartmentFunc._internal();
  late Box<TempCurrentDepartment> currentDepartmentBox;
  final String currentDepartmentBoxName =
      'currentDepartmentBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(TempCurrentDepartmentAdapter());

      currentDepartmentBox = await Hive.openBox(
        currentDepartmentBoxName,
      );
      print('✅ Current Department Box Initialized');
    } catch (e) {
      print('❌ Error New: ${e.toString()}');
      try {
        if (Hive.isBoxOpen(currentDepartmentBoxName)) {
          await Hive.box(currentDepartmentBoxName).close();
        }

        await Hive.deleteBoxFromDisk(
          currentDepartmentBoxName,
        );
        print(
          '🧹 Deleted Corrupted Current Department Box',
        );

        currentDepartmentBox = await Hive.openBox(
          currentDepartmentBoxName,
        );
        print('✅ Reinitialized Current Department Box');
      } catch (innerError) {
        print('⚠️ Failed to recover Hive box: $innerError');
      }
    }
  }

  TempCurrentDepartment? getCurrentDepartment() {
    TempCurrentDepartment? departmentId =
        currentDepartmentBox.values.isNotEmpty
            ? currentDepartmentBox.values.first
            : null;
    return departmentId;
  }

  Future<int> createCurrentDepartment(
    TempCurrentDepartment department,
  ) async {
    try {
      await clearCurrentDepartment();
      await currentDepartmentBox.put(
        department.currentDepartmentId,
        department,
      );
      print(
        'Offline Current Department inserted Successfully',
      );

      return 1;
    } catch (e) {
      print(
        'Offline Current Department Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCurrentDepartment() async {
    try {
      if (currentDepartmentBox.values.isNotEmpty) {
        await currentDepartmentBox.clear();
        print('Offline Current Department Cleared');
      }
      return 1;
    } catch (e) {
      print(
        '❌❌ Offline Current Department Error: ${e.toString()}',
      );
      return 0;
    }
  }
}
