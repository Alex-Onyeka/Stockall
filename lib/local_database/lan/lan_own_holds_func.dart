import 'dart:async';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// What the store server holds for this device's carts, as it last said:
/// keyed `cart|product`, valued by the amount. Lets the device
/// tell its own holds from other devices' in the server's totals.
///
/// No adapter: a plain `Box<String>`. Shop data: cleared by
/// `clearAllShopData`.
class LanOwnHoldsFunc {
  static final LanOwnHoldsFunc instance = LanOwnHoldsFunc._internal();
  factory LanOwnHoldsFunc() => instance;
  LanOwnHoldsFunc._internal();

  late Box<String> ownHoldsBox;
  final String ownHoldsBoxName = 'lanOwnHoldsBoxStockall';

  bool _warned = false;

  Future<void> init() async {
    try {
      ownHoldsBox = await openBoxSafely<String>(ownHoldsBoxName);
      await mainLocalLog('✅ LAN Own Holds Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Own Holds Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Not open: the holds live in memory only (the next re-sync with the
  /// server sets them again).
  bool _open() {
    if (Hive.isBoxOpen(ownHoldsBoxName)) return true;
    if (!_warned) {
      _warned = true;
      unawaited(
        mainLocalLog(
          '⚠️ LAN stock: own holds box "$ownHoldsBoxName" is not open; '
          'kept in memory only until the next re-sync.',
        ),
      );
    }
    return false;
  }

  Map<String, double> all() {
    if (!_open()) return {};
    final out = <String, double>{};
    for (final e in ownHoldsBox.toMap().entries) {
      final v = double.tryParse(e.value);
      if (v != null) out['${e.key}'] = v;
    }
    return out;
  }

  /// Replaces what is stored with [holds].
  Future<void> replaceAll(Map<String, double> holds) async {
    if (!_open()) return;
    await ownHoldsBox.clear();
    await ownHoldsBox.putAll({
      for (final e in holds.entries) e.key: '${e.value}',
    });
  }

  Future<void> put(String key, double quantity) async {
    if (!_open()) return;
    if (quantity <= 0) {
      await ownHoldsBox.delete(key);
    } else {
      await ownHoldsBox.put(key, '$quantity');
    }
  }

  Future<void> clearOwnHolds() async {
    if (_open()) await ownHoldsBox.clear();
  }
}
