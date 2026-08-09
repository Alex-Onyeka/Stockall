import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/created/created_production_item.dart';
import 'package:stockall/main.dart';

class CreatedProductionItemsFunc {
  static final CreatedProductionItemsFunc instance =
      CreatedProductionItemsFunc._internal();
  factory CreatedProductionItemsFunc() => instance;
  CreatedProductionItemsFunc._internal();

  Box<CreatedProductionItem>? _createdProductionItemsBox;
  final String createdProductionItemsBoxName =
      'createdProductionItemsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(
        CreatedProductionItemAdapter().typeId,
      )) {
        Hive.registerAdapter(
          CreatedProductionItemAdapter(),
        );
        await mainLocalLog(
          'Created Production Items Adapter registered ✅',
        );
      }

      // Open the box only if it isn’t already open
      await _openBox();
    } catch (e, s) {
      await Hive.deleteBoxFromDisk(
        'createdProductionItemsBoxStockall',
      );
      await mainLocalLog(
        'Error Initializing Created Production Items Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
      await _openBox();
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(createdProductionItemsBoxName)) {
      _createdProductionItemsBox =
          await Hive.openBox<CreatedProductionItem>(
            createdProductionItemsBoxName,
          );
      await mainLocalLog(
        'Created Production Items Box opened ✅',
      );
    } else {
      _createdProductionItemsBox =
          Hive.box<CreatedProductionItem>(
            createdProductionItemsBoxName,
          );
      await mainLocalLog(
        'Created Production Items Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedProductionItem> get createdProductionItemsBox {
    if (_createdProductionItemsBox == null) {
      throw Exception(
        "CreatedProductionItemsFunc not initialized. Call await CreatedProductionItemsFunc.instance.init() first.",
      );
    }
    return _createdProductionItemsBox!;
  }

  List<CreatedProductionItem> getProductionItems() {
    return createdProductionItemsBox.values.toList();
  }

  Future<int> insertAllProductionItems(
    List<CreatedProductionItem> createdProductionItems,
  ) async {
    try {
      for (var productionItem in createdProductionItems) {
        await createdProductionItemsBox.put(
          productionItem.productionItem.uuid,
          productionItem,
        );
      }
      await mainLocalLog(
        "Offline Created Production Items inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Items insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createProductionItem(
    CreatedProductionItem createdProductionItem,
  ) async {
    try {
      await createdProductionItemsBox.put(
        createdProductionItem.productionItem.uuid,
        createdProductionItem,
      );
      await mainLocalLog(
        'Offline Created Production Item inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Item insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateProductionItem(
    CreatedProductionItem createdProductionItem,
  ) async {
    try {
      await mainLocalLog(
        createdProductionItemsBox
            .containsKey(
              createdProductionItem.productionItem.uuid,
            )
            .toString(),
      );
      await createdProductionItemsBox.put(
        createdProductionItem.productionItem.uuid,
        createdProductionItem,
      );
      await mainLocalLog(
        'Offline Created Production Item Updated Successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌Offline Created Production Item Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteProductionItem(String uuid) async {
    try {
      await mainLocalLog(
        createdProductionItemsBox
            .containsKey(uuid)
            .toString(),
      );
      await createdProductionItemsBox.delete(uuid);
      await mainLocalLog('Production Item Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Production Item Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductionItems() async {
    try {
      await createdProductionItemsBox.clear();
      await mainLocalLog(
        'All Created Production Items cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Production Items ❌: $e',
      );
      return 0;
    }
  }
}
