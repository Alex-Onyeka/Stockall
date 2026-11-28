import 'dart:async';
import 'dart:convert';

import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

const double _eps = 1e-9;

/// Stock one cart of one device holds of one product, in stock
/// units (`TempCartItem.getStockQuantity()`: area for 2D items).
class LanHold {
  LanHold({
    required this.deviceId,
    required this.cartId,
    required this.productUuid,
    required this.quantity,
    required this.updatedAt,
    this.userId,
  });

  factory LanHold.fromJson(Map<String, dynamic> json) => LanHold(
    deviceId: json['device_id'] as String,
    cartId: json['cart_id'] as String,
    productUuid: json['product_uuid'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    userId: json['user_id'] as String?,
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  final String deviceId;
  final String cartId;
  final String productUuid;
  final double quantity;
  final String? userId;
  final DateTime updatedAt;

  static String keyOf(String device, String cart, String product) =>
      '$device|$cart|$product';

  String get key => keyOf(deviceId, cartId, productUuid);

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    'cart_id': cartId,
    'product_uuid': productUuid,
    'quantity': quantity,
    'user_id': userId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}

/// What a cart asks to hold of a product: the absolute amount.
class LanHoldRequest {
  const LanHoldRequest(this.cartId, this.productUuid, this.quantity);

  final String cartId;
  final String productUuid;
  final double quantity;

  static List<LanHoldRequest> parseAll(Object? holds) {
    if (holds is! List) {
      throw const PgError(400, '22P02', 'expects {"holds": [...]}');
    }
    return [
      for (final h in holds)
        if (h is Map<String, dynamic> &&
            h['cart_id'] is String &&
            (h['cart_id'] as String).isNotEmpty &&
            h['product_uuid'] is String &&
            (h['product_uuid'] as String).isNotEmpty &&
            h['quantity'] is num &&
            (h['quantity'] as num) >= 0)
          LanHoldRequest(
            h['cart_id'] as String,
            h['product_uuid'] as String,
            (h['quantity'] as num).toDouble(),
          )
        else
          throw PgError(400, '22P02', 'bad hold', details: '$h'),
    ];
  }
}

/// The answer for one [LanHoldRequest].
class LanHoldOutcome {
  const LanHoldOutcome({
    required this.request,
    required this.held,
    required this.ok,
    this.available,
    this.free = false,
  });

  final LanHoldRequest request;

  /// What this cart now holds of the product (for a free item: what it
  /// asked, nothing being held).
  final double held;

  /// The request fits. In a refused atomic batch, a request that would
  /// have fitted is still `ok` (only its batch failed; [held] is
  /// unchanged).
  final bool ok;

  /// What this cart could hold of the product, when the request didn't
  /// fit.
  final double? available;

  /// Not held at all: an unmanaged item, or one this server doesn't have
  /// (yet). The client asks again later (it may arrive).
  final bool free;

  Map<String, dynamic> toJson() => {
    'cart_id': request.cartId,
    'product_uuid': request.productUuid,
    'wanted': request.quantity,
    'held': held,
    'ok': ok,
    if (available != null) 'available': available,
    if (free) 'free': true,
  };
}

/// The LAN server's cart stock holds.
///
/// - `available(product) = quantity − every other (device, cart)'s hold`.
/// - A hold only for managed products this server holds; other items are
///   free (accepted, nothing held), as the app treats them today.
/// - Everything that changes holds or stock runs under [exclusive] (the
///   delta RPCs' and the puller's lock), so a reserve never interleaves
///   with an apply or a pull.
/// - A device's holds are released [grace] after its last WebSocket
///   closed (or its last stock call, if it never opened one), unless it
///   comes back; this server's own device never expires.
/// - Changes are announced as `{type: stock, reserved: {uuid: total}}`,
///   batched.
class LanStockService implements LanStockRpcs {
  LanStockService({
    required this.exclusive,
    required this.product,
    required this.applyCheckout,
    this.prepareCheckout,
    required this.ownDeviceId,
    this.send,
    this.productChanges,
    this.grace = LanConstants.holdGrace,
    this.eventBatch = LanConstants.stockEventBatch,
    DateTime Function()? clock,
    Timer Function(Duration, void Function())? timer,
    LanStockHoldsFunc? store,
  }) : _clock = clock ?? DateTime.now,
       _timer = timer ?? Timer.new,
       _store = store ?? LanStockHoldsFunc();

  /// `LanDeltaRpcs.runExclusive`.
  final Future<R> Function<R>(Future<R> Function() body) exclusive;

  /// This store's product by uuid (the server's box).
  final TempProductClass? Function(String uuid) product;

  /// Applies a checkout's `{"updates": [...]}` (already under the lock).
  final Future<LanDeltaBatch> Function(Object? body) applyCheckout;

  /// Asks Supabase what [applyCheckout] needs to know about the items,
  /// before the lock is taken (`LanDeltaRpcs.prepare`).
  final Future<void> Function(Object? body)? prepareCheckout;

  final String Function() ownDeviceId;
  final void Function(Map<String, dynamic> event)? send;

  /// Keys of products changed in the server's box (to log stock that
  /// went negative or below its holds).
  final Stream<String> Function()? productChanges;
  final Duration grace;
  final Duration eventBatch;
  final DateTime Function() _clock;
  final Timer Function(Duration, void Function()) _timer;
  final LanStockHoldsFunc _store;

  final Map<String, LanHold> _holds = {};
  final Map<String, int> _sockets = {};
  final Map<String, Timer> _expiry = {};
  final Set<String> _changed = {};
  final Set<String> _flagged = {};
  Timer? _eventTimer;
  StreamSubscription<String>? _productSub;
  bool _stopped = false;

  static const Set<String> rpcs = {
    LanConstants.stockReserveRpc,
    LanConstants.stockSyncRpc,
    LanConstants.stockReleaseRpc,
    LanConstants.stockCheckoutRpc,
  };

  @override
  bool handles(String name) => rpcs.contains(name);

  // ------------------------------------------------------------ lifecycle

  /// Loads the holds kept in Hive. A restarted server gives every other
  /// device [grace] from now to come back.
  void start() {
    _holds.clear();
    for (final json in _store.values()) {
      try {
        final hold = LanHold.fromJson(jsonDecode(json) as Map<String, dynamic>);
        _holds[hold.key] = hold;
      } catch (_) {}
    }
    for (final device in {for (final h in _holds.values) h.deviceId}) {
      _scheduleExpiry(device);
    }
    try {
      _productSub = productChanges?.call().listen(_checkProduct);
    } catch (e) {
      // The products box failed to open: stock isn't watched for the log.
      unawaited(mainLocalLog('LAN stock: products not watched: $e'));
    }
  }

  Future<void> stop() async {
    _stopped = true;
    for (final t in _expiry.values) {
      t.cancel();
    }
    _expiry.clear();
    _eventTimer?.cancel();
    _eventTimer = null;
    await _productSub?.cancel();
    _productSub = null;
  }

  // ------------------------------------------------------------- presence

  /// A WebSocket of [device] opened.
  void deviceOnline(String device) {
    _sockets[device] = (_sockets[device] ?? 0) + 1;
    _expiry.remove(device)?.cancel();
  }

  /// A WebSocket of [device] closed: with none left, its holds go after
  /// [grace].
  void deviceOffline(String device) {
    final left = (_sockets[device] ?? 1) - 1;
    if (left > 0) {
      _sockets[device] = left;
      return;
    }
    _sockets.remove(device);
    _scheduleExpiry(device);
  }

  void _scheduleExpiry(String device) {
    if (_stopped || device == ownDeviceId()) return;
    if ((_sockets[device] ?? 0) > 0) return;
    if (!_holds.values.any((h) => h.deviceId == device)) return;
    _expiry.remove(device)?.cancel();
    _expiry[device] = _timer(grace, () {
      _expiry.remove(device);
      if (_stopped || (_sockets[device] ?? 0) > 0) return;
      unawaited(
        exclusive(() async {
          final released = await _release(device, null);
          if (released.isNotEmpty) {
            await mainLocalLog(
              'LAN stock: device $device gone; ${released.length} holds '
              'released',
            );
          }
        }),
      );
    });
  }

  // --------------------------------------------------------------- reads

  /// Every product's total held (all devices).
  Map<String, double> totals([Iterable<String>? products]) {
    final out = <String, double>{};
    if (products != null) {
      for (final p in products) {
        out[p] = 0;
      }
    }
    for (final h in _holds.values) {
      if (products != null && !out.containsKey(h.productUuid)) continue;
      out[h.productUuid] = (out[h.productUuid] ?? 0) + h.quantity;
    }
    return out;
  }

  double heldBy(String device, String cart, String productUuid) =>
      _holds[LanHold.keyOf(device, cart, productUuid)]?.quantity ?? 0;

  /// What devices other than [device] hold of [productUuid] (the server's
  /// own till reads it directly).
  double reservedElsewhere(String productUuid, String device) {
    var total = 0.0;
    for (final h in _holds.values) {
      if (h.productUuid == productUuid && h.deviceId != device) {
        total += h.quantity;
      }
    }
    return total;
  }

  Iterable<LanHold> get holds => _holds.values;

  /// The devices with a WebSocket open now, and how many.
  Map<String, int> get connected => Map.unmodifiable(_sockets);

  /// Releases every hold of [device] (a manager frees what a till
  /// that won't come back was holding). Returns how many.
  Future<int> releaseDevice(String device) => exclusive(() async {
    final released = await _release(device, null);
    if (released.isNotEmpty) {
      await mainLocalLog(
        'LAN stock: ${released.length} holds of $device released by hand',
      );
    }
    return released.length;
  });

  // ----------------------------------------------------------- operations

  /// Holds each request's absolute amount. A decrease always
  /// passes; an increase only if it fits. [atomic]: if any doesn't fit,
  /// nothing changes.
  Future<List<LanHoldOutcome>> reserve({
    required String device,
    required List<LanHoldRequest> requests,
    String? userId,
    bool atomic = false,
  }) => exclusive(() async {
    final outcomes = <LanHoldOutcome>[];
    final free = <LanHoldOutcome>{};
    final apply = <LanHold?>[];
    final keys = <String>[];
    // Holds as they would stand, so two requests for one product in one
    // batch see each other.
    final tentative = Map.of(_holds);
    for (final r in requests) {
      final key = LanHold.keyOf(device, r.cartId, r.productUuid);
      final current = tentative[key]?.quantity ?? 0;
      final available = _availableIn(tentative, r.productUuid, key);
      if (available == null) {
        // Free item: nothing held (and nothing kept from before).
        final outcome = LanHoldOutcome(
          request: r,
          held: r.quantity,
          ok: true,
          free: true,
        );
        outcomes.add(outcome);
        free.add(outcome);
        tentative.remove(key);
        apply.add(null);
        keys.add(key);
        continue;
      }
      if (r.quantity <= current + _eps || r.quantity <= available + _eps) {
        final hold = _hold(device, r, userId);
        outcomes.add(LanHoldOutcome(request: r, held: r.quantity, ok: true));
        if (hold == null) {
          tentative.remove(key);
        } else {
          tentative[key] = hold;
        }
        apply.add(hold);
        keys.add(key);
      } else {
        outcomes.add(
          LanHoldOutcome(
            request: r,
            held: current,
            ok: false,
            available: available < 0 ? 0 : available,
          ),
        );
      }
    }
    if (atomic && outcomes.any((o) => !o.ok)) {
      // Nothing changes: each answer keeps whether it would have fitted.
      return [
        for (final o in outcomes)
          LanHoldOutcome(
            request: o.request,
            held:
                free.contains(o)
                    ? o.request.quantity
                    : _holds[LanHold.keyOf(
                              device,
                              o.request.cartId,
                              o.request.productUuid,
                            )]
                            ?.quantity ??
                        0,
            ok: o.ok,
            available: o.available,
            free: o.free,
          ),
      ];
    }
    for (var i = 0; i < keys.length; i++) {
      await _put(keys[i], apply[i]);
    }
    _touched(device);
    return outcomes;
  });

  /// Replaces every hold of [device] with [requests] (a re-sync on
  /// connect): each holds what fits; the rest are conflicts.
  Future<List<LanHoldOutcome>> sync({
    required String device,
    required List<LanHoldRequest> requests,
    String? userId,
  }) => exclusive(() async {
    final tentative = Map.of(_holds)
      ..removeWhere((_, h) => h.deviceId == device);
    final outcomes = <LanHoldOutcome>[];
    for (final r in requests) {
      final key = LanHold.keyOf(device, r.cartId, r.productUuid);
      final available = _availableIn(tentative, r.productUuid, key);
      if (available == null) {
        outcomes.add(
          LanHoldOutcome(request: r, held: r.quantity, ok: true, free: true),
        );
        continue;
      }
      final fits = available < 0 ? 0.0 : available;
      final ok = r.quantity <= fits + _eps;
      final held = ok ? r.quantity : fits;
      final hold = _hold(
        device,
        LanHoldRequest(r.cartId, r.productUuid, held),
        userId,
      );
      if (hold != null) tentative[key] = hold;
      outcomes.add(
        LanHoldOutcome(
          request: r,
          held: held,
          ok: ok,
          available: ok ? null : fits,
        ),
      );
    }
    for (final key in {..._holds.keys, ...tentative.keys}) {
      final before = _holds[key];
      final after = tentative[key];
      if (before?.deviceId != device && after?.deviceId != device) continue;
      if (before?.quantity == after?.quantity) continue;
      await _put(key, after);
    }
    _touched(device);
    return outcomes;
  });

  /// Releases [cart] of [device], or every hold of [device].
  Future<void> release({required String device, String? cart}) =>
      exclusive(() async {
        await _release(device, cart);
        _touched(device);
      });

  /// A checkout, in one step: the sale's stock change is applied
  /// (repeats dropped by `hiveUuid`; items not here yet left out) and
  /// the cart's holds released. Done once per receipt and cart.
  Future<LanDeltaBatch?> checkout({
    required String device,
    required String cart,
    required String receiptUuid,
    required Object? updates,
  }) async {
    final hasUpdates = updates is List && updates.isNotEmpty;
    // Network lookups first: never while holding the lock.
    if (hasUpdates) await prepareCheckout?.call({'updates': updates});
    return exclusive(() async {
      final batch =
          hasUpdates
              ? await applyCheckout({'updates': updates})
              : null;
      await _release(device, cart);
      for (final uuid in batch?.changedItems ?? const <String>{}) {
        _checkProduct(uuid);
      }
      _touched(device);
      return batch;
    });
  }

  // ------------------------------------------------------------- the RPCs

  @override
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal) async {
    final device = principal.deviceId;
    if (device == null || device.isEmpty) {
      throw const PgError(400, 'LAN07', 'This session has no device');
    }
    final body =
        request.body is Map<String, dynamic>
            ? request.body as Map<String, dynamic>
            : const <String, dynamic>{};
    return PgResponse(
      200,
      body: await call(
        request.table,
        body,
        device: device,
        userId: principal.userId,
      ),
    );
  }

  /// One of the four RPCs for [device], answered as JSON: over HTTP
  /// ([handle], the device from the session) or in process by the
  /// server's own till.
  Future<Map<String, dynamic>> call(
    String rpc,
    Map<String, dynamic> body, {
    required String device,
    String? userId,
  }) async {
    switch (rpc) {
      case LanConstants.stockReserveRpc:
        final requests = LanHoldRequest.parseAll(body['holds']);
        final outcomes = await reserve(
          device: device,
          requests: requests,
          userId: userId,
          atomic: body['atomic'] == true,
        );
        return {
          'holds': [for (final o in outcomes) o.toJson()],
          'reserved': totals({for (final r in requests) r.productUuid}),
        };
      case LanConstants.stockSyncRpc:
        final requests = LanHoldRequest.parseAll(body['holds']);
        final outcomes = await sync(
          device: device,
          requests: requests,
          userId: userId,
        );
        return {
          'holds': [for (final o in outcomes) o.toJson()],
          'conflicts': [
            for (final o in outcomes)
              if (!o.ok) o.toJson(),
          ],
          'reserved': totals(),
        };
      case LanConstants.stockReleaseRpc:
        final cart = body['cart_id'];
        if (cart != null && (cart is! String || cart.isEmpty)) {
          throw const PgError(400, '22P02', 'bad cart_id');
        }
        await release(device: device, cart: cart as String?);
        return {'reserved': totals()};
      case LanConstants.stockCheckoutRpc:
        final cart = body['cart_id'];
        final receipt = body['receipt_uuid'];
        final updates = body['updates'] ?? const [];
        if (cart is! String ||
            cart.isEmpty ||
            receipt is! String ||
            receipt.isEmpty ||
            updates is! List) {
          throw const PgError(
            400,
            '22P02',
            'expects {"cart_id", "receipt_uuid", "updates": [...]}',
          );
        }
        // Every entry must carry its queue uuid, so a repeat is dropped.
        for (final u in updates) {
          if (u is! Map || u['hiveUuid'] is! String) {
            throw PgError(
              400,
              '22P02',
              'a checkout update needs its hiveUuid',
              details: '$u',
            );
          }
        }
        final batch = await checkout(
          device: device,
          cart: cart,
          receiptUuid: receipt,
          updates: updates,
        );
        return {
          'done': [for (final e in batch?.done ?? const []) e.hiveUuid],
          'not_here_yet': [
            for (final e in batch?.notHereYet ?? const []) e.hiveUuid,
          ],
          'reserved': totals(),
        };
    }
    throw PgError.unknownFunction(rpc);
  }

  // -------------------------------------------------------------- helpers

  /// What the hold under [exceptKey] could take of [productUuid], with
  /// [holds] as they stand; null for a free item (not managed, or not a
  /// product of this server).
  double? _availableIn(
    Map<String, LanHold> holds,
    String productUuid,
    String exceptKey,
  ) {
    final p = product(productUuid);
    if (p == null || !p.isManaged) return null;
    var others = 0.0;
    for (final h in holds.values) {
      if (h.productUuid == productUuid && h.key != exceptKey) {
        others += h.quantity;
      }
    }
    return (p.getActualQuantity() ?? 0) - others;
  }

  LanHold? _hold(String device, LanHoldRequest r, String? userId) {
    if (r.quantity <= _eps) return null;
    return LanHold(
      deviceId: device,
      cartId: r.cartId,
      productUuid: r.productUuid,
      quantity: r.quantity,
      userId: userId,
      updatedAt: _clock().toUtc(),
    );
  }

  /// Stores (or, with null, removes) the hold under [key].
  Future<void> _put(String key, LanHold? hold) async {
    final before = _holds[key];
    if (hold == null) {
      if (before == null) return;
      _holds.remove(key);
      await _store.delete(key);
      _announce(before.productUuid);
      return;
    }
    _holds[key] = hold;
    await _store.put(key, jsonEncode(hold.toJson()));
    if (before?.quantity != hold.quantity) _announce(hold.productUuid);
  }

  Future<List<LanHold>> _release(String device, String? cart) async {
    final gone = [
      for (final h in _holds.values)
        if (h.deviceId == device && (cart == null || h.cartId == cart)) h,
    ];
    for (final h in gone) {
      await _put(h.key, null);
    }
    return gone;
  }

  /// A stock call from [device]: without a socket, its holds go [grace]
  /// after its last call.
  void _touched(String device) {
    if ((_sockets[device] ?? 0) == 0) _scheduleExpiry(device);
  }

  void _announce(String productUuid) {
    _changed.add(productUuid);
    _checkProduct(productUuid);
    if (_stopped || send == null) return;
    _eventTimer ??= _timer(eventBatch, () {
      _eventTimer = null;
      if (_changed.isEmpty) return;
      final event = {'type': 'stock', 'reserved': totals(_changed.toList())};
      _changed.clear();
      send?.call(event);
    });
  }

  /// Logs (once per change of state) a product whose stock went below 0
  /// or below what carts hold of it.
  void _checkProduct(String productUuid) {
    final p = product(productUuid);
    if (p == null || !p.isManaged) {
      _flagged.remove(productUuid);
      return;
    }
    final actual = p.getActualQuantity() ?? 0;
    final held = totals([productUuid])[productUuid] ?? 0;
    final bad = actual < -_eps || held > actual + _eps;
    if (!bad) {
      _flagged.remove(productUuid);
      return;
    }
    if (!_flagged.add(productUuid)) return;
    unawaited(
      mainLocalLog(
        actual < -_eps
            ? 'LAN stock: ${p.name} ($productUuid) went below zero: $actual'
            : 'LAN stock: ${p.name} ($productUuid) has $actual, carts hold '
                '$held',
      ),
    );
  }
}
