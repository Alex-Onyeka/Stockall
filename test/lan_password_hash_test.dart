import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_password_hash.dart';

void main() {
  String vector(int iterations) => hexOf(
    pbkdf2Sha256(utf8.encode('password'), utf8.encode('salt'), iterations, 32),
  );

  test('PBKDF2-HMAC-SHA256 matches the published vectors', () {
    // P="password", S="salt", dkLen=32: the commonly published SHA-256
    // vectors, all also checked with Python's hashlib.pbkdf2_hmac.
    expect(
      vector(1),
      '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
    );
    expect(
      vector(2),
      'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
    );
    expect(
      vector(4096),
      'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
    );
  });

  test('hash then verify: right password only', () async {
    final stored = await hashPassword('s3cret!', iterations: 1000);

    expect(stored.iterations, 1000);
    expect(isHex(stored.salt, LanConstants.pbkdf2SaltBytes * 2), isTrue);
    expect(isHex(stored.hash, LanConstants.pbkdf2KeyBytes * 2), isTrue);
    expect(await verifyPassword('s3cret!', stored), isTrue);
    expect(await verifyPassword('s3cret', stored), isFalse);
    expect(await verifyPassword('S3cret!', stored), isFalse);
  });

  test('every hash gets its own salt; a given salt reproduces it', () async {
    final a = await hashPassword('same', iterations: 1000);
    final b = await hashPassword('same', iterations: 1000);
    final again = await hashPassword(
      'same',
      saltHex: a.salt,
      iterations: 1000,
    );

    expect(a.salt, isNot(b.salt));
    expect(a.hash, isNot(b.hash));
    expect(again.hash, a.hash);
  });

  test('the default iteration count is the D9 floor', () async {
    expect(LanConstants.pbkdf2Iterations, greaterThanOrEqualTo(100000));
    expect(lanDummyPasswordHash.iterations, LanConstants.pbkdf2Iterations);
    expect(await verifyPassword('anything', lanDummyPasswordHash), isFalse);
  });
}
