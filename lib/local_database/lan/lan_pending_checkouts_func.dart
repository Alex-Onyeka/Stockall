import 'dart:async';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// A LAN client's checkouts the store server hasn't confirmed yet,
/// keyed by cart id, valued by JSON: the cart's holds (kept until
/// the server has the sale) and the sale's queued stock changes.
///
/// No adapter: a plain `Box<String>`. Shop data: cleared by
/// `clearAllShopData`.
class LanPendingCheckoutsFunc {
  static final LanPendingCheckoutsFunc instance =
      LanPendingCheckoutsFunc._internal();
  factory LanPendingCheckoutsFunc() => instance;
  LanPendingCheckoutsFunc._internal();

  late Box<String> pendingBox;
  final String pendingBoxName = 'lanPendingCheckoutsBoxStockall';

  /// Used while the box isn't open.
  final Map<String, String> _memory = {};
  bool _warned = false;

  Future<void> init() async {
    try {
      pendingBox = await openBoxSafely<String>(pendingBoxName);
      await mainLocalLog('✅ LAN Pending Checkouts Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Pending Checkouts Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  bool _open() {
    if (Hive.isBoxOpen(pendingBoxName)) return true;
    if (!_warned) {
      _warned = true;
      unawaited(
        mainLocalLog(
          '⚠️ LAN stock: pending checkouts box "$pendingBoxName" is not '
          'open. Pending checkouts are kept in memory only and will be '
          'LOST if the app restarts.',
        ),
      );
    }
    return false;
  }

  Map<String, String> all() =>
      _open() ? Map<String, String>.from(pendingBox.toMap()) : Map.of(_memory);

  Future<void> put(String cartId, String json) async {
    if (_open()) {
      await pendingBox.put(cartId, json);
    } else {
      _memory[cartId] = json;
    }
  }

  Future<void> delete(String cartId) async {
    if (_open()) {
      await pendingBox.delete(cartId);
    } else {
      _memory.remove(cartId);
    }
  }

  Future<void> clearPending() async {
    _memory.clear();
    if (_open()) await pendingBox.clear();
  }
}
