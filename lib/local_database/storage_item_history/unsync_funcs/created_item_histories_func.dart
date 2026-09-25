import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_item_history/unsynced/created_storage_item_history.dart';
import 'package:stockall/main.dart';

class CreatedStorageItemHistoriesFunc {
  static final CreatedStorageItemHistoriesFunc instance =
      CreatedStorageItemHistoriesFunc._internal();
  factory CreatedStorageItemHistoriesFunc() => instance;
  CreatedStorageItemHistoriesFunc._internal();

  Box<CreatedStorageItemHistory>?
  _createdStorageItemHistoriesBox;
  final String createdStorageItemHistoriesBoxName =
      'createdStorageItemHistoriesBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedStorageItemHistoryAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedStorageItemHistoryAdapter(),
      );
      await mainLocalLog(
        'Created Storage Item History Class Adapter registered ✅',
      );
    }

    if (!Hive.isBoxOpen(
      createdStorageItemHistoriesBoxName,
    )) {
      _createdStorageItemHistoriesBox =
          await Hive.openBox<CreatedStorageItemHistory>(
            createdStorageItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Storage Item Histories Box opened ✅',
      );
    } else {
      _createdStorageItemHistoriesBox =
          Hive.box<CreatedStorageItemHistory>(
            createdStorageItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Storage Item Histories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedStorageItemHistory>
  get createdStorageItemHistoriesBox {
    if (_createdStorageItemHistoriesBox == null) {
      throw Exception(
        "Created Storage Item History Func not initialized. Call await Created Storage Item History Func.instance.init() first.",
      );
    }
    return _createdStorageItemHistoriesBox!;
  }

  List<CreatedStorageItemHistory>
  getCreatedStorageItemHistoriess() {
    return createdStorageItemHistoriesBox.values.toList();
  }

  Future<int> insertAllCreatedStorageItemHistories(
    List<CreatedStorageItemHistory>
    createdStorageItemHistories,
  ) async {
    try {
      for (var history in createdStorageItemHistories) {
        await createdStorageItemHistoriesBox.put(
          history.storageItemHistory.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Created Storage Item Histories inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Storage Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createStorageItemHistory(
    CreatedStorageItemHistory createdStorageItemHistory,
  ) async {
    try {
      await createdStorageItemHistoriesBox.put(
        createdStorageItemHistory.storageItemHistory.uuid,
        createdStorageItemHistory,
      );
      await mainLocalLog(
        'Offline Created Storage Item Histories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Storage Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearStorageItemHistory() async {
    try {
      await createdStorageItemHistoriesBox.clear();
      await mainLocalLog(
        'All Created Storage Item History cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Storage Item History ❌: $e',
      );
      return 0;
    }
  }
}
