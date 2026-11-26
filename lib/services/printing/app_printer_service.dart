import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:stockall/classes/receipt_printer_class/receipt_printer_class.dart';
import 'package:stockall/local_database/receipt_printer_func/receipt_printer_func.dart';
import 'package:stockall/main.dart' show mainLocalLog, returnShopProvider;
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart'
    show listPrinters;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_store.dart';

/// Whether the selected printer is used for thermal receipt rolls or A4 documents.
enum AppPrintDocumentType { roll, a4 }

/// Unified printer and receipt roll settings for the entire application.
class AppPrinterSettings {
  final String? printerName;
  final String? printerUrl;
  final AppPrintDocumentType documentType;
  final PosPaper paper;
  final bool cutPaper;

  const AppPrinterSettings({
    this.printerName,
    this.printerUrl,
    this.documentType = AppPrintDocumentType.roll,
    required this.paper,
    required this.cutPaper,
  });

  bool get hasPrinter =>
      printerName != null &&
      printerName!.trim().isNotEmpty &&
      printerName != 'Not Set';

  int get printerTypeInt => paper == PosPaper.mm80 ? 2 : 1;

  AppPrinterSettings copyWith({
    String? printerName,
    String? printerUrl,
    bool clearPrinter = false,
    AppPrintDocumentType? documentType,
    PosPaper? paper,
    bool? cutPaper,
  }) {
    return AppPrinterSettings(
      printerName: clearPrinter ? null : (printerName ?? this.printerName),
      printerUrl: clearPrinter ? null : (printerUrl ?? this.printerUrl),
      documentType: documentType ?? this.documentType,
      paper: paper ?? this.paper,
      cutPaper: cutPaper ?? this.cutPaper,
    );
  }
}

/// Manages global printer selection, receipt roll preferences (58mm/80mm & cut),
/// system printer discovery, and PDF printing using the selected printer.
class AppPrinterService {
  static const String _rollSettingsKey = 'rollSettings';

  static Future<Box> _box() async =>
      Hive.isBoxOpen(PosPrinterStore.boxName)
          ? Hive.box(PosPrinterStore.boxName)
          : Hive.openBox(PosPrinterStore.boxName);

  static bool get _isDesktopNative =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  static bool get isMobileNative =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static PosTransport _nativeTransport() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return PosTransport.windowsSpooler;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return PosTransport.cups;
    }
    return PosTransport.bluetooth;
  }

  /// Loads the persisted printer and receipt roll settings.
  static Future<AppPrinterSettings> loadSettings() async {
    final posConfig = await PosPrinterStore.load();
    final legacyPrinter = ReceiptPrinterFunc().getReceiptPrinterClass();
    final shopPrintType = returnShopProvider().userShop()?.printType;

    Map? rollMap;
    try {
      final raw = (await _box()).get(_rollSettingsKey);
      if (raw is Map) rollMap = raw;
    } catch (_) {}

    final paper =
        posConfig?.paper ??
        (rollMap?['paper'] == 'mm80'
            ? PosPaper.mm80
            : rollMap?['paper'] == 'mm58'
            ? PosPaper.mm58
            : paperFromPrinterType(
              legacyPrinter?.printerSize ?? shopPrintType,
            ));

    final cutPaper =
        posConfig?.cut ??
        (rollMap?['cutPaper'] is bool
            ? rollMap!['cutPaper'] as bool
            : true);

    final documentType =
        isMobileNative
            ? AppPrintDocumentType.roll
            : (rollMap?['documentType'] == AppPrintDocumentType.a4.name
                ? AppPrintDocumentType.a4
                : AppPrintDocumentType.roll);

    String? printerName = posConfig?.name;
    String? printerUrl = posConfig?.address;

    if ((printerName == null || printerName.trim().isEmpty) &&
        legacyPrinter != null &&
        legacyPrinter.printerName.trim().isNotEmpty &&
        legacyPrinter.printerName != 'Not Set') {
      printerName = legacyPrinter.printerName;
      printerUrl = legacyPrinter.printerName;
    }

    if (rollMap?['printerUrl'] is String &&
        (rollMap!['printerUrl'] as String).isNotEmpty &&
        printerName == posConfig?.name) {
      printerUrl = rollMap['printerUrl'] as String;
    }

    return AppPrinterSettings(
      printerName: printerName,
      printerUrl: printerUrl,
      documentType: documentType,
      paper: paper,
      cutPaper: cutPaper,
    );
  }

  /// Best-effort detection of whether a system [Printer] is a POS receipt roll
  /// printer or an A4 document printer. Returns `null` when unknown so the
  /// user can choose manually.
  static AppPrintDocumentType? detectDocumentTypeForPrinter(Printer printer) {
    final haystack =
        '${printer.name} ${printer.model ?? ''} ${printer.comment ?? ''}'
            .toLowerCase();

    const rollKeywords = [
      'pos',
      'thermal',
      'receipt',
      '58mm',
      '80mm',
      'xp-',
      'xprinter',
      'epson tm',
      'tm-t',
      'tm-m',
      'bixolon',
      'star tsp',
      'tsp',
      'zywell',
      'munbyn',
      'rongta',
      'hoin',
      'sunmi',
      'imin',
      'esc/pos',
      'escpos',
    ];
    for (final kw in rollKeywords) {
      if (haystack.contains(kw)) return AppPrintDocumentType.roll;
    }

    const a4Keywords = [
      'print to pdf',
      'microsoft print to pdf',
      'laser',
      'inkjet',
      'deskjet',
      'officejet',
      'laserjet',
      'pixma',
      'ecotank',
      'mfc-',
      'hl-',
      'dcp-',
      'brother',
      'canon',
      'hp ',
      'ricoh',
      'xerox',
      'kyocera',
      'konica',
      'lexmark',
      'xps',
      'onenote',
      'fax',
      'a4',
      'document',
    ];
    for (final kw in a4Keywords) {
      if (haystack.contains(kw)) return AppPrintDocumentType.a4;
    }

    return null;
  }

  /// Saves printer and receipt roll settings across all stores so every
  /// printing path in the app respects them.
  static Future<void> saveSettings(AppPrinterSettings settings) async {
    try {
      await (await _box()).put(_rollSettingsKey, {
        'documentType': settings.documentType.name,
        'paper': settings.paper.name,
        'cutPaper': settings.cutPaper,
        'printerUrl': settings.printerUrl,
      });
    } catch (e) {
      debugPrint('Failed to save roll settings: $e');
    }

    if (settings.hasPrinter) {
      final name = settings.printerName!.trim();
      final url = (settings.printerUrl ?? name).trim();
      await PosPrinterStore.save(
        PosPrinterConfig(
          transport: _nativeTransport(),
          address: url,
          name: name,
          paper: settings.paper,
          cut: settings.cutPaper,
        ),
      );
      await ReceiptPrinterFunc().insertPrinter(
        ReceiptPrinterClass(
          printerName: name,
          printerSize: settings.paper.printerType,
        ),
      );
    } else {
      await PosPrinterStore.clear();
      await ReceiptPrinterFunc().insertPrinter(
        ReceiptPrinterClass(
          printerName: 'Not Set',
          printerSize: settings.paper.printerType,
        ),
      );
    }

    try {
      returnShopProvider().notifyReceiptPrinterChanged();
    } catch (_) {}
  }

  /// Lists all printers currently available on the system.
  static Future<List<Printer>> listSystemPrinters() async {
    if (kIsWeb) return const [];

    final Map<String, Printer> byName = {};

    try {
      final systemPrinters = await Printing.listPrinters();
      for (final p in systemPrinters) {
        if (p.name.trim().isNotEmpty) {
          byName[p.name] = p;
        }
      }
    } catch (e) {
      debugPrint('Printing.listPrinters failed: $e');
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      try {
        listPrinters();
        for (final p in returnShopProvider().printers) {
          if (p.name.trim().isNotEmpty && !byName.containsKey(p.name)) {
            byName[p.name] = Printer(url: p.name, name: p.name);
          }
        }
      } catch (e) {
        debugPrint('Windows EnumPrinters failed: $e');
      }
    }

    final list = byName.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Prints a PDF using the globally selected printer on desktop when
  /// configured, falling back to the system print dialog otherwise.
  static Future<bool> printPdf({
    required FutureOr<Uint8List> Function(PdfPageFormat format) onLayout,
    String name = 'Document',
    PdfPageFormat format = PdfPageFormat.standard,
    bool dynamicLayout = true,
  }) async {
    if (!kIsWeb && _isDesktopNative) {
      try {
        final settings = await loadSettings();
        if (settings.hasPrinter) {
          Printer targetPrinter = Printer(
            url: settings.printerUrl ?? settings.printerName!,
            name: settings.printerName!,
          );
          try {
            final printers = await Printing.listPrinters();
            for (final p in printers) {
              if (p.name == settings.printerName ||
                  p.url == settings.printerUrl) {
                targetPrinter = p;
                break;
              }
            }
          } catch (_) {}

          final sent = await Printing.directPrintPdf(
            printer: targetPrinter,
            onLayout: onLayout,
            name: name,
            format: format,
            dynamicLayout: dynamicLayout,
          );
          if (sent) return true;
        }
      } catch (e, stackTrace) {
        await mainLocalLog(
          'Direct print failed, falling back to system dialog: $e\n$stackTrace',
        );
      }
    }

    return Printing.layoutPdf(
      onLayout: onLayout,
      name: name,
      format: format,
      dynamicLayout: dynamicLayout,
    );
  }
}
