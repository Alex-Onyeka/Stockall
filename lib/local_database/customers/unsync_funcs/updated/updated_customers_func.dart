import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_customers/unsynced/updated/updated_customers.dart';
import 'package:stockall/main.dart';

class UpdatedCustomersFunc {
  static final UpdatedCustomersFunc instance =
      UpdatedCustomersFunc._internal();
  factory UpdatedCustomersFunc() => instance;
  UpdatedCustomersFunc._internal();

  Box<UpdatedCustomers>? _updatedCustomersBox;
  final String updatedCustomersBoxName =
      'updatedCustomersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedCustomersAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedCustomersAdapter());
      await mainLocalLog(
        'Updated Customers Adapter registered ✅',
      );
    }

_updatedCustomersBox = await openBoxSafely<UpdatedCustomers>(updatedCustomersBoxName);
  }

  /// Safe getter for the box
  Box<UpdatedCustomers> get updatedCustomersBox {
    if (_updatedCustomersBox == null) {
      throw Exception(
        "Updated Customers Func not initialized. Call await updated Customers Func.instance.init() first.",
      );
    }
    return _updatedCustomersBox!;
  }

  List<UpdatedCustomers> getCustomers() {
    try {
      if (_updatedCustomersBox == null) return [];
      return _updatedCustomersBox!.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> createUpdatedCustomer(
    UpdatedCustomers updatedCustomer,
  ) async {
    try {
      updatedCustomer.customer.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedCustomersBox.put(
        updatedCustomer.customer.uuid,
        updatedCustomer,
      );
      await mainLocalLog(
        'Offline updated Customer inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Customer insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedCustomer(String uuid) async {
    try {
      await mainLocalLog(
        updatedCustomersBox.containsKey(uuid).toString(),
      );
      await updatedCustomersBox.delete(uuid);
      await mainLocalLog('Updated Customer Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Customer Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearupdatedCustomers() async {
    try {
      await updatedCustomersBox.clear();
      await mainLocalLog('All updated Customers cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Customers ❌: $e',
      );
      return 0;
    }
  }
}
