import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/custom_label_printer_class/custom_label_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/custom_label_printer_class/custom_label_printer_settings/custom_label_printer_settings.dart';
import 'package:stockall/main.dart';

class CustomLabelPrinterFunc {
  static final CustomLabelPrinterFunc instance =
      CustomLabelPrinterFunc._internal();
  factory CustomLabelPrinterFunc() => instance;
  CustomLabelPrinterFunc._internal();
  late Box<CustomLabelPrinterLocal>
  customLabelPrinterLocalBox;
  final String customLabelPrinterLocalBoxName =
      'customLabelPrinterLocalBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(CustomLabelPrinterLocalAdapter());
    Hive.registerAdapter(
      CustomLabelPrinterSettingsAdapter(),
    );
    customLabelPrinterLocalBox = await Hive.openBox(
      customLabelPrinterLocalBoxName,
    );
    await mainLocalLog(
      '✅ Custom Labels Printer Box Initialized',
    );
  }

  CustomLabelPrinterLocal? getCustomLabelPrinterLocal() {
    return customLabelPrinterLocalBox.values.isNotEmpty
        ? customLabelPrinterLocalBox.values.first
        : null;
  }

  Future<int> insertCustomLabelPrinter(
    CustomLabelPrinterLocal customLabelPrinter,
  ) async {
    try {
      await clearCustomLabelPrinters();
      await customLabelPrinterLocalBox.put(
        customLabelPrinter.printer.name,
        customLabelPrinter,
      );
      await mainLocalLog(
        'Custom Labels Printer inserted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert Custom Labels Printer Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearCustomLabelPrinters() async {
    await customLabelPrinterLocalBox.clear();
    await mainLocalLog(
      'Offline Custom Labels Printer Cleared',
    );
  }
}
