import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/local_database/productions/unsync_funcs/created/created_production_record_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/deleted/deleted_production_records_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/updated/updated_production_records_func.dart';
import 'package:stockall/main.dart';

class ProductionRecordsFunc {
  static final ProductionRecordsFunc instance =
      ProductionRecordsFunc._internal();
  factory ProductionRecordsFunc() => instance;
  ProductionRecordsFunc._internal();
  late Box<ProductionRecord> productionRecordsBox;
  final String productionRecordsBoxName =
      'productionRecordsBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(
      ProductionRecordMaterialsAdapter(),
    );
    safeRegisterAdapter(ProductionRecordAdapter());
    productionRecordsBox = await openBoxSafely<ProductionRecord>(
      productionRecordsBoxName,
    );
    try {
      await CreatedProductionRecordsFunc().init();
    } catch (e, s) {
      await mainLocalLog('Error initializing CreatedProductionRecordsFunc: $e', error: e, stackTrace: s);
    }
    try {
      await DeletedProductionRecordsFunc().init();
    } catch (e, s) {
      await mainLocalLog('Error initializing DeletedProductionRecordsFunc: $e', error: e, stackTrace: s);
    }
    try {
      await UpdatedProductionRecordsFunc().init();
    } catch (e, s) {
      await mainLocalLog('Error initializing UpdatedProductionRecordsFunc: $e', error: e, stackTrace: s);
    }
    await mainLocalLog(
      'Production Records Box Initialized',
    );
  }

  List<ProductionRecord> getProductionRecords() {
    try {
      List<ProductionRecord> productionRecords =
          productionRecordsBox.values.toList();
      productionRecords.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)),
      );
      return productionRecords;
    } catch (e, s) {
      mainLocalLog('Error reading production records: $e', error: e, stackTrace: s);
      return [];
    }
  }

  Future<int> insertAllProductionRecords(
    List<ProductionRecord> productionRecords,
  ) async {
    await clearProductionRecords();
    try {
      for (var productionRecord in productionRecords) {
        await productionRecordsBox.put(
          productionRecord.uuid,
          productionRecord,
        );
      }
      await mainLocalLog(
        'Offline Production Records Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Records Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createProductionRecord(
    ProductionRecord productionRecords,
  ) async {
    try {
      await productionRecordsBox.put(
        productionRecords.uuid,
        productionRecords,
      );
      await mainLocalLog(
        'Offline Production Records Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Records Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateProductionRecord(
    ProductionRecord productionRecords,
  ) async {
    try {
      await productionRecordsBox.put(
        productionRecords.uuid,
        productionRecords,
      );
      await mainLocalLog(
        'Offline Production Records Updated',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Records Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteProductionRecord(String uuid) async {
    try {
      await productionRecordsBox.delete(uuid);
      await mainLocalLog(
        'Offline Production Records Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductionRecords() async {
    try {
      await productionRecordsBox.clear();
      await mainLocalLog(
        'Offline ProductionRecords Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Production Records Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedProductionRecordsFunc()
            .getProductions()
            .isEmpty &&
        UpdatedProductionRecordsFunc()
            .getProductionIds()
            .isEmpty &&
        DeletedProductionRecordsFunc()
            .getProductionIds()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
