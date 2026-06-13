import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/created/created_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/deleted/deleted_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/updated/updated_sub_staff_func.dart';
import 'package:stockall/main.dart';

class SubStaffFunc {
  static final SubStaffFunc instance =
      SubStaffFunc._internal();
  factory SubStaffFunc() => instance;
  SubStaffFunc._internal();
  late Box<TempSubStaff> subStaffBox;
  final String subStaffBoxName = 'subStaffBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempSubStaffAdapter());
    subStaffBox = await Hive.openBox(subStaffBoxName);
    await CreatedSubStaffFunc().init();
    await DeletedSubStaffFunc().init();
    await UpdatedSubStaffFunc().init();
    print('Sub Staff Box Initialized');
  }

  List<TempSubStaff> getSubStaffs() {
    List<TempSubStaff> subStaffs =
        subStaffBox.values.toList();
    subStaffs.sort(
      (a, b) => a.staffName!.toLowerCase().compareTo(
        b.staffName!.toLowerCase(),
      ),
    );
    print('Sub Staffs Gotten: ${subStaffs.length}');

    return subStaffs;
  }

  Future<int> insertAllSubStaffs(
    List<TempSubStaff> subStaffs,
  ) async {
    await clearSubStaffs();
    try {
      for (var subStaff in subStaffs) {
        await subStaffBox.put(subStaff.uuid, subStaff);
      }
      print('Offline Sub Staffs Inserted Successfully');
      return 1;
    } catch (e) {
      print(
        'Offline Sub Staff insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createSubStaff(TempSubStaff subStaff) async {
    try {
      await subStaffBox.put(subStaff.uuid, subStaff);
      print('Offline Sub Staff Inserted');
      return 1;
    } catch (e) {
      print('Sub Staff Insert Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> updateSubStaff(TempSubStaff subStaff) async {
    try {
      subStaff.updatedAt = DateTime.now();
      await subStaffBox.put(subStaff.uuid, subStaff);
      print('Offline Sub Staff Updated');
      return 1;
    } catch (e) {
      print('Sub Staff Update Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteSubStaff(String uuid) async {
    try {
      await subStaffBox.delete(uuid);
      print('Offline Sub Staff Deleted');
      return 1;
    } catch (e) {
      print('Sub Staff Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearSubStaffs() async {
    try {
      await subStaffBox.clear();
      print('Offline SubStaffs Cleared');
      return 1;
    } catch (e) {
      print(
        '❌❌ Error Clearing Offline Sub Staffs: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedSubStaffFunc().getSubStaffs().isEmpty &&
        UpdatedSubStaffFunc().getSubStaffs().isEmpty &&
        DeletedSubStaffFunc().getSubStaffIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
