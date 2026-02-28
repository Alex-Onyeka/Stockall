class TempBarcodePrinterClass {
  final String name;
  final String driverName;

  TempBarcodePrinterClass({
    required this.name,
    required this.driverName,
  });
}

class PrinterSettings {
  final double widthMm;
  final double heightMm;
  final double gapMm;
  final int startX;
  final int startY;
  final int barcodeHeight;
  final int barcodeScale;
  final int verticalSpacing;

  PrinterSettings({
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
