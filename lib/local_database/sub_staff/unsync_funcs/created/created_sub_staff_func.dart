import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/created_sub_staffs/created_sub_staff.dart';

class CreatedSubStaffFunc {
  static final CreatedSubStaffFunc instance =
      CreatedSubStaffFunc._internal();
  factory CreatedSubStaffFunc() => instance;
  CreatedSubStaffFunc._internal();

  Box<CreatedSubStaff>? _createdSubStaffBox;
  final String createdSubStaffBoxName =
      'createdSubStaffBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedSubStaffAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedSubStaffAdapter());
      print('Created Sub Staff Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdSubStaffBoxName)) {
      _createdSubStaffBox =
          await Hive.openBox<CreatedSubStaff>(
            createdSubStaffBoxName,
          );
      print('Created Sub Staffs Box opened ✅');
    } else {
      _createdSubStaffBox = Hive.box<CreatedSubStaff>(
        createdSubStaffBoxName,
      );
      print(
        'Created Sub Staffs Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedSubStaff> get createdSubStaffBox {
    if (_createdSubStaffBox == null) {
      throw Exception(
        "Created Sub Staffs Func not initialized. Call await CreatedSubStaffFunc.instance.init() first.",
      );
    }
    return _createdSubStaffBox!;
  }

  List<CreatedSubStaff> getSubStaffs() {
    List<CreatedSubStaff> subStaffs =
        createdSubStaffBox.values.toList();
    subStaffs.sort(
      (a, b) => a.subStaff.staffName!.compareTo(
        b.subStaff.staffName!,
      ),
    );
    return subStaffs;
  }

  Future<int> insertAllSubStaffs(
    List<CreatedSubStaff> subStaffs,
  ) async {
    try {
      for (var subStaff in subStaffs) {
        await createdSubStaffBox.put(
          subStaff.subStaff.uuid,
          subStaff,
        );
      }
      print("Offline Created Sub Staffs inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Sub Staffs insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createSubStaff(
    CreatedSubStaff createdSubStaff,
  ) async {
    try {
      await createdSubStaffBox.put(
        createdSubStaff.subStaff.uuid,
        createdSubStaff,
      );
      print(
        'Offline Created Sub Staff inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Sub Staff insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateSubStaff(
    CreatedSubStaff createdSubStaff,
  ) async {
    try {
      await createdSubStaffBox.put(
        createdSubStaff.subStaff.uuid,
        createdSubStaff,
      );
      print(
        'Offline Created Sub Staff inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Sub Staff insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteSubStaff(String uuid) async {
    try {
      print(
        createdSubStaffBox.containsKey(uuid).toString(),
      );
      await createdSubStaffBox.delete(uuid);
      print('Sub Staff Deleted');
      return 1;
    } catch (e) {
      print('Sub Staff Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearSubStaffs() async {
    try {
      await createdSubStaffBox.clear();
      print('All Created Sub Staffs cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Created Sub Staffs ❌: $e',
      );
      return 0;
    }
  }
}
