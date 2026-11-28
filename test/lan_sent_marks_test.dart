import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/customer_account_receipts_provider.dart';
import 'package:stockall/providers/quantity_update_provider.dart';
import 'package:stockall/services/lan/lan_held_deltas.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_carts.dart';
import 'lan_remote_router_test.dart' show MemoryAsyncStorage;

/// A store server's delta RPCs as the till sees them over HTTP: each
/// change applied once by its queue uuid (a repeat is skipped, as the real
/// server's applied set does), and, while [loseAnswers] is set, the answer
/// lost after the change was applied.
class FakeLanServer extends http.BaseClient {
  /// How often each queue uuid was applied (never more than once).
  final applied = <String, int>{};

  /// Every queue uuid received, repeats included.
  final received = <String>[];
  bool loseAnswers = false;

  /// Applies a batch: what the real server answers (the entries it took).
  List<Map<String, dynamic>> apply(List<dynamic> updates) {
    final done = <Map<String, dynamic>>[];
    for (final u in updates.cast<Map<String, dynamic>>()) {
      final id = u['hiveUuid'] as String;
      received.add(id);
      applied.putIfAbsent(id, () => 1);
      done.add({'hiveUuid': id});
    }
    return done;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().bytesToString();
    Object? answer = const [];
    if (request.method == 'POST' && request.url.path.contains('/rpc/')) {
      final updates = (jsonDecode(body) as Map)['updates'] as List;
      answer = apply(updates);
      if (loseAnswers) {
        throw const SocketException('connection reset after the write');
      }
    }
    final bytes = utf8.encode(jsonEncode(answer));
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      contentLength: bytes.length,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

/// A stock change sent to the store server whose answer is lost may already
/// be applied there: it is never sent to Supabase (off the LAN) or to
/// another server, only to that server again (which skips it), and it is
/// listed if that server is cleared.
void main() {
  late HttpServer supabase;
  final toSupabase = <String>[];
  late FakeLanServer lanServer;
  late SupabaseClient lan;
  late Directory dir;

  void onLan(String server) {
    LanSentMarks.target = () => RemoteRouter.usingLan ? server : null;
    RemoteRouter.debugUseLan(lan);
  }

  void offLan() => RemoteRouter.useOffLan(needsSignIn: false);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    dir = Directory.systemTemp.createTempSync('stockall_sent_marks');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => dir.path,
    );
    messenger.setMockStreamHandler(
      const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
      MockStreamHandler.inline(onListen: (_, _) {}),
    );
    supabase = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    supabase.listen((request) async {
      toSupabase.add('${request.method} ${request.uri.path}');
      await request.drain<void>();
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('[]');
      await request.response.close();
    });
    await Supabase.initialize(
      url: 'http://127.0.0.1:${supabase.port}',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    await MainDatabase().initHive();
    ConnectivityProvider().checkConnection(true);
  });

  tearDownAll(() async {
    LanSentMarks.target = LanSentMarks.appTarget;
    RemoteRouter.useSupabase();
    await supabase.close(force: true);
  });

  setUp(() async {
    toSupabase.clear();
    lanServer = FakeLanServer();
    lan = SupabaseClient(
      'https://stockall-lan:47811',
      'stockall-lan',
      httpClient: lanServer,
      accessToken: () async => 'token',
    );
    await QuantityUpdateFunc().quantityUpdateBox.clear();
    await CustomerAccountUpdateFunc().customerAccountUpdateBox.clear();
    await SentEntriesFunc().clearSentEntries();
    await LanPendingCheckoutsFunc().clearPending();
  });

  tearDown(() async {
    RemoteRouter.useSupabase();
    await lan.dispose();
  });

  Future<void> queueSale(String uuid, {double quantity = 2}) =>
      QuantityUpdateFunc().quantityUpdateBox.put(
        uuid,
        QuantityUpdate(
          uuid: uuid,
          createdAt: DateTime.now(),
          quantity: quantity,
          productUuid: 'p1',
          isIncrement: false,
          isStorage: false,
        ),
      );

  String products() => QuantityUpdateFunc().quantityUpdateBoxName;

  bool rpcToSupabase() => toSupabase.any((r) => r.contains('/rpc/'));

  test('a product change applied by the server whose answer was lost: off '
      'the LAN it is not sent to Supabase; back on the LAN it goes to that '
      'server again, which skips it; applied once in all', () async {
    await queueSale('q1');
    onLan('desk-1');
    lanServer.loseAnswers = true;

    await QuantityUpdateProvider().quantityUpdateSync();
    expect(lanServer.applied, {'q1': 1});
    expect(QuantityUpdateFunc().quantityUpdateBox.containsKey('q1'), isTrue);
    expect(SentEntriesFunc().serverOf(products(), 'q1'), 'desk-1');

    // The till leaves the LAN: the direct sync leaves it queued.
    offLan();
    await QuantityUpdateProvider().quantityUpdateSync();
    expect(rpcToSupabase(), isFalse);
    expect(QuantityUpdateFunc().quantityUpdateBox.containsKey('q1'), isTrue);

    // A change made off the LAN still goes to Supabase directly.
    await queueSale('q2');
    await QuantityUpdateProvider().quantityUpdateSync();
    expect(rpcToSupabase(), isTrue);
    expect(QuantityUpdateFunc().quantityUpdateBox.keys, ['q1']);
    toSupabase.clear();

    // Back on the LAN with the server answering.
    onLan('desk-1');
    lanServer.loseAnswers = false;
    await QuantityUpdateProvider().quantityUpdateSync();
    expect(lanServer.received, ['q1', 'q1']);
    expect(lanServer.applied, {'q1': 1});
    expect(QuantityUpdateFunc().quantityUpdateBox.isEmpty, isTrue);
    expect(SentEntriesFunc().sentEntriesBox.isEmpty, isTrue);
    expect(SentEntriesFunc().sentToServerBox.isEmpty, isTrue);
    expect(rpcToSupabase(), isFalse);
  });

  test('nor to another store server: it waits for its own', () async {
    await queueSale('q1');
    onLan('desk-1');
    lanServer.loseAnswers = true;
    await QuantityUpdateProvider().quantityUpdateSync();

    onLan('desk-2');
    lanServer.loseAnswers = false;
    await QuantityUpdateProvider().quantityUpdateSync();
    expect(lanServer.received, ['q1']);
    expect(QuantityUpdateFunc().quantityUpdateBox.containsKey('q1'), isTrue);
  });

  test('a customer account change: the same', () async {
    final accounts = CustomerAccountUpdateFunc();
    await accounts.customerAccountUpdateBox.put(
      'a1',
      CustomerAccountUpdate(
        uuid: 'a1',
        createdAt: DateTime.now(),
        amount: 500,
        customerUuid: 'c1',
        isIncrement: true,
        isBalance: true,
      ),
    );
    onLan('desk-1');
    lanServer.loseAnswers = true;
    await CustomerAccountReceiptsProvider().customerAccountUpdateSync();
    expect(lanServer.applied, {'a1': 1});
    expect(
      SentEntriesFunc().serverOf(accounts.customerAccountUpdateBoxName, 'a1'),
      'desk-1',
    );

    offLan();
    await CustomerAccountReceiptsProvider().customerAccountUpdateSync();
    expect(rpcToSupabase(), isFalse);
    expect(accounts.customerAccountUpdateBox.containsKey('a1'), isTrue);

    onLan('desk-1');
    lanServer.loseAnswers = false;
    await CustomerAccountReceiptsProvider().customerAccountUpdateSync();
    expect(lanServer.applied, {'a1': 1});
    expect(accounts.customerAccountUpdateBox.isEmpty, isTrue);
    expect(SentEntriesFunc().sentToServerBox.isEmpty, isTrue);
  });

  test('a checkout whose answer was lost: its stock changes are not sent '
      'to Supabase off the LAN; the retry on the LAN ends them once',
      () async {
    await queueSale('q1');
    final client = LanStockClient();
    var calls = 0;
    var lose = true;
    final link = LanStockLink(
      call: (rpc, params) async {
        calls++;
        final done = lanServer.apply(params['updates'] as List);
        if (lose) throw const SocketException('answer lost');
        return {'done': [for (final d in done) d['hiveUuid']], 'reserved': {}};
      },
    );
    client
      ..reset()
      ..deps = LanStockClientDeps(
        link: () => link,
        route: () => RemoteRouter.route,
        carts: () => const [],
        held: (_) => true,
        queued: () => {
          for (final q in QuantityUpdateFunc().getQuantitiesUpdate())
            q.uuid!: {
              'hiveUuid': q.uuid,
              'itemUuid': q.productUuid,
              'quantity': q.quantity,
              'isIncrement': q.isIncrement,
              'isStorage': q.isStorage,
            },
        },
        dropQueued: (uuids) async {
          for (final u in uuids) {
            await QuantityUpdateFunc().deleteQuantityUpdate(uuid: u);
          }
        },
        sentQueue: products(),
        serverId: () => 'desk-1',
      );
    addTearDown(client.reset);
    onLan('desk-1');

    await client.checkout(
      cart: cart('c1', []),
      receiptUuid: 'r1',
      queueBefore: const {},
    );
    expect(calls, 1);
    expect(lanServer.applied, {'q1': 1});
    expect(SentEntriesFunc().serverOf(products(), 'q1'), 'desk-1');

    offLan();
    await QuantityUpdateProvider().quantityUpdateSync();
    expect(rpcToSupabase(), isFalse);
    expect(QuantityUpdateFunc().quantityUpdateBox.containsKey('q1'), isTrue);

    onLan('desk-1');
    lose = false;
    await client.retryPending();
    expect(lanServer.applied, {'q1': 1});
    expect(QuantityUpdateFunc().quantityUpdateBox.isEmpty, isTrue);
    expect(SentEntriesFunc().sentToServerBox.isEmpty, isTrue);
    expect(client.pendingCheckouts, isEmpty);
  });

  test('a cleared server: what it never answered for is listed (and stays '
      'queued for it)', () async {
    await queueSale('q1', quantity: 3);
    onLan('desk-1');
    lanServer.loseAnswers = true;
    await QuantityUpdateProvider().quantityUpdateSync();

    final held = heldQueuedFor('desk-1');
    expect(held, hasLength(1));
    expect(held.single.kind, 'Product');
    expect(held.single.itemUuid, 'p1');
    expect(held.single.amount, 3);
    expect(held.single.isIncrement, isFalse);
    expect(held.single.source, 'Not confirmed');
    expect(heldQueuedFor('desk-2'), isEmpty);
    expect(QuantityUpdateFunc().quantityUpdateBox.containsKey('q1'), isTrue);
  });
}
