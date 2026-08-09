import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/created/created_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/deleted/deleted_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/updated/updated_production_items_func.dart';
import 'package:stockall/main.dart';

class ProductionItemsFunc {
  static final ProductionItemsFunc instance =
      ProductionItemsFunc._internal();
  factory ProductionItemsFunc() => instance;
  ProductionItemsFunc._internal();
  late Box<ProductionItem> productionItemsBox;
  final String productionItemsBoxName =
      'productionItemsBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(ProductionItemAdapter());
      productionItemsBox = await Hive.openBox(
        productionItemsBoxName,
      );
      await CreatedProductionItemsFunc().init();
      await DeletedProductionItemsFunc().init();
      await UpdatedProductionItemsFunc().init();
      await ProductionItemsQuantityUpdateFunc().init();
      await mainLocalLog('Production Item Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Production Items Func: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<ProductionItem> getProductionItems() {
    List<ProductionItem> productionItems =
        productionItemsBox.values.toList();
    productionItems.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return productionItems;
  }

  ProductionItem? getSingleProductionItem({
    required String uuid,
  }) {
    List<ProductionItem> productionItems =
        productionItemsBox.values
            .where((pro) => pro.uuid == uuid)
            .toList();
    if (productionItems.isNotEmpty) {
      return productionItems.first;
    } else {
      return null;
    }
  }

  Future<int> insertAllProductionItems(
    List<ProductionItem> productionItems,
  ) async {
    await clearProductionItems();
    try {
      for (var productionItem in productionItems) {
        await productionItemsBox.put(
          productionItem.uuid,
          productionItem,
        );
      }
      await mainLocalLog(
        "Offline Production Items inserted: ${productionItems.length}",
      );
      await mainLocalLog(
        getProductionItems().length.toString(),
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Items Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createProductionItem(
    ProductionItem productionItem,
  ) async {
    try {
      await productionItemsBox.put(
        productionItem.uuid,
        productionItem,
      );
      await mainLocalLog(
        'Offline ProductionItem inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline ProductionItem Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateProductionItem(
    ProductionItem productionItem,
  ) async {
    try {
      productionItem.updatedAt = DateTime.now();
      await productionItemsBox.put(
        productionItem.uuid,
        productionItem,
      );
      await mainLocalLog(
        'Offline ProductionItem Update Successful ${productionItem.quantity ?? 0}',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Update Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteProductionItem(String uuid) async {
    try {
      await productionItemsBox.delete(uuid);
      await mainLocalLog(
        'Offline ProductionItem Deleted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline ProductionItem Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductionItems() async {
    try {
      if (productionItemsBox.values.isNotEmpty) {
        await productionItemsBox.clear();
        await mainLocalLog(
          'Offline Production Items Cleared',
        );
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Production Items Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedProductionItemsFunc()
            .getProductionItems()
            .isEmpty &&
        UpdatedProductionItemsFunc()
            .getProductionItems()
            .isEmpty &&
        DeletedProductionItemsFunc()
            .getProductionItemIds()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
