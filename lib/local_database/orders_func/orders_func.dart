import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/created/created_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/deleted/deleted_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/updated/updated_orders_func.dart';
import 'package:stockall/main.dart';

class OrdersFunc {
  static final OrdersFunc instance = OrdersFunc._internal();
  factory OrdersFunc() => instance;
  OrdersFunc._internal();
  late Box<Orders> orderBox;
  final String orderBoxName = 'mainOrderBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(OrdersAdapter());
    Hive.registerAdapter(OrderItemsAdapter());
    orderBox = await Hive.openBox(orderBoxName);
    await CreatedOrdersFunc().init();
    await DeletedOrdersFunc().init();
    await UpdatedOrdersFunc().init();
    await mainLocalLog('Order Box Initialized');
  }

  List<Orders> getOrders() {
    List<Orders> orders = orderBox.values.toList();
    orders.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    return orders;
  }

  Future<int> insertAllOrders(List<Orders> orders) async {
    await clearOrders();
    try {
      for (var rec in orders) {
        await orderBox.put(rec.uuid, rec);
      }
      await mainLocalLog('Offline Order Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Order Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createOrder(Orders rec) async {
    try {
      await orderBox.put(rec.uuid, rec);
      await mainLocalLog('Offline Order Created');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Order Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteOrder(String uuid) async {
    try {
      await orderBox.delete(uuid);
      await mainLocalLog('Offline Order Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearOrders() async {
    try {
      await orderBox.clear();
      await mainLocalLog('Offline Orders Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Order Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedOrdersFunc().getOrders().isEmpty &&
        UpdatedOrdersFunc().getOrderIds().isEmpty &&
        DeletedOrdersFunc().getOrderIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
