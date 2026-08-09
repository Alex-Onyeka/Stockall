import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/updated/updated_material.dart';
import 'package:stockall/main.dart';

class UpdatedMaterialsFunc {
  static final UpdatedMaterialsFunc instance =
      UpdatedMaterialsFunc._internal();
  factory UpdatedMaterialsFunc() => instance;
  UpdatedMaterialsFunc._internal();

  Box<UpdatedMaterial>? _updatedMaterialsBox;
  final String updatedMaterialsBoxName =
      'updatedMaterialsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      UpdatedMaterialAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedMaterialAdapter());
      await mainLocalLog(
        'Updated Materials Adapter registered ✅',
      );
    }

    try {
      await _openBox();
    } catch (e, s) {
      await mainLocalLog(
        'Failed to open Updated Materials Box. Deleting and recreating...',
        error: e,
        stackTrace: s,
      );

      await Hive.deleteBoxFromDisk(updatedMaterialsBoxName);

      // Try exactly one more time
      await _openBox();
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(updatedMaterialsBoxName)) {
      _updatedMaterialsBox =
          await Hive.openBox<UpdatedMaterial>(
            updatedMaterialsBoxName,
          );
      await mainLocalLog('Updated Materials Box opened ✅');
    } else {
      _updatedMaterialsBox = Hive.box<UpdatedMaterial>(
        updatedMaterialsBoxName,
      );
      await mainLocalLog(
        'Updated Materials Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedMaterial> get updatedMaterialsBox {
    if (_updatedMaterialsBox == null) {
      throw Exception(
        "Updated Materials Func not initialized. Call await updated Materials Func.instance.init() first.",
      );
    }
    return _updatedMaterialsBox!;
  }

  List<UpdatedMaterial> getMaterials() {
    return updatedMaterialsBox.values.toList();
  }

  Future<int> createUpdatedMaterial(
    UpdatedMaterial updatedMaterial,
  ) async {
    try {
      updatedMaterial.material.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedMaterialsBox.put(
        updatedMaterial.material.uuid,
        updatedMaterial,
      );
      await mainLocalLog(
        'Offline updated Material inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Material insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedMaterial(
    UpdatedMaterial updatedMaterial,
  ) async {
    try {
      updatedMaterial.material.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedMaterialsBox.put(
        updatedMaterial.material.uuid,
        updatedMaterial,
      );
      await mainLocalLog(
        'Offline updated Material inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Material insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedMaterial(String uuid) async {
    try {
      await mainLocalLog(
        updatedMaterialsBox.containsKey(uuid).toString(),
      );
      await updatedMaterialsBox.delete(uuid);
      await mainLocalLog('Updated Material Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Material Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearupdatedMaterials() async {
    try {
      await updatedMaterialsBox.clear();
      await mainLocalLog('All updated Materials cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Materials ❌: $e',
      );
      return 0;
    }
  }
}
