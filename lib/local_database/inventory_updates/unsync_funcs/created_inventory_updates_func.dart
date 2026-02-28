import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_inventory_updates/unsynced/created_inventory_updates_class.dart';

class CreatedInventoryUpdatesFunc {
  static final CreatedInventoryUpdatesFunc instance =
      CreatedInventoryUpdatesFunc._internal();
  factory CreatedInventoryUpdatesFunc() => instance;
  CreatedInventoryUpdatesFunc._internal();

  Box<CreatedInventoryUpdatesClass>?
  _createdInventoryUpdatesBox;
  final String createdInventoryUpdatesBoxName =
      'createdInventoryUpdatesBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedInventoryUpdatesClassAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedInventoryUpdatesClassAdapter(),
      );
      print(
        'Created Inventory Updates Class Adapter registered ✅',
      );
    }

    if (!Hive.isBoxOpen(createdInventoryUpdatesBoxName)) {
      _createdInventoryUpdatesBox =
          await Hive.openBox<CreatedInventoryUpdatesClass>(
            createdInventoryUpdatesBoxName,
          );
      print('Created Inventory Update Box opened ✅');
    } else {
      _createdInventoryUpdatesBox =
          Hive.box<CreatedInventoryUpdatesClass>(
            createdInventoryUpdatesBoxName,
          );
      print(
        'Created Inventory Update Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedInventoryUpdatesClass>
  get createdInventoryUpdatesBox {
    if (_createdInventoryUpdatesBox == null) {
      throw Exception(
        "Created Inventory Updates Func not initialized. Call await Created Inventory Updates Func.instance.init() first.",
      );
    }
    return _createdInventoryUpdatesBox!;
  }

  List<CreatedInventoryUpdatesClass>
  getCreatedInventoryUpdatess() {
    return createdInventoryUpdatesBox.values.toList();
  }

  Future<int> insertAllCreatedInventoryUpdates(
    List<CreatedInventoryUpdatesClass>
    createdInventoryUpdates,
  ) async {
    try {
      for (var update in createdInventoryUpdates) {
        await createdInventoryUpdatesBox.put(
          update.inventoryUpdate.uuid,
          update,
        );
      }
      print("Offline Created Inventory Update inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Inventory Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createInventoryUpdate(
    CreatedInventoryUpdatesClass createdInventoryUpdates,
  ) async {
    try {
      await createdInventoryUpdatesBox.put(
        createdInventoryUpdates.inventoryUpdate.uuid,
        createdInventoryUpdates,
      );
      print(
        'Offline Created Inventory Update inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Inventory Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearInventoryUpdate() async {
    try {
      await createdInventoryUpdatesBox.clear();
      print('All Created Inventory Updates cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Created Inventory Updates ❌: $e',
      );
      return 0;
    }
  }
}
