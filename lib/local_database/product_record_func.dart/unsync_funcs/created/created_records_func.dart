import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_slaes_record/unsynced/created_records/created_records.dart';

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
      print('Created Records Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdRecordsBoxName)) {
      _createdRecordsBox =
          await Hive.openBox<CreatedRecords>(
            createdRecordsBoxName,
          );
      print('Created Records Box opened ✅');
    } else {
      _createdRecordsBox = Hive.box<CreatedRecords>(
        createdRecordsBoxName,
      );
      print('Created Records Box already open, reused ✅');
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
      print("Offline Created Records inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createRecords(
    CreatedRecords createdRecords,
  ) async {
    try {
      await createdRecordsBox.put(
        createdRecords.record.uuid,
        createdRecords,
      );
      print(
        'Offline Created Records inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteRecords(String uuid) async {
    try {
      print(createdRecordsBox.containsKey(uuid).toString());
      await createdRecordsBox.delete(uuid);
      print('Records Deleted');
      return 1;
    } catch (e) {
      print('Records Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearRecords() async {
    try {
      await createdRecordsBox.clear();
      print('All Created Records cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Records ❌: $e');
      return 0;
    }
  }
}
