import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'lan_remote_router_test.dart' show MemoryAsyncStorage;

/// What routing sees of the app, scripted.
class World {
  int? shop = 7;
  bool serving = false;
  bool session = true;
  bool canConnect = true;
  bool connected = false;
  bool interfaceUp = true;
  LanPresence presence = LanPresence.onLan;
  // A Supabase session on this device (none after a LAN-only sign-in).
  bool cloudSession = true;
  LanHandoffStatus? status;
  // While set, a connect waits for it.
  Future<void>? connectGate;
  final events = <String>[];
  final client = SupabaseClient(
    'https://stockall-lan:47811',
    'stockall-lan',
    accessToken: () async => 'token',
  );
}

/// With [realShop], the shop comes from where the app keeps it (Hive's
/// current shop), not from [World.shop].
LanRoutingDeps depsOf(
  World w,
  LanHandoffTarget Function() target, {
  bool realShop = false,
}) {
  return LanRoutingDeps(
    shopId: realShop ? LanRoutingDeps.currentShopId : () => w.shop,
    serving: (_) => w.serving,
    hasSession: (_) => w.session,
    connectedClient: () => w.connected ? w.client : null,
    connect: (shop, {required quick}) async {
      w.events.add('connect');
      await w.connectGate;
      w.connected = w.canConnect;
      return w.canConnect;
    },
    presence: (_) async {
      w.events.add('presence');
      return w.presence;
    },
    interfaceUp: () => w.interfaceUp,
    sync: () async => w.events.add('sync'),
    handoffStatus: () async => w.status,
    supabaseTarget: target,
    notifyServerSynced: () => w.events.add('notify'),
    hasCloudSession: () => w.cloudSession,
  );
}

void main() {
  late World w;
  late HttpServer fakeSupabase;
  final received = <String>[];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // The test binding answers every HTTP request with 400; the replay
    // test needs the real network (a local fake Supabase).
    HttpOverrides.global = null;
    Hive.init(Directory.systemTemp.createTempSync('stockall_routing').path);
    await LanHandoffsFunc().init();
    await CurrentShopFunc().init();
    await Supabase.initialize(
      url: 'https://routing.test',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    fakeSupabase = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    fakeSupabase.listen((request) async {
      received.add('${request.method} ${request.uri.path}');
      await request.drain<void>();
      request.response.statusCode = 201;
      await request.response.close();
    });
  });

  tearDownAll(() async {
    await fakeSupabase.close(force: true);
    await Hive.close();
  });

  setUp(() async {
    w = World();
    received.clear();
    await LanHandoffsFunc().clearHandoffs();
    RemoteRouter.useSupabase();
    LanRouting().deps = depsOf(
      w,
      () => LanHandoffTarget(
        restUrl: 'http://127.0.0.1:${fakeSupabase.port}/rest/v1',
        headers: const {'apikey': 'anon'},
        client: http.Client(),
        lastWriteWins: true,
      ),
    );
  });

  tearDown(() => w.client.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Future<void> holdInsert(String uuid) => LanHandoffsFunc().add(
    jsonEncode(
      LanHandoff(
        kind: LanHandoffKind.rest,
        method: 'POST',
        path: 'products',
        query: '',
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'uuid': uuid}),
        serverDeviceId: 'desk-1',
        epoch: 3,
        serverTime: 100,
        handedAt: DateTime.now().toUtc(),
      ).toJson(),
    ),
  );

  test('the routing rule, as a table', () {
    LanRoute route({
      bool serving = false,
      bool session = true,
      bool reachable = false,
      LanPresence presence = LanPresence.onLan,
    }) => decideLanRoute(
      serving: serving,
      hasSession: session,
      serverReachable: reachable,
      presence: presence,
    );

    expect(route(serving: true), LanRoute.server);
    expect(route(session: false), LanRoute.standalone);
    expect(route(reachable: true), LanRoute.lanUp);
    expect(route(), LanRoute.lanDown);
    // When unsure, the safe side: offline on the LAN, never Supabase.
    expect(route(presence: LanPresence.unsure), LanRoute.lanDown);
    expect(route(presence: LanPresence.offLan), LanRoute.offLan);
  });

  test('on the LAN means a private /24 shared with the server', () {
    expect(sharesSubnet(['192.168.1.20'], ['192.168.1.5']), isTrue);
    expect(sharesSubnet(['10.0.4.9'], ['10.0.4.200', 'fe80::1%en0']), isTrue);
    expect(sharesSubnet(['192.168.2.20'], ['192.168.1.5']), isFalse);
    // Carrier and public addresses never count.
    expect(sharesSubnet(['100.64.1.2'], ['100.64.1.3']), isFalse);
    expect(sharesSubnet(['fe80::2%en0'], ['fe80::1%en0']), isFalse);
    expect(sharesSubnet(const [], ['192.168.1.5']), isFalse);
  });

  test('server answers: the LAN client is the backend, reachable whatever '
      'the interface flag says, and the queue syncs to the server', () async {
    final route = await LanRouting().evaluate();
    await settle();

    expect(route, LanRoute.lanUp);
    expect(RemoteRouter.route, LanRoute.lanUp);
    expect(RemoteRouter.usingLan, isTrue);
    expect(identical(backend(), w.client), isTrue);
    // The same client on every call: one per connection.
    expect(identical(backend(), backend()), isTrue);
    expect(RemoteRouter.reachable(false), isTrue);
    expect(w.events, ['connect', 'sync']);
  });

  test('on the LAN with the server down: offline (queue), never Supabase',
      () async {
    w.canConnect = false;
    final route = await LanRouting().evaluate();
    await settle();

    expect(route, LanRoute.lanDown);
    expect(RemoteRouter.reachable(true), isFalse);
    expect(identical(backend(), Supabase.instance.client), isFalse);
    // A query that runs anyway fails as a network error, not a server
    // answer, so the providers' offline handling runs.
    await expectLater(
      backend().from('products').select(),
      throwsA(isNot(isA<PostgrestException>())),
    );
    expect(w.events, ['connect', 'presence']);

    // Unsure counts as on the LAN.
    w.presence = LanPresence.unsure;
    expect(await LanRouting().evaluate(), LanRoute.lanDown);
  });

  test('no network at all: offline, without trying the server', () async {
    w.interfaceUp = false;
    expect(await LanRouting().evaluate(), LanRoute.lanDown);
    expect(RemoteRouter.reachable(false), isFalse);
    expect(w.events, isEmpty);
  });

  test('off the LAN: Supabase directly when online; the direct sync sends '
      'held handoffs first', () async {
    w.canConnect = false;
    w.presence = LanPresence.offLan;
    await holdInsert('p1');

    final route = await LanRouting().evaluate();
    await settle();

    expect(route, LanRoute.offLan);
    expect(identical(backend(), Supabase.instance.client), isTrue);
    expect(RemoteRouter.reachable(true), isTrue);
    expect(RemoteRouter.reachable(false), isFalse);
    expect(w.events, ['connect', 'presence', 'sync']);

    // syncData() runs this before its queues.
    await LanRouting().beforeSync();
    expect(received, ['POST /rest/v1/products']);
    expect(LanHandoffs().all(), isEmpty);
  });

  test('off the LAN, signed in only through the store server (no cloud '
      'session): it queues and waits, with no direct sync and no handoff '
      'replay, until the user signs in to the cloud', () async {
    w.canConnect = false;
    w.presence = LanPresence.offLan;
    w.cloudSession = false;
    await holdInsert('p1');

    final route = await LanRouting().evaluate();
    await settle();

    expect(route, LanRoute.offLan);
    expect(RemoteRouter.needsCloudSignIn, isTrue);
    expect(identical(backend(), Supabase.instance.client), isFalse);
    expect(RemoteRouter.reachable(true), isFalse);
    expect(w.events, ['connect', 'presence']);
    await LanRouting().beforeSync();
    expect(received, isEmpty);
    expect(LanHandoffs().all(), hasLength(1));
    // What every provider sees: a network error, so its queue stays.
    await expectLater(
      backend().from('products').insert({'uuid': 'p2'}),
      throwsA(isA<Exception>()),
    );

    // Signed in to the cloud: the next evaluation syncs, replaying first.
    w.cloudSession = true;
    expect(await LanRouting().evaluate(), LanRoute.offLan);
    expect(RemoteRouter.needsCloudSignIn, isFalse);
    expect(identical(backend(), Supabase.instance.client), isTrue);
    expect(RemoteRouter.reachable(true), isTrue);
    await LanRouting().beforeSync();
    expect(received, ['POST /rest/v1/products']);
    expect(LanHandoffs().all(), isEmpty);
  });

  test('on the LAN, handoffs are not replayed to Supabase; after a sync the '
      'server\'s status ends them', () async {
    await holdInsert('p1');
    await LanRouting().evaluate();
    await LanRouting().beforeSync();
    expect(received, isEmpty);
    expect(LanHandoffs().all(), hasLength(1));

    w.status = const LanHandoffStatus(
      serverDeviceId: 'desk-1',
      epoch: 3,
      syncedThrough: 200,
    );
    await LanRouting().afterSync();
    expect(LanHandoffs().all(), isEmpty);
  });

  test('the server and a device without a LAN session use Supabase', () async {
    w.serving = true;
    expect(await LanRouting().evaluate(), LanRoute.server);
    expect(identical(backend(), Supabase.instance.client), isTrue);
    expect(RemoteRouter.reachable(true), isTrue);
    // After a sync the server tells its clients.
    await LanRouting().afterSync();
    expect(w.events, ['notify']);

    w.serving = false;
    w.session = false;
    expect(await LanRouting().evaluate(), LanRoute.standalone);
    expect(identical(backend(), Supabase.instance.client), isTrue);
    w.shop = null;
    expect(await LanRouting().evaluate(), LanRoute.standalone);
    expect(w.events, ['notify']);
  });

  test('the server goes away: the next evaluation goes offline; it comes '
      'back: to the server again, and the queue syncs to it', () async {
    await LanRouting().evaluate();
    w.connected = false;
    w.canConnect = false;
    expect(await LanRouting().evaluate(), LanRoute.lanDown);
    w.canConnect = true;
    expect(await LanRouting().evaluate(), LanRoute.lanUp);
    await settle();
    expect(w.events.where((e) => e == 'sync'), hasLength(2));
  });
  group('the current shop, from Hive (not the shops in memory)', () {
    LanHandoffTarget noTarget() => throw UnimplementedError();

    tearDown(() async {
      LanRouting().stop();
      await CurrentShopFunc().clearCurrentShop();
      RemoteRouter.useSupabase();
    });

    Future<void> until(bool Function() done) async {
      for (var i = 0; i < 200 && !done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    }

    test('cold start with a LAN session: nothing goes anywhere until the '
        'first evaluation, which finds the server', () async {
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 7),
      );
      final gate = Completer<void>();
      w.connectGate = gate.future;
      LanRouting().deps = depsOf(w, noTarget, realShop: true);
      expect(ShopProvider().userShops, isEmpty);

      LanRouting().start();
      // The first evaluation is still connecting.
      expect(RemoteRouter.route, LanRoute.lanDown);
      expect(identical(backend(), Supabase.instance.client), isFalse);

      gate.complete();
      await LanRouting().evaluate();
      expect(RemoteRouter.route, LanRoute.lanUp);
      expect(identical(backend(), w.client), isTrue);
    });

    test('cold start without a LAN session: Supabase, as before', () async {
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 7),
      );
      w.session = false;
      LanRouting().deps = depsOf(w, noTarget, realShop: true);

      LanRouting().start();
      expect(RemoteRouter.route, LanRoute.standalone);
      await LanRouting().evaluate();
      expect(RemoteRouter.route, LanRoute.standalone);
    });

    test('the current shop changing runs routing again', () async {
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 7),
      );
      LanRouting().deps = depsOf(w, noTarget, realShop: true);
      LanRouting().start();
      await LanRouting().evaluate();
      expect(RemoteRouter.route, LanRoute.lanUp);

      // Another store, with no LAN session there.
      w.session = false;
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 8),
      );
      await until(() => RemoteRouter.route == LanRoute.standalone);
      expect(RemoteRouter.route, LanRoute.standalone);

      // Back to the store with the session.
      w.session = true;
      await CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: 7),
      );
      await until(() => RemoteRouter.route == LanRoute.lanUp);
      expect(RemoteRouter.route, LanRoute.lanUp);
    });
  });
}
