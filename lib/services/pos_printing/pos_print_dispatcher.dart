import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:stockall/main.dart' show mainLocalLog;
import 'package:stockall/providers/pos_printer/device_service.dart';
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/navigation_service.dart' show navigatorKey;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_setup_dialog.dart';
import 'package:stockall/services/pos_printing/pos_transports.dart';
import 'package:stockall/services/pos_printing/printer_settings_panel.dart';
import 'package:stockall/services/pos_printing/roll_document_escpos.dart';
import 'package:stockall/services/printing/pdf_escpos_raster.dart'
    show pdfToEscPosRaster;

// Prints on the roll printer saved in Printer Settings, with the roll
// options in force (width, cut).
//
// Web: the browser print dialog with the roll PDF (browsers can't reach
// printers directly).
// Native: straight to the saved roll printer (Bluetooth, network, Windows
// spooler or CUPS). With none saved, the user picks one and it prints
// right away. If sending fails: Retry, Change printer, or Use system
// print (the roll PDF in the system dialog).
//
// escPos builds the bytes for the printer it goes to (its paper and
// cut). rollPdf builds the roll PDF for a printType (1 = 58mm, 2 = 80mm),
// for web and the system print fallback; systemPrint replaces the plain
// system dialog when given. beforeUi runs before any dialog opens (to
// close a loading overlay). shopPrintType is the shop's default width,
// used while this device has none of its own.
Future<void> printRoll({
  required BuildContext context,
  required FutureOr<List<Uint8List>> Function(PosPrinterConfig target) escPos,
  required Future<Uint8List> Function(int printerType) rollPdf,
  Future<void> Function(PosPaper paper)? systemPrint,
  VoidCallback? beforeUi,
  int? shopPrintType,
}) async {
  final platform = currentPosPlatform();
  final settings = PrinterSettingsProvider();
  await seedRollPrinterIfNeeded(platform);
  RollOptions options() => settings.rollOptions(shopPrintType: shopPrintType);

  Future<void> toSystemDialog(PosPaper paper) async {
    beforeUi?.call();
    if (systemPrint != null) {
      await systemPrint(paper);
    } else {
      await _systemPrint(rollPdf, paper);
    }
  }

  if (platform == PosPlatform.web) {
    await toSystemDialog(options().paper);
    return;
  }

  var choosePrinter = false;
  while (true) {
    final printer = settings.rollPrinter;
    final route =
        choosePrinter ? const PosSetupRoute() : choosePosRoute(platform, printer);
    switch (route) {
      case PosSystemPrintRoute():
        await toSystemDialog(options().paper);
        return;

      case PosSetupRoute():
        beforeUi?.call();
        if (!context.mounted) return;
        final current = options();
        final picked = await showPosPrinterSetup(
          context,
          platform: platform,
          paper: current.paper,
          cut: current.cut,
          current: printer,
        );
        if (picked == null) return;
        await settings.setRollOptions(
          current.copyWith(paper: picked.paper, cut: picked.cut),
        );
        await settings.setRollPrinter(picked, shopPrintType: shopPrintType);
        choosePrinter = false;
        continue; // Print on it straight away.

      case PosDirectRoute(printer: final saved):
        final target = printerWithOptions(saved, options());
        try {
          final chunks = await escPos(target);
          await sendToPosPrinter(target, chunks);
          return;
        } catch (e, stackTrace) {
          await mainLocalLog('POS print failed on $target: $e\n$stackTrace');
          beforeUi?.call();
          if (!context.mounted) return;
          final choice = await askAfterPrintFailure(
            context,
            printerName: target.name,
            error: e,
            choices: failureChoices(platform),
          );
          switch (choice) {
            case PosFailureChoice.retry:
              continue;
            case PosFailureChoice.changePrinter:
              choosePrinter = true;
              continue;
            case PosFailureChoice.systemPrint:
              await toSystemDialog(target.paper);
              return;
            case null:
              return;
          }
        }
    }
  }
}

// A receipt, invoice, order or purchase on the roll printer, as ESC/POS
// text (lib/services/pos_printing/roll_document_escpos.dart).
Future<void> printRollDocument({
  required BuildContext context,
  required SalesDocument document,
  required DocFormat format,
  required Future<Uint8List> Function(int printerType) rollPdf,
  int? shopPrintType,
}) {
  return printRoll(
    context: context,
    shopPrintType: shopPrintType,
    rollPdf: rollPdf,
    escPos:
        (target) =>
            buildRollEscPos(
              document,
              format,
              paper: target.paper,
              logo: rollLogoBands(document.shop.logo, target.paper),
              cut: target.cut,
              feedLines: DeviceService.isPos ? 5 : 4,
            ).build(),
  );
}

// A roll that only exists as a PDF (purchase payment, customer balance)
// on the roll printer: the PDF at the printer's width, printed as an
// image, then cut if the roll options say so.
Future<void> printRollPdf({
  required BuildContext context,
  required Future<Uint8List> Function(int printerType) rollPdf,
  int? shopPrintType,
}) {
  return printRoll(
    context: context,
    shopPrintType: shopPrintType,
    rollPdf: rollPdf,
    escPos: (target) async {
      final type = target.paper.printerType;
      final chunks = await pdfToEscPosRaster(
        await rollPdf(type),
        printerType: type,
      );
      return withCut(chunks, cut: target.cut);
    },
  );
}

// Change the saved roll printer, paper size or cut without printing.
// Returns the printer now saved (unchanged when the user cancels).
Future<PosPrinterConfig?> changePosPrinter(
  BuildContext context, {
  int? shopPrintType,
}) async {
  final platform = currentPosPlatform();
  if (platform == PosPlatform.web) return null;
  final settings = PrinterSettingsProvider();
  await settings.ensureLoaded();
  final current = settings.rollPrinter;
  final options = settings.rollOptions(shopPrintType: shopPrintType);
  if (!context.mounted) return current;
  final picked = await showPosPrinterSetup(
    context,
    platform: platform,
    paper: options.paper,
    cut: options.cut,
    current: current,
  );
  final change = printerAfterSetup(current, picked);
  if (change.save) {
    await settings.setRollOptions(
      options.copyWith(paper: picked!.paper, cut: picked.cut),
    );
    await settings.setRollPrinter(picked, shopPrintType: shopPrintType);
  }
  return settings.rollPrinter;
}

// The settings entry from menus: the Printer Settings panel. Uses the app
// navigator, because the menu that calls it is gone by the time the panel
// opens.
Future<void> openPosPrinterSettings() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  await openPrinterSettings(context);
}

Future<void> _systemPrint(
  Future<Uint8List> Function(int printerType) rollPdf,
  PosPaper paper,
) async {
  final bytes = await rollPdf(paper.printerType);
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}

// After a direct print fails: Retry, Change printer or Use system print.
// Null when the user cancels.
Future<PosFailureChoice?> askAfterPrintFailure(
  BuildContext context, {
  required String printerName,
  required Object error,
  required List<PosFailureChoice> choices,
}) {
  final message =
      error is PosSendException
          ? error.message
          : 'Could not print to $printerName.';
  String label(PosFailureChoice choice) => switch (choice) {
    PosFailureChoice.retry => 'Retry',
    PosFailureChoice.changePrinter => 'Change printer',
    PosFailureChoice.systemPrint => 'Use system print',
  };
  return showDialog<PosFailureChoice>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Printer not reachable',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            for (final choice in choices)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(choice),
                child: Text(label(choice)),
              ),
          ],
        ),
  );
}
