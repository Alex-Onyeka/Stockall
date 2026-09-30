import 'package:hive/hive.dart';

part 'custom_label_printer_settings.g.dart';

@HiveType(typeId: 146)
class CustomLabelPrinterSettings {
  @HiveField(0)
  final double widthMm;

  @HiveField(1)
  final double heightMm;

  @HiveField(2)
  final int startX;

  @HiveField(3)
  final int startY;

  @HiveField(4)
  final int labelHeight;

  @HiveField(5)
  final int labelScale;

  CustomLabelPrinterSettings({
    required this.widthMm,
    required this.heightMm,
    required this.startX,
    required this.startY,
    required this.labelHeight,
    required this.labelScale,
  });
}
