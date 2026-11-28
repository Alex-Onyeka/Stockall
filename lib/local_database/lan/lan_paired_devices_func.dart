import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Who may sign in on this device's LAN server, and how a till proves it
/// was paired. No adapters: plain boxes. Device data (pairing is between
/// devices): not cleared on logout.
/// - [devicesBox] (server): `shopId|deviceId` of each device paired for a
///   store → the SHA-256 (hex) of the secret it was given when it paired.
/// - [formerServersBox] (server): certificate fingerprints of servers of
///   the shop this one proved it outranks → when (ms since epoch). A move
///   one of them signed lets its paired tills sign in here.
/// - [secretsBox] (till): each paired server's fingerprint → the secret
///   it gave this device.
/// - [movesBox] (till): a server's fingerprint → the signed `moved` event
///   (JSON) this device followed there, kept until it first signs in
///   there, so a restart in between doesn't force pairing again.
class LanPairedDevicesFunc {
  static final LanPairedDevicesFunc instance = LanPairedDevicesFunc._internal();
  factory LanPairedDevicesFunc() => instance;
  LanPairedDevicesFunc._internal();

  late Box<String> devicesBox;
  late Box<int> formerServersBox;
  late Box<String> secretsBox;
  late Box<String> movesBox;
  final String devicesBoxName = 'lanPairedDevicesBoxStockall';
  final String formerServersBoxName = 'lanFormerServersBoxStockall';
  final String secretsBoxName = 'lanPairSecretsBoxStockall';
  final String movesBoxName = 'lanFollowedMovesBoxStockall';

  Future<void> init() async {
    try {
      devicesBox = await openBoxSafely<String>(devicesBoxName);
      formerServersBox = await openBoxSafely<int>(formerServersBoxName);
      secretsBox = await openBoxSafely<String>(secretsBoxName);
      movesBox = await openBoxSafely<String>(movesBoxName);
      await mainLocalLog('✅ LAN Paired Devices Boxes Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Paired Devices Boxes: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  bool get _serverOpen =>
      Hive.isBoxOpen(devicesBoxName) && Hive.isBoxOpen(formerServersBoxName);

  static String _deviceKey(int shopId, String deviceId) => '$shopId|$deviceId';

  String? secretHashOf(int shopId, String deviceId) =>
      _serverOpen ? devicesBox.get(_deviceKey(shopId, deviceId)) : null;

  Future<void> putSecretHash(int shopId, String deviceId, String hash) async {
    if (_serverOpen) await devicesBox.put(_deviceKey(shopId, deviceId), hash);
  }

  /// The devices paired for [shopId].
  List<String> pairedDeviceIds(int shopId) {
    if (!_serverOpen) return const [];
    final prefix = '$shopId|';
    return [
      for (final k in devicesBox.keys)
        if ('$k'.startsWith(prefix)) '$k'.substring(prefix.length),
    ];
  }

  bool isFormerServer(String fingerprint) =>
      _serverOpen && formerServersBox.containsKey(fingerprint);

  Future<void> addFormerServer(String fingerprint) async {
    if (!_serverOpen) return;
    await formerServersBox.put(
      fingerprint,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  String? secretFor(String serverFingerprint) =>
      Hive.isBoxOpen(secretsBoxName) ? secretsBox.get(serverFingerprint) : null;

  Future<void> putSecret(String serverFingerprint, String secret) async {
    if (Hive.isBoxOpen(secretsBoxName)) {
      await secretsBox.put(serverFingerprint, secret);
    }
  }

  Map<String, dynamic>? moveTo(String serverFingerprint) {
    if (!Hive.isBoxOpen(movesBoxName)) return null;
    final json = movesBox.get(serverFingerprint);
    if (json == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> putMove(
    String serverFingerprint,
    Map<String, dynamic> event,
  ) async {
    if (Hive.isBoxOpen(movesBoxName)) {
      await movesBox.put(serverFingerprint, jsonEncode(event));
    }
  }

  Future<void> removeMove(String serverFingerprint) async {
    if (Hive.isBoxOpen(movesBoxName)) await movesBox.delete(serverFingerprint);
  }
}
