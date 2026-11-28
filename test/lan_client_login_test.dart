import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_paired_devices_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/lan/device_identity.dart';
import 'package:stockall/services/lan/lan_addresses.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A LAN client that counts how often it is disposed.
class CountingRemote extends SupabaseClient {
  CountingRemote(super.url, super.key, {super.httpClient, super.accessToken});

  static final made = <CountingRemote>[];
  int disposed = 0;

  /// Whether the router still sent requests here when it was disposed.
  bool routedWhenDisposed = false;

  @override
  Future<void> dispose() {
    disposed++;
    routedWhenDisposed = RemoteRouter.usingLan && identical(backend(), this);
    return super.dispose();
  }
}

class NoDiscovery implements LanDiscoveryBackend {
  @override
  Stream<LanFound> browse(String type, Duration timeout) =>
      const Stream.empty();

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

/// The client side of a LAN login, end to end over loopback TLS: the
/// provider finds the paired server, signs in, and saves what the app
/// needs to keep working offline.
void main() {
  late LanTlsIdentity identity;
  late LanServer server;
  late LanRoutingDeps noShopRouting;
  final shopKey = 'b' * 64;

  final shopJson = <String, dynamic>{
    'shop_id': 7,
    'created_at': '2026-01-02T03:04:05.000Z',
    'user_id': 'owner',
    'name': 'Test Shop',
    'currency': 'NGN',
    'is_verified': true,
    'employees': ['cashier'],
  };

  // What the server answers with; a test may break it.
  var servedShop = Map<String, dynamic>.of(shopJson);

  // As a person pairing with the code does: the server and its trust.
  Future<void> pairWith({required int port, String? pin}) async {
    await LanPairedServersFunc().put(
      LanPairedServer(
        serverDeviceId: 'desk-1',
        certFingerprint: pin ?? identity.fingerprint,
        port: port,
        addresses: const ['127.0.0.1'],
        pairedAt: DateTime.utc(2026, 11, 25),
      ),
    );
    await LanPairedServersFunc().markPairedByPerson(pin ?? identity.fingerprint);
  }

  setUpAll(() async {
    identity = LanTlsIdentity.generate();
    Hive.init(
      Directory.systemTemp.createTempSync('stockall_lan_client_login').path,
    );
    await DeviceIdentity().init();
    await UserFunc().init();
    await LoggedInUserFunc().init();
    await ShopFunc().init();
    await LocalServerFunc().init();
    await LanPairedServersFunc().init();
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanClientSessionFunc().init();
    await LanShopKeysFunc().init();
    await CurrentShopFunc().init();
    await LanPairedDevicesFunc().init();

    LanTransport().discovery = NoDiscovery();
    LanTransport().interfaces = () async => const <LanInterface>[];
    // Routing (run after a LAN login) is tested in lan_routing_test.dart;
    // here it sees no shop and stays put (but see the current-shop test).
    LanRouting().deps = noShopRouting = LanRoutingDeps(
      shopId: () => null,
      serving: (_) => false,
      hasSession: (_) => false,
      connectedClient: () => null,
      connect: (_, {required quick}) async => false,
      presence: (_) async => LanPresence.unsure,
      interfaceUp: () => false,
      sync: () async {},
      handoffStatus: () async => null,
      supabaseTarget: () => throw UnimplementedError(),
      notifyServerSynced: () {},
    );
    LanTransport().remoteFactory =
        ({
          required connection,
          required token,
          required deviceId,
          onAnswer,
        }) {
          final client = CountingRemote(
            'https://stockall-lan:${connection.current.port}',
            'stockall-lan',
            accessToken: () async => token,
          );
          CountingRemote.made.add(client);
          return client;
        };

    // The "server" side shares this process's Hive, as a desktop would.
    await LanShopKeysFunc().put(7, shopKey);
    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
      [
        TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Cashier',
          pin: '4321',
          departmentUuids: const [],
          access: const ['Make Sale'],
        ),
      ],
      iterations: 1000,
    );
    server = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {
        'shop_tag': shopTag(shopKey),
        'epoch': 3,
        'server_device_id': 'desk-1',
        'cleared': false,
        'claimed_at': null,
      },
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => servedShop),
    );
    await server.start(ports: const [0]);
  });

  setUp(() async {
    servedShop = Map<String, dynamic>.of(shopJson);
    await LanPairedServersFunc().pairedServersBox.clear();
    await LanPairedServersFunc().trustBox.clear();
    await LanClientSessionFunc().clearClientSessions();
    await LanServerSessionsFunc().clearSessions();
    await LoggedInUserFunc().logOut();
    await CurrentShopFunc().clearCurrentShop();
  });

  tearDownAll(() async {
    await LanTransport().disconnectClient();
    await server.stop();
    await Hive.close();
  });

  test('no paired server: falls through to the existing login at once',
      () async {
    final watch = Stopwatch()..start();
    final result = await LocalServerProvider().loginViaLan(
      email: 'ada@shop.test',
      password: 'right',
    );

    expect(result, LanAuthResult.unreachable);
    expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
  });

  test('a paired server that is down is unreachable', () async {
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final closedPort = closed.port;
    await closed.close();
    await pairWith(port: closedPort);

    final result = await LocalServerProvider().loginViaLan(
      email: 'ada@shop.test',
      password: 'right',
    );

    expect(result, LanAuthResult.unreachable);
    expect(LanClientSessionFunc().all(), isEmpty);
  });

  test('a wrong password is final and saves nothing', () async {
    await pairWith(port: server.port!);

    final result = await LocalServerProvider().loginViaLan(
      email: 'ada@shop.test',
      password: 'wrong',
    );

    expect(result, LanAuthResult.invalidCredentials);
    expect(LanClientSessionFunc().all(), isEmpty);
    expect(LoggedInUserFunc().getLoggedInUser(), isNull);
  });

  test('a server with another certificate is never trusted', () async {
    await pairWith(port: server.port!, pin: 'c' * 64);

    final result = await LocalServerProvider().loginViaLan(
      email: 'ada@shop.test',
      password: 'right',
    );

    // The pin fails during the handshake, so no password is ever sent.
    expect(result, LanAuthResult.unreachable);
    expect(LanServerSessionsFunc().sessionsBox.values, isEmpty);
    expect(LanClientSessionFunc().all(), isEmpty);
  });

  test('shopFromLanLogin refuses a shop missing a field fromJson needs', () {
    expect(LocalServerProvider.shopFromLanLogin(shopJson)!.name, 'Test Shop');
    expect(LocalServerProvider.shopFromLanLogin(null), isNull);
    for (final field in [
      'is_verified',
      'currency',
      'name',
      'created_at',
      'shop_id',
      'user_id',
    ]) {
      final missing = Map<String, dynamic>.of(shopJson)..remove(field);
      final nulled = Map<String, dynamic>.of(shopJson)..[field] = null;
      expect(LocalServerProvider.shopFromLanLogin(missing), isNull, reason: field);
      expect(LocalServerProvider.shopFromLanLogin(nulled), isNull, reason: field);
    }
    expect(
      LocalServerProvider.shopFromLanLogin({
        ...shopJson,
        'created_at': 'not a date',
      }),
      isNull,
    );
    expect(
      LocalServerProvider.shopFromLanLogin({...shopJson, 'is_verified': 'yes'}),
      isNull,
    );
    // Any other field of the wrong type is caught too.
    expect(
      LocalServerProvider.shopFromLanLogin({...shopJson, 'employees': 'x'}),
      isNull,
    );
  });

  test('an incomplete shop fails the LAN login cleanly: nothing saved, '
      'the server session ended, the normal login can run', () async {
    servedShop.remove('is_verified');
    await pairWith(port: server.port!);

    final result = await LocalServerProvider().loginViaLan(
      email: 'ada@shop.test',
      password: 'right',
    );

    // `failed` (not `invalidCredentials`) is what makes signIn fall
    // through to the Supabase / offline login.
    expect(result, LanAuthResult.failed);
    expect(LanClientSessionFunc().all(), isEmpty);
    expect(LoggedInUserFunc().getLoggedInUser(), isNull);
    expect(LanServerSessionsFunc().sessionsBox.values, isEmpty);
  });

  test('login saves session, key, shop and user; then connect, verify '
      'and logout', () async {
    await pairWith(port: server.port!);
    final provider = LocalServerProvider();

    final result = await provider.loginViaLan(
      email: 'ADA@shop.test',
      password: 'right',
    );

    expect(result, LanAuthResult.ok);
    final session = LanClientSessionFunc().get(7)!;
    expect(session.serverDeviceId, 'desk-1');
    expect(session.userId, 'cashier');
    expect(LanShopKeysFunc().get(7), shopKey);
    expect(ShopFunc().shopBox.get(7)!.name, 'Test Shop');
    final loggedIn = LoggedInUserFunc().getLoggedInUser()!.loggedInUser!;
    expect(loggedIn.userId, 'cashier');
    expect(loggedIn.pin, '4321');
    // The typed password, so a later offline login still works.
    expect(loggedIn.password, 'right');
    expect(
      UserFunc().offlineLoginByEmailandPassword('right', 'ada@shop.test')
          ?.userId,
      'cashier',
    );

    expect(await provider.connectToServer(shopId: 7), isTrue);
    expect(provider.isClientConnected, isTrue);
    expect(server.connectedSockets, 1);

    // One LAN client (one JSON-decoding isolate) for the connection.
    final first = LanTransport().lanClient;
    expect(first, same(CountingRemote.made.single));
    expect(LanTransport().lanClient, same(first));
    // Disposed when the connection ends, once the router no longer sends
    // anything to it; a new connection gets its own.
    RemoteRouter.debugUseLan(first!);
    await provider.disconnectFromServer();
    expect(LanTransport().lanClient, isNull);
    expect(CountingRemote.made.single.disposed, 1);
    expect(CountingRemote.made.single.routedWhenDisposed, isFalse);
    expect(RemoteRouter.usingLan, isFalse);
    expect(await provider.connectToServer(shopId: 7, quick: true), isTrue);
    expect(CountingRemote.made, hasLength(2));
    expect(LanTransport().lanClient, same(CountingRemote.made.last));

    expect(
      await provider.verifyPassword(
        shopId: 7,
        userId: 'cashier',
        password: 'right',
      ),
      LanAuthResult.ok,
    );
    expect(
      await provider.verifyPassword(
        shopId: 7,
        userId: 'cashier',
        password: 'nope',
      ),
      LanAuthResult.invalidCredentials,
    );

    await provider.logoutFromLan();

    expect(provider.isClientConnected, isFalse);
    expect(CountingRemote.made.map((c) => c.disposed), [1, 1]);
    expect(LanClientSessionFunc().all(), isEmpty);
    expect(LanServerSessionsFunc().sessionsBox.values, isEmpty);
  });

  test('a LAN login stores the current shop, and routing (reading it from '
      'there, not from the shops in memory) goes to the server', () async {
    await pairWith(port: server.port!);
    final provider = LocalServerProvider();
    final transport = LanTransport();
    // Everything but the shop as the app has it; the shop from Hive.
    LanRouting().deps = LanRoutingDeps(
      serving: (_) => false,
      hasSession: (shop) =>
          LanClientSessionFunc().get(shop) != null &&
          LanShopKeysFunc().get(shop) != null,
      connectedClient: () =>
          transport.isClientConnected ? transport.lanClient : null,
      connect: (shop, {required quick}) =>
          provider.connectToServer(shopId: shop, quick: quick),
      presence: (_) async => LanPresence.onLan,
      interfaceUp: () => true,
      sync: () async {},
      handoffStatus: () async => null,
      supabaseTarget: () => throw UnimplementedError(),
      notifyServerSynced: () {},
    );
    addTearDown(() async {
      LanRouting().deps = noShopRouting;
      await provider.disconnectFromServer();
      RemoteRouter.useSupabase();
      await LanClientSessionFunc().clearClientSessions();
    });
    expect(ShopProvider().userShops, isEmpty);
    expect(CurrentShopFunc().getCurrentShop(), isNull);

    expect(
      await provider.loginViaLan(email: 'ada@shop.test', password: 'right'),
      LanAuthResult.ok,
    );
    expect(CurrentShopFunc().getCurrentShop()?.currentShopId, 7);
    expect(LanRoutingDeps.currentShopId(), 7);

    // The login started an evaluation; this one runs after it.
    await LanRouting().evaluate();
    await LanRouting().evaluate();
    expect(RemoteRouter.route, LanRoute.lanUp);
    expect(ShopProvider().userShops, isEmpty);
  });

  test('a login answer never replaces the shop key this device holds',
      () async {
    // A server that answers with another key (as a rogue one would).
    final rogue = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {
        'shop_tag': shopTag(shopKey),
        'epoch': 3,
        'server_device_id': 'desk-1',
        'cleared': false,
        'claimed_at': null,
      },
      auth: _OtherKeyAuth(shopId: () => 7, shopJson: (_) => servedShop),
    );
    await rogue.start(ports: const [0]);
    addTearDown(rogue.stop);
    await pairWith(port: rogue.port!);

    expect(
      await LocalServerProvider().loginViaLan(
        email: 'ada@shop.test',
        password: 'right',
      ),
      LanAuthResult.ok,
    );
    expect(LanShopKeysFunc().get(7), shopKey);
    await LocalServerProvider().logoutFromLan();
  });

  test('no password goes to a paired server whose certificate no person '
      'paired: the normal login runs instead', () async {
    // Paired (say, by an older automatic follow) but not trusted.
    await LanPairedServersFunc().put(
      LanPairedServer(
        serverDeviceId: 'desk-1',
        certFingerprint: identity.fingerprint,
        port: server.port!,
        addresses: const ['127.0.0.1'],
        pairedAt: DateTime.utc(2026, 11, 25),
      ),
    );
    expect(
      await LocalServerProvider().loginViaLan(
        email: 'ada@shop.test',
        password: 'right',
      ),
      LanAuthResult.unreachable,
    );
    expect(LanServerSessionsFunc().sessionsBox.values, isEmpty);
    expect(LanClientSessionFunc().all(), isEmpty);
  });

  test('a server that says this device is not paired with it: no session, '
      'and the status asks to pair again', () async {
    // A server that only lets paired devices in (S4).
    final strict = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {
        'shop_tag': shopTag(shopKey),
        'epoch': 3,
        'server_device_id': 'desk-1',
        'cleared': false,
        'claimed_at': null,
      },
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => servedShop),
      admission: LanMemoryAdmission(),
    );
    await strict.start(ports: const [0]);
    addTearDown(strict.stop);
    await pairWith(port: strict.port!);

    final outcome = await LanTransport().loginToPairedServer(
      email: 'ada@shop.test',
      password: 'right',
      deviceId: 'this-till',
    );
    expect(outcome.result, LanAuthResult.unreachable);
    expect(outcome.notPairedBy, ['desk-1']);

    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(
        loggedInUser: TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Cashier',
          departmentUuids: const [],
          access: const ['Make Sale'],
        ),
      ),
    );
    expect(LocalServerProvider().mustPairAgainFor(7), isFalse);
    expect(
      await LocalServerProvider().signInOnServer(7, serverDeviceId: 'desk-1'),
      LanAuthResult.unreachable,
    );
    expect(LocalServerProvider().mustPairAgainFor(7), isTrue);
    expect(LanClientSessionFunc().all(), isEmpty);
  });
  test('after the store server refuses a password: the cloud decides when '
      'it can be reached, else the refusal is final', () {
    LanLoginStep step(LanAuthResult r, bool up) =>
        lanLoginStep(r, interfaceUp: up);
    for (final up in [true, false]) {
      expect(step(LanAuthResult.ok, up), LanLoginStep.signedIn);
      expect(step(LanAuthResult.rateLimited, up), LanLoginStep.rateLimited);
      expect(step(LanAuthResult.unreachable, up), LanLoginStep.fallback);
      expect(step(LanAuthResult.failed, up), LanLoginStep.fallback);
    }
    expect(step(LanAuthResult.invalidCredentials, true), LanLoginStep.cloudOnly);
    expect(step(LanAuthResult.invalidCredentials, false), LanLoginStep.refused);
  });

  test('a paired till may ask the server to fetch its logins again; not an '
      'unpaired one, and not more than once a minute', () async {
    var now = DateTime.utc(2026, 11, 27, 12);
    var refreshed = 0;
    final admission = LanMemoryAdmission();
    final refreshing = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 3},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => servedShop),
      admission: admission,
      onRefreshCredentials: () async => refreshed++,
      clock: () => now,
    );
    await refreshing.start(ports: const [0]);
    addTearDown(refreshing.stop);
    final secret = await admission.admit('phone-1');
    final connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', refreshing.port!),
    ], pin: identity.fingerprint))!;
    addTearDown(connection.close);

    Future<int> ask(String device, String? secret) async {
      try {
        await connection.postJson('/v1/auth/refresh', {
          'device_id': device,
          if (secret != null) 'pair_secret': secret,
        });
        return 202;
      } on LanHttpException catch (e) {
        return e.statusCode;
      }
    }

    expect(await ask('stranger', 'guess'), 403);
    expect(await ask('phone-1', null), 403);
    expect(refreshed, 0);
    expect(await ask('phone-1', secret), 202);
    await Future<void>.delayed(Duration.zero);
    expect(refreshed, 1);
    expect(await ask('phone-1', secret), 429);
    now = now.add(LanConstants.credentialRefreshGap);
    expect(await ask('phone-1', secret), 202);
    await Future<void>.delayed(Duration.zero);
    expect(refreshed, 2);
  });

  test('the till asks its paired server with the secret it was given',
      () async {
    var refreshed = 0;
    final admission = LanMemoryAdmission();
    final refreshing = LanServer(
      identity: identity,
      deviceId: 'desk-1',
      serverView: () => {'epoch': 3},
      auth: LanAuthService(shopId: () => 7, shopJson: (_) => servedShop),
      admission: admission,
      onRefreshCredentials: () async => refreshed++,
    );
    await refreshing.start(ports: const [0]);
    addTearDown(refreshing.stop);
    await pairWith(port: refreshing.port!);
    addTearDown(() => LanPairedDevicesFunc().secretsBox.clear());

    // No secret for it yet: nothing is asked.
    expect(
      await LanTransport().requestCredentialRefresh(deviceId: 'this-till'),
      isFalse,
    );
    await LanPairedDevicesFunc().putSecret(
      identity.fingerprint.toLowerCase(),
      await admission.admit('this-till'),
    );
    expect(
      await LanTransport().requestCredentialRefresh(deviceId: 'this-till'),
      isTrue,
    );
    await Future<void>.delayed(Duration.zero);
    expect(refreshed, 1);
  });
}

/// Answers every successful login with a shop key other than the store's.
class _OtherKeyAuth extends LanAuthService {
  _OtherKeyAuth({required super.shopId, super.shopJson});

  @override
  Future<LanAuthResponse> login(
    Map<String, dynamic> body, {
    required String remoteAddress,
  }) async {
    final answer = await super.login(body, remoteAddress: remoteAddress);
    if (answer.status != 200) return answer;
    return LanAuthResponse(200, {...answer.body, 'shop_key': 'z' * 64});
  }
}
