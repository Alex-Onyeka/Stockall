import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';

// Pairing proves to a new client that the server it reached is the one on
// the server's screen, without a certificate authority.
//
// 1. The client connects over TLS (unpinned) and notes the certificate
//    fingerprint it was shown.
// 2. Client -> server: commit = H(nc). Server -> client: ns.
// 3. Client -> server: nc. The server checks the commitment.
// 4. Both sides compute code = base32(H(fingerprint | ns | nc | device)).
//    The server shows its code; the person types it on the client.
//
// A man in the middle shows the client a different fingerprint, so the two
// codes only match by chance. Each side commits to its nonce before seeing
// the other's, so the attacker gets one 1-in-2^40 guess per session, and
// sessions are rate-limited.

String commitFor(String ncHex) {
  return sha256
      .convert(utf8.encode('stockall-pair-commit-v1|$ncHex'))
      .toString();
}

String pairingCodeFor({
  required String fingerprint,
  required String ns,
  required String nc,
  required String deviceId,
}) {
  final digest = sha256.convert(
    utf8.encode(
      'stockall-pair-v1|${fingerprint.toLowerCase()}|$ns|$nc|$deviceId',
    ),
  );
  return crockfordEncode(digest.bytes, 8);
}

String pairingProofFor(String code, String ns) {
  return Hmac(sha256, utf8.encode(code))
      .convert(utf8.encode('confirm|$ns'))
      .toString();
}

class LanPairingError implements Exception {
  const LanPairingError(this.code);

  /// bad_request, busy, rate_limited, unknown_session, expired,
  /// bad_commit or bad_proof.
  final String code;

  int get httpStatus {
    switch (code) {
      case 'busy':
        return 409;
      case 'rate_limited':
        return 429;
      case 'unknown_session':
        return 404;
      case 'expired':
        return 410;
      case 'bad_commit':
      case 'bad_proof':
        return 403;
      default:
        return 400;
    }
  }

  @override
  String toString() => 'LanPairingError($code)';
}

class LanPairingSession {
  LanPairingSession({
    required this.id,
    required this.deviceId,
    required this.commit,
    required this.ns,
    required this.createdAt,
  });

  final String id;
  final String deviceId;
  final String commit;
  final String ns;
  final DateTime createdAt;
  String? code;
}

/// Server side: one pairing session at a time, rate-limited.
class LanPairingServer {
  LanPairingServer({
    required this.fingerprint,
    DateTime Function()? clock,
    Random? random,
  }) : _now = clock ?? DateTime.now,
       _random = random ?? Random.secure();

  final String fingerprint;
  final DateTime Function() _now;
  final Random _random;
  final List<DateTime> _starts = [];
  LanPairingSession? _active;

  LanPairingSession? get activeSession {
    final session = _active;
    if (session == null) return null;
    if (_isExpired(session)) {
      _active = null;
      return null;
    }
    return session;
  }

  /// The code to show on the server's screen, once the client revealed.
  String? get pendingCode => activeSession?.code;

  bool _isExpired(LanPairingSession s) {
    return _now().difference(s.createdAt) > LanConstants.pairingSessionTtl;
  }

  ({String sessionId, String ns}) start({
    required String deviceId,
    required String commit,
  }) {
    final now = _now();
    _starts.removeWhere(
      (t) => now.difference(t) >= const Duration(minutes: 1),
    );
    if (_starts.length >= LanConstants.pairingStartsPerMinute) {
      throw const LanPairingError('rate_limited');
    }
    if (deviceId.isEmpty || !isHex(commit, 64)) {
      throw const LanPairingError('bad_request');
    }
    final active = activeSession;
    if (active != null && active.deviceId != deviceId) {
      throw const LanPairingError('busy');
    }
    _starts.add(now);
    final session = LanPairingSession(
      id: hexOf(randomBytes(16, _random)),
      deviceId: deviceId,
      commit: commit,
      ns: hexOf(randomBytes(32, _random)),
      createdAt: now,
    );
    _active = session;
    return (sessionId: session.id, ns: session.ns);
  }

  void reveal({required String sessionId, required String nc}) {
    final session = _session(sessionId);
    if (session.code != null || !isHex(nc, 64)) {
      throw const LanPairingError('bad_request');
    }
    if (commitFor(nc) != session.commit) {
      _active = null;
      throw const LanPairingError('bad_commit');
    }
    session.code = pairingCodeFor(
      fingerprint: fingerprint,
      ns: session.ns,
      nc: nc,
      deviceId: session.deviceId,
    );
  }

  /// Returns the paired client's device id.
  String confirm({required String sessionId, required String proof}) {
    final session = _session(sessionId);
    final code = session.code;
    if (code == null) {
      throw const LanPairingError('bad_request');
    }
    _active = null;
    if (!constantTimeEquals(proof, pairingProofFor(code, session.ns))) {
      throw const LanPairingError('bad_proof');
    }
    return session.deviceId;
  }

  /// The pairing client gave up on [sessionId] (its code didn't match, or
  /// it cancelled): the session ends, so another device can pair at once.
  /// Checked like `reveal` and `confirm`: only that session's id.
  void abort({required String sessionId}) {
    _session(sessionId);
    _active = null;
  }

  /// The server's own screen ends the session (its Cancel button).
  void cancel() {
    _active = null;
  }

  LanPairingSession _session(String sessionId) {
    final session = _active;
    if (session == null || session.id != sessionId) {
      throw const LanPairingError('unknown_session');
    }
    if (_isExpired(session)) {
      _active = null;
      throw const LanPairingError('expired');
    }
    return session;
  }
}

/// Client side of one pairing attempt.
class LanPairingClient {
  LanPairingClient({
    required this.deviceId,
    required this.fingerprintSeen,
    Random? random,
  }) : nc = hexOf(randomBytes(32, random));

  final String deviceId;
  final String fingerprintSeen;
  final String nc;
  String? sessionId;
  String? ns;

  String get commit => commitFor(nc);

  void started({required String sessionId, required String ns}) {
    if (!isHex(ns, 64)) {
      throw const LanPairingError('bad_request');
    }
    this.sessionId = sessionId;
    this.ns = ns;
  }

  String get expectedCode {
    final serverNonce = ns;
    if (serverNonce == null) {
      throw StateError('Pairing not started');
    }
    return pairingCodeFor(
      fingerprint: fingerprintSeen,
      ns: serverNonce,
      nc: nc,
      deviceId: deviceId,
    );
  }

  bool matches(String typed) {
    return constantTimeEquals(normalizePairingCode(typed), expectedCode);
  }

  String get proof => pairingProofFor(expectedCode, ns!);
}

/// QR payload: carries the full fingerprint, so no code is needed.
class LanPairingQr {
  const LanPairingQr({
    required this.fingerprint,
    required this.port,
    required this.addresses,
    required this.deviceId,
    this.token,
  });

  static const String prefix = 'stockall-lan-pair:';

  final String fingerprint;
  final int port;
  final List<String> addresses;
  final String deviceId;

  /// What the scanning device exchanges for the secret it signs in with
  /// (`POST /v1/pair/qr`); valid for a few minutes.
  final String? token;

  String encode() {
    return prefix +
        jsonEncode({
          'v': 1,
          'fp': fingerprint,
          'port': port,
          'addrs': addresses,
          'dev': deviceId,
          if (token != null) 'tok': token,
        });
  }

  static LanPairingQr? decode(String raw) {
    if (!raw.startsWith(prefix)) return null;
    try {
      final json = jsonDecode(raw.substring(prefix.length));
      if (json is! Map<String, dynamic> || json['v'] != 1) return null;
      final fp = json['fp'];
      final port = json['port'];
      final addrs = json['addrs'];
      final dev = json['dev'];
      if (fp is! String || !isHex(fp.toLowerCase(), 64)) return null;
      if (port is! int || port < 1 || port > 65535) return null;
      if (addrs is! List || addrs.any((a) => a is! String)) return null;
      if (dev is! String || dev.isEmpty) return null;
      final tok = json['tok'];
      return LanPairingQr(
        fingerprint: fp.toLowerCase(),
        port: port,
        addresses: List<String>.from(addrs),
        deviceId: dev,
        token: tok is String && tok.isNotEmpty ? tok : null,
      );
    } on FormatException {
      return null;
    }
  }
}
