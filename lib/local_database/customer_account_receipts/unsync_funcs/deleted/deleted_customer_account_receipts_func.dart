import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/deleted/deleted_customer_account_receipts.dart';
import 'package:stockall/main.dart';

class DeletedCustomerAccountReceiptsFunc {
  static final DeletedCustomerAccountReceiptsFunc instance =
      DeletedCustomerAccountReceiptsFunc._internal();
  factory DeletedCustomerAccountReceiptsFunc() => instance;
  DeletedCustomerAccountReceiptsFunc._internal();

  Box<DeletedCustomerAccountReceipts>?
  _deletedCustomerAccountReceiptsBox;
  final String deletedCustomerAccountReceiptsBoxName =
      'deletedCustomerAccountReceiptsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedCustomerAccountReceiptsAdapter().typeId,
    )) {
      Hive.registerAdapter(
        DeletedCustomerAccountReceiptsAdapter(),
      );
      await mainLocalLog(
        'Deleted Customer Account Receiptss Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      deletedCustomerAccountReceiptsBoxName,
    )) {
      _deletedCustomerAccountReceiptsBox =
          await Hive.openBox<
            DeletedCustomerAccountReceipts
          >(deletedCustomerAccountReceiptsBoxName);
      await mainLocalLog(
        'Deleted Customer Account Receiptss Box opened ✅',
      );
    } else {
      _deletedCustomerAccountReceiptsBox =
          Hive.box<DeletedCustomerAccountReceipts>(
            deletedCustomerAccountReceiptsBoxName,
          );
      await mainLocalLog(
        'Deleted Customer Account Receiptss Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedCustomerAccountReceipts>
  get deletedCustomerAccountReceiptsBox {
    if (_deletedCustomerAccountReceiptsBox == null) {
      throw Exception(
        "Deleted Customer Account Receiptss Func not initialized. Call await Deleted Customer Account Receiptss Func.instance.init() first.",
      );
    }
    return _deletedCustomerAccountReceiptsBox!;
  }

  List<DeletedCustomerAccountReceipts>
  getCustomerAccountReceiptsIds() {
    return deletedCustomerAccountReceiptsBox.values
        .toList();
  }

  Future<int> insertAllDeletedCustomerAccountReceipts(
    List<DeletedCustomerAccountReceipts>
    deletedCustomerAccountReceipts,
  ) async {
    try {
      for (var customerAccountReceipt
          in deletedCustomerAccountReceipts) {
        await deletedCustomerAccountReceiptsBox.add(
          customerAccountReceipt,
        );
      }
      await mainLocalLog(
        "Offline Deleted Customer Account Receiptss inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Customer Account Receiptss insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedCustomerAccountReceipts(
    DeletedCustomerAccountReceipts
    deletedCustomerAccountReceipts,
  ) async {
    try {
      await deletedCustomerAccountReceiptsBox.add(
        deletedCustomerAccountReceipts,
      );
      await mainLocalLog(
        'Offline Deleted Customer Account Receiptss inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Customer Account Receiptss insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedCustomerAccountReceipts(
    String uuid,
  ) async {
    try {
      await deletedCustomerAccountReceiptsBox.delete(uuid);
      await mainLocalLog(
        'Delete Customer Account Receiptss cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Customer Account Receiptss ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedCustomerAccountReceipts() async {
    try {
      await deletedCustomerAccountReceiptsBox.clear();
      await mainLocalLog(
        'All Deleted Customer Account Receiptss cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Customer Account Receiptss ❌: $e',
      );
      return 0;
    }
  }
}
