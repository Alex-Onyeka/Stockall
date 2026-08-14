import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/updated/updated_production_materials_usage.dart';
import 'package:stockall/main.dart';

class UpdatedProductionMaterialsUsageFunc {
  static final UpdatedProductionMaterialsUsageFunc
  instance =
      UpdatedProductionMaterialsUsageFunc._internal();
  factory UpdatedProductionMaterialsUsageFunc() => instance;
  UpdatedProductionMaterialsUsageFunc._internal();

  Box<UpdatedProductionMaterialsUsage>?
  _updatedProductionMaterialsUsageBox;
  final String updatedProductionMaterialsUsageBoxName =
      'updatedProductionMaterialsUsageBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedProductionMaterialsUsageAdapter().typeId,
    )) {
      Hive.registerAdapter(
        UpdatedProductionMaterialsUsageAdapter(),
      );
      await mainLocalLog(
        'Updated Production Materials Usage Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      updatedProductionMaterialsUsageBoxName,
    )) {
      _updatedProductionMaterialsUsageBox =
          await Hive.openBox<
            UpdatedProductionMaterialsUsage
          >(updatedProductionMaterialsUsageBoxName);
      await mainLocalLog(
        'Updated Production Materials Usage Box opened ✅',
      );
    } else {
      _updatedProductionMaterialsUsageBox =
          Hive.box<UpdatedProductionMaterialsUsage>(
            updatedProductionMaterialsUsageBoxName,
          );
      await mainLocalLog(
        'Updated Production Materials Usage Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedProductionMaterialsUsage>
  get updatedProductionMaterialsUsageBox {
    if (_updatedProductionMaterialsUsageBox == null) {
      throw Exception(
        "Updated Production Materials Usage Func not initialized. Call await updated Production Materials Usage Func.instance.init() first.",
      );
    }
    return _updatedProductionMaterialsUsageBox!;
  }

  List<UpdatedProductionMaterialsUsage>
  getProductionMaterialsUsageIds() {
    return updatedProductionMaterialsUsageBox.values
        .toList();
  }

  Future<int> createUpdatedProductionMaterialsUsage(
    UpdatedProductionMaterialsUsage
    updatedProductionMaterialsUsage,
  ) async {
    try {
      updatedProductionMaterialsUsageBox.add(
        UpdatedProductionMaterialsUsage(
          updatedProductionMaterialsUsage:
              updatedProductionMaterialsUsage
                  .updatedProductionMaterialsUsage,
        ),
      );
      await mainLocalLog(
        'Offline Updated Production Materials Usage inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Production Materials Usage insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedProductionMaterialsUsage(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        updatedProductionMaterialsUsageBox
            .containsKey(uuid)
            .toString(),
      );
      await updatedProductionMaterialsUsageBox.delete(uuid);
      await mainLocalLog(
        'Updated Production Materials Usage Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'ProductionMaterialsUsage Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedProductionMaterialsUsage() async {
    try {
      await updatedProductionMaterialsUsageBox.clear();
      await mainLocalLog(
        'All updated Production Materials Usage cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Production Materials Usage ❌: $e',
      );
      return 0;
    }
  }
}
