import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

/// A server's signature over "the shop's server is now [LanServerCandidate]",
/// made with the private key of its own TLS certificate. A till verifies it
/// against the certificate fingerprint it pinned when a person paired it,
/// so only the server it already trusts can send it to a new one. A proof
/// made with the shop key alone can't do this: every signed-in device of
/// the shop holds that key.
///
/// Pure: no I/O.
class LanMoveProof {
  LanMoveProof._();

  static const String version = 'stockall-moved-v1';
  static const String _algorithm = 'SHA-256/ECDSA';

  /// The signed text: who is moving away, at which epoch, exactly which
  /// server (certificate and claim) the till may follow, and the devices
  /// paired with the server moving away (the new server lets them sign
  /// in).
  static String message({
    required String shopTag,
    required String fromDeviceId,
    required int fromEpoch,
    required LanServerCandidate to,
    List<String> paired = const [],
  }) => [
    version,
    shopTag,
    fromDeviceId,
    fromEpoch,
    to.fingerprint.toLowerCase(),
    to.view.serverDeviceId ?? '',
    to.view.epoch,
    to.view.claimedAt?.toUtc().millisecondsSinceEpoch ?? '',
    (List.of(paired)..sort()).join(','),
  ].join('|');

  /// The SHA-256 fingerprint of [certificatePem]; null if it isn't one.
  static String? fingerprintOf(String certificatePem) {
    try {
      return fingerprintOfDer(CryptoUtils.getBytesFromPEMString(certificatePem));
    } catch (_) {
      return null;
    }
  }

  /// Base64 DER ECDSA signature of [text] with [privateKeyPem].
  static String sign(String privateKeyPem, String text) {
    final key = CryptoUtils.ecPrivateKeyFromPem(privateKeyPem);
    final signature = CryptoUtils.ecSign(
      key,
      Uint8List.fromList(utf8.encode(text)),
      algorithmName: _algorithm,
    );
    return CryptoUtils.ecSignatureToBase64(signature);
  }

  /// Whether [signature] over [text] was made by the key of [certificatePem],
  /// and that certificate is the one pinned as [pinnedFingerprint]. Never
  /// throws: anything malformed is false.
  static bool verify({
    required String certificatePem,
    required String pinnedFingerprint,
    required String text,
    required String signature,
  }) {
    try {
      final der = CryptoUtils.getBytesFromPEMString(certificatePem);
      if (fingerprintOfDer(der) != pinnedFingerprint.toLowerCase()) {
        return false;
      }
      final spkiHex = X509Utils.x509CertificateFromPem(
        certificatePem,
      ).tbsCertificate?.subjectPublicKeyInfo.bytes;
      if (spkiHex == null) return false;
      final publicKey = CryptoUtils.ecPublicKeyFromDerBytes(_hexBytes(spkiHex));
      return CryptoUtils.ecVerify(
        publicKey,
        Uint8List.fromList(utf8.encode(text)),
        CryptoUtils.ecSignatureFromBase64(signature),
        algorithm: _algorithm,
      );
    } catch (_) {
      return false;
    }
  }

  static Uint8List _hexBytes(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    return Uint8List.fromList([
      for (var i = 0; i + 1 < clean.length; i += 2)
        int.parse(clean.substring(i, i + 2), radix: 16),
    ]);
  }
}
