import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';

class RecordingProxy implements LanProxy {
  final forwarded = <PgRequest>[];
  final otherShops = <Set<int>>[];

  @override
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  ) async {
    forwarded.add(request);
    this.otherShops.add(otherShops);
    return const PgResponse(
      200,
      body: [
        {'proxied': true},
      ],
    );
  }
}

PgRequest select(
  String table, {
  List<PgFilter> filters = const [],
  List<List<PgFilter>> or = const [],
  List<PgOrder> order = const [],
  List<String>? columns,
  int? offset,
  int? limit,
  bool count = false,
  bool single = false,
}) {
  return PgRequest(
    table: table,
    op: PgOp.select,
    filters: filters,
    orGroups: or,
    order: order,
    columns: columns,
    offset: offset,
    limit: limit,
    countExact: count,
    single: single,
  );
}

PgFilter f(String column, PgFilterOp op, Object? value) =>
    PgFilter(column, op, value);

void main() {
  final products = <TempProductClass>[];
  final receipts = <TempMainReceipt>[];
  final productChanges = StreamController<Object?>.broadcast();
  var manageDepartments = false;
  var online = false;
  late RecordingProxy proxy;
  late HiveRestEngine engine;

  List<Map<String, dynamic>> rows(PgResponse r) {
    expect(r.status, 200, reason: '${r.body}');
    return (r.body as List).cast<Map<String, dynamic>>();
  }

  setUp(() {
    manageDepartments = false;
    online = false;
    proxy = RecordingProxy();
    products
      ..clear()
      ..addAll([
        product('p1', name: 'Rice', updatedAt: t0, department: 'd1'),
        product('p2', name: 'Beans', updatedAt: t0.add(const Duration(days: 1))),
        product(
          'p3',
          name: 'Oil',
          updatedAt: t0.add(const Duration(days: 2)),
          department: 'd2',
        ),
        product('p4', name: 'Salt', departments: ['d2', 'd1']),
        product('x1', shopId: 8, name: 'Other shop'),
      ]);
    receipts
      ..clear()
      ..addAll([
        for (var day = 0; day < 10; day++)
          receipt(
            'r$day',
            t0.add(Duration(days: day)),
            department: day.isEven ? 'd1' : 'd2',
          ),
        receipt('x-r', t0, shopId: 8),
      ]);
    engine = HiveRestEngine(
      tables: [
        productsTable(() => products, changes: () => productChanges.stream),
        receiptsTable(() => receipts),
        ordersTable(() => [order('o1', balance: 5), order('o2'), order('o3', balance: 0)]),
      ],
      shopId: () => 7,
      manageDepartments: () => manageDepartments,
      isOnline: () => online,
      proxy: proxy,
    );
  });

  group('accessor parity with toJson', () {
    // Every registered column must read what toJson sends under that key,
    // or a filter would mean something different on the LAN.
    void check<T>(LanTable<T> table, T row) {
      final json = table.toJson(row);
      for (final entry in table.columns.entries) {
        expect(
          json.containsKey(entry.key),
          isTrue,
          reason: '${table.name}.${entry.key} is not a toJson key',
        );
        final fromAccessor = entry.value.get(row);
        final fromJson = json[entry.key];
        switch (entry.value.type) {
          case LanColumnType.timestamp:
            expect(
              (fromAccessor as DateTime?)?.microsecondsSinceEpoch,
              fromJson == null
                  ? null
                  : DateTime.parse(fromJson as String).microsecondsSinceEpoch,
              reason: '${table.name}.${entry.key}',
            );
          case LanColumnType.textArray:
            expect(fromAccessor ?? const [], fromJson ?? const []);
          default:
            expect(fromAccessor, fromJson, reason: '${table.name}.${entry.key}');
        }
      }
    }

    test('all six tables', () {
      // UTC instants so a local-time toIso8601String can't hide a shift.
      check(productsTable(() => []), product('p1', department: 'd1'));
      check(receiptsTable(() => []), receipt('r1', t0, balance: 2));
      check(invoicesTable(() => []), invoice('i1', t0));
      check(ordersTable(() => []), order('o1', balance: 3));
      check(customersTable(() => []), customer('c1'));
      check(expensesTable(() => []), expense('e1'));
    });
  });

  test('eq shop_id, order name asc, range: the catalogue page', () async {
    final page = rows(
      await engine.handle(
        select(
          'products',
          filters: [f('shop_id', PgFilterOp.eq, '7')],
          order: [const PgOrder('name', ascending: true, nullsFirst: false)],
          offset: 1,
          limit: 2,
          count: true,
        ),
        principal(),
      ),
    );

    expect(page.map((p) => p['name']), ['Oil', 'Rice']);
  });

  test('count header: total before paging', () async {
    final r = await engine.handle(
      select(
        'products',
        filters: [f('shop_id', PgFilterOp.eq, '7')],
        offset: 1,
        limit: 2,
        count: true,
      ),
      principal(),
    );
    expect(r.headers['content-range'], '1-2/4');

    final head = await engine.handle(
      const PgRequest(table: 'products', op: PgOp.count, countExact: true),
      principal(),
    );
    expect(head.headers['content-range'], '*/4');
  });

  test('gt updated_at (incremental sync) through the date index', () async {
    final changed = rows(
      await engine.handle(
        select(
          'products',
          filters: [
            f('shop_id', PgFilterOp.eq, '7'),
            f('updated_at', PgFilterOp.gt, t0.toIso8601String()),
          ],
          order: [
            const PgOrder('updated_at', ascending: true, nullsFirst: false),
          ],
        ),
        principal(),
      ),
    );

    expect(changed.map((p) => p['uuid']), ['p2', 'p3']);
  });

  test('a receipts window: gte inclusive, lt exclusive, newest first',
      () async {
    final window = rows(
      await engine.handle(
        select(
          'receipts',
          filters: [
            f('shop_id', PgFilterOp.eq, '7'),
            f(
              'created_at',
              PgFilterOp.gte,
              t0.add(const Duration(days: 2)).toIso8601String(),
            ),
            f(
              'created_at',
              PgFilterOp.lt,
              t0.add(const Duration(days: 5)).toIso8601String(),
            ),
          ],
          order: [
            const PgOrder('created_at', ascending: false, nullsFirst: false),
          ],
        ),
        principal(),
      ),
    );

    expect(window.map((r) => r['uuid']), ['r4', 'r3', 'r2']);
  });

  test('a timestamp without a zone is read as UTC, like Supabase', () async {
    final naive = rows(
      await engine.handle(
        select(
          'receipts',
          filters: [f('created_at', PgFilterOp.lt, '2026-11-02T00:00:00')],
        ),
        principal(),
      ),
    );
    expect(naive.map((r) => r['uuid']), ['r0']);
  });

  test('inFilter, or with is.null, column projection', () async {
    final picked = rows(
      await engine.handle(
        select(
          'products',
          filters: [
            f('uuid', PgFilterOp.inList, ['p1', 'p3', 'x1', 'nope']),
          ],
          columns: ['uuid', 'name'],
        ),
        principal(),
      ),
    );
    // x1 belongs to shop 8: never served locally.
    expect(picked, [
      {'uuid': 'p1', 'name': 'Rice'},
      {'uuid': 'p3', 'name': 'Oil'},
    ]);

    final owing = rows(
      await engine.handle(
        select(
          'orders',
          filters: [f('shop_id', PgFilterOp.eq, '7')],
          or: [
            [
              f('balance', PgFilterOp.gt, '0'),
              f('balance', PgFilterOp.isValue, null),
            ],
          ],
        ),
        principal(),
      ),
    );
    expect(owing.map((o) => o['uuid']), ['o1', 'o2']);
  });

  test('single and maybeSingle shapes', () async {
    final one = await engine.handle(
      select(
        'products',
        filters: [f('uuid', PgFilterOp.eq, 'p2')],
        single: true,
      ),
      principal(),
    );
    expect((one.body as Map)['name'], 'Beans');

    final none = await engine.handle(
      select(
        'products',
        filters: [f('uuid', PgFilterOp.eq, 'nope')],
        single: true,
      ),
      principal(),
    );
    expect(none.status, 406);
    expect((none.body as Map)['code'], 'PGRST116');
  });

  group('shop scope', () {
    PgRequest shops(PgFilter filter) => select('receipts', filters: [filter]);

    test('offline: another shop gives nothing; a mix gives this shop only',
        () async {
      expect(
        rows(
          await engine.handle(
            shops(f('shop_id', PgFilterOp.eq, '8')),
            principal(),
          ),
        ),
        isEmpty,
      );
      final mixed = rows(
        await engine.handle(
          shops(f('shop_id', PgFilterOp.inList, ['7', '8'])),
          principal(),
        ),
      );
      expect(mixed, hasLength(10));
      expect(mixed.every((r) => r['shop_id'] == 7), isTrue);
      expect(proxy.forwarded, isEmpty);
    });

    test('online: a query naming another shop goes to Supabase', () async {
      online = true;

      final r = rows(
        await engine.handle(
          shops(f('shop_id', PgFilterOp.inList, ['7', '8'])),
          principal(),
        ),
      );

      expect(r, [
        {'proxied': true},
      ]);
      expect(proxy.forwarded.single.table, 'receipts');
      expect(proxy.otherShops.single, {8});

      // This shop only: answered locally even when online.
      expect(
        rows(
          await engine.handle(
            shops(f('shop_id', PgFilterOp.eq, '7')),
            principal(),
          ),
        ),
        hasLength(10),
      );
      expect(proxy.forwarded, hasLength(1));
    });
  });

  group('department scope matches the app (D17)', () {
    // The app filters on the device with
    // DepartmentProvider.departmentRecordVisible for the current
    // department; a user's devices can pick any of the user's departments.
    // So the server must return exactly the union of what the app shows
    // over those choices: no less (the app would lose rows), no more.
    late HiveRestEngine scoped;
    final productRows = [
      product('pa', department: 'd1'),
      product('pb', department: 'd2'),
      product('pm', departments: ['d2', 'd1']),
      product('pn'),
    ];
    final receiptRows = [
      receipt('ra', t0, department: 'd1'),
      receipt('rb', t0, department: 'd2'),
      receipt('rn', t0),
    ];
    final customerRows = [
      customer('ca', department: 'd1'),
      customer('cb', department: 'd2'),
      customer('cn', department: null),
    ];

    setUp(() {
      manageDepartments = true;
      scoped = HiveRestEngine(
        tables: [
          productsTable(() => productRows),
          receiptsTable(() => receiptRows),
          customersTable(() => customerRows),
        ],
        shopId: () => 7,
        manageDepartments: () => manageDepartments,
      );
    });

    Future<List<String>> visible(String table, LanPrincipal who) async {
      final r = rows(await scoped.handle(select(table), who));
      return [for (final row in r) row['uuid'] as String];
    }

    final viewAll = principal(access: [Authorizations().viewAllDepartments]);
    final inD1 = principal(departments: ['d1']);
    final inBoth = principal(departments: ['d1', 'd2']);
    final unassigned = principal();

    test('departments off: everyone sees everything', () async {
      manageDepartments = false;
      for (final who in [viewAll, inD1, unassigned]) {
        expect(await visible('products', who), ['pa', 'pb', 'pm', 'pn']);
        expect(await visible('receipts', who), ['ra', 'rb', 'rn']);
      }
    });

    test('"View All Departments" sees everything', () async {
      expect(await visible('products', viewAll), ['pa', 'pb', 'pm', 'pn']);
      expect(await visible('receipts', viewAll), ['ra', 'rb', 'rn']);
      expect(await visible('customers', viewAll), ['ca', 'cb', 'cn']);
    });

    test('staff in a department see their department; records in none '
        'only where the app shares them (products, customers)', () async {
      expect(await visible('products', inD1), ['pa', 'pm', 'pn']);
      expect(await visible('customers', inD1), ['ca', 'cn']);
      expect(await visible('receipts', inD1), ['ra']);
      expect(await visible('receipts', inBoth), ['ra', 'rb']);
    });

    test('staff in no department, without "View All Departments": only '
        'records in no department', () async {
      expect(await visible('products', unassigned), ['pn']);
      expect(await visible('receipts', unassigned), ['rn']);
      expect(await visible('customers', unassigned), ['cn']);
    });

    test('equals the union of what the app shows, for every user and '
        'every current department they can pick', () async {
      // (table, the app's includeUnassignedWhenDeptSelected, rows as
      // (uuid, department, departments)).
      final tables = [
        (
          'products',
          true,
          [
            for (final p in productRows)
              (p.uuid!, p.departmentUuid, p.departmentUuids),
          ],
        ),
        (
          'receipts',
          false,
          [
            for (final r in receiptRows)
              (r.uuid!, r.departmentUuidNew, null as List<String>?),
          ],
        ),
        (
          'customers',
          true,
          [
            for (final c in customerRows)
              (c.uuid!, c.departmentUuid, null as List<String>?),
          ],
        ),
      ];
      for (final who in [viewAll, inD1, inBoth, unassigned]) {
        final canViewAll = who.access.contains(
          Authorizations().viewAllDepartments,
        );
        final isUnassigned = !canViewAll && who.departmentUuids.isEmpty;
        // A "view all" user may also pick no department; staff in
        // departments always have one of theirs (DepartmentProvider).
        final choices = <String?>[
          if (canViewAll || isUnassigned) null,
          if (!isUnassigned)
            ...(canViewAll ? ['d1', 'd2'] : who.departmentUuids),
        ];
        for (final (table, includeUnassigned, records) in tables) {
          final app = <String>{
            for (final current in choices)
              for (final (uuid, single, multi) in records)
                if (DepartmentProvider.departmentRecordVisible(
                  manageDepartments: true,
                  canViewAll: canViewAll,
                  isUnassignedUser: isUnassigned,
                  currentDeptUuid: current,
                  departmentUuid: single,
                  departmentUuids: multi,
                  includeUnassignedWhenDeptSelected: includeUnassigned,
                ))
                  uuid,
          };
          expect(
            (await visible(table, who)).toSet(),
            app,
            reason: '$table for ${who.departmentUuids} ${who.access}',
          );
        }
      }
    });
  });

  test('errors in PostgREST shape', () async {
    Matcher pg(int status, String code) => throwsA(
      isA<PgError>()
          .having((e) => e.status, 'status', status)
          .having((e) => e.code, 'code', code),
    );

    await expectLater(
      engine.handle(select('nope'), principal()),
      pg(404, 'PGRST205'),
    );
    await expectLater(
      engine.handle(
        select('products', filters: [f('colour', PgFilterOp.eq, 'red')]),
        principal(),
      ),
      pg(400, '42703'),
    );
    await expectLater(
      engine.handle(select('products', columns: ['colour']), principal()),
      pg(400, '42703'),
    );
    await expectLater(
      engine.handle(
        select(
          'receipts',
          filters: [f('created_at', PgFilterOp.gte, 'yesterday')],
        ),
        principal(),
      ),
      pg(400, '22P02'),
    );
    // A table registered without write hooks (these fixtures) is
    // read-only.
    await expectLater(
      engine.handle(
        const PgRequest(
          table: 'products',
          op: PgOp.insert,
          body: {'uuid': 'p9'},
        ),
        principal(),
      ),
      pg(405, 'LAN501'),
    );
  });

  test('a change to the box rebuilds the date index', () async {
    Future<List<String>> recent() async {
      final r = rows(
        await engine.handle(
          select(
            'products',
            filters: [
              f(
                'updated_at',
                PgFilterOp.gte,
                t0.add(const Duration(days: 2)).toIso8601String(),
              ),
            ],
          ),
          principal(),
        ),
      );
      return [for (final p in r) p['uuid'] as String];
    }

    expect(await recent(), ['p3']);
    products.add(
      product('p5', updatedAt: t0.add(const Duration(days: 3))),
    );
    // Not yet seen: the index is cached until the box reports a change.
    expect(await recent(), ['p3']);

    productChanges.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(await recent(), ['p3', 'p5']);
  });

  group('end to end through a real SupabaseClient', () {
    late LanServer server;
    late LanConnection connection;
    late SupabaseClient lan;

    setUpAll(() async {
      Hive.init(
        Directory.systemTemp.createTempSync('stockall_lan_engine').path,
      );
      await LanCredentialsFunc().init();
      await LanServerSessionsFunc().init();
      await LanShopKeysFunc().init();
      await LanUserBackfill().apply(
        7,
        const LanBackfillShop(ownerId: 'owner', employees: ['staff-1']),
        [
          TempUserClass(
            userId: 'staff-1',
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

    tearDownAll(() async {
      await Hive.close();
    });

    setUp(() async {
      final identity = LanTlsIdentity.generate();
      server = LanServer(
        identity: identity,
        deviceId: 'desk-1',
        serverView: () => {'epoch': 1},
        auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
        rest: engine,
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
      await lan.dispose();
      connection.close();
      await server.stop();
    });

    test('the receipts query loadReceipts sends, and the products page',
        () async {
      final windowStart = t0.add(const Duration(days: 3));
      final windowEnd = t0.add(const Duration(days: 6));
      final data = await lan
          .from('receipts')
          .select()
          .eq('shop_id', 7)
          .gte('created_at', windowStart.toUtc().toIso8601String())
          .lt('created_at', windowEnd.toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .range(0, 1000);
      expect(data.map((r) => r['uuid']), ['r5', 'r4', 'r3']);
      // The client turns it back into the model, as the provider does.
      expect(TempMainReceipt.fromJson(data.first).uuid, 'r5');

      final page = await lan
          .from('products')
          .select()
          .eq('shop_id', 7)
          .order('name', ascending: true)
          .range(0, 1)
          .count(CountOption.exact);
      expect(page.count, 4);
      expect(page.data.map((p) => p['name']), ['Beans', 'Oil']);
      expect(
        TempProductClass.fromJson(page.data.first).uuid,
        'p2',
      );

      await expectLater(
        lan.from('products').select().eq('colour', 'red'),
        throwsA(isA<PostgrestException>().having((e) => e.code, 'code', '42703')),
      );
    });
  });
}
