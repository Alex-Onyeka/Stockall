import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_quantity/quantity_update_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuantityUpdateProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  static final QuantityUpdateProvider _instance =
      QuantityUpdateProvider._internal();
  factory QuantityUpdateProvider() => _instance;
  QuantityUpdateProvider._internal();

  List<QuantityUpdate> quantityUpdates = [];

  final String tableName = 'products';

  Future<int> createQuantityUpdate({
    required QuantityUpdate quantityUpdate,
  }) async {
    try {
      var res = await QuantityUpdateFunc()
          .createQuantityUpdate(quantityUpdate);
      notifyListeners();
      return res;
    } catch (e) {
      print(
        'Error Creating Quantity Update: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  Future<void> clearQuantityUpdates() async {
    try {
      await QuantityUpdateFunc().clearQuantitiesUpdate();
      notifyListeners();
    } catch (e) {
      print('Error Clearing: ${e.toString()}');
    }
  }

  Future<void> quantityUpdateSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (QuantityUpdateFunc()
              .getQuantitiesUpdate()
              .isNotEmpty &&
          isOnline) {
        final tempQuantityUpdates =
            QuantityUpdateFunc()
                .getQuantitiesUpdate()
                .toList();

        for (var item in tempQuantityUpdates) {
          try {
            var res =
                await client
                    .from(tableName)
                    .select()
                    .eq('uuid', item.productUuid)
                    .maybeSingle();
            if (res != null) {
              TempProductClass product =
                  TempProductClass.fromJson(res);
              await client
                  .from(tableName)
                  .update({
                    'quantity':
                        item.isIncrement
                            ? ((product.quantity ?? 0) +
                                item.quantity)
                            : ((product.quantity ?? 0) -
                                item.quantity),
                  })
                  .eq('uuid', item.productUuid)
                  .select();
              await QuantityUpdateFunc()
                  .deleteQuantityUpdate(uuid: item.uuid);
            }
          } on PostgrestException catch (e) {
            print(
              'Error Occoured While Creating Error Log: ${e.toString()}',
            );
          }
        }

        await QuantityUpdateFunc().clearQuantitiesUpdate();
        print('Unsynced Quantity Updates Cleared');
        print('Mounted, refreshing Receipts ✅');
      }
    } catch (e) {
      print('Batch Quantity Updates insert failed ❌: $e');
    }
  }
}
