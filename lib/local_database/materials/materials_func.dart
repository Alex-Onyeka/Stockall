import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/local_database/materials/unsync_funcs/created_materials/created_materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/deleted_materials/deleted_materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/updated_materials/updated_materials_func.dart';
import 'package:stockall/main.dart';

class MaterialsFunc {
  static final MaterialsFunc instance =
      MaterialsFunc._internal();
  factory MaterialsFunc() => instance;
  MaterialsFunc._internal();
  late Box<MaterialClass> materialBox;
  final String materialBoxName = 'materialBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(MaterialClassAdapter());
      materialBox = await Hive.openBox(materialBoxName);
      await CreatedMaterialsFunc().init();
      await DeletedMaterialsFunc().init();
      await UpdatedMaterialsFunc().init();
      await MaterialsQuantityUpdateFunc().init();
      await mainLocalLog('Material Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Materials Func: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<MaterialClass> getMaterials() {
    List<MaterialClass> materials =
        materialBox.values.toList();
    materials.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return materials;
  }

  MaterialClass? getSingleMaterial({required String uuid}) {
    List<MaterialClass> materials =
        materialBox.values
            .where((pro) => pro.uuid == uuid)
            .toList();
    if (materials.isNotEmpty) {
      return materials.first;
    } else {
      return null;
    }
  }

  Future<int> insertAllMaterials(
    List<MaterialClass> materials,
  ) async {
    await clearMaterials();
    try {
      for (var material in materials) {
        await materialBox.put(material.uuid, material);
      }
      await mainLocalLog(
        "Offline Materials inserted: ${materials.length}",
      );
      await mainLocalLog(getMaterials().length.toString());
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createMaterial(MaterialClass material) async {
    try {
      await materialBox.put(material.uuid, material);
      await mainLocalLog(
        'Offline Material inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Material Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateMaterial(MaterialClass material) async {
    try {
      material.updatedAt = DateTime.now();
      await materialBox.put(material.uuid, material);
      await mainLocalLog(
        'Offline Material Update Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Update Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteMaterial(String uuid) async {
    try {
      await materialBox.delete(uuid);
      await mainLocalLog(
        'Offline Material Deleted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Material Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMaterials() async {
    try {
      if (materialBox.values.isNotEmpty) {
        await materialBox.clear();
        await mainLocalLog('Offline Materials Cleared');
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Materials Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedMaterialsFunc().getMaterials().isEmpty &&
        UpdatedMaterialsFunc().getMaterials().isEmpty &&
        DeletedMaterialsFunc().getMaterialIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
