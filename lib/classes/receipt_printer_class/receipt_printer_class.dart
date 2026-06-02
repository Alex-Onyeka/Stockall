import 'package:hive/hive.dart';
part 'receipt_printer_class.g.dart';

@HiveType(typeId: 93)
class ReceiptPrinterClass extends HiveObject {
  @HiveField(0)
  String printerName;

  @HiveField(1)
  int printerSize;

  ReceiptPrinterClass({
    required this.printerName,
    required this.printerSize,
  });
}
