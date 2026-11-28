import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 25, 9);
  final t1 = DateTime.utc(2026, 11, 25, 10);

  LocalServerRecord serving({int shopId = 7, int epoch = 3}) {
    return LocalServerRecord(
      shopId: shopId,
      epoch: epoch,
      serverDeviceId: 'device-a',
      claimedAt: t0,
      claimedByUserId: 'user-1',
      certFingerprint: 'fp-a',
      lastKnownAddresses: ['192.168.0.10'],
    );
  }

  LocalServerRecord cleared({int shopId = 7, int epoch = 4}) {
    return LocalServerRecord(shopId: shopId, epoch: epoch);
  }

  group('claim', () {
    test('from no record gives epoch 1 with this device', () {
      final next = LocalServerRecord.claim(
        null,
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
        certFingerprint: 'fp-b',
      );

      expect(next, isNotNull);
      expect(next!.epoch, 1);
      expect(next.shopId, 7);
      expect(next.serverDeviceId, 'device-b');
      expect(next.claimedByUserId, 'user-2');
      expect(next.claimedAt, t1);
      expect(next.certFingerprint, 'fp-b');
      expect(next.isCleared, isFalse);
    });

    test('from a cleared record bumps the epoch by one', () {
      final next = LocalServerRecord.claim(
        cleared(epoch: 4),
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
      );

      expect(next!.epoch, 5);
      expect(next.serverDeviceId, 'device-b');
    });

    test('uses the highest known epoch when it is above the local one', () {
      final fromNothing = LocalServerRecord.claim(
        null,
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
        highestKnownEpoch: 7,
      );
      final fromCleared = LocalServerRecord.claim(
        cleared(epoch: 4),
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
        highestKnownEpoch: 9,
      );

      expect(fromNothing!.epoch, 8);
      expect(fromCleared!.epoch, 10);
    });

    test('ignores a highest known epoch below the local one', () {
      final next = LocalServerRecord.claim(
        cleared(epoch: 9),
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
        highestKnownEpoch: 3,
      );

      expect(next!.epoch, 10);
    });

    test('is still refused while a server is set, whatever is known', () {
      expect(
        LocalServerRecord.claim(
          serving(),
          shopId: 7,
          deviceId: 'device-b',
          userId: 'user-2',
          now: t1,
          highestKnownEpoch: 100,
        ),
        isNull,
      );
    });

    test('is refused while another server is set', () {
      final next = LocalServerRecord.claim(
        serving(),
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
      );

      expect(next, isNull);
    });

    test('is refused even when this device is already the server', () {
      final next = LocalServerRecord.claim(
        serving(),
        shopId: 7,
        deviceId: 'device-a',
        userId: 'user-1',
        now: t1,
      );

      expect(next, isNull);
    });
  });

  group('clear', () {
    test('gives epoch + 1 with no server, fingerprint or addresses', () {
      final next = LocalServerRecord.clear(
        serving(epoch: 3),
        userId: 'user-2',
        now: t1,
      );

      expect(next, isNotNull);
      expect(next!.epoch, 4);
      expect(next.shopId, 7);
      expect(next.isCleared, isTrue);
      expect(next.serverDeviceId, isNull);
      expect(next.certFingerprint, isNull);
      expect(next.lastKnownAddresses, isEmpty);
      expect(next.claimedByUserId, 'user-2');
      expect(next.claimedAt, t1);
    });

    test('is a no-op on an already cleared record', () {
      expect(
        LocalServerRecord.clear(cleared(), userId: 'user-2', now: t1),
        isNull,
      );
    });

    test('is a no-op when there is no record', () {
      expect(
        LocalServerRecord.clear(null, userId: 'user-2', now: t1),
        isNull,
      );
    });

    test('then claim gives epoch + 2', () {
      final afterClear = LocalServerRecord.clear(
        serving(epoch: 3),
        userId: 'user-2',
        now: t1,
      );
      final afterClaim = LocalServerRecord.claim(
        afterClear,
        shopId: 7,
        deviceId: 'device-b',
        userId: 'user-2',
        now: t1,
      );

      expect(afterClaim!.epoch, 5);
      expect(afterClaim.serverDeviceId, 'device-b');
    });
  });

  group('supersedes', () {
    test('any record supersedes no record', () {
      expect(LocalServerRecord.supersedes(cleared(epoch: 1), null), isTrue);
    });

    test('a higher epoch wins, even when it is cleared', () {
      expect(
        LocalServerRecord.supersedes(cleared(epoch: 4), serving(epoch: 3)),
        isTrue,
      );
    });

    test('an equal epoch keeps the current record', () {
      expect(
        LocalServerRecord.supersedes(cleared(epoch: 3), serving(epoch: 3)),
        isFalse,
      );
    });

    test('a lower epoch loses', () {
      expect(
        LocalServerRecord.supersedes(serving(epoch: 2), cleared(epoch: 4)),
        isFalse,
      );
    });

    test('a record for a different shop never wins', () {
      expect(
        LocalServerRecord.supersedes(
          serving(shopId: 8, epoch: 99),
          cleared(shopId: 7, epoch: 1),
        ),
        isFalse,
      );
    });
  });

  test('withAddresses changes the cache only', () {
    final moved = serving(epoch: 3).withAddresses(['10.0.0.7']);

    expect(moved.epoch, 3);
    expect(moved.serverDeviceId, 'device-a');
    expect(moved.certFingerprint, 'fp-a');
    expect(moved.lastKnownAddresses, ['10.0.0.7']);
  });

  test('json round-trip keeps every field', () {
    final copy = LocalServerRecord.fromJson(serving().toJson());

    expect(copy.toJson(), serving().toJson());
  });

  group('LocalServerFunc (Hive)', () {
    setUpAll(() async {
      Hive.init(
        Directory.systemTemp.createTempSync('stockall_lan_record').path,
      );
      await LocalServerFunc().init();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('stores records keyed by shop and clears them', () async {
      await LocalServerFunc().putRecord(serving(shopId: 7, epoch: 3));
      await LocalServerFunc().putRecord(cleared(shopId: 8, epoch: 9));

      final seven = LocalServerFunc().getRecord(7)!;
      expect(seven.epoch, 3);
      expect(seven.serverDeviceId, 'device-a');
      expect(seven.claimedAt, t0);
      expect(seven.lastKnownAddresses, ['192.168.0.10']);
      expect(LocalServerFunc().getRecord(8)!.isCleared, isTrue);

      await LocalServerFunc().clearLocalServerRecords();

      expect(LocalServerFunc().getRecord(7), isNull);
      expect(LocalServerFunc().getRecord(8), isNull);
    });
  });
}
