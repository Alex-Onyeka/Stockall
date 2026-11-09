import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/local_database/materials_item_history/unsync_funcs/created_materials_item_histories_func.dart';
import 'package:stockall/main.dart';

class MaterialsItemHistoriesFunc {
  static final MaterialsItemHistoriesFunc instance =
      MaterialsItemHistoriesFunc._internal();
  factory MaterialsItemHistoriesFunc() => instance;
  MaterialsItemHistoriesFunc._internal();
  late Box<MaterialsItemHistory> materialsItemHistoryBox;
  final String materialsItemHistoryBoxName =
      'materialsItemHistoryBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(MaterialsItemHistoryAdapter());
    materialsItemHistoryBox =
        await openBoxSafely<MaterialsItemHistory>(
          materialsItemHistoryBoxName,
        );
    try {
      await CreatedMaterialsItemHistoriesFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CreatedMaterialsItemHistoriesFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    await mainLocalLog(
      'Materials Item History Box Initialized',
    );
  }

  List<MaterialsItemHistory> getMaterialsItemHistories() {
    try {
      List<MaterialsItemHistory> materialsItemHistory =
          materialsItemHistoryBox.values.toList();
      materialsItemHistory.sort(
        (a, b) => a.createdAt!.compareTo(b.createdAt!),
      );
      return materialsItemHistory;
    } catch (e, s) {
      mainLocalLog(
        'Error reading materials item histories: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<int> insertAllMaterialsItemHistories(
    List<MaterialsItemHistory> materialsItemHistory,
  ) async {
    await clearMaterialsItemHistories();
    try {
      for (var history in materialsItemHistory) {
        await materialsItemHistoryBox.put(
          history.uuid,
          history,
        );
      }
      await mainLocalLog(
        "Offline Materials Item History  inserted: ${materialsItemHistory.length}",
      );
      await mainLocalLog(
        getMaterialsItemHistories().length.toString(),
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Item History  Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createMaterialsItemHistories(
    MaterialsItemHistory materialsItemHistory,
  ) async {
    try {
      await materialsItemHistoryBox.put(
        materialsItemHistory.uuid,
        materialsItemHistory,
      );
      await mainLocalLog(
        'Offline Materials Item History inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Item History Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMaterialsItemHistories() async {
    try {
      if (materialsItemHistoryBox.values.isNotEmpty) {
        await materialsItemHistoryBox.clear();
        await mainLocalLog(
          'Offline Materials Item Histories  Cleared',
        );
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Materials Item Historie  Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedMaterialsItemHistoriesFunc()
            .getCreatedMaterialsItemHistoriess()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
