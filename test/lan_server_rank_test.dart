import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_server_watch.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

/// Two servers, pure parts: the winner rule, the proof and the watch's
/// decisions.
void main() {
  final t1 = DateTime.utc(2026, 11, 20, 9);
  final t2 = DateTime.utc(2026, 11, 20, 10);
  const key = 'shop-key-7';

  LocalServerRecord serving(int epoch, String device, DateTime? at) =>
      LocalServerRecord(
        shopId: 7,
        epoch: epoch,
        serverDeviceId: device,
        claimedAt: at,
      );

  LanServerView view(
    int epoch,
    String device,
    DateTime? at, {
    bool cleared = false,
    String? tag,
  }) => LanServerView(
    shopTag: tag ?? shopTag(key),
    epoch: epoch,
    serverDeviceId: device,
    cleared: cleared,
    claimedAt: at,
  );

  LanServerCandidate candidate(LanServerView v) => LanServerCandidate(
    view: v,
    fingerprint: 'fp-${v.serverDeviceId}',
    addresses: const ['127.0.0.1'],
    port: 1,
  );

  group('the winner rule', () {
    test('higher epoch, then earlier claimed_at, then lower device id', () {
      // Epoch first, whatever the rest.
      expect(
        LocalServerRecord.outranks(serving(3, 'z', t2), serving(2, 'a', t1)),
        isTrue,
      );
      // Same epoch: the earlier claim.
      expect(
        LocalServerRecord.outranks(serving(2, 'z', t1), serving(2, 'a', t2)),
        isTrue,
      );
      // A claim with no time loses to one with a time.
      expect(
        LocalServerRecord.outranks(serving(2, 'a', null), serving(2, 'z', t2)),
        isFalse,
      );
      // Same epoch and time: the lower device id.
      expect(
        LocalServerRecord.outranks(serving(2, 'a', t1), serving(2, 'b', t1)),
        isTrue,
      );
      // The same claim outranks nothing.
      expect(
        LocalServerRecord.outranks(serving(2, 'a', t1), serving(2, 'a', t1)),
        isFalse,
      );
    });

    test('both sides agree: exactly one of two claims outranks the other', () {
      final claims = [
        serving(2, 'a', t1),
        serving(2, 'b', t1),
        serving(2, 'a', t2),
        serving(3, 'b', null),
        serving(2, 'c', null),
      ];
      for (final x in claims) {
        for (final y in claims) {
          if (identical(x, y)) continue;
          expect(
            LocalServerRecord.outranks(x, y) !=
                LocalServerRecord.outranks(y, x),
            isTrue,
            reason:
                '${x.epoch}/${x.serverDeviceId} vs ${y.epoch}/'
                '${y.serverDeviceId}',
          );
        }
      }
    });

    test('supersedes: an equal epoch from a split network resolves to the '
        'outranking claim; a cleared record or the same device does not '
        'replace', () {
      expect(
        LocalServerRecord.supersedes(serving(2, 'a', t1), serving(2, 'b', t2)),
        isTrue,
      );
      expect(
        LocalServerRecord.supersedes(serving(2, 'b', t2), serving(2, 'a', t1)),
        isFalse,
      );
      final cleared = LocalServerRecord(shopId: 7, epoch: 2, claimedAt: t1);
      expect(
        LocalServerRecord.supersedes(cleared, serving(2, 'b', t2)),
        isFalse,
      );
      expect(
        LocalServerRecord.supersedes(serving(2, 'a', t1), cleared),
        isFalse,
      );
      // Same device, another claim time: not a conflict.
      expect(
        LocalServerRecord.supersedes(serving(2, 'a', t1), serving(2, 'a', t2)),
        isFalse,
      );
    });
  });

  group('the proof', () {
    final v = view(2, 'desk', t1);

    test('checks out for the same nonce, certificate, claim and shop', () {
      final mac = LanPeerProof.mac(
        shopKey: key,
        nonce: 'n1',
        fingerprint: 'fp',
        view: v,
      );
      expect(
        LanPeerProof.verify(
          shopKey: key,
          nonce: 'n1',
          fingerprint: 'fp',
          view: v,
          mac: mac,
        ),
        isTrue,
      );
    });

    test('fails for another nonce, certificate, claim field or shop key', () {
      final mac = LanPeerProof.mac(
        shopKey: key,
        nonce: 'n1',
        fingerprint: 'fp',
        view: v,
      );
      bool ok({
        String shopKey = key,
        String nonce = 'n1',
        String fingerprint = 'fp',
        LanServerView? claim,
      }) => LanPeerProof.verify(
        shopKey: shopKey,
        nonce: nonce,
        fingerprint: fingerprint,
        view: claim ?? v,
        mac: mac,
      );
      expect(ok(nonce: 'n2'), isFalse);
      expect(ok(fingerprint: 'other-cert'), isFalse);
      expect(ok(claim: view(3, 'desk', t1)), isFalse);
      expect(ok(claim: view(2, 'other', t1)), isFalse);
      expect(ok(claim: view(2, 'desk', t2)), isFalse);
      expect(ok(claim: view(2, 'desk', t1, cleared: true)), isFalse);
      // Another shop: neither its key nor its tag matches.
      expect(ok(shopKey: 'another-key'), isFalse);
      expect(ok(claim: view(2, 'desk', t1, tag: 'other-tag')), isFalse);
    });

    test('nonces differ', () {
      expect(LanPeerProof.nonce(), isNot(LanPeerProof.nonce()));
    });

    test('a candidate survives JSON (a moved event)', () {
      final c = candidate(view(2, 'desk', t1));
      final back = LanServerCandidate.fromJson(c.toJson())!;
      expect(back.view.serverDeviceId, 'desk');
      expect(back.view.claimedAt, t1);
      expect(back.fingerprint, 'fp-desk');
      expect(back.addresses, ['127.0.0.1']);
      expect(LanServerCandidate.fromJson({'view': 1}), isNull);
    });
  });

  group('the watch', () {
    final self = view(2, 'me', t2);

    test('pickOutranking: the strongest outranking claim; cleared claims and '
        'its own are skipped', () {
      final weaker = candidate(view(2, 'z', DateTime.utc(2026, 11, 21)));
      final strong = candidate(view(2, 'b', t1));
      final stronger = candidate(view(3, 'c', t2));
      final cleared = candidate(view(9, 'x', t1, cleared: true));
      final own = candidate(view(9, 'me', t1));
      expect(pickOutranking([weaker, cleared, own], self), isNull);
      expect(pickOutranking([weaker, strong, stronger], self), same(stronger));
    });

    test('outranked: stops at the winner and tells no one; outranking: tells '
        'each lower server; one check at a time; started and stopped on a '
        'timer', () async {
      final outranked = <String?>[];
      final told = <String?>[];
      var found = <LanServerCandidate>[];
      var finds = 0;
      final finding = Completer<void>();
      Timer? ticking;
      final watch = LanServerWatch(
        find: () async {
          finds++;
          if (finds == 1) await finding.future;
          return found;
        },
        self: () => self,
        onOutranked: (w) async => outranked.add(w.view.serverDeviceId),
        onOutranks: (l) async => told.add(l.view.serverDeviceId),
        periodic: (every, tick) {
          expect(every, const Duration(seconds: 30));
          return ticking = Timer(const Duration(days: 1), () {});
        },
      )..start();
      expect(ticking, isNotNull);

      found = [
        candidate(view(2, 'low', DateTime.utc(2026, 11, 21))),
        candidate(view(1, 'older', t1)),
      ];
      final first = watch.check();
      final second = watch.check();
      finding.complete();
      await Future.wait([first, second]);
      expect(finds, 1);
      expect(told, ['low', 'older']);
      expect(outranked, isEmpty);

      found = [...found, candidate(view(2, 'win', t1))];
      await watch.check();
      expect(outranked, ['win']);
      expect(told, ['low', 'older']);

      watch.stop();
      expect(ticking!.isActive, isFalse);
    });
  });
}
