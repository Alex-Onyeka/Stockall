import 'package:hive/hive.dart';

part 'price_and_barcode_printer_settings.g.dart';

@HiveType(typeId: 55)
class PriceAndBarcodePrinterSettings {
  @HiveField(0)
  final double widthMm;

  @HiveField(1)
  final double heightMm;

  @HiveField(2)
  final double gapMm;

  @HiveField(3)
  final int startX;

  @HiveField(4)
  final int startY;

  @HiveField(5)
  final int barcodeHeight;

  @HiveField(6)
  final int barcodeScale;

  @HiveField(7)
  final int verticalSpacing;

  PriceAndBarcodePrinterSettings({
    required this.widthMm,
    required this.heightMm,
    required this.gapMm,
    required this.startX,
    required this.startY,
    required this.barcodeHeight,
    required this.barcodeScale,
    required this.verticalSpacing,
  });
}
