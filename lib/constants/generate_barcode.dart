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
import 'package:universal_html/html.dart' as html;

class GenerateBarcodeScreen extends StatelessWidget {
  final String data;
  final TempProductClass product;

  const GenerateBarcodeScreen({
    super.key,
    required this.data,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        Flexible(
          child: Text(
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            product.name,
          ),
        ),
        SizedBox(height: 5),
        BarcodeWidget(
          barcode: Barcode.code128(),
          data: data,
          width: 300,
          height: 100,
          color: Colors.black,
          backgroundColor: Colors.white,
          drawText: true,
          errorBuilder:
              (context, error) => Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
        ),
        SizedBox(height: 5),
        Text(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          'Price: ${product.sellingPrice == null || product.sellingPrice == 0 ? 'Not Set' : formatMoneyMid(amount: product.sellingPrice ?? 0, context: context)}',
        ),
      ],
    );
  }
}

Future<bool> printBarcode(
  String data,
  BuildContext context,
  TempProductClass product,
) async {
  final barcode = Barcode.code128();
  final svg = barcode.toSvg(
    data,
    width: 200,
    height: 70,
    fontHeight: 14,
    drawText: true,
  );

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll57,
      margin: pw.EdgeInsets.only(
        left:
            kIsWeb ||
                    screenWidth(context) < tabletScreenSmall
                ? 25
                : 0,
        top: 15,
        right: 30,
        bottom: 20,
      ),
      build: (pw.Context pcontext) {
        return pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // pw.SizedBox(height: 80),
              pw.Text(
                style: pw.TextStyle(fontSize: 5),
                '-',
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                product.name,
              ),
              pw.SizedBox(height: 5),
              pw.SvgImage(svg: svg),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    style: pw.TextStyle(
                      fontSize: 8,
                      // fontWeight: pw.FontWeight.bold,
                    ),
                    'Price: ',
                  ),
                  pw.Text(
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    product.sellingPrice == null ||
                            product.sellingPrice == 0
                        ? 'Not Set'
                        : 'N ${formatLargeNumberDouble(product.sellingPrice ?? 0)}',
                  ),
                ],
              ),
              pw.SizedBox(height: 80),
              pw.Text(
                style: pw.TextStyle(fontSize: 5),
                '-',
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                style: pw.TextStyle(fontSize: 5),
                '-',
              ),
            ],
          ),
        );
      },
    ),
  );

  if (kIsWeb) {
    final blob = html.Blob([
      await pdf.save(),
    ], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = data
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
    return true;
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
        filename:
            'barcode_${data.replaceAll(' ', '_')}.pdf',
      );
      return res;
    }
  }
}

Future<dynamic> generateBarcodeAndPrint(
  BuildContext context,
  TempProductClass product,
) {
  print('Starting Generation');
  final safeContext = context;

  final productUuid =
      '${product.name.substring(0, 3).toUpperCase()}-${product.uuid!.split('-').first.substring(0, 5)}${product.uuid!.split('-')[1]}';

  return showDialog(
    context: safeContext,
    builder: (confirmAlert) {
      return DialogTemplate(
        theme: returnTheme(safeContext, listen: false),
        message:
            'Generated for this Product. This action automatically sets the product barcode to the new generated barcode once you print it.',
        title: 'Generated Barcode',
        action: () async {
          print('Starting Printing');
          Navigator.of(confirmAlert).pop();

          bool res = await printBarcode(
            productUuid,
            safeContext,
            product,
          );

          if (res) {
            var newP = product;
            newP.barcode = productUuid;

            if (safeContext.mounted) {
              await returnData(
                safeContext,
                listen: false,
              ).updateProduct(
                product: newP,
                context: safeContext,
              );
              print(
                'Finished Printing and Starting Updating Product Barcode',
              );
            } else {
              print('safeContext not mounted');
            }
          } else {
            print('Printing Cancelled');
          }
        },
        actionButtonText: buttonDislayText(safeContext),
        widget: GenerateBarcodeScreen(
          data: productUuid,
          product: product,
        ),
      );
    },
  );
}

String buttonDislayText(BuildContext context) {
  if (kIsWeb) {
    return screenWidth(context) > tabletScreenSmall
        ? 'Print'
        : 'Download';
  } else {
    return screenWidth(context) > tabletScreenSmall
        ? 'Print'
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
                                  IconButton(
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
                                  Opacity(
                                    opacity: 0,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        size: 20,
                                        Icons.clear,
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
                                      returnData(context)
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
                                                      if (product.barcode ==
                                                          null) {
                                                        generateBarcodeAndPrint(
                                                          context,
                                                          product,
                                                        );
                                                      } else {
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

                                                                generateBarcodeAndPrint(
                                                                  context,
                                                                  product,
                                                                );

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
                                                            5,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            spacing:
                                                                10,
                                                            children: [
                                                              Icon(
                                                                size:
                                                                    16,
                                                                color:
                                                                    theme.lightModeColor.secColor200,
                                                                Icons.inventory_2,
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b2.fontSize,
                                                                  // fontWeight:
                                                                  //     FontWeight.bold,
                                                                ),
                                                                product.name,
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b2.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            product.barcode ??
                                                                'Barcode Not Set',
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
      productSearch.clear();
    }
  });
}
