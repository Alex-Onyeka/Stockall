import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_held_deltas.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/lan_rest_handler.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Accepts what the app sends: products (with duplicates refused), the
/// delta and online-only RPCs, and a forwarded table.
class AcceptingHandler implements LanRestHandler {
  final uuids = <String>{};

  @override
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal) async {
    switch (request.op) {
      case PgOp.rpc:
        return const PgResponse(200, body: <Object>[]);
      case PgOp.select:
      case PgOp.count:
        return pgReadResponse(request, const [], total: 0);
      case PgOp.insert:
      case PgOp.upsert:
        for (final row in request.rows) {
          if (!uuids.add('${request.table}:${row['uuid']}')) {
            throw PgError.duplicate(request.table, 'uuid');
          }
        }
        return pgWriteResponse(request, request.rows);
      case PgOp.update:
      case PgOp.delete:
        return pgWriteResponse(request, const []);
    }
  }
}

/// Plays Supabase for a replay: answers each request by its uuid.
class FakeSupabase {
  late HttpServer server;
  final received = <(String method, String path, String query, String body)>[];
  final headers = <Map<String, String>>[];
  final answers = <String, (int, Map<String, dynamic>?)>{};

  String get restUrl => 'http://127.0.0.1:${server.port}/rest/v1';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      received.add((
        request.method,
        request.uri.path,
        request.uri.query,
        body,
      ));
      final h = <String, String>{};
      request.headers.forEach((k, v) => h[k] = v.join(','));
      headers.add(h);
      final key = answers.keys.firstWhere(
        (k) => body.contains(k) || request.uri.query.contains(k),
        orElse: () => '',
      );
      final (status, json) = answers[key] ?? (201, null);
      request.response.statusCode = status;
      if (json != null) {
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(json));
      }
      await request.response.close();
    });
  }
}

LanHandoff held(
  String method,
  String path, {
  String query = '',
  Object? body,
  LanHandoffKind kind = LanHandoffKind.rest,
  String server = 'desk-1',
  int epoch = 3,
  int? serverTime = 100,
  DateTime? handedAt,
}) => LanHandoff(
  kind: kind,
  method: method,
  path: path,
  query: query,
  headers: const {'content-type': 'application/json', 'prefer': 'return=minimal'},
  body: body == null ? null : jsonEncode(body),
  serverDeviceId: server,
  epoch: epoch,
  serverTime: serverTime,
  handedAt: handedAt ?? DateTime.now().toUtc(),
);

Future<void> hold(LanHandoff h) =>
    LanHandoffsFunc().add(jsonEncode(h.toJson()));

void main() {
  late LanTlsIdentity identity;
  late LanServer server;
  late LanConnection connection;
  late SupabaseClient lan;
  late String token;
  var queuesEmpty = false;
  var serverMs = 1000;

  setUpAll(() async {
    identity = LanTlsIdentity.generate();
    Hive.init(Directory.systemTemp.createTempSync('stockall_handoffs').path);
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanShopKeysFunc().init();
    await LanHandoffsFunc().init();
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
    await LanHandoffsFunc().clearHandoffs();
    queuesEmpty = false;
    serverMs = 1000;
    server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 3},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
      rest: AcceptingHandler(),
      handoffStatus: LanHandoffStatusSource(
        queuesEmpty: () => queuesEmpty,
        clock: () => DateTime.fromMillisecondsSinceEpoch(serverMs),
      ),
    );
    await server.start(ports: const [0]);
    connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: identity.fingerprint))!;
    final login = await connection.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': 'phone-1',
    });
    token = login['token'] as String;
    lan = createLanRemote(
      connection: connection,
      token: token,
      deviceId: 'phone-1',
      onAnswer: (request, body, response) => LanHandoffs().recordAnswer(
        method: request.method,
        url: request.url,
        headers: request.headers,
        body: body,
        status: response.statusCode,
        answerHeaders: response.headers,
        serverDeviceId: 'desk-1',
        epoch: 3,
      ),
    );
  });

  tearDown(() async {
    await lan.dispose();
    connection.close();
    await server.stop();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  Future<LanHandoffStatus> status() async => LanHandoffStatus.fromJson(
    await connection.getJson(
      '/v1/handoff/status',
      session: LanSessionHeaders(token: token, deviceId: 'phone-1'),
    ),
  )!;

  test('a write the server acknowledges is held, stamped with the server '
      'clock; reads, refusals, other RPCs and forwarded tables are not',
      () async {
    await lan.from('products').insert({'uuid': 'p1', 'shop_id': 7});
    await lan.from('products').select();
    await expectLater(
      lan.from('products').insert({'uuid': 'p1', 'shop_id': 7}),
      throwsA(isA<PostgrestException>().having((e) => e.code, 'code', '23505')),
    );
    serverMs = 2000;
    await lan
        .from('products')
        .update({'name': 'Rice', 'updated_at': '2026-11-02T08:00:00.000Z'})
        .eq('uuid', 'p1');
    serverMs = 3000;
    await lan.rpc(
      'update_product_quantities',
      params: {
        'updates': [
          {'hiveUuid': 'q1', 'itemUuid': 'p1', 'quantity': 1},
        ],
      },
    );
    await lan.rpc('get_this_month_subscription_payments');
    await lan.from('notifications').insert({'uuid': 'n1'});
    await lan.from('users').insert({'uuid': 'u1'});
    await lan.from('products').delete().eq('uuid', 'p1');

    final all = LanHandoffs().all().map((e) => e.$2).toList();
    expect(
      [for (final h in all) '${h.kind.name} ${h.method} ${h.path} ${h.query}'],
      [
        'rest POST products ',
        'rest PATCH products uuid=eq.p1',
        'delta POST rpc/update_product_quantities ',
        'rest DELETE products uuid=eq.p1',
      ],
    );
    expect(all.map((h) => h.serverTime), [1000, 2000, 3000, 3000]);
    expect(all.first.body, contains('"p1"'));
    expect(all.first.headers['content-type'], contains('application/json'));
    expect(all.first.headers.containsKey('authorization'), isFalse);
    expect(all.every((h) => h.isFrom('desk-1', 3)), isTrue);
  });

  test('the server\'s status ends the handoffs it synced through, and only '
      'its own', () async {
    await lan.from('products').insert({'uuid': 'p1', 'shop_id': 7});
    serverMs = 2000;
    await lan.from('products').insert({'uuid': 'p2', 'shop_id': 7});
    // From an earlier server record (another epoch): never ended here.
    await hold(held('POST', 'products', epoch: 2, serverTime: 10));

    // Queues not empty yet: nothing is known to be on Supabase.
    var s = await status();
    expect(s.serverDeviceId, 'desk-1');
    expect(s.epoch, 3);
    expect(s.syncedThrough, isNull);
    expect(await LanHandoffs().confirm(s), 0);

    serverMs = 2500;
    queuesEmpty = true;
    s = await status();
    expect(s.syncedThrough, 2500);
    queuesEmpty = false;
    serverMs = 3000;
    await lan.from('products').insert({'uuid': 'p3', 'shop_id': 7});

    expect(await LanHandoffs().confirm(s), 2);
    expect(
      LanHandoffs().all().map((e) => (e.$2.epoch, e.$2.serverTime)),
      [(2, 10), (3, 3000)],
    );
    // The server's queues are not empty again: it still says 2500.
    expect((await status()).syncedThrough, 2500);

    // Only for a signed-in member.
    await expectLater(
      connection.getJson('/v1/handoff/status'),
      throwsA(isA<LanHttpException>().having((e) => e.statusCode, 's', 401)),
    );
  });

  group('off the LAN: replay to Supabase', () {
    late FakeSupabase supabase;
    late LanHandoffTarget target;

    setUp(() async {
      supabase = FakeSupabase();
      await supabase.start();
      target = LanHandoffTarget(
        restUrl: supabase.restUrl,
        headers: const {'apikey': 'anon'},
        client: http.Client(),
        lastWriteWins: true,
      );
    });

    tearDown(() => supabase.server.close(force: true));

    test('oldest first: sent, already there and refused writes end; a '
        'missing dependency is kept; deltas wait; an outage stops the run',
        () async {
      supabase.answers
        ..['p2'] = (409, {'code': '23505', 'message': 'duplicate'})
        ..['r1'] = (409, {'code': '23503', 'message': 'no such product'})
        ..['bad'] = (400, {'code': '22P02', 'message': 'invalid'})
        ..['down'] = (503, {'message': 'unavailable'});
      await hold(held('POST', 'products', body: {'uuid': 'p1'}));
      await hold(held('POST', 'products', body: {'uuid': 'p2'}));
      await hold(
        held(
          'PATCH',
          'products',
          query: 'uuid=eq.p1',
          body: {'name': 'Rice', 'updated_at': '2026-11-02T08:00:00.000Z'},
        ),
      );
      await hold(held('POST', 'receipts', body: {'uuid': 'r1'}));
      await hold(
        held(
          'POST',
          'rpc/update_product_quantities',
          kind: LanHandoffKind.delta,
          body: {'updates': <Object>[]},
        ),
      );
      await hold(held('POST', 'products', body: {'uuid': 'bad'}));
      await hold(held('POST', 'products', body: {'uuid': 'down'}));
      await hold(held('POST', 'products', body: {'uuid': 'after'}));

      final result = await LanHandoffs().replay(target);

      expect(result.sent, 4);
      expect(result.kept, 2);
      expect(result.stopped, isTrue);
      // In order, the delta never sent, nothing after the outage.
      expect(
        [for (final r in supabase.received) '${r.$1} ${r.$2}'],
        [
          'POST /rest/v1/products',
          'POST /rest/v1/products',
          'PATCH /rest/v1/products',
          'POST /rest/v1/receipts',
          'POST /rest/v1/products',
          'POST /rest/v1/products',
        ],
      );
      expect(supabase.headers.first['apikey'], 'anon');
      expect(supabase.headers.first['prefer'], 'return=minimal');
      // Last write wins: the update only applies where Supabase is older.
      expect(
        Uri.splitQueryString(supabase.received[2].$3),
        {
          'uuid': 'eq.p1',
          'or': '(updated_at.is.null,updated_at.lt."2026-11-02T08:00:00.000Z")',
        },
      );
      final left = LanHandoffs().all().map((e) => e.$2).toList();
      expect(left.map((h) => h.body), [
        '{"uuid":"r1"}',
        '{"updates":[]}',
        '{"uuid":"down"}',
        '{"uuid":"after"}',
      ]);
      expect(left.first.attempts, 1);
    });

    test('an insert of a row deleted here since is never sent again; a '
        'batch insert sends only the rows still there (D7)', () async {
      final deleted = {'products:p-gone', 'products:b-gone'};
      final handoffs = LanHandoffs(
        wasDeleted: (table, uuid) => deleted.contains('$table:$uuid'),
      );
      await hold(held('POST', 'products', body: {'uuid': 'p-gone'}));
      await hold(
        held(
          'POST',
          'products',
          body: [
            {'uuid': 'b-kept'},
            {'uuid': 'b-gone'},
          ],
        ),
      );
      // Not an insert: sent as it is (Supabase ignores it for a deleted
      // row).
      await hold(
        held(
          'PATCH',
          'products',
          query: 'uuid=eq.p-gone',
          body: {'name': 'Rice'},
        ),
      );
      await hold(held('POST', 'customers', body: {'uuid': 'c1'}));

      final result = await handoffs.replay(target);

      expect(result.sent, 4);
      expect(result.stopped, isFalse);
      expect(
        [for (final r in supabase.received) '${r.$1} ${r.$2} ${r.$4}'],
        [
          'POST /rest/v1/products [{"uuid":"b-kept"}]',
          'PATCH /rest/v1/products {"name":"Rice"}',
          'POST /rest/v1/customers {"uuid":"c1"}',
        ],
      );
      expect(handoffs.all(), isEmpty);
    });

    test('writes refused for permission (P8): never ended by a LAN '
        'server\'s status; a refused-only run sends just them', () async {
      await hold(held('POST', 'products', body: {'uuid': 'acked'}));
      await hold(
        held(
          'DELETE',
          'products',
          query: 'uuid=in.(p9)',
          kind: LanHandoffKind.refused,
          serverTime: null,
        ),
      );
      // Everything desk-1 acknowledged reached Supabase: the refused write
      // (no LAN server took it) stays.
      expect(
        await LanHandoffs().confirm(
          const LanHandoffStatus(
            serverDeviceId: 'desk-1',
            epoch: 3,
            syncedThrough: 5000,
          ),
        ),
        1,
      );
      expect(LanHandoffs().refused(), hasLength(1));

      await hold(held('POST', 'products', body: {'uuid': 'later'}));
      final result = await LanHandoffs().replay(target, refusedOnly: true);
      expect(result.sent, 1);
      expect(result.kept, 1);
      expect(
        supabase.received.map((r) => (r.$1, r.$2, r.$3)),
        [('DELETE', '/rest/v1/products', 'uuid=in.(p9)')],
      );
      expect(LanHandoffs().refused(), isEmpty);
      expect(LanHandoffs().all(), hasLength(1));
    });

    test('a server the shop moved away from (P8b): only its REST writes go '
        'to the current server, guarded with a bare timestamp; its deltas '
        'end when it hands over', () async {
      await hold(
        held(
          'PATCH',
          'products',
          query: 'uuid=eq.p1',
          body: {'name': 'Rice', 'updated_at': '2026-11-02T08:00:00.000Z'},
          server: 'old-desk',
          epoch: 2,
        ),
      );
      await hold(
        held(
          'POST',
          'rpc/update_product_quantities',
          kind: LanHandoffKind.delta,
          server: 'old-desk',
          epoch: 2,
        ),
      );
      // The current server's own, an older epoch of it, and a refused one.
      await hold(held('POST', 'products', body: {'uuid': 'mine'}, server: 'new-desk', epoch: 2));
      await hold(held('POST', 'products', body: {'uuid': 'later'}, server: 'old-desk', epoch: 3));
      await hold(held('DELETE', 'products', kind: LanHandoffKind.refused, server: 'old-desk', epoch: 2));

      bool superseded(LanHandoff h) =>
          h.kind == LanHandoffKind.rest &&
          LanHandoffs.isSuperseded(h, 'new-desk', 2);
      final lanTarget = LanHandoffTarget(
        restUrl: supabase.restUrl,
        headers: const {},
        client: http.Client(),
        lastWriteWins: true,
        quoteGuard: false,
      );
      final result = await LanHandoffs().replay(lanTarget, only: superseded);
      expect(result.sent, 1);
      expect(result.kept, 4);
      expect(supabase.received.single.$1, 'PATCH');
      expect(
        Uri.splitQueryString(supabase.received.single.$3)['or'],
        '(updated_at.is.null,updated_at.lt.2026-11-02T08:00:00.000Z)',
      );

      expect(await LanHandoffs().endDeltasFrom('old-desk', 2), 1);
      expect(
        LanHandoffs().all().map((e) => (e.$2.serverDeviceId, e.$2.kind)),
        [
          ('new-desk', LanHandoffKind.rest),
          ('old-desk', LanHandoffKind.rest),
          ('old-desk', LanHandoffKind.refused),
        ],
      );
    });

    test('P8c: the status\'s handed-over servers end their deltas; the '
        'held changes are listed by item, change, sale or entry, never sent',
        () async {
      await hold(
        held(
          'POST',
          'rpc/lan_checkout',
          kind: LanHandoffKind.delta,
          server: 'old-desk',
          epoch: 2,
          body: {
            'receipt_uuid': '5a1e0000-0000-4000-8000-000000000001',
            'updates': [
              {'hiveUuid': 'q1', 'itemUuid': 'p1', 'quantity': 2, 'isIncrement': false},
            ],
          },
        ),
      );
      await hold(
        held(
          'POST',
          'rpc/update_customer_account',
          kind: LanHandoffKind.delta,
          server: 'old-desk',
          epoch: 1,
          body: {
            'updates': [
              {'hiveUuid': '7f3c2a11-aaaa', 'customerUuid': 'c1', 'amount': -500, 'isIncrement': true},
            ],
          },
        ),
      );
      final deltas = heldDeltasOf(LanHandoffs().deltasFor('old-desk'));
      final rows = heldDeltaRows(
        deltas,
        nameOf: (d) => d.itemUuid == 'p1' ? 'Rice' : null,
      );
      expect([for (final r in rows) r.sublist(0, 3)], [
        ['Rice (Product)', '-2', 'Sale 5a1e0000'],
        ['c1 (Customer account)', '-500', 'Change 7f3c2a11'],
      ]);

      // new-desk says old-desk handed over its epoch 2 queue: only that
      // epoch's delta ends.
      final status = LanHandoffStatus.fromJson({
        'server_device_id': 'new-desk',
        'epoch': 2,
        'synced_through': null,
        'handed_over': [
          {'device': 'old-desk', 'epoch': 2},
        ],
      })!;
      expect(await LanHandoffs().confirm(status), 1);
      expect(
        LanHandoffs().deltasFor('old-desk').map((h) => h.epoch),
        [1],
      );
      expect(supabase.received, isEmpty);
    });

    test('a delta waiting too long is reported', () async {
      await hold(
        held(
          'POST',
          'rpc/update_customer_account',
          kind: LanHandoffKind.delta,
          handedAt: DateTime.now().toUtc().subtract(const Duration(days: 4)),
        ),
      );
      await hold(held('POST', 'rpc/update_customer_account',
          kind: LanHandoffKind.delta));
      expect(LanHandoffs().staleDeltas(), 1);
    });
  });
}
