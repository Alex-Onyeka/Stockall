import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/lan/pending_creates.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialQuantityUpdateProvider with ChangeNotifier {
  SupabaseClient get client => backend();
  static final MaterialQuantityUpdateProvider _instance =
      MaterialQuantityUpdateProvider._internal();
  factory MaterialQuantityUpdateProvider() => _instance;
  MaterialQuantityUpdateProvider._internal();

  List<MaterialQuantityUpdate> materialsQuantityUpdates = [];

  final String tableName = 'production_materials';

  Future<int> createMaterialQuantityUpdate({
    required MaterialQuantityUpdate materialsQuantityUpdate,
  }) async {
    try {
      materialsQuantityUpdate.createdAt = DateTime.now();
      materialsQuantityUpdate.uuid = uuidGen();
      var res = await MaterialsQuantityUpdateFunc()
          .createMaterialsQuantityUpdate(materialsQuantityUpdate);
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
      await MaterialsQuantityUpdateFunc().clearMaterialsQuantitiesUpdate();
      notifyListeners();
    } catch (e) {
      await mainLocalLog('Error Clearing: ${e.toString()}');
    }
  }

  Future<void> materialsQuantityUpdateSync() async {
    try {
      bool isOnline = await ConnectivityProvider().isOnline();
      if (MaterialsQuantityUpdateFunc()
              .getMaterialsQuantitiesUpdate()
              .isNotEmpty &&
          isOnline) {
        final queue = MaterialsQuantityUpdateFunc();
        // The entries as they are now, by their queue keys (their uuids).
        final snapshot = Map.of(queue.materialsQuantityUpdateBox.toMap());
        // Not yet for an item whose create is still queued here: it stays
        // queued for a later run (see PendingCreates).
        final notCreated = PendingCreates.materials();
        snapshot.removeWhere((_, u) => notCreated.contains(u.materialUuid));
        // Not an entry sent to a LAN server without an answer, except to
        // that server (see LanSentMarks).
        final to = LanSentMarks.target();
        snapshot.removeWhere(
          (key, _) => !LanSentMarks.maySend(
            queue.materialsQuantityUpdateBoxName,
            key,
            to: to,
          ),
        );
        if (snapshot.isEmpty) return;
        final sending = snapshot.values.toList();
        final sentUuids = snapshot.keys.toList();
        // From here on, new changes go into new entries (not merged into
        // these), and only these are removed after the answer.
        await LanSentMarks.markSending(
          queue.materialsQuantityUpdateBoxName,
          sentUuids,
          to: to,
        );
        final tempMaterialQuantityUpdates =
            sending
                .map((item) {
                  return {
                    // The LAN server skips an entry it already applied
                    // (a retry after a lost answer); Supabase never gets it.
                    if (RemoteRouter.usingLan) 'hiveUuid': item.uuid,
                    "materialItemUuid": item.materialUuid,
                    "quantity": item.quantity,
                    "isIncrement": item.isIncrement,
                  };
                })
                .toList();

        await LanSentMarks.send(
          queue.materialsQuantityUpdateBoxName,
          sentUuids,
          to: to,
          run: () => client.rpc(
            'update_materials_quantities',
            params: {'updates': tempMaterialQuantityUpdates},
          ),
        );

        await queue.materialsQuantityUpdateBox.deleteAll(sentUuids);
        await SentEntriesFunc().unmark(
          queue.materialsQuantityUpdateBoxName,
          sentUuids,
        );
        await mainLocalLog('Unsynced Materials Quantity Updates Cleared');
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Materials Quantity Updates insert failed ❌: $e',
      );
    }
  }
}
