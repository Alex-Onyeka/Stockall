import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/lan/lan_own_holds_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';
import 'package:stockall/services/lan/lan_transport.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/remote/remote_client.dart';

/// The answer to one hold before a cart change.
class LanHoldCheck {
  const LanHoldCheck({
    required this.ok,
    this.available,
    this.unreachable = false,
  });

  static const LanHoldCheck allowed = LanHoldCheck(ok: true);

  /// The change can be saved: held, nothing to hold, or no server to ask
  /// (allowed while the server is unreachable).
  final bool ok;

  /// Refused: what the cart's lines can total of the product.
  final double? available;

  /// Allowed because the store server can't be reached.
  final bool unreachable;
}

/// What the client needs from the app; replaceable in tests.
class LanStockClientDeps {
  const LanStockClientDeps({
    required this.link,
    required this.route,
    required this.carts,
    required this.held,
    required this.queued,
    required this.dropQueued,
    this.sentQueue,
    this.serverId,
    this.cartChanges,
    this.onChanged,
    this.callTimeout = const Duration(seconds: 3),
    this.debounce = const Duration(milliseconds: 100),
    this.pinFor = const Duration(seconds: 2),
  });

  /// The store server's stock RPCs, or null when there is none to reach.
  final LanStockLink? Function() link;
  final LanRoute Function() route;

  /// Every cart on this device (as saved).
  final Iterable<TempCart> Function() carts;

  /// Whether the server holds [product] (a managed stock product).
  final bool Function(String product) held;

  /// This device's queued stock changes by queue uuid, in the
  /// `update_product_quantities` shape.
  final Map<String, Map<String, dynamic>> Function() queued;

  /// Removes queued stock changes the server applied.
  final Future<void> Function(Iterable<String> hiveUuids) dropQueued;

  /// The queue box [queued] reads: a checkout marks the changes it sends
  /// there as sent to the server (see `LanSentMarks`). Null: not marked.
  final String? sentQueue;

  /// The device id of the server [link] reaches.
  final String? Function()? serverId;

  /// Fires when a cart is saved (the safety net).
  final Stream<Object?> Function()? cartChanges;

  /// Other tills' holds changed: availability on screen must refresh.
  final void Function()? onChanged;
  final Duration callTimeout;
  final Duration debounce;

  /// How long a hold just given waits for its cart change to be saved
  /// before the safety net may lower it again.
  final Duration pinFor;

  factory LanStockClientDeps.app() => LanStockClientDeps(
    link: () {
      String? userId;
      try {
        userId = currentUser().userId;
      } catch (_) {}
      return LanTransport().stockLink(userId: userId);
    },
    route: () => RemoteRouter.route,
    carts: () => CartFunc().cartBox.values.expand((m) => m.cartQueue),
    held:
        (product) => returnData().productListMain.any(
          (p) => p.uuid == product && p.isManaged,
        ),
    queued:
        () => {
          for (final q in QuantityUpdateFunc().getQuantitiesUpdate())
            if (q.uuid != null)
              q.uuid!: {
                'hiveUuid': q.uuid,
                'itemUuid': q.productUuid,
                'quantity': q.quantity,
                'isIncrement': q.isIncrement,
                'isStorage': q.isStorage,
              },
        },
    dropQueued: (uuids) async {
      for (final uuid in uuids) {
        await QuantityUpdateFunc().deleteQuantityUpdate(uuid: uuid);
      }
    },
    sentQueue: QuantityUpdateFunc().quantityUpdateBoxName,
    serverId: () => LanTransport().clientServerView?.serverDeviceId,
    cartChanges: () => CartFunc().cartBox.watch(),
    onChanged: () => SalesProvider().lanStockChanged(),
  );
}

/// This device's side of cart stock holds: asks the store server to
/// hold what its receipt and invoice carts need, keeps the server's totals
/// to tell what other tills hold, re-syncs on (re)connect,
/// sends checkouts and releases on logout.
///
/// Every call to the server runs one at a time. With no server to reach
/// (standalone, off the LAN, or the server unreachable) nothing is asked
/// and every change is allowed.
class LanStockClient {
  static final LanStockClient _instance = LanStockClient._internal();
  factory LanStockClient() => _instance;
  LanStockClient._internal();

  LanStockClientDeps? _deps;
  LanStockClientDeps get deps => _deps ??= LanStockClientDeps.app();
  set deps(LanStockClientDeps value) => _deps = value;

  LanOwnHoldsFunc get _ownStore => LanOwnHoldsFunc();
  LanPendingCheckoutsFunc get _pendingStore => LanPendingCheckoutsFunc();

  final Map<LanHoldKey, double> _own = {};
  final Map<String, double> _totals = {};
  final Map<LanHoldKey, ({double quantity, DateTime until})> _pins = {};
  final StreamController<List<LanStockConflict>> _conflicts =
      StreamController.broadcast();

  Future<void> _tail = Future.value();
  Timer? _debounce;
  Timer? _pinTimer;
  StreamSubscription<Object?>? _cartSub;
  bool _started = false;
  LanRoute? _lastRoute;

  /// Holds the server couldn't give (re-sync, the safety net, add many,
  /// a cart type switch): for the conflict dialog.
  Stream<List<LanStockConflict>> get conflicts => _conflicts.stream;

  /// What this device holds, as the server last said.
  Map<LanHoldKey, double> get own => Map.unmodifiable(_own);

  /// The server can't be reached: stock isn't being held.
  bool get unreachable => deps.route() == LanRoute.lanDown;

  // ------------------------------------------------------------ lifecycle

  /// Main window only. Loads what was held before a restart and listens
  /// for stock events, (re)connects and cart changes.
  void start() {
    if (_started) return;
    _started = true;
    _loadOwn();
    _lastRoute = deps.route();
    final transport = LanTransport();
    if (transport.isAvailable) {
      transport.onStock = onStock;
      transport.onConnected = () => unawaited(resync());
    }
    RemoteRouter.addListener(_onRoute);
    try {
      _cartSub = deps.cartChanges?.call().listen((_) {
        // A cart was saved: the changes holds were given for are in it.
        _pins.clear();
        schedule();
      });
    } catch (e) {
      unawaited(mainLocalLog('LAN stock: carts not watched: $e'));
    }
  }

  @visibleForTesting
  Future<void> stop() async {
    _started = false;
    _debounce?.cancel();
    _debounce = null;
    _pinTimer?.cancel();
    _pinTimer = null;
    await _cartSub?.cancel();
    _cartSub = null;
    RemoteRouter.removeListener(_onRoute);
    final transport = LanTransport();
    if (transport.isAvailable) {
      transport.onStock = null;
      transport.onConnected = null;
    }
    await _tail;
  }

  @visibleForTesting
  void reset() {
    _own.clear();
    _totals.clear();
    _pins.clear();
    _deps = null;
  }

  void _loadOwn() {
    _own.clear();
    for (final e in _ownStore.all().entries) {
      final key = _parseKey(e.key);
      if (key != null && e.value > 0) _own[key] = e.value;
    }
  }

  void _onRoute() {
    final route = deps.route();
    final before = _lastRoute;
    _lastRoute = route;
    if (route == before) return;
    if (route == LanRoute.server ||
        (route == LanRoute.lanUp && before != LanRoute.lanUp)) {
      unawaited(resync());
    }
    if (route == LanRoute.standalone || route == LanRoute.offLan) {
      _totals.clear();
    }
    _changed();
  }

  // ---------------------------------------------------------------- reads

  /// What other tills hold of [product]: subtracted from what this
  /// device can sell. 0 away from the LAN.
  double reservedElsewhere(String product) {
    final link = deps.link();
    if (link != null && link.inProcess) {
      final v = link.reservedElsewhere?.call(product) ?? 0;
      return v > lanHoldEps ? v : 0;
    }
    final route = deps.route();
    if (route != LanRoute.lanUp && route != LanRoute.lanDown) return 0;
    var mine = 0.0;
    for (final e in _own.entries) {
      if (e.key.product == product) mine += e.value;
    }
    final v = (_totals[product] ?? 0) - mine;
    return v > lanHoldEps ? v : 0;
  }

  // ------------------------------------------------------------ operations

  /// Before a change that makes [cart]'s lines need [needed] of
  /// [product]: holds it. A decrease is left to the safety net
  /// (after the change is saved).
  Future<LanHoldCheck> hold(
    TempCart cart,
    String product,
    double needed,
  ) async {
    final id = cart.id;
    if (id == null || !deps.held(product)) return LanHoldCheck.allowed;
    final want = cartHoldFor(cart, product, needed);
    final key = (cart: id, product: product);
    if (want <= (_own[key] ?? 0) + lanHoldEps) return LanHoldCheck.allowed;
    final link = deps.link();
    if (link == null) return LanHoldCheck(ok: true, unreachable: unreachable);
    final outcomes = await _serial(() => _reserve(link, {key: want}));
    if (outcomes == null) {
      return const LanHoldCheck(ok: true, unreachable: true);
    }
    final o = outcomes.firstOrNull;
    if (o == null || o.ok) {
      _pin(key, want);
      return LanHoldCheck.allowed;
    }
    // What the lines can total: what may be held, plus an edit's original.
    return LanHoldCheck(
      ok: false,
      available: (o.available ?? 0) + (needed - want),
    );
  }

  /// Holds what [cart]'s lines will need per product ([needed]) in one
  /// batch: refusals come back (add many: per product; [atomic], a cart
  /// type switch: all or nothing). [asHolding]: [cart] is about to become
  /// a receipt or invoice.
  Future<List<LanStockConflict>> holdMany(
    TempCart cart,
    Map<String, double> needed, {
    bool atomic = false,
    bool asHolding = false,
  }) async {
    final id = cart.id;
    if (id == null) return const [];
    final holds = <LanHoldKey, double>{};
    for (final e in needed.entries) {
      if (!deps.held(e.key)) continue;
      final want = cartHoldFor(
        cart,
        e.key,
        e.value,
        holdsStock: asHolding ? true : null,
      );
      final key = (cart: id, product: e.key);
      if (want > (_own[key] ?? 0) + lanHoldEps) holds[key] = want;
    }
    if (holds.isEmpty) return const [];
    final link = deps.link();
    if (link == null) return const [];
    final outcomes = await _serial(() => _reserve(link, holds, atomic: atomic));
    if (outcomes == null) return const [];
    final refused = [
      for (final o in outcomes)
        if (!o.ok) o.conflict,
    ];
    if (refused.isEmpty || !atomic) {
      for (final o in outcomes) {
        if (!o.ok) continue;
        final key = (cart: o.conflict.cartId, product: o.conflict.productUuid);
        _pin(key, o.conflict.wanted);
      }
    }
    return refused;
  }

  /// The safety net: soon after a cart is saved, sends what changed.
  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(deps.debounce, () {
      _debounce = null;
      unawaited(reconcile());
    });
  }

  /// Makes the server hold what the carts need now (the safety net):
  /// decreases go straight through; an increase nobody asked for is
  /// asked, and a refusal goes to [conflicts].
  Future<void> reconcile() async {
    final link = deps.link();
    if (link == null) return;
    await _serial(() async {
      final diff = holdDiff(_wanted(), _own);
      if (diff.isEmpty) return;
      final outcomes = await _reserve(link, diff);
      final refused = [
        for (final o in outcomes ?? const <_Outcome>[])
          if (!o.ok) o.conflict,
      ];
      if (refused.isNotEmpty) _conflicts.add(refused);
    });
  }

  /// On (re)connect: the server's holds for this device become what
  /// its carts and pending checkouts need, holding what fits; the rest
  /// go to [conflicts]. Then pending checkouts are sent again. A connect
  /// asks for it twice (the connection, then the route): a call while one
  /// is still running joins it, so its conflicts are reported once.
  Future<List<LanStockConflict>> resync() =>
      _resyncing ??= _resync().whenComplete(() => _resyncing = null);

  Future<List<LanStockConflict>>? _resyncing;

  Future<List<LanStockConflict>> _resync() async {
    final link = deps.link();
    if (link == null) return const [];
    final conflicts = await _serial(() async {
      final wanted = _wanted();
      final Map<String, dynamic> res;
      try {
        res = await link
            .call(LanConstants.stockSyncRpc, {
              'holds': [
                for (final e in wanted.entries)
                  if (e.value > lanHoldEps) _holdJson(e.key, e.value),
              ],
            })
            .timeout(deps.callTimeout);
      } catch (e) {
        await mainLocalLog('LAN stock: re-sync failed: $e');
        return const <LanStockConflict>[];
      }
      _own.clear();
      for (final o in _outcomes(res['holds'])) {
        if (!o.free && o.held > lanHoldEps) {
          _own[(cart: o.conflict.cartId, product: o.conflict.productUuid)] =
              o.held;
        }
      }
      _totals
        ..clear()
        ..addAll(_reserved(res['reserved']));
      await _saveOwn();
      _changed();
      return [for (final o in _outcomes(res['conflicts'])) o.conflict];
    });
    if (conflicts.isNotEmpty) {
      await mainLocalLog('LAN stock: re-sync conflicts: $conflicts');
      _conflicts.add(conflicts);
    }
    await retryPending();
    return conflicts;
  }

  /// A receipt or invoice checkout, before its cart is deleted.
  /// On a client: the cart's holds are kept as a pending checkout, with
  /// the sale's queued stock changes (those queued since [queueBefore]),
  /// and sent to the server, which applies them and releases the cart in
  /// one step; until it has, the holds stay. On the server's own till:
  /// the sale is already in its stock; the cart is released.
  Future<void> checkout({
    required TempCart cart,
    required String receiptUuid,
    required Set<String> queueBefore,
  }) async {
    final cartId = cart.id;
    if (cartId == null) return;
    final link = deps.link();
    if (link != null && link.inProcess) {
      await _serial(() async {
        try {
          final res = await link
              .call(LanConstants.stockReleaseRpc, {'cart_id': cartId})
              .timeout(deps.callTimeout);
          _dropCart(cartId);
          _totals.addAll(_reserved(res['reserved']));
          await _saveOwn();
        } catch (e) {
          await mainLocalLog('LAN stock: release after checkout failed: $e');
        }
      });
      return;
    }
    final route = deps.route();
    if (route != LanRoute.lanUp && route != LanRoute.lanDown) return;
    final updates = [
      for (final e in deps.queued().entries)
        if (!queueBefore.contains(e.key)) e.value,
    ];
    final holds = {
      for (final e in _own.entries)
        if (e.key.cart == cartId) e.key.product: e.value,
    };
    if (updates.isEmpty && holds.isEmpty) return;
    await _pendingStore.put(
      cartId,
      jsonEncode({
        'cart_id': cartId,
        'receipt_uuid': receiptUuid,
        'updates': updates,
        'holds': holds,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    if (link != null) await _serial(() => _sendCheckout(link, cartId));
  }

  /// Sends every pending checkout again (after a re-sync and a LAN sync).
  Future<void> retryPending() async {
    final pending = _pendingStore.all();
    if (pending.isEmpty) return;
    final link = deps.link();
    if (link == null || link.inProcess) return;
    for (final cartId in pending.keys) {
      await _serial(() => _sendCheckout(link, cartId));
    }
  }

  /// Carts checked out that the server hasn't confirmed yet.
  Iterable<String> get pendingCheckouts => _pendingStore.all().keys;

  /// On logout: every hold of this device goes. Pending checkouts stay
  /// (their stock changes are still sent).
  Future<void> releaseAll() async {
    final link = deps.link();
    await _serial(() async {
      if (link != null) {
        try {
          await link
              .call(LanConstants.stockReleaseRpc, const {})
              .timeout(deps.callTimeout);
        } catch (e) {
          await mainLocalLog('LAN stock: release on logout failed: $e');
        }
      }
      _own.clear();
      _pins.clear();
      _totals.clear();
      await _saveOwn();
    });
    _changed();
  }

  /// A `stock` event: hold totals of the products that changed.
  void onStock(Map<String, double> reserved) {
    _totals.addAll(reserved);
    _changed();
  }

  /// Items left out of a cart change (add many skips them): for the
  /// conflict dialog.
  void report(List<LanStockConflict> conflicts) {
    if (conflicts.isNotEmpty) _conflicts.add(conflicts);
  }

  /// The queue uuids of this device's stock changes now (a checkout sends
  /// those queued after).
  Set<String> queuedKeys() {
    try {
      return deps.queued().keys.toSet();
    } catch (_) {
      return const {};
    }
  }

  // ------------------------------------------------------------- helpers

  Future<T> _serial<T>(Future<T> Function() body) {
    final run = _tail.then((_) => body());
    _tail = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  /// What the carts and pending checkouts need, with holds just given
  /// whose cart change isn't saved yet.
  Map<LanHoldKey, double> _wanted() {
    final wanted = cartHolds(deps.carts(), held: deps.held);
    for (final e in _pendingStore.all().entries) {
      try {
        final json = jsonDecode(e.value) as Map<String, dynamic>;
        final holds = (json['holds'] as Map?) ?? const {};
        for (final h in holds.entries) {
          final q = (h.value as num).toDouble();
          if (q > lanHoldEps) wanted[(cart: e.key, product: '${h.key}')] = q;
        }
      } catch (_) {}
    }
    final now = DateTime.now();
    _pins.removeWhere((key, pin) {
      final want = wanted[key] ?? 0;
      if (want >= pin.quantity - lanHoldEps || now.isAfter(pin.until)) {
        return true;
      }
      wanted[key] = pin.quantity;
      return false;
    });
    return wanted;
  }

  void _pin(LanHoldKey key, double quantity) {
    final until = DateTime.now().add(deps.pinFor);
    _pins[key] = (quantity: quantity, until: until);
    _pinTimer?.cancel();
    // Unsaved past the pin: the safety net looks again.
    _pinTimer = Timer(deps.pinFor + const Duration(milliseconds: 10), () {
      _pinTimer = null;
      if (_pins.isNotEmpty) schedule();
    });
  }

  /// Asks for [holds]; null when the server couldn't be asked.
  Future<List<_Outcome>?> _reserve(
    LanStockLink link,
    Map<LanHoldKey, double> holds, {
    bool atomic = false,
  }) async {
    final Map<String, dynamic> res;
    try {
      res = await link
          .call(LanConstants.stockReserveRpc, {
            'holds': [for (final e in holds.entries) _holdJson(e.key, e.value)],
            if (atomic) 'atomic': true,
          })
          .timeout(deps.callTimeout);
    } catch (e) {
      await mainLocalLog('LAN stock: hold failed: $e');
      return null;
    }
    final outcomes = _outcomes(res['holds']);
    final refusedAtomic = atomic && outcomes.any((o) => !o.ok);
    if (!refusedAtomic) {
      for (final o in outcomes) {
        final key = (cart: o.conflict.cartId, product: o.conflict.productUuid);
        if (o.free || o.held <= lanHoldEps) {
          _own.remove(key);
        } else {
          _own[key] = o.held;
        }
      }
    }
    _totals.addAll(_reserved(res['reserved']));
    await _saveOwn();
    _changed();
    return outcomes;
  }

  Future<void> _sendCheckout(LanStockLink link, String cartId) async {
    final raw = _pendingStore.all()[cartId];
    if (raw == null) return;
    final Map<String, dynamic> pending;
    try {
      pending = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      await _pendingStore.delete(cartId);
      return;
    }
    // Only what is still queued here: a change that left the queue was
    // sent already (to this server, which has it, or to Supabase off the
    // LAN, which this server must not apply again). Nor one sent to
    // another server without an answer: it waits for that server.
    final queued = deps.queued().keys.toSet();
    final sentQueue = deps.sentQueue;
    final server = deps.serverId?.call() ?? LanSentMarks.unknownServer;
    final updates = [
      for (final u in (pending['updates'] as List? ?? const []))
        if (u is Map &&
            queued.contains(u['hiveUuid']) &&
            (sentQueue == null ||
                LanSentMarks.maySend(sentQueue, u['hiveUuid'], to: server)))
          u,
    ];
    final sent = [for (final u in updates) '${u['hiveUuid']}'];
    // Without an answer, these may be applied there: they go nowhere else.
    if (sentQueue != null) {
      await LanSentMarks.markSending(sentQueue, sent, to: server);
    }
    final Map<String, dynamic> res;
    try {
      res = await link
          .call(LanConstants.stockCheckoutRpc, {
            'cart_id': cartId,
            'receipt_uuid': pending['receipt_uuid'],
            'updates': updates,
          })
          .timeout(deps.callTimeout);
    } catch (e) {
      await mainLocalLog('LAN stock: checkout $cartId kept pending: $e');
      return;
    }
    final done = [
      for (final u in (res['done'] as List? ?? const []))
        if (u is String) u,
    ];
    if (done.isNotEmpty) await deps.dropQueued(done);
    // Answered: applied (and dropped), or not applied (still queued, and
    // free to go anywhere).
    if (sentQueue != null) await SentEntriesFunc().unmark(sentQueue, sent);
    await _pendingStore.delete(cartId);
    _dropCart(cartId);
    _totals.addAll(_reserved(res['reserved']));
    await _saveOwn();
    _changed();
  }

  void _dropCart(String cartId) {
    _own.removeWhere((key, _) => key.cart == cartId);
    _pins.removeWhere((key, _) => key.cart == cartId);
  }

  Future<void> _saveOwn() async {
    try {
      await _ownStore.replaceAll({
        for (final e in _own.entries) _keyString(e.key): e.value,
      });
    } catch (e) {
      await mainLocalLog('LAN stock: own holds not saved: $e');
    }
  }

  /// Only once started (the app's main window): a logout or a call before
  /// that has no screen to refresh.
  void _changed() {
    if (!_started) return;
    try {
      deps.onChanged?.call();
    } catch (_) {}
  }

  static Map<String, dynamic> _holdJson(LanHoldKey key, double quantity) => {
    'cart_id': key.cart,
    'product_uuid': key.product,
    'quantity': quantity,
  };

  static String _keyString(LanHoldKey key) => '${key.cart}|${key.product}';

  static LanHoldKey? _parseKey(String key) {
    final i = key.indexOf('|');
    if (i <= 0 || i == key.length - 1) return null;
    return (cart: key.substring(0, i), product: key.substring(i + 1));
  }

  static Map<String, double> _reserved(Object? json) => {
    if (json is Map)
      for (final e in json.entries)
        if (e.value is num) '${e.key}': (e.value as num).toDouble(),
  };

  static List<_Outcome> _outcomes(Object? json) => [
    if (json is List)
      for (final h in json)
        if (h is Map<String, dynamic>) _Outcome.fromJson(h),
  ];
}

class _Outcome {
  _Outcome(this.conflict, {required this.ok, required this.free});

  factory _Outcome.fromJson(Map<String, dynamic> json) => _Outcome(
    LanStockConflict.fromJson(json),
    ok: json['ok'] == true,
    free: json['free'] == true,
  );

  final LanStockConflict conflict;
  final bool ok;
  final bool free;

  double get held => conflict.held;
  double? get available => conflict.available;
}
