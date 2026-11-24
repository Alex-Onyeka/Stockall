import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart';
import 'package:stockall/main.dart' show mainLocalLog;
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/services/pos_printing/pos_print_dispatcher.dart'
    show askAfterPrintFailure;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_transports.dart'
    show currentPosPlatform;
import 'package:stockall/services/pos_printing/printer_settings_panel.dart';

// Prints an A4 document on the A4 printer saved in Printer Settings.
//
// Desktop and iOS: straight to the saved printer, without a dialog. With
// none saved, Printer Settings opens on its A4 section; closing it without
// choosing one prints through the system dialog instead. If printing
// fails: Retry, Change printer, or Use system print.
// Android and web: the system print dialog (they can't print to a chosen
// printer).
//
// beforeUi runs before any dialog opens (to close a loading overlay).
Future<void> printA4Pdf(
  BuildContext context, {
  required Future<Uint8List> Function() buildPdf,
  String name = 'Document',
  VoidCallback? beforeUi,
}) async {
  final platform = currentPosPlatform();
  final settings = PrinterSettingsProvider();
  await settings.ensureLoaded();

  Future<void> toSystemDialog() async {
    final bytes = await buildPdf();
    beforeUi?.call();
    await Printing.layoutPdf(
      name: name,
      format: PdfPageFormat.a4,
      onLayout: (_) async => bytes,
    );
  }

  var choosePrinter = false;
  while (true) {
    final route =
        choosePrinter
            ? const A4SetupRoute()
            : chooseA4Route(platform, settings.a4Printer);
    switch (route) {
      case A4SystemPrintRoute():
        await toSystemDialog();
        return;

      case A4SetupRoute():
        beforeUi?.call();
        if (!context.mounted) return;
        await openPrinterSettings(context, focus: PrinterSettingsFocus.a4);
        if (settings.a4Printer == null) {
          await toSystemDialog();
          return;
        }
        choosePrinter = false;
        continue; // Print on it straight away.

      case A4DirectRoute(printer: final saved):
        try {
          final bytes = await buildPdf();
          final printed = await Printing.directPrintPdf(
            printer: Printer(url: saved.url, name: saved.name),
            name: name,
            format: PdfPageFormat.a4,
            onLayout: (_) async => bytes,
          );
          if (!printed) {
            throw Exception('${saved.name} did not accept the document.');
          }
          return;
        } catch (e, stackTrace) {
          await mainLocalLog('A4 print failed on $saved: $e\n$stackTrace');
          beforeUi?.call();
          if (!context.mounted) return;
          final choice = await askAfterPrintFailure(
            context,
            printerName: saved.name,
            error: e,
            choices: PosFailureChoice.values,
          );
          switch (choice) {
            case PosFailureChoice.retry:
              continue;
            case PosFailureChoice.changePrinter:
              choosePrinter = true;
              continue;
            case PosFailureChoice.systemPrint:
              await toSystemDialog();
              return;
            case null:
              return;
          }
        }
    }
  }
}
