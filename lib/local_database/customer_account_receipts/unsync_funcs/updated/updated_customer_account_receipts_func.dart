import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/updated/updated_customer_account_receipts.dart';
import 'package:stockall/main.dart';

class UpdatedCustomerAccountReceiptsFunc {
  static final UpdatedCustomerAccountReceiptsFunc instance =
      UpdatedCustomerAccountReceiptsFunc._internal();
  factory UpdatedCustomerAccountReceiptsFunc() => instance;
  UpdatedCustomerAccountReceiptsFunc._internal();

  Box<UpdatedCustomerAccountReceipts>?
  _updatedCustomerAccountReceiptsBox;
  final String updatedCustomerAccountReceiptsBoxName =
      'updatedCustomerAccountReceiptsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedCustomerAccountReceiptsAdapter().typeId,
    )) {
      Hive.registerAdapter(
        UpdatedCustomerAccountReceiptsAdapter(),
      );
      await mainLocalLog(
        'Updated Customer Account Receipts Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      updatedCustomerAccountReceiptsBoxName,
    )) {
      _updatedCustomerAccountReceiptsBox =
          await Hive.openBox<
            UpdatedCustomerAccountReceipts
          >(updatedCustomerAccountReceiptsBoxName);
      await mainLocalLog(
        'Updated Customer Account Receipts Box opened ✅',
      );
    } else {
      _updatedCustomerAccountReceiptsBox =
          Hive.box<UpdatedCustomerAccountReceipts>(
            updatedCustomerAccountReceiptsBoxName,
          );
      await mainLocalLog(
        'Updated Customer Account Receipts Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedCustomerAccountReceipts>
  get updatedCustomerAccountReceiptsBox {
    if (_updatedCustomerAccountReceiptsBox == null) {
      throw Exception(
        "Updated Customer Account Receipts Func not initialized. Call await updated Customer Account Receipts Func.instance.init() first.",
      );
    }
    return _updatedCustomerAccountReceiptsBox!;
  }

  List<UpdatedCustomerAccountReceipts>
  getCustomerAccountReceiptsIds() {
    return updatedCustomerAccountReceiptsBox.values
        .toList();
  }

  Future<int> createUpdatedCustomerAccountReceipts(
    UpdatedCustomerAccountReceipts
    updatedCustomerAccountReceipt,
  ) async {
    try {
      updatedCustomerAccountReceiptsBox.add(
        UpdatedCustomerAccountReceipts(
          updatedCustomerAccountReceipts:
              updatedCustomerAccountReceipt
                  .updatedCustomerAccountReceipts,
        ),
      );
      await mainLocalLog(
        'Offline Updated Customer Account Receipts inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Customer Account Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedCustomerAccountReceipts(
    UpdatedCustomerAccountReceipts
    updatedCustomerAccountReceipt,
  ) async {
    try {
      updatedCustomerAccountReceiptsBox.add(
        UpdatedCustomerAccountReceipts(
          updatedCustomerAccountReceipts:
              updatedCustomerAccountReceipt
                  .updatedCustomerAccountReceipts,
        ),
      );
      await mainLocalLog(
        'Offline Updated Customer Account Receipts Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Customer Account Receipts Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedCustomerAccountReceipts(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        updatedCustomerAccountReceiptsBox
            .containsKey(uuid)
            .toString(),
      );
      await updatedCustomerAccountReceiptsBox.delete(uuid);
      await mainLocalLog(
        'Updated Customer Account Receipts Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Customer Account Receipt Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int>
  clearUpdatedCustomerAccountReceiptsRecord() async {
    try {
      await updatedCustomerAccountReceiptsBox.clear();
      await mainLocalLog(
        'All updated Customer Account Receipts cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Customer Account Receipts ❌: $e',
      );
      return 0;
    }
  }
}
