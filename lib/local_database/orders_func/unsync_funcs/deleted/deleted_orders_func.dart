import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_orders/unsynced/deleted/deleted_orders.dart';
import 'package:stockall/main.dart';

class DeletedOrdersFunc {
  static final DeletedOrdersFunc instance =
      DeletedOrdersFunc._internal();
  factory DeletedOrdersFunc() => instance;
  DeletedOrdersFunc._internal();

  Box<DeletedOrders>? _deletedOrdersBox;
  final String deletedOrdersBoxName =
      'deletedOrdersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedOrdersAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedOrdersAdapter());
      await mainLocalLog(
        'Deleted Orders Adapter registered ✅',
      );
    }

_deletedOrdersBox = await openBoxSafely<DeletedOrders>(deletedOrdersBoxName);
  }

  /// Safe getter for the box
  Box<DeletedOrders> get deletedOrdersBox {
    if (_deletedOrdersBox == null) {
      throw Exception(
        "Deleted Orders Func not initialized. Call await Deleted Orders Func.instance.init() first.",
      );
    }
    return _deletedOrdersBox!;
  }

  List<DeletedOrders> getOrderIds() {
    return deletedOrdersBox.values.toList();
  }

  Future<int> insertAllDeletedOrders(
    List<DeletedOrders> deletedOrders,
  ) async {
    try {
      for (var order in deletedOrders) {
        await deletedOrdersBox.add(order);
      }
      await mainLocalLog(
        "Offline Deleted Orders inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Orders insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedOrder(
    DeletedOrders deletedOrder,
  ) async {
    try {
      await deletedOrdersBox.put(
        deletedOrder.orderUuid,
        deletedOrder,
      );
      await mainLocalLog(
        'Offline Deleted Order inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Order insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedOrders(String uuid) async {
    try {
      await deletedOrdersBox.delete(uuid);
      final keysToDelete = <dynamic>[];
      for (var key in deletedOrdersBox.keys) {
        final val = deletedOrdersBox.get(key);
        if (val != null && val.orderUuid == uuid) {
          keysToDelete.add(key);
        }
      }
      for (var key in keysToDelete) {
        await deletedOrdersBox.delete(key);
      }
      await mainLocalLog('Delete Order cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Order ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedOrders() async {
    try {
      await deletedOrdersBox.clear();
      await mainLocalLog('All Deleted Orders cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Orders ❌: $e',
      );
      return 0;
    }
  }
}
