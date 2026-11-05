import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:stockall/main.dart' show mainLocalLog, returnShopProvider;
import 'package:stockall/providers/pos_printer/device_service.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/navigation_service.dart' show navigatorKey;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_setup_dialog.dart';
import 'package:stockall/services/pos_printing/pos_printer_store.dart';
import 'package:stockall/services/pos_printing/pos_transports.dart';
import 'package:stockall/services/pos_printing/roll_document_escpos.dart';

// Prints a document on the roll printer.
//
// Web: the browser print dialog with the roll PDF (browsers can't reach
// printers directly).
// Native: straight to the printer saved on this device (Bluetooth,
// network, Windows spooler or CUPS). With none saved, the user picks one
// and it prints right away. If sending fails: Retry, Change printer, or
// Use system print (the roll PDF in the system dialog).
//
// rollPdf builds the roll PDF for a printType (1 = 58mm, 2 = 80mm), for
// web and the system print fallback.
Future<void> printRollDocument({
  required BuildContext context,
  required SalesDocument document,
  required DocFormat format,
  required Future<Uint8List> Function(int printerType) rollPdf,
  int? shopPrintType,
}) async {
  final platform = currentPosPlatform();
  if (platform == PosPlatform.web) {
    await _systemPrint(rollPdf, paperFromPrinterType(shopPrintType));
    return;
  }

  var printer = await PosPrinterStore.load();
  if (printer == null) {
    final windowsPrinter =
        platform == PosPlatform.windows
            ? returnShopProvider().getReceiptPrinter()
            : null;
    printer = seedPosPrinter(
      platform: platform,
      windowsPrinterName: windowsPrinter?.printerName,
      windowsPaperSize: windowsPrinter?.printerSize,
      shopPrintType: shopPrintType,
    );
    if (printer != null) await PosPrinterStore.save(printer);
  }

  var choosePrinter = false;
  while (true) {
    final route =
        choosePrinter ? const PosSetupRoute() : choosePosRoute(platform, printer);
    switch (route) {
      case PosSystemPrintRoute():
        await _systemPrint(rollPdf, initialPaper(printer, shopPrintType));
        return;

      case PosSetupRoute():
        if (!context.mounted) return;
        final picked = await showPosPrinterSetup(
          context,
          platform: platform,
          paper: initialPaper(printer, shopPrintType),
          current: printer,
        );
        if (picked == null) return;
        final change = printerAfterSetup(printer, picked);
        if (change.save) await PosPrinterStore.save(picked);
        printer = change.printer;
        choosePrinter = false;
        continue; // Print on it straight away.

      case PosDirectRoute(printer: final target):
        try {
          final chunks =
              buildRollEscPos(
                document,
                format,
                paper: target.paper,
                logo: rollLogoBands(document.shop.logo, target.paper),
                cut: target.cut,
                feedLines: DeviceService.isPos ? 5 : 4,
              ).build();
          await sendToPosPrinter(target, chunks);
          return;
        } catch (e, stackTrace) {
          await mainLocalLog('POS print failed on $target: $e\n$stackTrace');
          if (!context.mounted) return;
          final choice = await _askAfterFailure(
            context,
            target,
            e,
            failureChoices(platform),
          );
          switch (choice) {
            case PosFailureChoice.retry:
              continue;
            case PosFailureChoice.changePrinter:
              choosePrinter = true;
              continue;
            case PosFailureChoice.systemPrint:
              await _systemPrint(rollPdf, target.paper);
              return;
            case null:
              return;
          }
        }
    }
  }
}

// Change the saved printer, paper size or cut without printing. Returns
// the printer now saved (unchanged when the user cancels).
Future<PosPrinterConfig?> changePosPrinter(
  BuildContext context, {
  int? shopPrintType,
}) async {
  final platform = currentPosPlatform();
  if (platform == PosPlatform.web) return null;
  final current = await PosPrinterStore.load();
  if (!context.mounted) return current;
  final picked = await showPosPrinterSetup(
    context,
    platform: platform,
    paper: initialPaper(current, shopPrintType),
    current: current,
  );
  final change = printerAfterSetup(current, picked);
  if (change.save) await PosPrinterStore.save(change.printer!);
  return change.printer;
}

// The settings entry (Edit Receipt Template menu, mobile and desktop).
// Uses the app navigator, because the menu that calls it is gone by the
// time the dialog opens.
Future<void> openPosPrinterSettings() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  final before = await PosPrinterStore.load();
  if (!context.mounted) return;
  final after = await changePosPrinter(
    context,
    shopPrintType: returnShopProvider().userShop()?.printType,
  );
  if (after == null || after == before || !context.mounted) return;
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      content: Text('POS printer saved: ${after.name} (${after.paper.label})'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> _systemPrint(
  Future<Uint8List> Function(int printerType) rollPdf,
  PosPaper paper,
) async {
  final bytes = await rollPdf(paper.printerType);
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}

Future<PosFailureChoice?> _askAfterFailure(
  BuildContext context,
  PosPrinterConfig printer,
  Object error,
  List<PosFailureChoice> choices,
) {
  final message =
      error is PosSendException
          ? error.message
          : 'Could not print to ${printer.name}.';
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
