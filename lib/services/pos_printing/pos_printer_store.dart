import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';

// The POS printer saved on this device. A plain map in its own Hive box
// (no adapter), not synced: a printer belongs to the machine, not the
// shop.
class PosPrinterStore {
  static const String boxName = 'posPrinterBoxStockall';
  static const String _key = 'printer';

  static Future<Box> _box() async =>
      Hive.isBoxOpen(boxName) ? Hive.box(boxName) : Hive.openBox(boxName);

  static Future<PosPrinterConfig?> load() async {
    try {
      return PosPrinterConfig.fromMap((await _box()).get(_key));
    } catch (e) {
      debugPrint('POS printer could not be read: $e');
      return null;
    }
  }

  static Future<void> save(PosPrinterConfig printer) async {
    await (await _box()).put(_key, printer.toMap());
  }

  static Future<void> clear() async {
    await (await _box()).delete(_key);
  }

  // The roll options (width, cut). Null when never saved: use
  // effectiveRollOptions for the ones in force.
  static const String _rollOptionsKey = 'rollOptions';

  static Future<RollOptions?> loadRollOptions() async {
    try {
      return RollOptions.fromMap((await _box()).get(_rollOptionsKey));
    } catch (e) {
      debugPrint('Roll options could not be read: $e');
      return null;
    }
  }

  static Future<void> saveRollOptions(RollOptions options) async {
    await (await _box()).put(_rollOptionsKey, options.toMap());
  }

  // The A4 printer.
  static const String _a4Key = 'a4Printer';

  static Future<A4PrinterConfig?> loadA4() async {
    try {
      return A4PrinterConfig.fromMap((await _box()).get(_a4Key));
    } catch (e) {
      debugPrint('A4 printer could not be read: $e');
      return null;
    }
  }

  static Future<void> saveA4(A4PrinterConfig printer) async {
    await (await _box()).put(_a4Key, printer.toMap());
  }

  static Future<void> clearA4() async {
    await (await _box()).delete(_a4Key);
  }
}
