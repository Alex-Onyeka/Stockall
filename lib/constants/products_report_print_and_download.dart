import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

void downloadProductReportPdfWebRoll({
  required BuildContext context,
  required String filename,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        await mainLocalLog('Begin Download');
        final pdfBytes = await _buildPdfRoll(context);

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
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
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

Future<void> generateAndPreviewProductReportPdfRoll({
  required BuildContext context,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(true);
      final Uint8List pdfBytes = await _buildPdfRoll(
        context,
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

Future<Uint8List> _buildPdfRoll(
  BuildContext context,
) async {
  var shop = returnShopProvider().userShop()!;
  var printerType = shop.printType;
  double headingText = printerType == 1 ? 10 : 12;
  double parText = printerType == 1 ? 6 : 8;
  // double parTextAlt = printerType == 1 ? 5 : 7;
  double totalText = printerType == 1 ? 8 : 9;
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
        right: kIsWeb ? 10 : 15,
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
                        pw.Row(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              textAlign:
                                  pw.TextAlign.center,
                              "#Shop Id: ${shopRef()}",
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: parText,
                              ),
                              // maxLines: 2,
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
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
                                  pw.TextOverflow.clip,
                            ),
                          ],
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
                      'GENERAL ITEMS RECORD',
                      style: pw.TextStyle(
                        font: fontBold,
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
                                  font: fontBold,
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
                                  font: fontBold,
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
                pw.SizedBox(height: 2),
                pw.Divider(thickness: 0.6, height: 6),

                pw.Builder(
                  builder: (beansContext) {
                    if (shop.manageInventoryStorage ==
                        true) {
                      return pw.Column(
                        children: [
                          pw.Container(height: 35),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                textAlign:
                                    pw.TextAlign.center,
                                'STORAGE ITEMS RECORDS',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Divider(
                            color: PdfColor.fromHex(
                              '#1C1C1C',
                            ),
                            thickness: 0.5,
                            height: 3,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 6,
                                child: pw.Text(
                                  'Name:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  'Qtty:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...returnStorageProductProvider()
                              .storageProductListMain
                              .map(
                                (record) => pw.Padding(
                                  padding:
                                      const pw.EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw
                                            .MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      pw.Expanded(
                                        flex: 6,
                                        child: pw.Text(
                                          style:
                                              pw.TextStyle(
                                                fontSize:
                                                    parText,
                                                font:
                                                    fontBold,
                                              ),
                                          '${record.name.toUpperCase()} ',
                                        ),
                                      ),
                                      pw.SizedBox(width: 2),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Text(
                                          style:
                                              pw.TextStyle(
                                                fontSize:
                                                    parText,
                                                font:
                                                    fontBold,
                                              ),
                                          '[${formatLargeNumberDoubleWidgetDecimal(record.quantity ?? 0)}] ',
                                        ),
                                      ),
                                    ],
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
                  builder: (beansContext) {
                    if (shop.manageDepartments != true) {
                      return pw.Column(
                        children: [
                          pw.Container(height: 35),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                textAlign:
                                    pw.TextAlign.center,
                                'SALES ITEMS RECORDS',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Divider(
                            color: PdfColor.fromHex(
                              '#1C1C1C',
                            ),
                            thickness: 0.5,
                            height: 3,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 6,
                                child: pw.Text(
                                  'Name:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  'Qtty:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 4,
                                child: pw.Text(
                                  'Amount:',
                                  style: pw.TextStyle(
                                    fontSize: parText,
                                    font: fontBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // pw.Container(height: 5),
                          ...returnData().productListMain.map(
                            (record) => pw.Padding(
                              padding:
                                  const pw.EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw
                                        .MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  pw.Expanded(
                                    flex: 6,
                                    child: pw.Text(
                                      style: pw.TextStyle(
                                        fontSize: parText,
                                        font: fontBold,
                                      ),
                                      '${record.name.toUpperCase()} ',
                                    ),
                                  ),
                                  pw.SizedBox(width: 2),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Text(
                                      style: pw.TextStyle(
                                        fontSize: parText,
                                        font: fontBold,
                                      ),
                                      '[${formatLargeNumberDoubleWidgetDecimal(record.quantity ?? 0)}] ',
                                    ),
                                  ),
                                  pw.SizedBox(width: 2),
                                  pw.Expanded(
                                    flex: 4,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw
                                              .CrossAxisAlignment
                                              .start,
                                      children: [
                                        pw.Text(
                                          style:
                                              pw.TextStyle(
                                                fontSize:
                                                    parText,
                                                font:
                                                    fontBold,
                                              ),
                                          formatMoneyMid(
                                            amount:
                                                (record.sellingPrice ??
                                                    0) *
                                                (record.quantity ??
                                                    1),
                                            context:
                                                context,
                                          ).split('.').first,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return pw.Column(
                        children: [
                          pw.Column(
                            children:
                                returnDepartmentProvider()
                                    .departments
                                    .map(
                                      (dept) => pw.Column(
                                        children: [
                                          pw.Container(
                                            height: 35,
                                          ),
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
                                                dept.name
                                                    .toUpperCase(),
                                                style: pw.TextStyle(
                                                  font:
                                                      fontBold,
                                                  fontSize:
                                                      parText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(
                                            height: 2,
                                          ),
                                          pw.Divider(
                                            color:
                                                PdfColor.fromHex(
                                                  '#1C1C1C',
                                                ),
                                            thickness: 0.5,
                                            height: 3,
                                          ),
                                          pw.SizedBox(
                                            height: 2,
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                flex: 6,
                                                child: pw.Text(
                                                  'Name:',
                                                  style: pw.TextStyle(
                                                    fontSize:
                                                        parText,
                                                    font:
                                                        fontBold,
                                                  ),
                                                ),
                                              ),
                                              pw.Expanded(
                                                flex: 2,
                                                child: pw.Text(
                                                  'Qtty:',
                                                  style: pw.TextStyle(
                                                    fontSize:
                                                        parText,
                                                    font:
                                                        fontBold,
                                                  ),
                                                ),
                                              ),
                                              pw.Expanded(
                                                flex: 4,
                                                child: pw.Text(
                                                  'Amount:',
                                                  style: pw.TextStyle(
                                                    fontSize:
                                                        parText,
                                                    font:
                                                        fontBold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // pw.SizedBox(
                                          //   height: 5,
                                          // ),
                                          ...returnData()
                                              .productListMain
                                              .where(
                                                (item) =>
                                                    item.departmentUuid ==
                                                    dept.uuid,
                                              )
                                              .map(
                                                (
                                                  record,
                                                ) => pw.Padding(
                                                  padding: const pw.EdgeInsets.symmetric(
                                                    vertical:
                                                        2,
                                                  ),
                                                  child: pw.Row(
                                                    mainAxisAlignment:
                                                        pw.MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      pw.Expanded(
                                                        flex:
                                                            6,
                                                        child: pw.Text(
                                                          style: pw.TextStyle(
                                                            fontSize:
                                                                parText,
                                                            font:
                                                                fontBold,
                                                          ),
                                                          '${record.name.toUpperCase()} ',
                                                        ),
                                                      ),
                                                      pw.SizedBox(
                                                        width:
                                                            2,
                                                      ),
                                                      pw.Expanded(
                                                        flex:
                                                            2,
                                                        child: pw.Text(
                                                          style: pw.TextStyle(
                                                            fontSize:
                                                                parText,
                                                            font:
                                                                fontBold,
                                                          ),
                                                          '[${formatLargeNumberDoubleWidgetDecimal(record.quantity ?? 0)}] ',
                                                        ),
                                                      ),
                                                      pw.SizedBox(
                                                        width:
                                                            2,
                                                      ),
                                                      pw.Expanded(
                                                        flex:
                                                            4,
                                                        child: pw.Column(
                                                          crossAxisAlignment:
                                                              pw.CrossAxisAlignment.start,
                                                          children: [
                                                            pw.Text(
                                                              style: pw.TextStyle(
                                                                fontSize:
                                                                    parText,
                                                                font:
                                                                    fontBold,
                                                              ),
                                                              formatMoneyMid(
                                                                    amount:
                                                                        ((record.sellingPrice ??
                                                                                0) *
                                                                            (record.quantity ??
                                                                                1)),
                                                                    context:
                                                                        context,
                                                                  )
                                                                  .split(
                                                                    '.',
                                                                  )
                                                                  .first,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          ),
                          pw.Column(
                            children: [
                              pw.Container(height: 35),
                              pw.Row(
                                mainAxisAlignment:
                                    pw
                                        .MainAxisAlignment
                                        .center,
                                children: [
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    'NO DEPARTMENT'
                                        .toUpperCase(),
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: parText,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 2),
                              pw.Divider(
                                color: PdfColor.fromHex(
                                  '#1C1C1C',
                                ),
                                thickness: 0.5,
                                height: 3,
                              ),
                              pw.SizedBox(height: 2),
                              pw.Row(
                                children: [
                                  pw.Expanded(
                                    flex: 6,
                                    child: pw.Text(
                                      'Name:',
                                      style: pw.TextStyle(
                                        fontSize: parText,
                                        font: fontBold,
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Text(
                                      'Qtty:',
                                      style: pw.TextStyle(
                                        fontSize: parText,
                                        font: fontBold,
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 4,
                                    child: pw.Text(
                                      'Amount:',
                                      style: pw.TextStyle(
                                        fontSize: parText,
                                        font: fontBold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...returnData()
                                  .productListMain
                                  .where(
                                    (item) =>
                                        item.departmentUuid ==
                                        null,
                                  )
                                  .map(
                                    (record) => pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw
                                                .MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          pw.Expanded(
                                            flex: 6,
                                            child: pw.Text(
                                              style: pw.TextStyle(
                                                fontSize:
                                                    parText,
                                                font:
                                                    fontBold,
                                              ),
                                              '${record.name.toUpperCase()} ',
                                            ),
                                          ),
                                          pw.SizedBox(
                                            width: 2,
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: pw.Text(
                                              style: pw.TextStyle(
                                                fontSize:
                                                    parText,
                                                font:
                                                    fontBold,
                                              ),
                                              '[${formatLargeNumberDoubleWidgetDecimal(record.quantity ?? 0)}] ',
                                            ),
                                          ),
                                          pw.SizedBox(
                                            width: 2,
                                          ),
                                          pw.Expanded(
                                            flex: 4,
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw
                                                      .CrossAxisAlignment
                                                      .start,
                                              children: [
                                                pw.Text(
                                                  style: pw.TextStyle(
                                                    fontSize:
                                                        parText,
                                                    font:
                                                        fontBold,
                                                  ),
                                                  formatMoneyMid(
                                                    amount:
                                                        ((record.sellingPrice ??
                                                                0) *
                                                            (record.quantity ??
                                                                1)),
                                                    context:
                                                        context,
                                                  ).split('.').first,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                pw.Divider(),
                pw.Builder(
                  builder: (beansContext) {
                    if (returnData()
                            .productListMain
                            .length >
                        15) {
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
