import 'package:hive/hive.dart';

part 'lan_client_session.g.dart';

/// This device's session with the LAN server of a shop, from a LAN login.
@HiveType(typeId: 164)
class LanClientSession extends HiveObject {
  @HiveField(0)
  final String serverDeviceId;

  @HiveField(1)
  final int shopId;

  @HiveField(2)
  final String userId;

  /// Sent as `Authorization: Bearer`.
  @HiveField(3)
  final String token;

  @HiveField(4)
  final DateTime expiresAt;

  @HiveField(5)
  final DateTime createdAt;

  LanClientSession({
    required this.serverDeviceId,
    required this.shopId,
    required this.userId,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
  });
}
