import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
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

void downloadPdfWebInvoice({
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required List<TempMainReceipt> receipts,
  required String staffName,
  // required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      try {
        final pdfBytes = await _buildPdfInvoice(
          invoice: invoice,
          context: context,
          receipts: receipts,
          staffName: staffName,
          records: records,
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

        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
      } catch (e, stackTrace) {
        print('❌ Error downloading PDF: $e\n$stackTrace');
      }
    },
  );
}

Future<Uint8List> _buildPdfInvoice({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required String staffName,
  required List<TempProductSaleRecord> records,
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
                        'Invoice Receipt',
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
                                    staffName,
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
                                    'Customer Name:',
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 10,
                                    ),
                                    invoice.customerName ??
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
                  pw.Builder(
                    builder: (pw.Context pdfContext) {
                      if (shop.showSecond!) {
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
                                        'Payment Method:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        invoice
                                            .paymentMethod,
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
                                        'Amount(s):',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Column(
                                        crossAxisAlignment:
                                            pw
                                                .CrossAxisAlignment
                                                .start,
                                        children: [
                                          pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 8,
                                            ),
                                            'Cash: ${formatMoneyMid(amount: invoice.cashAlt, context: context)}',
                                          ),
                                          pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 8,
                                            ),
                                            'Bank: ${formatMoneyMid(amount: invoice.bank, context: context)}',
                                          ),
                                        ],
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
                                          invoice.createdAt,
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
                                          invoice.createdAt,
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

                  ...records.map(
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
                              '${record.productName} ',
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
                            child: pw.Column(
                              crossAxisAlignment:
                                  pw
                                      .CrossAxisAlignment
                                      .start,
                              children: [
                                pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: 10,
                                  ),
                                  formatMoneyMid(
                                    amount:
                                        (invoice.fixedDiscount ==
                                                        null &&
                                                    invoice.generalDiscount ==
                                                        null) &&
                                                record.discount !=
                                                    null
                                            ? ((record.originalCost ??
                                                    0) -
                                                (record.discountedAmount ??
                                                    0))
                                            : (record
                                                    .originalCost ??
                                                0),
                                    context: context,
                                  ),
                                ),
                                pw.Builder(
                                  builder: (pdfContext) {
                                    if (record.discount !=
                                            null &&
                                        !record
                                            .customPriceSet &&
                                        (invoice.fixedDiscount ==
                                                null &&
                                            invoice.generalDiscount ==
                                                null)) {
                                      return pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          decoration:
                                              pw
                                                  .TextDecoration
                                                  .lineThrough,
                                          fontSize: 7,
                                        ),
                                        formatMoneyMid(
                                          amount:
                                              (record.originalCost ??
                                                  0),
                                          context: context,
                                        ),
                                      );
                                    } else {
                                      return pw.Container();
                                    }
                                  },
                                ),
                              ],
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
                            amount: returnInvoicesProvider()
                                .getOriginalCostInvoice(
                                  invoice,
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
                        child: pw.Row(
                          children: [
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                              ),
                              'VAT:',
                            ),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                              ),
                              '(${invoice.vat ?? 0}%)',
                            ),
                          ],
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
                            amount: returnInvoicesProvider()
                                .getVATInvoice(
                                  invoice: invoice,
                                ),
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Builder(
                    builder: (pdfContext) {
                      if (invoice.fixedDiscount != null ||
                          invoice.generalDiscount != null) {
                        return pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .spaceEvenly,
                              children: [
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 8,
                                        ),
                                        'Discount:',
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 8,
                                        ),
                                        invoice.generalDiscount !=
                                                null
                                            ? " (${invoice.generalDiscount}%)"
                                            : '',
                                      ),
                                    ],
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
                                      amount: returnInvoicesProvider()
                                          .getDiscountAmountForInvoice(
                                            invoice,
                                          ),
                                      context: context,
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
                  pw.SizedBox(height: 5),
                  pw.Builder(
                    builder: (pdfContext) {
                      if (returnInvoicesProvider()
                              .getBalance(
                                invoice: invoice,
                              ) >
                          0) {
                        return pw.Column(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .spaceEvenly,
                              children: [
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 8,
                                        ),
                                        'Balance:',
                                      ),
                                    ],
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
                                      amount:
                                          (returnInvoicesProvider()
                                              .getBalance(
                                                invoice:
                                                    invoice,
                                              )),
                                      context: context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),

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
                          'Paid:',
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
                            amount: returnInvoicesProvider()
                                .getAmountPaid(
                                  invoice: invoice,
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
                            amount: returnInvoicesProvider()
                                .getTotalMainRevenueInvoice(
                                  invoice: invoice,
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

Future<void> generateAndPreviewPdfInvoice({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required String staffName,
  required List<TempProductSaleRecord> records,
  required BuildContext context,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(true);
      final Uint8List bytes = await _buildPdfInvoice(
        invoice: invoice,
        shop: returnShopProvider().userShop()!,
        receipts: receipts,
        staffName: staffName,
        records: records,
        context: context,
      );
      var invoiceId = invoice.uuid!.toString().substring(
        0,
        5,
      );
      var name =
          "Stockall_Invoice_$invoiceId.${DateTime.now().millisecondsSinceEpoch}";

      if (Platform.isAndroid || Platform.isIOS) {
        await savePdfMobileInvoice(bytes, name);
      } else {
        print('Printing For Desktop');
        await savePdfDesktopInvoice(bytes, name);
      }

      if (context.mounted) {
        returnReceiptProvider(
          context,
          listen: false,
        ).toggleIsLoading(false);
      }
    },
  );
}

Future<void> savePdfDesktopInvoice(
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

Future<void> savePdfMobileInvoice(
  Uint8List bytes,
  String name,
) async {
  await Printing.sharePdf(
    bytes: bytes,
    filename: '$name.pdf',
  );
}

void downloadPdfWebRollInvoice({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required List<TempProductSaleRecord> records,
  required String staffName,
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
        final pdfBytes = await _buildPdfRollInvoice(
          invoice: invoice,
          receipts: receipts,
          records: records,
          staffName: staffName,
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

Future<Uint8List> _buildPdfRollInvoice({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required List<TempProductSaleRecord> records,
  required String staffName,
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
                      'Invoice Receipt',
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
                                      staffName,
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
                                      'Customer Name:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      invoice.customerName ??
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
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (shop.showSecond!) {
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
                                      'Payment Method:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      invoice.paymentMethod,
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
                                      'Amount(s):',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw
                                              .CrossAxisAlignment
                                              .start,
                                      children: [
                                        pw.Text(
                                          style: pw.TextStyle(
                                            font:
                                                fontRegular,
                                            fontSize:
                                                parTextAlt,
                                          ),
                                          'Cash: ${formatMoneyMid(amount: invoice.cashAlt, context: context)}',
                                        ),
                                        pw.Text(
                                          style: pw.TextStyle(
                                            font:
                                                fontRegular,
                                            fontSize:
                                                parTextAlt,
                                          ),
                                          'Bank: ${formatMoneyMid(amount: invoice.bank, context: context)}',
                                        ),
                                      ],
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
                                        invoice.createdAt,
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
                                        invoice.createdAt,
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

                ...records.map(
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
                            '${record.productName} ',
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
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: parText,
                                ),
                                formatMoneyMid(
                                  amount:
                                      (invoice.fixedDiscount ==
                                                      null &&
                                                  invoice.generalDiscount ==
                                                      null) &&
                                              record.discount !=
                                                  null
                                          ? ((record.originalCost ??
                                                  0) -
                                              (record.discountedAmount ??
                                                  0))
                                          : (record
                                                  .originalCost ??
                                              0),
                                  context: context,
                                ),
                              ),
                              pw.Builder(
                                builder: (pdfContext) {
                                  if (record.discount !=
                                          null &&
                                      !record
                                          .customPriceSet &&
                                      (invoice.fixedDiscount ==
                                              null &&
                                          invoice.generalDiscount ==
                                              null)) {
                                    return pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        decoration:
                                            pw
                                                .TextDecoration
                                                .lineThrough,
                                        fontSize: 6,
                                      ),
                                      formatMoneyMid(
                                        amount:
                                            (record.originalCost ??
                                                0),
                                        context: context,
                                      ),
                                    );
                                  } else {
                                    return pw.Container();
                                  }
                                },
                              ),
                            ],
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
                          amount: returnInvoicesProvider()
                              .getOriginalCostInvoice(
                                invoice,
                              ),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Builder(
                  builder: (pdfContext) {
                    if (invoice.fixedDiscount != null ||
                        invoice.generalDiscount != null) {
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
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      'Discount:',
                                    ),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      invoice.generalDiscount !=
                                              null
                                          ? " (${invoice.generalDiscount}%)"
                                          : '',
                                    ),
                                  ],
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
                                    amount: returnInvoicesProvider()
                                        .getDiscountAmountForInvoice(
                                          invoice,
                                        ),
                                    context: context,
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
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      flex: 9,
                      child: pw.Row(
                        children: [
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parTextAlt,
                            ),
                            'VAT:',
                          ),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parTextAlt,
                            ),
                            '(${invoice.vat ?? 0}%)',
                          ),
                        ],
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
                          amount: returnInvoicesProvider()
                              .getVATInvoice(
                                invoice: invoice,
                              ),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1),
                pw.Builder(
                  builder: (pdfContext) {
                    if (returnInvoicesProvider().getBalance(
                          invoice: invoice,
                        ) >
                        0) {
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
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      'Balance:',
                                    ),
                                  ],
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
                                    amount:
                                        returnInvoicesProvider()
                                            .getBalance(
                                              invoice:
                                                  invoice,
                                            ),
                                    context: context,
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
                pw.SizedBox(height: 1),
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        pw.Expanded(
                          flex: 9,
                          child: pw.Row(
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: parTextAlt,
                                ),
                                'Paid:',
                              ),
                            ],
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
                              amount:
                                  returnInvoicesProvider()
                                      .getAmountPaid(
                                        invoice: invoice,
                                      ),
                              context: context,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 1),
                  ],
                ),
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
                          amount: returnInvoicesProvider()
                              .getTotalMainRevenueInvoice(
                                invoice: invoice,
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
                pw.SizedBox(height: 35),
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
                    if (records.length > 15) {
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
                pw.Builder(
                  builder: (beansContext) {
                    if (records.length > 15) {
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

Future<void> generateAndPreviewPdfRollInvoice({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      final Uint8List pdfBytes = await _buildPdfRollInvoice(
        invoice: invoice,
        receipts: receipts,
        records: records,
        staffName: staffName,
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
