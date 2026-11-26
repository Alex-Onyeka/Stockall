import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/functions.dart'
    show savePdfDesktop, savePdfMobile;
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/documents/document_downloads.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/pos_printing/pos_print_dispatcher.dart';
import 'package:stockall/services/printing/app_printer_service.dart';

SalesDocument expenseDownloadDocument({
  required TempExpensesClass expense,
  required TempShopClass shop,
  required DocShopAssets assets,
}) {
  final fmt = docFormatFor(shop);
  final docShop = docShopFrom(
    shop,
    logo: assets.logo,
    logoIsWide: assets.logoIsWide,
    reference: assets.reference,
  );
  final subs = expense.subExpenses ?? const [];
  final lines = <DocLine>[
    if (subs.isNotEmpty)
      for (final sub in subs)
        DocLine(
          name: sub.name,
          quantity: sub.quantity ?? 1,
          unit: sub.unit ?? '',
          unitPrice:
              (sub.quantity != null && sub.quantity! > 0)
                  ? sub.amount / sub.quantity!
                  : sub.amount,
          amount: sub.amount,
          notes: [
            if (sub.description != null && sub.description!.trim().isNotEmpty)
              sub.description!.trim(),
            if (sub.paymentChannel.trim().isNotEmpty) sub.paymentChannel.trim(),
          ],
        )
    else
      DocLine(
        name: expense.name,
        quantity: expense.quantity ?? 1,
        unit: expense.unit ?? '',
        unitPrice:
            (expense.quantity != null && expense.quantity! > 0)
                ? expense.amount / expense.quantity!
                : expense.amount,
        amount: expense.amount,
        notes: [
          if (expense.description != null &&
              expense.description!.trim().isNotEmpty)
            expense.description!.trim(),
        ],
      ),
  ];

  final entries = expense.paymentEntries ?? const [];
  final payments = <DocPayment>[
    if (entries.isNotEmpty)
      for (final entry in entries)
        DocPayment(method: entry.method, amount: entry.amount)
    else if (expense.paymentChannel != null &&
        expense.paymentChannel!.trim().isNotEmpty)
      DocPayment(method: expense.paymentChannel!.trim(), amount: expense.amount),
  ];

  final id = expense.uuid ?? '';
  final number = id.length > 8 ? id.substring(0, 8).toUpperCase() : id;

  final expenseDate = expense.createdDate ?? DateTime.now();

  final info = <DocField>[
    if (number.isNotEmpty) DocField('Expense No', number),
    DocField('Category', expense.categoryLabel),
    DocField('Date', fmt.dateTime(expenseDate)),
    if ((expense.creator ?? expense.userName ?? '').trim().isNotEmpty)
      DocField('Recorded By', (expense.creator ?? expense.userName!).trim()),
    if ((expense.staffName ?? '').trim().isNotEmpty)
      DocField('Staff', expense.staffName!.trim()),
    if ((expense.departmentName ?? '').trim().isNotEmpty)
      DocField('Department', expense.departmentName!.trim()),
  ];

  return SalesDocument(
    type: DocType.purchase,
    title: 'EXPENSE',
    number: number,
    date: expenseDate,
    shop: docShop,
    info: info,
    lines: lines,
    totals: DocTotals(
      subtotal: expense.amount,
      itemDiscounts: 0,
      discount: 0,
      discountLabel: 'Discount',
      vatRate: null,
      vat: 0,
      total: expense.amount,
    ),
    payments: payments,
    notes:
        (expense.description != null && expense.description!.trim().isNotEmpty)
            ? expense.description!.trim()
            : null,
    footerText:
        (shop.bottomText != null && shop.bottomText!.trim().isNotEmpty)
            ? shop.bottomText!.trim()
            : null,
  );
}

Future<Uint8List> _buildPdfExpense(TempExpensesClass expense) {
  final shop = returnShopProvider().userShop()!;
  return salesDocumentA4Pdf(
    expenseDownloadDocument(
      expense: expense,
      shop: shop,
      assets: DocShopAssets.current(),
    ),
    shop,
  );
}

Future<bool> printExpenseA4Pdf({
  required TempExpensesClass expense,
  required BuildContext context,
}) async {
  try {
    final bytes = await _buildPdfExpense(expense);
    return await AppPrinterService.printPdf(
      onLayout: (_) async => bytes,
      name: 'Expense_${expense.uuid ?? ''}',
    );
  } catch (e, stackTrace) {
    await mainLocalLog('❌ Error printing A4 expense PDF: $e\n$stackTrace');
    return false;
  }
}

Future<bool> generateAndPreviewPdfExpense({
  required TempExpensesClass expense,
}) async {
  try {
    final bytes = await _buildPdfExpense(expense);
    final id = expense.uuid ?? '';
    final short = id.length > 5 ? id.substring(0, 5) : id;
    final name = 'downloaded_expense_$short.${DateTime.now().millisecondsSinceEpoch}';
    if (Platform.isAndroid || Platform.isIOS) {
      await savePdfMobile(bytes, name);
    } else {
      await savePdfDesktop(bytes, name);
    }
    return true;
  } catch (e, stackTrace) {
    await mainLocalLog('❌ Error downloading expense PDF: $e\n$stackTrace');
    return false;
  }
}

Future<bool> downloadPdfWebExpense({
  required TempExpensesClass expense,
}) async {
  try {
    final bytes = await _buildPdfExpense(expense);
    downloadPdfBytesWeb(
      bytes,
      'downloaded_expense_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    return true;
  } catch (e, stackTrace) {
    await mainLocalLog('❌ Error downloading web expense PDF: $e\n$stackTrace');
    return false;
  }
}

Future<Uint8List> _buildPdfRollExpense({
  required TempExpensesClass expense,
  required TempShopClass shop,
  required int printerType,
}) async {
  final double headingText = printerType == 1 ? 12 : 14;
  final double parText = printerType == 1 ? 7 : 9;
  final double parTextAlt = printerType == 1 ? 5 : 7;
  final double totalText = printerType == 1 ? 8 : 10;
  final pdf = pw.Document();

  final fontRegular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'),
  );

  pw.Widget infoCell(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: parTextAlt,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            value,
            style: pw.TextStyle(font: fontBold, fontSize: parText),
          ),
        ],
      ),
    );
  }

  final doc = expenseDownloadDocument(
    expense: expense,
    shop: shop,
    assets: DocShopAssets.current(),
  );

  final subs = expense.subExpenses ?? const [];

  pdf.addPage(
    pw.Page(
      pageFormat: printerType == 1 ? PdfPageFormat.roll57 : PdfPageFormat.roll80,
      margin: pw.EdgeInsets.symmetric(
        horizontal: printerType == 1 ? 6 : 8,
        vertical: 10,
      ),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (returnShopProvider().selectedLogo != null)
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(returnShopProvider().selectedLogo!),
                  height: 36,
                  fit: pw.BoxFit.contain,
                ),
              ),
            pw.SizedBox(height: 4),
            pw.Text(
              shop.name,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: fontBold, fontSize: headingText),
            ),
            for (final line in doc.shop.contactLines)
              pw.Text(
                line,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: fontRegular, fontSize: parTextAlt),
              ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 0.6),
                  bottom: pw.BorderSide(width: 0.6),
                ),
              ),
              child: pw.Text(
                'EXPENSE',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: fontBold, fontSize: totalText),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                infoCell('Title', expense.name),
                infoCell('Category', expense.categoryLabel),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                infoCell(
                  'Date',
                  docFormatFor(shop).dateTime(
                    expense.createdDate ?? DateTime.now(),
                  ),
                ),
                infoCell(
                  'Recorded By',
                  (expense.creator ?? expense.userName ?? 'N/A').trim(),
                ),
              ],
            ),
            if ((expense.departmentName ?? '').trim().isNotEmpty ||
                (expense.staffName ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  if ((expense.departmentName ?? '').trim().isNotEmpty)
                    infoCell('Department', expense.departmentName!.trim()),
                  if ((expense.staffName ?? '').trim().isNotEmpty)
                    infoCell('Staff', expense.staffName!.trim()),
                ],
              ),
            ],
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.6, height: 6),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Item',
                    style: pw.TextStyle(font: fontBold, fontSize: parText),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Qty',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: fontBold, fontSize: parText),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Amount',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: fontBold, fontSize: parText),
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 0.6, height: 6),
            if (subs.isNotEmpty)
              for (final sub in subs) ...[
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              sub.name,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: parText,
                              ),
                            ),
                            pw.Text(
                              sub.paymentChannel,
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: parTextAlt,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${sub.quantity ?? 1}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: parText,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          docFormatFor(shop).money(sub.amount),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: parText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            else
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        expense.name,
                        style: pw.TextStyle(font: fontBold, fontSize: parText),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '${expense.quantity ?? 1}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parText,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        docFormatFor(shop).money(expense.amount),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: fontBold, fontSize: parText),
                      ),
                    ),
                  ],
                ),
              ),
            pw.Divider(thickness: 0.6, height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(font: fontBold, fontSize: totalText),
                ),
                pw.Text(
                  docFormatFor(shop).money(expense.amount),
                  style: pw.TextStyle(font: fontBold, fontSize: totalText),
                ),
              ],
            ),
            if (doc.payments.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              for (final p in doc.payments)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      p.method,
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: parTextAlt,
                      ),
                    ),
                    pw.Text(
                      docFormatFor(shop).money(p.amount),
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: parTextAlt,
                      ),
                    ),
                  ],
                ),
            ],
            if ((expense.description ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                'Note: ${expense.description!.trim()}',
                style: pw.TextStyle(font: fontRegular, fontSize: parTextAlt),
              ),
            ],
            if ((shop.bottomText ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                shop.bottomText!.trim(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: fontRegular, fontSize: parTextAlt),
              ),
            ],
          ],
        );
      },
    ),
  );

  return pdf.save();
}

Future<void> generateAndPreviewPdfRollExpense({
  required TempExpensesClass expense,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        await printRollDocument(
          context: context,
          document: expenseDownloadDocument(
            expense: expense,
            shop: shop,
            assets: DocShopAssets.current(),
          ),
          format: docFormatFor(shop),
          shopPrintType: printerType,
          rollPdf:
              (type) => _buildPdfRollExpense(
                expense: expense,
                shop: shop,
                printerType: type,
              ),
        );
      } catch (e, stackTrace) {
        await mainLocalLog('❌ Error printing expense: $e\n$stackTrace');
      }
    },
  );
}
