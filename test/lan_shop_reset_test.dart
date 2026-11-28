import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_client_session.dart';
import 'package:stockall/classes/lan/lan_server_session.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_addresses.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

class RecordingDiscovery implements LanDiscoveryBackend {
  bool serverAdvertised = false;
  bool peerAdvertised = false;

  @override
  Stream<LanFound> browse(String type, Duration timeout) {
    return const Stream.empty();
  }

  @override
  Future<void> advertiseServer({
    required String name,
    required int port,
    required Map<String, String> txt,
  }) async {
    serverAdvertised = true;
  }

  @override
  Future<void> stopServerAdvert() async {
    serverAdvertised = false;
  }

  @override
  Future<void> advertisePeer({
    required String name,
    required Map<String, String> txt,
  }) async {
    peerAdvertised = true;
  }

  @override
  Future<void> stopPeerAdvert() async {
    peerAdvertised = false;
  }
}

void main() {
  late RecordingDiscovery discovery;

  setUpAll(() async {
    Hive.init(
      Directory.systemTemp.createTempSync('stockall_lan_shop_reset').path,
    );
    await DeviceIdentity().init();
    await LocalServerFunc().init();
    await LanShopKeysFunc().init();
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanClientSessionFunc().init();
  });

  tearDownAll(() async {
    await LanTransport().stopServer();
    await Hive.close();
  });

  setUp(() {
    discovery = RecordingDiscovery();
    LanTransport().discovery = discovery;
    LanTransport().interfaces = () async => const <LanInterface>[];
    LanTransport().serverPorts = const [0];
    // Offline: the server starts without pulling from Supabase.
    LanTransport().isOnline = () => false;
  });

  test('clearAllShopData stops the server and both adverts at once, and '
      'clears the LAN auth boxes', () async {
    final deviceId = await DeviceIdentity().deviceId();
    final record = LocalServerRecord(
      shopId: 7,
      epoch: 3,
      serverDeviceId: deviceId,
    );
    await LocalServerFunc().putRecord(record);
    final shopKey = 'k' * 64;
    final port = await LanTransport().startServer(
      record: record,
      deviceId: deviceId,
      shopKey: shopKey,
    );
    await LanTransport().advertisePeer(
      shopKey: shopKey,
      epoch: 3,
      deviceId: deviceId,
    );
    await LanShopKeysFunc().put(7, shopKey);
    await LanCredentialsFunc().replaceForShop(7, [
      LanUserCredential(
        shopId: 7,
        userId: 'u1',
        email: 'a@b.co',
        salt: '00',
        hash: '00',
        iterations: 1,
        role: 'Owner',
        isOwner: true,
        profileJson: '{}',
        updatedAt: DateTime.utc(2026, 11, 25),
      ),
    ]);
    await LanServerSessionsFunc().put(
      LanServerSession(
        tokenHash: 'h',
        shopId: 7,
        userId: 'u1',
        deviceId: 'phone',
        createdAt: DateTime.utc(2026, 11, 25),
        expiresAt: DateTime.utc(2026, 12, 25),
        lastUsedAt: DateTime.utc(2026, 11, 25),
      ),
    );
    await LanClientSessionFunc().put(
      LanClientSession(
        serverDeviceId: 'desk',
        shopId: 7,
        userId: 'u1',
        token: 't',
        expiresAt: DateTime.utc(2026, 12, 25),
        createdAt: DateTime.utc(2026, 11, 25),
      ),
    );
    expect(LocalServerProvider().isServing, isTrue);
    expect(discovery.serverAdvertised, isTrue);
    expect(discovery.peerAdvertised, isTrue);

    await MainDatabase().clearAllShopData();

    expect(LocalServerProvider().isServing, isFalse);
    expect(discovery.serverAdvertised, isFalse);
    expect(discovery.peerAdvertised, isFalse);
    expect(LocalServerFunc().getRecord(7), isNull);
    expect(LanShopKeysFunc().get(7), isNull);
    expect(LanCredentialsFunc().forShop(7), isEmpty);
    expect(LanServerSessionsFunc().get('h'), isNull);
    expect(LanClientSessionFunc().get(7), isNull);
    await expectLater(
      Socket.connect('127.0.0.1', port, timeout: const Duration(seconds: 2)),
      throwsA(isA<SocketException>()),
    );
  });

  test('clearAllShopData is fine when nothing is serving', () async {
    expect(LocalServerProvider().isServing, isFalse);

    await MainDatabase().clearAllShopData();

    expect(LocalServerProvider().isServing, isFalse);
    expect(discovery.serverAdvertised, isFalse);
    expect(discovery.peerAdvertised, isFalse);
  });
}
