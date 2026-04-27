import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_purchase_record/unsynced/created_item_records/created_item_records.dart';

class CreatedItemPurchaseFunc {
  static final CreatedItemPurchaseFunc instance =
      CreatedItemPurchaseFunc._internal();
  factory CreatedItemPurchaseFunc() => instance;
  CreatedItemPurchaseFunc._internal();

  Box<CreatedItemRecords>? _createdItemPurchaseRecordsBox;
  final String createdItemPurchaseRecordsBoxName =
      'createdItemPurchaseRecordsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedItemRecordsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedItemRecordsAdapter());
      print(
        'Created Item Purchase Records Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      createdItemPurchaseRecordsBoxName,
    )) {
      _createdItemPurchaseRecordsBox =
          await Hive.openBox<CreatedItemRecords>(
            createdItemPurchaseRecordsBoxName,
          );
      print('Created Item Purchase Records Box opened ✅');
    } else {
      _createdItemPurchaseRecordsBox =
          Hive.box<CreatedItemRecords>(
            createdItemPurchaseRecordsBoxName,
          );
      print(
        'Created Item Purchase Records Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedItemRecords>
  get createdItemPurchaseRecordsBox {
    if (_createdItemPurchaseRecordsBox == null) {
      throw Exception(
        "Created Item Purchase Records Func not initialized. Call await CreatedItemPurchaseFunc.instance.init() first.",
      );
    }
    return _createdItemPurchaseRecordsBox!;
  }

  List<CreatedItemRecords> getRecords() {
    List<CreatedItemRecords> records =
        createdItemPurchaseRecordsBox.values.toList();
    records.sort(
      (a, b) =>
          a.record.createdAt.compareTo(b.record.createdAt),
    );
    return records;
  }

  Future<int> insertAllRecords(
    List<CreatedItemRecords> createdItemRecords,
  ) async {
    try {
      for (var records in createdItemRecords) {
        await createdItemPurchaseRecordsBox.put(
          records.record.uuid,
          records,
        );
      }
      print(
        "Offline Created Item Purchase Records inserted ✅",
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Item Purchase Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createRecords(
    CreatedItemRecords createdItemRecords,
  ) async {
    try {
      await createdItemPurchaseRecordsBox.put(
        createdItemRecords.record.uuid,
        createdItemRecords,
      );
      print(
        'Offline Created Item Purchase Records inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Item Purchase Records insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteRecords(String uuid) async {
    try {
      print(
        createdItemPurchaseRecordsBox
            .containsKey(uuid)
            .toString(),
      );
      await createdItemPurchaseRecordsBox.delete(uuid);
      print('Records Deleted');
      return 1;
    } catch (e) {
      print('Records Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearRecords() async {
    try {
      await createdItemPurchaseRecordsBox.clear();
      print('All Created Item Purchase Records cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Created Item Purchase Records ❌: $e',
      );
      return 0;
    }
  }
}
