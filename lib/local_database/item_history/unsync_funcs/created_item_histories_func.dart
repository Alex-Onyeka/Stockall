import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_history/unsynced/created_item_history.dart';
import 'package:stockall/main.dart';

class CreatedItemHistoriesFunc {
  static final CreatedItemHistoriesFunc instance =
      CreatedItemHistoriesFunc._internal();
  factory CreatedItemHistoriesFunc() => instance;
  CreatedItemHistoriesFunc._internal();

  Box<CreatedItemHistory>? _createdItemHistoriesBox;
  final String createdItemHistoriesBoxName =
      'createdItemHistoriesBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedItemHistoryAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedItemHistoryAdapter());
      await mainLocalLog(
        'Created Item History Class Adapter registered ✅',
      );
    }

    if (!Hive.isBoxOpen(createdItemHistoriesBoxName)) {
      _createdItemHistoriesBox =
          await Hive.openBox<CreatedItemHistory>(
            createdItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Item Histories Box opened ✅',
      );
    } else {
      _createdItemHistoriesBox =
          Hive.box<CreatedItemHistory>(
            createdItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Item Histories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedItemHistory> get createdItemHistoriesBox {
    if (_createdItemHistoriesBox == null) {
      throw Exception(
        "Created Item History Func not initialized. Call await Created Item History Func.instance.init() first.",
      );
    }
    return _createdItemHistoriesBox!;
  }

  List<CreatedItemHistory> getCreatedItemHistoriess() {
    return createdItemHistoriesBox.values.toList();
  }

  Future<int> insertAllCreatedItemHistories(
    List<CreatedItemHistory> createdItemHistories,
  ) async {
    try {
      for (var history in createdItemHistories) {
        await createdItemHistoriesBox.put(
          history.itemHistory.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Created Item Histories inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createItemHistory(
    CreatedItemHistory createdItemHistory,
  ) async {
    try {
      await createdItemHistoriesBox.put(
        createdItemHistory.itemHistory.uuid,
        createdItemHistory,
      );
      await mainLocalLog(
        'Offline Created Item Histories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearItemHistory() async {
    try {
      await createdItemHistoriesBox.clear();
      await mainLocalLog(
        'All Created Item History cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Item History ❌: $e',
      );
      return 0;
    }
  }
}
