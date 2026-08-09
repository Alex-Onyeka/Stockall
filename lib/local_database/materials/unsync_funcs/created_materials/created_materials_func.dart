import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/created_materials/created_material.dart';
import 'package:stockall/main.dart';

class CreatedMaterialsFunc {
  static final CreatedMaterialsFunc instance =
      CreatedMaterialsFunc._internal();
  factory CreatedMaterialsFunc() => instance;
  CreatedMaterialsFunc._internal();

  Box<CreatedMaterial>? _createdMaterialsBox;
  final String createdMaterialsBoxName =
      'createdMaterialsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(
        CreatedMaterialAdapter().typeId,
      )) {
        Hive.registerAdapter(CreatedMaterialAdapter());
        await mainLocalLog(
          'Created Materials Adapter registered ✅',
        );
      }

      // Open the box only if it isn’t already open
      await _openBox();
    } catch (e, s) {
      await Hive.deleteBoxFromDisk(
        'createdMaterialsBoxStockall',
      );
      await mainLocalLog(
        'Error Initializing Created Materials Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
      await _openBox();
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(createdMaterialsBoxName)) {
      _createdMaterialsBox =
          await Hive.openBox<CreatedMaterial>(
            createdMaterialsBoxName,
          );
      await mainLocalLog('Created Materials Box opened ✅');
    } else {
      _createdMaterialsBox = Hive.box<CreatedMaterial>(
        createdMaterialsBoxName,
      );
      await mainLocalLog(
        'Created Materials Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedMaterial> get createdMaterialsBox {
    if (_createdMaterialsBox == null) {
      throw Exception(
        "CreatedMaterialsFunc not initialized. Call await CreatedMaterialsFunc.instance.init() first.",
      );
    }
    return _createdMaterialsBox!;
  }

  List<CreatedMaterial> getMaterials() {
    return createdMaterialsBox.values.toList();
  }

  Future<int> insertAllMaterials(
    List<CreatedMaterial> createdMaterials,
  ) async {
    try {
      for (var material in createdMaterials) {
        await createdMaterialsBox.put(
          material.material.uuid,
          material,
        );
      }
      await mainLocalLog(
        "Offline Created Materials inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Materials insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createMaterial(
    CreatedMaterial createdMaterial,
  ) async {
    try {
      await createdMaterialsBox.put(
        createdMaterial.material.uuid,
        createdMaterial,
      );
      await mainLocalLog(
        'Offline Created Material inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Material insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateMaterial(
    CreatedMaterial createdMaterial,
  ) async {
    try {
      await mainLocalLog(
        createdMaterialsBox
            .containsKey(createdMaterial.material.uuid)
            .toString(),
      );
      await createdMaterialsBox.put(
        createdMaterial.material.uuid,
        createdMaterial,
      );
      await mainLocalLog(
        'Offline Created Material Updated Successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌Offline Created Material Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteMaterial(String uuid) async {
    try {
      await mainLocalLog(
        createdMaterialsBox.containsKey(uuid).toString(),
      );
      await createdMaterialsBox.delete(uuid);
      await mainLocalLog('Material Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Material Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMaterials() async {
    try {
      await createdMaterialsBox.clear();
      await mainLocalLog('All Created Materials cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Materials ❌: $e',
      );
      return 0;
    }
  }
}
