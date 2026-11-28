import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_pull_cursors_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/sync/lan_invalidator.dart';
import 'package:stockall/services/lan/sync/lan_puller.dart';
import 'package:stockall/services/lan/sync/lan_supabase_reader.dart';

import 'helpers/lan_fixtures.dart';
import 'lan_stock_service_test.dart' show FakeTimers;

/// Invalidate events: the server's batches over a real
/// `LanServer` WebSocket, and a client's refreshes.
void main() {
  group('server', () {
    late LanServer server;
    late LanInvalidator invalidator;
    late HiveRestEngine engine;
    late WebSocket ws;
    late StreamIterator<dynamic> messages;
    late LanConnection connection;
    late HttpServer supabase;
    // The batch window runs on timers the test fires.
    final timers = FakeTimers();
    final tables = lanTables(shopId: () => 7)
        .where((t) => const {'products', 'categories'}.contains(t.name))
        .toList();

    setUpAll(() async {
      Hive.init(Directory.systemTemp.createTempSync('stockall_lan_inv').path);
      registerAllHiveAdapters();
      await ProductsFunc().init();
      await CategoryFunc().init();
      await LanAppliedDeltasFunc().init();
      await LanDeletedItemsFunc().init();
      await LanPullCursorsFunc().init();
      // Supabase for the pull: one product.
      supabase = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      supabase.listen((request) async {
        final rows = request.uri.pathSegments.last == 'products'
            ? [product('p-pulled').toJson(isIncludeQuantity: true)]
            : const [];
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(rows));
        await request.response.close();
      });

      final identity = LanTlsIdentity.generate();
      engine = HiveRestEngine(
        tables: tables,
        shopId: () => 7,
        manageDepartments: () => false,
      );
      server = LanServer(
        identity: identity,
        deviceId: 'desk-1',
        serverView: () => const {
          'shop_tag': 'tag',
          'epoch': 1,
          'server_device_id': 'desk-1',
          'cleared': false,
          'claimed_at': null,
        },
      );
      invalidator = LanInvalidator(
        tables: lanTables(shopId: () => 7), // every table, as served
        send: server.broadcast,
        timer: timers.create,
      );
      await server.start(ports: const [0]);
      invalidator.start();
      connection = (await LanConnection.open([
        LanEndpoint('127.0.0.1', server.port!),
      ], pin: identity.fingerprint))!;
      ws = await connection.openWebSocket();
      messages = StreamIterator(ws);
      expect(await messages.moveNext(), isTrue); // the `server` event
    });

    tearDownAll(() async {
      await invalidator.stop();
      await ws.close();
      connection.close();
      await server.stop();
      await engine.dispose();
      await supabase.close(force: true);
      await Hive.close();
    });

    /// Ends the batch window (after the box events arrive), then reads
    /// the event it sent.
    Future<Map<String, dynamic>> next() async {
      await Future<void>.delayed(Duration.zero);
      await timers.fire(LanConstants.invalidateBatch);
      expect(
        await messages.moveNext().timeout(const Duration(seconds: 3)),
        isTrue,
      );
      return jsonDecode(messages.current as String) as Map<String, dynamic>;
    }

    test('a burst of LAN writes is one event, sent after the burst', () async {
      final before = timers.timers.length;
      for (final id in ['p1', 'p2', 'p3']) {
        await engine.handle(
          PgRequest(
            table: 'products',
            op: PgOp.insert,
            body: product(id).toJson(isIncludeQuantity: true),
          ),
          principal(access: [Authorizations().addProduct]),
        );
      }
      await Future<void>.delayed(Duration.zero);
      // One window for the whole burst, not yet over.
      expect(timers.timers.length, before + 1);
      expect(timers.active.single.duration, LanConstants.invalidateBatch);
      final event = await next();
      expect(event, {
        'type': 'invalidate',
        'tables': ['products'],
      });
    });

    test('direct box writes (the server\'s own screens) of two tables: one '
        'event naming both', () async {
      await ProductsFunc().productBox.put('p9', product('p9'));
      await CategoryFunc().categoryBox.put(
        'cat-1',
        CategoryClass(
          name: 'Grains',
          shopId: 7,
          uuid: 'cat-1',
          departmentId: null,
          departmentName: null,
        ),
      );
      expect(await next(), {
        'type': 'invalidate',
        'tables': ['categories', 'products'],
      });
    });

    test('rows pulled from Supabase are announced too', () async {
      final puller = LanPuller(
        tables: tables,
        reader: LanSupabaseReader(
          restUrl: () => 'http://127.0.0.1:${supabase.port}/rest/v1',
          headers: () => const {},
          client: http.Client(),
        ),
        shopId: () => 7,
        exclusive: LanDeltaRpcs(
          rpcs: const [],
          applied: const HiveAppliedDeltas(),
        ).runExclusive,
        canPull: () => true,
      );
      await CategoryFunc().categoryBox.clear();
      expect((await next())['tables'], ['categories']);
      expect(await puller.fullPull('products'), isTrue);
      final event = await next();
      expect(event['tables'], ['products']);
      expect(ProductsFunc().productBox.containsKey('p-pulled'), isTrue);
    });
  });

  group('client', () {
    final refreshed = <String>[];
    var now = DateTime.utc(2026, 11, 26, 9);
    late FakeTimers timers;

    setUp(() {
      timers = FakeTimers();
      refreshed.clear();
      LanInvalidations().reset();
      LanInvalidations()
        ..refreshers = {
          for (final t in ['products', 'customers', 'categories'])
            t: () async => refreshed.add(t),
        }
        ..minGap = const Duration(milliseconds: 300)
        ..clock = (() => now)
        ..timer = timers.create;
    });

    tearDown(() => LanInvalidations().reset());

    test('every table is published; only mapped ones are refreshed',
        () async {
      final published = <Set<String>>[];
      final sub = LanInvalidations().stream.listen(published.add);
      addTearDown(sub.cancel);

      LanInvalidations().receive(['products', 'receipts']);
      await Future<void>.delayed(Duration.zero);

      expect(published, [
        {'products', 'receipts'},
      ]);
      expect(refreshed, ['products']);
    });

    test('a table is refreshed at most once per gap; changes inside the gap '
        'get one refresh at its end', () async {
      LanInvalidations().receive(['products']);
      await Future<void>.delayed(Duration.zero);
      expect(refreshed, ['products']);

      now = now.add(const Duration(milliseconds: 100));
      LanInvalidations().receive(['products']);
      LanInvalidations().receive(['products', 'customers']);
      await Future<void>.delayed(Duration.zero);
      // customers: never refreshed, so now; products: waits.
      expect(refreshed, ['products', 'customers']);

      // products waits for the rest of its gap, then refreshes.
      expect(
        timers.active.single.duration,
        const Duration(milliseconds: 200),
      );
      now = now.add(const Duration(milliseconds: 200));
      await timers.fire();
      expect(refreshed, ['products', 'customers', 'products']);

      // After the gap, at once again.
      now = now.add(const Duration(seconds: 1));
      LanInvalidations().receive(['products']);
      await Future<void>.delayed(Duration.zero);
      expect(refreshed, ['products', 'customers', 'products', 'products']);
    });

    test('after a reconnect every table counts as invalidated once',
        () async {
      final published = <Set<String>>[];
      final sub = LanInvalidations().stream.listen(published.add);
      addTearDown(sub.cancel);

      LanInvalidations().receiveAll();
      await Future<void>.delayed(Duration.zero);

      expect(published.single, containsAll(lanPullPlans.keys));
      expect(refreshed.toSet(), {'products', 'customers', 'categories'});
      expect(refreshed, hasLength(3));
    });

    test('a failed refresh is logged, not thrown', () async {
      LanInvalidations().refreshers = {
        'products': () async => throw StateError('offline'),
      };
      LanInvalidations().receive(['products']);
      // The failing refresh runs to its end (no error reaches the test).
      await Future<void>.delayed(Duration.zero);
    });
  });
}
