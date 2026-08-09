import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/created_productions/created_production_record.dart';
import 'package:stockall/main.dart';

class CreatedProductionRecordsFunc {
  static final CreatedProductionRecordsFunc instance =
      CreatedProductionRecordsFunc._internal();
  factory CreatedProductionRecordsFunc() => instance;
  CreatedProductionRecordsFunc._internal();

  Box<CreatedProductionRecord>?
  _createdProductionRecordsBox;
  final String createdProductionRecordsBoxName =
      'createdProductionRecordsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedProductionRecordAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedProductionRecordAdapter(),
      );
      await mainLocalLog(
        'Created Production Records Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdProductionRecordsBoxName)) {
      _createdProductionRecordsBox =
          await Hive.openBox<CreatedProductionRecord>(
            createdProductionRecordsBoxName,
          );
      await mainLocalLog(
        'Created Production Records Box opened ✅',
      );
    } else {
      _createdProductionRecordsBox =
          Hive.box<CreatedProductionRecord>(
            createdProductionRecordsBoxName,
          );
      await mainLocalLog(
        'Created Production Records Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedProductionRecord>
  get createdProductionRecordsBox {
    if (_createdProductionRecordsBox == null) {
      throw Exception(
        "Created Production Records Func not initialized. Call await CreatedProductionRecordsFunc.instance.init() first.",
      );
    }
    return _createdProductionRecordsBox!;
  }

  List<CreatedProductionRecord> getProductions() {
    List<CreatedProductionRecord> productions =
        createdProductionRecordsBox.values.toList();
    productions.sort(
      (a, b) => a.createdProductionRecord.createdAt!
          .compareTo(b.createdProductionRecord.createdAt!),
    );
    return productions;
  }

  Future<int> insertAllProductions(
    List<CreatedProductionRecord> createdProductionRecords,
  ) async {
    try {
      for (var productions in createdProductionRecords) {
        await createdProductionRecordsBox.put(
          productions.createdProductionRecord.uuid,
          productions,
        );
      }
      await mainLocalLog(
        "Offline Created Production Records inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createProductions(
    CreatedProductionRecord createdProductionRecords,
  ) async {
    try {
      await createdProductionRecordsBox.put(
        createdProductionRecords
            .createdProductionRecord
            .uuid,
        createdProductionRecords,
      );
      await mainLocalLog(
        'Offline Created Production Records inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCreatedProductionRecord(
    CreatedProductionRecord createdProductionRecords,
  ) async {
    try {
      await createdProductionRecordsBox.put(
        createdProductionRecords
            .createdProductionRecord
            .uuid,
        createdProductionRecords,
      );
      await mainLocalLog(
        'Offline Created Production Records Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Records Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteProduction(String uuid) async {
    try {
      await mainLocalLog(
        createdProductionRecordsBox
            .containsKey(uuid)
            .toString(),
      );
      await createdProductionRecordsBox.delete(uuid);
      await mainLocalLog('Created Production Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Production Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductions() async {
    try {
      await createdProductionRecordsBox.clear();
      await mainLocalLog(
        'All Created Production Records cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Production Records ❌: $e',
      );
      return 0;
    }
  }
}
