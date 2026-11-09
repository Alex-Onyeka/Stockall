import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
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
    safeRegisterAdapter(TempMainReceiptAdapter());
    receiptBox = await openBoxSafely<TempMainReceipt>(
      receiptBoxName,
    );
    try {
      await CreatedReceiptsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing CreatedReceiptsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await DeletedReceiptsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing DeletedReceiptsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    try {
      await UpdatedReceiptsFunc().init();
    } catch (e, s) {
      await mainLocalLog(
        'Error initializing UpdatedReceiptsFunc: $e',
        error: e,
        stackTrace: s,
      );
    }
    await mainLocalLog('Receipt Box Initialized');
  }

  List<TempMainReceipt> getReceipts() {
    try {
      List<TempMainReceipt> receipts =
          receiptBox.values.toList();
      receipts.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      return receipts;
    } catch (e, s) {
      mainLocalLog(
        'Error reading receipts: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  TempMainReceipt? getSingleReceipt({
    required String uuid,
  }) {
    try {
      return receiptBox.get(uuid);
    } catch (e, s) {
      mainLocalLog(
        'Error reading single receipt $uuid: $e',
        error: e,
        stackTrace: s,
      );
      return null;
    }
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
