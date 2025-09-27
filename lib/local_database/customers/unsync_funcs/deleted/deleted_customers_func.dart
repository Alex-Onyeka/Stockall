import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/unsynced/deleted_customers/deleted_customers.dart';

class DeletedCustomersFunc {
  static final DeletedCustomersFunc instance =
      DeletedCustomersFunc._internal();
  factory DeletedCustomersFunc() => instance;
  DeletedCustomersFunc._internal();

  Box<DeletedCustomers>? _deletedCustomersBox;
  final String deletedCustomersBoxName =
      'deletedCustomersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedCustomersAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedCustomersAdapter());
      print('Deleted Customers Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedCustomersBoxName)) {
      _deletedCustomersBox =
          await Hive.openBox<DeletedCustomers>(
            deletedCustomersBoxName,
          );
      print('Deleted Customers Box opened ✅');
    } else {
      _deletedCustomersBox = Hive.box<DeletedCustomers>(
        deletedCustomersBoxName,
      );
      print('Deleted Customers Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<DeletedCustomers> get deletedCustomersBox {
    if (_deletedCustomersBox == null) {
      throw Exception(
        "Deleted Customers Func not initialized. Call await Deleted Customers Func.instance.init() first.",
      );
    }
    return _deletedCustomersBox!;
  }

  List<DeletedCustomers> getCustomerIds() {
    return deletedCustomersBox.values.toList();
  }

  Future<int> insertAllDeletedCustomers(
    List<DeletedCustomers> deletedCustomers,
  ) async {
    try {
      for (var customer in deletedCustomers) {
        await deletedCustomersBox.add(customer);
      }
      print("Offline Deleted Customers inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Customers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedCustomer(
    DeletedCustomers deletedCustomer,
  ) async {
    try {
      await deletedCustomersBox.add(deletedCustomer);
      print(
        'Offline Deleted Customer inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Customer insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedCustomers() async {
    try {
      await deletedCustomersBox.clear();
      print('All Deleted Customers cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Customers ❌: $e');
      return 0;
    }
  }
}
