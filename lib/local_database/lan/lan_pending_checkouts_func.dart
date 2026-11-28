import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/main.dart';

/// A LAN client's checkouts the store server hasn't confirmed yet,
/// keyed by cart id, valued by JSON: the cart's holds (kept until
/// the server has the sale) and the sale's queued stock changes.
///
/// No adapter: a plain `Box<String>`. Kept over a logout or a store
/// switch (they can't happen while one is here, except a logout that skips
/// the unsent check, or a store deleted): each names its store
/// (`shop_id`), and only the current store's are seen ([all]).
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

  /// The current store's pending checkouts (with those without a store).
  Map<String, String> all() {
    final every = _open()
        ? Map<String, String>.from(pendingBox.toMap())
        : Map.of(_memory);
    final shop = _currentShop();
    if (shop == null) return every;
    every.removeWhere((_, json) {
      try {
        final of = (jsonDecode(json) as Map)['shop_id'];
        return of is int && of != shop;
      } catch (_) {
        return false;
      }
    });
    return every;
  }

  static int? _currentShop() {
    final shops = CurrentShopFunc();
    if (!Hive.isBoxOpen(shops.currentShopBoxName)) return null;
    try {
      return shops.getCurrentShop()?.currentShopId;
    } catch (_) {
      return null;
    }
  }

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
