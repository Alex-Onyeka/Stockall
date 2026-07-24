import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/unsynced/created_waybills/created_waybills.dart';
import 'package:stockall/main.dart';

class CreatedWaybillsFunc {
  static final CreatedWaybillsFunc instance =
      CreatedWaybillsFunc._internal();
  factory CreatedWaybillsFunc() => instance;
  CreatedWaybillsFunc._internal();

  Box<CreatedWaybills>? _createdWaybillsBox;
  final String createdWaybillsBoxName =
      'createdWaybillsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedWaybillsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedWaybillsAdapter());
      await mainLocalLog(
        'Created Waybills Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdWaybillsBoxName)) {
      _createdWaybillsBox =
          await Hive.openBox<CreatedWaybills>(
            createdWaybillsBoxName,
          );
      await mainLocalLog('Created Waybills Box opened ✅');
    } else {
      _createdWaybillsBox = Hive.box<CreatedWaybills>(
        createdWaybillsBoxName,
      );
      await mainLocalLog(
        'Created Waybills Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedWaybills> get createdWaybillsBox {
    if (_createdWaybillsBox == null) {
      throw Exception(
        "Created Waybills Func not initialized. Call await CreatedWaybillsFunc.instance.init() first.",
      );
    }
    return _createdWaybillsBox!;
  }

  List<CreatedWaybills> getWaybills() {
    List<CreatedWaybills> waybills =
        createdWaybillsBox.values.toList();
    waybills.sort(
      (a, b) => a.waybill.createdAt!.compareTo(
        b.waybill.createdAt!,
      ),
    );
    return waybills;
  }

  Future<int> insertAllWaybills(
    List<CreatedWaybills> createdWaybills,
  ) async {
    try {
      for (var waybills in createdWaybills) {
        await createdWaybillsBox.put(
          waybills.waybill.uuid,
          waybills,
        );
      }
      await mainLocalLog(
        "Offline Created Waybills inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Waybills insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createWaybills(
    CreatedWaybills createdWaybills,
  ) async {
    try {
      await createdWaybillsBox.put(
        createdWaybills.waybill.uuid,
        createdWaybills,
      );
      await mainLocalLog(
        'Offline Created Waybills inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Waybills insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCreatedWaybills(
    CreatedWaybills createdWaybills,
  ) async {
    try {
      await createdWaybillsBox.put(
        createdWaybills.waybill.uuid,
        createdWaybills,
      );
      await mainLocalLog(
        'Offline Created Waybills Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Waybills Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteWaybill(String uuid) async {
    try {
      await mainLocalLog(
        createdWaybillsBox.containsKey(uuid).toString(),
      );
      await createdWaybillsBox.delete(uuid);
      await mainLocalLog('Created Waybill Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Waybill Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearWaybills() async {
    try {
      await createdWaybillsBox.clear();
      await mainLocalLog('All Created Waybills cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Waybills ❌: $e',
      );
      return 0;
    }
  }
}
