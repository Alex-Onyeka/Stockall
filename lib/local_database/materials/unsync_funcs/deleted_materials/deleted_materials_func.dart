import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/deleted_materials/deleted_material.dart';
import 'package:stockall/main.dart';

class DeletedMaterialsFunc {
  static final DeletedMaterialsFunc instance =
      DeletedMaterialsFunc._internal();
  factory DeletedMaterialsFunc() => instance;
  DeletedMaterialsFunc._internal();

  Box<DeletedMaterial>? _deletedMaterialsBox;
  final String deletedMaterialsBoxName =
      'deletedMaterialsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(
        DeletedMaterialAdapter().typeId,
      )) {
        Hive.registerAdapter(DeletedMaterialAdapter());
        await mainLocalLog(
          'deletedMaterialsAdapter registered ✅',
        );
      }

      // Open the box only if it isn’t already open
      if (!Hive.isBoxOpen(deletedMaterialsBoxName)) {
        _deletedMaterialsBox =
            await Hive.openBox<DeletedMaterial>(
              deletedMaterialsBoxName,
            );
        await mainLocalLog(
          'Deleted Materials Box opened ✅',
        );
      } else {
        _deletedMaterialsBox = Hive.box<DeletedMaterial>(
          deletedMaterialsBoxName,
        );
        await mainLocalLog(
          'Deleted Materials Box already open, reused ✅',
        );
      }
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Deleted Materials Func: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedMaterial> get deletedMaterialsBox {
    if (_deletedMaterialsBox == null) {
      throw Exception(
        "Deleted Materials Func not initialized. Call await Deleted Materials Func.instance.init() first.",
      );
    }
    return _deletedMaterialsBox!;
  }

  List<DeletedMaterial> getMaterialIds() {
    return deletedMaterialsBox.values.toList();
  }

  Future<int> insertAllDeletedMaterial(
    List<DeletedMaterial> deletedMaterials,
  ) async {
    try {
      for (var material in deletedMaterials) {
        await deletedMaterialsBox.add(material);
      }
      await mainLocalLog(
        "Offline Deleted Materials inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Materials insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedMaterial(
    DeletedMaterial deletedMaterial,
  ) async {
    try {
      await deletedMaterialsBox.add(deletedMaterial);
      await mainLocalLog(
        'Offline Deleted Material inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Material insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedMaterial() async {
    try {
      await deletedMaterialsBox.clear();
      await mainLocalLog('All Deleted Materials cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Materials ❌: $e',
      );
      return 0;
    }
  }
}
