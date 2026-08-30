import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/updated/updated_orders.dart';
import 'package:stockall/main.dart';

class UpdatedOrdersFunc {
  static final UpdatedOrdersFunc instance =
      UpdatedOrdersFunc._internal();
  factory UpdatedOrdersFunc() => instance;
  UpdatedOrdersFunc._internal();

  Box<UpdatedOrders>? _updatedOrdersBox;
  final String updatedOrdersBoxName =
      'updatedOrdersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedOrdersAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedOrdersAdapter());
      await mainLocalLog(
        'Updated Orders Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedOrdersBoxName)) {
      _updatedOrdersBox = await Hive.openBox<UpdatedOrders>(
        updatedOrdersBoxName,
      );
      await mainLocalLog('Updated Orders Box opened ✅');
    } else {
      _updatedOrdersBox = Hive.box<UpdatedOrders>(
        updatedOrdersBoxName,
      );
      await mainLocalLog(
        'Updated Orders Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedOrders> get updatedOrdersBox {
    if (_updatedOrdersBox == null) {
      throw Exception(
        "Updated Orders Func not initialized. Call await updated Orders Func.instance.init() first.",
      );
    }
    return _updatedOrdersBox!;
  }

  List<UpdatedOrders> getOrderIds() {
    return updatedOrdersBox.values.toList();
  }

  Future<int> createUpdatedOrder(Orders order) async {
    try {
      updatedOrdersBox.add(UpdatedOrders(order: order));
      await mainLocalLog(
        'Offline Updated Order inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Order insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedOrder(String uuid) async {
    try {
      await mainLocalLog(
        updatedOrdersBox.containsKey(uuid).toString(),
      );
      await updatedOrdersBox.delete(uuid);
      await mainLocalLog('Updated Order Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Order Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedOrders() async {
    try {
      await updatedOrdersBox.clear();
      await mainLocalLog('All updated Orders cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Orders ❌: $e',
      );
      return 0;
    }
  }
}
