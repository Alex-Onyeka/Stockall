import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
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
    safeRegisterAdapter(TempInventoryUpdateClassAdapter());
    inventoryUpdatesBox =
        await openBoxSafely<TempInventoryUpdateClass>(
          inventoryUpdatesBoxName,
        );
    try {
      await CreatedInventoryUpdatesFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CreatedInventoryUpdatesFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    await mainLocalLog(
      'Inventory Updates  Box Initialized',
    );
  }

  List<TempInventoryUpdateClass> getInventoryUpdatess() {
    try {
      List<TempInventoryUpdateClass> inventoryUpdates =
          inventoryUpdatesBox.values.toList();
      inventoryUpdates.sort(
        (a, b) => (a.createdAt ?? DateTime(2000)).compareTo(
          b.createdAt ?? DateTime(2000),
        ),
      );
      return inventoryUpdates;
    } catch (e, s) {
      mainLocalLog(
        'Error reading inventory updates: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
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
          'Offline Inventory Updates  Cleared',
        );
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Inventory Updates  Clear Error: ${e.toString()}',
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
