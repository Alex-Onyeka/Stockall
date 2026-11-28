import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

/// A server's proof that it holds the shop's claim it advertises.
/// Pure: no I/O.
///
/// An advert or an unauthenticated `GET /v1/server` is only a hint: acting
/// on one would let anything on the network demote the shop's server. So
/// a server answers `POST /v1/peer/prove {nonce}` with its view and an
/// HMAC-SHA256, keyed from the shop key, over the nonce, the fingerprint of
/// its own TLS certificate and its claim. The verifier uses the fingerprint
/// it saw on the TLS connection, so a proof can't be replayed from another
/// machine or certificate.
///
/// Limit: every signed-in device of the shop holds the shop key, so one of
/// them could forge a proof. Devices outside the shop can't.
class LanPeerProof {
  LanPeerProof._();

  static const String version = 'stockall-peer-v1';

  /// The nonce of a cleared notice: the device that sends it
  /// has no nonce from the server, so the mac is bound to the server's
  /// certificate and the cleared claim only.
  static const String clearedNotice = 'cleared-notice';

  static List<int> _key(String shopKey) =>
      Hmac(sha256, utf8.encode(shopKey)).convert(utf8.encode(version)).bytes;

  static String _message({
    required String nonce,
    required String fingerprint,
    required LanServerView view,
  }) => [
    version,
    nonce,
    fingerprint,
    view.shopTag,
    view.epoch,
    view.claimedAt?.toUtc().millisecondsSinceEpoch ?? '',
    view.serverDeviceId ?? '',
    view.cleared,
  ].join('|');

  static String mac({
    required String shopKey,
    required String nonce,
    required String fingerprint,
    required LanServerView view,
  }) => base64Url.encode(
    Hmac(sha256, _key(shopKey))
        .convert(
          utf8.encode(
            _message(nonce: nonce, fingerprint: fingerprint, view: view),
          ),
        )
        .bytes,
  );

  /// Whether [mac] proves [view] for the server whose TLS certificate has
  /// [fingerprint], answering [nonce], in the shop of [shopKey].
  static bool verify({
    required String shopKey,
    required String nonce,
    required String fingerprint,
    required LanServerView view,
    required String mac,
  }) {
    if (view.shopTag != shopTag(shopKey)) return false;
    final expected = LanPeerProof.mac(
      shopKey: shopKey,
      nonce: nonce,
      fingerprint: fingerprint,
      view: view,
    );
    if (expected.length != mac.length) return false;
    var diff = 0;
    for (var i = 0; i < mac.length; i++) {
      diff |= expected.codeUnitAt(i) ^ mac.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// 16 random bytes, base64url.
  static String nonce([Random? random]) {
    final r = random ?? Random.secure();
    return base64Url.encode([for (var i = 0; i < 16; i++) r.nextInt(256)]);
  }
}
