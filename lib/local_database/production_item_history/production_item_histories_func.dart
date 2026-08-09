import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/local_database/production_item_history/unsync_funcs/created_production_item_histories_func.dart';
import 'package:stockall/main.dart';

class ProductionItemHistoriesFunc {
  static final ProductionItemHistoriesFunc instance =
      ProductionItemHistoriesFunc._internal();
  factory ProductionItemHistoriesFunc() => instance;
  ProductionItemHistoriesFunc._internal();
  late Box<ProductionItemHistory> productionItemHistoryBox;
  final String productionItemHistoryBoxName =
      'productionItemHistoryBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(ProductionItemHistoryAdapter());
    productionItemHistoryBox = await Hive.openBox(
      productionItemHistoryBoxName,
    );
    await CreatedProductionItemHistoriesFunc().init();
    await mainLocalLog(
      'Production Item History Box Initialized',
    );
  }

  List<ProductionItemHistory> getProductionItemHistories() {
    List<ProductionItemHistory> productionItemHistory =
        productionItemHistoryBox.values.toList();
    productionItemHistory.sort(
      (a, b) => a.createdAt!.compareTo(b.createdAt!),
    );
    return productionItemHistory;
  }

  Future<int> insertAllProductionItemHistories(
    List<ProductionItemHistory> productionItemHistory,
  ) async {
    await clearProductionItemHistories();
    try {
      for (var history in productionItemHistory) {
        await productionItemHistoryBox.put(
          history.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Production Item History  inserted: ${productionItemHistory.length}",
      );
      await mainLocalLog(
        getProductionItemHistories().length.toString(),
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Item History  Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createProductionItemHistories(
    ProductionItemHistory productionItemHistory,
  ) async {
    try {
      await productionItemHistoryBox.put(
        productionItemHistory.uuid,
        productionItemHistory,
      );
      await mainLocalLog(
        'Offline Production Item History inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Item History Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductionItemHistories() async {
    try {
      if (productionItemHistoryBox.values.isNotEmpty) {
        await productionItemHistoryBox.clear();
        await mainLocalLog(
          'Offline Production Item Histories  Cleared',
        );
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Production Item Historie  Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedProductionItemHistoriesFunc()
            .getCreatedProductionItemHistoriess()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
