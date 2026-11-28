import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/lan/lan_codes.dart';

void main() {
  group('crockfordEncode', () {
    test('all-zero bits give zeros', () {
      expect(crockfordEncode([0, 0, 0, 0, 0], 8), '00000000');
    });

    test('all-one bits give Z', () {
      expect(crockfordEncode([255, 255, 255, 255, 255], 8), 'ZZZZZZZZ');
    });

    test('reads 5 bits at a time across byte boundaries', () {
      // 00001 repeated eight times.
      expect(crockfordEncode([0x08, 0x42, 0x10, 0x84, 0x21], 8), '11111111');
    });

    test('never uses I, L, O or U', () {
      expect(crockfordAlphabet, isNot(matches(RegExp('[ILOU]'))));
    });

    test('throws when there are not enough bytes', () {
      expect(() => crockfordEncode([1, 2], 8), throwsArgumentError);
    });
  });

  test('normalizePairingCode reads look-alikes and drops separators', () {
    expect(normalizePairingCode(' ab-cd oil '), 'ABCD011');
    expect(normalizePairingCode('7k2q.9x_4m'), '7K2Q9X4M');
  });

  test('shopTag (tv=2) is an HMAC of the shop key, 16 hex characters', () {
    final key = '0123456789abcdef' * 4;
    // HMAC-SHA256(key, 'stockall-shop-tag-v2'), computed independently.
    expect(shopTag(key), 'a686906d9e007a13');
    expect(shopTag(key), matches(RegExp(r'^[0-9a-f]{16}$')));
    expect(shopTag(key), isNot(shopTag('f' * 64)));
  });

  test('session tokens are random base64url; only their SHA-256 is kept', () {
    final a = newSessionToken();
    final b = newSessionToken();
    expect(a, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(a, isNot(b));
    expect(
      hashSessionToken('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('constantTimeEquals', () {
    expect(constantTimeEquals('ABCD', 'ABCD'), isTrue);
    expect(constantTimeEquals('ABCD', 'ABCE'), isFalse);
    expect(constantTimeEquals('ABC', 'ABCD'), isFalse);
  });

  test('hexOf and isHex', () {
    expect(hexOf([0, 15, 255]), '000fff');
    expect(isHex('00ff', 4), isTrue);
    expect(isHex('00FF', 4), isFalse);
    expect(isHex('00f', 4), isFalse);
  });
}
