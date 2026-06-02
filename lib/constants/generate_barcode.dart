import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:flutter/foundation.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../services/barcode_generation/barcode_import_helper.dart';

String returnOnlyDigits(String text) {
  if (text.length < 13) {
    return '121212121212';
  } else {
    List<String> temp = [];

    // Step 1: extract only digits, but stop after 12
    for (var te in text.split('')) {
      if (RegExp(r'^[0-9]$').hasMatch(te)) {
        if (temp.length < 12) {
          temp.add(te);
        }
      }
    }

    // If we don't have exactly 12 digits, we cannot generate EAN-13
    if (temp.length != 12) {
      throw ArgumentError(
        "Input must contain at least 12 digits.",
      );
    }

    // Step 2: calculate checksum
    int checksum = calculateEan13Checksum(temp.join());

    // Step 3: append checksum to form full 13-digit code
    temp.add(checksum.toString());

    return temp.join();
  }
}

// Helper function to compute EAN-13 checksum
int calculateEan13Checksum(String data) {
  int sumOdd = 0;
  int sumEven = 0;

  for (int i = 0; i < 12; i++) {
    int digit = int.parse(data[i]);

    if (i % 2 == 0) {
      sumOdd += digit;
    } else {
      sumEven += digit;
    }
  }

  int total = sumOdd + (sumEven * 3);
  int checksum = (10 - (total % 10)) % 10;

  return checksum;
}

class GenerateBarcodeScreen extends StatefulWidget {
  final String data;
  final List<ProductBarcode> productBarcodes;

  const GenerateBarcodeScreen({
    super.key,
    required this.data,
    required this.productBarcodes,
  });

  @override
  State<GenerateBarcodeScreen> createState() =>
      _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState
    extends State<GenerateBarcodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (widget.productBarcodes.length == 1) {
          return Container(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 15,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                43,
                245,
                245,
                245,
              ),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  // spacing: 5,
                  children: [
                    Flexible(
                      child: Text(
                        widget
                                .productBarcodes[0]
                                .product
                                .name
                                .isEmpty
                            ? 'Name Not Set'
                            : widget
                                .productBarcodes[0]
                                .product
                                .name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      visible:
                          returnData()
                              .barcodeGeneratingIndex !=
                          1,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          BarcodeWidget(
                            barcode: Barcode.ean13(),
                            data: widget.data,
                            width: 220,
                            height: 80,
                            color: Colors.black,
                            backgroundColor: Colors.white,
                            drawText: true,
                            errorBuilder: (context, error) {
                              print(error.toString());
                              return Text(
                                'Error: $error',
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Visibility(
                      visible:
                          returnData()
                              .barcodeGeneratingIndex !=
                          0,
                      child: Row(
                        children: [
                          Text(
                            'Price: ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget
                                            .productBarcodes[0]
                                            .product
                                            .sellingPrice ==
                                        null ||
                                    widget
                                            .productBarcodes[0]
                                            .product
                                            .sellingPrice ==
                                        0
                                ? 'Not Set'
                                : formatMoneyMid(
                                  amount:
                                      widget
                                          .productBarcodes[0]
                                          .product
                                          .sellingPrice ??
                                      0,
                                  context: context,
                                ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        returnData().barcodeGeneratingIndex !=
                                1
                            ? 10
                            : 0,
                  ),
                  child: ProductBarcodeCounter(
                    pBarcode: widget.productBarcodes[0],
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: screenHeight(context) - 320,
            width: 400,
            child: ListView(
              shrinkWrap: true,
              children:
                  widget.productBarcodes.map((pr) {
                    var data2 = returnOnlyDigits(
                      pr.product.uuid!,
                    );
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          43,
                          245,
                          245,
                          245,
                        ),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 15,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            // spacing: 5,
                            children: [
                              Flexible(
                                child: Text(
                                  pr.product.name.isEmpty
                                      ? 'Name Not Set'
                                      : pr.product.name,
                                  textAlign:
                                      TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    returnData()
                                        .barcodeGeneratingIndex !=
                                    1,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    BarcodeWidget(
                                      barcode:
                                          Barcode.ean13(),
                                      data: data2,
                                      width: 220,
                                      height: 80,
                                      color: Colors.black,
                                      backgroundColor:
                                          Colors.white,
                                      drawText: true,
                                      errorBuilder: (
                                        context,
                                        error,
                                      ) {
                                        print(
                                          error.toString(),
                                        );
                                        return Text(
                                          'Error: $error',
                                          style:
                                              const TextStyle(
                                                color:
                                                    Colors
                                                        .red,
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Visibility(
                                visible:
                                    returnData()
                                        .barcodeGeneratingIndex !=
                                    0,
                                child: Row(
                                  children: [
                                    Text(
                                      'Price: ',
                                      style:
                                          const TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                    Text(
                                      pr.product.sellingPrice ==
                                                  null ||
                                              pr.product.sellingPrice ==
                                                  0
                                          ? 'Not Set'
                                          : formatMoneyMid(
                                            amount:
                                                pr
                                                    .product
                                                    .sellingPrice ??
                                                0,
                                            context:
                                                context,
                                          ),
                                      style:
                                          const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  returnData().barcodeGeneratingIndex !=
                                          1
                                      ? 10
                                      : 0,
                            ),
                            child: ProductBarcodeCounter(
                              pBarcode: pr,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          );
        }
      },
    );
  }
}

Future<bool> printBarcodeWebAndMobile(
  BuildContext context,
  List<ProductBarcode> productBarcodes,
) async {
  final barcode = Barcode.ean13();
  final pdf = pw.Document();

  // Loop through each product and create a page
  for (var productBarcode in productBarcodes) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          40 * PdfPageFormat.mm,
          marginAll: 5,
        ),
        build: (pw.Context pcontext) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                // Product name
                pw.Text(
                  productBarcode.product.name.isEmpty
                      ? 'Name Not Set'
                      : productBarcode.product.name,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 6,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),

                // Barcode
                pw.SvgImage(
                  svg: barcode.toSvg(
                    returnOnlyDigits(
                      productBarcode.product.uuid!,
                    ),
                    width: 100,
                    height: 45,
                    fontHeight: 10,
                    drawText: true,
                  ),
                ),
                pw.SizedBox(height: 3),

                // Price row
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Price: ',
                      style: pw.TextStyle(fontSize: 5),
                    ),
                    pw.Text(
                      productBarcode.product.sellingPrice ==
                                  null ||
                              productBarcode
                                      .product
                                      .sellingPrice ==
                                  0
                          ? 'Not Set'
                          : 'N ${formatLargeNumberDouble(productBarcode.product.sellingPrice ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Save PDF
  final pdfBytes = await pdf.save();

  // Handle platform-specific printing/sharing
  if (kIsWeb) {
    if (platforms(context) == TargetPlatform.iOS) {
      // iOS web printing
      var res = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
      return res;
    } else {
      // Web download
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor =
          html.AnchorElement(href: url)
            ..download = 'barcodes.pdf'
            ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      return true;
    }
  } else {
    if (screenWidth(context) > tabletScreenSmall) {
      // Desktop printing
      var res = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
      return res;
    } else {
      // Mobile sharing
      var res = await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            '${returnOnlyDigits(productBarcodes[0].product.uuid!)}.pdf',
      );
      return res;
    }
  }
}

Future<bool> generateBarcodeAndPrint(
  BuildContext context,
  List<ProductBarcode> productBarcodes,
  bool isEdit,
) async {
  print('Starting Generation');
  final safeContext = context;
  for (var pr in productBarcodes) {
    print(pr.product.barcode);
  }

  final productUuid = returnOnlyDigits(
    productBarcodes[0].product.uuid!,
  );

  final result = await showDialog<bool>(
    context: safeContext,
    builder: (confirmAlert) {
      return DialogTemplate(
        theme: returnTheme(safeContext, listen: false),
        message:
            'Generated Barcode for this Product(s). This action automatically sets the products\' barcode to the new generated barcode once you print or download it.',
        title:
            returnData().barcodeGeneratingIndex == 0
                ? 'Generated Barcode'
                : returnData().barcodeGeneratingIndex == 1
                ? 'Generated Price'
                : 'B.Code & Price',
        action: () async {
          print('Starting Printing');

          List<ProductBarcode> productBarcodesTemp() {
            List<ProductBarcode> temp = [];
            for (var prB in productBarcodes) {
              for (var i = 0; i < prB.number; i++) {
                print("❤❌❌❌✅${prB.product.barcode}");
                temp.add(
                  ProductBarcode(
                    product: prB.product,
                    number: 1,
                  ),
                );
              }
            }
            print(temp.length);
            return temp;
          }

          bool
          printingSuccess =
              (kIsWeb ||
                      // ignore: use_build_context_synchronously
                      screenWidth(safeContext) <
                          tabletScreenSmall)
                  ? await printBarcodeWebAndMobile(
                    // ignore: use_build_context_synchronously
                    safeContext,
                    productBarcodesTemp(),
                  )
                  : await printBarcodeDesktop(
                    returnShopProvider()
                            .printerCache
                            ?.name ??
                        '',
                    productBarcodesTemp(),
                  );
          print(printingSuccess);

          if (!printingSuccess && safeContext.mounted) {
            print('Printing Cancelled');
            Navigator.pop(safeContext, false);
            return;
          }

          // for (var pr in productBarcodes) {
          //   print("✅✅✅✅ ${pr.product.barcode}");
          // }

          if (safeContext.mounted) {
            if (!isEdit) {
              if (returnData().barcodeGeneratingIndex !=
                  1) {
                for (var pr
                    in returnData().barcodeGenerationList) {
                  final newShit = returnOnlyDigits(
                    pr.product.uuid!,
                  );

                  pr.product.barcode = newShit;
                  print("✅✅✅❌$newShit");

                  await returnData().updateProduct(
                    product: pr.product,
                  );
                }
                print(
                  'Finished Printing and Updating Product Barcode',
                );
              }
            }
            if (!safeContext.mounted) {
              return;
            }
            print('Finished Printing');
            Navigator.pop(safeContext, true);
          } else {
            print('Context not mounted');
            if (!safeContext.mounted) {
              return;
            }
            Navigator.pop(safeContext, false);
          }
        },
        actionButtonText: buttonDislayText(safeContext),
        widget: GenerateBarcodeScreen(
          data: productUuid,
          productBarcodes:
              returnData().barcodeGenerationList,
        ),
      );
    },
  ).then((_) {
    returnData().clearBarcodeGenerationList();
  });

  return result ?? false;
}

String buttonDislayText(BuildContext context) {
  if (kIsWeb) {
    return screenWidth(context) > tabletScreenSmall
        ? 'Save and Print'
        : 'Download';
  } else {
    return screenWidth(context) > tabletScreenSmall
        ? 'Save and Print'
        : 'share';
  }
}

Future<dynamic> settingsGenerateProductBarcode(
  BuildContext context,
  TextEditingController productSearch,
) {
  var theme = returnTheme(context, listen: false);
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => AlertDialog(
              elevation: 0,
              shadowColor: Colors.transparent,
              contentPadding: EdgeInsets.all(0),
              insetPadding: EdgeInsets.all(
                screenWidth(context) > tabletScreen
                    ? 15
                    : 0,
              ),
              backgroundColor: Colors.transparent,
              shape: BoxBorder.all(
                color: Colors.transparent,
                width: 0,
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Container(
                  // height: 300,
                  width: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      screenWidth(context) < mobileScreen
                          ? 0
                          : 10,
                    ),
                    // border: Border.all(
                    //   color:
                    //       theme.lightModeColor.secColor200,
                    // ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      spacing: 5,
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                      icon: Icon(
                                        size: 20,
                                        Icons.clear,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .h4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Set Barcode',
                                  ),
                                  Material(
                                    color:
                                        Colors.transparent,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color:
                                            returnData(
                                                  context:
                                                      context,
                                                ).barcodeGenerationList.isNotEmpty
                                                ? theme
                                                    .lightModeColor
                                                    .prColor300
                                                : Colors
                                                    .grey,
                                        borderRadius:
                                            BorderRadius.circular(
                                              2,
                                            ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (returnData()
                                              .barcodeGenerationList
                                              .isNotEmpty) {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                firstContext,
                                              ) {
                                                return ConfirmationAlert(
                                                  theme:
                                                      theme,
                                                  message:
                                                      'You are about to regenrate and print the barcode of this item, are you sure you want to proceed?',
                                                  actionButtonText:
                                                      'Generate',
                                                  title:
                                                      'Regenerate and Print Barcode?',
                                                  action: () async {
                                                    Navigator.of(
                                                      firstContext,
                                                    ).pop();

                                                    var res = await generateBarcodeAndPrint(
                                                      context,
                                                      returnData()
                                                          .barcodeGenerationList,
                                                      false,
                                                    );

                                                    if (res &&
                                                        context.mounted) {
                                                      returnData()
                                                          .clearBarcodeGenerationList();
                                                    }

                                                    print(
                                                      'Generate Clicked',
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(
                                                horizontal:
                                                    8,
                                                vertical: 3,
                                              ),

                                          child: Center(
                                            child: Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .white,
                                              ),
                                              'Generate',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              'Search for a product to set its Barcode.',
                            ),
                            // Divider(),
                            SizedBox(height: 20),
                            GeneralTextfieldOnly(
                              hint: 'Search Product Name',
                              controller: productSearch,
                              onChanged: (value) {
                                setState(() {});
                              },
                              lines: 1,
                              theme: theme,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5,
                            children: [
                              SizedBox(height: 5),
                              Builder(
                                builder: (context) {
                                  List<TempProductClass>
                                  products =
                                      returnData(
                                            context:
                                                context,
                                          )
                                          .productList()
                                          .where(
                                            (
                                              product,
                                            ) => product
                                                .name
                                                .toLowerCase()
                                                .contains(
                                                  productSearch
                                                      .text
                                                      .toLowerCase(),
                                                ),
                                          )
                                          .toList();
                                  return Expanded(
                                    child: ListView(
                                      children:
                                          products
                                              .map(
                                                (
                                                  product,
                                                ) => Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      var dataP =
                                                          returnData();
                                                      if (dataP
                                                          .barcodeGenerationList
                                                          .where(
                                                            (
                                                              pr,
                                                            ) =>
                                                                pr.product.uuid ==
                                                                product.uuid,
                                                          )
                                                          .isNotEmpty) {
                                                        dataP.removeFromBarcodeGenerationList(
                                                          ProductBarcode(
                                                            product:
                                                                product,
                                                            number:
                                                                1,
                                                          ),
                                                        );
                                                      } else {
                                                        dataP.addToBarcodeGenerationList(
                                                          ProductBarcode(
                                                            product:
                                                                product,
                                                            number:
                                                                1,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color:
                                                                Colors.grey.shade100,
                                                          ),
                                                        ),
                                                      ),
                                                      margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            5,
                                                      ),
                                                      padding: EdgeInsets.fromLTRB(
                                                        15,
                                                        10,
                                                        10,
                                                        10,
                                                      ),
                                                      child: Row(
                                                        spacing:
                                                            12,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              spacing:
                                                                  8,
                                                              children: [
                                                                Icon(
                                                                  size:
                                                                      16,
                                                                  color:
                                                                      theme.lightModeColor.secColor200,
                                                                  Icons.inventory_2,
                                                                ),
                                                                Flexible(
                                                                  child: Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b2.fontSize,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                    ),
                                                                    product.name,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color:
                                                                  product.barcode ==
                                                                          null
                                                                      ? Colors.redAccent
                                                                      : null,
                                                            ),
                                                            product.barcode ??
                                                                'Barcode Not Set',
                                                          ),
                                                          Visibility(
                                                            visible:
                                                                returnData(
                                                                      context:
                                                                          context,
                                                                    ).barcodeGenerationList
                                                                    .where(
                                                                      (
                                                                        pr,
                                                                      ) =>
                                                                          pr.product.uuid ==
                                                                          product.uuid,
                                                                    )
                                                                    .isNotEmpty,
                                                            child: Icon(
                                                              size:
                                                                  18,
                                                              color:
                                                                  theme.lightModeColor.secColor200,
                                                              Icons.check,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      );
    },
  ).then((_) {
    if (context.mounted) {
      returnData().clearBarcodeGenerationList();
      productSearch.clear();
    }
  });
}
