import 'package:stockall/main.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

/// Server-to-server calls: asking another server of the shop to prove
/// its claim, and telling an outranked one to step down. io only: import
/// it from io code (the transport) and tests.

/// Asks the server at [endpoints] to prove its claim. Unpinned when
/// [pin] is null (a server found by browsing: the proof is checked against
/// the certificate it presented); else only a server with that
/// certificate. Null when nothing answers or the proof fails.
Future<LanServerCandidate?> proveLanServer({
  required String shopKey,
  required List<LanEndpoint> endpoints,
  String? pin,
}) async {
  if (endpoints.isEmpty) return null;
  final connection =
      pin == null
          ? await LanConnection.openUnpinned(endpoints)
          : await LanConnection.open(endpoints, pin: pin);
  if (connection == null) return null;
  try {
    final nonce = LanPeerProof.nonce();
    final answer = await connection.postJson('/v1/peer/prove', {
      'nonce': nonce,
    });
    final viewJson = answer['view'];
    final mac = answer['mac'];
    final view =
        viewJson is Map
            ? LanServerView.fromJson(Map<String, dynamic>.from(viewJson))
            : null;
    if (view == null || mac is! String) return null;
    if (view.shopTag != shopTag(shopKey) ||
        !LanPeerProof.verify(
          shopKey: shopKey,
          nonce: nonce,
          fingerprint: connection.pin,
          view: view,
          mac: mac,
        )) {
      await mainLocalLog(
        'LAN peer: ${view.serverDeviceId} at ${connection.current.address} '
        'did not prove its claim',
      );
      return null;
    }
    return LanServerCandidate(
      view: view,
      fingerprint: connection.pin,
      addresses:
          {
            connection.current.address,
            for (final e in endpoints) e.address,
          }.toList(),
      port: connection.current.port,
    );
  } catch (_) {
    return null;
  } finally {
    connection.close();
  }
}

/// Tells the outranked server [loser] that this one ([selfAddresses],
/// [selfPort], [selfFingerprint]) is the shop's server. The loser proves
/// this server itself before acting (a notice is never trusted alone).
/// Best effort.
Future<bool> notifyLanServerSuperseded({
  required LanServerCandidate loser,
  required List<String> selfAddresses,
  required int selfPort,
  required String selfFingerprint,
}) async {
  final connection = await LanConnection.open([
    for (final a in loser.addresses) LanEndpoint(a, loser.port),
  ], pin: loser.fingerprint);
  if (connection == null) return false;
  try {
    await connection.postJson('/v1/server/superseded', {
      'kind': 'server',
      'addresses': selfAddresses,
      'port': selfPort,
      'fingerprint': selfFingerprint,
    });
    return true;
  } catch (e) {
    await mainLocalLog('LAN peer: superseded notice not delivered: $e');
    return false;
  } finally {
    connection.close();
  }
}
