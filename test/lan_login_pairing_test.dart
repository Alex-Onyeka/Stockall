import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_pairing.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';

void main() {
  late LanTlsIdentity identity;
  late LanServer server;
  late LanConnection connection;
  late DateTime now;

  setUpAll(() async {
    identity = LanTlsIdentity.generate();
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_pairs').path);
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
    now = DateTime.utc(2026, 11, 27, 9);
    server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 3},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
      admission: LanMemoryAdmission(),
      clock: () => now,
    );
    await server.start(ports: const [0]);
    connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: identity.fingerprint))!;
  });

  tearDown(() async {
    connection.close();
    await server.stop();
  });

  Future<Map<String, dynamic>> login(String device, [String? secret]) =>
      connection.postJson('/v1/auth/login', {
        'email': 'ada@shop.test',
        'password': 'right',
        'device_id': device,
        if (secret != null) 'pair_secret': secret,
      });

  Matcher notPaired() => throwsA(
    isA<LanHttpException>()
        .having((e) => e.statusCode, 'status', 403)
        .having((e) => e.errorCode, 'error', 'not_paired'),
  );

  group('only paired devices sign in', () {
    test('a device that never paired is refused, whatever it sends',
        () async {
      await expectLater(login('phone-1'), notPaired());
      await expectLater(login('phone-1', 'made-up'), notPaired());
    });

    test('pairing with the code gives a secret; it signs in with it, and '
        'only that device', () async {
      final client = LanPairingClient(
        deviceId: 'phone-1',
        fingerprintSeen: connection.pin,
      );
      final started = await connection.postJson('/v1/pair/start', {
        'device_id': 'phone-1',
        'commit': client.commit,
      });
      client.started(
        sessionId: started['session_id'] as String,
        ns: started['ns'] as String,
      );
      await connection.postJson('/v1/pair/reveal', {
        'session_id': client.sessionId,
        'nc': client.nc,
      });
      final confirmed = await connection.postJson('/v1/pair/confirm', {
        'session_id': client.sessionId,
        'proof': client.proof,
      });
      final secret = confirmed['pair_secret'] as String;

      expect((await login('phone-1', secret))['token'], isA<String>());
      await expectLater(login('phone-2', secret), notPaired());
      await expectLater(login('phone-1', '${secret}x'), notPaired());
    });

    test('the QR code\'s token gives a secret while it is fresh', () async {
      final token = server.issueQrToken();
      final admitted = await connection.postJson('/v1/pair/qr', {
        'token': token,
        'device_id': 'phone-3',
      });
      final secret = admitted['pair_secret'] as String;
      expect((await login('phone-3', secret))['token'], isA<String>());

      await expectLater(
        connection.postJson('/v1/pair/qr', {
          'token': 'not-a-token',
          'device_id': 'phone-4',
        }),
        notPaired(),
      );
      now = now.add(LanServer.qrTokenFor);
      await expectLater(
        connection.postJson('/v1/pair/qr', {
          'token': token,
          'device_id': 'phone-4',
        }),
        notPaired(),
      );
      // The token is in the QR payload the till scans.
      final qr = LanPairingQr(
        fingerprint: identity.fingerprint,
        port: 47811,
        addresses: const ['127.0.0.1'],
        deviceId: 'desk-1',
        token: 'tok-1',
      );
      expect(LanPairingQr.decode(qr.encode())!.token, 'tok-1');
    });
    Future<String> pairByCode(String device) async {
      final client = LanPairingClient(
        deviceId: device,
        fingerprintSeen: connection.pin,
      );
      final started = await connection.postJson('/v1/pair/start', {
        'device_id': device,
        'commit': client.commit,
      });
      client.started(
        sessionId: started['session_id'] as String,
        ns: started['ns'] as String,
      );
      await connection.postJson('/v1/pair/reveal', {
        'session_id': client.sessionId,
        'nc': client.nc,
      });
      final confirmed = await connection.postJson('/v1/pair/confirm', {
        'session_id': client.sessionId,
        'proof': client.proof,
      });
      return confirmed['pair_secret'] as String;
    }

    Future<int> scan(
      String token,
      String device, {
      LanConnection? from,
    }) async {
      try {
        await (from ?? connection).postJson('/v1/pair/qr', {
          'token': token,
          'device_id': device,
        });
        return 200;
      } on LanHttpException catch (e) {
        return e.statusCode;
      }
    }

    test('a QR code pairs one device; hidden, it pairs none', () async {
      final token = server.issueQrToken();
      expect(server.qrPairings, 0);
      expect(await scan(token, 'phone-3'), 200);
      // Counted: the screen shows a fresh code.
      expect(server.qrPairings, 1);
      expect(await scan(token, 'phone-4'), 403);
      expect(server.qrPairings, 1);

      final hidden = server.issueQrToken();
      server.revokeQrTokens();
      expect(await scan(hidden, 'phone-5'), 403);
    });

    test('a scanned QR code can\'t pair a device id that is paired already; '
        'a person pairing it with the code can', () async {
      final first = await pairByCode('phone-1');
      expect(await scan(server.issueQrToken(), 'phone-1'), 409);
      // Its pairing is untouched.
      expect((await login('phone-1', first))['token'], isA<String>());

      final again = await pairByCode('phone-1');
      expect((await login('phone-1', again))['token'], isA<String>());
      await expectLater(login('phone-1', first), notPaired());
    });

    test('an address that sent 10 QR tokens that pair nothing in a minute '
        'is refused; other devices still pair with the QR code', () async {
      // Another device: the server sees it at another address.
      final other = (await LanConnection.open([
        LanEndpoint('::1', server.port!),
      ], pin: identity.fingerprint))!;
      addTearDown(other.close);

      for (var i = 0; i < 10; i++) {
        expect(await scan('guess-$i', 'phone-$i'), 403);
      }
      expect(await scan(server.issueQrToken(), 'phone-x'), 429);
      expect(await scan(server.issueQrToken(), 'phone-y', from: other), 200);
      // Good scans don't count.
      for (var i = 0; i < 10; i++) {
        expect(
          await scan(server.issueQrToken(), 'phone-z$i', from: other),
          200,
        );
      }
      expect(await scan(server.issueQrToken(), 'phone-w', from: other), 200);
      now = now.add(const Duration(minutes: 1));
      expect(await scan(server.issueQrToken(), 'phone-x'), 200);
    });

    test('a move can\'t take over the id of a device paired here', () async {
      final moving = LanServer(
        identity: identity,
        deviceId: 'desk-2',
        serverView: () => {'epoch': 4},
        auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
        admission: LanMemoryAdmission(),
        acceptMoved: (_, _) => true,
      );
      await moving.start(ports: const [0]);
      addTearDown(moving.stop);
      final there = (await LanConnection.open([
        LanEndpoint('127.0.0.1', moving.port!),
      ], pin: identity.fingerprint))!;
      addTearDown(there.close);
      Future<Map<String, dynamic>> moved(String device) =>
          there.postJson('/v1/auth/login', {
            'email': 'ada@shop.test',
            'password': 'right',
            'device_id': device,
            'moved': {'type': 'moved'},
          });

      // A device new here: let in, and given a secret.
      expect((await moved('phone-7'))['pair_secret'], isA<String>());
      // The same id again (another device claiming it): refused.
      await expectLater(moved('phone-7'), notPaired());
    });
  });

  test('pairing is per store: a device paired while this desktop served one '
      'store is not paired for another', () async {
    await LanPairedDevicesFunc().init();
    await LanPairedDevicesFunc().devicesBox.clear();
    final seven = LanHiveAdmission(shopId: () => 7);
    final eight = LanHiveAdmission(shopId: () => 8);
    final secret = (await seven.admit('phone-1'))!;
    expect(seven.admitted('phone-1', secret), isTrue);
    expect(seven.deviceIds(), ['phone-1']);
    expect(eight.admitted('phone-1', secret), isFalse);
    expect(eight.isPaired('phone-1'), isFalse);
    expect(eight.deviceIds(), isEmpty);
    // New to store 8: a QR code or a move may pair it there.
    expect(await eight.admit('phone-1'), isNotNull);
    expect(await seven.admit('phone-1'), isNull);
  });

  test('the failed-login record keeps at most its cap of keys, expired ones '
      'first', () async {
    var at = DateTime.utc(2026, 11, 27, 9);
    final auth = LanAuthService(
      shopId: () => 7,
      shopJson: (_) => null,
      clock: () => at,
      maxTrackedKeys: 3,
    );
    Future<void> fail(String email, String address) => auth.login({
      'email': email,
      'password': 'wrong',
      'device_id': 'd',
    }, remoteAddress: address);

    for (var i = 0; i < 5; i++) {
      await fail('user$i@shop.test', '10.0.0.$i');
      at = at.add(const Duration(seconds: 1));
    }
    expect(auth.trackedFailureKeys, 3);
    expect(auth.trackedAddresses, 3);

    // Past both windows, a new failure drops every expired key.
    at = at.add(const Duration(minutes: 10));
    await fail('late@shop.test', '10.0.1.1');
    expect(auth.trackedFailureKeys, 1);
    expect(auth.trackedAddresses, 1);
  });
}
