import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/deleted/deleted_production_item.dart';
import 'package:stockall/main.dart';

class DeletedProductionItemsFunc {
  static final DeletedProductionItemsFunc instance =
      DeletedProductionItemsFunc._internal();
  factory DeletedProductionItemsFunc() => instance;
  DeletedProductionItemsFunc._internal();

  Box<DeletedProductionItem>? _deletedProductionItemsBox;
  final String deletedProductionItemsBoxName =
      'deletedProductionItemsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      DeletedProductionItemAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedProductionItemAdapter());
      await mainLocalLog(
        'deletedProductionItemsAdapter registered ✅',
      );
    }

    _deletedProductionItemsBox =
        await openBoxSafely<DeletedProductionItem>(
          deletedProductionItemsBoxName,
        );
  }

  /// Safe getter for the box
  Box<DeletedProductionItem> get deletedProductionItemsBox {
    if (_deletedProductionItemsBox == null) {
      throw Exception(
        "Deleted Production Items Func not initialized. Call await Deleted Production Items Func.instance.init() first.",
      );
    }
    return _deletedProductionItemsBox!;
  }

  List<DeletedProductionItem> getProductionItemIds() {
    return deletedProductionItemsBox.values.toList();
  }

  Future<int> insertAllDeletedProductionItem(
    List<DeletedProductionItem> deletedProductionItems,
  ) async {
    try {
      for (var productionItem in deletedProductionItems) {
        await deletedProductionItemsBox.add(productionItem);
      }
      await mainLocalLog(
        "Offline Deleted Production Items inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Production Items insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedProductionItem(
    DeletedProductionItem deletedProductionItem,
  ) async {
    try {
      await deletedProductionItemsBox.add(
        deletedProductionItem,
      );
      await mainLocalLog(
        'Offline Deleted Production Item inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Production Item insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedProductionItem() async {
    try {
      await deletedProductionItemsBox.clear();
      await mainLocalLog(
        'All Deleted Production Items cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Production Items ❌: $e',
      );
      return 0;
    }
  }
}
