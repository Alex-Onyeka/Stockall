import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionItemsQuantityUpdateProvider
    with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  static final ProductionItemsQuantityUpdateProvider
  _instance =
      ProductionItemsQuantityUpdateProvider._internal();
  factory ProductionItemsQuantityUpdateProvider() =>
      _instance;
  ProductionItemsQuantityUpdateProvider._internal();

  List<ProductionItemQuantityUpdate>
  productionItemsQuantityUpdates = [];

  final String tableName = 'production_items';

  Future<int> createProductionItemQuantityUpdate({
    required ProductionItemQuantityUpdate
    productionItemsQuantityUpdate,
  }) async {
    try {
      productionItemsQuantityUpdate.createdAt =
          DateTime.now();
      productionItemsQuantityUpdate.uuid = uuidGen();
      var res = await ProductionItemsQuantityUpdateFunc()
          .createProductionItemsQuantityUpdate(
            productionItemsQuantityUpdate,
          );
      notifyListeners();
      return res;
    } catch (e) {
      await mainLocalLog(
        'Error ProductionItems Creating Quantity Update: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  Future<void> clearProductionItemQuantityUpdates() async {
    try {
      await ProductionItemsQuantityUpdateFunc()
          .clearProductionItemsQuantitiesUpdate();
      notifyListeners();
    } catch (e) {
      await mainLocalLog('Error Clearing: ${e.toString()}');
    }
  }

  Future<void> productionItemsQuantityUpdateSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (ProductionItemsQuantityUpdateFunc()
              .getProductionItemsQuantitiesUpdate()
              .isNotEmpty &&
          isOnline) {
        final tempProductionItemQuantityUpdates =
            ProductionItemsQuantityUpdateFunc()
                .getProductionItemsQuantitiesUpdate()
                .toList()
                .map((item) {
                  return {
                    "productionItemUuid":
                        item.productionItemUuid,
                    "quantity": item.quantity,
                    "isIncrement": item.isIncrement,
                  };
                })
                .toList();

        await client.rpc(
          'update_production_items_quantities',
          params: {
            'updates': tempProductionItemQuantityUpdates,
          },
        );

        await ProductionItemsQuantityUpdateFunc()
            .clearProductionItemsQuantitiesUpdate();
        await mainLocalLog(
          'Unsynced ProductionItems Quantity Updates Cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch ProductionItems Quantity Updates insert failed ❌: $e',
      );
    }
  }
}
