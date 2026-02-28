import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_tag_printer_class/price_tag_printer_settings/price_tag_printer_settings.dart';

part 'price_tag_printer_local.g.dart';

@HiveType(typeId: 51)
class PriceTagPrinterLocal {
  @HiveField(0)
  final TempBarcodePrinterClass printer;

  @HiveField(1)
  final PriceTagPrinterSettings settings;

  PriceTagPrinterLocal({
    required this.printer,
    required this.settings,
  });
}
