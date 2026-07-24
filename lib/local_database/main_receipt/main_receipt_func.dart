import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/main.dart';

class MainReceiptFunc {
  static final MainReceiptFunc instance =
      MainReceiptFunc._internal();
  factory MainReceiptFunc() => instance;
  MainReceiptFunc._internal();
  late Box<TempMainReceipt> receiptBox;
  final String receiptBoxName = 'mainReceiptBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempMainReceiptAdapter());
    receiptBox = await Hive.openBox(receiptBoxName);
    await CreatedReceiptsFunc().init();
    await DeletedReceiptsFunc().init();
    await UpdatedReceiptsFunc().init();
    await mainLocalLog('Receipt Box Initialized');
  }

  List<TempMainReceipt> getReceipts() {
    List<TempMainReceipt> receipts =
        receiptBox.values.toList();
    receipts.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    return receipts;
  }

  Future<int> insertAllReceipts(
    List<TempMainReceipt> receipts,
  ) async {
    await clearReceipts();
    try {
      for (var rec in receipts) {
        await receiptBox.put(rec.uuid, rec);
      }
      await mainLocalLog('Offline Receipt Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Receipt Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createReceipt(TempMainReceipt rec) async {
    // var newRec = rec.copyWith();
    // newRec.createdAt.add(Duration(hours: 1));
    try {
      await receiptBox.put(rec.uuid, rec);
      await mainLocalLog('Offline Receipt Created');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Receipt Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteReceipt(String uuid) async {
    try {
      await receiptBox.delete(uuid);
      await mainLocalLog('Offline Receipt Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> payCredit(String uuid) async {
    try {
      var receipt = receiptBox.get(uuid);
      if (receipt != null) {
        receipt.isInvoice = false;
        receipt.createdAt = DateTime.now();

        // Save back into Hive explicitly
        await receiptBox.put(uuid, receipt);

        await mainLocalLog(
          'Offline Receipt Sale Updated Successfully',
        );
        return 1;
      } else {
        await mainLocalLog('receipt not found in box ❌');
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        'Offline Receipt Sale Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearReceipts() async {
    try {
      await receiptBox.clear();
      await mainLocalLog('Offline Receipts Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Receipt Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedReceiptsFunc().getReceipts().isEmpty &&
        UpdatedReceiptsFunc().getReceiptIds().isEmpty &&
        DeletedReceiptsFunc().getReceiptIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
