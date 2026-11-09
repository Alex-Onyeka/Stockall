import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_customers/unsynced/deleted_customers/deleted_customers.dart';
import 'package:stockall/main.dart';

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
      await mainLocalLog(
        'Deleted Customers Adapter registered ✅',
      );
    }

    _deletedCustomersBox =
        await openBoxSafely<DeletedCustomers>(
          deletedCustomersBoxName,
        );
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
    try {
      if (_deletedCustomersBox == null) return [];
      return _deletedCustomersBox!.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAllDeletedCustomers(
    List<DeletedCustomers> deletedCustomers,
  ) async {
    try {
      for (var customer in deletedCustomers) {
        await deletedCustomersBox.add(customer);
      }
      await mainLocalLog(
        "Offline Deleted Customers inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
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
      await mainLocalLog(
        'Offline Deleted Customer inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Customer insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedCustomers() async {
    try {
      await deletedCustomersBox.clear();
      await mainLocalLog('All Deleted Customers cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Customers ❌: $e',
      );
      return 0;
    }
  }
}
