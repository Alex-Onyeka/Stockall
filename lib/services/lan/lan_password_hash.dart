import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';

/// A stored PBKDF2-HMAC-SHA256 password hash.
class LanPasswordHash {
  const LanPasswordHash({
    required this.salt,
    required this.hash,
    required this.iterations,
  });

  /// Hex.
  final String salt;

  /// Hex.
  final String hash;
  final int iterations;
}

/// PBKDF2-HMAC-SHA256 (RFC 8018). Synchronous: call through [hashPassword]
/// or [verifyPassword], which run it off the UI isolate.
Uint8List pbkdf2Sha256(
  List<int> password,
  List<int> salt,
  int iterations,
  int length,
) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(Uint8List.fromList(salt), iterations, length));
  return derivator.process(Uint8List.fromList(password));
}

String _deriveHex((String, String, int) args) {
  final (password, saltHex, iterations) = args;
  return hexOf(
    pbkdf2Sha256(
      utf8.encode(password),
      _bytesOfHex(saltHex),
      iterations,
      LanConstants.pbkdf2KeyBytes,
    ),
  );
}

List<int> _bytesOfHex(String hex) {
  return [
    for (var i = 0; i + 1 < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ];
}

Future<String> _derive(String password, String saltHex, int iterations) {
  return compute(_deriveHex, (password, saltHex, iterations));
}

/// Hashes [password] with a new random salt (or [saltHex]).
Future<LanPasswordHash> hashPassword(
  String password, {
  String? saltHex,
  int iterations = LanConstants.pbkdf2Iterations,
}) async {
  final salt = saltHex ?? hexOf(randomBytes(LanConstants.pbkdf2SaltBytes));
  return LanPasswordHash(
    salt: salt,
    hash: await _derive(password, salt, iterations),
    iterations: iterations,
  );
}

/// Whether [password] matches [stored], compared in constant time.
Future<bool> verifyPassword(String password, LanPasswordHash stored) async {
  final derived = await _derive(password, stored.salt, stored.iterations);
  return constantTimeEquals(derived, stored.hash);
}

/// Checked for unknown emails, so they take as long as wrong passwords.
const LanPasswordHash lanDummyPasswordHash = LanPasswordHash(
  salt: '00000000000000000000000000000000',
  hash: '0000000000000000000000000000000000000000000000000000000000000000',
  iterations: LanConstants.pbkdf2Iterations,
);
