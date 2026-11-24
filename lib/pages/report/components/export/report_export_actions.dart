// The real export paths, per platform:
//
// | Platform     | Roll print                               | Print A4                      | PDF / Excel      |
// |--------------|------------------------------------------|-------------------------------|------------------|
// | Android/iOS  | the roll printer in Printer Settings     | system dialog (iOS: the saved | share sheet      |
// |              | (Bluetooth or network)                   | AirPrint printer)             |                  |
// | Windows      | the roll printer (spooler or network)    | the saved A4 printer          | save (FileSaver) |
// | macOS/Linux  | the roll printer (CUPS or network)       | the saved A4 printer          | save (FileSaver) |
// | Web          | roll PDF in the browser print dialog     | browser print dialog          | download         |
//
// Roll prints use the width and cut from Printer Settings
// (lib/services/pos_printing).

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
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/providers/excel_provider.dart';
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/services/pos_printing/a4_print_dispatcher.dart';
import 'package:stockall/services/pos_printing/pos_print_dispatcher.dart'
    as pos
    show printRoll;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/printer_settings_panel.dart'
    show shopDefaultPrintType;
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

  /// The roll width in Printer Settings, else the shop's default
  /// (1 = 58mm, 2 = 80mm).
  @override
  RollPaper? savedPaper() {
    try {
      final paper =
          PrinterSettingsProvider()
              .rollOptions(shopPrintType: shopDefaultPrintType())
              .paper;
      return _rollPaper(paper);
    } catch (_) {}
    return null;
  }

  static RollPaper _rollPaper(PosPaper paper) =>
      paper == PosPaper.mm80 ? RollPaper.mm80 : RollPaper.mm58;

  @override
  void logError(String action, Object error, StackTrace stack) {
    mainLocalLog('Report export ($action) failed: $error\n$stack');
  }

  // ------------------------------------------------------------------
  // Roll print
  // ------------------------------------------------------------------

  /// On the roll printer from Printer Settings, laid out for the width it
  /// prints at; the roll PDF in the system dialog on web and as the
  /// fallback.
  @override
  Future<void> printRoll(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required RollPaper paper,
    required List<String?> groupings,
    required VoidCallback beforeUi,
  }) async {
    List<RollLine> lines(RollPaper p) =>
        buildRollLines(spec, ctx, paper: p, groupings: groupings);
    RollPaper fromType(int type) =>
        type == 2 ? RollPaper.mm80 : RollPaper.mm58;

    await pos.printRoll(
      context: context,
      shopPrintType: paper == RollPaper.mm80 ? 2 : 1,
      beforeUi: beforeUi,
      escPos: (target) {
        final p = _rollPaper(target.paper);
        return buildRollEscPos(lines(p), p, cut: target.cut);
      },
      rollPdf:
          (type) async => buildRollPdf(
            lines(fromType(type)),
            fromType(type),
            fonts: await fonts(),
          ),
      systemPrint: (posPaper) async {
        final p = _rollPaper(posPaper);
        final bytes = await buildRollPdf(lines(p), p, fonts: await fonts());
        beforeUi();
        await Printing.layoutPdf(
          name: reportExportBaseName(spec, now: ctx.generatedAt),
          format: p.pdfFormat,
          dynamicLayout: false,
          onLayout: (_) async => bytes,
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // Print A4
  // ------------------------------------------------------------------

  @override
  Future<void> printA4(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async {
    await printA4Pdf(
      context,
      name: reportExportBaseName(spec, now: ctx.generatedAt),
      beforeUi: beforeUi,
      buildPdf:
          () async =>
              buildReportPdf(resolveExport(spec, ctx), fonts: await fonts()),
    );
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
