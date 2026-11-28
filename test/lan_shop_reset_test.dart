import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_client_session.dart';
import 'package:stockall/classes/lan/lan_server_session.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_addresses.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/sync/lan_server_sync.dart';

class RecordingDiscovery implements LanDiscoveryBackend {
  bool serverAdvertised = false;
  bool peerAdvertised = false;

  /// When set, a browse finds nothing once it completes; [browsing]
  /// completes when one starts.
  Completer<void>? browseGate;
  final Completer<void> browsing = Completer<void>();

  @override
  Stream<LanFound> browse(String type, Duration timeout) {
    if (!browsing.isCompleted) browsing.complete();
    final gate = browseGate;
    if (gate == null) return const Stream.empty();
    return Stream.fromFuture(gate.future).expand((_) => const <LanFound>[]);
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
    await CurrentShopFunc().init();
    await LanPairedServersFunc().init();
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

  test('clearAllShopData (logout, store switch) stops the server and both '
      'adverts at once; the served store\'s record, key, logins and tills\' '
      'sessions stay, another store\'s go', () async {
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
    // Another store's, from an earlier sign-in here.
    await LanShopKeysFunc().put(8, 'x' * 64);
    await LanServerSessionsFunc().put(
      LanServerSession(
        tokenHash: 'other',
        shopId: 8,
        userId: 'u2',
        deviceId: 'phone',
        createdAt: DateTime.utc(2026, 11, 25),
        expiresAt: DateTime.utc(2026, 12, 25),
        lastUsedAt: DateTime.utc(2026, 11, 25),
      ),
    );
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
    expect(LocalServerFunc().getRecord(7)?.serverDeviceId, deviceId);
    expect(LanShopKeysFunc().get(7), shopKey);
    expect(LanCredentialsFunc().forShop(7), hasLength(1));
    expect(LanServerSessionsFunc().get('h'), isNotNull);
    expect(LanShopKeysFunc().get(8), isNull);
    expect(LanServerSessionsFunc().get('other'), isNull);
    expect(LanClientSessionFunc().get(7), isNull);
    await expectLater(
      Socket.connect('127.0.0.1', port, timeout: const Duration(seconds: 2)),
      throwsA(isA<SocketException>()),
    );
  });

  test('when the stores served here can\'t be worked out, clearAllShopData '
      'still stops the server and keeps every key, login and session',
      () async {
    final deviceId = await DeviceIdentity().deviceId();
    final record = LocalServerRecord(
      shopId: 7,
      epoch: 3,
      serverDeviceId: deviceId,
    );
    await LocalServerFunc().putRecord(record);
    final shopKey = 'k' * 64;
    await LanTransport().startServer(
      record: record,
      deviceId: deviceId,
      shopKey: shopKey,
    );
    await LanShopKeysFunc().put(7, shopKey);
    await LanServerSessionsFunc().put(
      LanServerSession(
        tokenHash: 'kept',
        shopId: 7,
        userId: 'u1',
        deviceId: 'phone',
        createdAt: DateTime.utc(2026, 11, 25),
        expiresAt: DateTime.utc(2026, 12, 25),
        lastUsedAt: DateTime.utc(2026, 11, 25),
      ),
    );
    addTearDown(() async {
      await DeviceIdentity().init();
      await LanServerSessionsFunc().clearSessions(keep: const {});
      await LanShopKeysFunc().clearShopKeys(keep: const {});
    });
    expect(LocalServerProvider().isServing, isTrue);
    // The device id can't be read: ownedShops() throws.
    await DeviceIdentity().deviceIdentityBox.close();

    await MainDatabase().clearAllShopData();

    expect(LocalServerProvider().isServing, isFalse);
    expect(LanShopKeysFunc().get(7), shopKey);
    expect(LanServerSessionsFunc().get('kept'), isNotNull);
  });

  test('clearAllShopData is fine when nothing is serving', () async {
    expect(LocalServerProvider().isServing, isFalse);

    await MainDatabase().clearAllShopData();

    expect(LocalServerProvider().isServing, isFalse);
    expect(discovery.serverAdvertised, isFalse);
    expect(discovery.peerAdvertised, isFalse);
  });
  test('a sign-in to the store this desktop serves starts it again; a '
      'sign-in to another store does not', () async {
    final deviceId = await DeviceIdentity().deviceId();
    final shopKey = 'k' * 64;
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 3,
        serverDeviceId: deviceId,
        certFingerprint: await LanTransport().serverFingerprint(),
      ),
    );
    await LanShopKeysFunc().put(7, shopKey);
    LocalServerProvider().clearCache();
    addTearDown(() async {
      await LanTransport().stopServer();
      await CurrentShopFunc().clearCurrentShop();
    });

    // Signed out: no current store, nothing serves.
    await CurrentShopFunc().clearCurrentShop();
    await LocalServerProvider().resumeServerIfOwned();
    expect(LocalServerProvider().isServing, isFalse);

    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 8),
    );
    await LocalServerProvider().resumeServerIfOwned();
    expect(LocalServerProvider().isServing, isFalse);

    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 7),
    );
    await LocalServerProvider().resumeServerIfOwned();
    expect(LocalServerProvider().isServing, isTrue);
    expect(LanTransport().servingShopId, 7);
  });
  test('a logout or a store switch while a resume looks for another server '
      'of the store: it doesn\'t start serving', () async {
    final deviceId = await DeviceIdentity().deviceId();
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 3,
        serverDeviceId: deviceId,
        certFingerprint: await LanTransport().serverFingerprint(),
      ),
    );
    await LanShopKeysFunc().put(7, 'k' * 64);
    LocalServerProvider().clearCache();
    addTearDown(() async {
      await LanTransport().stopServer();
      await CurrentShopFunc().clearCurrentShop();
    });

    Future<void> resumeThen(Future<void> Function() meanwhile) async {
      discovery = RecordingDiscovery()..browseGate = Completer<void>();
      LanTransport().discovery = discovery;
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 7),
      );
      final resuming = LocalServerProvider().resumeServerIfOwned();
      await discovery.browsing.future;
      await meanwhile();
      discovery.browseGate!.complete();
      await resuming;
    }

    // Logout.
    await resumeThen(() => MainDatabase().clearAllShopData());
    expect(LocalServerProvider().isServing, isFalse);
    expect(discovery.serverAdvertised, isFalse);

    // Another store chosen.
    await resumeThen(
      () => CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 8),
      ),
    );
    expect(LocalServerProvider().isServing, isFalse);

    // Nothing in between: it serves.
    await resumeThen(() async {});
    expect(LocalServerProvider().isServing, isTrue);
    expect(LanTransport().servingShopId, 7);
  });

  test('a server that can\'t bind its port leaves nothing running, and a '
      'claim that fails to start is undone', () async {
    final busy = await ServerSocket.bind(
      InternetAddress.anyIPv6,
      0,
      v6Only: false,
    );
    addTearDown(busy.close);
    addTearDown(() => LanTransport().serverPorts = const [0]);
    final deviceId = await DeviceIdentity().deviceId();
    LanTransport().serverPorts = [busy.port];

    await expectLater(
      LanTransport().startServer(
        record: LocalServerRecord(
          shopId: 9,
          epoch: 1,
          serverDeviceId: deviceId,
        ),
        deviceId: deviceId,
        shopKey: 'k' * 64,
      ),
      throwsA(isA<StateError>()),
    );
    expect(LocalServerProvider().isServing, isFalse);
    expect(LanTransport().servingShopId, isNull);
    expect(LanTransport().puller, isNull);
    expect(LanServerSync.pullerActive, isFalse);
    expect(discovery.serverAdvertised, isFalse);

    // Through the claim: the record it wrote is taken back.
    await LanShopKeysFunc().put(9, 'k' * 64);
    await LanCredentialsFunc().replaceForShop(9, [
      LanUserCredential(
        shopId: 9,
        userId: 'u1',
        email: 'a@b.co',
        salt: '00',
        hash: '00',
        iterations: 1,
        role: 'Owner',
        isOwner: true,
        profileJson: '{}',
        updatedAt: DateTime.utc(2026, 11, 28),
      ),
    ]);
    LocalServerProvider().clearCache();
    expect(
      await LocalServerProvider().setThisDeviceAsServer(
        shopId: 9,
        userId: 'u1',
      ),
      LocalServerChange.serverStartFailed,
    );
    expect(LocalServerFunc().getRecord(9), isNull);
    expect(LocalServerProvider().record(shopId: 9), isNull);
    expect(LocalServerProvider().isServing, isFalse);
    expect(LanServerSync.pullerActive, isFalse);

    // With a free port it serves.
    LanTransport().serverPorts = const [0];
    expect(
      await LocalServerProvider().setThisDeviceAsServer(
        shopId: 9,
        userId: 'u1',
      ),
      LocalServerChange.applied,
    );
    expect(LocalServerProvider().isServing, isTrue);
    expect(LocalServerFunc().getRecord(9)?.serverDeviceId, deviceId);
    await LanTransport().stopServer();
  });
  test('a desktop holding another store\'s server record knows it after a '
      'sign-in here', () async {
    final deviceId = await DeviceIdentity().deviceId();
    await LocalServerFunc().clearLocalServerRecords();
    await LocalServerFunc().putRecord(
      LocalServerRecord(shopId: 7, epoch: 3, serverDeviceId: deviceId),
    );
    addTearDown(() async {
      await CurrentShopFunc().clearCurrentShop();
      await LocalServerFunc().clearLocalServerRecords();
    });
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 8),
    );
    expect(await LocalServerProvider().otherStoreServedHere(), 7);
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 7),
    );
    expect(await LocalServerProvider().otherStoreServedHere(), isNull);
  });
}
