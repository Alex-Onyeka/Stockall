import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/printer_settings/printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';

part 'barcode_printer_local.g.dart';

@HiveType(typeId: 36)
class BarcodePrinterLocal {
  @HiveField(0)
  final TempBarcodePrinterClass printer;

  @HiveField(1)
  final PrinterSettings settings;

  BarcodePrinterLocal({
    required this.printer,
    required this.settings,
  });
}
