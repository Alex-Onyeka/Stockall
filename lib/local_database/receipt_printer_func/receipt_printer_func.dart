import 'package:hive/hive.dart';
import 'package:stockall/classes/receipt_printer_class/receipt_printer_class.dart';
import 'package:stockall/main.dart';

class ReceiptPrinterFunc {
  static final ReceiptPrinterFunc instance =
      ReceiptPrinterFunc._internal();
  factory ReceiptPrinterFunc() => instance;
  ReceiptPrinterFunc._internal();
  late Box<ReceiptPrinterClass> receiptPrinterBox;
  final String receiptPrinterBoxName =
      'receiptPrinterBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(receiptPrinterBoxName);
    Hive.registerAdapter(ReceiptPrinterClassAdapter());
    receiptPrinterBox = await Hive.openBox(
      receiptPrinterBoxName,
    );
    await mainLocalLog('✅Receipt Printer Box Initialized');
  }

  ReceiptPrinterClass? getReceiptPrinterClass() {
    return receiptPrinterBox.values.isNotEmpty
        ? receiptPrinterBox.values.first
        : null;
  }

  Future<int> insertPrinter(
    ReceiptPrinterClass receiptPrinter,
  ) async {
    await clearPrinters();
    try {
      await receiptPrinterBox.put(
        receiptPrinter.printerName,
        receiptPrinter,
      );
      await mainLocalLog(
        'Printer inserted Success: Name: ${receiptPrinter.printerName}  |  Size: ${receiptPrinter.printerSize}',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert Printer Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearPrinters() async {
    await receiptPrinterBox.clear();
    await mainLocalLog('Offline Printer Cleared');
  }
}
