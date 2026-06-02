import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/receipt_printer_class/receipt_printer_class.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/printing/printer_service_mobile.dart';
import 'package:win32/win32.dart';

Future<void> startReceiptPrintAction({
  required BuildContext context,
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
}) async {
  final data = generateStyledReceipt(
    receipt: receipt,
    records: records,
    shop: shop,
    context: context,
  );

  await checkPrint(context: context, receiptBytes: data);
}

Future<bool> checkPrint({
  required BuildContext context,
  required Uint8List receiptBytes,
}) async {
  var printers = returnShopProvider().printers;
  var currentPrinterName =
      returnShopProvider().getReceiptPrinter()?.printerName;
  var paperSize =
      returnShopProvider().getReceiptPrinter()?.printerSize;
  if ((paperSize != 1 && paperSize != 2) ||
      printers
          .where(
            (print) => print.name == currentPrinterName,
          )
          .isEmpty) {
    return printerSelectionDialog(context: context);
  } else {
    return await sendReceiptToPrinter(receiptBytes);
  }
}

Future<bool> printerSelectionDialog({
  required BuildContext context,
}) async {
  var theme = returnTheme(context, listen: false);
  return showDialog(
    context: context,
    builder: (errorContext) {
      return DialogTemplate(
        theme: theme,
        message:
            'You have not Selected Any Printer for this action. Please Proceed to Select the List of Installed Printers from the List.',
        title: 'Printer Not Selected',
        action: () {},
        showBottomActionButtons: false,
        topRightWidget: IconButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          icon: Icon(size: 20, Icons.clear),
        ),
        widget: SizedBox(
          width:
              screenWidth(context) <= mobileScreen
                  ? screenWidth(context) - 100
                  : mobileScreen,
          height: screenHeight(context) * 0.6,
          child: ListView(
            children: [
              Divider(height: 20),
              Column(
                spacing: 10,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Receipt Paper Size:',
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: PaperSizeSelectionWidget(
                          index: 1,
                          title: 'Size 58mm',
                        ),
                      ),
                      Expanded(
                        child: PaperSizeSelectionWidget(
                          index: 2,
                          title: 'Size 80mm',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              Visibility(
                // visible:
                //    returnShopProvider(context: context).getReceiptPrinter() != null,
                child: Column(
                  children: [
                    PrinterListTileWidget(
                      printer: TempBarcodePrinterClass(
                        name:
                            returnShopProvider(
                                  context: context,
                                )
                                .getReceiptPrinter()
                                ?.printerName ??
                            'POS 80Cxx 345',
                        driverName:
                            returnShopProvider(
                                  context: context,
                                )
                                .getReceiptPrinter()
                                ?.printerName ??
                            '',
                      ),
                    ),
                    Divider(),
                  ],
                ),
              ),
              Column(
                children:
                    returnShopProvider(context: context)
                        .printers
                        .where(
                          (print) =>
                              print.name !=
                              returnShopProvider(
                                    context: context,
                                  )
                                  .getReceiptPrinter()
                                  ?.printerName,
                        )
                        .map(
                          (printer) =>
                              PrinterListTileWidget(
                                printer: printer,
                              ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) {
    return false;
  });
}

class PaperSizeSelectionWidget extends StatelessWidget {
  final int index;
  final String title;
  const PaperSizeSelectionWidget({
    super.key,
    required this.index,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var currentIndex =
        returnShopProvider(
          context: context,
        ).getReceiptPrinter()?.printerSize;
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              index == currentIndex
                  ? const Color.fromARGB(38, 255, 127, 7)
                  : Colors.grey.shade300,
          border: Border.all(
            color:
                index == currentIndex
                    ? Colors.amber
                    : Colors.grey.shade100,
          ),
        ),
        child: InkWell(
          onTap: () {
            var currentPrinter =
                returnShopProvider().getReceiptPrinter();
            var newPrinter = ReceiptPrinterClass(
              printerName:
                  currentPrinter?.printerName ?? 'Not Set',
              printerSize: index,
            );
            returnShopProvider().selectReceiptPrinter(
              newPrinter,
              true,
              context,
            );
          },
          child: Container(
            padding: EdgeInsets.all(13),

            child: Center(
              child: Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight:
                      index == currentIndex
                          ? FontWeight.bold
                          : null,
                ),
                title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrinterListTileWidget extends StatelessWidget {
  const PrinterListTileWidget({
    super.key,
    required this.printer,
  });

  final TempBarcodePrinterClass printer;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    bool isSelected =
        returnShopProvider(
          context: context,
        ).getReceiptPrinter()?.printerName ==
        printer.name;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade200 : null,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: InkWell(
            onTap: () {
              if (!isSelected) {
                var currentPrinter =
                    returnShopProvider()
                        .getReceiptPrinter();
                var newPrinter = ReceiptPrinterClass(
                  printerName: printer.name,
                  printerSize:
                      currentPrinter?.printerSize ?? 1,
                );
                returnShopProvider().selectReceiptPrinter(
                  newPrinter,
                  false,
                  context,
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 15,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight:
                          isSelected
                              ? FontWeight.bold
                              : null,
                    ),
                    printer.name,
                  ),
                  Visibility(
                    visible: isSelected,
                    child: Icon(size: 20, Icons.check),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> sendReceiptToPrinter(
  // String printerName,
  Uint8List receiptBytes,
) async {
  try {
    final hPrinter = calloc<HANDLE>();
    final pPrinterName =
        returnShopProvider()
            .getReceiptPrinter()!
            .printerName
            .toNativeUtf16();

    if (OpenPrinter(pPrinterName, hPrinter, nullptr) == 0) {
      calloc.free(pPrinterName);
      calloc.free(hPrinter);
      return false;
    }

    final docInfo = calloc<DOC_INFO_1>();

    docInfo.ref.pDocName =
        'Stockall Receipt'.toNativeUtf16();

    docInfo.ref.pOutputFile = nullptr;

    docInfo.ref.pDatatype = 'RAW'.toNativeUtf16();

    final pBytes = calloc<Uint8>(receiptBytes.length);

    for (int i = 0; i < receiptBytes.length; i++) {
      pBytes[i] = receiptBytes[i];
    }

    final written = calloc<DWORD>();

    bool success = false;

    if (StartDocPrinter(
          hPrinter.value,
          1,
          docInfo.cast(),
        ) !=
        0) {
      if (StartPagePrinter(hPrinter.value) != 0) {
        final result = WritePrinter(
          hPrinter.value,
          pBytes.cast(),
          receiptBytes.length,
          written,
        );

        success = result != 0;

        EndPagePrinter(hPrinter.value);
      }

      EndDocPrinter(hPrinter.value);
    }

    ClosePrinter(hPrinter.value);

    calloc.free(pPrinterName);
    calloc.free(hPrinter);
    calloc.free(docInfo.ref.pDocName);
    calloc.free(docInfo.ref.pDatatype);
    calloc.free(docInfo);
    calloc.free(pBytes);
    calloc.free(written);

    return success;
  } catch (e) {
    print('Error Sending to Printer: ${e.toString()}');
    return false;
  }
}
