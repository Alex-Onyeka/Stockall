import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/created/created_customer_account_receipts_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/deleted/deleted_customer_account_receipts_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/updated/updated_customer_account_receipts_func.dart';
import 'package:stockall/main.dart';

class CustomerAccountReceiptsFunc {
  static final CustomerAccountReceiptsFunc instance =
      CustomerAccountReceiptsFunc._internal();
  factory CustomerAccountReceiptsFunc() => instance;
  CustomerAccountReceiptsFunc._internal();
  late Box<CustomerAccountReceipts>
  customerAccountReceiptsBox;
  final String customerAccountReceiptsBoxName =
      'customerAccountReceiptsBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(CustomerAccountReceiptsAdapter());
    customerAccountReceiptsBox =
        await openBoxSafely<CustomerAccountReceipts>(
          customerAccountReceiptsBoxName,
        );
    try {
      await CreatedCustomerAccountReceiptsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CreatedCustomerAccountReceiptsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await DeletedCustomerAccountReceiptsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing DeletedCustomerAccountReceiptsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await UpdatedCustomerAccountReceiptsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing UpdatedCustomerAccountReceiptsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await CustomerAccountUpdateFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CustomerAccountUpdateFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    await mainLocalLog(
      'Customer Account Receipts Box Initialized',
    );
  }

  List<CustomerAccountReceipts>
  getCustomerAccountReceipts() {
    try {
      List<CustomerAccountReceipts>
      customerAccountReceipts =
          customerAccountReceiptsBox.values.toList();
      customerAccountReceipts.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
      return customerAccountReceipts;
    } catch (e, s) {
      mainLocalLog(
        'Error reading customer account receipts: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<int> insertAllCustomerAccountReceipts(
    List<CustomerAccountReceipts> customerAccountReceipts,
  ) async {
    await clearCustomerAccountReceipts();
    try {
      for (var productionRecord
          in customerAccountReceipts) {
        await customerAccountReceiptsBox.put(
          productionRecord.uuid,
          productionRecord,
        );
      }
      await mainLocalLog(
        'Offline Customer Account Receipts Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Customer Account Receipts Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createCustomerAccountReceipts(
    CustomerAccountReceipts customerAccountReceipts,
  ) async {
    try {
      await customerAccountReceiptsBox.put(
        customerAccountReceipts.uuid,
        customerAccountReceipts,
      );
      await mainLocalLog(
        'Offline Customer Account Receipts Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Customer Account Receipts Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateCustomerAccountReceipts(
    CustomerAccountReceipts customerAccountReceipts,
  ) async {
    try {
      await customerAccountReceiptsBox.put(
        customerAccountReceipts.uuid,
        customerAccountReceipts,
      );
      await mainLocalLog(
        'Offline Customer Account Receipts Updated',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Customer Account Receipts Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteCustomerAccountReceipts(
    String uuid,
  ) async {
    try {
      await customerAccountReceiptsBox.delete(uuid);
      await mainLocalLog(
        'Offline Customer Account Receipts Deleted',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCustomerAccountReceipts() async {
    try {
      await customerAccountReceiptsBox.clear();
      await mainLocalLog(
        'Offline CustomerAccountReceipts Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Customer Account Receipts Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedCustomerAccountReceiptsFunc()
            .getCustomerAccountReceipts()
            .isEmpty &&
        UpdatedCustomerAccountReceiptsFunc()
            .getCustomerAccountReceiptsIds()
            .isEmpty &&
        DeletedCustomerAccountReceiptsFunc()
            .getCustomerAccountReceiptsIds()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
