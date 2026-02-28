import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_and_barcode_printer_class%20copy/price_and_barcode_printer_settings/price_and_barcode_printer_settings.dart';

part 'price_and_barcode_printer_local.g.dart';

@HiveType(typeId: 54)
class PriceAndBarcodePrinterLocal {
  @HiveField(0)
  final TempBarcodePrinterClass printer;

  @HiveField(1)
  final PriceAndBarcodePrinterSettings settings;

  PriceAndBarcodePrinterLocal({
    required this.printer,
    required this.settings,
  });
}
