import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:win32/win32.dart';

Future<bool> printBarcodeDesktop(
  String printerName,
  List<ProductBarcode> productBarcodes,
) async {
  final tsplCommand =
      returnData().barcodeGeneratingIndex == 0
          ? generateTsplForBarcodes(productBarcodes)
          : returnData().barcodeGeneratingIndex == 1
          ? generateTsplForPriceTag(productBarcodes)
          : generateTsplForBarcodesAndPriceTag(
            productBarcodes,
          );
  return await sendRawToUsbPrinter(
    printerName,
    tsplCommand,
  );
}

Future<bool> sendRawToUsbPrinter(
  String printerName,
  String command,
) async {
  final hPrinter = calloc<HANDLE>();
  final pPrinterName = printerName.toNativeUtf16();

  // Try to open the printer by name
  if (OpenPrinter(pPrinterName, hPrinter, nullptr) == 0) {
    print('Failed to open printer: $printerName');
    calloc.free(pPrinterName);
    calloc.free(hPrinter);
    return false;
  }

  // Prepare document info
  final docInfo = calloc<DOC_INFO_1>();
  docInfo.ref.pDocName = 'Raw TSPL'.toNativeUtf16();
  docInfo.ref.pOutputFile = nullptr;
  docInfo.ref.pDatatype = 'RAW'.toNativeUtf16();

  // Convert command string to UTF-8 bytes
  final bytes = utf8.encode(command);
  final pBytes = calloc<Uint8>(bytes.length);
  for (var i = 0; i < bytes.length; i++) {
    pBytes[i] = bytes[i];
  }

  final written = calloc<DWORD>();
  var success = false;

  // Start document and page
  if (StartDocPrinter(hPrinter.value, 1, docInfo.cast()) !=
      0) {
    if (StartPagePrinter(hPrinter.value) != 0) {
      final res = WritePrinter(
        hPrinter.value,
        pBytes.cast<Void>(),
        bytes.length,
        written,
      );
      if (res != 0) {
        print('Sent ${written.value} bytes to printer.');
        success = true;
      } else {
        print('Failed to write to printer: $printerName');
      }
      EndPagePrinter(hPrinter.value);
    }
    EndDocPrinter(hPrinter.value);
  } else {
    print(
      'Failed to start document for printer: $printerName',
    );
  }

  // Clean up
  ClosePrinter(hPrinter.value);
  calloc.free(pPrinterName);
  calloc.free(hPrinter);
  calloc.free(docInfo.ref.pDocName);
  calloc.free(docInfo.ref.pDatatype);
  calloc.free(docInfo);
  calloc.free(pBytes);
  calloc.free(written);

  return success;
}

String generateTsplForPriceTag(
  List<ProductBarcode> productBarcodes,
) {
  final buffer = StringBuffer();

  for (var pb in productBarcodes) {
    // final digits = returnOnlyDigits(pb.product.uuid!);
    final productName = pb.product.name.toUpperCase();
    String productPrice = formatPrice(
      pb.product.sellingPrice,
    );

    final settings =
        returnShopProvider().priceTagPrinterSettings!;

    buffer.writeln(
      'SIZE ${settings.labelWidth.toDouble()} mm,25 mm',
    );
    buffer.writeln('GAP ${settings.gapMm} mm,0');
    buffer.writeln('DENSITY 8');
    buffer.writeln('CLS');

    /// 🆕 Product Name (Top)
    buffer.writeln(
      'TEXT ${calcTitleLeftMargin(productName.length, settings.labelWidth.toDouble())},${settings.startPriceY - 40},"3",0,1,1,"${formatName(productName)}"',
    );

    /// 🆕 Product Price
    buffer.writeln(
      'TEXT ${calcPriceLeftMargin(productPrice.length, settings.labelWidth.toDouble())},${settings.startPriceY},"5",0,1,1,"$productPrice"',
    );

    buffer.writeln('PRINT 1,1');
  }

  return buffer.toString();
}

String formatPrice(double? price) {
  return price != null
      ? formatMoneyAlt(
        amount: (price),
        currency: 'N',
      ).split('.').first
      : 'Not Set';
}

double calcPriceLeftMargin(int length, double labelWidth) {
  double margin = -17.5 * length + 190;
  return margin < 0 ? 0 : margin * (labelWidth / 58);
}

double calcTitleLeftMargin(int length, double labelWidth) {
  double margin = -10 * length + 200;
  return margin < 0 ? 0 : margin * (labelWidth / 58);
}

String generateTsplForBarcodes(
  List<ProductBarcode> productBarcodes,
) {
  final buffer = StringBuffer();

  for (var pb in productBarcodes) {
    final digits = returnOnlyDigits(pb.product.uuid!);
    final productName = pb.product.name.toUpperCase();

    final settings = returnShopProvider().printerSettings!;

    buffer.writeln(
      'SIZE ${settings.widthMm} mm,${settings.heightMm} mm',
    );
    buffer.writeln('GAP ${settings.gapMm} mm,0');
    buffer.writeln('DENSITY 8');
    buffer.writeln('CLS');

    /// 🆕 Product Name (Top)
    buffer.writeln(
      'TEXT ${calcTitleLeftMargin(productName.length, settings.widthMm)},${settings.startY - 40},"3",0,1,1,"${formatName(productName)}"',
    );

    /// Barcode
    buffer.writeln(
      'BARCODE ${settings.startX},${settings.startY},"EAN13",'
      '${settings.barcodeHeight},1,0,'
      '${settings.barcodeScale},${settings.barcodeScale},"$digits"',
    );

    buffer.writeln('PRINT 1,1');
  }

  return buffer.toString();
}

String generateTsplForBarcodesAndPriceTag(
  List<ProductBarcode> productBarcodes,
) {
  final buffer = StringBuffer();

  for (var pb in productBarcodes) {
    final digits = returnOnlyDigits(pb.product.uuid!);
    final productName = pb.product.name.toUpperCase();
    final productPrice =
        "PRICE: ${formatPrice(pb.product.sellingPrice)}";

    final settings =
        returnShopProvider()
            .priceAndBarcodePrinterSettings!;

    buffer.writeln(
      'SIZE ${settings.widthMm} mm,${settings.heightMm} mm',
    );
    buffer.writeln('GAP ${settings.gapMm} mm,0');
    buffer.writeln('DENSITY 8');
    buffer.writeln('CLS');

    /// 🆕 Product Name (Top)
    buffer.writeln(
      'TEXT ${calcTitleLeftMargin(productName.length, settings.widthMm)},${settings.startY - 35},"3",0,1,1,"${formatName(productName)}"',
    );

    /// Barcode
    buffer.writeln(
      'BARCODE ${settings.startX},${settings.startY},"EAN13",'
      '${settings.barcodeHeight - 5},1,0,'
      '${settings.barcodeScale},${settings.barcodeScale},"$digits"',
    );

    /// 🆕 Product Price (Bottom)
    buffer.writeln(
      'TEXT ${calcTitleLeftMargin(productPrice.length, settings.widthMm)},${settings.startY + 105},"3",0,1,1,"$productPrice"',
    );

    buffer.writeln('PRINT 1,1');
  }

  return buffer.toString();
}

String formatName(String name, {int maxChars = 20}) {
  if (name.length <= maxChars) return name;
  return name.substring(0, maxChars);
}

void listPrinters() {
  if (returnShopProvider().isDesktop()) {
    returnShopProvider().setPrinterCache();
    returnShopProvider().setPrinterSettingsCache();

    final needed = calloc<Uint32>();
    final returned = calloc<Uint32>();

    // First call to get the required buffer size
    EnumPrinters(
      PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
      nullptr,
      2,
      nullptr,
      0,
      needed,
      returned,
    );

    final buffer = calloc<Uint8>(needed.value);

    // Second call to actually get the printer info
    final success = EnumPrinters(
      PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
      nullptr,
      2,
      buffer,
      needed.value,
      needed,
      returned,
    );

    if (success == 0) {
      print('Failed to enumerate printers.');
      calloc.free(buffer);
      calloc.free(needed);
      calloc.free(returned);
      return;
    }

    final info = buffer.cast<PRINTER_INFO_2>();
    returnShopProvider().clearPrinters();
    for (var i = 0; i < returned.value; i++) {
      final printer = info.elementAt(i).ref;
      returnShopProvider().listPrintersSub(
        TempBarcodePrinterClass(
          name: printer.pPrinterName.toDartString(),
          driverName: printer.pDriverName.toDartString(),
        ),
      );
    }

    calloc.free(buffer);
    calloc.free(needed);
    calloc.free(returned);
  }
}
