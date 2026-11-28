import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';
import 'package:uuid/uuid.dart';

/// A stable identity for this installation, used by LAN sync in place of an
/// IP address. Generated on first use and stored in its own Hive box, which
/// is never cleared by `clearAllShopData`.
class DeviceIdentity {
  static final DeviceIdentity _instance = DeviceIdentity._internal();
  factory DeviceIdentity() => _instance;
  DeviceIdentity._internal();

  late Box<String> deviceIdentityBox;
  final String deviceIdentityBoxName = 'deviceIdentityBoxStockall';
  static const String _deviceIdKey = 'device_id';
  static const String _tlsCertKey = 'tls_cert_pem';
  static const String _tlsKeyKey = 'tls_key_pem';

  Future<void> init() async {
    try {
      deviceIdentityBox = await openBoxSafely<String>(
        deviceIdentityBoxName,
      );
      await mainLocalLog('✅ Device Identity Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Device Identity Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// This device's id. Created and stored the first time it is read.
  Future<String> deviceId() async {
    final existing = deviceIdentityBox.get(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final created = const Uuid().v4();
    await deviceIdentityBox.put(_deviceIdKey, created);
    await mainLocalLog('Device Identity Created');
    return created;
  }

  /// This device's LAN server certificate and key, if one was generated.
  ({String certificatePem, String privateKeyPem})? tlsPems() {
    final cert = deviceIdentityBox.get(_tlsCertKey);
    final key = deviceIdentityBox.get(_tlsKeyKey);
    if (cert == null || key == null || cert.isEmpty || key.isEmpty) {
      return null;
    }
    return (certificatePem: cert, privateKeyPem: key);
  }

  Future<void> saveTlsPems({
    required String certificatePem,
    required String privateKeyPem,
  }) async {
    await deviceIdentityBox.put(_tlsCertKey, certificatePem);
    await deviceIdentityBox.put(_tlsKeyKey, privateKeyPem);
  }
}
