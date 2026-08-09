import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/unsynced/created_production_item_history.dart';
import 'package:stockall/main.dart';

class CreatedProductionItemHistoriesFunc {
  static final CreatedProductionItemHistoriesFunc instance =
      CreatedProductionItemHistoriesFunc._internal();
  factory CreatedProductionItemHistoriesFunc() => instance;
  CreatedProductionItemHistoriesFunc._internal();

  Box<CreatedProductionItemHistory>?
  _createdProductionItemHistoriesBox;
  final String createdProductionItemHistoriesBoxName =
      'createdProductionItemHistoriesBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedProductionItemHistoryAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedProductionItemHistoryAdapter(),
      );
      await mainLocalLog(
        'Created Production Production Item History Class Adapter registered ✅',
      );
    }

    if (!Hive.isBoxOpen(
      createdProductionItemHistoriesBoxName,
    )) {
      _createdProductionItemHistoriesBox =
          await Hive.openBox<CreatedProductionItemHistory>(
            createdProductionItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Production Item Histories Box opened ✅',
      );
    } else {
      _createdProductionItemHistoriesBox =
          Hive.box<CreatedProductionItemHistory>(
            createdProductionItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Production Item Histories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedProductionItemHistory>
  get createdProductionItemHistoriesBox {
    if (_createdProductionItemHistoriesBox == null) {
      throw Exception(
        "Created Production Production Item History Func not initialized. Call await Created Production Production Item History Func.instance.init() first.",
      );
    }
    return _createdProductionItemHistoriesBox!;
  }

  List<CreatedProductionItemHistory>
  getCreatedProductionItemHistoriess() {
    return createdProductionItemHistoriesBox.values
        .toList();
  }

  Future<int> insertAllCreatedProductionItemHistories(
    List<CreatedProductionItemHistory>
    createdProductionItemHistories,
  ) async {
    try {
      for (var history in createdProductionItemHistories) {
        await createdProductionItemHistoriesBox.put(
          history.productionItemHistory.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Created Production Item Histories inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createProductionItemHistory(
    CreatedProductionItemHistory
    createdProductionItemHistory,
  ) async {
    try {
      await createdProductionItemHistoriesBox.put(
        createdProductionItemHistory
            .productionItemHistory
            .uuid,
        createdProductionItemHistory,
      );
      await mainLocalLog(
        'Offline Created Production Item Histories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearProductionItemHistory() async {
    try {
      await createdProductionItemHistoriesBox.clear();
      await mainLocalLog(
        'All Created Production Production Item History cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Production Production Item History ❌: $e',
      );
      return 0;
    }
  }
}
