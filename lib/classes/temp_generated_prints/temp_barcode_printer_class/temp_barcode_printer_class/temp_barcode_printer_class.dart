import 'package:hive/hive.dart';

part 'temp_barcode_printer_class.g.dart';

@HiveType(typeId: 37)
class TempBarcodePrinterClass {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String driverName;

  TempBarcodePrinterClass({
    required this.name,
    required this.driverName,
  });
}
