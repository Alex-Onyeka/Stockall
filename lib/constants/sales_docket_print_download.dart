import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<bool> downloadDocket({
  required BuildContext context,
  required String fileName,
  required TempCart cart,
  required String waiter,
  required List<TempCartItem> items,
  required bool setTotal,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdfRoll(
      context: context,
      fileName: fileName,
      waiter: waiter,
      cart: cart,
      items: items,
      setTotal: setTotal,
    );

    // ✅ Ensure Uint8List
    final pdfUint8 = Uint8List.fromList(pdfBytes);

    // Step 1: Download
    final blob = html.Blob([pdfUint8], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = fileName
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);

    // Step 2: Print (make sure this runs in same click event if possible)
    var res = await Printing.layoutPdf(
      onLayout: (format) async => pdfUint8,
    );
    if (res) {
      await returnSalesProvider()
          .updateCurrentCartIsPrintedDocket();
    }

    if (context.mounted) {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    }
    return res;
    // return pdfUint8;
  } catch (e, stackTrace) {
    print(
      '❌ Error downloading/printing PDF: $e\n$stackTrace',
    );
    return false;
  }
}

Future<bool> printDocket({
  required BuildContext context,
  required String fileName,
  required TempCart cart,
  required String waiter,
  required List<TempCartItem> items,
  required bool setTotal,
}) async {
  final Uint8List pdfBytes = await _buildPdfRoll(
    context: context,
    fileName: fileName,
    waiter: waiter,
    cart: cart,
    items: items,
    setTotal: setTotal,
  );

  var res = await Printing.layoutPdf(
    onLayout: (_) async => pdfBytes,
  );
  if (res) {
    await returnSalesProvider()
        .updateCurrentCartIsPrintedDocket();
  }
  return res;
}

Future<Uint8List> _buildPdfRoll({
  required BuildContext context,
  required String fileName,
  required TempCart cart,
  required String waiter,
  required List<TempCartItem> items,
  required bool setTotal,
}) async {
  double headingText =
      returnShopProvider().userShop()?.printType == 1
          ? 12
          : 14;
  double parText =
      returnShopProvider().userShop()?.printType == 1
          ? 7
          : 9;
  // double parTextAlt =
  //     returnShopProvider().userShop()?.printType == 1
  //         ? 5
  //         : 7;
  double totalText =
      returnShopProvider().userShop()?.printType == 1
          ? 8
          : 10;
  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegular = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    ),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ),
  );

  pdf.addPage(
    pw.Page(
      pageFormat:
          returnShopProvider().userShop()?.printType == 1
              ? PdfPageFormat.roll57
              : PdfPageFormat.roll80,
      margin: pw.EdgeInsets.only(
        left: kIsWeb ? 2 : 0,
        top: 5,
        right: kIsWeb ? 15 : 20,
        bottom: 10,
      ),

      // 🔹 HEADER
      build:
          (pw.Context pdfContext) => pw.DefaultTextStyle(
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 10,
            ),
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      children: [
                        pw.Builder(
                          builder: (beansContext) {
                            if (setTotal) {
                              return pw.Text(
                                textAlign:
                                    pw.TextAlign.center,
                                returnShopProvider()
                                        .userShop()
                                        ?.name ??
                                    'Shop Name',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: headingText,
                                ),
                                // maxLines: 2,
                                overflow:
                                    pw.TextOverflow.clip,
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),
                        pw.Column(
                          children: [
                            pw.SizedBox(height: 1),
                            pw.Text(
                              textAlign:
                                  pw.TextAlign.center,

                              returnDepartmentProvider()
                                      .currentDepartment()
                                      ?.name
                                      .toUpperCase() ??
                                  'Department Name'
                                      .toUpperCase(),
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: parText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Divider(
                      color: PdfColor.fromHex('#1C1C1C'),
                      thickness: 0.5,
                      height: 4,
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Builder(
                  builder: (beansContext) {
                    if (setTotal) {
                      return pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw
                                          .CrossAxisAlignment
                                          .start,
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize: parText,
                                      ),
                                      'Staff Name:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      cart.staffName ??
                                          'Staff',
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw
                                          .CrossAxisAlignment
                                          .start,
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize: parText,
                                      ),
                                      'Waiter:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      waiter,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        pw.Expanded(
                          child: pw.Builder(
                            builder: (beansContext) {
                              if (setTotal) {
                                return pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw
                                            .CrossAxisAlignment
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: parText,
                                        ),
                                        'Table:',
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: parText,
                                        ),
                                        cart.cartName
                                                ?.toUpperCase() ??
                                            'Not Set',
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw
                                            .CrossAxisAlignment
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: parText,
                                        ),
                                        'Waiter:',
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: parText,
                                        ),
                                        waiter,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: parText,
                                ),
                                'Ticket No.:',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                                (cart.id?.substring(
                                      0,
                                      5,
                                    ))?.toUpperCase() ??
                                    'Not Set',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: parText,
                                ),
                                'Date:',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                                formatDateTime(
                                  DateTime.now(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: parText,
                                ),
                                'Time:',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                                formatTime(DateTime.now()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 6),

                pw.Builder(
                  builder: (beansContext) {
                    if (setTotal) {
                      return pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              'Items:',
                              style: pw.TextStyle(
                                fontSize: parText,
                                font: fontBold,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'Qty:',
                              style: pw.TextStyle(
                                fontSize: parText,
                                font: fontBold,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              'Price:',
                              style: pw.TextStyle(
                                fontSize: parText,
                                font: fontBold,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.SizedBox(height: 1),

                ...items.map(
                  (record) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '${record.item.name} ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '[ ${formatLargeNumberDouble(record.quantity)} ] ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                              fontWeight:
                                  pw.FontWeight.bold,
                            ),
                            '[ ${formatLargeNumberDouble(record.revenue())} ] ',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Divider(thickness: 0.6, height: 10),

                pw.Builder(
                  builder: (beansContext) {
                    if (setTotal) {
                      return pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                flex: 9,
                                child: pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: parText,
                                  ),
                                  'Subtotal:',
                                ),
                              ),
                              pw.Expanded(
                                flex: 7,
                                child: pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: parText,
                                  ),
                                  formatMoneyMid(
                                    amount:
                                        returnSalesProvider()
                                            .calcSubTotal(),
                                    context: context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.Builder(
                            builder: (pdfContext) {
                              if (cart.fixedDiscount !=
                                      null ||
                                  cart.discount != null) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw
                                              .MainAxisAlignment
                                              .spaceEvenly,
                                      children: [
                                        pw.Expanded(
                                          flex: 9,
                                          child: pw.Row(
                                            children: [
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                'Discount:',
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                cart.discount !=
                                                        null
                                                    ? " (${cart.discount}%)"
                                                    : '',
                                              ),
                                            ],
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 7,
                                          child: pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize:
                                                  parText,
                                            ),
                                            formatMoneyMid(
                                              amount:
                                                  returnSalesProvider()
                                                      .calcDiscountMain(),
                                              context:
                                                  context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),
                          pw.SizedBox(height: 1),
                          pw.Builder(
                            builder: (pdfContext) {
                              if (returnShopProvider()
                                      .userShop()
                                      ?.applyVAT ==
                                  true) {
                                return pw.Column(
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw
                                              .MainAxisAlignment
                                              .spaceEvenly,
                                      children: [
                                        pw.Expanded(
                                          flex: 9,
                                          child: pw.Row(
                                            children: [
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                'VAT:',
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                '(${returnShopProvider().userShop()?.applyVAT == true ? vat : 0}%)',
                                              ),
                                            ],
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 7,
                                          child: pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize:
                                                  parText,
                                            ),
                                            formatMoneyMid(
                                              amount:
                                                  returnSalesProvider()
                                                      .calcVatAmount(),
                                              context:
                                                  context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 1),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                flex: 9,
                                child: pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: parText,
                                  ),
                                  'Total:',
                                ),
                              ),
                              pw.Expanded(
                                flex: 7,
                                child: pw.Text(
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: totalText,
                                  ),
                                  formatMoneyMid(
                                    amount:
                                        returnSalesProvider()
                                            .calcFinalTotal(),
                                    context: context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Divider(),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.SizedBox(height: 3),
                pw.Builder(
                  builder: (beansContext) {
                    if (setTotal) {
                      return pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment.center,
                        children: [
                          pw.Flexible(
                            child: pw.Text(
                              textAlign:
                                  pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: totalText,
                                fontWeight:
                                    pw.FontWeight.bold,
                                // color: PdfColor(50, 50, 050),
                              ),
                              'Thank you for shopping with us'
                                  .toUpperCase(),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.SizedBox(height: 20),

                // pw.SizedBox(height: 5),
                pw.Text(
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: totalText,
                    fontWeight: pw.FontWeight.bold,
                    // color: PdfColor(50, 50, 050),
                  ),
                  '------------',
                ),
                pw.Builder(
                  builder: (beansContext) {
                    if (items.length > 15) {
                      return pw.Text(
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: totalText,
                          fontWeight: pw.FontWeight.bold,
                          // color: PdfColor(50, 50, 050),
                        ),
                        '------------',
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
              ],
            ),
          ),

      // pw.Expanded(child: pw.Spacer()),
    ),
  );

  return pdf.save();
}
