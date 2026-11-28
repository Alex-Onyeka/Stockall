import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/lan/lan_pairing.dart';

void main() {
  final realFp = 'a' * 64;
  final rogueFp = 'b' * 64;

  ({LanPairingServer server, LanPairingClient client}) startPairing({
    required String serverFp,
    required String clientSeesFp,
    String deviceId = 'phone-1',
    DateTime Function()? clock,
  }) {
    final server = LanPairingServer(fingerprint: serverFp, clock: clock);
    final client = LanPairingClient(
      deviceId: deviceId,
      fingerprintSeen: clientSeesFp,
    );
    final started = server.start(deviceId: deviceId, commit: client.commit);
    client.started(sessionId: started.sessionId, ns: started.ns);
    return (server: server, client: client);
  }

  test('an honest run gives the same 8-character code on both sides', () {
    final p = startPairing(serverFp: realFp, clientSeesFp: realFp);
    expect(p.server.pendingCode, isNull);

    p.server.reveal(sessionId: p.client.sessionId!, nc: p.client.nc);

    final code = p.server.pendingCode!;
    expect(code, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{8}$')));
    expect(code, p.client.expectedCode);
    expect(p.client.matches(code.toLowerCase()), isTrue);
    expect(
      p.client.matches('${code.substring(0, 4)}-${code.substring(4)}'),
      isTrue,
    );
  });

  test('a man in the middle (different certificate) gets a different code', () {
    final p = startPairing(serverFp: realFp, clientSeesFp: rogueFp);
    p.server.reveal(sessionId: p.client.sessionId!, nc: p.client.nc);

    expect(p.client.expectedCode, isNot(p.server.pendingCode));
    expect(p.client.matches(p.server.pendingCode!), isFalse);
  });

  test('confirm with the right proof returns the client device', () {
    final p = startPairing(serverFp: realFp, clientSeesFp: realFp);
    p.server.reveal(sessionId: p.client.sessionId!, nc: p.client.nc);

    final device = p.server.confirm(
      sessionId: p.client.sessionId!,
      proof: p.client.proof,
    );

    expect(device, 'phone-1');
    expect(p.server.activeSession, isNull);
  });

  test('a wrong proof is refused and ends the session', () {
    final p = startPairing(serverFp: realFp, clientSeesFp: rogueFp);
    p.server.reveal(sessionId: p.client.sessionId!, nc: p.client.nc);

    expect(
      () => p.server.confirm(
        sessionId: p.client.sessionId!,
        proof: p.client.proof,
      ),
      throwsA(isA<LanPairingError>().having((e) => e.code, 'code', 'bad_proof')),
    );
    expect(p.server.activeSession, isNull);
  });

  test('a nonce that does not match the commitment is refused', () {
    final p = startPairing(serverFp: realFp, clientSeesFp: realFp);

    expect(
      () => p.server.reveal(sessionId: p.client.sessionId!, nc: 'c' * 64),
      throwsA(
        isA<LanPairingError>().having((e) => e.code, 'code', 'bad_commit'),
      ),
    );
    expect(p.server.activeSession, isNull);
  });

  test('sessions expire after 2 minutes', () {
    var now = DateTime.utc(2026, 11, 25, 12);
    final p = startPairing(
      serverFp: realFp,
      clientSeesFp: realFp,
      clock: () => now,
    );
    now = now.add(const Duration(minutes: 2, seconds: 1));

    expect(
      () => p.server.reveal(sessionId: p.client.sessionId!, nc: p.client.nc),
      throwsA(isA<LanPairingError>().having((e) => e.code, 'code', 'expired')),
    );
  });

  test('a second device is refused while a session is active', () {
    final p = startPairing(serverFp: realFp, clientSeesFp: realFp);
    final other = LanPairingClient(deviceId: 'phone-2', fingerprintSeen: realFp);

    expect(
      () => p.server.start(deviceId: 'phone-2', commit: other.commit),
      throwsA(isA<LanPairingError>().having((e) => e.code, 'code', 'busy')),
    );
  });

  test('more than 5 starts a minute are rate-limited', () {
    var now = DateTime.utc(2026, 11, 25, 12);
    final server = LanPairingServer(fingerprint: realFp, clock: () => now);
    final client = LanPairingClient(deviceId: 'phone-1', fingerprintSeen: realFp);
    for (var i = 0; i < 5; i++) {
      server.start(deviceId: 'phone-1', commit: client.commit);
    }

    expect(
      () => server.start(deviceId: 'phone-1', commit: client.commit),
      throwsA(
        isA<LanPairingError>().having((e) => e.code, 'code', 'rate_limited'),
      ),
    );

    now = now.add(const Duration(minutes: 1));
    expect(
      server.start(deviceId: 'phone-1', commit: client.commit).ns,
      hasLength(64),
    );
  });

  test('malformed input is a bad request', () {
    final server = LanPairingServer(fingerprint: realFp);
    expect(
      () => server.start(deviceId: 'phone-1', commit: 'not-hex'),
      throwsA(
        isA<LanPairingError>().having((e) => e.code, 'code', 'bad_request'),
      ),
    );
    expect(
      () => server.reveal(sessionId: 'nope', nc: 'c' * 64),
      throwsA(
        isA<LanPairingError>().having((e) => e.code, 'code', 'unknown_session'),
      ),
    );
  });

  group('QR payload', () {
    test('round-trips', () {
      final qr = LanPairingQr(
        fingerprint: realFp,
        port: 47811,
        addresses: ['192.168.1.20', 'fe80::aaaa%en0'],
        deviceId: 'desk-1',
      );

      final decoded = LanPairingQr.decode(qr.encode())!;

      expect(decoded.fingerprint, realFp);
      expect(decoded.port, 47811);
      expect(decoded.addresses, ['192.168.1.20', 'fe80::aaaa%en0']);
      expect(decoded.deviceId, 'desk-1');
    });

    test('rejects anything else', () {
      expect(LanPairingQr.decode('https://example.com'), isNull);
      expect(LanPairingQr.decode('${LanPairingQr.prefix}{oops'), isNull);
      expect(
        LanPairingQr.decode(
          '${LanPairingQr.prefix}{"v":1,"fp":"short","port":1,"addrs":[],"dev":"d"}',
        ),
        isNull,
      );
    });
  });
}
