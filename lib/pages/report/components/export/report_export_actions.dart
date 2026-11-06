// The real export paths, per platform:
//
// | Platform     | Roll print                         | PDF            | Excel          |
// |--------------|------------------------------------|----------------|----------------|
// | Android/iOS  | ESC/POS over Bluetooth             | share sheet    | share sheet    |
// | Windows      | raw ESC/POS to the receipt printer | save (FileSaver) | save (FileSaver) |
// | macOS/Linux  | roll PDF in the system print dialog| save (FileSaver) | save (FileSaver) |
// | Web          | roll PDF in the browser print dialog | download     | download       |

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stockall/constants/functions.dart'
    show savePdfDesktop, savePdfMobile, usesBluetoothPrint;
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart'
    show currentUser, mainLocalLog, returnShopProvider;
import 'package:stockall/pages/report/components/export/report_document_parts.dart';
import 'package:stockall/pages/report/components/export/report_excel_builder.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_bluetooth.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/providers/excel_provider.dart';
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart'
    show listPrinters;
import 'package:stockall/services/receipt_print_service/receipt_import_helper.dart'
    show checkPrint, printerSelectionDialog;
import 'package:universal_html/html.dart' as html;

class DefaultReportExportBackend implements ReportExportBackend {
  const DefaultReportExportBackend();

  static Future<DocFonts>? _fonts;

  /// Plus Jakarta Sans, loaded once. It has the ₦ glyph.
  static Future<DocFonts> fonts() {
    return _fonts ??= () async {
      final regular = await rootBundle.load(
        'assets/fonts/PlusJakartaSans-Regular.ttf',
      );
      final bold = await rootBundle.load(
        'assets/fonts/PlusJakartaSans-Bold.ttf',
      );
      return DocFonts(regular: pw.Font.ttf(regular), bold: pw.Font.ttf(bold));
    }();
  }

  static bool get _isMobile => usesBluetoothPrint();

  static bool get _isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  // ------------------------------------------------------------------
  // Gate and context
  // ------------------------------------------------------------------

  /// Each gate's plan check, called without an action so it shows no
  /// dialog.
  @override
  bool isAllowed(BuildContext context, ReportPrintGate gate) {
    switch (gate) {
      case ReportPrintGate.receiptPrint:
        return SalesAuthAction().printReceiptAction(context: context);
      case ReportPrintGate.itemsReport:
        return ReportAuthAction().printItemsReportAction(context: context);
      case ReportPrintGate.salesReport:
        return ReportAuthAction().printSalesReportAction(context: context);
      case ReportPrintGate.customersReport:
        return ReportAuthAction().printCustomerReportAction(context: context);
      case ReportPrintGate.employeesReport:
        return ReportAuthAction().printEmployeesReportAction(
          context: context,
        );
      case ReportPrintGate.expensesReport:
        return ReportAuthAction().printExpensesReportAction(
          context: context,
        );
      case ReportPrintGate.generalReport:
        return ReportAuthAction().printGeneralReportAction(context: context);
    }
  }

  @override
  ExportContext exportContext() {
    final shop = returnShopProvider().userShop();
    String clean(String? v) => (v ?? '').trim();

    final details = <String>[];
    if (shop != null) {
      if (shop.showAddress != false) {
        final address = [
          clean(shop.shopAddress),
          clean(shop.city),
          clean(shop.state),
        ].where((p) => p.isNotEmpty).join(', ');
        if (address.isNotEmpty) details.add(address);
      }
      if (shop.showPhone != false && clean(shop.phoneNumber).isNotEmpty) {
        details.add(clean(shop.phoneNumber));
      }
      if (shop.showEmail != false && clean(shop.email).isNotEmpty) {
        details.add(clean(shop.email));
      }
    }

    final user = clean(currentUser().name);
    return ExportContext(
      shopName: clean(shop?.name),
      currencySymbol: shop?.currency ?? '',
      generatedBy: user.isEmpty ? 'Unknown' : user,
      generatedAt: DateTime.now(),
      shopDetails: details,
    );
  }

  /// Same settings the receipt and Items roll prints read:
  /// the chosen receipt printer's size, else the shop's print type
  /// (1 = 58mm, 2 = 80mm).
  @override
  RollPaper? savedPaper() {
    try {
      final shop = returnShopProvider();
      final size =
          shop.getReceiptPrinter()?.printerSize ?? shop.userShop()?.printType;
      if (size == 1) return RollPaper.mm58;
      if (size == 2) return RollPaper.mm80;
    } catch (_) {}
    return null;
  }

  @override
  void logError(String action, Object error, StackTrace stack) {
    mainLocalLog('Report export ($action) failed: $error\n$stack');
  }

  // ------------------------------------------------------------------
  // Roll print
  // ------------------------------------------------------------------

  @override
  Future<void> printRoll(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required RollPaper paper,
    required List<String?> groupings,
    required VoidCallback beforeUi,
  }) async {
    final lines = buildRollLines(
      spec,
      ctx,
      paper: paper,
      groupings: groupings,
    );

    if (!kIsWeb && _isMobile) {
      final chunks = buildRollEscPos(lines, paper);
      if (!context.mounted) return;
      await reportPrintBluetooth(context, chunks, beforeUi: beforeUi);
      return;
    }

    if (_isWindows) {
      await _printWindows(context, buildRollEscPos(lines, paper), beforeUi);
      return;
    }

    // macOS, Linux and web: the system print dialog with a roll-sized PDF.
    final bytes = await buildRollPdf(lines, paper, fonts: await fonts());
    beforeUi();
    await Printing.layoutPdf(
      name: reportExportBaseName(spec, now: ctx.generatedAt),
      format: paper.pdfFormat,
      dynamicLayout: false,
      onLayout: (_) async => bytes,
    );
  }

  // Same condition checkPrint uses to decide whether a printer is set.
  static bool _windowsPrinterReady() {
    final shop = returnShopProvider();
    final printer = shop.getReceiptPrinter();
    final size = printer?.printerSize;
    return (size == 1 || size == 2) &&
        shop.printers.any((p) => p.name == printer?.printerName);
  }

  Future<void> _printWindows(
    BuildContext context,
    List<Uint8List> chunks,
    VoidCallback beforeUi,
  ) async {
    try {
      listPrinters();
    } catch (_) {}

    if (!_windowsPrinterReady()) {
      beforeUi();
      if (!context.mounted) return;
      await printerSelectionDialog(
        context: context,
        title: 'Receipt Printer & Paper Size',
        message:
            'Select your receipt printer and paper size to print this report.',
      );
      // Closed without choosing a printer: nothing to print.
      if (!_windowsPrinterReady()) return;
    }

    if (!context.mounted) return;
    final bytes = Uint8List.fromList([for (final c in chunks) ...c]);
    final sent = await checkPrint(context: context, receiptBytes: bytes);
    if (!sent) {
      throw const ReportExportException(
        "Couldn't reach the printer. Check that it is on and connected.",
      );
    }
  }

  // ------------------------------------------------------------------
  // PDF and Excel
  // ------------------------------------------------------------------

  @override
  Future<ReportSaveResult> downloadPdf(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async {
    final bytes = await buildReportPdf(
      resolveExport(spec, ctx),
      fonts: await fonts(),
    );
    final base = reportExportBaseName(spec, now: ctx.generatedAt);
    final fileName = '$base.pdf';

    if (kIsWeb) {
      _downloadWeb(bytes, fileName, 'application/pdf');
      return ReportSaveResult(fileName: fileName, showSaved: true);
    }
    beforeUi();
    if (_isMobile) {
      await savePdfMobile(bytes, base);
      return ReportSaveResult(fileName: fileName, showSaved: false);
    }
    await savePdfDesktop(bytes, base);
    return ReportSaveResult(fileName: fileName, showSaved: true);
  }

  @override
  Future<ReportSaveResult> exportExcel(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    String? splitId,
    required VoidCallback beforeUi,
  }) async {
    final bytes = buildReportWorkbook(
      resolveWorkbook(spec, ctx, splitId: splitId),
    );
    final base = reportExportBaseName(spec, now: ctx.generatedAt);
    beforeUi();
    final saved = await ExcelProvider().save(
      bytes: bytes,
      name: base,
      addSuffix: false,
    );
    if (!saved) {
      throw const ReportExportException(
        "Couldn't save the Excel file. Please try again.",
      );
    }
    return ReportSaveResult(
      fileName: '$base.xlsx',
      showSaved: kIsWeb || !_isMobile,
    );
  }

  static void _downloadWeb(Uint8List bytes, String fileName, String mime) {
    final blob = html.Blob([bytes], mime);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
