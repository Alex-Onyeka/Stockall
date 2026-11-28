import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_server_session.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/services/lan/lan_password_hash.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';

TempUserClass user(
  String id, {
  String? email,
  String password = 'pw',
  String role = 'Cashier',
  List<String> access = const ['Make Sale'],
  List<String>? departments,
}) {
  return TempUserClass(
    userId: id,
    name: 'Name $id',
    email: email ?? '$id@Shop.Test',
    password: password,
    role: role,
    pin: '1234',
    departmentUuids: departments,
    access: access,
  );
}

void main() {
  const iterations = 1000;
  final now = DateTime.utc(2026, 11, 25, 12);
  const shop = LanBackfillShop(ownerId: 'owner', employees: ['e1', 'e2']);

  Future<List<LanUserCredential>> plan(
    List<TempUserClass> users, {
    LanBackfillShop forShop = shop,
    Map<String, LanUserCredential> existing = const {},
  }) {
    return planCredentials(
      shopId: 7,
      shop: forShop,
      users: users,
      existing: existing,
      now: now,
      iterations: iterations,
    );
  }

  test('members are the owner plus employees, listed or not', () {
    expect(shop.members, {'owner', 'e1', 'e2'});
    expect(
      const LanBackfillShop(ownerId: 'owner', employees: ['owner', 'e1'])
          .members,
      {'owner', 'e1'},
    );
    final fromRow = LanBackfillShop.fromRow({
      'user_id': 'owner',
      'employees': ['e1', null, 'e2'],
      'lan_key': 'k' * 64,
    });
    expect(fromRow.members, {'owner', 'e1', 'e2'});
    expect(fromRow.lanKey, 'k' * 64);
    expect(LanBackfillShop.fromRow({'user_id': 'o'}).lanKey, isNull);
  });

  test('only members with an email and password get credentials', () async {
    final out = await plan([
      user('owner', role: 'Owner'),
      user('e1', departments: ['d1']),
      user('e2', password: ''),
      user('stranger'),
      user('e1'), // duplicate row: first wins
    ]);

    expect(out.map((c) => c.userId), ['owner', 'e1']);
    final owner = out.first;
    final e1 = out.last;
    expect(owner.isOwner, isTrue);
    expect(e1.isOwner, isFalse);
    expect(e1.email, 'e1@shop.test');
    expect(e1.role, 'Cashier');
    expect(e1.access, ['Make Sale']);
    expect(e1.departmentUuids, ['d1']);
    expect(e1.iterations, iterations);
    expect(e1.updatedAt, now);
    expect(
      await verifyPassword(
        'pw',
        LanPasswordHash(salt: e1.salt, hash: e1.hash, iterations: 1000),
      ),
      isTrue,
    );
  });

  test('the stored profile has no password but keeps the pin', () async {
    final out = await plan([user('e1')]);
    final profile = jsonDecode(out.single.profileJson) as Map;

    expect(profile.containsKey('password'), isFalse);
    expect(profile['user_id'], 'e1');
    expect(profile['pin'], '1234');
    expect(out.single.profile()['email'], 'e1@Shop.Test');
  });

  test('an unchanged password keeps its salt; a changed one does not', () async {
    final first = await plan([user('e1'), user('e2')]);
    final existing = {for (final c in first) c.userId: c};

    final second = await plan([
      user('e1'),
      user('e2', password: 'new'),
    ], existing: existing);

    expect(second[0].salt, existing['e1']!.salt);
    expect(second[0].hash, existing['e1']!.hash);
    expect(second[1].salt, isNot(existing['e2']!.salt));
    expect(second[1].hash, isNot(existing['e2']!.hash));
  });

  group('apply (Hive)', () {
    setUpAll(() async {
      Hive.init(
        Directory.systemTemp.createTempSync('stockall_lan_backfill').path,
      );
      await LanCredentialsFunc().init();
      await LanServerSessionsFunc().init();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    Future<void> session(String userId) {
      return LanServerSessionsFunc().put(
        LanServerSession(
          tokenHash: 'hash-$userId',
          shopId: 7,
          userId: userId,
          deviceId: 'phone',
          createdAt: now,
          expiresAt: now.add(const Duration(days: 30)),
          lastUsedAt: now,
        ),
      );
    }

    test('leavers and changed passwords lose sessions; others keep them',
        () async {
      await LanUserBackfill().apply(
        7,
        shop,
        [user('owner'), user('e1'), user('e2')],
        iterations: iterations,
      );
      expect(LanCredentialsFunc().forShop(7), hasLength(3));
      await session('owner');
      await session('e1');
      await session('e2');

      // e2 left the shop; e1 changed password; the owner is unchanged.
      await LanUserBackfill().apply(
        7,
        const LanBackfillShop(ownerId: 'owner', employees: ['e1']),
        [user('owner'), user('e1', password: 'changed'), user('e2')],
        iterations: iterations,
      );

      expect(
        LanCredentialsFunc().forShop(7).map((c) => c.userId).toSet(),
        {'owner', 'e1'},
      );
      expect(LanCredentialsFunc().get(7, 'e2'), isNull);
      expect(LanServerSessionsFunc().get('hash-owner'), isNotNull);
      expect(LanServerSessionsFunc().get('hash-e1'), isNull);
      expect(LanServerSessionsFunc().get('hash-e2'), isNull);
      expect(LanCredentialsFunc().byEmail(7, ' OWNER@shop.test '), isNotNull);
    });
  });
}
