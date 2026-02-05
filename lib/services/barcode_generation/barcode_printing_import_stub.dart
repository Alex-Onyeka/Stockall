import 'package:stockall/providers/data_provider.dart';

Future<bool> printBarcodeDesktop(
  String printerName,
  List<ProductBarcode> productBarcodes,
) async {
  return true;
}

Future<bool> sendRawToUsbPrinter(
  String printerName,
  String command,
) async {
  return true;
}

String generateTsplForBarcodes(
  List<ProductBarcode> productBarcodes,
) {
  return '';
}

void listPrinters() {}
