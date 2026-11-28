import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_client_session_func.dart';
import 'package:stockall/local_database/lan/lan_paired_servers_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_discovery.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_transport_io.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// No servers advertised; another till of the shop is seen nearby (so the
/// till knows it is on the shop's network when its server stops).
class _NoDiscovery implements LanDiscoveryBackend {
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
  Stream<LanFound> browse(String type, Duration timeout) =>
      type == LanConstants.peerServiceType
      ? Stream.value(
          LanFound(
            name: 'Stockall-peer-phone-2',
            addresses: const ['127.0.0.1'],
            port: 0,
            txt: {
              'v': LanConstants.protocolVersion,
              't': shopTag('shop-key-7'),
              'tv': LanConstants.shopTagVersion,
              'e': '2',
              'd': 'phone-2',
            },
          ),
        )
      : const Stream.empty();
}

/// End to end on a till: the store server ("desk", its own isolate
/// and Hive) says whether it reaches the internet and how far its first
/// load is; the till shows it and hides the online-only screens; and the
/// password re-entry is checked by the server while it answers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The widget binding answers every HttpClient request with 400; these
  // tests talk to a real server over TLS.
  HttpOverrides.global = null;

  const key = 'shop-key-7';
  late PeerServer desk;

  Future<void> eventually(
    FutureOr<bool> Function() done, {
    Duration within = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(within);
    while (!await done()) {
      if (DateTime.now().isAfter(end)) fail('timed out');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Signed in on [desk] and routed there.
  Future<void> join() async {
    await LanTransport().disconnectClient();
    RemoteRouter.useSupabase();
    await LanClientSessionFunc().delete(7);
    await LanPairedServersFunc().pairedServersBox.clear();
    await LanPairedServersFunc().trustBox.clear();
    await LocalServerFunc().putRecord(
      LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: 'desk',
        claimedAt: DateTime.utc(2026, 11, 20),
        certFingerprint: desk.fingerprint,
        lastKnownAddresses: const ['127.0.0.1'],
      ),
    );
    LocalServerProvider().clearCache();
    await LanPairedServersFunc().put(
      LanPairedServer(
        serverDeviceId: 'desk',
        certFingerprint: desk.fingerprint,
        port: desk.port,
        addresses: const ['127.0.0.1'],
        pairedAt: DateTime.now().toUtc(),
        label: 'Stockall-desk',
      ),
    );
    await LanPairedServersFunc().markPairedByPerson(desk.fingerprint);
    expect(
      await LocalServerProvider().loginViaLan(
        email: 'ada@shop.test',
        password: 'right',
      ),
      LanAuthResult.ok,
    );
    await UserProvider().fetchCurrentUserOffline();
    await eventually(() => RemoteRouter.route == LanRoute.lanUp);
  }

  setUpAll(() async {
    final tillDir = Directory.systemTemp.createTempSync('stockall_p10_till');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
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
    await UserProvider().fetchCurrentUserOffline();
    await LanShopKeysFunc().put(7, key);
    LanTransport()
      ..discovery = _NoDiscovery()
      ..interfaces = (() async => const [])
      ..browseTimeout = const Duration(milliseconds: 10)
      ..loginBrowseTimeout = const Duration(milliseconds: 10)
      ..backfillPollEvery = const Duration(milliseconds: 100)
      ..isOnline = (() => false);
    LocalServerProvider();
    ConnectivityProvider().interfaceUp = true;
    LanRouting().start();
  });

  setUp(() async {
    desk = await PeerServer.spawn(
      shopKey: key,
      deviceId: 'desk',
      epoch: 2,
      claimedAt: DateTime.utc(2026, 11, 20),
    );
  });

  tearDown(() async {
    await LanTransport().disconnectClient();
    await desk.stop();
  });

  tearDownAll(() {
    LanRouting().stop();
    RemoteRouter.useSupabase();
  });

  test('the server\'s internet and first load reach the till: shown, and '
      'the online-only screens follow its internet', () async {
    await desk.setBackfill(table: 'products');
    await join();
    final provider = LocalServerProvider();

    var status = provider.status;
    expect(status.kind, LanStatusKind.connected);
    expect(status.serverOnline, isTrue);
    expect(status.loading, isTrue);
    expect(status.backfill!.table, 'products');
    expect(provider.onlineFeaturesAvailable, isTrue);

    // Done: read again while it ran, without an event.
    await desk.setBackfill(done: true);
    await eventually(() => !provider.status.loading);

    // Its internet goes: it says so, and the till hides them.
    await desk.setOnline(false);
    await eventually(() => !provider.onlineFeaturesAvailable);
    expect(provider.status.serverOnline, isFalse);
    await desk.setOnline(true);
    await eventually(() => provider.onlineFeaturesAvailable);

    // The server stops answering: hidden, and nothing known of it.
    await desk.halt();
    await eventually(() => RemoteRouter.route == LanRoute.lanDown);
    expect(provider.onlineFeaturesAvailable, isFalse);
    expect(provider.status.kind, LanStatusKind.serverUnreachable);
    expect(provider.status.serverOnline, isNull);
  });

  test('the password re-entry: the server checks it while it answers; '
      'otherwise the password kept for offline login', () async {
    await join();
    final provider = LocalServerProvider();
    // The copy kept here differs from the server's, to tell them apart.
    final user = LoggedInUserFunc().getLoggedInUser()!.loggedInUser!;
    user.password = 'kept-here';
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(loggedInUser: user),
    );
    Future<LanAuthResult> confirm(String password, {String user = 'cashier'}) =>
        provider.confirmPassword(shopId: 7, userId: user, password: password);

    expect(await confirm('right'), LanAuthResult.ok);
    expect(await confirm('kept-here'), LanAuthResult.invalidCredentials);

    await desk.halt();
    await eventually(() => !LanTransport().isClientConnected);
    expect(await confirm('kept-here'), LanAuthResult.ok);
    expect(await confirm('right'), LanAuthResult.invalidCredentials);
    // Only for the user signed in here.
    expect(
      await confirm('kept-here', user: 'someone-else'),
      LanAuthResult.invalidCredentials,
    );
  });

  test('after pairing (P10b): signed in on the server with the password '
      'kept here, and routed there; a password the server refuses is said',
      () async {
    await LanTransport().disconnectClient();
    RemoteRouter.useSupabase();
    await LanClientSessionFunc().delete(7);
    await LanPairedServersFunc().pairedServersBox.clear();
    await LanPairedServersFunc().trustBox.clear();
    await LanPairedServersFunc().put(
      LanPairedServer(
        serverDeviceId: 'desk',
        certFingerprint: desk.fingerprint,
        port: desk.port,
        addresses: const ['127.0.0.1'],
        pairedAt: DateTime.now().toUtc(),
        label: 'Stockall-desk',
      ),
    );
    await LanPairedServersFunc().markPairedByPerson(desk.fingerprint);
    final user = LoggedInUserFunc().getLoggedInUser()!.loggedInUser!;
    Future<void> keep(String password) async {
      user.password = password;
      await LoggedInUserFunc().insertLoggedInUser(
        LoggedInUser(loggedInUser: user),
      );
    }

    final provider = LocalServerProvider();
    await keep('not-the-servers');
    expect(
      await provider.signInAfterPairing(shopId: 7, serverDeviceId: 'desk'),
      LanAuthResult.invalidCredentials,
    );
    expect(LanClientSessionFunc().get(7), isNull);

    await keep('right');
    expect(
      await provider.signInAfterPairing(shopId: 7, serverDeviceId: 'desk'),
      LanAuthResult.ok,
    );
    expect(LanClientSessionFunc().get(7)?.serverDeviceId, 'desk');
    await eventually(() => RemoteRouter.route == LanRoute.lanUp);
    expect(provider.status.kind, LanStatusKind.connected);
  });
}
