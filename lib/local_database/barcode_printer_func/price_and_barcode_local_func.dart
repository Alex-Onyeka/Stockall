import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_and_barcode_printer_class%20copy/price_and_barcode_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_and_barcode_printer_class%20copy/price_and_barcode_printer_settings/price_and_barcode_printer_settings.dart';
import 'package:stockall/main.dart';

class PriceAndBarcodePrinterLocalFunc {
  static final PriceAndBarcodePrinterLocalFunc instance =
      PriceAndBarcodePrinterLocalFunc._internal();
  factory PriceAndBarcodePrinterLocalFunc() => instance;
  PriceAndBarcodePrinterLocalFunc._internal();
  late Box<PriceAndBarcodePrinterLocal>
  priceAndBarcodePrinterLocalBox;
  final String priceAndBarcodePrinterLocalBoxName =
      'priceAndBarcodePrinterLocalBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(
      PriceAndBarcodePrinterLocalAdapter(),
    );
    Hive.registerAdapter(
      PriceAndBarcodePrinterSettingsAdapter(),
    );
    priceAndBarcodePrinterLocalBox = await Hive.openBox(
      priceAndBarcodePrinterLocalBoxName,
    );
    await mainLocalLog('✅ Barcode Printer Box Initialized');
  }

  PriceAndBarcodePrinterLocal?
  getpriceAndBarcodePrinterLocal() {
    return priceAndBarcodePrinterLocalBox.values.isNotEmpty
        ? priceAndBarcodePrinterLocalBox.values.first
        : null;
  }

  Future<int> insertpriceBarcodeAndPrinter(
    PriceAndBarcodePrinterLocal priceBarcodeAndPrinter,
  ) async {
    try {
      await clearpriceBarcodeAndPrinters();
      await priceAndBarcodePrinterLocalBox.put(
        priceBarcodeAndPrinter.printer.name,
        priceBarcodeAndPrinter,
      );
      await mainLocalLog(
        'priceBarcodeAndPrinter inserted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert priceBarcodeAndPrinter Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearpriceBarcodeAndPrinters() async {
    await priceAndBarcodePrinterLocalBox.clear();
    await mainLocalLog(
      'Offline priceBarcodeAndPrinter Cleared',
    );
  }
}
