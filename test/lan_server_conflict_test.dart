import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_move_proof.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';
import 'helpers/lan_peer_server.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

/// mDNS as the tests set it: the servers "seen" on the network.
class _FakeDiscovery implements LanDiscoveryBackend {
  List<LanFound> servers = [];

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

  @override
  Stream<LanFound> browse(String type, Duration timeout) => Stream.fromIterable(
    type == LanConstants.serverServiceType ? servers : const [],
  );
}

/// End to end: this test's app (every box `initHive` opens, the real
/// `LanTransport` and `LocalServerProvider`) serves the shop, and another
/// server of the shop runs in its own isolate and Hive. Two claims at
/// epoch 2 (a split network): the other claimed first, so it outranks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to real servers over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  final t1 = DateTime.utc(2026, 11, 20, 9);
  final t2 = DateTime.utc(2026, 11, 20, 10);
  final discovery = _FakeDiscovery();
  late PeerServer other;
  late String me;

  LanFound advert(int port, String device, {int epoch = 2}) => LanFound(
    name: 'Stockall-$device',
    addresses: const ['127.0.0.1'],
    port: port,
    txt: {
      'v': LanConstants.protocolVersion,
      't': shopTag(key),
      'tv': LanConstants.shopTagVersion,
      'e': '$epoch',
      'd': device,
    },
  );

  Future<void> eventually(
    FutureOr<bool> Function() done, {
    Duration within = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(within);
    while (!await done()) {
      if (DateTime.now().isAfter(end)) fail('timed out');
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  List<LanAlert> alerts() => LanAlerts().all();

  /// This device serves the shop at epoch 2, claimed at [at] (t2: after
  /// the other one), with nothing left from an earlier test.
  Future<void> becomeServer({DateTime? at}) async {
    final transport = LanTransport();
    await transport.stopServer();
    await transport.disconnectClient();
    RemoteRouter.useSupabase();
    discovery.servers = [];
    await LanClientSessionFunc().delete(7);
    await LanPairedServersFunc().pairedServersBox.clear();
    await LanPairedServersFunc().trustBox.clear();
    await LanAlertsFunc().clearAlerts();
    await LanHandoffsFunc().clearHandoffs();
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: me,
        claimedAt: at ?? t2,
        certFingerprint: await transport.serverFingerprint(),
      ),
    );
    LocalServerProvider().clearCache();
    await LocalServerProvider().resumeServerIfOwned();
    expect(transport.isServing, isTrue);
  }

  setUpAll(() async {
    final tillDir = Directory.systemTemp.createTempSync('stockall_p8_till');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tillDir.path,
    );
    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    await MainDatabase().initHive();
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 7),
    );
    ShopProvider().userShops = [
      TempShopClass(
        shopId: 7,
        createdAt: DateTime.utc(2026),
        userId: 'owner',
        name: 'Shop',
        currency: 'NGN',
        isVerified: true,
        applyVAT: false,
        manageInventoryStorage: false,
        wholeSale: false,
        manageDepartments: false,
        printSalesDocket: false,
        closeSaleTimeString: null,
        trackCart: false,
        accessPin: null,
        manageProductions: false,
        manageProductionsStorage: false,
        manageProductionItems: false,
        customerPercentageReward: 0,
        manageCustomerReward: false,
        manageCustomerAccount: false,
      ),
    ];
    final ada = TempUserClass(
      userId: 'cashier',
      name: 'Ada',
      email: 'ada@shop.test',
      password: 'right',
      role: 'Cashier',
      departmentUuids: const [],
      access: const ['Make Sale'],
    );
    // Ada is signed in here (her password kept for offline login).
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(loggedInUser: ada),
    );
    await UserProvider().fetchCurrentUserOffline();
    await LanShopKeysFunc().put(7, key);
    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
      [ada],
      iterations: 1000,
    );
    await ProductsFunc().productBox.put('p1', product('p1')..quantity = 5);

    final transport =
        LanTransport()
          ..discovery = discovery
          ..interfaces = (() async => const [])
          ..serverPorts = const [0]
          ..browseTimeout = const Duration(milliseconds: 10)
          // No Supabase pulls from this desktop while it serves.
          ..isOnline = (() => false);
    expect(transport.isAvailable, isTrue);
    // Its callbacks on the transport.
    LocalServerProvider();
    // The network interface is up (routing connects only then).
    ConnectivityProvider().interfaceUp = true;
    me = await DeviceIdentity().deviceId();

    other = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'other-desk',
      epoch: 2,
      claimedAt: t1,
    );
  });

  tearDownAll(() async {
    await LanTransport().stopServer();
    await LanTransport().disconnectClient();
    RemoteRouter.useSupabase();
    await other.stop();
  });

  test('the watch finds an outranking server: this one tells its clients '
      '(a move signed with its certificate) and stops; it sends no password '
      'there until a person pairs it with the winner; then it signs in and '
      'pushes the queue it kept; a write the signed-in user may not make is '
      'set aside for Supabase', () async {
    await becomeServer();
    // The queue it kept as a server: a sale's stock change (7 of p1: the
    // other side sold too, so the store ends below zero), and a deletion
    // Ada (a cashier) may not make.
    await QuantityUpdateFunc().createQuantityUpdate(
      QuantityUpdate(
        uuid: 'q-split',
        createdAt: DateTime.now(),
        quantity: 7,
        productUuid: 'p1',
        isIncrement: false,
        isStorage: false,
      ),
    );
    await DeletedProductsFunc().createDeletedProduct(
      DeletedProducts(productUuid: 'p9', date: DateTime.now()),
    );

    // A client of this server, with its WebSocket.
    final transport = LanTransport();
    final connection =
        (await LanConnection.open([
          LanEndpoint('127.0.0.1', transport.serverPort!),
        ], pin: await transport.serverFingerprint()))!;
    addTearDown(connection.close);
    // Paired with this server (as pairing would).
    final secret = (await LanHiveAdmission(
      shopId: () => 7,
    ).admit('phone-1', byPerson: true))!;
    final login = await connection.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': 'phone-1',
      'pair_secret': secret,
    });
    final ws = await connection.openWebSocket(
      session: LanSessionHeaders(
        token: login['token'] as String,
        deviceId: 'phone-1',
      ),
    );
    final events = <Map<String, dynamic>>[];
    ws.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
    );

    final loginsBefore = (await other.state())['logins'] as int;
    discovery.servers = [advert(other.port, 'other-desk')];
    await transport.serverWatch!.check();

    // Its client was told where the server is now, signed with this
    // server's certificate key, then it stopped.
    await eventually(() => events.any((e) => e['type'] == 'moved'));
    final moved = events.firstWhere((e) => e['type'] == 'moved');
    expect((moved['to'] as Map)['view']['server_device_id'], 'other-desk');
    expect((moved['to'] as Map)['fingerprint'], other.fingerprint);
    expect(moved['sig'], isA<String>());
    expect(moved['cert'], isA<String>());
    expect(transport.isServing, isFalse);

    // It keeps the other's record, but the other proved itself with the
    // shop key only: no password goes there until a person pairs.
    final record = LocalServerProvider().record(shopId: 7)!;
    expect(record.serverDeviceId, 'other-desk');
    expect(record.certFingerprint, other.fingerprint);
    expect(LanClientSessionFunc().get(7)?.serverDeviceId, isNot('other-desk'));
    expect((await other.state())['logins'], loginsBefore);
    expect(LocalServerProvider().mustPairAgainFor(7), isTrue);
    expect(LanAlertsFunc().pushingShop(), 7);
    expect(alerts().map((a) => a.kind), [LanAlertKind.demoted]);
    expect(alerts().single.message, contains('Pair this device'));

    // A person pairs it with the winner; it signs in there.
    await LanPairedServersFunc().markPairedByPerson(other.fingerprint);
    expect(
      await LocalServerProvider().signInAfterPairing(
        shopId: 7,
        serverDeviceId: 'other-desk',
      ),
      LanAuthResult.ok,
    );
    expect(LanClientSessionFunc().get(7)!.serverDeviceId, 'other-desk');

    // Its queue reaches the other server through the normal sync.
    await eventually(
      () async =>
          (await other.applied(['update_product_quantities:q-split'])).single,
    );
    expect((await other.state())['quantity'], -2.0);
    await eventually(() => returnData().isSynced() == 1);
    expect(QuantityUpdateFunc().getQuantitiesUpdate(), isEmpty);
    expect(DeletedProductsFunc().getProductIds(), isEmpty);
    // The deletion was refused there (Ada lacks Delete Items): kept for
    // Supabase, not lost.
    final refused = LanHandoffs().refused();
    expect(refused, hasLength(1));
    expect(refused.single.method, 'DELETE');
    expect(refused.single.path, 'products');
    expect(refused.single.query, contains('p9'));

    // Once the queue is empty: the alert says so, naming what is set aside
    // and the items now below zero (pulled back from the other server).
    await eventually(() => ProductsFunc().productBox.get('p1')!.quantity == -2);
    await LanRouting().afterDemotionSync();
    expect(LanAlertsFunc().pushingShop(), isNull);
    final merged = alerts().firstWhere((a) => a.kind == LanAlertKind.merged);
    expect(merged.message, contains('except 1'));
    expect(merged.message, contains('products'));
    expect(merged.message, contains('below zero'));
    expect(merged.columns, ['Item', 'In stock']);
    expect(merged.rows, [
      ['Item', '-2'],
    ]);
    // And the other server was told this one's queue from epoch 2 is all
    // there, once.
    expect((await other.state())['handed_over'], ['$me|2']);
    expect(LanAlertsFunc().handingOverEpoch(), isNull);
    await ws.close();
  });

  test('only the other server sees this one (mDNS one way): it tells this '
      'one, which proves it and stops', () async {
    await becomeServer();
    expect(await other.watchOnce(LanTransport().serverPort!), 'outranks');
    await eventually(() => !LanTransport().isServing);
    // Raised last, once it has signed in there.
    await eventually(() => alerts().any((a) => a.kind == LanAlertKind.demoted));
    expect(
      LocalServerProvider().record(shopId: 7)!.serverDeviceId,
      'other-desk',
    );
    expect(alerts().map((a) => a.kind), contains(LanAlertKind.demoted));
  });

  test('a spoofed advert or notice changes nothing: no proof, a proof with '
      'another key, or a claim it can\'t prove', () async {
    await becomeServer();
    final transport = LanTransport();
    LanServer fake(String device, String proofKey, {bool proves = true}) {
      final identity = LanTlsIdentity.generate();
      final view = LanServerView(
        shopTag: shopTag(key),
        epoch: 9,
        serverDeviceId: device,
        cleared: false,
        claimedAt: t1,
      );
      return LanServer(
        identity: identity,
        deviceId: device,
        serverView: view.toJson,
        peerProof:
            proves
                ? (nonce) => {
                  'view': view.toJson(),
                  'mac': LanPeerProof.mac(
                    shopKey: proofKey,
                    nonce: nonce,
                    fingerprint: identity.fingerprint,
                    view: view,
                  ),
                }
                : null,
      );
    }

    final wrongKey = fake('spoof-a', 'not-the-shop-key');
    final noProof = fake('spoof-b', key, proves: false);
    await wrongKey.start(ports: const [0]);
    await noProof.start(ports: const [0]);
    addTearDown(wrongKey.stop);
    addTearDown(noProof.stop);
    discovery.servers = [
      advert(wrongKey.port!, 'spoof-a', epoch: 9),
      advert(noProof.port!, 'spoof-b', epoch: 9),
    ];
    await transport.serverWatch!.check();

    // A notice naming the fake server.
    final connection =
        (await LanConnection.openUnpinned([
          LanEndpoint('127.0.0.1', transport.serverPort!),
        ]))!;
    addTearDown(connection.close);
    await connection.postJson('/v1/server/superseded', {
      'kind': 'server',
      'addresses': ['127.0.0.1'],
      'port': wrongKey.port,
      'fingerprint': wrongKey.identity.fingerprint,
    });
    await transport.noticesHandled();

    expect(transport.isServing, isTrue);
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, me);
    expect(alerts(), isEmpty);
  });

  test('a desktop that was off finds an outranking server before it serves: '
      'it doesn\'t serve, keeps its record, and waits for a person to pair '
      'it there (no password sent)', () async {
    await becomeServer();
    await LanTransport().stopServer();
    final loginsBefore = (await other.state())['logins'] as int;
    discovery.servers = [advert(other.port, 'other-desk')];

    await LocalServerProvider().resumeServerIfOwned();
    expect(LanTransport().isServing, isFalse);
    expect(
      LocalServerProvider().record(shopId: 7)!.serverDeviceId,
      'other-desk',
    );
    expect(LanClientSessionFunc().get(7)?.serverDeviceId, isNot('other-desk'));
    expect((await other.state())['logins'], loginsBefore);
    expect(LocalServerProvider().mustPairAgainFor(7), isTrue);
    expect(alerts().map((a) => a.kind), contains(LanAlertKind.demoted));
  });

  test('a returning server told by a till that the shop\'s server was '
      'force-cleared meanwhile: a notice it can\'t prove changes nothing; a '
      'proven one stops it, it keeps the cleared record and its clients get '
      'the cleared event', () async {
    await becomeServer();
    final transport = LanTransport();
    final connection =
        (await LanConnection.open([
          LanEndpoint('127.0.0.1', transport.serverPort!),
        ], pin: await transport.serverFingerprint()))!;
    addTearDown(connection.close);
    // Paired with this server (as pairing would).
    final secret = (await LanHiveAdmission(
      shopId: () => 7,
    ).admit('phone-1', byPerson: true))!;
    final login = await connection.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': 'phone-1',
      'pair_secret': secret,
    });
    final ws = await connection.openWebSocket(
      session: LanSessionHeaders(
        token: login['token'] as String,
        deviceId: 'phone-1',
      ),
    );
    final events = <Map<String, dynamic>>[];
    ws.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
    );
    final cleared = LanServerView(
      shopTag: shopTag(key),
      epoch: 3,
      serverDeviceId: null,
      cleared: true,
      claimedAt: DateTime.utc(2026, 11, 22),
    );
    Map<String, dynamic> notice(String shopKey, String fingerprint) => {
      'kind': 'cleared',
      'view': cleared.toJson(),
      'mac': LanPeerProof.mac(
        shopKey: shopKey,
        nonce: LanPeerProof.clearedNotice,
        fingerprint: fingerprint,
        view: cleared,
      ),
    };

    // Another shop's key, or bound to another certificate: ignored.
    await connection.postJson(
      '/v1/server/superseded',
      notice('not-the-shop-key', await transport.serverFingerprint()),
    );
    await connection.postJson(
      '/v1/server/superseded',
      notice(key, 'another-certificate'),
    );
    // Refused as it arrived (checked before the answer).
    expect(transport.isServing, isTrue);

    await connection.postJson(
      '/v1/server/superseded',
      notice(key, await transport.serverFingerprint()),
    );
    await eventually(() => !transport.isServing);
    final record = LocalServerProvider().record(shopId: 7)!;
    expect(record.epoch, 3);
    expect(record.isCleared, isTrue);
    await eventually(
      () => events.any((e) => e['type'] == 'server' && e['cleared'] == true),
    );
    // Raised after the server stopped.
    await eventually(() => alerts().isNotEmpty);
    expect(alerts().map((a) => a.kind), [LanAlertKind.forceCleared]);
    await ws.close();
  });

  test('a normal clear tells its clients it delivers their stock changes '
      'itself (handed over) before the cleared event, so tills have nothing '
      'to report', () async {
    await becomeServer();
    final transport = LanTransport();
    final connection =
        (await LanConnection.open([
          LanEndpoint('127.0.0.1', transport.serverPort!),
        ], pin: await transport.serverFingerprint()))!;
    addTearDown(connection.close);
    // Paired with this server (as pairing would).
    final secret = (await LanHiveAdmission(
      shopId: () => 7,
    ).admit('phone-1', byPerson: true))!;
    final login = await connection.postJson('/v1/auth/login', {
      'email': 'ada@shop.test',
      'password': 'right',
      'device_id': 'phone-1',
      'pair_secret': secret,
    });
    final ws = await connection.openWebSocket(
      session: LanSessionHeaders(
        token: login['token'] as String,
        deviceId: 'phone-1',
      ),
    );
    final events = <Map<String, dynamic>>[];
    ws.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
    );
    await eventually(() => events.isNotEmpty);

    expect(
      await LocalServerProvider().clearServer(shopId: 7, userId: 'cashier'),
      LocalServerChange.applied,
    );
    await eventually(
      () => events.any((e) => e['type'] == 'server' && e['cleared'] == true),
    );
    final handed = events.indexWhere((e) => e['type'] == 'handed_over');
    final cleared = events.indexWhere(
      (e) => e['type'] == 'server' && e['cleared'] == true,
    );
    expect(events[handed], {
      'type': 'handed_over',
      'server_device_id': me,
      'epoch': 2,
    });
    expect(handed, lessThan(cleared));
    expect(transport.isServing, isFalse);
    await ws.close();
  });

  test('a former server that pushed its whole queue says so: this '
      'server keeps it, tells its tills and lists it in the handoff status; '
      'only that device can say it', () async {
    await becomeServer();
    final transport = LanTransport();
    Future<(LanConnection, LanSessionHeaders)> signIn(String device) async {
      final c =
          (await LanConnection.open([
            LanEndpoint('127.0.0.1', transport.serverPort!),
          ], pin: await transport.serverFingerprint()))!;
      addTearDown(c.close);
      final secret = (await LanHiveAdmission(
        shopId: () => 7,
      ).admit(device, byPerson: true))!;
      final login = await c.postJson('/v1/auth/login', {
        'email': 'ada@shop.test',
        'password': 'right',
        'device_id': device,
        'pair_secret': secret,
      });
      return (
        c,
        LanSessionHeaders(token: login['token'] as String, deviceId: device),
      );
    }

    final (till, tillSession) = await signIn('phone-1');
    final ws = await till.openWebSocket(session: tillSession);
    final events = <Map<String, dynamic>>[];
    ws.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
    );
    final (former, formerSession) = await signIn('old-desk');

    await expectLater(
      former.postJson('/v1/handoff/handed-over', {
        'epoch': 'two',
      }, session: formerSession),
      throwsA(isA<LanHttpException>()),
    );
    await former.postJson('/v1/handoff/handed-over', {
      'epoch': 2,
    }, session: formerSession);

    expect(LanAlertsFunc().handedOver(), [(device: 'old-desk', epoch: 2)]);
    await eventually(() => events.any((e) => e['type'] == 'handed_over'));
    expect(events.firstWhere((e) => e['type'] == 'handed_over'), {
      'type': 'handed_over',
      'server_device_id': 'old-desk',
      'epoch': 2,
    });
    final status = LanHandoffStatus.fromJson(
      await till.getJson('/v1/handoff/status', session: tillSession),
    )!;
    expect(status.handedOver, [(device: 'old-desk', epoch: 2)]);
    await ws.close();
  });

  test('this server outranks the other: it keeps serving, tells the other, '
      'and raises the alert once', () async {
    // The other claimed after this one.
    await other.setClaim(epoch: 2, claimedAt: DateTime.utc(2026, 11, 21));
    addTearDown(() => other.setClaim(epoch: 2, claimedAt: t1));
    await becomeServer();
    discovery.servers = [advert(other.port, 'other-desk')];
    final transport = LanTransport();
    await transport.serverWatch!.check();
    await transport.serverWatch!.check();

    expect(transport.isServing, isTrue);
    expect(LocalServerProvider().record(shopId: 7)!.serverDeviceId, me);
    await eventually(() async => (await other.state())['notices'] as int > 0);
    await eventually(() => alerts().isNotEmpty);
    expect(alerts().map((a) => a.kind), [LanAlertKind.conflict]);
  });

  test('only paired devices sign in: a stranger is refused before its '
      'password is checked; a till of a former server signs in once with the '
      'move that server signed, then with the secret it is given here',
      () async {
    await becomeServer();
    final transport = LanTransport();
    final fingerprint = await transport.serverFingerprint();
    Future<Map<String, dynamic>> login(
      String device,
      Map<String, dynamic> extra,
    ) async {
      final c =
          (await LanConnection.open([
            LanEndpoint('127.0.0.1', transport.serverPort!),
          ], pin: fingerprint))!;
      addTearDown(c.close);
      return c.postJson('/v1/auth/login', {
        'email': 'ada@shop.test',
        'password': 'right',
        'device_id': device,
        ...extra,
      });
    }

    Matcher notPaired() => throwsA(
      isA<LanHttpException>()
          .having((e) => e.statusCode, 'status', 403)
          .having((e) => e.errorCode, 'error', 'not_paired'),
    );
    await expectLater(login('stranger', const {}), notPaired());
    await expectLater(login('stranger', {'pair_secret': 'guess'}), notPaired());

    // old-desk served the shop before this one and signs its move here.
    final old = LanTlsIdentity.generate();
    final to = LanServerCandidate(
      view: LanServerView.fromRecord(
        LocalServerProvider().record(shopId: 7)!,
        shopTag(key),
      ),
      fingerprint: fingerprint,
      addresses: const ['127.0.0.1'],
      port: transport.serverPort!,
    );
    Map<String, dynamic> moved({
      LanTlsIdentity? by,
      List<String> signed = const ['till-9'],
      List<String>? sent,
    }) {
      final signer = by ?? old;
      final text = LanMoveProof.message(
        shopTag: shopTag(key),
        fromDeviceId: 'old-desk',
        fromEpoch: 1,
        to: to,
        paired: signed,
      );
      return {
        'type': LanConstants.movedEvent,
        'to': to.toJson(),
        'from_device_id': 'old-desk',
        'from_epoch': 1,
        'paired': sent ?? signed,
        'cert': signer.certificatePem,
        'sig': LanMoveProof.sign(signer.privateKeyPem, text),
      };
    }

    // Until this server proved old-desk ranks below it: refused.
    await expectLater(login('till-9', {'moved': moved()}), notPaired());
    await LanPairedDevicesFunc().addFormerServer(old.fingerprint);

    // A device the move doesn't list, a list changed after signing, a move
    // signed by another key: refused.
    await expectLater(login('till-8', {'moved': moved()}), notPaired());
    await expectLater(
      login('till-8', {
        'moved': moved(sent: ['till-9', 'till-8']),
      }),
      notPaired(),
    );
    await expectLater(
      login('till-9', {'moved': moved(by: LanTlsIdentity.generate())}),
      notPaired(),
    );

    final first = await login('till-9', {'moved': moved()});
    expect(first['token'], isA<String>());
    final secret = first['pair_secret'] as String;
    final again = await login('till-9', {'pair_secret': secret});
    expect(again['token'], isA<String>());
    expect(LanPairedDevicesFunc().pairedDeviceIds(7), contains('till-9'));
  });
}
