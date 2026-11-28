import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Every query form the app uses, captured from postgrest-dart itself (a
/// `SupabaseClient` over a mock HTTP client), then parsed by the server.
void main() {
  late SupabaseClient client;
  late http.Request captured;
  var respondWith = http.Response('[]', 200);

  setUpAll(() {
    client = SupabaseClient(
      'https://lan.test',
      'key',
      accessToken: () async => 'token',
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          respondWith.body,
          respondWith.statusCode,
          headers: respondWith.headers,
          request: request,
        );
      }),
    );
  });

  tearDownAll(() async {
    await client.dispose();
  });

  setUp(() {
    respondWith = http.Response('[]', 200);
  });

  PgRequest parsed() {
    final path = captured.url.path;
    expect(path, startsWith('/rest/v1/'));
    return parsePgRequest(
      method: captured.method,
      path: path.substring('/rest/v1/'.length),
      query: captured.url.queryParametersAll,
      headers: {
        for (final e in captured.headers.entries) e.key.toLowerCase(): e.value,
      },
      body: captured.body.isEmpty ? null : jsonDecode(captured.body),
    );
  }

  test('select, eq, order asc (catalogue lists)', () async {
    await client
        .from('products')
        .select()
        .eq('shop_id', 7)
        .order('name', ascending: true);
    final r = parsed();

    expect(r.table, 'products');
    expect(r.op, PgOp.select);
    expect(r.columns, isNull);
    expect(r.filters, [const PgFilter('shop_id', PgFilterOp.eq, '7')]);
    expect(r.order, [
      const PgOrder('name', ascending: true, nullsFirst: false),
    ]);
  });

  test('gt updated_at, order, range (incremental sync)', () async {
    final since = DateTime.utc(2026, 11, 1).toIso8601String();
    await client
        .from('products')
        .select()
        .eq('shop_id', 7)
        .gt('updated_at', since)
        .order('updated_at', ascending: true)
        .range(1000, 1999);
    final r = parsed();

    expect(r.filters, [
      const PgFilter('shop_id', PgFilterOp.eq, '7'),
      PgFilter('updated_at', PgFilterOp.gt, since),
    ]);
    expect(r.offset, 1000);
    expect(r.limit, 1000);
  });

  test('a gte/lt date window, order desc (receipts)', () async {
    await client
        .from('receipts')
        .select()
        .eq('shop_id', 7)
        .gte('created_date', '2026-11-01T00:00:00.000')
        .lt('created_date', '2026-12-01T00:00:00.000')
        .order('created_at', ascending: false)
        .range(0, 1000);
    final r = parsed();

    expect(r.filters, [
      const PgFilter('shop_id', PgFilterOp.eq, '7'),
      const PgFilter('created_date', PgFilterOp.gte, '2026-11-01T00:00:00.000'),
      const PgFilter('created_date', PgFilterOp.lt, '2026-12-01T00:00:00.000'),
    ]);
    expect(r.order, [
      const PgOrder('created_at', ascending: false, nullsFirst: false),
    ]);
    expect(r.offset, 0);
    expect(r.limit, 1001);
  });

  test('inFilter with strings (quoted, commas kept) and numbers', () async {
    await client
        .from('products')
        .select()
        .inFilter('uuid', ['a', 'b,c', 'd e']);
    expect(parsed().filters, [
      const PgFilter('uuid', PgFilterOp.inList, ['a', 'b,c', 'd e']),
    ]);

    await client.from('receipts').select().inFilter('shop_id', [3, 7]);
    expect(parsed().filters, [
      const PgFilter('shop_id', PgFilterOp.inList, ['3', '7']),
    ]);
  });

  test('contains on an array, eq on a bool (shops of an employee)', () async {
    await client
        .from('shops')
        .select()
        .contains('employees', ['user-1'])
        .eq('is_allowed_by_subscription', true);

    expect(parsed().filters, [
      const PgFilter('employees', PgFilterOp.contains, ['user-1']),
      const PgFilter('is_allowed_by_subscription', PgFilterOp.eq, 'true'),
    ]);
  });

  test('or with is.null (orders with a balance)', () async {
    await client
        .from('orders')
        .select()
        .eq('shop_id', 7)
        .or('balance.gt.0,balance.is.null');
    final r = parsed();

    expect(r.filters, [const PgFilter('shop_id', PgFilterOp.eq, '7')]);
    expect(r.orGroups, [
      [
        const PgFilter('balance', PgFilterOp.gt, '0'),
        const PgFilter('balance', PgFilterOp.isValue, null),
      ],
    ]);
  });

  test('a column list, maybeSingle on GET, single, limit', () async {
    await client
        .from('users')
        .select('user_id, email')
        .eq('email', 'a@b.co')
        .maybeSingle();
    var r = parsed();
    expect(r.columns, ['user_id', 'email']);
    // postgrest-dart reads a list for maybeSingle on GET.
    expect(r.single, isFalse);

    respondWith = http.Response('{"uuid":"x"}', 200);
    await client.from('products').select().eq('uuid', 'x').single();
    r = parsed();
    expect(r.single, isTrue);

    respondWith = http.Response('[]', 200);
    await client.from('app_version').select().limit(1);
    expect(parsed().limit, 1);
  });

  test('count() is HEAD; count(exact) on a select is a header', () async {
    respondWith = http.Response('', 200, headers: {'content-range': '*/5'});
    final n = await client.from('products').count();
    expect(n, 5);
    var r = parsed();
    expect(r.op, PgOp.count);
    expect(r.countExact, isTrue);

    respondWith = http.Response(
      '[]',
      200,
      headers: {'content-range': '*/0'},
    );
    await client
        .from('receipts')
        .select()
        .eq('shop_id', 7)
        .count(CountOption.exact);
    r = parsed();
    expect(r.op, PgOp.select);
    expect(r.countExact, isTrue);
  });

  test('insert one, insert many, insert then select single', () async {
    respondWith = http.Response('', 201);
    await client.from('products').insert({'uuid': 'p1', 'name': 'Rice'});
    var r = parsed();
    expect(r.op, PgOp.insert);
    expect(r.rows, [
      {'uuid': 'p1', 'name': 'Rice'},
    ]);
    expect(r.returnRepresentation, isFalse);

    await client.from('products').insert([
      {'uuid': 'p1'},
      {'uuid': 'p2', 'name': 'Beans'},
    ]);
    r = parsed();
    expect(r.rows.map((e) => e['uuid']), ['p1', 'p2']);

    respondWith = http.Response('{"uuid":"p3"}', 201);
    await client.from('products').insert({'uuid': 'p3'}).select().single();
    r = parsed();
    expect(r.returnRepresentation, isTrue);
    expect(r.single, isTrue);
  });

  test('upsert with onConflict, update and delete with filters', () async {
    respondWith = http.Response('', 201);
    await client
        .from('customers')
        .upsert({'uuid': 'c1', 'name': 'Ada'}, onConflict: 'uuid');
    var r = parsed();
    expect(r.op, PgOp.upsert);
    expect(r.onConflict, 'uuid');
    expect(r.ignoreDuplicates, isFalse);

    respondWith = http.Response('', 204);
    await client.from('products').update({'name': 'Rice 2'}).eq('uuid', 'p1');
    r = parsed();
    expect(r.op, PgOp.update);
    expect(r.body, {'name': 'Rice 2'});
    expect(r.filters, [const PgFilter('uuid', PgFilterOp.eq, 'p1')]);

    await client.from('products').delete().eq('uuid', 'p1');
    r = parsed();
    expect(r.op, PgOp.delete);
    expect(r.filters, [const PgFilter('uuid', PgFilterOp.eq, 'p1')]);
  });

  test('rpc with params', () async {
    await client.rpc(
      'update_product_quantities',
      params: {
        'updates': [
          {'hiveUuid': 'h1', 'itemUuid': 'p1', 'quantity': 2},
        ],
      },
    );
    final r = parsed();

    expect(r.op, PgOp.rpc);
    expect(r.table, 'update_product_quantities');
    expect((r.body as Map)['updates'], hasLength(1));
  });

  test('anything outside the subset is a 400 PGRST100', () {
    Matcher bad = throwsA(
      isA<PgError>()
          .having((e) => e.status, 'status', 400)
          .having((e) => e.code, 'code', 'PGRST100'),
    );
    PgRequest parse(String query, {String method = 'GET', Object? body}) {
      return parsePgRequest(
        method: method,
        path: 'products',
        query: Uri(query: query).queryParametersAll,
        headers: const {},
        body: body,
      );
    }

    expect(() => parse('name=like.*rice*'), bad);
    expect(() => parse('select=*,category(*)'), bad);
    expect(() => parse('order=name.sideways'), bad);
    expect(() => parse('uuid=in.a,b'), bad);
    expect(() => parse('offset=-1'), bad);
    expect(() => parse('', method: 'PATCH'), bad);
    expect(() => parse('', method: 'POST', body: 'text'), bad);
    expect(
      () => parsePgRequest(
        method: 'GET',
        path: '../secret',
        query: const {},
        headers: const {},
      ),
      bad,
    );
  });

  test('responses: pages, counts, single, and the 0-row maybeSingle', () {
    const read = PgRequest(
      table: 'products',
      op: PgOp.select,
      countExact: true,
      offset: 10,
    );
    final page = pgReadResponse(read, [
      {'a': 1},
      {'a': 2},
    ], total: 40);
    expect(page.status, 200);
    expect(page.headers['content-range'], '10-11/40');
    expect(pgReadResponse(read, [], total: 0).headers['content-range'], '*/0');

    const one = PgRequest(table: 'products', op: PgOp.select, single: true);
    expect(pgReadResponse(one, [{'a': 1}]).body, {'a': 1});
    final none = pgReadResponse(one, []);
    expect(none.status, 406);
    expect((none.body as Map)['code'], 'PGRST116');
    expect((none.body as Map)['details'], contains('Results contain 0 rows'));

    const write = PgRequest(table: 'products', op: PgOp.insert);
    expect(pgWriteResponse(write, [{'a': 1}]).status, 201);
    expect(pgWriteResponse(write, [{'a': 1}]).body, isNull);
  });
}
