import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_online_scope.dart';
import 'package:stockall/services/lan/rest/lan_store_tables.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

/// Records what the server would forward to Supabase, and answers with
/// [answer].
class _Recorder implements LanProxy {
  final forwarded = <PgRequest>[];
  Object? answer = const <Object>[];

  @override
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  ) async {
    forwarded.add(request);
    return PgResponse(200, body: answer);
  }
}

LanPrincipal _who(String userId, {List<String> access = const []}) =>
    LanPrincipal(
      userId: userId,
      shopId: 7,
      role: 'Manager',
      access: access,
      departmentUuids: const [],
      isOwner: userId == 'owner',
    );

/// The request as it arrives over HTTP (with the query string forwarded).
PgRequest _http(String method, String path, String rawQuery, {Object? body}) {
  final query = <String, List<String>>{};
  for (final part in rawQuery.split('&').where((p) => p.isNotEmpty)) {
    final i = part.indexOf('=');
    query
        .putIfAbsent(Uri.decodeQueryComponent(part.substring(0, i)), () => [])
        .add(Uri.decodeQueryComponent(part.substring(i + 1)));
  }
  return parsePgRequest(
    method: method,
    path: path,
    query: query,
    headers: const {},
    body: body,
    rawQuery: rawQuery,
  );
}

void main() {
  final a = Authorizations();
  late _Recorder proxy;
  late HiveRestEngine engine;

  setUp(() {
    proxy = _Recorder();
    engine = HiveRestEngine(
      tables: [usersTable(() => const <LanUserCredential>[])],
      shopId: () => 7,
      manageDepartments: () => false,
      isOnline: () => true,
      proxy: proxy,
      onlineOnlyTables: const {
        'subscription',
        'subscription_payments',
        'app_version',
        'utility_constants',
        'notifications',
      },
      onlineOnlyRpcs: const {
        'mark_all_notifications_viewed',
        'get_this_month_subscription_payments',
      },
      storeMembers: () => const LanStoreMembers(
        ownerId: 'owner',
        members: {'owner', 'staff-1', 'staff-2'},
        departments: {'dep-7'},
      ),
    );
  });

  Matcher denied() => throwsA(
    isA<PgError>().having((e) => e.status, 'status', 403),
  );

  group('users writes', () {
    final manager = _who('staff-1', access: [a.updateEmployee, a.deleteEmployee]);

    test('a member of this store, named by user_id=eq.: forwarded', () async {
      await engine.handle(
        _http('PATCH', 'users', 'user_id=eq.staff-2', body: {'role': 'Cashier'}),
        manager,
      );
      expect(proxy.forwarded, hasLength(1));
    });

    test('someone not in this store: refused, nothing forwarded', () async {
      await expectLater(
        engine.handle(
          _http('PATCH', 'users', 'user_id=eq.stranger', body: {'pin': '1'}),
          manager,
        ),
        denied(),
      );
      await expectLater(
        engine.handle(_http('DELETE', 'users', 'user_id=eq.stranger'), manager),
        denied(),
      );
      expect(proxy.forwarded, isEmpty);
    });

    test('the owner\'s row: only the owner', () async {
      await expectLater(
        engine.handle(
          _http('PATCH', 'users', 'user_id=eq.owner', body: {'access': []}),
          manager,
        ),
        denied(),
      );
      expect(proxy.forwarded, isEmpty);
      await engine.handle(
        _http('PATCH', 'users', 'user_id=eq.owner', body: {'name': 'Me'}),
        _who('owner'),
      );
      expect(proxy.forwarded, hasLength(1));
    });

    test('no filter, another filter, several users, or an upsert: refused',
        () async {
      for (final query in [
        '',
        'email=eq.ada@shop.test',
        'user_id=in.(staff-1,staff-2)',
        'user_id=eq.staff-2&role=eq.Cashier',
      ]) {
        await expectLater(
          engine.handle(
            _http('PATCH', 'users', query, body: {'role': 'Cashier'}),
            manager,
          ),
          denied(),
          reason: query,
        );
      }
      expect(proxy.forwarded, isEmpty);
    });
    test('a new user: forwarded when it joins only this store, as anything '
        'but an owner', () async {
      final adder = _who('staff-1', access: [a.addEmployee]);
      await engine.handle(
        _http('POST', 'users', '', body: {
          'name': 'Bo',
          'role': 'Cashier',
          'department_uuids': ['dep-7'],
        }),
        adder,
      );
      expect(proxy.forwarded, hasLength(1));

      for (final row in <Map<String, dynamic>>[
        {'name': 'Bo', 'role': 'Owner'},
        {'name': 'Bo', 'role': ' owner '},
        {'name': 'Bo', 'role': 'Cashier', 'shop_id': 8},
        {'name': 'Bo', 'role': 'Cashier', 'department_uuid': 'dep-8'},
        {
          'name': 'Bo',
          'role': 'Cashier',
          'department_uuids': ['dep-7', 'dep-8'],
        },
      ]) {
        await expectLater(
          engine.handle(_http('POST', 'users', '', body: row), adder),
          denied(),
          reason: '$row',
        );
      }
      // One bad row in a batch refuses the batch.
      await expectLater(
        engine.handle(
          _http('POST', 'users', '', body: [
            {'name': 'Bo', 'role': 'Cashier'},
            {'name': 'Cy', 'role': 'Owner'},
          ]),
          adder,
        ),
        denied(),
      );
      expect(proxy.forwarded, hasLength(1));
    });
  });

  group('online-only tables', () {
    final member = _who('staff-1', access: [a.deleteNotification, a.manageShop]);

    test('notifications: forced to this store, in the forwarded query too',
        () async {
      await engine.handle(_http('GET', 'notifications', 'select=*'), member);
      await engine.handle(
        _http('PATCH', 'notifications', 'uuid=eq.n1', body: {'is_viewed': true}),
        member,
      );
      await engine.handle(
        _http('DELETE', 'notifications', 'uuid=eq.n1'),
        member,
      );
      for (final f in proxy.forwarded) {
        expect(
          f.filters.any(
            (x) => x.column == 'shop_id' && x.op == PgFilterOp.eq && x.value == '7',
          ),
          isTrue,
        );
        expect(f.wire!.query, contains('shop_id=eq.7'));
      }
      expect(proxy.forwarded, hasLength(3));
    });

    test('notifications of another store: refused', () async {
      await expectLater(
        engine.handle(
          _http('GET', 'notifications', 'select=*&shop_id=eq.8'),
          member,
        ),
        denied(),
      );
      expect(proxy.forwarded, isEmpty);
    });

    test('subscription and its payments: forced to this store\'s owner',
        () async {
      await engine.handle(_http('GET', 'subscription', 'select=*'), member);
      await engine.handle(
        _http('GET', 'subscription_payments', 'select=*'),
        member,
      );
      for (final f in proxy.forwarded) {
        expect(f.wire!.query, contains('user_id=eq.owner'));
      }
      await expectLater(
        engine.handle(
          _http('POST', 'subscription', '', body: {'user_id': 'someone-else'}),
          member,
        ),
        denied(),
      );
      await expectLater(
        engine.handle(
          _http('GET', 'subscription', 'select=*&user_id=eq.someone-else'),
          member,
        ),
        denied(),
      );
      expect(proxy.forwarded, hasLength(2));
    });

    test('app version and utility constants: read only', () async {
      await engine.handle(_http('GET', 'app_version', 'select=*'), member);
      expect(proxy.forwarded.single.wire!.query, 'select=*');
      const store = LanStoreMembers(ownerId: 'owner', members: {'owner'});
      for (final table in ['app_version', 'utility_constants']) {
        for (final op in [PgOp.insert, PgOp.update, PgOp.delete]) {
          expect(
            () => LanOnlineScope.scope(
              PgRequest(table: table, op: op, body: const {}),
              _who('owner'),
              shopId: 7,
              store: store,
            ),
            throwsA(isA<PgError>().having((e) => e.status, 'status', 403)),
            reason: '$table ${op.name}',
          );
        }
      }
    });

    test('RPCs: notifications of this store only; payments answered for '
        'this store\'s owner only', () async {
      await expectLater(
        engine.handle(
          _http(
            'POST',
            'rpc/mark_all_notifications_viewed',
            '',
            body: {'p_shop_id': 8},
          ),
          member,
        ),
        denied(),
      );
      await engine.handle(
        _http(
          'POST',
          'rpc/mark_all_notifications_viewed',
          '',
          body: {'p_shop_id': 7},
        ),
        member,
      );
      proxy.answer = [
        {'user_id': 'owner', 'payments_id': 1},
        {'user_id': 'another-owner', 'payments_id': 2},
      ];
      final r = await engine.handle(
        _http('POST', 'rpc/get_this_month_subscription_payments', ''),
        member,
      );
      expect(r.body, [
        {'user_id': 'owner', 'payments_id': 1},
      ]);
    });
  });
}
