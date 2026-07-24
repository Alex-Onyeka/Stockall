import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/unsynced/updated/updated_waybills.dart';
import 'package:stockall/main.dart';

class UpdatedWaybillsFunc {
  static final UpdatedWaybillsFunc instance =
      UpdatedWaybillsFunc._internal();
  factory UpdatedWaybillsFunc() => instance;
  UpdatedWaybillsFunc._internal();

  Box<UpdatedWaybills>? _updatedWaybillsBox;
  final String updatedWaybillsBoxName =
      'updatedWaybillsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedWaybillsAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedWaybillsAdapter());
      await mainLocalLog(
        'Updated Waybills Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedWaybillsBoxName)) {
      _updatedWaybillsBox =
          await Hive.openBox<UpdatedWaybills>(
            updatedWaybillsBoxName,
          );
      await mainLocalLog('Updated Waybills Box opened ✅');
    } else {
      _updatedWaybillsBox = Hive.box<UpdatedWaybills>(
        updatedWaybillsBoxName,
      );
      await mainLocalLog(
        'Updated Waybills Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedWaybills> get updatedWaybillsBox {
    if (_updatedWaybillsBox == null) {
      throw Exception(
        "Updated Waybills Func not initialized. Call await updated Waybills Func.instance.init() first.",
      );
    }
    return _updatedWaybillsBox!;
  }

  List<UpdatedWaybills> getWaybillIds() {
    return updatedWaybillsBox.values.toList();
  }

  Future<int> createUpdatedWaybill(
    UpdatedWaybills updatedWaybill,
  ) async {
    try {
      updatedWaybillsBox.add(
        UpdatedWaybills(waybill: updatedWaybill.waybill),
      );
      await mainLocalLog(
        'Offline Updated Waybill inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Waybill insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedWaybill(
    UpdatedWaybills updatedWaybill,
  ) async {
    try {
      updatedWaybillsBox.add(
        UpdatedWaybills(waybill: updatedWaybill.waybill),
      );
      await mainLocalLog(
        'Offline Updated Waybill Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Waybill Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedWaybill(String uuid) async {
    try {
      await mainLocalLog(
        updatedWaybillsBox.containsKey(uuid).toString(),
      );
      await updatedWaybillsBox.delete(uuid);
      await mainLocalLog('Updated Waybill Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Waybill Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedWaybills() async {
    try {
      await updatedWaybillsBox.clear();
      await mainLocalLog('All updated Waybills cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Waybills ❌: $e',
      );
      return 0;
    }
  }
}
