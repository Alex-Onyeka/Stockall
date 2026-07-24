import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/updated/updated_sub_staff.dart';
import 'package:stockall/main.dart';

class UpdatedSubStaffFunc {
  static final UpdatedSubStaffFunc instance =
      UpdatedSubStaffFunc._internal();
  factory UpdatedSubStaffFunc() => instance;
  UpdatedSubStaffFunc._internal();

  Box<UpdatedSubStaff>? _updatedSubStaffBox;
  final String updatedSubStaffBoxName =
      'updatedSubStaffBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedSubStaffAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedSubStaffAdapter());
      await mainLocalLog(
        'Updated Sub Staff Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedSubStaffBoxName)) {
      _updatedSubStaffBox =
          await Hive.openBox<UpdatedSubStaff>(
            updatedSubStaffBoxName,
          );
      await mainLocalLog('Updated Sub Staff Box opened ✅');
    } else {
      _updatedSubStaffBox = Hive.box<UpdatedSubStaff>(
        updatedSubStaffBoxName,
      );
      await mainLocalLog(
        'Updated Sub Staff Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedSubStaff> get updatedSubStaffBox {
    if (_updatedSubStaffBox == null) {
      throw Exception(
        "Updated Sub Staff Func not initialized. Call await updated Sub Staff Func.instance.init() first.",
      );
    }
    return _updatedSubStaffBox!;
  }

  List<UpdatedSubStaff> getSubStaffs() {
    return updatedSubStaffBox.values.toList();
  }

  Future<int> createUpdatedSubStaff(
    UpdatedSubStaff updatedSubStaff,
  ) async {
    try {
      updatedSubStaff.subStaff.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedSubStaffBox.put(
        updatedSubStaff.subStaff.uuid,
        updatedSubStaff,
      );
      await mainLocalLog(
        'Offline updated Sub Staff inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Sub Staff insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedSubStaff(String uuid) async {
    try {
      await mainLocalLog(
        updatedSubStaffBox.containsKey(uuid).toString(),
      );
      await updatedSubStaffBox.delete(uuid);
      await mainLocalLog('Updated Sub Staff Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Sub Staff Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedSubStaff() async {
    try {
      await updatedSubStaffBox.clear();
      await mainLocalLog('All updated Sub Staff cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Sub Staff ❌: $e',
      );
      return 0;
    }
  }
}
