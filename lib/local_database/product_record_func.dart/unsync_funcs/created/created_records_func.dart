import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_slaes_record/unsynced/created_records/created_records.dart';
import 'package:stockall/main.dart';

class CreatedRecordsFunc {
  static final CreatedRecordsFunc instance =
      CreatedRecordsFunc._internal();
  factory CreatedRecordsFunc() => instance;
  CreatedRecordsFunc._internal();

  Box<CreatedRecords>? _createdRecordsBox;
  final String createdRecordsBoxName =
      'createdRecordsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedRecordsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedRecordsAdapter());
      await mainLocalLog(
        'Created Records Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdRecordsBoxName)) {
      _createdRecordsBox =
          await Hive.openBox<CreatedRecords>(
            createdRecordsBoxName,
          );
      await mainLocalLog('Created Records Box opened ✅');
    } else {
      _createdRecordsBox = Hive.box<CreatedRecords>(
        createdRecordsBoxName,
      );
      await mainLocalLog(
        'Created Records Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedRecords> get createdRecordsBox {
    if (_createdRecordsBox == null) {
      throw Exception(
        "Created Records Func not initialized. Call await CreatedRecordsFunc.instance.init() first.",
      );
    }
    return _createdRecordsBox!;
  }

  List<CreatedRecords> getRecords() {
    List<CreatedRecords> records =
        createdRecordsBox.values.toList();
    records.sort(
      (a, b) =>
          a.record.createdAt.compareTo(b.record.createdAt),
    );
    return records;
  }

  Future<int> insertAllRecords(
    List<CreatedRecords> createdRecords,
  ) async {
    try {
      for (var records in createdRecords) {
        await createdRecordsBox.put(
          records.record.uuid,
          records,
        );
      }
      await mainLocalLog(
        "Offline Created Records inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createRecords(
    CreatedRecords createdRecords,
  ) async {
    // var newDate = createdRecords.record.createdAt.subtract(
    //   Duration(hours: 1),
    // );
    // createdRecords.record.createdAt = newDate;
    try {
      await createdRecordsBox.put(
        createdRecords.record.uuid,
        createdRecords,
      );
      await mainLocalLog(
        'Offline Created Records inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteRecords(String uuid) async {
    try {
      await mainLocalLog(
        createdRecordsBox.containsKey(uuid).toString(),
      );
      await createdRecordsBox.delete(uuid);
      await mainLocalLog('Records Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Records Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearRecords() async {
    try {
      await createdRecordsBox.clear();
      await mainLocalLog('All Created Records cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Records ❌: $e',
      );
      return 0;
    }
  }
}
