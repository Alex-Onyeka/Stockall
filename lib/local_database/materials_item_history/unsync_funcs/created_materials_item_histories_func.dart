import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/unsynced/created_materials_item_history.dart';
import 'package:stockall/main.dart';

class CreatedMaterialsItemHistoriesFunc {
  static final CreatedMaterialsItemHistoriesFunc instance =
      CreatedMaterialsItemHistoriesFunc._internal();
  factory CreatedMaterialsItemHistoriesFunc() => instance;
  CreatedMaterialsItemHistoriesFunc._internal();

  Box<CreatedMaterialsItemHistory>?
  _createdMaterialsItemHistoriesBox;
  final String createdMaterialsItemHistoriesBoxName =
      'createdMaterialsItemHistoriesBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedMaterialsItemHistoryAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedMaterialsItemHistoryAdapter(),
      );
      await mainLocalLog(
        'Created Created Materials Item History Class Adapter registered ✅',
      );
    }

    if (!Hive.isBoxOpen(
      createdMaterialsItemHistoriesBoxName,
    )) {
      _createdMaterialsItemHistoriesBox =
          await Hive.openBox<CreatedMaterialsItemHistory>(
            createdMaterialsItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Created Materials Item Histories Box opened ✅',
      );
    } else {
      _createdMaterialsItemHistoriesBox =
          Hive.box<CreatedMaterialsItemHistory>(
            createdMaterialsItemHistoriesBoxName,
          );
      await mainLocalLog(
        'Created Created Materials Item Histories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedMaterialsItemHistory>
  get createdMaterialsItemHistoriesBox {
    if (_createdMaterialsItemHistoriesBox == null) {
      throw Exception(
        "Created Created Materials Item History Func not initialized. Call await Created Created Materials Item History Func.instance.init() first.",
      );
    }
    return _createdMaterialsItemHistoriesBox!;
  }

  List<CreatedMaterialsItemHistory>
  getCreatedMaterialsItemHistoriess() {
    return createdMaterialsItemHistoriesBox.values.toList();
  }

  Future<int> insertAllCreatedMaterialsItemHistories(
    List<CreatedMaterialsItemHistory>
    createdMaterialsItemHistories,
  ) async {
    try {
      for (var history in createdMaterialsItemHistories) {
        await createdMaterialsItemHistoriesBox.put(
          history.createdMaterialsItemHistory.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Created Created Materials Item Histories inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Created Materials Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createMaterialsItemHistory(
    CreatedMaterialsItemHistory createdMaterialsItemHistory,
  ) async {
    try {
      await createdMaterialsItemHistoriesBox.put(
        createdMaterialsItemHistory
            .createdMaterialsItemHistory
            .uuid,
        createdMaterialsItemHistory,
      );
      await mainLocalLog(
        'Offline Created Created Materials Item Histories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Created Materials Item Histories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearMaterialsItemHistory() async {
    try {
      await createdMaterialsItemHistoriesBox.clear();
      await mainLocalLog(
        'All Created Created Materials Item History cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Created Materials Item History ❌: $e',
      );
      return 0;
    }
  }
}
