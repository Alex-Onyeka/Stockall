import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/local_database/inventory_updates/unsync_funcs/created_inventory_updates_func.dart';
import 'package:stockall/main.dart';

class InventoryUpdatesFunc {
  static final InventoryUpdatesFunc instance =
      InventoryUpdatesFunc._internal();
  factory InventoryUpdatesFunc() => instance;
  InventoryUpdatesFunc._internal();
  late Box<TempInventoryUpdateClass> inventoryUpdatesBox;
  final String inventoryUpdatesBoxName =
      'inventoryUpdatesBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempInventoryUpdateClassAdapter());
    inventoryUpdatesBox = await Hive.openBox(
      inventoryUpdatesBoxName,
    );
    await CreatedInventoryUpdatesFunc().init();
    await mainLocalLog(
      'Inventory Updates  Box Initialized',
    );
  }

  List<TempInventoryUpdateClass> getInventoryUpdatess() {
    List<TempInventoryUpdateClass> inventoryUpdates =
        inventoryUpdatesBox.values.toList();
    inventoryUpdates.sort(
      (a, b) => a.createdAt!.compareTo(b.createdAt!),
    );
    return inventoryUpdates;
  }

  Future<int> insertAllInventoryUpdates(
    List<TempInventoryUpdateClass> inventoryUpdates,
  ) async {
    await clearInventoryUpdates();
    try {
      for (var update in inventoryUpdates) {
        await inventoryUpdatesBox.put(update.uuid, update);
      }
      await mainLocalLog(
        "Offline Inventory Updates  inserted: ${inventoryUpdates.length}",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Inventory Updates  Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createInventoryUpdates(
    TempInventoryUpdateClass inventoryUpdates,
  ) async {
    try {
      await inventoryUpdatesBox.put(
        inventoryUpdates.uuid,
        inventoryUpdates,
      );
      await mainLocalLog(
        'Offline Inventory Updates inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Inventory Updates Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearInventoryUpdates() async {
    try {
      if (inventoryUpdatesBox.values.isNotEmpty) {
        await inventoryUpdatesBox.clear();
        await mainLocalLog(
          'Offline InventoryU pdates  Cleared',
        );
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline InventoryUpdates  Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedInventoryUpdatesFunc()
            .getCreatedInventoryUpdatess()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
