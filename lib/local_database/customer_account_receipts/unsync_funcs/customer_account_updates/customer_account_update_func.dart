import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/main.dart';

class CustomerAccountUpdateFunc {
  static final CustomerAccountUpdateFunc instance =
      CustomerAccountUpdateFunc._internal();
  factory CustomerAccountUpdateFunc() => instance;
  CustomerAccountUpdateFunc._internal();

  Box<CustomerAccountUpdate>? _customerAccountUpdateBox;
  final String customerAccountUpdateBoxName =
      'customerAccountUpdateBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(
        CustomerAccountUpdateAdapter().typeId,
      )) {
        Hive.registerAdapter(
          CustomerAccountUpdateAdapter(),
        );
        await mainLocalLog(
          'Customer Account Update Adapter registered ✅',
        );
      }

      // Open the box only if it isn’t already open
      if (!Hive.isBoxOpen(customerAccountUpdateBoxName)) {
        _customerAccountUpdateBox =
            await Hive.openBox<CustomerAccountUpdate>(
              customerAccountUpdateBoxName,
            );
        await mainLocalLog(
          'Customer Account Update Box opened ✅',
        );
      } else {
        _customerAccountUpdateBox =
            Hive.box<CustomerAccountUpdate>(
              customerAccountUpdateBoxName,
            );
        await mainLocalLog(
          'Customer Account Update Box already open, reused ✅',
        );
      }
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Quantitiy Update Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Safe getter for the box
  Box<CustomerAccountUpdate> get customerAccountUpdateBox {
    if (_customerAccountUpdateBox == null) {
      throw Exception(
        " Customer Account Update Func not initialized. Call await CustomerAccountUpdateFunc.instance.init() first.",
      );
    }
    return _customerAccountUpdateBox!;
  }

  List<CustomerAccountUpdate> getQuantitiesUpdate() {
    return customerAccountUpdateBox.values.toList();
  }

  Future<int> createCustomerAccountUpdate(
    CustomerAccountUpdate customerAccountUpdate,
  ) async {
    try {
      final existingLogs = getQuantitiesUpdate().where(
        (item) =>
            item.customerUuid ==
            customerAccountUpdate.customerUuid,
      );

      if (existingLogs.isEmpty) {
        await customerAccountUpdateBox.put(
          customerAccountUpdate.uuid,
          customerAccountUpdate,
        );

        await mainLocalLog(
          'Offline Customer Account Update inserted successfully ✅',
        );
      } else {
        final existing = existingLogs.first;

        // Convert both values to signed numbers
        final double existingValue =
            existing.isIncrement
                ? existing.amount
                : -existing.amount;

        final double incomingValue =
            customerAccountUpdate.isIncrement
                ? customerAccountUpdate.amount
                : -customerAccountUpdate.amount;

        // Calculate the net value
        final double total = existingValue + incomingValue;

        // Convert back to absolute customerAccount + direction
        existing.amount = total.abs();
        existing.isIncrement = total >= 0;

        // Save to Hive
        await customerAccountUpdateBox.put(
          existing.uuid,
          existing,
        );

        await mainLocalLog(
          'Offline Customer Account Update merged successfully ✅',
        );
      }

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Customer Account Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteCustomerAccountUpdate({
    required String uuid,
  }) async {
    try {
      await customerAccountUpdateBox.delete(uuid);
      await mainLocalLog(
        'Customer Account Update Deleted ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Customer Account Update ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearQuantitiesUpdate() async {
    try {
      await customerAccountUpdateBox.clear();
      await mainLocalLog(
        'All Customer Account Update cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Customer Account Update ❌: $e',
      );
      return 0;
    }
  }
}
