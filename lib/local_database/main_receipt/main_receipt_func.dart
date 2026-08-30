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
