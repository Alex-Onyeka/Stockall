import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';

class CustomerFunc {
  static final CustomerFunc instance =
      CustomerFunc._internal();
  factory CustomerFunc() => instance;
  CustomerFunc._internal();
  late Box<TempCustomersClass> customerBox;
  final String customerBoxName = 'customerBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempCustomersClassAdapter());
    customerBox = await Hive.openBox(customerBoxName);
    await CreatedCustomersFunc().init();
    await DeletedCustomersFunc().init();
    await UpdatedCustomersFunc().init();
    print('Customter Box Initialized');
  }

  List<TempCustomersClass> getCustomers() {
    List<TempCustomersClass> customers =
        customerBox.values.toList();
    customers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    print('Customers Gotten: ${customers.length}');

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
      print('Offline Customers Inserted Successfullyy');
      return 1;
    } catch (e) {
      print(
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
      print('Offline Customer Inserted');
      return 1;
    } catch (e) {
      print('Customer Insert Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> updateCustomer(
    TempCustomersClass customer,
  ) async {
    try {
      customer.updatedAt = DateTime.now();
      await customerBox.put(customer.uuid, customer);
      print('Offline Customer Updated');
      return 1;
    } catch (e) {
      print('Customer Update Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteCustomer(String uuid) async {
    try {
      await customerBox.delete(uuid);
      print('Offline Customer Deleted');
      return 1;
    } catch (e) {
      print('Customer Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearCustomers() async {
    try {
      await customerBox.clear();
      print('Offline Customers Cleared');
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }
}
