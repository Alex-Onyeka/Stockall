import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
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

void downloadPdfWebWaybill({
  required TempWayBills waybill,
  required BuildContext context,
  required String filename,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      try {
        final pdfBytes = await _buildPdfWaybill(
          waybill: waybill,
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

        returnWaybillProvider().toggleIsLoading(false);
      } catch (e, stackTrace) {
        print('❌ Error downloading PDF: $e\n$stackTrace');
      }
    },
  );
}

Future<Uint8List> _buildPdfWaybill({
  required TempWayBills waybill,
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
                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (returnShopProvider()
                                      .selectedLogo !=
                                  null) {
                                return pw.Container(
                                  height:
                                      (returnShopProvider()
                                                      .imageWidth ??
                                                  0) >
                                              (2 *
                                                  (returnShopProvider()
                                                          .imageHeight ??
                                                      0))
                                          ? 35
                                          : 80,
                                  width: 200,
                                  child: pw.Image(
                                    pw.MemoryImage(
                                      returnShopProvider()
                                              .selectedLogo ??
                                          Uint8List(12),
                                    ),
                                    fit: pw.BoxFit.contain,
                                  ),
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),
                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showShopName!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 4),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60, // match margins
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Text(
                                        shop.name,
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 16,
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

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showEmail! &&
                                  shop.email != null) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 4),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Text(
                                        shop.email ?? '',
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
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

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showPhone!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),

                                    pw.Text(
                                      textAlign:
                                          pw
                                              .TextAlign
                                              .center,
                                      shop.phoneNumber ??
                                          '',
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            shop.phoneNumber ==
                                                    null
                                                ? 1
                                                : 9,
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
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showAddress!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Text(
                                        shop.shopAddress ??
                                            'Address Not Set',
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
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

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showFacebookTop!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw
                                                .MainAxisAlignment
                                                .center,
                                        children: [
                                          pw.Text(
                                            'Facebook: ',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontBold,
                                              fontSize: 7,
                                            ),
                                          ),
                                          pw.Text(
                                            shop.faceBookHandle ??
                                                'Facebook Not Set',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 9,
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
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showInstaTop!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw
                                                .MainAxisAlignment
                                                .center,
                                        children: [
                                          pw.Text(
                                            'Instagrm: ',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontBold,
                                              fontSize: 7,
                                            ),
                                          ),
                                          pw.Text(
                                            shop.instaHandle ??
                                                'Instagram Not Set',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 9,
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
                        'Waybill Receipt',
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
                  pw.Builder(
                    builder: (context) {
                      if (shop.showFirst!) {
                        return pw.Row(
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
                                      fontSize: 9,
                                    ),
                                    'Staff Name:',
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 10,
                                    ),
                                    waybill.staffName ??
                                        'Not Set',
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
                                      fontSize: 9,
                                    ),
                                    'Supplier Name:',
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 10,
                                    ),
                                    waybill.customerName ??
                                        'Not Set',
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
                  // pw.Builder(
                  //   builder: (pw.Context pdfContext) {
                  //     if (shop.showSecond!) {
                  //       return pw.Column(
                  //         children: [
                  //           pw.SizedBox(height: 10),
                  //           pw.Row(
                  //             mainAxisAlignment:
                  //                 pw
                  //                     .MainAxisAlignment
                  //                     .spaceEvenly,
                  //             children: [
                  //               pw.Expanded(
                  //                 child: pw.Column(
                  //                   crossAxisAlignment:
                  //                       pw
                  //                           .CrossAxisAlignment
                  //                           .start,
                  //                   children: [
                  //                     pw.Text(
                  //                       style: pw.TextStyle(
                  //                         font: fontRegular,
                  //                         fontSize: 9,
                  //                       ),
                  //                       'Payment Method:',
                  //                     ),
                  //                     pw.SizedBox(
                  //                       height: 5,
                  //                     ),
                  //                     pw.Text(
                  //                       style: pw.TextStyle(
                  //                         font: fontBold,
                  //                         fontSize: 10,
                  //                       ),
                  //                       waybill
                  //                           .paymentMethod,
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //               pw.Expanded(
                  //                 child: pw.Column(
                  //                   crossAxisAlignment:
                  //                       pw
                  //                           .CrossAxisAlignment
                  //                           .start,
                  //                   children: [
                  //                     pw.Text(
                  //                       style: pw.TextStyle(
                  //                         font: fontRegular,
                  //                         fontSize: 9,
                  //                       ),
                  //                       'Amount(s):',
                  //                     ),
                  //                     pw.SizedBox(
                  //                       height: 5,
                  //                     ),
                  //                     pw.Column(
                  //                       crossAxisAlignment:
                  //                           pw
                  //                               .CrossAxisAlignment
                  //                               .start,
                  //                       children: [
                  //                         pw.Text(
                  //                           style: pw.TextStyle(
                  //                             font:
                  //                                 fontRegular,
                  //                             fontSize: 8,
                  //                           ),
                  //                           'Cash: ${formatMoneyMid(amount: waybill.cashAlt, context: context)}',
                  //                         ),
                  //                         pw.Text(
                  //                           style: pw.TextStyle(
                  //                             font:
                  //                                 fontRegular,
                  //                             fontSize: 8,
                  //                           ),
                  //                           'Bank: ${formatMoneyMid(amount: waybill.bank, context: context)}',
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       );
                  //     } else {
                  //       return pw.Container();
                  //     }
                  //   },
                  // ),
                  pw.Builder(
                    builder: (pw.Context pdfContext) {
                      if (shop.showThird!) {
                        return pw.Column(
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
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                        'Date:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        formatDateTime(
                                          waybill.createdAt ??
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
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                        'Time:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        formatTime(
                                          waybill.createdAt ??
                                              DateTime.now(),
                                        ),
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
                  pw.SizedBox(height: 5),
                  pw.Divider(),

                  pw.Text(
                    'Items:',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.SizedBox(height: 5),

                  ...waybill.items.map(
                    (record) => pw.Padding(
                      padding:
                          const pw.EdgeInsets.symmetric(
                            vertical: 3,
                          ),
                      child: pw.Row(
                        mainAxisAlignment:
                            pw
                                .MainAxisAlignment
                                .spaceBetween,
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              '${record.itemName} ',
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              style: pw.TextStyle(
                                fontSize: 8,
                              ),
                              '( ${formatLargeNumberDouble(record.quantity)} ) ',
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 10,
                              ),
                              formatMoneyMid(
                                amount: (record.amount),
                                context: context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 12),
                  pw.Divider(),

                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 8,
                          ),
                          'Subtotal:',
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 8,
                          ),
                          formatMoneyMid(
                            amount: returnWaybillProvider()
                                .getTotalMainRevenueWaybill(
                                  waybill,
                                ),
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                          ),
                          'Total:',
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                          ),
                          formatMoneyMid(
                            amount: returnWaybillProvider()
                                .getTotalMainRevenueWaybill(
                                  waybill,
                                ),
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Expanded(child: pw.Spacer()),
          ],
    ),
  );

  return pdf.save();
}

Future<void> generateAndPreviewPdfWaybill({
  required TempWayBills waybill,
  required BuildContext context,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      returnWaybillProvider().toggleIsLoading(true);
      final Uint8List bytes = await _buildPdfWaybill(
        waybill: waybill,
        shop: returnShopProvider().userShop()!,
        context: context,
      );
      var waybillId = waybill.uuid!.toString().substring(
        0,
        5,
      );
      var name =
          "Stockall_Waybill_$waybillId.${DateTime.now().millisecondsSinceEpoch}";

      if (Platform.isAndroid || Platform.isIOS) {
        await savePdfMobileWaybill(bytes, name);
      } else {
        print('Printing For Desktop');
        await savePdfDesktopWaybill(bytes, name);
      }

      if (context.mounted) {
        returnWaybillProvider().toggleIsLoading(false);
      }
    },
  );
}

Future<void> savePdfDesktopWaybill(
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

Future<void> savePdfMobileWaybill(
  Uint8List bytes,
  String name,
) async {
  await Printing.sharePdf(
    bytes: bytes,
    filename: '$name.pdf',
  );
}

void downloadPdfWebRollWaybill({
  required TempWayBills waybill,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
  required int printType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        print('Begin Download');
        final pdfBytes = await _buildPdfRollWaybill(
          waybill: waybill,
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
          returnWaybillProvider().toggleIsLoading(false);
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

Future<Uint8List> _buildPdfRollWaybill({
  required TempWayBills waybill,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  double headingText = printerType == 1 ? 12 : 14;
  double parText = printerType == 1 ? 7 : 9;
  double parTextAlt = printerType == 1 ? 5 : 7;
  double totalText = printerType == 1 ? 8 : 10;
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
      margin: const pw.EdgeInsets.only(
        left: 0,
        top: 15,
        right: 25,
        bottom: 1,
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
                        if (returnShopProvider()
                                .selectedLogo !=
                            null)
                          pw.Container(
                            height:
                                (returnShopProvider()
                                                .imageWidth ??
                                            0) >
                                        (2 *
                                            (returnShopProvider()
                                                    .imageHeight ??
                                                0))
                                    ? 25
                                    : 75,
                            width: 200,
                            child: pw.Image(
                              pw.MemoryImage(
                                returnShopProvider()
                                        .selectedLogo ??
                                    Uint8List(12),
                              ),
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                        if (returnShopProvider()
                                .selectedLogo !=
                            null)
                          pw.SizedBox(height: 2),
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

                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showPhone!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.phoneNumber ?? '',
                                    style: pw.TextStyle(
                                      font: fontRegular,
                                      fontSize:
                                          shop.phoneNumber ==
                                                  null
                                              ? 1
                                              : parText,
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
                          builder: (pw.Context pdfContext) {
                            if (shop.showAddress!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.shopAddress ?? '',
                                    style: pw.TextStyle(
                                      font: fontRegular,
                                      fontSize:
                                          shop.shopAddress ==
                                                  null
                                              ? 1
                                              : parText,
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
                          builder: (pw.Context pdfContext) {
                            if (shop.showFacebookTop!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw
                                            .MainAxisAlignment
                                            .center,
                                    children: [
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,

                                        'Facebook:',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize:
                                              shop.faceBookHandle ==
                                                      null
                                                  ? 1
                                                  : parTextAlt,
                                        ),
                                      ),
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        shop.faceBookHandle ??
                                            '',
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize:
                                              shop.faceBookHandle ==
                                                      null
                                                  ? 1
                                                  : parText,
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

                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showInstaTop!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw
                                            .MainAxisAlignment
                                            .center,
                                    children: [
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,

                                        'Instagram:',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize:
                                              shop.instaHandle ==
                                                      null
                                                  ? 1
                                                  : parTextAlt,
                                        ),
                                      ),
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        shop.instaHandle ??
                                            '',
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize:
                                              shop.instaHandle ==
                                                      null
                                                  ? 1
                                                  : parText,
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
                      'Waybill Receipt',
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
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (shop.showFirst!) {
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
                                      waybill.staffName ??
                                          'Not Set',
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
                                      'Supplier Name:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      waybill.customerName ??
                                          'Not Set',
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
                // pw.Builder(
                //   builder: (pw.Context pdfContext) {
                //     if (shop.showSecond!) {
                //       return pw.Column(
                //         children: [
                //           pw.SizedBox(height: 3),
                //           pw.Row(
                //             mainAxisAlignment:
                //                 pw
                //                     .MainAxisAlignment
                //                     .spaceEvenly,
                //             children: [
                //               pw.Expanded(
                //                 child: pw.Column(
                //                   crossAxisAlignment:
                //                       pw
                //                           .CrossAxisAlignment
                //                           .start,
                //                   children: [
                //                     pw.Text(
                //                       style: pw.TextStyle(
                //                         font: fontRegular,
                //                         fontSize: parText,
                //                       ),
                //                       'Payment Method:',
                //                     ),
                //                     pw.SizedBox(height: 1),
                //                     pw.Text(
                //                       style: pw.TextStyle(
                //                         font: fontBold,
                //                         fontSize: parText,
                //                       ),
                //                       waybill
                //                           .paymentMethod,
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               pw.Expanded(
                //                 child: pw.Column(
                //                   crossAxisAlignment:
                //                       pw
                //                           .CrossAxisAlignment
                //                           .start,
                //                   children: [
                //                     pw.Text(
                //                       style: pw.TextStyle(
                //                         font: fontRegular,
                //                         fontSize: parText,
                //                       ),
                //                       'Amount(s):',
                //                     ),
                //                     pw.SizedBox(height: 1),
                //                     pw.Column(
                //                       crossAxisAlignment:
                //                           pw
                //                               .CrossAxisAlignment
                //                               .start,
                //                       children: [
                //                         pw.Text(
                //                           style: pw.TextStyle(
                //                             font:
                //                                 fontRegular,
                //                             fontSize:
                //                                 parTextAlt,
                //                           ),
                //                           'Cash: ${formatMoneyMid(amount: waybill.cashAlt, context: context)}',
                //                         ),
                //                         pw.Text(
                //                           style: pw.TextStyle(
                //                             font:
                //                                 fontRegular,
                //                             fontSize:
                //                                 parTextAlt,
                //                           ),
                //                           'Bank: ${formatMoneyMid(amount: waybill.bank, context: context)}',
                //                         ),
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       );
                //     } else {
                //       return pw.Container();
                //     }
                //   },
                // ),
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (shop.showThird!) {
                      return pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
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
                                      'Date:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      formatDateTime(
                                        waybill.createdAt ??
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
                                          .start,
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
                                      formatTime(
                                        waybill.createdAt ??
                                            DateTime.now(),
                                      ),
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
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 6),

                pw.Row(
                  children: [
                    pw.Text(
                      'Items:',
                      style: pw.TextStyle(
                        fontSize: parText,
                        font: fontBold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1),

                ...waybill.items.map(
                  (record) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '${record.itemName} ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parTextAlt,
                            ),
                            '( ${formatLargeNumberDouble(record.quantity)} ) ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parText,
                            ),
                            formatMoneyMid(
                              amount: (record.amount),
                              context: context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 10),

                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      flex: 9,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parTextAlt,
                        ),
                        'Subtotal:',
                      ),
                    ),
                    pw.Expanded(
                      flex: 7,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parTextAlt,
                        ),
                        formatMoneyMid(
                          amount: returnWaybillProvider()
                              .getTotalMainRevenueWaybill(
                                waybill,
                              ),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 1),

                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
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
                          fontSize: parText,
                        ),
                        formatMoneyMid(
                          amount: returnWaybillProvider()
                              .getTotalMainRevenueWaybill(
                                waybill,
                              ),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Flexible(
                      child: pw.Text(
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: totalText,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        shop.bottomText?.toUpperCase() ??
                            'Thank you for shopping with us'
                                .toUpperCase(),
                      ),
                    ),
                  ],
                ),
                pw.Builder(
                  builder: (beansContext) {
                    if (waybill.items.length > 15) {
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
    ),
  );

  return pdf.save();
}

Future<void> generateAndPreviewPdfRollWaybill({
  required TempWayBills waybill,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      final Uint8List pdfBytes = await _buildPdfRollWaybill(
        waybill: waybill,
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
