import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';

/// The devices that paired with this LAN server: each got a secret when it
/// paired, which it presents to sign in. Only the secret's hash is kept.
abstract class LanDeviceAdmission {
  /// A new secret for [deviceId] (any earlier one stops working).
  Future<String> admit(String deviceId);

  /// Whether [secret] is the one [deviceId] was given.
  bool admitted(String deviceId, String? secret);

  /// The devices that paired here.
  List<String> deviceIds();
}

String _newSecret() {
  final random = Random.secure();
  return base64Url
      .encode([for (var i = 0; i < 32; i++) random.nextInt(256)])
      .replaceAll('=', '');
}

String _hashOf(String secret) => sha256.convert(utf8.encode(secret)).toString();

/// Compares in time independent of where they differ.
bool _same(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Kept on the server's Hive ([LanPairedDevicesFunc]).
class LanHiveAdmission implements LanDeviceAdmission {
  const LanHiveAdmission();

  @override
  Future<String> admit(String deviceId) async {
    final secret = _newSecret();
    await LanPairedDevicesFunc().putSecretHash(deviceId, _hashOf(secret));
    return secret;
  }

  @override
  bool admitted(String deviceId, String? secret) {
    final hash = LanPairedDevicesFunc().secretHashOf(deviceId);
    return hash != null && secret != null && _same(hash, _hashOf(secret));
  }

  @override
  List<String> deviceIds() => LanPairedDevicesFunc().pairedDeviceIds();
}

/// Kept in memory (tests).
class LanMemoryAdmission implements LanDeviceAdmission {
  final _hashes = <String, String>{};

  @override
  Future<String> admit(String deviceId) async {
    final secret = _newSecret();
    _hashes[deviceId] = _hashOf(secret);
    return secret;
  }

  @override
  bool admitted(String deviceId, String? secret) {
    final hash = _hashes[deviceId];
    return hash != null && secret != null && _same(hash, _hashOf(secret));
  }

  @override
  List<String> deviceIds() => _hashes.keys.toList();
}
