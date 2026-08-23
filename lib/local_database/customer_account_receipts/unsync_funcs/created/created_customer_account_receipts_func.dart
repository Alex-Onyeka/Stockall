import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/created/created_customer_account_receipts.dart';
import 'package:stockall/main.dart';

class CreatedCustomerAccountReceiptsFunc {
  static final CreatedCustomerAccountReceiptsFunc instance =
      CreatedCustomerAccountReceiptsFunc._internal();
  factory CreatedCustomerAccountReceiptsFunc() => instance;
  CreatedCustomerAccountReceiptsFunc._internal();

  Box<CreatedCustomerAccountReceipts>?
  _createdCustomerAccountReceiptsBox;
  final String createdCustomerAccountReceiptsBoxName =
      'createdCustomerAccountReceiptsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedCustomerAccountReceiptsAdapter().typeId,
    )) {
      Hive.registerAdapter(
        CreatedCustomerAccountReceiptsAdapter(),
      );
      await mainLocalLog(
        'Created Customer Account Receipts Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(
      createdCustomerAccountReceiptsBoxName,
    )) {
      _createdCustomerAccountReceiptsBox =
          await Hive.openBox<
            CreatedCustomerAccountReceipts
          >(createdCustomerAccountReceiptsBoxName);
      await mainLocalLog(
        'Created Customer Account Receipts Box opened ✅',
      );
    } else {
      _createdCustomerAccountReceiptsBox =
          Hive.box<CreatedCustomerAccountReceipts>(
            createdCustomerAccountReceiptsBoxName,
          );
      await mainLocalLog(
        'Created Customer Account Receipts Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedCustomerAccountReceipts>
  get createdCustomerAccountReceiptsBox {
    if (_createdCustomerAccountReceiptsBox == null) {
      throw Exception(
        "Created Customer Account Receipts Func not initialized. Call await CreatedCustomerAccountReceiptsFunc.instance.init() first.",
      );
    }
    return _createdCustomerAccountReceiptsBox!;
  }

  List<CreatedCustomerAccountReceipts>
  getCustomerAccountReceipts() {
    List<CreatedCustomerAccountReceipts>
    customerAccountReceipts =
        createdCustomerAccountReceiptsBox.values.toList();
    customerAccountReceipts.sort(
      (a, b) => a.createdCustomerAccountReceipts.createdAt!
          .compareTo(
            b.createdCustomerAccountReceipts.createdAt!,
          ),
    );
    return customerAccountReceipts;
  }

  Future<int> insertAllCustomerAccountReceipts(
    List<CreatedCustomerAccountReceipts>
    createdCustomerAccountReceipts,
  ) async {
    try {
      for (var customerAccountReceipts
          in createdCustomerAccountReceipts) {
        await createdCustomerAccountReceiptsBox.put(
          customerAccountReceipts
              .createdCustomerAccountReceipts
              .uuid,
          customerAccountReceipts,
        );
      }
      await mainLocalLog(
        "Offline Created Customer Account Receipts inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Customer Account Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createCustomerAccountReceipts(
    CreatedCustomerAccountReceipts
    createdCustomerAccountReceipts,
  ) async {
    try {
      await createdCustomerAccountReceiptsBox.put(
        createdCustomerAccountReceipts
            .createdCustomerAccountReceipts
            .uuid,
        createdCustomerAccountReceipts,
      );
      await mainLocalLog(
        'Offline Created Customer Account Receipts inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Customer Account Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCreatedCustomerAccountReceipts(
    CreatedCustomerAccountReceipts
    createdCustomerAccountReceipts,
  ) async {
    try {
      await createdCustomerAccountReceiptsBox.put(
        createdCustomerAccountReceipts
            .createdCustomerAccountReceipts
            .uuid,
        createdCustomerAccountReceipts,
      );
      await mainLocalLog(
        'Offline Created Customer Account Receipts Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Customer Account Receipts Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteCustomerAccountReceipt(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        createdCustomerAccountReceiptsBox
            .containsKey(uuid)
            .toString(),
      );
      await createdCustomerAccountReceiptsBox.delete(uuid);
      await mainLocalLog(
        'Created CustomerAccountReceipt Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created CustomerAccountReceipt Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCustomerAccountReceipts() async {
    try {
      await createdCustomerAccountReceiptsBox.clear();
      await mainLocalLog(
        'All Created Customer Account Receipts cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Customer Account Receipts ❌: $e',
      );
      return 0;
    }
  }
}
