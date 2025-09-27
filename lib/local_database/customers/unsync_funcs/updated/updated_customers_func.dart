import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/unsynced/updated/updated_customers.dart';

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
      print('Updated Customers Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedCustomersBoxName)) {
      _updatedCustomersBox =
          await Hive.openBox<UpdatedCustomers>(
            updatedCustomersBoxName,
          );
      print('Updated Customers Box opened ✅');
    } else {
      _updatedCustomersBox = Hive.box<UpdatedCustomers>(
        updatedCustomersBoxName,
      );
      print('Updated Customers Box already open, reused ✅');
    }
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
    return updatedCustomersBox.values.toList();
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
      print(
        'Offline updated Customer inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Customer insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedCustomer(String uuid) async {
    try {
      print(
        updatedCustomersBox.containsKey(uuid).toString(),
      );
      await updatedCustomersBox.delete(uuid);
      print('Updated Customer Deleted');
      return 1;
    } catch (e) {
      print('Customer Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearupdatedCustomers() async {
    try {
      await updatedCustomersBox.clear();
      print('All updated Customers cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Customers ❌: $e');
      return 0;
    }
  }
}
