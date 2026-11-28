import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/services/lan/sync/lan_puller.dart';
import 'package:stockall/services/lan/sync/lan_server_scheduler.dart';
import 'package:stockall/services/lan/sync/lan_supabase_reader.dart';

Future<R> _direct<R>(Future<R> Function() body) => body();

/// Records what the schedule asks of the puller.
class _Puller extends LanPuller {
  _Puller()
    : super(
        tables: const [],
        reader: LanSupabaseReader(
          restUrl: () => 'http://127.0.0.1:1/rest/v1',
          headers: () => const {},
          client: http.Client(),
        ),
        shopId: () => 7,
        exclusive: _direct,
        canPull: () => true,
      );

  final calls = <String>[];
  final due = <String>{};
  Object? failWith;

  @override
  List<String> get tableNames => const [
    'categories',
    'products',
    'orders',
    'item_history',
  ];

  Future<bool> _record(String call) async {
    calls.add(call);
    if (failWith case final e?) throw e;
    return true;
  }

  @override
  Future<bool> pullIncremental([List<String>? names]) =>
      _record('pull ${names!.join(',')}');

  @override
  Future<bool> catchUp() => _record('catch-up');

  @override
  bool reconcileDue(String name) => due.contains(name);

  @override
  Future<bool> reconcile(String name) {
    due.remove(name);
    return _record('reconcile $name');
  }
}

void main() {
  late _Puller puller;
  late LanServerScheduler schedule;
  late DateTime now;
  var online = true;
  var syncing = false;
  var logins = 0;
  Object? loginFailure;

  LanServerScheduler make() => LanServerScheduler(
    puller: puller,
    refreshCredentials: () async {
      logins++;
      if (loginFailure case final e?) throw e;
    },
    online: () => online,
    syncing: () => syncing,
    clock: () => now,
    // Ticks are called by the tests.
    tickEvery: const Duration(days: 1),
    afterSyncDelay: const Duration(milliseconds: 20),
  );

  setUp(() {
    puller = _Puller();
    now = DateTime.utc(2026, 11, 26, 9);
    online = true;
    syncing = false;
    logins = 0;
    loginFailure = null;
    schedule = make();
  });

  tearDown(() => schedule.stop());

  Future<List<String>> tickAt(Duration sinceStart, DateTime start) async {
    now = start.add(sinceStart);
    puller.calls.clear();
    await schedule.tick();
    return List.of(puller.calls);
  }

  test('busy tables every 60 s, the others every 5 min, logins every '
      '15 min; nothing before (the server\'s start did a catch-up)',
      () async {
    final start = now;
    schedule.start();

    expect(await tickAt(const Duration(seconds: 15), start), isEmpty);
    expect(logins, 0);
    expect(await tickAt(const Duration(seconds: 60), start), [
      'pull products,orders',
    ]);
    expect(await tickAt(const Duration(seconds: 75), start), isEmpty);
    expect(await tickAt(const Duration(minutes: 5), start), [
      'pull products,orders,categories,item_history',
    ]);
    expect(logins, 0);
    expect(await tickAt(const Duration(minutes: 15), start), [
      'pull products,orders,categories,item_history',
    ]);
    expect(logins, 1);
    expect(await tickAt(const Duration(minutes: 16), start), [
      'pull products,orders',
    ]);
    expect(logins, 1);
    expect(await tickAt(const Duration(minutes: 30), start), hasLength(1));
    expect(logins, 2);
  });

  test('a table whose day is up is reconciled', () async {
    final start = now;
    schedule.start();
    puller.due.add('categories');
    expect(await tickAt(const Duration(seconds: 15), start), [
      'reconcile categories',
    ]);
    expect(await tickAt(const Duration(seconds: 30), start), isEmpty);
  });

  test('offline: nothing; while the server\'s own sync runs: no pulls',
      () async {
    final start = now;
    schedule.start();
    online = false;
    expect(await tickAt(const Duration(minutes: 20), start), isEmpty);
    expect(logins, 0);

    // (Back online, but syncing: the catch-up waits; logins go ahead.)
    online = true;
    syncing = true;
    puller.due.add('products');
    expect(await tickAt(const Duration(minutes: 21), start), isEmpty);
    expect(logins, 1);

    syncing = false;
    expect(await tickAt(const Duration(minutes: 22), start), ['catch-up']);
  });

  test('the interface comes back: a catch-up and a login refresh at once; '
      'a server started offline catches up the same way', () async {
    online = false;
    final start = now;
    schedule.start();
    expect(await tickAt(const Duration(seconds: 15), start), isEmpty);

    online = true;
    expect(await tickAt(const Duration(seconds: 20), start), ['catch-up']);
    expect(logins, 1);
    // The intervals start again from the catch-up.
    expect(await tickAt(const Duration(seconds: 70), start), isEmpty);
    expect(await tickAt(const Duration(seconds: 80), start), [
      'pull products,orders',
    ]);
  });

  test('after the server\'s own sync, the busy tables are pulled shortly',
      () async {
    final start = now;
    schedule.start();
    now = start.add(const Duration(seconds: 10));
    schedule.afterSync();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(puller.calls, ['pull products,orders']);
  });

  test('failures are logged, not thrown, and the steps run again when next '
      'due', () async {
    final start = now;
    schedule.start();
    loginFailure = StateError('no network');
    puller.failWith = StateError('timeout');

    expect(await tickAt(const Duration(minutes: 15), start), [
      'pull products,orders,categories,item_history',
    ]);
    expect(logins, 1);

    loginFailure = null;
    puller.failWith = null;
    expect(await tickAt(const Duration(minutes: 16), start), [
      'pull products,orders',
    ]);
    expect(await tickAt(const Duration(minutes: 30), start), hasLength(1));
    expect(logins, 2);
  });

  test('stopped: nothing runs', () async {
    final start = now;
    schedule.start();
    schedule.stop();
    schedule.afterSync();
    expect(await tickAt(const Duration(hours: 1), start), isEmpty);
    expect(logins, 0);
  });
}
