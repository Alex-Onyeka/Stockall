import 'dart:async';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// The LAN server's stock holds for open receipt and invoice carts:
/// one entry per (device, cart, product), keyed
/// `device|cart|product`, valued by the hold as JSON
/// (`LanHold.toJson`). Kept so a restarted server still holds what its
/// devices' carts need.
///
/// No adapter: a plain `Box<String>`. Shop data: cleared by
/// `clearAllShopData`.
class LanStockHoldsFunc {
  static final LanStockHoldsFunc instance = LanStockHoldsFunc._internal();
  factory LanStockHoldsFunc() => instance;
  LanStockHoldsFunc._internal();

  late Box<String> holdsBox;
  final String holdsBoxName = 'lanStockHoldsBoxStockall';

  Future<void> init() async {
    try {
      holdsBox = await openBoxSafely<String>(holdsBoxName);
      await mainLocalLog('✅ LAN Stock Holds Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Stock Holds Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  bool _warned = false;

  /// The box failed to open (or isn't yet): holds live in memory only,
  /// and are lost if the server restarts. Warned once.
  bool _open() {
    if (Hive.isBoxOpen(holdsBoxName)) {
      _warned = false;
      return true;
    }
    if (!_warned) {
      _warned = true;
      unawaited(
        mainLocalLog(
          '⚠️ LAN stock: holds box "$holdsBoxName" is not open. Cart holds '
          'are kept in memory only and will be LOST if the server restarts '
          '(devices re-sync them when they reconnect).',
        ),
      );
    }
    return false;
  }

  Iterable<String> values() => _open() ? holdsBox.values : const [];

  Future<void> put(String key, String json) async {
    if (_open()) await holdsBox.put(key, json);
  }

  Future<void> delete(String key) async {
    if (_open()) await holdsBox.delete(key);
  }

  Future<void> clearHolds() async {
    if (_open()) await holdsBox.clear();
  }
}
