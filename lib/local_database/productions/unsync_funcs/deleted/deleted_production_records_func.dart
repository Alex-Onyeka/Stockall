import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/deleted_productions/deleted_production_record.dart';
import 'package:stockall/main.dart';

class DeletedProductionRecordsFunc {
  static final DeletedProductionRecordsFunc instance =
      DeletedProductionRecordsFunc._internal();
  factory DeletedProductionRecordsFunc() => instance;
  DeletedProductionRecordsFunc._internal();

  Box<DeletedProductionRecord>? _deletedProductionRecordBox;
  final String deletedProductionRecordBoxName =
      'deletedProductionRecordBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedProductionRecordAdapter().typeId,
    )) {
      Hive.registerAdapter(
        DeletedProductionRecordAdapter(),
      );
      await mainLocalLog(
        'Deleted Production Records Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedProductionRecordBoxName)) {
      _deletedProductionRecordBox =
          await Hive.openBox<DeletedProductionRecord>(
            deletedProductionRecordBoxName,
          );
      await mainLocalLog(
        'Deleted Production Records Box opened ✅',
      );
    } else {
      _deletedProductionRecordBox =
          Hive.box<DeletedProductionRecord>(
            deletedProductionRecordBoxName,
          );
      await mainLocalLog(
        'Deleted Production Records Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedProductionRecord>
  get deletedProductionRecordBox {
    if (_deletedProductionRecordBox == null) {
      throw Exception(
        "Deleted Production Records Func not initialized. Call await Deleted Production Records Func.instance.init() first.",
      );
    }
    return _deletedProductionRecordBox!;
  }

  List<DeletedProductionRecord> getProductionIds() {
    return deletedProductionRecordBox.values.toList();
  }

  Future<int> insertAllDeletedProductionRecords(
    List<DeletedProductionRecord> deletedProductionRecord,
  ) async {
    try {
      for (var production in deletedProductionRecord) {
        await deletedProductionRecordBox.add(production);
      }
      await mainLocalLog(
        "Offline Deleted Production Records inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Production Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedProductionRecords(
    DeletedProductionRecord deletedProductionRecord,
  ) async {
    try {
      await deletedProductionRecordBox.add(
        deletedProductionRecord,
      );
      await mainLocalLog(
        'Offline Deleted Production Records inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Production Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedProductionRecords(
    String uuid,
  ) async {
    try {
      await deletedProductionRecordBox.delete(uuid);
      await mainLocalLog('Delete Production cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Production Records ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedProductionRecords() async {
    try {
      await deletedProductionRecordBox.clear();
      await mainLocalLog(
        'All Deleted Production Records cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Production Records ❌: $e',
      );
      return 0;
    }
  }
}
