import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';
import 'package:stockall/main.dart';

class DeletedReceiptsFunc {
  static final DeletedReceiptsFunc instance =
      DeletedReceiptsFunc._internal();
  factory DeletedReceiptsFunc() => instance;
  DeletedReceiptsFunc._internal();

  Box<DeletedReceipts>? _deletedReceiptsBox;
  final String deletedReceiptsBoxName =
      'deletedReceiptsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedReceiptsAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedReceiptsAdapter());
      await mainLocalLog(
        'Deleted Receipts Adapter registered ✅',
      );
    }

    _deletedReceiptsBox =
        await openBoxSafely<DeletedReceipts>(
          deletedReceiptsBoxName,
        );
  }

  /// Safe getter for the box
  Box<DeletedReceipts> get deletedReceiptsBox {
    if (_deletedReceiptsBox == null) {
      throw Exception(
        "Deleted Receipts Func not initialized. Call await Deleted Receipts Func.instance.init() first.",
      );
    }
    return _deletedReceiptsBox!;
  }

  List<DeletedReceipts> getReceiptIds() {
    return deletedReceiptsBox.values.toList();
  }

  Future<int> insertAllDeletedReceipts(
    List<DeletedReceipts> deletedReceipts,
  ) async {
    try {
      for (var receipt in deletedReceipts) {
        await deletedReceiptsBox.add(receipt);
      }
      await mainLocalLog(
        "Offline Deleted Receipts inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedReceipt(
    DeletedReceipts deletedReceipt,
  ) async {
    try {
      await deletedReceiptsBox.put(
        deletedReceipt.receiptUuid,
        deletedReceipt,
      );
      await mainLocalLog(
        'Offline Deleted Receipt inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Receipt insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedReceipts(String uuid) async {
    try {
      await deletedReceiptsBox.delete(uuid);
      final keysToDelete = <dynamic>[];
      for (var key in deletedReceiptsBox.keys) {
        final val = deletedReceiptsBox.get(key);
        if (val != null && val.receiptUuid == uuid) {
          keysToDelete.add(key);
        }
      }
      for (var key in keysToDelete) {
        await deletedReceiptsBox.delete(key);
      }
      await mainLocalLog('Delete Receipt cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Receipt ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedReceipts() async {
    try {
      await deletedReceiptsBox.clear();
      await mainLocalLog('All Deleted Receipts cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Receipts ❌: $e',
      );
      return 0;
    }
  }
}
