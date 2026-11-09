import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/updated/updated_production_record.dart';
import 'package:stockall/main.dart';

class UpdatedProductionRecordsFunc {
  static final UpdatedProductionRecordsFunc instance =
      UpdatedProductionRecordsFunc._internal();
  factory UpdatedProductionRecordsFunc() => instance;
  UpdatedProductionRecordsFunc._internal();

  Box<UpdatedProductionRecord>?
  _updatedProductionRecordsBox;
  final String updatedProductionRecordsBoxName =
      'updatedProductionRecordsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedProductionRecordAdapter().typeId,
    )) {
      Hive.registerAdapter(
        UpdatedProductionRecordAdapter(),
      );
      await mainLocalLog(
        'Updated Production Records Records Adapter registered ✅',
      );
    }

_updatedProductionRecordsBox = await openBoxSafely<UpdatedProductionRecord>(updatedProductionRecordsBoxName);
  }

  /// Safe getter for the box
  Box<UpdatedProductionRecord>
  get updatedProductionRecordsBox {
    if (_updatedProductionRecordsBox == null) {
      throw Exception(
        "Updated Production Records Records Func not initialized. Call await updated Productions Func.instance.init() first.",
      );
    }
    return _updatedProductionRecordsBox!;
  }

  List<UpdatedProductionRecord> getProductionIds() {
    return updatedProductionRecordsBox.values.toList();
  }

  Future<int> createUpdatedProductionRecords(
    UpdatedProductionRecord updatedProduction,
  ) async {
    try {
      updatedProductionRecordsBox.add(
        UpdatedProductionRecord(
          updatedProductionRecord:
              updatedProduction.updatedProductionRecord,
        ),
      );
      await mainLocalLog(
        'Offline Updated Production Records inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Production Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedProductionRecords(
    UpdatedProductionRecord updatedProduction,
  ) async {
    try {
      updatedProductionRecordsBox.add(
        UpdatedProductionRecord(
          updatedProductionRecord:
              updatedProduction.updatedProductionRecord,
        ),
      );
      await mainLocalLog(
        'Offline Updated Production Records Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Production Records Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedProductionRecords(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        updatedProductionRecordsBox
            .containsKey(uuid)
            .toString(),
      );
      await updatedProductionRecordsBox.delete(uuid);
      await mainLocalLog(
        'Updated Production Records Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Production Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedProductionRecordsRecord() async {
    try {
      await updatedProductionRecordsBox.clear();
      await mainLocalLog(
        'All updated Productions cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Productions ❌: $e',
      );
      return 0;
    }
  }
}
