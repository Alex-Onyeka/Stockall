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

String returnOnlyDigits(String text) {
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
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
                  ProductBarcodeCounter(
                    pBarcode: widget.productBarcodes[0],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Price: ${widget.productBarcodes[0].product.sellingPrice == null || widget.productBarcodes[0].product.sellingPrice == 0 ? 'Not Set' : formatMoneyMid(amount: widget.productBarcodes[0].product.sellingPrice ?? 0, context: context)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                    // '${pr.uuid!.split('-').first.substring(0, 5).toUpperCase()}${pr.uuid!.split('-')[1].toUpperCase()}';

                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
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
                            spacing: 5,
                            children: [
                              Flexible(
                                child: Text(
                                  pr.product.name.isEmpty
                                      ? 'Name Not Set'
                                      : pr.product.name,
                                  textAlign:
                                      TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              BarcodeWidget(
                                barcode: Barcode.ean13(),
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
                                  print(error.toString());
                                  return Text(
                                    'Error: $error',
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Price: ${pr.product.sellingPrice == null || pr.product.sellingPrice == 0 ? 'Not Set' : formatMoneyMid(amount: pr.product.sellingPrice ?? 0, context: context)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                color: Colors.grey.shade600,
                                thickness: 0.4,
                                height: 5,
                              ),
                            ],
                          ),
                          ProductBarcodeCounter(
                            pBarcode: pr,
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

Future<bool> printBarcode(
  // String data,
  BuildContext context,
  List<ProductBarcode> productBarcodes,
) async {
  final barcode = Barcode.ean13();

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        58 * PdfPageFormat.mm,
        40 * PdfPageFormat.mm,
        marginLeft:
            kIsWeb ||
                    screenWidth(context) < tabletScreenSmall
                ? 10
                : 5,
        marginTop: 25,
        marginRight: 30,
        marginBottom: 0,
        // marginAll: 5,
      ),
      // margin: pw.EdgeInsets.only(
      //   left:
      //       kIsWeb ||
      //               screenWidth(context) < tabletScreenSmall
      //           ? 10
      //           : 5,
      //   top: 5,
      //   right: 30,
      //   bottom: 2,
      // ),
      build: (pw.Context pcontext) {
        return pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              ...productBarcodes.map(
                (productBarcode) => pw.Column(
                  children: [
                    // pw.Text(
                    //   style: pw.TextStyle(fontSize: 5),
                    //   '-',
                    // ),
                    // pw.SizedBox(height: 5),
                    // pw.Text(
                    //   textAlign: pw.TextAlign.center,
                    //   style: pw.TextStyle(
                    //     fontSize: 6,
                    //     fontWeight: pw.FontWeight.bold,
                    //   ),
                    //   productBarcode.product.name.isEmpty
                    //       ? 'Name Not Set'
                    //       : productBarcode.product.name,
                    // ),
                    // pw.SizedBox(height: 2),
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
                    // pw.SizedBox(height: 3),
                    // pw.Row(
                    //   mainAxisAlignment:
                    //       pw.MainAxisAlignment.center,
                    //   mainAxisSize: pw.MainAxisSize.min,
                    //   children: [
                    //     pw.Text(
                    //       style: pw.TextStyle(fontSize: 5),
                    //       'Price: ',
                    //     ),
                    //     pw.Text(
                    //       style: pw.TextStyle(
                    //         fontSize: 7,
                    //         fontWeight: pw.FontWeight.bold,
                    //       ),
                    //       productBarcode
                    //                       .product
                    //                       .sellingPrice ==
                    //                   null ||
                    //               productBarcode
                    //                       .product
                    //                       .sellingPrice ==
                    //                   0
                    //           ? 'Not Set'
                    //           : 'N ${formatLargeNumberDouble(productBarcode.product.sellingPrice ?? 0)}',
                    //     ),
                    //   ],
                    // ),
                    // pw.SizedBox(height: 5),
                    // pw.Text(
                    //   style: pw.TextStyle(fontSize: 5),
                    //   '-',
                    // ),
                    // pw.SizedBox(height: 5),
                    // pw.Text(
                    //   style: pw.TextStyle(fontSize: 5),
                    //   '-',
                    // ),
                  ],
                ),
              ),

              // pw.SizedBox(height: 80),
            ],
          ),
        );
      },
    ),
  );

  if (kIsWeb) {
    if (platforms(context) == TargetPlatform.iOS) {
      var res = await Printing.layoutPdf(
        onLayout:
            (PdfPageFormat format) async => pdf.save(),
      );
      return res;
    } else {
      final blob = html.Blob([
        await pdf.save(),
      ], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor =
          html.AnchorElement(href: url)
            ..download = returnOnlyDigits(
              productBarcodes[0].product.uuid!,
            )
            // '${products[0].uuid!.split('-').first.substring(0, 5).toUpperCase()}${products[0].uuid!.split('-')[1].toUpperCase()}'
            ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      html.Url.revokeObjectUrl(url);
      return true;
    }
  } else {
    if (screenWidth(context) > tabletScreenSmall) {
      var res = await Printing.layoutPdf(
        onLayout:
            (PdfPageFormat format) async => pdf.save(),
      );
      return res;
    } else {
      final pdfBytes = await pdf.save();
      var res = await Printing.sharePdf(
        bytes: pdfBytes,
        filename: returnOnlyDigits(
          productBarcodes[0].product.uuid!,
        ),
        // 'barcode_${'${products[0].uuid!.split('-').first.substring(0, 5).toUpperCase()}${products[0].uuid!.split('-')[1].toUpperCase()}'.replaceAll(' ', '_')}.pdf',
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

  final productUuid = returnOnlyDigits(
    productBarcodes[0].product.uuid!,
  );
  // '${products[0].uuid!.split('-').first.substring(0, 5).toUpperCase()}${products[0].uuid!.split('-')[1].toUpperCase()}';

  final result = await showDialog<bool>(
    context: safeContext,
    builder: (confirmAlert) {
      return DialogTemplate(
        theme: returnTheme(safeContext, listen: false),
        message:
            'Generated Barcode for this Product(s). This action automatically sets the products\' barcode to the new generated barcode once you print or download it.',
        title: 'Generated Barcode',
        action: () async {
          print('Starting Printing');

          // Navigator.pop(confirmAlert);

          List<ProductBarcode> productBarcodesTemp() {
            List<ProductBarcode> temp = [];
            for (var prB in productBarcodes) {
              for (var i = 0; i < prB.number; i++) {
                temp.add(
                  ProductBarcode(
                    product: prB.product,
                    number: 1,
                  ),
                );
              }
            }
            return temp;
          }

          bool printingSuccess = await printBarcode(
            // productUuid,
            safeContext,
            productBarcodesTemp(),
          );

          if (!printingSuccess && safeContext.mounted) {
            print('Printing Cancelled');
            Navigator.pop(
              safeContext,
              false,
            ); // return false
            return;
          }

          if (safeContext.mounted) {
            if (!isEdit) {
              for (var pr in productBarcodes) {
                final newShit = returnOnlyDigits(
                  productBarcodes[0].product.uuid!,
                );
                // '${pr.uuid!.split('-').first.substring(0, 5).toUpperCase()}${pr.uuid!.split('-')[1].toUpperCase()}';

                pr.product.barcode = newShit;

                await returnData().updateProduct(
                  product: pr.product,
                  context: safeContext,
                );
              }
              print(
                'Finished Printing and Updating Product Barcode',
              );
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
                                            returnData()
                                                    .barcodeGenerationList
                                                    .isNotEmpty
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
                                      returnData()
                                          .productList
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
                                                      // if (product.barcode ==
                                                      //     null) {
                                                      //   generateBarcodeAndPrint(
                                                      //     context,
                                                      //     [
                                                      //       product,
                                                      //     ],
                                                      //   );
                                                      // } else {
                                                      //
                                                      // }
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
                                                                returnData().barcodeGenerationList
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
