import 'package:hive/hive.dart';

part 'lan_paired_server.g.dart';

/// A LAN server this device has paired with: the pinned certificate
/// fingerprint plus where it was last reached. Device-level trust, so it is
/// not cleared when switching stores or logging out.
@HiveType(typeId: 161)
class LanPairedServer extends HiveObject {
  @HiveField(0)
  final String serverDeviceId;

  /// Lower-case hex SHA-256 of the server certificate (the pin).
  @HiveField(1)
  final String certFingerprint;

  @HiveField(2)
  final int port;

  /// A cache only. Discovery is tried first.
  @HiveField(3)
  final List<String> addresses;

  @HiveField(4)
  final DateTime pairedAt;

  @HiveField(5)
  final String? label;

  LanPairedServer({
    required this.serverDeviceId,
    required this.certFingerprint,
    required this.port,
    this.addresses = const [],
    required this.pairedAt,
    this.label,
  });

  LanPairedServer withAddresses(List<String> newAddresses, {int? newPort}) {
    return LanPairedServer(
      serverDeviceId: serverDeviceId,
      certFingerprint: certFingerprint,
      port: newPort ?? port,
      addresses: newAddresses,
      pairedAt: pairedAt,
      label: label,
    );
  }
}
