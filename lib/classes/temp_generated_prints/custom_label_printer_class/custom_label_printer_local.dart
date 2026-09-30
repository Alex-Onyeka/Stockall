import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_generated_prints/custom_label_printer_class/custom_label_printer_settings/custom_label_printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';

part 'custom_label_printer_local.g.dart';

@HiveType(typeId: 145)
class CustomLabelPrinterLocal {
  @HiveField(0)
  final TempBarcodePrinterClass printer;

  @HiveField(1)
  final CustomLabelPrinterSettings settings;

  CustomLabelPrinterLocal({
    required this.printer,
    required this.settings,
  });
}
