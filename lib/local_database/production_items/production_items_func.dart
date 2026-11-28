import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/created/created_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/deleted/deleted_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/updated/updated_production_items_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
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
      safeRegisterAdapter(ProductionItemAdapter());
      productionItemsBox =
          await openBoxSafely<ProductionItem>(
            productionItemsBoxName,
          );
      try {
        await CreatedProductionItemsFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing CreatedProductionItemsFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
      try {
        await DeletedProductionItemsFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing DeletedProductionItemsFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
      try {
        await UpdatedProductionItemsFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing UpdatedProductionItemsFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
      try {
        await ProductionItemsQuantityUpdateFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing ProductionItemsQuantityUpdateFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
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
    try {
      List<ProductionItem> productionItems =
          productionItemsBox.values.toList();
      productionItems.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
      return productionItems;
    } catch (e, s) {
      mainLocalLog(
        'Error reading production items: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
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
      // Lets the LAN server drop deltas for it (not "not held yet").
      await LanDeletedItemsFunc().add('production_items', uuid);
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
        ProductionItemsQuantityUpdateFunc()
            .getProductionItemsQuantitiesUpdate()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
