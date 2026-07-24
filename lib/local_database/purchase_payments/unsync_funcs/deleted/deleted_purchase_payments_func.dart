import 'package:hive/hive.dart';
import 'package:stockall/classes/purchase_payments/unsynced/deleted_purchase_payments/deleted_purchase_payments.dart';
import 'package:stockall/main.dart';

class DeletedPurchasePaymentsFunc {
  static final DeletedPurchasePaymentsFunc instance =
      DeletedPurchasePaymentsFunc._internal();
  factory DeletedPurchasePaymentsFunc() => instance;
  DeletedPurchasePaymentsFunc._internal();

  Box<DeletedPurchasePayments>? _deletedPurchasePaymentsBox;
  final String deletedPurchasePaymentsBoxName =
      'deletedPurchasePaymentsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedPurchasePaymentsAdapter().typeId,
    )) {
      Hive.registerAdapter(
        DeletedPurchasePaymentsAdapter(),
      );
      await mainLocalLog(
        'Deleted PurchasePayments Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedPurchasePaymentsBoxName)) {
      _deletedPurchasePaymentsBox =
          await Hive.openBox<DeletedPurchasePayments>(
            deletedPurchasePaymentsBoxName,
          );
      await mainLocalLog(
        'Deleted PurchasePayments Box opened ✅',
      );
    } else {
      _deletedPurchasePaymentsBox =
          Hive.box<DeletedPurchasePayments>(
            deletedPurchasePaymentsBoxName,
          );
      await mainLocalLog(
        'Deleted PurchasePayments Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedPurchasePayments>
  get deletedPurchasePaymentsBox {
    if (_deletedPurchasePaymentsBox == null) {
      throw Exception(
        "Deleted Purchase Payments Func not initialized. Call await Deleted Purchase Payments Func.instance.init() first.",
      );
    }
    return _deletedPurchasePaymentsBox!;
  }

  List<DeletedPurchasePayments> getPurchaseIds() {
    return deletedPurchasePaymentsBox.values.toList();
  }

  Future<int> insertAllDeletedPurchasePayments(
    List<DeletedPurchasePayments> deletedPurchasePayments,
  ) async {
    try {
      for (var purchase in deletedPurchasePayments) {
        await deletedPurchasePaymentsBox.add(purchase);
      }
      await mainLocalLog(
        "Offline Deleted Purchase Payments inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Purchase Payments insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedPurchasePayment(
    DeletedPurchasePayments deletedPurchasePayment,
  ) async {
    try {
      await deletedPurchasePaymentsBox.add(
        deletedPurchasePayment,
      );
      await mainLocalLog(
        'Offline Deleted Purchase Payment inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Purchase Payment insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedPurchasePayments(
    String uuid,
  ) async {
    try {
      await deletedPurchasePaymentsBox.delete(uuid);
      await mainLocalLog(
        'Delete Purchase Payment cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Purchase Payment ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedPurchasePayments() async {
    try {
      await deletedPurchasePaymentsBox.clear();
      await mainLocalLog(
        'All Deleted Purchase Payments cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Purchase Payments ❌: $e',
      );
      return 0;
    }
  }
}
