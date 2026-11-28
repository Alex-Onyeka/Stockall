import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/services/lan/lan_addresses.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

class FakeDiscovery implements LanDiscoveryBackend {
  List<LanFound> servers = [];
  List<LanFound> peers = [];

  @override
  Stream<LanFound> browse(String type, Duration timeout) {
    return Stream.fromIterable(
      type == LanConstants.serverServiceType ? servers : peers,
    );
  }

  @override
  Future<void> advertiseServer({
    required String name,
    required int port,
    required Map<String, String> txt,
  }) async {}

  @override
  Future<void> stopServerAdvert() async {}

  @override
  Future<void> advertisePeer({
    required String name,
    required Map<String, String> txt,
  }) async {}

  @override
  Future<void> stopPeerAdvert() async {}
}

LanFound advert({
  required int shopId,
  required int epoch,
  required String deviceId,
  int port = LanConstants.port,
  List<String> addresses = const ['127.0.0.1'],
}) {
  return LanFound(
    name: 'Stockall-$deviceId',
    addresses: addresses,
    port: port,
    txt: {'v': '1', 't': shopTag(keyOf(shopId)), 'e': '$epoch', 'd': deviceId},
  );
}

/// A distinct shop key per shop id, as `shops.lan_key` would give.
String keyOf(int shopId) => 'key-$shopId'.padRight(64, '0');

void main() {
  late LanTlsIdentity identity;
  late FakeDiscovery discovery;
  final servers = <LanServer>[];

  Future<LanServer> serverAnswering({
    required int shopId,
    required int epoch,
    required bool cleared,
  }) async {
    final server = LanServer(
      identity: identity,
      deviceId: 'desk-b',
      serverView: () => {
        'shop_tag': shopTag(keyOf(shopId)),
        'epoch': epoch,
        'server_device_id': cleared ? null : 'desk-b',
        'cleared': cleared,
        'claimed_at': null,
      },
    );
    await server.start(ports: const [0]);
    servers.add(server);
    return server;
  }

  setUpAll(() {
    identity = LanTlsIdentity.generate();
  });

  setUp(() {
    discovery = FakeDiscovery();
    LanTransport().discovery = discovery;
    LanTransport().interfaces = () async => const <LanInterface>[];
  });

  tearDown(() async {
    for (final server in servers) {
      await server.stop();
    }
    servers.clear();
  });

  test('a live server for the shop refuses the claim', () async {
    final server = await serverAnswering(shopId: 7, epoch: 5, cleared: false);
    discovery.servers = [
      advert(shopId: 7, epoch: 5, deviceId: 'desk-b', port: server.port!),
    ];

    final preflight = await LanTransport().claimPreflight(
      shopKey: keyOf(7),
      ownDeviceId: 'desk-a',
    );

    expect(preflight.liveServerFound, isTrue);
    expect(preflight.maxEpoch, 5);
  });

  test('a server that answers as cleared is not live', () async {
    final server = await serverAnswering(shopId: 7, epoch: 6, cleared: true);
    discovery.servers = [
      advert(shopId: 7, epoch: 5, deviceId: 'desk-b', port: server.port!),
    ];

    final preflight = await LanTransport().claimPreflight(
      shopKey: keyOf(7),
      ownDeviceId: 'desk-a',
    );

    expect(preflight.liveServerFound, isFalse);
    expect(preflight.maxEpoch, 6);
  });

  test('a stale advert counts for its epoch but not as live', () async {
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final closedPort = closed.port;
    await closed.close();
    discovery.servers = [
      advert(shopId: 7, epoch: 9, deviceId: 'desk-b', port: closedPort),
    ];

    final preflight = await LanTransport().claimPreflight(
      shopKey: keyOf(7),
      ownDeviceId: 'desk-a',
    );

    expect(preflight.liveServerFound, isFalse);
    expect(preflight.maxEpoch, 9);
  });

  test('peers of this shop raise the epoch; others and self do not', () async {
    discovery.peers = [
      advert(shopId: 7, epoch: 7, deviceId: 'till-1'),
      advert(shopId: 7, epoch: 4, deviceId: 'till-2'),
      advert(shopId: 8, epoch: 50, deviceId: 'other-shop'),
      advert(shopId: 7, epoch: 99, deviceId: 'desk-a'),
    ];

    final preflight = await LanTransport().claimPreflight(
      shopKey: keyOf(7),
      ownDeviceId: 'desk-a',
    );

    expect(preflight.liveServerFound, isFalse);
    expect(preflight.maxEpoch, 7);

    // ...so a desktop that only knew epoch 5 claims epoch 8, not 6.
    final claimed = LocalServerRecord.claim(
      LocalServerRecord(shopId: 7, epoch: 5),
      shopId: 7,
      deviceId: 'desk-a',
      userId: 'owner',
      now: DateTime.utc(2026, 11, 25),
      highestKnownEpoch: preflight.maxEpoch,
    );
    expect(claimed!.epoch, 8);
  });

  test('a server for another shop is ignored', () async {
    final server = await serverAnswering(shopId: 8, epoch: 30, cleared: false);
    discovery.servers = [
      advert(shopId: 8, epoch: 30, deviceId: 'desk-b', port: server.port!),
    ];

    final preflight = await LanTransport().claimPreflight(
      shopKey: keyOf(7),
      ownDeviceId: 'desk-a',
    );

    expect(preflight.liveServerFound, isFalse);
    expect(preflight.maxEpoch, 0);
  });

  group('epoch floor', () {
    setUpAll(() async {
      Hive.init(
        Directory.systemTemp.createTempSync('stockall_lan_floor').path,
      );
      await LocalServerFunc().init();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('only rises, and survives clearing the records', () async {
      await LocalServerFunc().putRecord(
        LocalServerRecord(shopId: 7, epoch: 12),
      );
      await LocalServerFunc().raiseEpochFloor(7, 12);
      await LocalServerFunc().raiseEpochFloor(7, 3);
      expect(LocalServerFunc().epochFloor(7), 12);

      await LocalServerFunc().clearLocalServerRecords();

      expect(LocalServerFunc().getRecord(7), isNull);
      expect(LocalServerFunc().epochFloor(7), 12);
      expect(LocalServerFunc().epochFloor(8), 0);
    });
  });
}
