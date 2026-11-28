import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_own_holds_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';
import 'package:stockall/services/remote/remote_client.dart';

import 'helpers/lan_carts.dart';
import 'helpers/lan_fixtures.dart';

/// The device side of cart stock holds: what carts need
/// (`cartHolds`), and `LanStockClient` against a real `LanStockService`
/// (answers JSON-encoded, as over the wire).
void main() {
  group('cartHolds', () {
    bool all(String _) => true;

    test('per (cart, product): units and duplicate lines add up; void lines '
        'and other products don\'t', () {
      final p = productWithPack('p1', packOf: 6);
      final pack = line(p, 2)..unitUuid = 'pack-p1';
      final holds = cartHolds([
        cart('c1', [
          line(p, 1),
          pack,
          line(p, 5, isVoid: true),
          line(product('p2'), 3),
        ]),
        cart('c2', [line(p, 4)]),
      ], held: all);
      expect(holds, {
        (cart: 'c1', product: 'p1'): 13.0,
        (cart: 'c1', product: 'p2'): 3.0,
        (cart: 'c2', product: 'p1'): 4.0,
      });
    });

    test('2D items hold area: each size its own line, one hold', () {
      final s = sheet('glass');
      final custom =
          line(s, 2)
            ..widthDimension = 2
            ..heightDimension = 1.5;
      final whole = line(s, 1);
      final holds = cartHolds([
        cart('c1', [custom, whole]),
      ], held: all);
      expect(custom.getStockQuantity(), 6);
      expect(
        holds[(cart: 'c1', product: 'glass')],
        closeTo(6 + whole.getStockQuantity(), 1e-9),
      );
      expect(whole.getStockQuantity(), 12);
    });

    test('drafts and orders hold nothing; custom/unmanaged items are left '
        'to the server\'s rule (filtered by held)', () {
      final p = product('p1');
      final holds = cartHolds([
        cart('draft', [line(p, 1)], type: 4),
        cart('order', [line(p, 1)], type: 3),
        cart('invoice', [line(p, 2)], type: 2),
        cart('receipt', [line(product('custom'), 2)]),
      ], held: (uuid) => uuid != 'custom');
      expect(holds, {(cart: 'invoice', product: 'p1'): 2.0});
    });

    test('a receipt edit holds only what it adds over its original lines', () {
      final p = product('p1');
      final q = product('p2');
      final original = [line(p, 3), line(q, 2)];
      final edit = cart(
        'edit',
        [line(p, 5), line(q, 1)],
        receiptEdit: 'r-1',
        original: original,
      );
      expect(cartHolds([edit], held: all), {
        (cart: 'edit', product: 'p1'): 2.0,
      });
      expect(cartHoldFor(edit, 'p1', 5), 2);
      expect(cartHoldFor(edit, 'p2', 1), 0);
      // As it opens (same lines): nothing.
      expect(
        cartHolds([
          cart('open', [line(p, 3)], receiptEdit: 'r-1', original: original),
        ], held: all),
        isEmpty,
      );
    });

    test('cartNeedOf leaves out the line a change replaces', () {
      final p = product('p1');
      final a = line(p, 2, uuid: 'a');
      final c = cart('c1', [a, line(p, 3, uuid: 'b')]);
      expect(cartNeedOf(c, 'p1'), 5);
      expect(cartNeedOf(c, 'p1', without: a, plus: 4), 7);
      expect(cartNeedOf(c, 'p1', without: line(p, 9, uuid: 'a')), 3);
    });

    test('holdDiff: what changed, with 0 to release', () {
      expect(
        holdDiff(
          {(cart: 'c', product: 'a'): 2, (cart: 'c', product: 'b'): 1},
          {(cart: 'c', product: 'a'): 2, (cart: 'c', product: 'z'): 4},
        ),
        {(cart: 'c', product: 'b'): 1.0, (cart: 'c', product: 'z'): 0.0},
      );
    });
  });

  group('LanStockClient', () {
    late LanDeltaRpcs deltas;
    late LanStockService server;
    late List<TempCart> carts;
    late Map<String, Map<String, dynamic>> queue;
    late LanRoute route;
    late int calls;
    late int changes;
    late List<List<LanStockConflict>> conflicts;
    StreamSubscription<List<LanStockConflict>>? sub;
    final client = LanStockClient();

    Future<void> stockOf(String uuid, double quantity) =>
        ProductsFunc().productBox.put(uuid, product(uuid)..quantity = quantity);

    /// The server's answers as they come over the wire.
    LanStockLink remote(String device) => LanStockLink(
      call: (rpc, params) async {
        calls++;
        final res = await server.call(
          rpc,
          jsonDecode(jsonEncode(params)) as Map<String, dynamic>,
          device: device,
        );
        return jsonDecode(jsonEncode(res)) as Map<String, dynamic>;
      },
    );

    LanStockClientDeps deps({LanStockLink? link}) {
      final l = link ?? remote('phone');
      return LanStockClientDeps(
        link:
            () => switch (route) {
              LanRoute.lanUp || LanRoute.server => l,
              _ => null,
            },
        route: () => route,
        carts: () => carts,
        held: (p) => ProductsFunc().productBox.get(p)?.isManaged == true,
        queued: () => Map.of(queue),
        dropQueued:
            (uuids) async => queue.removeWhere((k, _) => uuids.contains(k)),
        onChanged: () => changes++,
        debounce: const Duration(milliseconds: 5),
        pinFor: const Duration(milliseconds: 60),
      );
    }

    LanStockService makeServer() => LanStockService(
      exclusive: deltas.runExclusive,
      product: (uuid) => ProductsFunc().productBox.get(uuid),
      applyCheckout:
          (body) => deltas.applyHoldingLock(
            'update_product_quantities',
            body,
            skipUnknown: true,
          ),
      ownDeviceId: () => 'desk',
    );

    Future<void> startClient({LanStockLink? link}) async {
      await client.stop();
      client
        ..reset()
        ..deps = deps(link: link)
        ..start();
      await sub?.cancel();
      sub = client.conflicts.listen(conflicts.add);
    }

    Map<String, dynamic> update(String hiveUuid, String item, double q) => {
      'hiveUuid': hiveUuid,
      'itemUuid': item,
      'quantity': q,
      'isIncrement': false,
      'isStorage': false,
    };

    setUpAll(() async {
      Hive.init(
        Directory.systemTemp.createTempSync('stockall_lan_stock_client').path,
      );
      registerAllHiveAdapters();
      await ProductsFunc().init();
      await QuantityUpdateFunc().init();
      await LanAppliedDeltasFunc().init();
      await LanDeletedItemsFunc().init();
      await LanStockHoldsFunc().init();
      await LanPendingCheckoutsFunc().init();
      await LanOwnHoldsFunc().init();
    });

    setUp(() async {
      await ProductsFunc().productBox.clear();
      await QuantityUpdateFunc().quantityUpdateBox.clear();
      await LanAppliedDeltasFunc().appliedDeltasBox.clear();
      await LanStockHoldsFunc().clearHolds();
      await LanPendingCheckoutsFunc().clearPending();
      await LanOwnHoldsFunc().clearOwnHolds();
      deltas = LanDeltaRpcs(
        rpcs: lanDeltaRpcs(shopId: () => 7),
        applied: const HiveAppliedDeltas(),
      );
      server = makeServer()..start();
      carts = [];
      queue = {};
      route = LanRoute.lanUp;
      calls = 0;
      changes = 0;
      conflicts = [];
      await startClient();
    });

    tearDown(() async {
      await sub?.cancel();
      sub = null;
      await client.stop();
      client.reset();
      await server.stop();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('the last units: refused with what is left; the totals tell what '
        'other tills hold', () async {
      await stockOf('p1', 4);
      await server.reserve(
        device: 'other',
        requests: [const LanHoldRequest('o1', 'p1', 3)],
      );
      final c = cart('c1', []);

      var check = await client.hold(c, 'p1', 2);
      expect(check.ok, isFalse);
      expect(check.available, 1);
      expect(client.reservedElsewhere('p1'), 3);

      check = await client.hold(c, 'p1', 1);
      expect(check.ok, isTrue);
      expect(server.heldBy('phone', 'c1', 'p1'), 1);
      expect(client.own, {(cart: 'c1', product: 'p1'): 1.0});
      // Its own hold isn't "elsewhere".
      expect(client.reservedElsewhere('p1'), 3);
      expect(changes, greaterThan(0));

      // A decrease asks nothing (the safety net lowers it after saving).
      final before = calls;
      expect((await client.hold(c, 'p1', 0)).ok, isTrue);
      expect(calls, before);
    });

    test('an edit holds only its increase; a refusal reports what its lines '
        'can total', () async {
      await stockOf('p1', 1);
      final original = [line(product('p1'), 3)];
      final edit = cart('e1', [], receiptEdit: 'r-1', original: original);
      expect((await client.hold(edit, 'p1', 4)).ok, isTrue);
      expect(server.heldBy('phone', 'e1', 'p1'), 1);
      final refused = await client.hold(edit, 'p1', 5);
      expect(refused.ok, isFalse);
      expect(refused.available, 4);
    });

    test(
      'the safety net: a removed line, a cleared cart and a switch to a '
      'draft release; an unasked increase that doesn\'t fit is reported',
      () async {
        await stockOf('p1', 5);
        await stockOf('p2', 5);
        final p1 = line(product('p1'), 2);
        final c = cart('c1', [p1, line(product('p2'), 1)]);
        carts = [c];
        await client.reconcile();
        expect(server.totals(), {'p1': 2.0, 'p2': 1.0});

        c.cartItems.remove(p1);
        client.schedule();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(server.totals(), {'p2': 1.0});

        c.cartItemTypeIndex = 4;
        await client.reconcile();
        expect(server.holds, isEmpty);

        await server.reserve(
          device: 'other',
          requests: [const LanHoldRequest('o1', 'p2', 4)],
        );
        c
          ..cartItemTypeIndex = 1
          ..cartItems.add(line(product('p2'), 2));
        await client.reconcile();
        await Future<void>.delayed(Duration.zero);
        expect(conflicts.single.single.productUuid, 'p2');
        expect(conflicts.single.single.available, 1);
        expect(server.heldBy('phone', 'c1', 'p2'), 0);
      },
    );

    test(
      'a hold just given isn\'t lowered before its change is saved',
      () async {
        await stockOf('p1', 5);
        final c = cart('c1', []);
        carts = [c];
        expect((await client.hold(c, 'p1', 3)).ok, isTrue);
        // The cart isn't saved yet: the safety net keeps the hold…
        await client.reconcile();
        expect(server.heldBy('phone', 'c1', 'p1'), 3);
        // …until its pin lapses without the change.
        await Future<void>.delayed(const Duration(milliseconds: 120));
        expect(server.heldBy('phone', 'c1', 'p1'), 0);
      },
    );

    test('holdMany: all or nothing for a type switch; per product for add '
        'many', () async {
      await stockOf('p1', 1);
      await stockOf('p2', 5);
      final draft = cart('d1', [], type: 4);
      var refused = await client.holdMany(
        draft,
        {'p1': 2, 'p2': 2},
        atomic: true,
        asHolding: true,
      );
      expect(refused.map((c) => c.productUuid), ['p1']);
      expect(server.holds, isEmpty);
      expect(client.own, isEmpty);

      refused = await client.holdMany(cart('c1', []), {'p1': 2, 'p2': 2});
      expect(refused.map((c) => c.productUuid), ['p1']);
      expect(server.totals(), {'p2': 2.0});
    });

    test('re-sync on connect: holds what fits, reports the rest, and takes '
        'the server\'s totals', () async {
      await stockOf('p1', 3);
      carts = [
        cart('c1', [line(product('p1'), 2)]),
        cart('c2', [line(product('p1'), 2)]),
      ];
      await server.reserve(
        device: 'other',
        requests: [const LanHoldRequest('o1', 'p1', 0.5)],
      );
      final reported = await client.resync();
      expect(reported.single.cartId, 'c2');
      expect(reported.single.held, 0.5);
      expect(conflicts.single, hasLength(1));
      expect(server.heldBy('phone', 'c1', 'p1'), 2);
      expect(client.own, {
        (cart: 'c1', product: 'p1'): 2.0,
        (cart: 'c2', product: 'p1'): 0.5,
      });
      expect(client.reservedElsewhere('p1'), 0.5);
    });

    test('a connect asks for a re-sync twice (the connection, then the '
        'route): the second joins the first, so one call and one report',
        () async {
      await stockOf('p1', 3);
      carts = [
        cart('c1', [line(product('p1'), 4)]),
      ];
      final before = calls;
      final first = client.resync();
      final second = client.resync();
      final (a, b) = (await first, await second);
      expect(identical(a, b), isTrue);
      expect(calls - before, 1);
      expect(conflicts.single.single.held, 3);
      // A later re-sync (another connect) runs again.
      await client.resync();
      expect(calls - before, 2);
    });

    test('a checkout while the server is unreachable stays pending over a '
        'restart; on reconnect its holds are kept, then it is sent and '
        'releases', () async {
      await stockOf('p1', 5);
      final c = cart('c1', [line(product('p1'), 2)]);
      carts = [c];
      await client.reconcile();
      expect(server.heldBy('phone', 'c1', 'p1'), 2);

      // The server goes; the sale is made and its cart deleted.
      route = LanRoute.lanDown;
      final before = client.queuedKeys();
      queue['q1'] = update('q1', 'p1', 2);
      await client.checkout(cart: c, receiptUuid: 'c1', queueBefore: before);
      carts = [];
      expect(client.pendingCheckouts, ['c1']);

      // The app restarts…
      await startClient();
      expect(client.own, {(cart: 'c1', product: 'p1'): 2.0});
      // …and the server lost every hold meanwhile (it restarted too).
      await server.release(device: 'phone');
      expect(server.holds, isEmpty);

      route = LanRoute.lanUp;
      final reported = await client.resync();
      expect(reported, isEmpty);
      // Sent: applied once, the cart released, the queue entry gone.
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(server.holds, isEmpty);
      expect(client.pendingCheckouts, isEmpty);
      expect(queue, isEmpty);
      expect(client.own, isEmpty);

      // Sending it again changes nothing.
      await LanPendingCheckoutsFunc().put(
        'c1',
        jsonEncode({
          'cart_id': 'c1',
          'receipt_uuid': 'c1',
          'updates': [update('q1', 'p1', 2)],
          'holds': <String, double>{},
        }),
      );
      queue['q1'] = update('q1', 'p1', 2);
      await client.retryPending();
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
    });

    test('a pending checkout only sends changes still queued here (one sent '
        'to Supabase off the LAN is never applied again)', () async {
      await stockOf('p1', 5);
      final c = cart('c1', [line(product('p1'), 2)]);
      carts = [c];
      await client.reconcile();
      route = LanRoute.lanDown;
      final before = client.queuedKeys();
      queue['q1'] = update('q1', 'p1', 2);
      await client.checkout(cart: c, receiptUuid: 'c1', queueBefore: before);
      carts = [];
      // Sent to Supabase meanwhile (off the LAN).
      queue.clear();

      route = LanRoute.lanUp;
      await client.retryPending();
      expect(ProductsFunc().productBox.get('p1')!.quantity, 5);
      expect(server.holds, isEmpty);
      expect(client.pendingCheckouts, isEmpty);
    });

    test('a checkout the server answers at once: applied and released; items '
        'it doesn\'t have yet stay queued', () async {
      await stockOf('p1', 5);
      final c = cart('c1', [line(product('p1'), 2)]);
      carts = [c];
      await client.reconcile();
      final before = client.queuedKeys();
      queue['q1'] = update('q1', 'p1', 2);
      queue['q2'] = update('q2', 'new-item', 1);
      await client.checkout(cart: c, receiptUuid: 'c1', queueBefore: before);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(queue.keys, ['q2']);
      expect(server.holds, isEmpty);
      expect(client.pendingCheckouts, isEmpty);
    });

    test('logout releases every hold of the device', () async {
      await stockOf('p1', 5);
      carts = [
        cart('c1', [line(product('p1'), 1)]),
        cart('c2', [line(product('p1'), 1)]),
      ];
      await client.reconcile();
      expect(server.totals(), {'p1': 2.0});
      await client.releaseAll();
      expect(server.holds, isEmpty);
      expect(client.own, isEmpty);
      expect(LanOwnHoldsFunc().all(), isEmpty);
    });

    test(
      'off the LAN nothing is asked and nothing is elsewhere; with the '
      'server unreachable a change is allowed on the cached totals',
      () async {
        await stockOf('p1', 1);
        await server.reserve(
          device: 'other',
          requests: [const LanHoldRequest('o1', 'p1', 1)],
        );
        await client.resync();
        expect(client.reservedElsewhere('p1'), 1);

        route = LanRoute.lanDown;
        final down = await client.hold(cart('c1', []), 'p1', 1);
        expect(down.ok, isTrue);
        expect(down.unreachable, isTrue);
        expect(client.reservedElsewhere('p1'), 1);

        route = LanRoute.offLan;
        final before = calls;
        expect((await client.hold(cart('c1', []), 'p1', 1)).ok, isTrue);
        expect(calls, before);
        expect(client.reservedElsewhere('p1'), 0);
      },
    );

    test('an item the server doesn\'t have yet is free, and asked again '
        'until it is held', () async {
      final c = cart('c1', [line(product('p1'), 2)]);
      carts = [c];
      // Known here (managed), not on the server yet.
      final localOnly = LanStockClientDeps(
        link: () => remote('phone'),
        route: () => route,
        carts: () => carts,
        held: (_) => true,
        queued: () => queue,
        dropQueued: (_) async {},
      );
      await client.stop();
      client
        ..reset()
        ..deps = localOnly
        ..start();
      await client.reconcile();
      expect(server.holds, isEmpty);
      expect(client.own, isEmpty);

      await stockOf('p1', 5);
      await client.reconcile();
      expect(server.heldBy('phone', 'c1', 'p1'), 2);
    });

    test('the server\'s own till: the same holds in process; other tills\' '
        'holds read directly; checkout releases its cart', () async {
      await stockOf('p1', 3);
      route = LanRoute.server;
      await startClient(
        link: LanStockLink(
          inProcess: true,
          call: (rpc, params) => server.call(rpc, params, device: 'desk'),
          reservedElsewhere: (p) => server.reservedElsewhere(p, 'desk'),
        ),
      );
      await server.reserve(
        device: 'phone',
        requests: [const LanHoldRequest('x', 'p1', 2)],
      );
      final c = cart('c1', []);
      expect((await client.hold(c, 'p1', 2)).ok, isFalse);
      expect((await client.hold(c, 'p1', 1)).ok, isTrue);
      expect(server.heldBy('desk', 'c1', 'p1'), 1);
      expect(client.reservedElsewhere('p1'), 2);

      queue['q1'] = update('q1', 'p1', 1);
      await client.checkout(cart: c, receiptUuid: 'c1', queueBefore: {});
      expect(server.heldBy('desk', 'c1', 'p1'), 0);
      expect(client.pendingCheckouts, isEmpty);
      // The server's own sale is already in its stock: nothing applied.
      expect(ProductsFunc().productBox.get('p1')!.quantity, 3);
      expect(queue.keys, ['q1']);
    });
  });
}
