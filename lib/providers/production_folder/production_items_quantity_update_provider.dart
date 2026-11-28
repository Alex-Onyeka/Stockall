import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/lan/pending_creates.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionItemsQuantityUpdateProvider with ChangeNotifier {
  SupabaseClient get client => backend();
  static final ProductionItemsQuantityUpdateProvider _instance =
      ProductionItemsQuantityUpdateProvider._internal();
  factory ProductionItemsQuantityUpdateProvider() => _instance;
  ProductionItemsQuantityUpdateProvider._internal();

  List<ProductionItemQuantityUpdate> productionItemsQuantityUpdates = [];

  final String tableName = 'production_items';

  Future<int> createProductionItemQuantityUpdate({
    required ProductionItemQuantityUpdate productionItemsQuantityUpdate,
  }) async {
    try {
      productionItemsQuantityUpdate.createdAt = DateTime.now();
      productionItemsQuantityUpdate.uuid = uuidGen();
      var res = await ProductionItemsQuantityUpdateFunc()
          .createProductionItemsQuantityUpdate(productionItemsQuantityUpdate);
      notifyListeners();
      return res;
    } catch (e) {
      await mainLocalLog(
        'Error ProductionItems Creating Quantity Update: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  Future<void> clearProductionItemQuantityUpdates() async {
    try {
      await ProductionItemsQuantityUpdateFunc()
          .clearProductionItemsQuantitiesUpdate();
      notifyListeners();
    } catch (e) {
      await mainLocalLog('Error Clearing: ${e.toString()}');
    }
  }

  Future<void> productionItemsQuantityUpdateSync() async {
    try {
      bool isOnline = await ConnectivityProvider().isOnline();
      if (ProductionItemsQuantityUpdateFunc()
              .getProductionItemsQuantitiesUpdate()
              .isNotEmpty &&
          isOnline) {
        final queue = ProductionItemsQuantityUpdateFunc();
        // The entries as they are now, by their queue keys (their uuids).
        final snapshot = Map.of(queue.productionItemsQuantityUpdateBox.toMap());
        // Not yet for an item whose create is still queued here: it stays
        // queued for a later run (see PendingCreates).
        final notCreated = PendingCreates.productionItems();
        snapshot.removeWhere(
          (_, u) => notCreated.contains(u.productionItemUuid),
        );
        // Not an entry sent to a LAN server without an answer, except to
        // that server (see LanSentMarks).
        final to = LanSentMarks.target();
        snapshot.removeWhere(
          (key, _) => !LanSentMarks.maySend(
            queue.productionItemsQuantityUpdateBoxName,
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
          queue.productionItemsQuantityUpdateBoxName,
          sentUuids,
          to: to,
        );
        final tempProductionItemQuantityUpdates =
            sending
                .map((item) {
                  return {
                    // The LAN server skips an entry it already applied
                    // (a retry after a lost answer); Supabase never gets it.
                    if (RemoteRouter.usingLan) 'hiveUuid': item.uuid,
                    "productionItemUuid": item.productionItemUuid,
                    "quantity": item.quantity,
                    "isIncrement": item.isIncrement,
                  };
                })
                .toList();

        await client.rpc(
          'update_production_items_quantities',
          params: {'updates': tempProductionItemQuantityUpdates},
        );

        await queue.productionItemsQuantityUpdateBox.deleteAll(sentUuids);
        await SentEntriesFunc().unmark(
          queue.productionItemsQuantityUpdateBoxName,
          sentUuids,
        );
        await mainLocalLog('Unsynced ProductionItems Quantity Updates Cleared');
      }
    } catch (e) {
      await mainLocalLog(
        'Batch ProductionItems Quantity Updates insert failed ❌: $e',
      );
    }
  }
}
