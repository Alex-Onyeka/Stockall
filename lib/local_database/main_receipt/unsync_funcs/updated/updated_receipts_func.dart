import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/updated/updated_receipts.dart';
import 'package:stockall/main.dart';

class UpdatedReceiptsFunc {
  static final UpdatedReceiptsFunc instance =
      UpdatedReceiptsFunc._internal();
  factory UpdatedReceiptsFunc() => instance;
  UpdatedReceiptsFunc._internal();

  Box<UpdatedReceipts>? _updatedReceiptsBox;
  final String updatedReceiptsBoxName =
      'updatedReceiptsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedReceiptsAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedReceiptsAdapter());
      await mainLocalLog(
        'Updated Receipts Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedReceiptsBoxName)) {
      _updatedReceiptsBox =
          await Hive.openBox<UpdatedReceipts>(
            updatedReceiptsBoxName,
          );
      await mainLocalLog('Updated Receipts Box opened ✅');
    } else {
      _updatedReceiptsBox = Hive.box<UpdatedReceipts>(
        updatedReceiptsBoxName,
      );
      await mainLocalLog(
        'Updated Receipts Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedReceipts> get updatedReceiptsBox {
    if (_updatedReceiptsBox == null) {
      throw Exception(
        "Updated Receipts Func not initialized. Call await updated Receipts Func.instance.init() first.",
      );
    }
    return _updatedReceiptsBox!;
  }

  List<UpdatedReceipts> getReceiptIds() {
    return updatedReceiptsBox.values.toList();
  }

  Future<int> createUpdatedReceipt(
    String receiptUuid,
  ) async {
    try {
      updatedReceiptsBox.add(
        UpdatedReceipts(receiptUuid: receiptUuid),
      );
      await mainLocalLog(
        'Offline Updated Receipt inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Receipt insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedReceipt(String uuid) async {
    try {
      await mainLocalLog(
        updatedReceiptsBox.containsKey(uuid).toString(),
      );
      await updatedReceiptsBox.delete(uuid);
      await mainLocalLog('Updated Receipt Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Receipt Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedReceipts() async {
    try {
      await updatedReceiptsBox.clear();
      await mainLocalLog('All updated Receipts cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Receipts ❌: $e',
      );
      return 0;
    }
  }
}
