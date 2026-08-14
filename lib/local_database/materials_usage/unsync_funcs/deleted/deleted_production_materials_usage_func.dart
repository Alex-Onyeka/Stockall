import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/deleted/deleted_production_materials_usage.dart';
import 'package:stockall/main.dart';

class DeletedProductionMaterialsUsageFunc {
  static final DeletedProductionMaterialsUsageFunc
  instance =
      DeletedProductionMaterialsUsageFunc._internal();
  factory DeletedProductionMaterialsUsageFunc() => instance;
  DeletedProductionMaterialsUsageFunc._internal();

  Box<DeletedProductionMaterialsUsage>?
  _deletedProductionMaterialsUsageBox;
  final String deletedProductionMaterialsUsageBoxName =
      'deletedProductionMaterialsUsageBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedProductionMaterialsUsageAdapter().typeId,
    )) {
      Hive.registerAdapter(
        DeletedProductionMaterialsUsageAdapter(),
      );
      await mainLocalLog(
        'Deleted ProductionMaterialsUsage Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      deletedProductionMaterialsUsageBoxName,
    )) {
      _deletedProductionMaterialsUsageBox =
          await Hive.openBox<
            DeletedProductionMaterialsUsage
          >(deletedProductionMaterialsUsageBoxName);
      await mainLocalLog(
        'Deleted ProductionMaterialsUsage Box opened ✅',
      );
    } else {
      _deletedProductionMaterialsUsageBox =
          Hive.box<DeletedProductionMaterialsUsage>(
            deletedProductionMaterialsUsageBoxName,
          );
      await mainLocalLog(
        'Deleted ProductionMaterialsUsage Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedProductionMaterialsUsage>
  get deletedProductionMaterialsUsageBox {
    if (_deletedProductionMaterialsUsageBox == null) {
      throw Exception(
        "Deleted ProductionMaterialsUsage Func not initialized. Call await Deleted ProductionMaterialsUsage Func.instance.init() first.",
      );
    }
    return _deletedProductionMaterialsUsageBox!;
  }

  List<DeletedProductionMaterialsUsage>
  getDeletedProductionMaterialsUsageIds() {
    return deletedProductionMaterialsUsageBox.values
        .toList();
  }

  Future<int> insertAllDeletedProductionMaterialsUsage(
    List<DeletedProductionMaterialsUsage>
    deletedProductionMaterialsUsages,
  ) async {
    try {
      for (var productionMaterialsUsage
          in deletedProductionMaterialsUsages) {
        await deletedProductionMaterialsUsageBox.add(
          productionMaterialsUsage,
        );
      }
      await mainLocalLog(
        "Offline Deleted ProductionMaterialsUsage inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted ProductionMaterialsUsage insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedDeletedProductionMaterialsUsage(
    DeletedProductionMaterialsUsage
    deletedDeletedProductionMaterialsUsage,
  ) async {
    try {
      await deletedProductionMaterialsUsageBox.add(
        deletedDeletedProductionMaterialsUsage,
      );
      await mainLocalLog(
        'Offline Deleted DeletedProductionMaterialsUsage inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted DeletedProductionMaterialsUsage insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedProductionMaterialsUsage(
    String uuid,
  ) async {
    try {
      await deletedProductionMaterialsUsageBox.delete(uuid);
      await mainLocalLog(
        'Delete DeletedProductionMaterialsUsage cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted DeletedProductionMaterialsUsage ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedProductionMaterialsUsage() async {
    try {
      await deletedProductionMaterialsUsageBox.clear();
      await mainLocalLog(
        'All Deleted ProductionMaterialsUsage cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted ProductionMaterialsUsage ❌: $e',
      );
      return 0;
    }
  }
}
