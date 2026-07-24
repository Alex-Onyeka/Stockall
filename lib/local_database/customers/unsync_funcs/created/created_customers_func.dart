import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/main.dart';

class CreatedCustomersFunc {
  static final CreatedCustomersFunc instance =
      CreatedCustomersFunc._internal();
  factory CreatedCustomersFunc() => instance;
  CreatedCustomersFunc._internal();

  Box<CreatedCustomers>? _createdCustomersBox;
  final String createdCustomersBoxName =
      'createdCustomersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedCustomersAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedCustomersAdapter());
      await mainLocalLog(
        'Created Customers Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdCustomersBoxName)) {
      _createdCustomersBox =
          await Hive.openBox<CreatedCustomers>(
            createdCustomersBoxName,
          );
      await mainLocalLog('Created Customers Box opened ✅');
    } else {
      _createdCustomersBox = Hive.box<CreatedCustomers>(
        createdCustomersBoxName,
      );
      await mainLocalLog(
        'Created Customers Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedCustomers> get createdCustomersBox {
    if (_createdCustomersBox == null) {
      throw Exception(
        "Created Customers Func not initialized. Call await CreatedCustomersFunc.instance.init() first.",
      );
    }
    return _createdCustomersBox!;
  }

  List<CreatedCustomers> getCustomers() {
    List<CreatedCustomers> customers =
        createdCustomersBox.values.toList();
    customers.sort(
      (a, b) => a.customer.name.compareTo(b.customer.name),
    );
    return customers;
  }

  Future<int> insertAllCustomers(
    List<CreatedCustomers> createdCustomers,
  ) async {
    try {
      for (var customers in createdCustomers) {
        await createdCustomersBox.put(
          customers.customer.uuid,
          customers,
        );
      }
      await mainLocalLog(
        "Offline Created Customers inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Customers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createCustomers(
    CreatedCustomers createdCustomers,
  ) async {
    try {
      await createdCustomersBox.put(
        createdCustomers.customer.uuid,
        createdCustomers,
      );
      await mainLocalLog(
        'Offline Created Customers inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Customers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCustomers(
    CreatedCustomers createdCustomers,
  ) async {
    try {
      await createdCustomersBox.put(
        createdCustomers.customer.uuid,
        createdCustomers,
      );
      await mainLocalLog(
        'Offline Created Customers inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Customers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteCustomer(String uuid) async {
    try {
      await mainLocalLog(
        createdCustomersBox.containsKey(uuid).toString(),
      );
      await createdCustomersBox.delete(uuid);
      await mainLocalLog('Customers Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Customers Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCustomers() async {
    try {
      await createdCustomersBox.clear();
      await mainLocalLog('All Created Customers cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Customers ❌: $e',
      );
      return 0;
    }
  }
}
