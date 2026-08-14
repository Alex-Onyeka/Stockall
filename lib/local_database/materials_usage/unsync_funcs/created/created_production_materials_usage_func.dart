import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/created/created_production_materials_usage.dart';
import 'package:stockall/main.dart';

class CreatedProductionMaterialsUsageFunc {
  static final CreatedProductionMaterialsUsageFunc
  instance =
      CreatedProductionMaterialsUsageFunc._internal();
  factory CreatedProductionMaterialsUsageFunc() => instance;
  CreatedProductionMaterialsUsageFunc._internal();

  Box<CreatedProductionMaterialsUsage>?
  _createdProductionMaterialsUsageBox;
  final String createdProductionMaterialsUsageBoxName =
      'createdProductionMaterialsUsageBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedProductionMaterialsUsageAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedProductionMaterialsUsageAdapter(),
      );
      await mainLocalLog(
        'Created Production Materials Usage Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      createdProductionMaterialsUsageBoxName,
    )) {
      _createdProductionMaterialsUsageBox =
          await Hive.openBox<
            CreatedProductionMaterialsUsage
          >(createdProductionMaterialsUsageBoxName);
      await mainLocalLog(
        'Created Production Materials Usage Box opened ✅',
      );
    } else {
      _createdProductionMaterialsUsageBox =
          Hive.box<CreatedProductionMaterialsUsage>(
            createdProductionMaterialsUsageBoxName,
          );
      await mainLocalLog(
        'Created Production Materials Usage Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedProductionMaterialsUsage>
  get createdProductionMaterialsUsageBox {
    if (_createdProductionMaterialsUsageBox == null) {
      throw Exception(
        "Created Production Materials Usage Func not initialized. Call await Created Production Materials Usage Func.instance.init() first.",
      );
    }
    return _createdProductionMaterialsUsageBox!;
  }

  List<CreatedProductionMaterialsUsage>
  getProductionMaterialsUsage() {
    List<CreatedProductionMaterialsUsage>
    createdProductionMaterialsUsages =
        createdProductionMaterialsUsageBox.values.toList();
    createdProductionMaterialsUsages.sort(
      (a, b) => a.createdProductionMaterialsUsage.createdAt!
          .compareTo(
            b.createdProductionMaterialsUsage.createdAt!,
          ),
    );
    return createdProductionMaterialsUsages;
  }

  Future<int> insertAllProductionMaterialsUsage(
    List<CreatedProductionMaterialsUsage>
    createdProductionMaterialsUsage,
  ) async {
    try {
      // await clearCreatedProductionMaterialsUsage();
      for (var createdProductionMaterialsUsages
          in createdProductionMaterialsUsage) {
        await createdProductionMaterialsUsageBox.put(
          createdProductionMaterialsUsages
              .createdProductionMaterialsUsage
              .uuid,
          createdProductionMaterialsUsages,
        );
      }
      await mainLocalLog(
        "Offline Created Production Materials Usage inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Materials Usage insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createProductionMaterialsUsage(
    CreatedProductionMaterialsUsage
    createdProductionMaterialsUsage,
  ) async {
    try {
      await createdProductionMaterialsUsageBox.put(
        createdProductionMaterialsUsage
            .createdProductionMaterialsUsage
            .uuid,
        createdProductionMaterialsUsage,
      );
      await mainLocalLog(
        'Offline Created Production Materials Usage inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Production Materials Usage insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteCreatedProductionMaterialsUsage(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        createdProductionMaterialsUsageBox
            .containsKey(uuid)
            .toString(),
      );
      await createdProductionMaterialsUsageBox.delete(uuid);
      await mainLocalLog(
        'Created Created Production Materials Usage Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Created Production Materials Usage Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCreatedProductionMaterialsUsage() async {
    try {
      await createdProductionMaterialsUsageBox.clear();
      await mainLocalLog(
        'All Created Production Materials Usage cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Production Materials Usage ❌: $e',
      );
      return 0;
    }
  }
}
