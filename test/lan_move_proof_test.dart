import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_move_proof.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

void main() {
  final from = LanTlsIdentity.generate();
  final forger = LanTlsIdentity.generate();
  final to = LanServerCandidate(
    view: LanServerView(
      shopTag: shopTag('shop-key-7'),
      epoch: 3,
      serverDeviceId: 'new-desk',
      cleared: false,
      claimedAt: DateTime.utc(2026, 11, 20, 9),
    ),
    fingerprint: 'ab' * 32,
    addresses: const ['127.0.0.1'],
    port: 47811,
  );
  String text({LanServerCandidate? target, int fromEpoch = 2}) =>
      LanMoveProof.message(
        shopTag: shopTag('shop-key-7'),
        fromDeviceId: 'old-desk',
        fromEpoch: fromEpoch,
        to: target ?? to,
      );

  test('a move signed with the pinned certificate\'s key verifies', () {
    final sig = LanMoveProof.sign(from.privateKeyPem, text());
    expect(
      LanMoveProof.verify(
        certificatePem: from.certificatePem,
        pinnedFingerprint: from.fingerprint,
        text: text(),
        signature: sig,
      ),
      isTrue,
    );
  });

  test('another certificate, even with a valid signature of its own, is '
      'not the pinned one', () {
    final sig = LanMoveProof.sign(forger.privateKeyPem, text());
    expect(
      LanMoveProof.verify(
        certificatePem: forger.certificatePem,
        pinnedFingerprint: from.fingerprint,
        text: text(),
        signature: sig,
      ),
      isFalse,
    );
  });

  test('the pinned certificate with a signature made by another key fails',
      () {
    final sig = LanMoveProof.sign(forger.privateKeyPem, text());
    expect(
      LanMoveProof.verify(
        certificatePem: from.certificatePem,
        pinnedFingerprint: from.fingerprint,
        text: text(),
        signature: sig,
      ),
      isFalse,
    );
  });

  test('a signature for one move doesn\'t cover another target or epoch', () {
    final sig = LanMoveProof.sign(from.privateKeyPem, text());
    final elsewhere = LanServerCandidate(
      view: to.view,
      fingerprint: 'cd' * 32,
      addresses: to.addresses,
      port: to.port,
    );
    for (final changed in [text(target: elsewhere), text(fromEpoch: 3)]) {
      expect(
        LanMoveProof.verify(
          certificatePem: from.certificatePem,
          pinnedFingerprint: from.fingerprint,
          text: changed,
          signature: sig,
        ),
        isFalse,
      );
    }
  });

  test('garbage never throws: false', () {
    expect(
      LanMoveProof.verify(
        certificatePem: 'not a certificate',
        pinnedFingerprint: from.fingerprint,
        text: text(),
        signature: 'not a signature',
      ),
      isFalse,
    );
    expect(
      LanMoveProof.verify(
        certificatePem: from.certificatePem,
        pinnedFingerprint: from.fingerprint,
        text: text(),
        signature: 'not a signature',
      ),
      isFalse,
    );
  });
}
