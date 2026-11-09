import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/barcode_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/printer_settings/printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/local_database/barcode_printer_func/custom_label_printer_func.dart';
import 'package:stockall/main.dart';

class BarcodePrinterLocalFunc {
  static final BarcodePrinterLocalFunc instance =
      BarcodePrinterLocalFunc._internal();
  factory BarcodePrinterLocalFunc() => instance;
  BarcodePrinterLocalFunc._internal();
  late Box<BarcodePrinterLocal> barcodePrinterLocalBox;
  final String barcodePrinterLocalBoxName =
      'barcodePrinterLocalBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(BarcodePrinterLocalAdapter());
    safeRegisterAdapter(TempBarcodePrinterClassAdapter());
    safeRegisterAdapter(PrinterSettingsAdapter());
    barcodePrinterLocalBox = await openBoxSafely<BarcodePrinterLocal>(
      barcodePrinterLocalBoxName,
    );
    try {
      await CustomLabelPrinterFunc().init();
    } catch (e, s) {
      await mainLocalLog('Error initializing CustomLabelPrinterFunc: $e', error: e, stackTrace: s);
    }
    await mainLocalLog('✅ Barcode Printer Box Initialized');
  }

  BarcodePrinterLocal? getbarcodePrinterLocal() {
    try {
      return barcodePrinterLocalBox.values.isNotEmpty
          ? barcodePrinterLocalBox.values.first
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<int> insertbarcodePrinter(
    BarcodePrinterLocal barcodePrinter,
  ) async {
    try {
      await clearbarcodePrinters();
      await barcodePrinterLocalBox.put(
        barcodePrinter.printer.name,
        barcodePrinter,
      );
      await mainLocalLog('BarcodePrinter inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert BarcodePrinter Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearbarcodePrinters() async {
    await barcodePrinterLocalBox.clear();
    await mainLocalLog('Offline barcodePrinter Cleared');
  }
}
