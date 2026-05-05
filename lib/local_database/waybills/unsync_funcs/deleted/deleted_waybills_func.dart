import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/unsynced/deleted_waybills/deleted_waybills.dart';

class DeletedWaybillsFunc {
  static final DeletedWaybillsFunc instance =
      DeletedWaybillsFunc._internal();
  factory DeletedWaybillsFunc() => instance;
  DeletedWaybillsFunc._internal();

  Box<DeletedWaybills>? _deletedWaybillsBox;
  final String deletedWaybillsBoxName =
      'deletedWaybillsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedWaybillsAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedWaybillsAdapter());
      print('Deleted Waybills Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedWaybillsBoxName)) {
      _deletedWaybillsBox =
          await Hive.openBox<DeletedWaybills>(
            deletedWaybillsBoxName,
          );
      print('Deleted Waybills Box opened ✅');
    } else {
      _deletedWaybillsBox = Hive.box<DeletedWaybills>(
        deletedWaybillsBoxName,
      );
      print('Deleted Waybills Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<DeletedWaybills> get deletedWaybillsBox {
    if (_deletedWaybillsBox == null) {
      throw Exception(
        "Deleted Waybills Func not initialized. Call await Deleted Waybills Func.instance.init() first.",
      );
    }
    return _deletedWaybillsBox!;
  }

  List<DeletedWaybills> getWaybillIds() {
    return deletedWaybillsBox.values.toList();
  }

  Future<int> insertAllDeletedWaybills(
    List<DeletedWaybills> deletedWaybills,
  ) async {
    try {
      for (var waybill in deletedWaybills) {
        await deletedWaybillsBox.add(waybill);
      }
      print("Offline Deleted Waybills inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Waybills insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedWaybill(
    DeletedWaybills deletedWaybill,
  ) async {
    try {
      await deletedWaybillsBox.add(deletedWaybill);
      print(
        'Offline Deleted Waybill inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Waybill insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedWaybills(String uuid) async {
    try {
      await deletedWaybillsBox.delete(uuid);
      print('Delete Waybill cleared ✅');
      return 1;
    } catch (e) {
      print('Error while Deleting Deleted Waybill ❌: $e');
      return 0;
    }
  }

  Future<int> clearDeletedWaybills() async {
    try {
      await deletedWaybillsBox.clear();
      print('All Deleted Waybills cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Waybills ❌: $e');
      return 0;
    }
  }
}
