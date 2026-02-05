import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:stockall/classes/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:win32/win32.dart';

Future<bool> printBarcodeDesktop(
  String printerName,
  List<ProductBarcode> productBarcodes,
) async {
  final tsplCommand = generateTsplForBarcodes(
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

String generateTsplForBarcodes(
  List<ProductBarcode> productBarcodes,
) {
  final buffer = StringBuffer();

  for (var pb in productBarcodes) {
    final digits = returnOnlyDigits(pb.product.uuid!);

    buffer.writeln(
      'SIZE ${returnShopProvider().printerSettings!.widthMm} mm,${returnShopProvider().printerSettings!.heightMm} mm',
    );
    buffer.writeln(
      'GAP ${returnShopProvider().printerSettings!.gapMm} mm,0',
    );
    buffer.writeln('DENSITY 8');
    buffer.writeln('CLS');
    buffer.writeln(
      'BARCODE ${returnShopProvider().printerSettings!.startX},${returnShopProvider().printerSettings!.startY},"EAN13",${returnShopProvider().printerSettings!.barcodeHeight},1,0,${returnShopProvider().printerSettings!.barcodeScale},${returnShopProvider().printerSettings!.barcodeScale},"$digits"',
    );
    buffer.writeln('PRINT 1,1');
  }

  return buffer.toString();
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
