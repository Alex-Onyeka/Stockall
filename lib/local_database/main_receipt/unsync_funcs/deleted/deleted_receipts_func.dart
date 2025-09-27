import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';

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
      print('Deleted Receipts Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedReceiptsBoxName)) {
      _deletedReceiptsBox =
          await Hive.openBox<DeletedReceipts>(
            deletedReceiptsBoxName,
          );
      print('Deleted Receipts Box opened ✅');
    } else {
      _deletedReceiptsBox = Hive.box<DeletedReceipts>(
        deletedReceiptsBoxName,
      );
      print('Deleted Receipts Box already open, reused ✅');
    }
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
      print("Offline Deleted Receipts inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedReceipt(
    DeletedReceipts deletedReceipt,
  ) async {
    try {
      await deletedReceiptsBox.add(deletedReceipt);
      print(
        'Offline Deleted Receipt inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Receipt insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedReceipts(String uuid) async {
    try {
      await deletedReceiptsBox.delete(uuid);
      print('Delete Receipt cleared ✅');
      return 1;
    } catch (e) {
      print('Error while Deleting Deleted Receipt ❌: $e');
      return 0;
    }
  }

  Future<int> clearDeletedReceipts() async {
    try {
      await deletedReceiptsBox.clear();
      print('All Deleted Receipts cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Receipts ❌: $e');
      return 0;
    }
  }
}
