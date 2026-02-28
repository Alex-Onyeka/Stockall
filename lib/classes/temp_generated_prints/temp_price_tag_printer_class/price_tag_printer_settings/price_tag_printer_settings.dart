import 'package:hive/hive.dart';

part 'price_tag_printer_settings.g.dart';

@HiveType(typeId: 50)
class PriceTagPrinterSettings {
  @HiveField(1)
  final double gapMm;

  @HiveField(2)
  final int labelWidth;

  @HiveField(3)
  final int verticalSpacing;

  // @HiveField(4)
  // final int startPriceX;

  @HiveField(4)
  final int startPriceY;

  PriceTagPrinterSettings({
    required this.gapMm,
    required this.startPriceY,
    required this.verticalSpacing,
    required this.labelWidth,
  });
}
