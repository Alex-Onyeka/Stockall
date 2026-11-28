import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:stockall/services/lan/lan_constants.dart';

/// Crockford base32 alphabet: no I, L, O or U, so typed codes are easy to read.
const String crockfordAlphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Encodes the leading bits of [bytes] as [length] Crockford base32
/// characters (5 bits each).
String crockfordEncode(List<int> bytes, int length) {
  final out = StringBuffer();
  var buffer = 0;
  var bits = 0;
  var index = 0;
  while (out.length < length) {
    if (bits < 5) {
      if (index >= bytes.length) {
        throw ArgumentError('Not enough bytes for $length characters');
      }
      buffer = (buffer << 8) | (bytes[index++] & 0xff);
      bits += 8;
    }
    bits -= 5;
    out.write(crockfordAlphabet[(buffer >> bits) & 31]);
    buffer &= (1 << bits) - 1;
  }
  return out.toString();
}

/// Normalizes a code typed by a person: upper case, separators removed,
/// and the look-alike letters O, I and L read as 0, 1 and 1.
String normalizePairingCode(String input) {
  return input
      .toUpperCase()
      .replaceAll(RegExp(r'[\s\-_.]'), '')
      .replaceAll('O', '0')
      .replaceAll('I', '1')
      .replaceAll('L', '1');
}

/// Opaque tag advertised over mDNS instead of the shop id (`tv=2`): an HMAC
/// keyed by the shop's secret `lan_key`, so it can't be matched to a shop
/// id without the key.
String shopTag(String shopKey) {
  return Hmac(sha256, utf8.encode(shopKey))
      .convert(utf8.encode('stockall-shop-tag-v2'))
      .toString()
      .substring(0, 16);
}

/// A new session token: 32 random bytes, base64url without padding.
String newSessionToken([Random? random]) {
  return base64Url
      .encode(randomBytes(LanConstants.sessionTokenBytes, random))
      .replaceAll('=', '');
}

/// What the server stores instead of a session token.
String hashSessionToken(String token) {
  return sha256.convert(utf8.encode(token)).toString();
}

String hexOf(List<int> bytes) {
  final out = StringBuffer();
  for (final b in bytes) {
    out.write((b & 0xff).toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}

List<int> randomBytes(int length, [Random? random]) {
  final source = random ?? Random.secure();
  return List<int>.generate(length, (_) => source.nextInt(256));
}

bool isHex(String value, int length) {
  return value.length == length && RegExp(r'^[0-9a-f]+$').hasMatch(value);
}

/// Compares two strings without stopping at the first difference.
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
