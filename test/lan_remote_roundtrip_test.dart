import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/lan_rest_handler.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A tiny in-memory `products` table: just enough PostgREST behaviour to
/// prove the wire format both ways. The Hive engine replaces it in the app.
class FakeProducts implements LanRestHandler {
  final rows = <Map<String, dynamic>>[];
  final rpcCalls = <Map<String, dynamic>>[];
  LanPrincipal? lastPrincipal;

  @override
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal) async {
    lastPrincipal = principal;
    if (request.op == PgOp.rpc) {
      rpcCalls.add(request.body as Map<String, dynamic>);
      final updates = (request.body as Map)['updates'] as List;
      return PgResponse(
        200,
        body: [
          for (final u in updates) {'hiveUuid': (u as Map)['hiveUuid']},
        ],
      );
    }
    if (request.table != 'products') throw PgError.unknownTable(request.table);
    switch (request.op) {
      case PgOp.insert:
        for (final row in request.rows) {
          if (rows.any((r) => r['uuid'] == row['uuid'])) {
            throw PgError.duplicate('products', 'uuid=${row['uuid']}');
          }
        }
        rows.addAll(request.rows);
        return pgWriteResponse(request, request.rows);
      case PgOp.select:
      case PgOp.count:
        var matched = rows.where((r) {
          for (final f in request.filters) {
            if (f.op != PgFilterOp.eq || '${r[f.column]}' != f.value) {
              return false;
            }
          }
          return true;
        }).toList();
        for (final o in request.order.reversed) {
          matched.sort((a, b) {
            final c = '${a[o.column]}'.compareTo('${b[o.column]}');
            return o.ascending ? c : -c;
          });
        }
        final total = matched.length;
        final start = request.offset ?? 0;
        final end = request.limit == null
            ? matched.length
            : (start + request.limit!).clamp(0, matched.length);
        matched = start >= matched.length ? [] : matched.sublist(start, end);
        return pgReadResponse(request, matched, total: total);
      default:
        throw const PgError(400, 'PGRST100', 'not in the fake');
    }
  }
}

void main() {
  late LanTlsIdentity identity;
  late LanServer server;
  late FakeProducts fake;
  late LanConnection connection;
  late SupabaseClient lan;

  setUpAll(() async {
    identity = LanTlsIdentity.generate();
    Hive.init(
      Directory.systemTemp.createTempSync('stockall_lan_roundtrip').path,
    );
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanShopKeysFunc().init();
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
    fake = FakeProducts()
      ..rows.addAll([
        {'uuid': 'p1', 'shop_id': 7, 'name': 'Rice'},
        {'uuid': 'p2', 'shop_id': 7, 'name': 'Beans'},
        {'uuid': 'p3', 'shop_id': 7, 'name': 'Oil'},
        {'uuid': 'x1', 'shop_id': 8, 'name': 'Other shop'},
      ]);
    server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 1},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
      rest: fake,
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
    lan = createLanRemote(
      connection: connection,
      token: login['token'] as String,
      deviceId: 'phone-1',
    );
  });

  tearDown(() async {
    RemoteRouter.useSupabase();
    await lan.dispose();
    connection.close();
    await server.stop();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('select with eq, order and range, as the providers write it',
      () async {
    final rows = await lan
        .from('products')
        .select()
        .eq('shop_id', 7)
        .order('name', ascending: true)
        .range(0, 1);

    expect(rows.map((r) => r['name']), ['Beans', 'Oil']);
    expect(fake.lastPrincipal!.userId, 'cashier');
  });

  test('count(exact), count(), single and maybeSingle', () async {
    final page = await lan
        .from('products')
        .select()
        .eq('shop_id', 7)
        .range(0, 0)
        .count(CountOption.exact);
    expect(page.data, hasLength(1));
    expect(page.count, 3);

    expect(await lan.from('products').count(), 4);

    final one = await lan.from('products').select().eq('uuid', 'p2').single();
    expect(one['name'], 'Beans');

    expect(
      await lan.from('products').select().eq('uuid', 'nope').maybeSingle(),
      isNull,
    );
    await expectLater(
      lan.from('products').select().eq('uuid', 'nope').single(),
      throwsA(
        isA<PostgrestException>().having((e) => e.code, 'code', 'PGRST116'),
      ),
    );
  });

  test('a duplicate insert throws PostgrestException 23505, as on Supabase',
      () async {
    await lan.from('products').insert({'uuid': 'p9', 'shop_id': 7});

    await expectLater(
      lan.from('products').insert({'uuid': 'p9', 'shop_id': 7}),
      throwsA(
        isA<PostgrestException>().having((e) => e.code, 'code', '23505'),
      ),
    );
    final created = await lan
        .from('products')
        .insert({'uuid': 'p10', 'shop_id': 7, 'name': 'Salt'})
        .select()
        .single();
    expect(created['name'], 'Salt');
  });

  test('rpc round-trips its params and result', () async {
    final result = await lan.rpc(
      'update_product_quantities',
      params: {
        'updates': [
          {'hiveUuid': 'h1', 'itemUuid': 'p1', 'quantity': 2},
        ],
      },
    );

    expect(result, [
      {'hiveUuid': 'h1'},
    ]);
    expect(fake.rpcCalls.single['updates'], hasLength(1));
  });

  test('without a valid session: PostgrestException PGRST301', () async {
    final stranger = createLanRemote(
      connection: connection,
      token: 'not-a-token',
      deviceId: 'phone-1',
    );
    addTearDown(stranger.dispose);

    await expectLater(
      stranger.from('products').select(),
      throwsA(
        isA<PostgrestException>().having((e) => e.code, 'code', 'PGRST301'),
      ),
    );
  });

  test('a table the handler does not know: PGRST205', () async {
    await expectLater(
      lan.from('nope').select(),
      throwsA(
        isA<PostgrestException>().having((e) => e.code, 'code', 'PGRST205'),
      ),
    );
  });

  test('the client fails over to another address mid-session', () async {
    final second = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 1},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
      rest: fake,
    );
    await second.start(ports: const [0]);
    addTearDown(second.stop);
    final both = (await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
      LanEndpoint('127.0.0.1', second.port!),
    ], pin: identity.fingerprint))!;
    addTearDown(both.close);
    final token = (await both.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': 'phone-2',
    }))['token'] as String;
    final client = createLanRemote(
      connection: both,
      token: token,
      deviceId: 'phone-2',
    );
    addTearDown(client.dispose);
    expect(await client.from('products').select().eq('uuid', 'p1'), hasLength(1));

    await server.stop();

    expect(await client.from('products').select().eq('uuid', 'p1'), hasLength(1));
    expect(both.current.port, second.port);
  });

  test('RemoteRouter: backend() is the LAN client only when switched on',
      () async {
    expect(RemoteRouter.usingLan, isFalse);
    RemoteRouter.debugUseLan(lan);
    expect(identical(backend(), lan), isTrue);
    expect(await backend().from('products').count(), 4);
    RemoteRouter.useSupabase();
    expect(RemoteRouter.usingLan, isFalse);
  });
}
