import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';

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
    print('Receipt Box Initialized');
  }

  List<TempMainReceipt> getReceipts() {
    return receiptBox.values.toList();
  }

  Future<int> insertAllReceipts(
    List<TempMainReceipt> receipts,
  ) async {
    try {
      for (var rec in receipts) {
        await receiptBox.put(rec.id, rec);
      }
      print('Offline Receipt Success');
      return 1;
    } catch (e) {
      print('Offline Receipt Failed: ${e.toString()}');
      return 0;
    }
  }
}
