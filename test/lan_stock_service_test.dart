import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';

import 'helpers/lan_fixtures.dart';

/// Timers the test fires by hand.
class FakeTimers {
  final timers = <FakeTimer>[];

  Timer create(Duration duration, void Function() callback) {
    final t = FakeTimer(duration, callback);
    timers.add(t);
    return t;
  }

  List<FakeTimer> get active => [
    for (final t in timers)
      if (t.isActive) t,
  ];

  /// Fires every active timer of [duration] (all, when null).
  Future<void> fire([Duration? duration]) async {
    for (final t in active) {
      if (duration == null || t.duration == duration) t.fire();
    }
    // Let the work the callbacks started (under the lock) finish.
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class FakeTimer implements Timer {
  FakeTimer(this.duration, this._callback);

  final Duration duration;
  final void Function() _callback;
  bool _active = true;

  void fire() {
    if (!_active) return;
    _active = false;
    _callback();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

const grace = LanConstants.holdGrace;
const batch = LanConstants.stockEventBatch;

void main() {
  late FakeTimers timers;
  late LanDeltaRpcs deltas;
  late LanStockService stock;
  late List<Map<String, dynamic>> events;

  LanStockService make() => LanStockService(
    exclusive: deltas.runExclusive,
    product: (uuid) => ProductsFunc().productBox.get(uuid),
    applyCheckout: (body) => deltas.applyHoldingLock(
      'update_product_quantities',
      body,
      skipUnknown: true,
    ),
    ownDeviceId: () => 'desk',
    send: events.add,
    timer: timers.create,
    clock: () => DateTime.utc(2026, 11, 26, 9),
  );

  Future<void> stockOf(String uuid, double quantity, {bool managed = true}) =>
      ProductsFunc().productBox.put(
        uuid,
        product(uuid)
          ..quantity = quantity
          ..isManaged = managed,
      );

  List<LanHoldRequest> hold(String cart, String product, double quantity) => [
    LanHoldRequest(cart, product, quantity),
  ];

  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_stock').path);
    registerAllHiveAdapters();
    await ProductsFunc().init();
    await QuantityUpdateFunc().init();
    await LanAppliedDeltasFunc().init();
    await LanDeletedItemsFunc().init();
    await LanStockHoldsFunc().init();
  });

  setUp(() async {
    await ProductsFunc().productBox.clear();
    await QuantityUpdateFunc().quantityUpdateBox.clear();
    await LanAppliedDeltasFunc().appliedDeltasBox.clear();
    await LanStockHoldsFunc().clearHolds();
    timers = FakeTimers();
    events = [];
    deltas = LanDeltaRpcs(
      rpcs: lanDeltaRpcs(shopId: () => 7),
      applied: const HiveAppliedDeltas(),
    );
    stock = make()..start();
  });

  tearDown(() => stock.stop());

  tearDownAll(() async {
    await Hive.close();
  });

  test('two devices and the last unit: the second is refused until the '
      'first lets it go', () async {
    await stockOf('p1', 1);
    var a = await stock.reserve(device: 'A', requests: hold('a1', 'p1', 1));
    expect(a.single.ok, isTrue);

    var b = await stock.reserve(device: 'B', requests: hold('b1', 'p1', 1));
    expect(b.single.ok, isFalse);
    expect(b.single.held, 0);
    expect(b.single.available, 0);

    a = await stock.reserve(device: 'A', requests: hold('a1', 'p1', 0));
    expect(a.single.ok, isTrue);
    b = await stock.reserve(device: 'B', requests: hold('b1', 'p1', 1));
    expect(b.single.ok, isTrue);
    expect(stock.totals(), {'p1': 1});
  });

  test('absolute amounts: a repeat holds once; a decrease always passes, '
      'even below what stock now has', () async {
    await stockOf('p1', 5);
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 2));
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 2));
    expect(stock.totals(), {'p1': 2});

    // Stock fell under the hold (a pull, a sale elsewhere).
    await stockOf('p1', 0);
    final down = await stock.reserve(device: 'A', requests: hold('a1', 'p1', 1));
    expect(down.single.ok, isTrue);
    expect(stock.heldBy('A', 'a1', 'p1'), 1);
    final up = await stock.reserve(device: 'A', requests: hold('a1', 'p1', 2));
    expect(up.single.ok, isFalse);
    expect(stock.heldBy('A', 'a1', 'p1'), 1);
  });

  test('two carts of one device are two holds', () async {
    await stockOf('p1', 1);
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 1));
    final second = await stock.reserve(device: 'A', requests: hold('a2', 'p1', 1));
    expect(second.single.ok, isFalse);
  });

  test('unmanaged, custom and unknown items are free: accepted, nothing '
      'held', () async {
    await stockOf('free', 0, managed: false);
    final out = await stock.reserve(
      device: 'A',
      requests: [
        const LanHoldRequest('a1', 'free', 9),
        const LanHoldRequest('a1', 'custom-or-unknown', 3),
      ],
    );
    expect(out.every((o) => o.ok), isTrue);
    expect(out.map((o) => o.held), [9, 3]);
    expect(stock.holds, isEmpty);
  });

  test('2D items hold area', () async {
    await ProductsFunc().productBox.put(
      'sheet',
      product('sheet')
        ..quantityType = 2
        ..widthDimension = 2
        ..heightDimension = 3
        ..quantity = 2,
    );
    expect(
      (await stock.reserve(device: 'A', requests: hold('a1', 'sheet', 12)))
          .single
          .ok,
      isTrue,
    );
    expect(
      (await stock.reserve(device: 'B', requests: hold('b1', 'sheet', 0.5)))
          .single
          .ok,
      isFalse,
    );
  });

  test('an atomic batch changes nothing if one product is short; a '
      'per-product batch holds what fits', () async {
    await stockOf('p1', 5);
    await stockOf('p2', 3);
    final requests = [
      const LanHoldRequest('a1', 'p1', 1),
      const LanHoldRequest('a1', 'p2', 5),
    ];
    final atomic = await stock.reserve(
      device: 'A',
      requests: requests,
      atomic: true,
    );
    expect(atomic.map((o) => o.ok), [true, false]);
    expect(atomic.map((o) => o.held), [0, 0]);
    expect(atomic[1].available, 3);
    expect(stock.holds, isEmpty);

    final each = await stock.reserve(device: 'A', requests: requests);
    expect(each.map((o) => o.ok), [true, false]);
    expect(stock.totals(), {'p1': 1});
  });

  test('release one cart, or the whole device', () async {
    await stockOf('p1', 5);
    await stock.reserve(
      device: 'A',
      requests: [
        const LanHoldRequest('a1', 'p1', 1),
        const LanHoldRequest('a2', 'p1', 2),
      ],
    );
    await stock.reserve(device: 'B', requests: hold('b1', 'p1', 1));
    await stock.release(device: 'A', cart: 'a1');
    expect(stock.totals(), {'p1': 3});
    await stock.release(device: 'A');
    expect(stock.totals(), {'p1': 1});
  });

  test('a re-sync replaces the device\'s holds; what doesn\'t fit is held '
      'in part and reported', () async {
    await stockOf('p1', 3);
    await stockOf('p2', 5);
    await stock.reserve(
      device: 'A',
      requests: [
        const LanHoldRequest('a1', 'p1', 1),
        const LanHoldRequest('a2', 'p2', 1),
      ],
    );
    await stock.reserve(device: 'B', requests: hold('b1', 'p1', 1));

    final out = await stock.sync(
      device: 'A',
      requests: [
        const LanHoldRequest('a1', 'p1', 3),
        const LanHoldRequest('a3', 'p2', 2),
      ],
    );
    expect(out[0].ok, isFalse);
    expect(out[0].held, 2);
    expect(out[0].available, 2);
    expect(out[1].ok, isTrue);
    expect(stock.heldBy('A', 'a1', 'p1'), 2);
    expect(stock.heldBy('A', 'a2', 'p2'), 0, reason: 'not in the new set');
    expect(stock.heldBy('A', 'a3', 'p2'), 2);
    expect(stock.heldBy('B', 'b1', 'p1'), 1, reason: 'other devices stay');
  });

  test('a device\'s holds go the grace after its last socket closes; a '
      'reconnect keeps them; the server\'s own device never expires',
      () async {
    await stockOf('p1', 5);
    stock.deviceOnline('A');
    stock.deviceOnline('A');
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 2));
    await stock.reserve(device: 'desk', requests: hold('d1', 'p1', 1));
    expect(timers.active.where((t) => t.duration == grace), isEmpty);

    // One of two sockets closes: still connected.
    stock.deviceOffline('A');
    expect(timers.active.where((t) => t.duration == grace), isEmpty);
    // The last one: the grace starts; a reconnect cancels it.
    stock.deviceOffline('A');
    expect(timers.active.where((t) => t.duration == grace), hasLength(1));
    stock.deviceOnline('A');
    await timers.fire(grace);
    expect(stock.heldBy('A', 'a1', 'p1'), 2);

    stock.deviceOffline('A');
    await timers.fire(grace);
    expect(stock.heldBy('A', 'a1', 'p1'), 0);
    expect(stock.heldBy('desk', 'd1', 'p1'), 1);
    // The release is announced.
    events.clear();
    await stock.reserve(device: 'B', requests: hold('b1', 'p1', 1));
    await timers.fire(batch);
    expect(events.single, {
      'type': 'stock',
      'reserved': {'p1': 2},
    });
  });

  test('a device holding stock without a socket gets the grace from its '
      'last call', () async {
    await stockOf('p1', 5);
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 2));
    expect(timers.active.where((t) => t.duration == grace), hasLength(1));
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 3));
    // Rescheduled: still one.
    expect(timers.active.where((t) => t.duration == grace), hasLength(1));
    await timers.fire(grace);
    expect(stock.holds, isEmpty);
  });

  test('a restarted server reloads its holds; other devices get the grace '
      'from boot', () async {
    await stockOf('p1', 5);
    stock.deviceOnline('A');
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 2));
    await stock.reserve(device: 'desk', requests: hold('d1', 'p1', 1));
    await stock.stop();

    timers = FakeTimers();
    stock = make()..start();
    expect(stock.totals(), {'p1': 3});
    expect(timers.active.where((t) => t.duration == grace), hasLength(1));
    stock.deviceOnline('A');
    await timers.fire(grace);
    expect(stock.heldBy('A', 'a1', 'p1'), 2);

    stock.deviceOffline('A');
    await timers.fire(grace);
    expect(stock.totals(), {'p1': 1});
  });

  test('checkout applies the sale and releases its cart in one step, once '
      'per receipt and cart; items not here yet are left out', () async {
    await stockOf('p1', 10);
    stock.deviceOnline('A');
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 3));
    final updates = [
      {'hiveUuid': 'q1', 'itemUuid': 'p1', 'quantity': 3, 'isIncrement': false},
      {'hiveUuid': 'q2', 'itemUuid': 'p-new', 'quantity': 1, 'isIncrement': false},
    ];

    var out = await stock.checkout(
      device: 'A',
      cart: 'a1',
      receiptUuid: 'a1',
      updates: updates,
    );
    expect(ProductsFunc().productBox.get('p1')!.quantity, 7);
    expect(stock.heldBy('A', 'a1', 'p1'), 0);
    expect(out!.done.map((e) => e.hiveUuid), ['q1']);
    expect(out.notHereYet.map((e) => e.hiveUuid), ['q2']);
    // Queued for Supabase once, by the server.
    expect(QuantityUpdateFunc().getQuantitiesUpdate(), hasLength(1));

    // A repeat changes nothing.
    out = await stock.checkout(
      device: 'A',
      cart: 'a1',
      receiptUuid: 'a1',
      updates: updates,
    );
    expect(ProductsFunc().productBox.get('p1')!.quantity, 7);
    expect(out!.done.map((e) => e.hiveUuid), ['q1']);
    expect(QuantityUpdateFunc().getQuantitiesUpdate(), hasLength(1));
    // The same delta later through the normal RPC: dropped as applied.
    await deltas.handle(
      PgRequest(
        table: 'update_product_quantities',
        op: PgOp.rpc,
        body: {
          'updates': [updates.first],
        },
      ),
    );
    expect(ProductsFunc().productBox.get('p1')!.quantity, 7);

    // An edit of that receipt, in its own cart: its own checkout.
    await stock.reserve(device: 'A', requests: hold('e1', 'p1', 2));
    await stock.checkout(
      device: 'A',
      cart: 'e1',
      receiptUuid: 'a1',
      updates: [
        {'hiveUuid': 'q3', 'itemUuid': 'p1', 'quantity': 2, 'isIncrement': false},
      ],
    );
    expect(ProductsFunc().productBox.get('p1')!.quantity, 5);
    expect(stock.holds, isEmpty);
  });

  test('the RPCs: shapes, the session\'s device, and bad input', () async {
    await stockOf('p1', 2);
    final onA = principalOn('A');

    final reserve = await stock.handle(
      PgRequest(
        table: LanConstants.stockReserveRpc,
        op: PgOp.rpc,
        body: {
          'holds': [
            {'cart_id': 'a1', 'product_uuid': 'p1', 'quantity': 3},
          ],
        },
      ),
      onA,
    );
    expect(reserve.body, {
      'holds': [
        {
          'cart_id': 'a1',
          'product_uuid': 'p1',
          'wanted': 3.0,
          'held': 0.0,
          'ok': false,
          'available': 2.0,
        },
      ],
      'reserved': {'p1': 0.0},
    });

    final sync = await stock.handle(
      PgRequest(
        table: LanConstants.stockSyncRpc,
        op: PgOp.rpc,
        body: {
          'holds': [
            {'cart_id': 'a1', 'product_uuid': 'p1', 'quantity': 3},
          ],
        },
      ),
      onA,
    );
    final syncBody = sync.body as Map<String, dynamic>;
    expect((syncBody['conflicts'] as List).single['held'], 2.0);
    expect(syncBody['reserved'], {'p1': 2.0});

    final checkout = await stock.handle(
      PgRequest(
        table: LanConstants.stockCheckoutRpc,
        op: PgOp.rpc,
        body: {
          'cart_id': 'a1',
          'receipt_uuid': 'a1',
          'updates': [
            {'hiveUuid': 'q1', 'itemUuid': 'p1', 'quantity': 2, 'isIncrement': false},
          ],
        },
      ),
      onA,
    );
    expect(checkout.body, {
      'done': ['q1'],
      'not_here_yet': <String>[],
      'reserved': <String, double>{},
    });

    Future<PgResponse> call(String name, Object body, [LanPrincipal? p]) =>
        stock.handle(PgRequest(table: name, op: PgOp.rpc, body: body), p ?? onA);
    final bad = isA<PgError>().having((e) => e.code, 'code', '22P02');
    await expectLater(
      call(LanConstants.stockReserveRpc, {'holds': [{'cart_id': 'a1'}]}),
      throwsA(bad),
    );
    await expectLater(
      call(LanConstants.stockCheckoutRpc, {
        'cart_id': 'a1',
        'receipt_uuid': 'r',
        'updates': [
          {'itemUuid': 'p1', 'quantity': 1, 'isIncrement': false},
        ],
      }),
      throwsA(bad),
    );
    await expectLater(
      call(LanConstants.stockReleaseRpc, const {}, principalOn('')),
      throwsA(isA<PgError>().having((e) => e.code, 'code', 'LAN07')),
    );
  });

  test('one lock: a reserve, and a LAN write to products, wait for a delta '
      'batch (or a pull) in progress', () async {
    await stockOf('p1', 5);
    final engine = HiveRestEngine(
      tables: lanTables(shopId: () => 7)
          .where((t) => t.name == 'products')
          .toList(),
      shopId: () => 7,
      manageDepartments: () => false,
      rpcs: deltas,
      stock: stock,
    );
    addTearDown(engine.dispose);
    final release = Completer<void>();
    final batch = deltas.runExclusive(() => release.future);

    var reserved = false;
    var written = false;
    final reserve = stock
        .reserve(device: 'A', requests: hold('a1', 'p1', 1))
        .then((_) => reserved = true);
    final write = engine
        .handle(
          PgRequest(
            table: 'products',
            op: PgOp.update,
            body: {'name': 'Renamed'},
            filters: const [PgFilter('uuid', PgFilterOp.eq, 'p1')],
          ),
          LanPrincipal(
            userId: 'staff-1',
            shopId: 7,
            role: 'Cashier',
            access: [Authorizations().updateProduct],
            departmentUuids: const [],
            isOwner: false,
            deviceId: 'A',
          ),
        )
        .then((_) => written = true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(reserved, isFalse);
    expect(written, isFalse);

    release.complete();
    await batch;
    await reserve;
    await write;
    expect(stock.heldBy('A', 'a1', 'p1'), 1);
    expect(ProductsFunc().productBox.get('p1')!.name, 'Renamed');
  });

  test('stock events: one per batch, with the changed products\' totals',
      () async {
    await stockOf('p1', 5);
    await stockOf('p2', 5);
    await stock.reserve(device: 'A', requests: hold('a1', 'p1', 1));
    await stock.reserve(device: 'B', requests: hold('b1', 'p1', 1));
    await stock.reserve(device: 'B', requests: hold('b1', 'p2', 2));
    expect(events, isEmpty);
    await timers.fire(batch);
    expect(events, [
      {
        'type': 'stock',
        'reserved': {'p1': 2.0, 'p2': 2.0},
      },
    ]);
  });
}

LanPrincipal principalOn(String device) => LanPrincipal(
  userId: 'staff-1',
  shopId: 7,
  role: 'Cashier',
  access: const [],
  departmentUuids: const [],
  isOwner: false,
  deviceId: device,
);
