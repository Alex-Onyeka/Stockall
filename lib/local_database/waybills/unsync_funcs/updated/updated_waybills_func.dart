import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/unsynced/updated/updated_waybills.dart';

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
      print('Updated Waybills Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedWaybillsBoxName)) {
      _updatedWaybillsBox =
          await Hive.openBox<UpdatedWaybills>(
            updatedWaybillsBoxName,
          );
      print('Updated Waybills Box opened ✅');
    } else {
      _updatedWaybillsBox = Hive.box<UpdatedWaybills>(
        updatedWaybillsBoxName,
      );
      print('Updated Waybills Box already open, reused ✅');
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
      print(
        'Offline Updated Waybill inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
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
      print(
        'Offline Updated Waybill Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      print('Offline Updated Waybill Update failed ❌: $e');
      return 0;
    }
  }

  Future<int> deleteUpdatedWaybill(String uuid) async {
    try {
      print(
        updatedWaybillsBox.containsKey(uuid).toString(),
      );
      await updatedWaybillsBox.delete(uuid);
      print('Updated Waybill Deleted');
      return 1;
    } catch (e) {
      print('Waybill Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearUpdatedWaybills() async {
    try {
      await updatedWaybillsBox.clear();
      print('All updated Waybills cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Waybills ❌: $e');
      return 0;
    }
  }
}
