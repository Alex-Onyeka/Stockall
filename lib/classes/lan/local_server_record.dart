import 'package:hive/hive.dart';

part 'local_server_record.g.dart';

/// Which device is the shop's LAN server. Every device keeps a copy.
///
/// `epoch` only ever increases. A server can only be set on a cleared record
/// (clear first, never two servers), and a device keeps whichever record has
/// the higher epoch.
@HiveType(typeId: 160)
class LocalServerRecord extends HiveObject {
  @HiveField(0)
  final int shopId;

  @HiveField(1)
  final int epoch;

  /// The server's device id. Null means cleared.
  @HiveField(2)
  final String? serverDeviceId;

  /// When the record last changed (claimed or cleared).
  @HiveField(3)
  final DateTime? claimedAt;

  /// The user who last changed the record (claimed or cleared).
  @HiveField(4)
  final String? claimedByUserId;

  @HiveField(5)
  final String? certFingerprint;

  /// A cache only. Real addresses come from discovery.
  @HiveField(6)
  final List<String> lastKnownAddresses;

  LocalServerRecord({
    required this.shopId,
    required this.epoch,
    this.serverDeviceId,
    this.claimedAt,
    this.claimedByUserId,
    this.certFingerprint,
    this.lastKnownAddresses = const [],
  });

  bool get isCleared => serverDeviceId == null;

  /// Sets [deviceId] as the server. Returns null (refused) unless [current]
  /// is cleared. A missing record counts as cleared at epoch 0. The new
  /// epoch is one above the higher of [current]'s and [highestKnownEpoch]
  /// (learned from the epoch floor, peers and servers before claiming).
  static LocalServerRecord? claim(
    LocalServerRecord? current, {
    required int shopId,
    required String deviceId,
    required String userId,
    required DateTime now,
    String? certFingerprint,
    int highestKnownEpoch = 0,
  }) {
    if (current != null && !current.isCleared) return null;
    final base = current?.epoch ?? 0;
    return LocalServerRecord(
      shopId: shopId,
      epoch: (base > highestKnownEpoch ? base : highestKnownEpoch) + 1,
      serverDeviceId: deviceId,
      claimedAt: now,
      claimedByUserId: userId,
      certFingerprint: certFingerprint,
    );
  }

  /// Clears the server. Returns null (no-op, no epoch bump) if [current] is
  /// missing or already cleared.
  static LocalServerRecord? clear(
    LocalServerRecord? current, {
    required String userId,
    required DateTime now,
  }) {
    if (current == null || current.isCleared) return null;
    return LocalServerRecord(
      shopId: current.shopId,
      epoch: current.epoch + 1,
      claimedAt: now,
      claimedByUserId: userId,
    );
  }

  /// The same record with a new address cache. Not an epoch change.
  LocalServerRecord withAddresses(List<String> addresses) {
    return LocalServerRecord(
      shopId: shopId,
      epoch: epoch,
      serverDeviceId: serverDeviceId,
      claimedAt: claimedAt,
      claimedByUserId: claimedByUserId,
      certFingerprint: certFingerprint,
      lastKnownAddresses: addresses,
    );
  }

  /// How far above the highest epoch a device knows a server claim may be
  /// before the device refuses to follow or step down for it. A claim takes
  /// the next epoch, and a force-clear one more, so a real server is never
  /// more than two ahead; a forged claim can't leap past them all.
  static const int maxEpochJump = 2;

  /// Whether [epoch] is at most [maxEpochJump] above [highestKnown].
  static bool withinEpochCap(int epoch, int highestKnown) =>
      epoch <= highestKnown + maxEpochJump;

  /// Whether [incoming] should replace [current]: same shop and a higher
  /// epoch; or the same epoch, both naming a server, different
  /// devices, and [incoming] outranks (a split network where both halves
  /// claimed). Otherwise an equal epoch keeps [current].
  static bool supersedes(
    LocalServerRecord incoming,
    LocalServerRecord? current,
  ) {
    if (current == null) return true;
    if (incoming.shopId != current.shopId) return false;
    if (incoming.epoch != current.epoch) return incoming.epoch > current.epoch;
    if (incoming.isCleared ||
        current.isCleared ||
        incoming.serverDeviceId == current.serverDeviceId) {
      return false;
    }
    return outranks(incoming, current);
  }

  /// Whether [a] outranks [b] as the shop's server: the higher
  /// epoch; then the earlier `claimedAt` (none counts as latest); then the
  /// lower device id.
  static bool outranks(LocalServerRecord a, LocalServerRecord b) =>
      compareRank(
        epoch: a.epoch,
        claimedAt: a.claimedAt,
        deviceId: a.serverDeviceId,
        otherEpoch: b.epoch,
        otherClaimedAt: b.claimedAt,
        otherDeviceId: b.serverDeviceId,
      ) >
      0;

  /// Positive when the first server outranks the other, negative when it
  /// is outranked, 0 when they are the same claim. Every device compares
  /// the same way, so both halves of a split agree on the winner.
  static int compareRank({
    required int epoch,
    required DateTime? claimedAt,
    required String? deviceId,
    required int otherEpoch,
    required DateTime? otherClaimedAt,
    required String? otherDeviceId,
  }) {
    if (epoch != otherEpoch) return epoch > otherEpoch ? 1 : -1;
    final at = claimedAt?.toUtc().millisecondsSinceEpoch;
    final otherAt = otherClaimedAt?.toUtc().millisecondsSinceEpoch;
    if (at != otherAt) {
      if (at == null) return -1;
      if (otherAt == null) return 1;
      return at < otherAt ? 1 : -1;
    }
    final d = deviceId ?? '';
    final o = otherDeviceId ?? '';
    if (d == o) return 0;
    return d.compareTo(o) < 0 ? 1 : -1;
  }

  factory LocalServerRecord.fromJson(Map<String, dynamic> json) {
    return LocalServerRecord(
      shopId: json['shop_id'] as int,
      epoch: json['epoch'] as int,
      serverDeviceId: json['server_device_id'] as String?,
      claimedAt:
          json['claimed_at'] != null
              ? DateTime.parse(json['claimed_at'])
              : null,
      claimedByUserId: json['claimed_by_user_id'] as String?,
      certFingerprint: json['cert_fingerprint'] as String?,
      lastKnownAddresses: List<String>.from(
        json['last_known_addresses'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'epoch': epoch,
      'server_device_id': serverDeviceId,
      'claimed_at': claimedAt?.toIso8601String(),
      'claimed_by_user_id': claimedByUserId,
      'cert_fingerprint': certFingerprint,
      'last_known_addresses': lastKnownAddresses,
    };
  }
}
