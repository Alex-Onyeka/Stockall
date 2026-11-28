import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_constants.dart';

/// This device's self-signed LAN server certificate. Clients pin its
/// SHA-256 fingerprint; there is no certificate authority.
class LanTlsIdentity {
  LanTlsIdentity({
    required this.certificatePem,
    required this.privateKeyPem,
  });

  final String certificatePem;
  final String privateKeyPem;

  Uint8List get certificateDer =>
      CryptoUtils.getBytesFromPEMString(certificatePem);

  /// Lower-case hex SHA-256 of the certificate DER. This is the pin.
  String get fingerprint => fingerprintOfDer(certificateDer);

  SecurityContext serverContext() {
    return SecurityContext(withTrustedRoots: false)
      ..useCertificateChainBytes(utf8.encode(certificatePem))
      ..usePrivateKeyBytes(utf8.encode(privateKeyPem));
  }

  /// EC P-256 key and a self-signed certificate for [LanConstants.tlsHost].
  static LanTlsIdentity generate({int days = 3650}) {
    final pair = CryptoUtils.generateEcKeyPair();
    final privateKey = pair.privateKey as ECPrivateKey;
    final publicKey = pair.publicKey as ECPublicKey;
    final csr = X509Utils.generateEccCsrPem(
      {'CN': 'Stockall LAN Server', 'O': 'Stockall'},
      privateKey,
      publicKey,
    );
    final certificate = X509Utils.generateSelfSignedCertificate(
      privateKey,
      csr,
      days,
      sans: [LanConstants.tlsHost],
    );
    return LanTlsIdentity(
      certificatePem: certificate,
      privateKeyPem: CryptoUtils.encodeEcPrivateKeyToPem(privateKey),
    );
  }

  /// The stored identity, or a new one saved for next time. It is never
  /// regenerated automatically: a new certificate means every client must
  /// pair again.
  static Future<LanTlsIdentity> loadOrCreate() async {
    final stored = DeviceIdentity().tlsPems();
    if (stored != null) {
      return LanTlsIdentity(
        certificatePem: stored.certificatePem,
        privateKeyPem: stored.privateKeyPem,
      );
    }
    final created = generate();
    await DeviceIdentity().saveTlsPems(
      certificatePem: created.certificatePem,
      privateKeyPem: created.privateKeyPem,
    );
    return created;
  }
}

String fingerprintOfDer(List<int> der) => sha256.convert(der).toString();

bool pinMatches(X509Certificate certificate, String pin) {
  return fingerprintOfDer(certificate.der) == pin.toLowerCase();
}
