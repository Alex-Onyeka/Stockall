import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/local_database/storage_item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/main.dart';

class StorageItemHistoriesFunc {
  static final StorageItemHistoriesFunc instance =
      StorageItemHistoriesFunc._internal();
  factory StorageItemHistoriesFunc() => instance;
  StorageItemHistoriesFunc._internal();
  late Box<StorageItemHistory> storageItemHistoryBox;
  final String storageItemHistoryBoxName =
      'storageItemHistoryBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(StorageItemHistoryAdapter().typeId)) {
      Hive.registerAdapter(StorageItemHistoryAdapter());
    }
    storageItemHistoryBox = await openBoxSafely<StorageItemHistory>(
      storageItemHistoryBoxName,
    );
    await CreatedStorageItemHistoriesFunc().init();
    await mainLocalLog(
      'Storage Item History Box Initialized',
    );
  }

  List<StorageItemHistory> getStorageItemHistories() {
    List<StorageItemHistory> storageItemHistory =
        storageItemHistoryBox.values.toList();
    storageItemHistory.sort(
      (a, b) => a.createdAt!.compareTo(b.createdAt!),
    );
    return storageItemHistory;
  }

  Future<int> insertAllStorageItemHistories(
    List<StorageItemHistory> storageItemHistory,
  ) async {
    await clearStorageItemHistories();
    try {
      for (var history in storageItemHistory) {
        await storageItemHistoryBox.put(
          history.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Storage Item History  inserted: ${storageItemHistory.length}",
      );
      await mainLocalLog(
        getStorageItemHistories().length.toString(),
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Item History  Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createStorageItemHistories(
    StorageItemHistory storageItemHistory,
  ) async {
    try {
      await storageItemHistoryBox.put(
        storageItemHistory.uuid,
        storageItemHistory,
      );
      await mainLocalLog(
        'Offline Storage Item History inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Item History Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearStorageItemHistories() async {
    try {
      if (storageItemHistoryBox.values.isNotEmpty) {
        await storageItemHistoryBox.clear();
        await mainLocalLog(
          'Offline Item Histories  Cleared',
        );
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Item Historie  Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedStorageItemHistoriesFunc()
            .getCreatedStorageItemHistoriess()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
