import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialQuantityUpdateProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  static final MaterialQuantityUpdateProvider _instance =
      MaterialQuantityUpdateProvider._internal();
  factory MaterialQuantityUpdateProvider() => _instance;
  MaterialQuantityUpdateProvider._internal();

  List<MaterialQuantityUpdate> materialsQuantityUpdates =
      [];

  final String tableName = 'production_materials';

  Future<int> createMaterialQuantityUpdate({
    required MaterialQuantityUpdate materialsQuantityUpdate,
  }) async {
    try {
      materialsQuantityUpdate.createdAt = DateTime.now();
      materialsQuantityUpdate.uuid = uuidGen();
      var res = await MaterialsQuantityUpdateFunc()
          .createMaterialsQuantityUpdate(
            materialsQuantityUpdate,
          );
      notifyListeners();
      return res;
    } catch (e) {
      await mainLocalLog(
        'Error Materials Creating Quantity Update: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  Future<void> clearMaterialQuantityUpdates() async {
    try {
      await MaterialsQuantityUpdateFunc()
          .clearMaterialsQuantitiesUpdate();
      notifyListeners();
    } catch (e) {
      await mainLocalLog('Error Clearing: ${e.toString()}');
    }
  }

  Future<void> materialsQuantityUpdateSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (MaterialsQuantityUpdateFunc()
              .getMaterialsQuantitiesUpdate()
              .isNotEmpty &&
          isOnline) {
        final tempMaterialQuantityUpdates =
            MaterialsQuantityUpdateFunc()
                .getMaterialsQuantitiesUpdate()
                .toList()
                .map((item) {
                  return {
                    "materialItemUuid": item.materialUuid,
                    "quantity": item.quantity,
                    "isIncrement": item.isIncrement,
                  };
                })
                .toList();

        await client.rpc(
          'update_materials_quantities',
          params: {'updates': tempMaterialQuantityUpdates},
        );

        await MaterialsQuantityUpdateFunc()
            .clearMaterialsQuantitiesUpdate();
        await mainLocalLog(
          'Unsynced Materials Quantity Updates Cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Materials Quantity Updates insert failed ❌: $e',
      );
    }
  }
}
