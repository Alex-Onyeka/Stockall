import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/documents/document_downloads.dart';
import 'package:stockall/services/pos_printing/pos_print_dispatcher.dart';
import 'package:stockall/services/printing/app_printer_service.dart';
import 'package:stockall/services/documents/document_model.dart'
    show DocType;
import 'package:stockall/services/documents/pdf_document_kit.dart'
    show docPageTheme;
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
        downloadPdfBytesWeb(pdfBytes, filename);
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error downloading PDF: $e\n$stackTrace',
        );
      } finally {
        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
      }
    },
  );
}

// A4 invoice from the shared document builder (lib/services/documents).
// receipts: the payments made against the invoice.
Future<Uint8List> _buildPdfInvoice({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required String staffName,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {
  return salesDocumentA4Pdf(
    invoiceDownloadDocument(
      invoice: invoice,
      records: records,
      receipts: receipts,
      staffName: staffName,
      shop: shop,
      assets: DocShopAssets.current(),
    ),
    shop,
  );
}

Future<void> printInvoiceA4Pdf({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required String staffName,
  required List<TempProductSaleRecord> records,
  required BuildContext context,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(true);
      try {
        final Uint8List bytes = await _buildPdfInvoice(
          invoice: invoice,
          shop: returnShopProvider().userShop()!,
          receipts: receipts,
          staffName: staffName,
          records: records,
          context: context,
        );
        await AppPrinterService.printPdf(
          onLayout: (_) async => bytes,
          name: 'Invoice_${invoice.uuid ?? ''}',
        );
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error printing A4 invoice: $e\n$stackTrace',
        );
      } finally {
        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
      }
    },
  );
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
      try {
        final Uint8List bytes = await _buildPdfInvoice(
          invoice: invoice,
          shop: returnShopProvider().userShop()!,
          receipts: receipts,
          staffName: staffName,
          records: records,
          context: context,
        );
        final now = DateTime.now();

        // dart:io Platform is not available on web.
        if (kIsWeb) {
          downloadPdfBytesWeb(
            bytes,
            documentWebDownloadName(DocType.invoice, now),
          );
          return;
        }

        var name = documentDownloadName(
          DocType.invoice,
          invoice.uuid,
          now,
        );

        if (Platform.isAndroid || Platform.isIOS) {
          await savePdfMobileInvoice(bytes, name);
        } else {
          await mainLocalLog('Printing For Desktop');
          await savePdfDesktopInvoice(bytes, name);
        }
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error downloading invoice PDF: $e\n$stackTrace',
        );
      } finally {
        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
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
        await mainLocalLog('Begin Download');
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
        await AppPrinterService.printPdf(
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
      // White page, so dark-mode PDF viewers don't show it black.
      pageTheme: docPageTheme(
        pageFormat:
            printerType == 1
                ? PdfPageFormat.roll57
                : PdfPageFormat.roll80,
        margin: pw.EdgeInsets.only(
          left: kIsWeb ? 2 : 0,
          top: 5,
          right: kIsWeb ? 15 : 0,
          bottom: 10,
        ),
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
                        pw.SizedBox(height: 1),
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
                                      'Payment Method:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      invoice.selectedBank?.displayName ??
                                          invoice.paymentMethod,
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
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
                          pw.Builder(
                            builder: (beansContext) {
                              if (invoice.subStaffName !=
                                  null) {
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
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                'Waiter:',
                                              ),
                                              pw.SizedBox(
                                                height: 1,
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontBold,
                                                  fontSize:
                                                      parText,
                                                ),
                                                invoice.subStaffName ??
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
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                'Receipt Id:',
                                              ),
                                              pw.SizedBox(
                                                height: 1,
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontBold,
                                                  fontSize:
                                                      parText,
                                                ),
                                                invoice.cartName ??
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
                                return pw.SizedBox();
                              }
                            },
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
                                '#Ticket ID',
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: parText,
                                ),
                                invoice.barcode ??
                                    returnOnlyDigits(
                                      invoice.uuid ?? '',
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (invoice.comment != null &&
                        invoice.comment?.isNotEmpty ==
                            true) {
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
                                      'Comment:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      invoice.comment ??
                                          'Comment',
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
                          flex: 6,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '${record.productName}${record.dimensionsLabel()} ${record.wastageNote().isEmpty ? '' : '\n${record.wastageNote()}'}',
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parTextAlt,
                            ),
                            '( ${formatLargeNumberDouble(record.displayQuantity())} ) ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
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
                          amount:
                              invoice
                                  .getOriginalCostInvoice(),
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
                                    amount:
                                        invoice
                                            .getDiscountAmountForInvoice(),
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
                pw.Builder(
                  builder: (beansContext) {
                    if (invoice.vat != null) {
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
                                      'VAT:',
                                    ),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
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
                                    amount:
                                        invoice
                                            .getVATInvoice(),
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
                      return pw.SizedBox();
                    }
                  },
                ),
                pw.SizedBox(height: 1),
                pw.Builder(
                  builder: (pdfContext) {
                    if (invoice.getBalance() > 0) {
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
                                        invoice
                                            .getBalance(),
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
                                  invoice.getAmountPaid(),
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
                          amount:
                              invoice
                                  .getTotalMainRevenueInvoice(),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.Column(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                        right: 10,
                      ),
                      child: pw.SvgImage(
                        svg: pw.Barcode.ean13().toSvg(
                          invoice.barcode ??
                              returnOnlyDigits(
                                invoice.uuid ?? '',
                              ),
                          width: 110,
                          height: 30,
                          fontHeight: 8,
                          drawText: true,
                        ),
                      ),
                    ),
                    pw.Divider(height: 8),
                  ],
                ),
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
                pw.SizedBox(height: 20),
                // pw.Text(
                //   textAlign: pw.TextAlign.center,
                //   style: pw.TextStyle(
                //     fontSize: totalText,
                //     fontWeight: pw.FontWeight.bold,
                //     // color: PdfColor(50, 50, 050),
                //   ),
                //   '------------',
                // ),
                // pw.Builder(
                //   builder: (beansContext) {
                //     if (records.length > 15) {
                //       return pw.Text(
                //         textAlign: pw.TextAlign.center,
                //         style: pw.TextStyle(
                //           fontSize: totalText,
                //           fontWeight: pw.FontWeight.bold,
                //           // color: PdfColor(50, 50, 050),
                //         ),
                //         '------------',
                //       );
                //     } else {
                //       return pw.Container();
                //     }
                //   },
                // ),
                // pw.Builder(
                //   builder: (beansContext) {
                //     if (records.length > 15) {
                //       return pw.Text(
                //         textAlign: pw.TextAlign.center,
                //         style: pw.TextStyle(
                //           fontSize: totalText,
                //           fontWeight: pw.FontWeight.bold,
                //           // color: PdfColor(50, 50, 050),
                //         ),
                //         '------------',
                //       );
                //     } else {
                //       return pw.Container();
                //     }
                //   },
                // ),
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
      // Straight to the POS printer on mobile and desktop; the system
      // print dialog on web (lib/services/pos_printing).
      try {
        await printRollDocument(
          context: context,
          document: invoiceDownloadDocument(
            invoice: invoice,
            records: records,
            receipts: receipts,
            staffName: staffName,
            shop: shop,
            assets: DocShopAssets.current(),
          ),
          format: docFormatFor(shop),
          shopPrintType: printerType,
          rollPdf:
              (type) => _buildPdfRollInvoice(
                invoice: invoice,
                receipts: receipts,
                records: records,
                staffName: staffName,
                shop: shop,
                context: context,
                printerType: type,
              ),
        );
      } catch (e, stackTrace) {
        await mainLocalLog('❌ Error printing invoice: $e\n$stackTrace');
      }
    },
  );
}

// Same roll layout as generateAndPreviewPdfRollInvoice, returned as PDF
// bytes so Bluetooth printing can rasterize it.
Future<Uint8List> buildInvoiceRollPdf({
  required TempInvoice invoice,
  required List<TempMainReceipt> receipts,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) {
  return _buildPdfRollInvoice(
    invoice: invoice,
    receipts: receipts,
    records: records,
    staffName: staffName,
    shop: shop,
    context: context,
    printerType: printerType,
  );
}
