import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuantityUpdateProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
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
        final tempQuantityUpdates =
            QuantityUpdateFunc().getQuantitiesUpdate().toList().map((item) {
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

        // Reconcile local products with server so this device immediately
        // reflects server state and any sales made by other staff.
        await returnData().syncProductsIncremental();
      }
    } catch (e) {
      await mainLocalLog('Batch Quantity Updates insert failed ❌: $e');
    }
  }
}
