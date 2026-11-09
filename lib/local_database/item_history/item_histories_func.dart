import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/local_database/item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/main.dart';

class ItemHistoriesFunc {
  static final ItemHistoriesFunc instance =
      ItemHistoriesFunc._internal();
  factory ItemHistoriesFunc() => instance;
  ItemHistoriesFunc._internal();
  late Box<ItemHistory> itemHistoryBox;
  final String itemHistoryBoxName =
      'itemHistoryBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(ItemHistoryAdapter());
    itemHistoryBox = await openBoxSafely<ItemHistory>(
      itemHistoryBoxName,
    );
    try {
      await CreatedItemHistoriesFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CreatedItemHistoriesFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    await mainLocalLog('Item History Box Initialized');
  }

  List<ItemHistory> getItemHistories() {
    try {
      List<ItemHistory> itemHistory =
          itemHistoryBox.values.toList();
      itemHistory.sort(
        (a, b) => (a.createdAt ?? DateTime(2000)).compareTo(
          b.createdAt ?? DateTime(2000),
        ),
      );
      return itemHistory;
    } catch (e, s) {
      mainLocalLog(
        'Error reading item histories: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<int> insertAllItemHistories(
    List<ItemHistory> itemHistory, {
    bool clearExisting = false,
  }) async {
    if (clearExisting) {
      await clearItemHistories();
    }
    try {
      for (var history in itemHistory) {
        await itemHistoryBox.put(history.uuid, history);
      }
      await mainLocalLog(
        "Offline Item History  inserted: ${itemHistory.length}",
      );
      await mainLocalLog(
        getItemHistories().length.toString(),
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Item History  Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createItemHistories(
    ItemHistory itemHistory,
  ) async {
    try {
      await itemHistoryBox.put(
        itemHistory.uuid,
        itemHistory,
      );
      await mainLocalLog(
        'Offline Item History inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Item History Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearItemHistories() async {
    try {
      if (itemHistoryBox.values.isNotEmpty) {
        await itemHistoryBox.clear();
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
    if (CreatedItemHistoriesFunc()
            .getCreatedItemHistoriess()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
