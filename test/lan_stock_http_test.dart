import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_own_holds_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_carts.dart';
import 'helpers/lan_fixtures.dart';
import 'lan_stock_service_test.dart' show FakeTimers;

/// Cart stock holds over a real `LanServer`: two signed-in devices,
/// the `lan_*` RPCs through the LAN `SupabaseClient`, `stock` events on
/// the WebSocket, and a device's holds going when its socket does.
const Duration grace = Duration(milliseconds: 300);

/// Waits for [done], checking often; fails after a while.
Future<void> until(bool Function() done) async {
  final end = DateTime.now().add(const Duration(seconds: 10));
  while (!done()) {
    if (DateTime.now().isAfter(end)) fail('timed out');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late FakeTimers timers;
  late LanTlsIdentity identity;
  late LanServer server;
  late LanStockService stock;
  late HiveRestEngine engine;
  late LanConnection connection;
  final clients = <String, SupabaseClient>{};
  final tokens = <String, String>{};

  setUpAll(() async {
    identity = LanTlsIdentity.generate();
    Hive.init(
      Directory.systemTemp.createTempSync('stockall_lan_stock_http').path,
    );
    registerAllHiveAdapters();
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanShopKeysFunc().init();
    await ProductsFunc().init();
    await QuantityUpdateFunc().init();
    await LanAppliedDeltasFunc().init();
    await LanDeletedItemsFunc().init();
    await LanStockHoldsFunc().init();
    await LanPendingCheckoutsFunc().init();
    await LanOwnHoldsFunc().init();
    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
      [
        TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Cashier',
          departmentUuids: const [],
          access: const ['Make Sale'],
        ),
      ],
      iterations: 1000,
    );
  });

  setUp(() async {
    timers = FakeTimers();
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 1);
    final deltas = LanDeltaRpcs(
      rpcs: lanDeltaRpcs(shopId: () => 7),
      applied: const HiveAppliedDeltas(),
    );
    LanServer? live;
    stock = LanStockService(
      exclusive: deltas.runExclusive,
      product: (uuid) => ProductsFunc().productBox.get(uuid),
      applyCheckout:
          (body) => deltas.applyHoldingLock(
            'update_product_quantities',
            body,
            skipUnknown: true,
          ),
      ownDeviceId: () => 'desk-1',
      send: (event) => live?.broadcast(event),
      grace: grace,
      eventBatch: const Duration(milliseconds: 20),
      // The grace runs on a timer the test fires; the event batch on a
      // real one.
      timer: (duration, callback) => duration == grace
          ? timers.create(duration, callback)
          : Timer(duration, callback),
    )..start();
    engine = HiveRestEngine(
      tables: const [],
      shopId: () => 7,
      manageDepartments: () => false,
      rpcs: deltas,
      stock: stock,
    );
    server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 1, 'cleared': false},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
      rest: engine,
      onDeviceOnline: stock.deviceOnline,
      onDeviceOffline: stock.deviceOffline,
    );
    await server.start(ports: const [0]);
    live = server;
    connection =
        (await LanConnection.open([
          LanEndpoint('127.0.0.1', server.port!),
        ], pin: identity.fingerprint))!;
    for (final device in ['phone-1', 'phone-2']) {
      final login = await connection.postJson('/v1/auth/login', {
        'email': 'ada@shop.test',
        'password': 'right',
        'device_id': device,
      });
      tokens[device] = login['token'] as String;
      clients[device] = createLanRemote(
        connection: connection,
        token: tokens[device]!,
        deviceId: device,
      );
    }
  });

  tearDown(() async {
    for (final c in clients.values) {
      await c.dispose();
    }
    clients.clear();
    await stock.stop();
    connection.close();
    await server.stop();
    await engine.dispose();
    await LanStockHoldsFunc().clearHolds();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  Future<Map<String, dynamic>> reserve(String device, double quantity) async =>
      await clients[device]!.rpc(
            LanConstants.stockReserveRpc,
            params: {
              'holds': [
                {
                  'cart_id': 'cart-$device',
                  'product_uuid': 'p1',
                  'quantity': quantity,
                },
              ],
            },
          )
          as Map<String, dynamic>;

  Future<WebSocket> socket(String device) => connection.openWebSocket(
    session: LanSessionHeaders(token: tokens[device]!, deviceId: device),
  );

  /// The next `stock` event on [events].
  Future<Map<String, dynamic>> nextStock(StreamIterator<dynamic> events) async {
    while (await events.moveNext().timeout(const Duration(seconds: 3))) {
      final event =
          jsonDecode(events.current as String) as Map<String, dynamic>;
      if (event['type'] == 'stock') return event;
    }
    throw StateError('socket closed');
  }

  test('the last unit over HTTP: one device holds it, the other is told '
      'what is left; holders see stock events', () async {
    final ws = await socket('phone-2');
    final events = StreamIterator(ws);
    addTearDown(ws.close);

    final first = await reserve('phone-1', 1);
    expect((first['holds'] as List).single['ok'], isTrue);
    expect(first['reserved'], {'p1': 1.0});
    expect(await nextStock(events), {
      'type': 'stock',
      'reserved': {'p1': 1.0},
    });

    final second = await reserve('phone-2', 1);
    final refused = (second['holds'] as List).single as Map<String, dynamic>;
    expect(refused['ok'], isFalse);
    expect(refused['held'], 0.0);
    expect(refused['available'], 0.0);
    // The holds are each device's own (from its session).
    expect(stock.heldBy('phone-1', 'cart-phone-1', 'p1'), 1);
  });

  test('a device whose socket closes loses its holds after the grace; '
      'others are told and can take the stock', () async {
    final watcher = await socket('phone-2');
    final events = StreamIterator(watcher);
    addTearDown(watcher.close);

    final holder = await socket('phone-1');
    await until(() => stock.connected['phone-1'] == 1);
    await reserve('phone-1', 1);
    expect(await nextStock(events), {
      'type': 'stock',
      'reserved': {'p1': 1.0},
    });

    await holder.close();
    await until(() => !stock.connected.containsKey('phone-1'));
    // Still held within the grace…
    expect(stock.heldBy('phone-1', 'cart-phone-1', 'p1'), 1);
    // …released after it, and announced.
    await timers.fire(grace);
    expect(stock.heldBy('phone-1', 'cart-phone-1', 'p1'), 0);
    expect(await nextStock(events), {
      'type': 'stock',
      'reserved': {'p1': 0.0},
    });
    final taken = await reserve('phone-2', 1);
    expect((taken['holds'] as List).single['ok'], isTrue);
  });

  test('checkout over HTTP: the sale applied and the cart released in one '
      'call; a repeat changes nothing', () async {
    await reserve('phone-1', 1);
    Future<Object?> checkout() => clients['phone-1']!.rpc(
      LanConstants.stockCheckoutRpc,
      params: {
        'cart_id': 'cart-phone-1',
        'receipt_uuid': 'cart-phone-1',
        'updates': [
          {
            'hiveUuid': 'q1',
            'itemUuid': 'p1',
            'quantity': 1,
            'isIncrement': false,
          },
        ],
      },
    );
    expect(await checkout(), {
      'done': ['q1'],
      'not_here_yet': <Object?>[],
      'reserved': <String, Object?>{},
    });
    expect(ProductsFunc().productBox.get('p1')!.quantity, 0);
    expect(stock.holds, isEmpty);

    await checkout();
    expect(ProductsFunc().productBox.get('p1')!.quantity, 0);
  });

  test('release: one cart or the whole device', () async {
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);
    await reserve('phone-1', 2);
    await clients['phone-1']!.rpc(
      LanConstants.stockReserveRpc,
      params: {
        'holds': [
          {'cart_id': 'other', 'product_uuid': 'p1', 'quantity': 1},
        ],
      },
    );
    await clients['phone-1']!.rpc(
      LanConstants.stockReleaseRpc,
      params: {'cart_id': 'other'},
    );
    expect(stock.totals(), {'p1': 2});
    await clients['phone-1']!.rpc(LanConstants.stockReleaseRpc, params: {});
    expect(stock.holds, isEmpty);
  });
  test('the device side over HTTP: a re-sync reports what another till '
      'holds; a checkout kept while the server was unreachable is sent '
      'later and releases', () async {
    final client = LanStockClient();
    var route = LanRoute.lanUp;
    final queue = <String, Map<String, dynamic>>{};
    var carts = [
      cart('c1', [line(product('p1'), 1)]),
    ];
    // As LanTransport.stockLink makes it for a connected client.
    final link = LanStockLink(
      call: (rpc, params) async {
        final res = await clients['phone-1']!.rpc(rpc, params: params);
        return Map<String, dynamic>.from(res as Map);
      },
    );
    client
      ..reset()
      ..deps = LanStockClientDeps(
        link: () => route == LanRoute.lanUp ? link : null,
        route: () => route,
        carts: () => carts,
        held: (p) => ProductsFunc().productBox.get(p)?.isManaged == true,
        queued: () => Map.of(queue),
        dropQueued:
            (uuids) async => queue.removeWhere((k, _) => uuids.contains(k)),
      );
    addTearDown(() async {
      client.reset();
      await LanPendingCheckoutsFunc().clearPending();
      await LanOwnHoldsFunc().clearOwnHolds();
    });

    await reserve('phone-2', 1);
    final reported = await client.resync();
    expect(reported.single.productUuid, 'p1');
    expect(reported.single.held, 0);
    expect(client.reservedElsewhere('p1'), 1);

    await clients['phone-2']!.rpc(LanConstants.stockReleaseRpc, params: {});
    await client.reconcile();
    expect(stock.heldBy('phone-1', 'c1', 'p1'), 1);

    // The sale is made with the server unreachable.
    route = LanRoute.lanDown;
    final before = client.queuedKeys();
    // (q1 was applied by an earlier test: a repeat would be dropped.)
    queue['q-device'] = {
      'hiveUuid': 'q-device',
      'itemUuid': 'p1',
      'quantity': 1,
      'isIncrement': false,
      'isStorage': false,
    };
    await client.checkout(
      cart: carts.single,
      receiptUuid: 'c1',
      queueBefore: before,
    );
    carts = [];
    expect(stock.heldBy('phone-1', 'c1', 'p1'), 1);

    route = LanRoute.lanUp;
    await client.retryPending();
    expect(ProductsFunc().productBox.get('p1')!.quantity, 0);
    expect(stock.holds, isEmpty);
    expect(queue, isEmpty);
    expect(client.pendingCheckouts, isEmpty);
  });
}
