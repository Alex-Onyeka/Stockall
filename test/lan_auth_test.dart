import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';

/// Login, sessions and the session-gated routes, over real in-process TLS
/// on loopback.
void main() {
  late LanTlsIdentity identity;
  final servers = <LanServer>[];
  final connections = <LanConnection>[];
  var now = DateTime.utc(2026, 11, 25, 12);
  final shopKey = 'a' * 64;

  const shop = LanBackfillShop(ownerId: 'owner', employees: ['cashier']);
  TempUserClass user(String id, String email, String password) {
    return TempUserClass(
      userId: id,
      name: id,
      email: email,
      password: password,
      role: id == 'owner' ? 'Owner' : 'Cashier',
      departmentUuids: const [],
      access: const ['Make Sale'],
    );
  }

  Future<LanConnection> serve() async {
    final server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {
        'shop_tag': shopTag(shopKey),
        'epoch': 3,
        'server_device_id': 'desk-1',
        'cleared': false,
        'claimed_at': null,
      },
      fullServerView: () => {
        'shop_tag': shopTag(shopKey),
        'epoch': 3,
        'server_device_id': 'desk-1',
        'cleared': false,
        'claimed_at': null,
        'shop_id': 7,
        'claimed_by_user_id': 'owner',
      },
      auth: LanAuthService(
        shopId: () => 7,
        shopJson: (id) => {'shop_id': id, 'name': 'Test Shop'},
        clock: () => now,
      ),
    );
    await server.start(ports: const [0]);
    servers.add(server);
    final connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: identity.fingerprint))!;
    connections.add(connection);
    return connection;
  }

  Future<Map<String, dynamic>> login(
    LanConnection connection, {
    String email = 'Cashier@Shop.test',
    String password = 'right',
    String deviceId = 'phone-1',
  }) {
    return connection.postJson('/v1/auth/login', {
      'email': email,
      'password': password,
      'device_id': deviceId,
    });
  }

  Matcher httpError(int status, String error) {
    return throwsA(
      isA<LanHttpException>()
          .having((e) => e.statusCode, 'status', status)
          .having((e) => e.errorCode, 'error', error),
    );
  }

  setUpAll(() async {
    identity = LanTlsIdentity.generate();
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_auth').path);
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanShopKeysFunc().init();
    await LanShopKeysFunc().put(7, shopKey);
  });

  setUp(() async {
    now = DateTime.utc(2026, 11, 25, 12);
    await LanServerSessionsFunc().clearSessions();
    await LanUserBackfill().apply(7, shop, [
      user('owner', 'owner@shop.test', 'boss'),
      user('cashier', 'cashier@shop.test', 'right'),
    ], iterations: 1000);
  });

  tearDown(() async {
    for (final c in connections) {
      c.close();
    }
    connections.clear();
    for (final s in servers) {
      await s.stop();
    }
    servers.clear();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('login returns a session, the user without password, shop and key',
      () async {
    final connection = await serve();

    final body = await login(connection);

    expect(body['token'], matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(
      DateTime.parse(body['expires_at'] as String),
      now.add(const Duration(days: 30)),
    );
    final user = body['user'] as Map<String, dynamic>;
    expect(user['user_id'], 'cashier');
    expect(user.containsKey('password'), isFalse);
    expect(body['shop'], {'shop_id': 7, 'name': 'Test Shop'});
    expect(body['shop_key'], shopKey);

    // The server keeps only the token's hash.
    final stored = LanServerSessionsFunc().sessionsBox.values.single;
    expect(stored.tokenHash, hashSessionToken(body['token'] as String));
    expect(stored.deviceId, 'phone-1');
    expect(stored.userId, 'cashier');
  });

  test('a wrong password and an unknown email get the same 401', () async {
    final connection = await serve();

    await expectLater(
      login(connection, password: 'wrong'),
      httpError(401, 'invalid_credentials'),
    );
    await expectLater(
      login(connection, email: 'nobody@shop.test'),
      httpError(401, 'invalid_credentials'),
    );
    await expectLater(
      connection.postJson('/v1/auth/login', {'email': 'x@y.z'}),
      httpError(400, 'bad_request'),
    );
  });

  test('5 failures for an email lock it for 5 minutes, then it works',
      () async {
    final connection = await serve();
    for (var i = 0; i < 5; i++) {
      await expectLater(
        login(connection, password: 'wrong-$i'),
        httpError(401, 'invalid_credentials'),
      );
    }

    await expectLater(login(connection), httpError(429, 'rate_limited'));
    // Another email is not affected.
    expect(
      (await login(connection, email: 'owner@shop.test', password: 'boss'))
          ['token'],
      isA<String>(),
    );

    now = now.add(const Duration(minutes: 5));
    expect((await login(connection))['token'], isA<String>());
  });

  test('/v1/server: reduced without a session, full with one', () async {
    final connection = await serve();
    final token = (await login(connection))['token'] as String;

    final open = await connection.getJson('/v1/server');
    final full = await connection.getJson(
      '/v1/server',
      session: LanSessionHeaders(token: token, deviceId: 'phone-1'),
    );
    final otherDevice = await connection.getJson(
      '/v1/server',
      session: LanSessionHeaders(token: token, deviceId: 'phone-2'),
    );

    expect(open.containsKey('shop_id'), isFalse);
    expect(full['shop_id'], 7);
    expect(full['claimed_by_user_id'], 'owner');
    // The session is bound to the device that logged in.
    expect(otherDevice.containsKey('shop_id'), isFalse);
  });

  test('wss needs a session', () async {
    final connection = await serve();
    final token = (await login(connection))['token'] as String;

    await expectLater(connection.openWebSocket(), throwsA(anything));

    final ws = await connection.openWebSocket(
      session: LanSessionHeaders(token: token, deviceId: 'phone-1'),
    );
    addTearDown(ws.close);
    final first = await StreamIterator(ws).moveNext();
    expect(first, isTrue);
  });

  test('verify-password: right, wrong, and no session', () async {
    final connection = await serve();
    final token = (await login(connection))['token'] as String;
    final session = LanSessionHeaders(token: token, deviceId: 'phone-1');

    expect(
      await connection.postJson('/v1/auth/verify-password', {
        'password': 'right',
      }, session: session),
      {'ok': true},
    );
    await expectLater(
      connection.postJson('/v1/auth/verify-password', {
        'password': 'nope',
      }, session: session),
      httpError(403, 'bad_password'),
    );
    await expectLater(
      connection.postJson('/v1/auth/verify-password', {'password': 'right'}),
      httpError(401, 'session_invalid'),
    );
  });

  test('logout revokes; a new login on the device replaces the old one',
      () async {
    final connection = await serve();
    final first = (await login(connection))['token'] as String;
    final second = (await login(connection))['token'] as String;
    final third = (await login(connection, deviceId: 'phone-2'))['token']
        as String;

    Future<Map<String, dynamic>> check(String token, String device) {
      return connection.postJson('/v1/auth/verify-password', {
        'password': 'right',
      }, session: LanSessionHeaders(token: token, deviceId: device));
    }

    await expectLater(check(first, 'phone-1'), httpError(401, 'session_invalid'));
    expect(await check(second, 'phone-1'), {'ok': true});
    expect(await check(third, 'phone-2'), {'ok': true});

    await connection.postJson(
      '/v1/auth/logout',
      const {},
      session: LanSessionHeaders(token: second, deviceId: 'phone-1'),
    );
    await expectLater(
      check(second, 'phone-1'),
      httpError(401, 'session_invalid'),
    );
    expect(await check(third, 'phone-2'), {'ok': true});
  });

  test('sessions slide while used and expire after 30 idle days', () async {
    final connection = await serve();
    final token = (await login(connection))['token'] as String;
    final session = LanSessionHeaders(token: token, deviceId: 'phone-1');
    final start = now;

    now = start.add(const Duration(days: 20));
    expect(
      (await connection.getJson('/v1/server', session: session))['shop_id'],
      7,
    );
    expect(
      LanServerSessionsFunc().get(hashSessionToken(token))!.expiresAt,
      start.add(const Duration(days: 50)),
    );

    now = start.add(const Duration(days: 50, seconds: 1));
    expect(
      (await connection.getJson('/v1/server', session: session))
          .containsKey('shop_id'),
      isFalse,
    );
    expect(LanServerSessionsFunc().get(hashSessionToken(token)), isNull);
  });

  test('a member removed by the backfill loses access at once', () async {
    final connection = await serve();
    final token = (await login(connection))['token'] as String;

    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: []),
      [user('owner', 'owner@shop.test', 'boss')],
      iterations: 1000,
    );

    await expectLater(
      connection.postJson('/v1/auth/verify-password', {
        'password': 'right',
      }, session: LanSessionHeaders(token: token, deviceId: 'phone-1')),
      httpError(401, 'session_invalid'),
    );
    await expectLater(login(connection), httpError(401, 'invalid_credentials'));
  });

  test('without auth (P2 servers) the auth routes are 404', () async {
    final server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 1},
    );
    await server.start(ports: const [0]);
    servers.add(server);
    final connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: identity.fingerprint))!;
    connections.add(connection);

    await expectLater(login(connection), httpError(404, 'not_found'));
    expect(jsonEncode(await connection.getJson('/v1/server')), '{"epoch":1}');
  });
}
