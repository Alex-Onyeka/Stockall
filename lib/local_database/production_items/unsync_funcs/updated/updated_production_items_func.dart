import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/updated/updated_production_item.dart';
import 'package:stockall/main.dart';

class UpdatedProductionItemsFunc {
  static final UpdatedProductionItemsFunc instance =
      UpdatedProductionItemsFunc._internal();
  factory UpdatedProductionItemsFunc() => instance;
  UpdatedProductionItemsFunc._internal();

  Box<UpdatedProductionItem>? _updatedProductionItemsBox;
  final String updatedProductionItemsBoxName =
      'updatedProductionItemsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      UpdatedProductionItemAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedProductionItemAdapter());
      await mainLocalLog(
        'Updated Production Item  Adapter registered ✅',
      );
    }

    try {
      await _openBox();
    } catch (e, s) {
      await mainLocalLog(
        'Failed to open Updated Production Item  Box. Deleting and recreating...',
        error: e,
        stackTrace: s,
      );

      await Hive.deleteBoxFromDisk(
        updatedProductionItemsBoxName,
      );

      // Try exactly one more time
      await _openBox();
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(updatedProductionItemsBoxName)) {
      _updatedProductionItemsBox =
          await Hive.openBox<UpdatedProductionItem>(
            updatedProductionItemsBoxName,
          );
      await mainLocalLog(
        'Updated Production Item  Box opened ✅',
      );
    } else {
      _updatedProductionItemsBox =
          Hive.box<UpdatedProductionItem>(
            updatedProductionItemsBoxName,
          );
      await mainLocalLog(
        'Updated Production Item  Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedProductionItem> get updatedProductionItemsBox {
    if (_updatedProductionItemsBox == null) {
      throw Exception(
        "Updated Production Item  Func not initialized. Call await updated Production Item  Func.instance.init() first.",
      );
    }
    return _updatedProductionItemsBox!;
  }

  List<UpdatedProductionItem> getProductionItems() {
    return updatedProductionItemsBox.values.toList();
  }

  Future<int> createUpdatedProductionItem(
    UpdatedProductionItem updatedProductionItem,
  ) async {
    try {
      updatedProductionItem
          .productionItem
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedProductionItemsBox.put(
        updatedProductionItem.productionItem.uuid,
        updatedProductionItem,
      );
      await mainLocalLog(
        'Offline updated Production Item inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Production Item insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedProductionItem(
    UpdatedProductionItem updatedProductionItem,
  ) async {
    try {
      updatedProductionItem
          .productionItem
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedProductionItemsBox.put(
        updatedProductionItem.productionItem.uuid,
        updatedProductionItem,
      );
      await mainLocalLog(
        'Offline updated Production Item inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Production Item insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedProductionItem(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        updatedProductionItemsBox
            .containsKey(uuid)
            .toString(),
      );
      await updatedProductionItemsBox.delete(uuid);
      await mainLocalLog('Updated Production Item Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Production Item Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearupdatedProductionItems() async {
    try {
      await updatedProductionItemsBox.clear();
      await mainLocalLog(
        'All updated Production Item  cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Production Item  ❌: $e',
      );
      return 0;
    }
  }
}
