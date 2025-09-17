import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';

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
    print('Customter Box Initialized');
  }

  List<TempCustomersClass> getCustomers() {
    return customerBox.values.toList();
  }

  Future<int> insertAllCustomers(
    List<TempCustomersClass> customers,
  ) async {
    try {
      for (var customer in customers) {
        await customerBox.put(customer.id, customer);
      }
      print('Offline Customers Inserted Successfully');
      return 1;
    } catch (e) {
      print(
        'Offline Customer insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
