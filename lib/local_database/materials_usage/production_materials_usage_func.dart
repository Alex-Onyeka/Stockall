import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/created/created_production_materials_usage_func.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/deleted/deleted_production_materials_usage_func.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/updated/updated_production_materials_usage_func.dart';
import 'package:stockall/main.dart';

class ProductionMaterialsUsageFunc {
  static final ProductionMaterialsUsageFunc instance =
      ProductionMaterialsUsageFunc._internal();
  factory ProductionMaterialsUsageFunc() => instance;
  ProductionMaterialsUsageFunc._internal();
  late Box<ProductionMaterialsUsage>
  productionMaterialsUsageBox;
  final String productionMaterialsUsageBoxName =
      'productionMaterialsUsageBoxStockall';

  Future<void> init() async {
    await Hive.deleteBoxFromDisk(
      productionMaterialsUsageBoxName,
    );
    Hive.registerAdapter(ProductionMaterialsUsageAdapter());
    productionMaterialsUsageBox = await Hive.openBox(
      productionMaterialsUsageBoxName,
    );
    await CreatedProductionMaterialsUsageFunc().init();
    await DeletedProductionMaterialsUsageFunc().init();
    await UpdatedProductionMaterialsUsageFunc().init();
    await mainLocalLog(
      'Production Materials Usage Box Initialized',
    );
  }

  List<ProductionMaterialsUsage>
  getProductionMaterialsUsages() {
    List<ProductionMaterialsUsage>
    productionMaterialsUsage =
        productionMaterialsUsageBox.values.toList();
    productionMaterialsUsage.sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    return productionMaterialsUsage;
  }

  Future<int> insertAllProductionMaterialsUsages(
    List<ProductionMaterialsUsage> productionMaterialsUsage,
  ) async {
    await clearProductionMaterialsUsages();
    try {
      for (var rec in productionMaterialsUsage) {
        await productionMaterialsUsageBox.put(
          rec.uuid,
          rec,
        );
      }
      await mainLocalLog(
        'Offline Production Materials Usage Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Materials Usage Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createProductionMaterialsUsage(
    ProductionMaterialsUsage purchase,
  ) async {
    try {
      await productionMaterialsUsageBox.put(
        purchase.uuid,
        purchase,
      );
      await mainLocalLog(
        'Offline Production Materials Usage Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Materials Usage Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteProductionMaterialsUsage(
    String uuid,
  ) async {
    try {
      await productionMaterialsUsageBox.delete(uuid);
      await mainLocalLog(
        'Offline Production Materials Usage Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductionMaterialsUsages() async {
    try {
      await productionMaterialsUsageBox.clear();
      await mainLocalLog(
        'Offline Production Materials Usages Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Materials Usage Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedProductionMaterialsUsageFunc()
            .getProductionMaterialsUsage()
            .isEmpty &&
        UpdatedProductionMaterialsUsageFunc()
            .getProductionMaterialsUsageIds()
            .isEmpty &&
        DeletedProductionMaterialsUsageFunc()
            .getDeletedProductionMaterialsUsageIds()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
