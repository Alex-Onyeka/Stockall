import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/main.dart';

class MaterialsQuantityUpdateFunc {
  static final MaterialsQuantityUpdateFunc instance =
      MaterialsQuantityUpdateFunc._internal();
  factory MaterialsQuantityUpdateFunc() => instance;
  MaterialsQuantityUpdateFunc._internal();

  Box<MaterialQuantityUpdate>? _materialsQuantityUpdateBox;
  final String materialsQuantityUpdateBoxName =
      'materialsQuantityUpdateBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      MaterialQuantityUpdateAdapter().typeId,
    )) {
      Hive.registerAdapter(
        MaterialQuantityUpdateAdapter(),
      );
      await mainLocalLog(
        'Materials Quantity Update Adapter registered ✅',
      );
    }

    _materialsQuantityUpdateBox = await openBoxSafely<MaterialQuantityUpdate>(materialsQuantityUpdateBoxName);
  }

  /// Safe getter for the box
  Box<MaterialQuantityUpdate>
  get materialsQuantityUpdateBox {
    if (_materialsQuantityUpdateBox == null) {
      throw Exception(
        " Materials Quantity Update Func not initialized. Call await Materials Materials Quantity Update Func.instance.init() first.",
      );
    }
    return _materialsQuantityUpdateBox!;
  }

  List<MaterialQuantityUpdate>
  getMaterialsQuantitiesUpdate() {
    return materialsQuantityUpdateBox.values.toList();
  }

  Future<int> createMaterialsQuantityUpdate(
    MaterialQuantityUpdate materialsQuantityUpdate,
  ) async {
    try {
      final existingLogs = getMaterialsQuantitiesUpdate()
          .where(
            (item) =>
                item.materialUuid ==
                    materialsQuantityUpdate.materialUuid &&
                // Never into an entry already sent: see SentEntriesFunc.
                !SentEntriesFunc().isSent(
                  materialsQuantityUpdateBoxName,
                  item.uuid,
                ),
          );

      if (existingLogs.isEmpty) {
        await materialsQuantityUpdateBox.put(
          materialsQuantityUpdate.uuid,
          materialsQuantityUpdate,
        );

        await mainLocalLog(
          'Offline Materials Quantity Update inserted successfully ✅',
        );
      } else {
        final existing = existingLogs.first;

        // Convert both values to signed numbers
        final double existingValue =
            existing.isIncrement
                ? existing.quantity
                : -existing.quantity;

        final double incomingValue =
            materialsQuantityUpdate.isIncrement
                ? materialsQuantityUpdate.quantity
                : -materialsQuantityUpdate.quantity;

        // Calculate the net value
        final double total = existingValue + incomingValue;

        // Convert back to absolute quantity + direction
        existing.quantity = total.abs();
        existing.isIncrement = total >= 0;

        // Save to Hive
        await materialsQuantityUpdateBox.put(
          existing.uuid,
          existing,
        );

        await mainLocalLog(
          'Offline Materials Quantity Update merged successfully ✅',
        );
      }

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Quantity Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteMaterialsQuantityUpdate({
    required String uuid,
  }) async {
    try {
      await materialsQuantityUpdateBox.delete(uuid);
      await mainLocalLog(
        'Materials Quantity Update Deleted ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Materials Quantity Update ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearMaterialsQuantitiesUpdate() async {
    try {
      await materialsQuantityUpdateBox.clear();
      await mainLocalLog(
        'All Materials Quantity Update cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Materials Quantity Update ❌: $e',
      );
      return 0;
    }
  }
}
