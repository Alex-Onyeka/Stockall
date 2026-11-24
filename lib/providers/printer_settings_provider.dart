import 'package:flutter/foundation.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_store.dart';

// The printer settings saved on this device (PosPrinterStore): the roll
// printer, the roll options and the A4 printer. Not synced: printers
// belong to the machine, not the shop.
class PrinterSettingsProvider extends ChangeNotifier {
  static final PrinterSettingsProvider _instance =
      PrinterSettingsProvider._internal();

  factory PrinterSettingsProvider() => _instance;

  PrinterSettingsProvider._internal();

  PosPrinterConfig? _rollPrinter;
  RollOptions? _savedRollOptions;
  A4PrinterConfig? _a4Printer;
  bool _loaded = false;

  PosPrinterConfig? get rollPrinter => _rollPrinter;
  A4PrinterConfig? get a4Printer => _a4Printer;
  bool get loaded => _loaded;

  // The roll options in force. shopPrintType is the shop's default width,
  // used while this device has none of its own.
  RollOptions rollOptions({int? shopPrintType}) => effectiveRollOptions(
    saved: _savedRollOptions,
    printer: _rollPrinter,
    shopPrintType: shopPrintType,
  );

  // Whether a roll width is set anywhere: on this device (roll options,
  // or the paper kept with the roll printer) or as the shop's default.
  bool hasRollWidth({int? shopPrintType}) =>
      _savedRollOptions != null ||
      _rollPrinter != null ||
      shopPrintType != null;

  // Reads the saved settings again.
  Future<void> load() async {
    _rollPrinter = await PosPrinterStore.load();
    _savedRollOptions = await PosPrinterStore.loadRollOptions();
    _a4Printer = await PosPrinterStore.loadA4();
    _loaded = true;
    notifyListeners();
  }

  // Loads once; later calls return at once.
  Future<void> ensureLoaded() async {
    if (!_loaded) await load();
  }

  // The printer keeps the roll options in force, so saves read by older
  // code (the printer's own paper and cut) agree with them.
  Future<void> setRollPrinter(
    PosPrinterConfig printer, {
    int? shopPrintType,
  }) async {
    final saved = printerWithOptions(
      printer,
      rollOptions(shopPrintType: shopPrintType),
    );
    await PosPrinterStore.save(saved);
    _rollPrinter = saved;
    notifyListeners();
  }

  Future<void> clearRollPrinter() async {
    await PosPrinterStore.clear();
    _rollPrinter = null;
    notifyListeners();
  }

  Future<void> setRollOptions(RollOptions options) async {
    await PosPrinterStore.saveRollOptions(options);
    _savedRollOptions = options;
    final printer = _rollPrinter;
    if (printer != null) {
      final updated = printerWithOptions(printer, options);
      if (updated != printer) {
        await PosPrinterStore.save(updated);
        _rollPrinter = updated;
      }
    }
    notifyListeners();
  }

  Future<void> setA4Printer(A4PrinterConfig? printer) async {
    if (printer == null) {
      await PosPrinterStore.clearA4();
    } else {
      await PosPrinterStore.saveA4(printer);
    }
    _a4Printer = printer;
    notifyListeners();
  }
}
