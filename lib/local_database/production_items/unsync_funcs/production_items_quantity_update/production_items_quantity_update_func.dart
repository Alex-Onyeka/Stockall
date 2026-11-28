import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/main.dart';

class ProductionItemsQuantityUpdateFunc {
  static final ProductionItemsQuantityUpdateFunc instance =
      ProductionItemsQuantityUpdateFunc._internal();
  factory ProductionItemsQuantityUpdateFunc() => instance;
  ProductionItemsQuantityUpdateFunc._internal();

  Box<ProductionItemQuantityUpdate>?
  _productionItemsQuantityUpdateBox;
  final String productionItemsQuantityUpdateBoxName =
      'productionItemsQuantityUpdateBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      ProductionItemQuantityUpdateAdapter().typeId,
    )) {
      Hive.registerAdapter(
        ProductionItemQuantityUpdateAdapter(),
      );
      await mainLocalLog(
        'Production Items Quantity Update Adapter registered ✅',
      );
    }

    _productionItemsQuantityUpdateBox = await openBoxSafely<ProductionItemQuantityUpdate>(productionItemsQuantityUpdateBoxName);
  }

  /// Safe getter for the box
  Box<ProductionItemQuantityUpdate>
  get productionItemsQuantityUpdateBox {
    if (_productionItemsQuantityUpdateBox == null) {
      throw Exception(
        " Production Items Quantity Update Func not initialized. Call await Production Items Production Items Quantity Update Func.instance.init() first.",
      );
    }
    return _productionItemsQuantityUpdateBox!;
  }

  List<ProductionItemQuantityUpdate>
  getProductionItemsQuantitiesUpdate() {
    return productionItemsQuantityUpdateBox.values.toList();
  }

  Future<int> createProductionItemsQuantityUpdate(
    ProductionItemQuantityUpdate
    productionItemsQuantityUpdate,
  ) async {
    try {
      final existingLogs =
          getProductionItemsQuantitiesUpdate().where(
            (item) =>
                item.productionItemUuid ==
                    productionItemsQuantityUpdate
                        .productionItemUuid &&
                // Never into an entry already sent: see SentEntriesFunc.
                !SentEntriesFunc().isSent(
                  productionItemsQuantityUpdateBoxName,
                  item.uuid,
                ),
          );

      if (existingLogs.isEmpty) {
        await productionItemsQuantityUpdateBox.put(
          productionItemsQuantityUpdate.uuid,
          productionItemsQuantityUpdate,
        );

        await mainLocalLog(
          'Offline Production Items Quantity Update inserted successfully ✅',
        );
      } else {
        final existing = existingLogs.first;

        // Convert both values to signed numbers
        final double existingValue =
            existing.isIncrement
                ? existing.quantity
                : -existing.quantity;

        final double incomingValue =
            productionItemsQuantityUpdate.isIncrement
                ? productionItemsQuantityUpdate.quantity
                : -productionItemsQuantityUpdate.quantity;

        // Calculate the net value
        final double total = existingValue + incomingValue;

        // Convert back to absolute quantity + direction
        existing.quantity = total.abs();
        existing.isIncrement = total >= 0;

        // Save to Hive
        await productionItemsQuantityUpdateBox.put(
          existing.uuid,
          existing,
        );

        await mainLocalLog(
          'Offline Production Items Quantity Update merged successfully ✅',
        );
      }

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Items Quantity Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteProductionItemsQuantityUpdate({
    required String uuid,
  }) async {
    try {
      await productionItemsQuantityUpdateBox.delete(uuid);
      await mainLocalLog(
        'Production Items Quantity Update Deleted ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Production Items Quantity Update ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearProductionItemsQuantitiesUpdate() async {
    try {
      await productionItemsQuantityUpdateBox.clear();
      await mainLocalLog(
        'All Production Items Quantity Update cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Production Items Quantity Update ❌: $e',
      );
      return 0;
    }
  }
}
