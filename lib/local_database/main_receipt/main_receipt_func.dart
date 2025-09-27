import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';

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
    print('Receipt Box Initialized');
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
      print('Offline Receipt Success');
      return 1;
    } catch (e) {
      print('Offline Receipt Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createReceipt(TempMainReceipt rec) async {
    try {
      await receiptBox.put(rec.uuid, rec);
      print('Offline Receipt Created');
      return 1;
    } catch (e) {
      print('Offline Receipt Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteReceipt(String uuid) async {
    try {
      await receiptBox.delete(uuid);
      print('Offline Receipt Deleted');
      return 1;
    } catch (e) {
      print('Offline Delete Failed: ${e.toString()}');
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

        print('Offline Receipt Sale Updated Successfully');
        return 1;
      } else {
        print('receipt not found in box ❌');
        return 0;
      }
    } catch (e) {
      print(
        'Offline Receipt Sale Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearReceipts() async {
    try {
      await receiptBox.clear();
      print('Offline Receipts Cleared');
      return 1;
    } catch (e) {
      print(
        'Offline Receipt Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
