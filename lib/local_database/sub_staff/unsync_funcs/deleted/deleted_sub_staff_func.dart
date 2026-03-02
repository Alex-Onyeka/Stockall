import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/deleted_sub_staff/deleted_sub_staff.dart';

class DeletedSubStaffFunc {
  static final DeletedSubStaffFunc instance =
      DeletedSubStaffFunc._internal();
  factory DeletedSubStaffFunc() => instance;
  DeletedSubStaffFunc._internal();

  Box<DeletedSubStaff>? _deletedSubStaffBox;
  final String deletedSubStaffBoxName =
      'deletedSubStaffBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedSubStaffAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedSubStaffAdapter());
      print('Deleted Sub Staff Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedSubStaffBoxName)) {
      _deletedSubStaffBox =
          await Hive.openBox<DeletedSubStaff>(
            deletedSubStaffBoxName,
          );
      print('Deleted Sub Staff Box opened ✅');
    } else {
      _deletedSubStaffBox = Hive.box<DeletedSubStaff>(
        deletedSubStaffBoxName,
      );
      print('Deleted Sub Staff Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<DeletedSubStaff> get deletedSubStaffBox {
    if (_deletedSubStaffBox == null) {
      throw Exception(
        "Deleted Sub Staff Func not initialized. Call await Deleted Sub Staff Func.instance.init() first.",
      );
    }
    return _deletedSubStaffBox!;
  }

  List<DeletedSubStaff> getSubStaffIds() {
    return deletedSubStaffBox.values.toList();
  }

  Future<int> insertAllDeletedSubStaff(
    List<DeletedSubStaff> deletedSubStaff,
  ) async {
    try {
      for (var subStaff in deletedSubStaff) {
        await deletedSubStaffBox.add(subStaff);
      }
      print("Offline Deleted Sub Staff inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Sub Staff insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedSubStaff(
    DeletedSubStaff deletedSubStaff,
  ) async {
    try {
      await deletedSubStaffBox.add(deletedSubStaff);
      print(
        'Offline Deleted Sub Staff inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Sub Staff insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedSubStaff() async {
    try {
      await deletedSubStaffBox.clear();
      print('All Deleted Sub Staff cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Sub Staff ❌: $e');
      return 0;
    }
  }
}
