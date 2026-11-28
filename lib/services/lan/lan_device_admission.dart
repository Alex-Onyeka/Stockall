import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';

/// The devices that paired with this LAN server for the store it serves:
/// each got a secret when it paired, which it presents to sign in. Only
/// the secret's hash is kept.
abstract class LanDeviceAdmission {
  /// A new secret for [deviceId] (any earlier one stops working), or null
  /// when [deviceId] is already paired and [byPerson] isn't set: only a
  /// person pairing it again (the code flow) replaces its secret, so a
  /// scanned QR code or a move can't take over a paired device's id.
  Future<String?> admit(String deviceId, {bool byPerson = false});

  /// Whether [secret] is the one [deviceId] was given.
  bool admitted(String deviceId, String? secret);

  /// Whether [deviceId] is paired here.
  bool isPaired(String deviceId) => deviceIds().contains(deviceId);

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

/// Kept on the server's Hive ([LanPairedDevicesFunc]), per store: a
/// device paired while this desktop served one store isn't paired for
/// another.
class LanHiveAdmission extends LanDeviceAdmission {
  LanHiveAdmission({required this.shopId});

  /// The store served now.
  final int Function() shopId;

  @override
  Future<String?> admit(String deviceId, {bool byPerson = false}) async {
    if (!byPerson && isPaired(deviceId)) return null;
    final secret = _newSecret();
    await LanPairedDevicesFunc().putSecretHash(
      shopId(),
      deviceId,
      _hashOf(secret),
    );
    return secret;
  }

  @override
  bool admitted(String deviceId, String? secret) {
    final hash = LanPairedDevicesFunc().secretHashOf(shopId(), deviceId);
    return hash != null && secret != null && _same(hash, _hashOf(secret));
  }

  @override
  List<String> deviceIds() => LanPairedDevicesFunc().pairedDeviceIds(shopId());
}

/// Kept in memory (tests).
class LanMemoryAdmission extends LanDeviceAdmission {
  final _hashes = <String, String>{};

  @override
  Future<String?> admit(String deviceId, {bool byPerson = false}) async {
    if (!byPerson && isPaired(deviceId)) return null;
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
