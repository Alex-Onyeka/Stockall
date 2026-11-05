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
}
