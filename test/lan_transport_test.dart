import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_pairing.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';

/// In-process TLS round trips on loopback: a real `bindSecure` server and
/// pinned clients that go through `connectionFactory`.
void main() {
  late LanTlsIdentity identity;
  late LanTlsIdentity rogue;
  final servers = <LanServer>[];

  var view = <String, dynamic>{
    'shop_tag': 'tag',
    'epoch': 3,
    'server_device_id': 'desk-1',
    'cleared': false,
    'claimed_at': null,
  };

  Future<LanServer> startServer(
    LanTlsIdentity withIdentity, {
    LanDeviceAdmission? admission,
  }) async {
    final server = LanServer(
      identity: withIdentity,
      deviceId: 'desk-1',
      serverView: () => view,
      admission: admission,
    );
    await server.start(ports: const [0]);
    servers.add(server);
    return server;
  }

  setUpAll(() {
    identity = LanTlsIdentity.generate();
    rogue = LanTlsIdentity.generate();
  });

  tearDown(() async {
    for (final server in servers) {
      await server.stop();
    }
    servers.clear();
    view = {
      'shop_tag': 'tag',
      'epoch': 3,
      'server_device_id': 'desk-1',
      'cleared': false,
      'claimed_at': null,
    };
  });

  test('the certificate is EC, self-signed for stockall-lan, and stable', () {
    expect(identity.fingerprint, matches(RegExp(r'^[0-9a-f]{64}$')));
    final reloaded = LanTlsIdentity(
      certificatePem: identity.certificatePem,
      privateKeyPem: identity.privateKeyPem,
    );
    expect(reloaded.fingerprint, identity.fingerprint);
    expect(rogue.fingerprint, isNot(identity.fingerprint));
  });

  for (final address in ['127.0.0.1', '::1']) {
    test('pinned /hello and /server over $address', () async {
      final server = await startServer(identity);
      final connection = await LanConnection.open([
        LanEndpoint(address, server.port!),
      ], pin: identity.fingerprint);
      addTearDown(() => connection?.close());

      expect(connection, isNotNull);
      final hello = await connection!.getJson('/v1/hello');
      expect(hello['device_id'], 'desk-1');
      expect(hello['tls_name'], 'stockall-lan');
      final record = await connection.getJson('/v1/server');
      expect(record['epoch'], 3);
      expect(record['cleared'], isFalse);
    });
  }

  test('a wrong pin is refused', () async {
    final server = await startServer(identity);

    final connection = await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: rogue.fingerprint);

    expect(connection, isNull);
  });

  test('a rogue server with another certificate is refused', () async {
    final server = await startServer(rogue);

    await expectLater(
      connectTls(
        LanEndpoint('127.0.0.1', server.port!),
        pin: identity.fingerprint,
      ),
      throwsA(anything),
    );
  });

  test('unknown paths are 404', () async {
    final server = await startServer(identity);
    // Under a loaded machine (the whole suite at once) one TLS handshake
    // can outlast the connect timeout: a few tries, then a clear failure.
    LanConnection? connection;
    for (var i = 0; i < 5 && connection == null; i++) {
      connection = await LanConnection.open([
        LanEndpoint('127.0.0.1', server.port!),
      ], pin: identity.fingerprint);
    }
    if (connection == null) fail('could not connect to the test server');
    addTearDown(connection.close);

    await expectLater(
      connection.getJson('/v1/nope'),
      throwsA(
        isA<LanHttpException>().having((e) => e.statusCode, 'status', 404),
      ),
    );
  });

  test('wss gets the server event on connect and when it changes', () async {
    final server = await startServer(identity);
    final connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: identity.fingerprint))!;
    addTearDown(connection.close);

    final ws = await connection.openWebSocket();
    final messages = StreamIterator(ws);
    addTearDown(ws.close);

    expect(await messages.moveNext(), isTrue);
    expect(jsonDecode(messages.current as String), {
      'type': 'server',
      'epoch': 3,
      'cleared': false,
    });

    view = {...view, 'epoch': 4, 'server_device_id': null, 'cleared': true};
    server.broadcastServerEvent();

    expect(await messages.moveNext(), isTrue);
    expect(jsonDecode(messages.current as String), {
      'type': 'server',
      'epoch': 4,
      'cleared': true,
    });
  });

  test('the race picks a live address over a dead one', () async {
    final server = await startServer(identity);
    final watch = Stopwatch()..start();

    final connection = await LanConnection.open([
      LanEndpoint('192.0.2.1', server.port!), // TEST-NET: never answers
      LanEndpoint('127.0.0.1', server.port!),
    ], pin: identity.fingerprint);
    addTearDown(() => connection?.close());

    expect(connection, isNotNull);
    expect(connection!.current.address, '127.0.0.1');
    expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
  });

  test('fails over to another address when the current one dies', () async {
    final first = await startServer(identity);
    final second = await startServer(identity);
    final connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', first.port!),
      LanEndpoint('127.0.0.1', second.port!),
    ], pin: identity.fingerprint))!;
    addTearDown(connection.close);
    expect(connection.current.port, first.port);
    expect((await connection.getJson('/v1/hello'))['device_id'], 'desk-1');

    await first.stop();

    expect((await connection.getJson('/v1/hello'))['device_id'], 'desk-1');
    expect(connection.current.port, second.port);
  });

  test('a tcp sweep finds the open port only', () async {
    final server = await startServer(identity);
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final closedPort = closed.port;
    await closed.close();

    final open = await tcpSweep(['127.0.0.1'], [closedPort, server.port!]);

    expect(open, [LanEndpoint('127.0.0.1', server.port!)]);
  });

  group('pairing over HTTPS', () {
    test('the code shown on the server is the code the client expects', () async {
      final admission = LanMemoryAdmission();
      final server = await startServer(identity, admission: admission);
      final connection = (await LanConnection.openUnpinned([
        LanEndpoint('127.0.0.1', server.port!),
      ]))!;
      addTearDown(connection.close);

      // Trust on first use records the real certificate.
      expect(connection.pin, identity.fingerprint);

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

      expect(server.pairing.pendingCode, client.expectedCode);
      expect(client.matches(server.pairing.pendingCode!), isTrue);

      final confirmed = await connection.postJson('/v1/pair/confirm', {
        'session_id': client.sessionId,
        'proof': client.proof,
      });
      // Paired: it signs in with the secret it got.
      expect(admission.deviceIds(), ['phone-1']);
      expect(
        admission.admitted('phone-1', confirmed['pair_secret'] as String),
        isTrue,
      );
    });

    test('a second device while a session is open gets 409 busy', () async {
      final server = await startServer(identity);
      final connection = (await LanConnection.openUnpinned([
        LanEndpoint('127.0.0.1', server.port!),
      ]))!;
      addTearDown(connection.close);
      final first = LanPairingClient(
        deviceId: 'phone-1',
        fingerprintSeen: connection.pin,
      );
      final second = LanPairingClient(
        deviceId: 'phone-2',
        fingerprintSeen: connection.pin,
      );
      await connection.postJson('/v1/pair/start', {
        'device_id': 'phone-1',
        'commit': first.commit,
      });

      await expectLater(
        connection.postJson('/v1/pair/start', {
          'device_id': 'phone-2',
          'commit': second.commit,
        }),
        throwsA(
          isA<LanHttpException>()
              .having((e) => e.statusCode, 'status', 409)
              .having((e) => e.errorCode, 'error', 'busy'),
        ),
      );
    });

    test('abort (a mistyped code): the session ends at once, so another '
        'device can pair; only with that session\'s id', () async {
      final server = await startServer(identity);
      final connection = (await LanConnection.openUnpinned([
        LanEndpoint('127.0.0.1', server.port!),
      ]))!;
      addTearDown(connection.close);
      final first = LanPairingClient(
        deviceId: 'phone-1',
        fingerprintSeen: connection.pin,
      );
      final started = await connection.postJson('/v1/pair/start', {
        'device_id': 'phone-1',
        'commit': first.commit,
      });
      first.started(
        sessionId: started['session_id'] as String,
        ns: started['ns'] as String,
      );
      await connection.postJson('/v1/pair/reveal', {
        'session_id': first.sessionId,
        'nc': first.nc,
      });
      expect(server.pairing.pendingCode, isNotNull);

      // Another session's id ends nothing.
      await expectLater(
        connection.postJson('/v1/pair/abort', {'session_id': 'ab' * 16}),
        throwsA(
          isA<LanHttpException>()
              .having((e) => e.statusCode, 'status', 404)
              .having((e) => e.errorCode, 'error', 'unknown_session'),
        ),
      );
      expect(server.pairing.pendingCode, isNotNull);

      await connection.postJson('/v1/pair/abort', {
        'session_id': first.sessionId,
      });
      expect(server.pairing.pendingCode, isNull);
      // phone-2 isn't kept waiting.
      final second = LanPairingClient(
        deviceId: 'phone-2',
        fingerprintSeen: connection.pin,
      );
      final again = await connection.postJson('/v1/pair/start', {
        'device_id': 'phone-2',
        'commit': second.commit,
      });
      expect(again['session_id'], isA<String>());
    });

    test('the server\'s Cancel ends the session: another device can pair, '
        'and the cancelled one can\'t confirm', () async {
      final server = await startServer(identity);
      final connection = (await LanConnection.openUnpinned([
        LanEndpoint('127.0.0.1', server.port!),
      ]))!;
      addTearDown(connection.close);
      final first = LanPairingClient(
        deviceId: 'phone-1',
        fingerprintSeen: connection.pin,
      );
      final started = await connection.postJson('/v1/pair/start', {
        'device_id': 'phone-1',
        'commit': first.commit,
      });
      first.started(
        sessionId: started['session_id'] as String,
        ns: started['ns'] as String,
      );
      await connection.postJson('/v1/pair/reveal', {
        'session_id': first.sessionId,
        'nc': first.nc,
      });

      server.pairing.cancel();
      expect(server.pairing.pendingCode, isNull);
      await expectLater(
        connection.postJson('/v1/pair/confirm', {
          'session_id': first.sessionId,
          'proof': first.proof,
        }),
        throwsA(
          isA<LanHttpException>().having(
            (e) => e.errorCode,
            'error',
            'unknown_session',
          ),
        ),
      );
      final second = LanPairingClient(
        deviceId: 'phone-2',
        fingerprintSeen: connection.pin,
      );
      await connection.postJson('/v1/pair/start', {
        'device_id': 'phone-2',
        'commit': second.commit,
      });
      expect(server.pairing.pendingCode, isNull);
    });
  });
}
