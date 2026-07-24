import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/main.dart';

class CustomerFunc {
  static final CustomerFunc instance =
      CustomerFunc._internal();
  factory CustomerFunc() => instance;
  CustomerFunc._internal();
  late Box<TempCustomersClass> customerBox;
  final String customerBoxName = 'customerBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(TempCustomersClassAdapter());
      customerBox = await Hive.openBox(customerBoxName);
      await CreatedCustomersFunc().init();
      await DeletedCustomersFunc().init();
      await UpdatedCustomersFunc().init();
      await mainLocalLog('Customter Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Customer Func Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<TempCustomersClass> getCustomers() {
    List<TempCustomersClass> customers =
        customerBox.values.toList();
    customers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return customers;
  }

  Future<int> insertAllCustomers(
    List<TempCustomersClass> customers,
  ) async {
    await clearCustomers();
    try {
      for (var customer in customers) {
        await customerBox.put(customer.uuid, customer);
      }
      await mainLocalLog(
        'Offline Customers Inserted Successfully',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Customer insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createCustomer(
    TempCustomersClass customer,
  ) async {
    try {
      await customerBox.put(customer.uuid, customer);
      await mainLocalLog('Offline Customer Inserted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Customer Insert Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateCustomer(
    TempCustomersClass customer,
  ) async {
    try {
      customer.updatedAt = DateTime.now();
      await customerBox.put(customer.uuid, customer);
      await mainLocalLog('Offline Customer Updated');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Customer Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteCustomer(String uuid) async {
    try {
      await customerBox.delete(uuid);
      await mainLocalLog('Offline Customer Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Customer Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCustomers() async {
    try {
      await customerBox.clear().timeout(
        Duration(seconds: 2),
      );
      await mainLocalLog('Offline Customers Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Error Clearing Offline Customers: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedCustomersFunc().getCustomers().isEmpty &&
        UpdatedCustomersFunc().getCustomers().isEmpty &&
        DeletedCustomersFunc().getCustomerIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
