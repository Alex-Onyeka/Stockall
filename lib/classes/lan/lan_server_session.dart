import 'package:hive/hive.dart';

part 'lan_server_session.g.dart';

/// A signed-in LAN client, as the server stores it: only the SHA-256 of
/// the token, bound to one device. One per device and user.
@HiveType(typeId: 163)
class LanServerSession extends HiveObject {
  @HiveField(0)
  final String tokenHash;

  @HiveField(1)
  final int shopId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String deviceId;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime expiresAt;

  @HiveField(6)
  final DateTime lastUsedAt;

  LanServerSession({
    required this.tokenHash,
    required this.shopId,
    required this.userId,
    required this.deviceId,
    required this.createdAt,
    required this.expiresAt,
    required this.lastUsedAt,
  });

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  LanServerSession touched(DateTime now, Duration ttl) {
    return LanServerSession(
      tokenHash: tokenHash,
      shopId: shopId,
      userId: userId,
      deviceId: deviceId,
      createdAt: createdAt,
      expiresAt: now.add(ttl),
      lastUsedAt: now,
    );
  }
}
