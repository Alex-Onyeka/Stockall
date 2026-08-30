import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/unsynced/created/created_orders.dart';
import 'package:stockall/main.dart';

class CreatedOrdersFunc {
  static final CreatedOrdersFunc instance =
      CreatedOrdersFunc._internal();
  factory CreatedOrdersFunc() => instance;
  CreatedOrdersFunc._internal();

  Box<CreatedOrders>? _createdOrdersBox;
  final String createdOrdersBoxName =
      'createdOrdersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedOrdersAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedOrdersAdapter());
      await mainLocalLog(
        'Created Orders Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdOrdersBoxName)) {
      _createdOrdersBox = await Hive.openBox<CreatedOrders>(
        createdOrdersBoxName,
      );
      await mainLocalLog('Created Orders Box opened ✅');
    } else {
      _createdOrdersBox = Hive.box<CreatedOrders>(
        createdOrdersBoxName,
      );
      await mainLocalLog(
        'Created Orders Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedOrders> get createdOrdersBox {
    if (_createdOrdersBox == null) {
      throw Exception(
        "Created Orders Func not initialized. Call await CreatedOrdersFunc.instance.init() first.",
      );
    }
    return _createdOrdersBox!;
  }

  List<CreatedOrders> getOrders() {
    List<CreatedOrders> orders =
        createdOrdersBox.values.toList();
    orders.sort(
      (a, b) =>
          a.order.createdAt.compareTo(b.order.createdAt),
    );
    return orders;
  }

  Future<int> insertAllOrders(
    List<CreatedOrders> createdOrders,
  ) async {
    try {
      for (var orders in createdOrders) {
        await createdOrdersBox.put(
          orders.order.uuid,
          orders,
        );
      }
      await mainLocalLog(
        "Offline Created Orders inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Orders insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createOrders(
    CreatedOrders createdOrders,
  ) async {
    try {
      await createdOrdersBox.put(
        createdOrders.order.uuid,
        createdOrders,
      );
      await mainLocalLog(
        'Offline Created Orders inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Orders insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteOrder(String uuid) async {
    try {
      await mainLocalLog(
        createdOrdersBox.containsKey(uuid).toString(),
      );
      await createdOrdersBox.delete(uuid);
      await mainLocalLog('Created eceipts Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Orders Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearOrders() async {
    try {
      await createdOrdersBox.clear();
      await mainLocalLog('All Created Orders cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Orders ❌: $e',
      );
      return 0;
    }
  }
}
