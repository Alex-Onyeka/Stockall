import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/lan/pending_creates.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuantityUpdateProvider with ChangeNotifier {
  SupabaseClient get client => backend();
  static final QuantityUpdateProvider _instance =
      QuantityUpdateProvider._internal();
  factory QuantityUpdateProvider() => _instance;
  QuantityUpdateProvider._internal();

  List<QuantityUpdate> quantityUpdates = [];

  // final String tableName = 'products';

  Future<int> createQuantityUpdate({
    required QuantityUpdate quantityUpdate,
  }) async {
    try {
      quantityUpdate.createdAt = DateTime.now();
      quantityUpdate.uuid = uuidGen();
      var res = await QuantityUpdateFunc().createQuantityUpdate(quantityUpdate);
      notifyListeners();
      return res;
    } catch (e) {
      await mainLocalLog('Error Creating Quantity Update: ${e.toString()}');
      notifyListeners();
      return 0;
    }
  }

  Future<void> clearQuantityUpdates() async {
    try {
      await QuantityUpdateFunc().clearQuantitiesUpdate();
      notifyListeners();
    } catch (e) {
      await mainLocalLog('Error Clearing: ${e.toString()}');
    }
  }

  Future<void> quantityUpdateSync() async {
    try {
      bool isOnline = await ConnectivityProvider().isOnline();
      if (QuantityUpdateFunc().getQuantitiesUpdate().isNotEmpty && isOnline) {
        // Not yet for a product whose create is still queued here: it stays
        // queued for a later run (see PendingCreates).
        final notCreated = PendingCreates.products();
        final queue = QuantityUpdateFunc();
        // Not an entry sent to a LAN server without an answer, except to
        // that server (see LanSentMarks).
        final to = LanSentMarks.target();
        final ready = queue
            .getQuantitiesUpdate()
            .where(
              (q) =>
                  !notCreated.contains(q.productUuid) &&
                  LanSentMarks.maySend(
                    queue.quantityUpdateBoxName,
                    q.uuid,
                    to: to,
                  ),
            )
            .toList();
        if (ready.isEmpty) return;
        final sentUuids = [for (final q in ready) q.uuid];
        // Out until the answer: a pull adds none of these back meanwhile.
        await LanSentMarks.markSending(
          queue.quantityUpdateBoxName,
          sentUuids,
          to: to,
        );
        final tempQuantityUpdates =
            ready.map((item) {
              return {
                'hiveUuid': item.uuid,
                "itemUuid": item.productUuid,
                "quantity": item.quantity,
                "isIncrement": item.isIncrement,
                'isStorage': item.isStorage,
              };
            }).toList();

        final dynamic rawRes = await client.rpc(
          'update_product_quantities',
          params: {'updates': tempQuantityUpdates},
        );

        if (rawRes is List) {
          final returnedUuids = <String>{};
          for (var item in rawRes) {
            if (item is Map && item['hiveUuid'] != null) {
              final hiveUuid = item['hiveUuid'].toString();
              returnedUuids.add(hiveUuid);
              await QuantityUpdateFunc().deleteQuantityUpdate(
                uuid: hiveUuid,
              );
              mainLocalLog('Quantity Updates Successfully');
            }
          }
          for (var sent in tempQuantityUpdates) {
            final hiveUuid = sent['hiveUuid']?.toString();
            if (hiveUuid != null && !returnedUuids.contains(hiveUuid)) {
              await QuantityUpdateFunc().deleteQuantityUpdate(
                uuid: hiveUuid,
              );
            }
          }
        } else {
          for (var sent in tempQuantityUpdates) {
            final hiveUuid = sent['hiveUuid']?.toString();
            if (hiveUuid != null) {
              await QuantityUpdateFunc().deleteQuantityUpdate(
                uuid: hiveUuid,
              );
            }
          }
        }

        await SentEntriesFunc().unmark(queue.quantityUpdateBoxName, sentUuids);

        // Reconcile local products with server so this device immediately
        // reflects server state and any sales made by other staff.
        await returnData().syncProductsIncremental();
      }
    } catch (e) {
      await mainLocalLog('Batch Quantity Updates insert failed ❌: $e');
    }
  }
}
