import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:file_saver/file_saver.dart';

void downloadPdfWebCustomerAccountBalance({
  required TempCustomersClass customer,
  required BuildContext context,
  required String filename,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      try {
        final pdfBytes =
            await _buildPdfCustomerAccountBalance(
              customer: customer,
              context: context,
              shop: returnShopProvider().userShop()!,
            );
        final blob = html.Blob([
          pdfBytes,
        ], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor =
            html.AnchorElement(href: url)
              ..download = filename
              ..style.display = 'none';

        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();

        html.Url.revokeObjectUrl(url);

        returnPurchaseProvider().toggleIsLoading(false);
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error downloading PDF: $e\n$stackTrace',
        );
      }
    },
  );
}

Future<Uint8List> _buildPdfCustomerAccountBalance({
  required TempCustomersClass customer,
  required TempShopClass shop,
  required BuildContext context,
}) async {
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
    pw.MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.only(
        left: 30,
        top: 30,
        right: 30,
        bottom: 10,
      ),
      // 🔹 HEADER
      header:
          (pw.Context pdfcontext) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Column(
                        children: [
                          pw.Column(
                            children: [
                              pw.SizedBox(height: 4),
                              pw.Container(
                                width:
                                    PdfPageFormat
                                        .a5
                                        .availableWidth -
                                    60, // match margins
                                alignment:
                                    pw.Alignment.center,
                                child: pw.Text(
                                  shop.name,
                                  textAlign:
                                      pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            children: [
                              pw.SizedBox(height: 4),
                              pw.Container(
                                width:
                                    PdfPageFormat
                                        .a5
                                        .availableWidth -
                                    60,
                                alignment:
                                    pw.Alignment.center,
                                child: pw.Text(
                                  shop.email ?? '',
                                  textAlign:
                                      pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(
                color: PdfColor.fromHex('#D3D3D3'),
                thickness: 0.5,
              ),
            ],
          ),
      // 🔹 FOOTER
      footer:
          (context) => pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      '( Page ${context.pageNumber} of ${context.pagesCount} )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Text(
                      'Created by $appName Solutions - ( www.stockallapp.com )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      build:
          (pw.Context pdfContext) => [
            pw.DefaultTextStyle(
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 12,
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        'Customer Account Balance',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(
                    color: PdfColor.fromHex('#D3D3D3'),
                    thickness: 0.5,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.center,
                    children: [
                      pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.center,
                        children: [
                          // pw.Text(
                          //   style: pw.TextStyle(
                          //     font: fontRegular,
                          //     fontSize: 9,
                          //   ),
                          //   'Customer Name:',
                          // ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                            ),
                            customer.name,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 10),
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
                                      .center,
                              children: [
                                pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: 9,
                                  ),
                                  'Date:',
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 10,
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
                                  pw
                                      .CrossAxisAlignment
                                      .center,
                              children: [
                                pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: 9,
                                  ),
                                  'Time:',
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 10,
                                  ),
                                  formatTime(
                                    DateTime.now(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(),
                  pw.SizedBox(height: 15),
                  pw.Builder(
                    builder: (beansContext) {
                      if (shop.manageCustomerAccount ==
                          true) {
                        return pw.Column(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .center,
                              children: [
                                pw.Center(
                                  child: pw.Text(
                                    'Account Balance:',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      font: fontBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 1),

                            pw.Padding(
                              padding:
                                  const pw.EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw
                                        .MainAxisAlignment
                                        .center,
                                mainAxisSize:
                                    pw.MainAxisSize.max,
                                children: [
                                  pw.Center(
                                    child: pw.Expanded(
                                      flex: 3,
                                      child: pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 12,
                                        ),
                                        formatMoneyMid(
                                          amount:
                                              (customer
                                                  .getBalance()),
                                          context: context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),
                  pw.Builder(
                    builder: (beansContext) {
                      if (shop.manageCustomerReward ==
                          true) {
                        return pw.Column(
                          children: [
                            pw.SizedBox(height: 10),
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .center,
                              children: [
                                pw.Center(
                                  child: pw.Text(
                                    'Cashback Balance:',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      font: fontBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 1),

                            pw.Padding(
                              padding:
                                  const pw.EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw
                                        .MainAxisAlignment
                                        .center,
                                mainAxisSize:
                                    pw.MainAxisSize.max,
                                children: [
                                  pw.Center(
                                    child: pw.Expanded(
                                      flex: 3,
                                      child: pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 12,
                                        ),
                                        formatMoneyMid(
                                          amount:
                                              (customer
                                                      .cashReward ??
                                                  0),
                                          context: context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),

                  pw.SizedBox(height: 3),
                  pw.Divider(thickness: 0.6, height: 10),
                ],
              ),
            ),
            pw.Expanded(child: pw.Spacer()),
          ],
    ),
  );

  return pdf.save();
}

Future<void> generateAndPreviewPdfCustomerAccountBalance({
  required TempCustomersClass customer,
  required BuildContext context,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      returnPurchaseProvider().toggleIsLoading(true);
      final Uint8List bytes =
          await _buildPdfCustomerAccountBalance(
            customer: customer,
            shop: returnShopProvider().userShop()!,
            context: context,
          );
      var customerId = customer.uuid!.toString().substring(
        0,
        5,
      );
      var name =
          "Stockall_Customer_Account_$customerId.${DateTime.now().millisecondsSinceEpoch}";

      if (Platform.isAndroid || Platform.isIOS) {
        await savePdfMobileCustomer(bytes, name);
      } else {
        await mainLocalLog('Printing For Desktop');
        await savePdfDesktopCustomer(bytes, name);
      }

      if (context.mounted) {
        returnPurchaseProvider().toggleIsLoading(false);
      }
    },
  );
}

Future<void> savePdfDesktopCustomer(
  Uint8List bytes,
  String name,
) async {
  await FileSaver.instance.saveFile(
    name: name,
    fileExtension: "pdf",
    bytes: bytes,
    mimeType: MimeType.pdf,
  );
}

Future<void> savePdfMobileCustomer(
  Uint8List bytes,
  String name,
) async {
  await Printing.sharePdf(
    bytes: bytes,
    filename: '$name.pdf',
  );
}

void downloadPdfWebRollCustomerAccountBalance({
  required TempCustomersClass customer,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
  required int printType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        await mainLocalLog('Begin Download');
        final pdfBytes =
            await _buildPdfRollCustomerAccountBalance(
              customer: customer,
              shop: returnShopProvider().userShop()!,
              context: context,
              printerType: printType,
            );

        // ✅ Ensure Uint8List
        final pdfUint8 = Uint8List.fromList(pdfBytes);

        // Step 1: Download
        final blob = html.Blob([
          pdfUint8,
        ], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor =
            html.AnchorElement(href: url)
              ..download = filename
              ..style.display = 'none';

        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);

        // Step 2: Print (make sure this runs in same click event if possible)
        await Printing.layoutPdf(
          onLayout: (format) async => pdfUint8,
        );

        if (context.mounted) {
          returnPurchaseProvider().toggleIsLoading(false);
        }
        // return pdfUint8;
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error downloading/printing PDF: $e\n$stackTrace',
        );
      }
    },
  );
}

Future<Uint8List> _buildPdfRollCustomerAccountBalance({
  required TempCustomersClass customer,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  double headingText = printerType == 1 ? 12 : 14;
  double parText = printerType == 1 ? 7 : 9;
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
          printerType == 1
              ? PdfPageFormat.roll57
              : PdfPageFormat.roll80,
      margin: pw.EdgeInsets.only(
        left: kIsWeb ? 2 : 0,
        top: 5,
        right: kIsWeb ? 15 : 25,
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
                          builder: (pw.Context pdfContext) {
                            if (shop.showShopName!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.name,
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: headingText,
                                    ),
                                    // maxLines: 2,
                                    overflow:
                                        pw
                                            .TextOverflow
                                            .clip,
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),
                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showEmail! &&
                                shop.email != null) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.email ?? '',
                                    style: pw.TextStyle(
                                      font: fontRegular,
                                      fontSize: parText,
                                    ),
                                    overflow:
                                        pw
                                            .TextOverflow
                                            .clip,
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
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
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      textAlign: pw.TextAlign.center,
                      'Customer Account Balance',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: parText,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Divider(
                  color: PdfColor.fromHex('#1C1C1C'),
                  thickness: 0.5,
                  height: 3,
                ),
                pw.SizedBox(height: 2),
                pw.Column(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: parText,
                      ),
                      'Customer Name:',
                    ),
                    pw.SizedBox(height: 1),
                    pw.Text(
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: parText,
                      ),
                      customer.name,
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 0.6, height: 6),
                pw.SizedBox(height: 10),
                pw.Builder(
                  builder: (beansContext) {
                    if (shop.manageCustomerAccount ==
                        true) {
                      return pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.center,
                            children: [
                              pw.Center(
                                child: pw.Text(
                                  'Account Balance:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 1),

                          pw.Padding(
                            padding:
                                const pw.EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .center,
                              mainAxisSize:
                                  pw.MainAxisSize.max,
                              children: [
                                pw.Center(
                                  child: pw.Expanded(
                                    flex: 3,
                                    child: pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 12,
                                      ),
                                      formatMoneyMid(
                                        amount:
                                            (customer
                                                .getBalance()),
                                        context: context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.Builder(
                  builder: (beansContext) {
                    if (shop.manageCustomerReward == true) {
                      return pw.Column(
                        children: [
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.center,
                            children: [
                              pw.Center(
                                child: pw.Text(
                                  'Cashback Balance:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 1),

                          pw.Padding(
                            padding:
                                const pw.EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .center,
                              mainAxisSize:
                                  pw.MainAxisSize.max,
                              children: [
                                pw.Center(
                                  child: pw.Expanded(
                                    flex: 3,
                                    child: pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 12,
                                      ),
                                      formatMoneyMid(
                                        amount:
                                            (customer
                                                    .cashReward ??
                                                0),
                                        context: context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),

                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 10),
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment:
                                pw
                                    .CrossAxisAlignment
                                    .center,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 6,
                                ),
                                'Date:',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 6,
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
                                pw
                                    .CrossAxisAlignment
                                    .center,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 6,
                                ),
                                'Time:',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 6,
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
                pw.Divider(thickness: 0.6, height: 10),
              ],
            ),
          ),

      // pw.Expanded(child: pw.Spacer()),
    ),
  );

  return pdf.save();
}

Future<void>
generateAndPreviewPdfRollCustomerAccountBalance({
  required TempCustomersClass customer,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      final Uint8List pdfBytes =
          await _buildPdfRollCustomerAccountBalance(
            customer: customer,
            shop: shop,
            context: context,
            printerType: printerType,
          );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );
    },
  );
}
