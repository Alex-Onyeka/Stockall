import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/branding_watermark.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stockall/services/documents/document_downloads.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/printing/app_printer_service.dart';
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

  final fontRegular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'),
  );

  final assets = DocShopAssets.current();
  final docShop = docShopFrom(
    shop,
    logo: assets.logo,
    logoIsWide: assets.logoIsWide,
    reference: assets.reference,
  );
  final fmt = docFormatFor(shop);
  final now = DateTime.now();

  final borderColor = PdfColor.fromHex('#E0E4E8');
  final cardBg = PdfColor.fromHex('#F8F9FB');
  final accentColor = PdfColor.fromHex('#1E293B');
  final mutedColor = PdfColor.fromHex('#64748B');

  pw.Widget infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 85,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 9.5,
                color: mutedColor,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 9.5,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget summaryCard({
    required String title,
    required String amountText,
    required String subtitle,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: cardBg,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: borderColor, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 8.5,
                color: mutedColor,
                letterSpacing: 0.6,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              amountText,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 18,
                color: accentColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 8.5,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
      header: (pw.Context pdfContext) => pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (docShop.logo != null) ...[
                      pw.Image(
                        pw.MemoryImage(docShop.logo!),
                        height: docShop.logoIsWide ? 36 : 48,
                        fit: pw.BoxFit.contain,
                      ),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            docShop.name,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 16,
                              color: accentColor,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          for (final line in docShop.contactLines)
                            pw.Text(
                              line,
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 9,
                                color: mutedColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      color: accentColor,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'ACCOUNT BALANCE',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                        color: PdfColors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Date: ${fmt.dateTime(now)}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 9,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Divider(color: borderColor, thickness: 1),
          pw.SizedBox(height: 10),
        ],
      ),
      footer: (pw.Context pdfContext) => pw.Column(
        children: [
          pw.Divider(color: borderColor, thickness: 0.8),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Page ${pdfContext.pageNumber} of ${pdfContext.pagesCount}',
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 8.5,
                  color: mutedColor,
                ),
              ),
              if (shouldShowBrandingWatermark())
                pw.Text(
                  'Created by $appName Solutions (www.stockallapp.com)',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8.5,
                    color: mutedColor,
                  ),
                ),
            ],
          ),
        ],
      ),
      build: (pw.Context pdfContext) => [
        // Customer Details Box
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: cardBg,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: borderColor, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CUSTOMER DETAILS',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 8.5,
                  color: mutedColor,
                  letterSpacing: 0.6,
                ),
              ),
              pw.SizedBox(height: 8),
              infoRow('Name', customer.name),
              if (customer.phone.trim().isNotEmpty)
                infoRow('Phone', customer.phone.trim()),
              if (customer.email.trim().isNotEmpty)
                infoRow('Email', customer.email.trim()),
              if ((customer.address ?? '').trim().isNotEmpty)
                infoRow('Address', customer.address!.trim()),
            ],
          ),
        ),
        pw.SizedBox(height: 18),

        // Account & Reward Balances
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (shop.manageCustomerAccount == true)
              summaryCard(
                title: 'Account Balance',
                amountText: fmt.money(customer.getBalance()),
                subtitle: 'Available customer account balance',
              ),
            if (shop.manageCustomerAccount == true &&
                shop.manageCustomerReward == true)
              pw.SizedBox(width: 14),
            if (shop.manageCustomerReward == true)
              summaryCard(
                title: 'Cashback Balance',
                amountText: fmt.money(customer.cashReward ?? 0),
                subtitle: 'Available loyalty / reward earnings',
              ),
          ],
        ),
        pw.SizedBox(height: 20),

        if ((shop.bottomText ?? '').trim().isNotEmpty)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              shop.bottomText!.trim(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 9,
                color: mutedColor,
              ),
            ),
          ),
      ],
    ),
  );

  return pdf.save();
}

Future<void> printCustomerAccountBalanceA4Pdf({
  required TempCustomersClass customer,
  required BuildContext context,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      final Uint8List pdfBytes = await _buildPdfCustomerAccountBalance(
        customer: customer,
        shop: returnShopProvider().userShop()!,
        context: context,
      );
      await AppPrinterService.printPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Customer_Balance_${customer.name}',
      );
    },
  );
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
        await AppPrinterService.printPdf(
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

      await AppPrinterService.printPdf(
        onLayout: (_) async => pdfBytes,
      );
    },
  );
}
