import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
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

  group('only paired devices sign in (S4)', () {
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
