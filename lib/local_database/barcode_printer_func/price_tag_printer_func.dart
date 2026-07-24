import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_tag_printer_class/price_tag_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_tag_printer_class/price_tag_printer_settings/price_tag_printer_settings.dart';
import 'package:stockall/main.dart';

class PriceTagPrinterFunc {
  static final PriceTagPrinterFunc instance =
      PriceTagPrinterFunc._internal();
  factory PriceTagPrinterFunc() => instance;
  PriceTagPrinterFunc._internal();
  late Box<PriceTagPrinterLocal> priceTagPrinterLocalBox;
  final String priceTagPrinterLocalBoxName =
      'priceTagPrinterLocalBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(PriceTagPrinterLocalAdapter());
    Hive.registerAdapter(PriceTagPrinterSettingsAdapter());
    priceTagPrinterLocalBox = await Hive.openBox(
      priceTagPrinterLocalBoxName,
    );
    await mainLocalLog(
      '✅ Price Tag Printer Box Initialized',
    );
  }

  PriceTagPrinterLocal? getPriceTagPrinterLocal() {
    return priceTagPrinterLocalBox.values.isNotEmpty
        ? priceTagPrinterLocalBox.values.first
        : null;
  }

  Future<int> insertPriceTagPrinter(
    PriceTagPrinterLocal priceTagPrinter,
  ) async {
    try {
      await clearPriceTagPrinters();
      await priceTagPrinterLocalBox.put(
        priceTagPrinter.printer.name,
        priceTagPrinter,
      );
      await mainLocalLog(
        'Price Tag Printer inserted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert Price Tag Printer Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearPriceTagPrinters() async {
    await priceTagPrinterLocalBox.clear();
    await mainLocalLog('Offline Price Tag Printer Cleared');
  }
}
