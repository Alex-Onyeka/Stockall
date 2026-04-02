import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

void downloadDocket({
  required BuildContext context,
  required String fileName,
  required TempCart cart,
  required String waiter,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        print('Begin Download');
        final pdfBytes = await _buildPdfRoll(
          context: context,
          fileName: fileName,
          waiter: waiter,
          cart: cart,
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
              ..download = fileName
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
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
        // return pdfUint8;
      } catch (e, stackTrace) {
        print(
          '❌ Error downloading/printing PDF: $e\n$stackTrace',
        );
      }
    },
  );
}

Future<void> printDocket({
  required BuildContext context,
  required String fileName,
  required TempCart cart,
  required String waiter,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(true);
      final Uint8List pdfBytes = await _buildPdfRoll(
        context: context,
        fileName: fileName,
        waiter: waiter,
        cart: cart,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );
      if (context.mounted) {
        returnReceiptProvider(
          context,
          listen: false,
        ).toggleIsLoading(false);
      }
    },
  );
}

Future<Uint8List> _buildPdfRoll({
  required BuildContext context,
  required String fileName,
  required TempCart cart,
  required String waiter,
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
      margin: const pw.EdgeInsets.only(
        left: 0,
        top: 15,
        right: 25,
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
                        pw.Column(
                          children: [
                            // pw.SizedBox(height: 1),
                            pw.Text(
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
                            ),
                          ],
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
                pw.Column(
                  children: [
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
                                'Staff Name:',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                                cart.staffName ?? 'Staff',
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
                                'Table:',
                              ),
                              pw.SizedBox(height: 1),
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

                pw.Row(
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
                  ],
                ),
                pw.SizedBox(height: 1),

                ...cart.cartItems.map(
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
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 3),

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
              ],
            ),
          ),

      // pw.Expanded(child: pw.Spacer()),
    ),
  );

  return pdf.save();
}
