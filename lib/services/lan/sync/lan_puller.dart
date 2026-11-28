import 'dart:async';

import 'package:hive/hive.dart';

import 'package:stockall/local_database/lan/lan_pull_cursors_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/sync/lan_pending_deltas.dart';
import 'package:stockall/services/lan/sync/lan_supabase_reader.dart';

/// How one table is pulled: its backfill group (what LAN clients need
/// first goes first) and the column its changes are found by.
class LanPullPlan {
  const LanPullPlan(this.group, {this.cursor = 'updated_at', this.key});

  final int group;

  /// `updated_at`; `created_at` for tables the app only appends to.
  final String cursor;

  /// The row's key column when the table has no writes (else theirs).
  final String? key;
}

/// Every table the server pulls. `users` is not here: the credential
/// refresh keeps them (`LanUserBackfill`). Other stores are never pulled.
const Map<String, LanPullPlan> lanPullPlans = {
  // 1: the store and its lists.
  'shops': LanPullPlan(1),
  'permissions': LanPullPlan(1, cursor: 'created_at', key: 'id'),
  'departments': LanPullPlan(1),
  'categories': LanPullPlan(1),
  'suppliers': LanPullPlan(1),
  'expense_categories': LanPullPlan(1),
  'sub_staff': LanPullPlan(1),
  // 2: what a sale needs.
  'products': LanPullPlan(2),
  'customers': LanPullPlan(2),
  'storage_products': LanPullPlan(2),
  'production_materials': LanPullPlan(2),
  'production_items': LanPullPlan(2),
  // 3: open documents.
  'orders': LanPullPlan(3),
  'invoices': LanPullPlan(3),
  'drafts': LanPullPlan(3),
  // 4: records. Receipts by `created_at`: the app's receipts carry no
  // `updated_at`, so Supabase may not have one (their updates come with the
  // weekly reconcile).
  'receipts': LanPullPlan(4, cursor: 'created_at'),
  'expenses': LanPullPlan(4),
  'purchases': LanPullPlan(4),
  'customer_account_receipts': LanPullPlan(4),
  'production_records': LanPullPlan(4),
  'production_materials_usage': LanPullPlan(4),
  // 5: histories and logs, only ever appended to.
  'storage_item_history': LanPullPlan(5, cursor: 'created_at'),
  'item_history': LanPullPlan(5, cursor: 'created_at'),
  'inventory_updates': LanPullPlan(5, cursor: 'created_at'),
  'event_logs': LanPullPlan(5, cursor: 'created_at'),
  'error_logs': LanPullPlan(5, cursor: 'created_at'),
  'production_item_history': LanPullPlan(5, cursor: 'created_at'),
  'production_materials_item_history': LanPullPlan(5, cursor: 'created_at'),
};

/// Where a backfill is, for `GET /v1/server` (the status shows "still loading").
class LanPullProgress {
  bool running = false;

  /// A complete backfill has finished (now or before).
  bool done = false;
  String? table;
  DateTime? at;

  Map<String, dynamic> toJson() => {
    'running': running,
    'done': done,
    'table': table,
    'at': at?.toUtc().toIso8601String(),
  };
}

/// The LAN server's pulls from Supabase: the served store's
/// rows into the server's own boxes, without its queues (Supabase already
/// has them), so the server answers LAN clients with what Supabase has.
///
/// - Rows with local work queued (a create, an update or a delete) are
///   kept as they are.
/// - Stock and account changes still queued are added back to the rows
///   pulled, under the delta RPCs' lock; a page is dropped (and
///   pulled again next time) when one of them left its queue meanwhile,
///   since the page may already include it.
/// - A full pull, and the daily reconcile, also remove local rows Supabase
///   no longer has (asked again just before), unless their create is still
///   queued, and record removed items of the delta tables as deleted.
/// - The reconcile is cheap on most days (it costs data on mobile): daily,
///   only each row's key and `updated_at` are listed, and the rows missing
///   here or changed are fetched. Weekly, every row is fetched again, for
///   updates that don't change `updated_at`.
class LanPuller {
  LanPuller({
    required Iterable<LanTable<dynamic>> tables,
    required this.reader,
    required this.shopId,
    required this.exclusive,
    required this.canPull,
    this.onRemoteDeleted,
    this.pageSize = 1000,
    this.overlap = const Duration(seconds: 5),
    this.reconcileEvery = const Duration(hours: 24),
    this.fullRowsEvery = const Duration(days: 7),
    this.refetchChunk = 100,
    DateTime Function()? clock,
    LanPullCursorsFunc? cursors,
  }) : _tables = {
         for (final t in tables)
           if (lanPullPlans.containsKey(t.name) && t.pull != null) t.name: t,
       },
       _clock = clock ?? DateTime.now,
       _cursors = cursors ?? LanPullCursorsFunc();

  final Map<String, LanTable<dynamic>> _tables;
  final LanSupabaseReader reader;
  final int Function() shopId;

  /// The delta RPCs' lock (`LanDeltaRpcs.runExclusive`).
  final Future<R> Function<R>(Future<R> Function() body) exclusive;

  /// Online, and the server's own sync isn't running.
  final bool Function() canPull;

  /// An item of a delta table Supabase no longer has.
  final Future<void> Function(String table, String uuid)? onRemoteDeleted;
  final int pageSize;
  final Duration overlap;

  /// How often each table is reconciled ([reconcileDue]).
  final Duration reconcileEvery;

  /// How often a reconcile fetches every row again (else keys and
  /// `updated_at` only).
  final Duration fullRowsEvery;

  /// Keys per request when rows are fetched (or checked) by key.
  final int refetchChunk;
  final DateTime Function() _clock;
  final LanPullCursorsFunc _cursors;

  final LanPullProgress progress = LanPullProgress();
  bool _stopped = false;
  Future<bool>? _running;

  /// The tables pulled, in backfill order.
  List<String> get tableNames {
    final names = _tables.keys.toList();
    names.sort((a, b) {
      final g = lanPullPlans[a]!.group.compareTo(lanPullPlans[b]!.group);
      return g != 0
          ? g
          : lanPullPlans.keys.toList().indexOf(a).compareTo(
              lanPullPlans.keys.toList().indexOf(b),
            );
    });
    return names;
  }

  /// Ends any run at its next page.
  void stop() => _stopped = true;

  bool _go() => !_stopped && canPull();

  /// One run at a time: a call while one runs gets that run's result.
  Future<bool> _single(Future<bool> Function() body) {
    final running = _running;
    if (running != null) return running;
    final run = body().whenComplete(() => _running = null);
    _running = run;
    return run;
  }

  /// When the server starts: a backfill if none ever completed; otherwise
  /// each table is reconciled when due ([reconcileDue]), else pulled by its
  /// cursor.
  Future<bool> catchUp() {
    final last = _cursors.backfillAt();
    if (last == null) return backfill();
    progress
      ..done = true
      ..at = last;
    return _single(() async {
      var complete = true;
      for (final name in tableNames) {
        if (_stopped) return false;
        final ok = await _guard(
          name,
          () => reconcileDue(name) ? _reconcile(name) : _incremental(name),
        );
        if (!ok) complete = false;
      }
      return complete;
    });
  }

  /// [name] was not reconciled (or pulled in full) in the last
  /// [reconcileEvery].
  bool reconcileDue(String name) {
    final last = _cursors.reconciledAt(name) ?? _cursors.fullPullAt(name);
    return last == null || _clock().difference(last) >= reconcileEvery;
  }

  /// Every table in full, in backfill order. True when all
  /// completed.
  Future<bool> backfill() => _single(() async {
    progress
      ..running = true
      ..done = false;
    var complete = true;
    try {
      for (final name in tableNames) {
        if (_stopped) return false;
        progress.table = name;
        if (!await _guard(name, () => _full(name))) complete = false;
      }
      if (complete) {
        final at = _clock().toUtc();
        await _cursors.setBackfillAt(at);
        progress
          ..done = true
          ..at = at;
        await mainLocalLog('LAN backfill complete');
      }
      return complete;
    } finally {
      progress
        ..running = false
        ..table = null;
    }
  });

  /// [names] (default: every table) by their cursor. A table never pulled
  /// is pulled in full.
  Future<bool> pullIncremental([List<String>? names]) => _single(() async {
    var complete = true;
    for (final name in names ?? tableNames) {
      if (_stopped) return false;
      if (!await _guard(name, () => _incremental(name))) complete = false;
    }
    return complete;
  });

  /// One table in full, every row (the backfill's step).
  Future<bool> fullPull(String name) =>
      _single(() => _guard(name, () => _full(name)));

  /// One table against Supabase: every row when the last full pull is
  /// older than [fullRowsEvery], otherwise by key and `updated_at` only.
  Future<bool> reconcile(String name) =>
      _single(() => _guard(name, () => _reconcile(name)));

  Future<bool> _guard(String name, Future<bool> Function() body) async {
    if (!_tables.containsKey(name)) return false;
    try {
      return await body();
    } catch (e) {
      await mainLocalLog('LAN pull of $name failed: $e');
      return false;
    }
  }

  Future<bool> _full(String name) {
    final table = _tables[name]!;
    return table.withRowType(<T>(LanTable<T> t) => _fullTyped<T>(t));
  }

  Future<bool> _reconcile(String name) {
    final last = _cursors.fullPullAt(name);
    if (last == null || _clock().difference(last) >= fullRowsEvery) {
      return _full(name);
    }
    final table = _tables[name]!;
    return table.withRowType(<T>(LanTable<T> t) => _lightTyped<T>(t));
  }

  Future<bool> _incremental(String name) {
    final table = _tables[name]!;
    if (_cursors.cursor(name) == null) return _full(name);
    return table.withRowType(<T>(LanTable<T> t) => _incrementalTyped<T>(t));
  }

  String _keyOf(LanTable<dynamic> t) =>
      t.writes?.key ?? lanPullPlans[t.name]!.key ?? 'uuid';

  List<(String, String)> _scope(LanTable<dynamic> t) => [
    if (!t.global) ('shop_id', 'eq.${shopId()}'),
  ];

  Future<bool> _fullTyped<T>(LanTable<T> t) async {
    final plan = lanPullPlans[t.name]!;
    final key = _keyOf(t);
    final seen = <String>{};
    String? newest;
    String? held;
    String? last;
    while (true) {
      if (!_go()) return false;
      final page = await _fetchAndStore(t, key, [
        ..._scope(t),
        ('order', '$key.asc'),
        ('limit', '$pageSize'),
        if (last != null) (key, 'gt.$last'),
      ]);
      if (page == null) return false;
      final rows = page.rows;
      held = _earlier(held, page.held);
      for (final row in rows) {
        seen.add('${row[key]}');
        newest = _later(newest, row[plan.cursor]);
      }
      if (rows.length < pageSize) break;
      last = '${rows.last[key]}';
    }
    await _removeUnseen(t, key, seen);
    newest = _earlier(newest, held);
    if (newest != null) await _cursors.setCursor(t.name, newest);
    await _cursors.setFullPullAt(t.name, _clock());
    await _cursors.setReconciledAt(t.name, _clock());
    return true;
  }

  /// The daily reconcile: lists each row's key (and `updated_at`, when the
  /// table is pulled by it and the rows here carry it), then fetches the
  /// rows missing here or whose `updated_at` differs, and removes the rows
  /// Supabase no longer has.
  Future<bool> _lightTyped<T>(LanTable<T> t) async {
    final plan = lanPullPlans[t.name]!;
    final key = _keyOf(t);
    final keyOf = t.columns[key]?.get;
    if (keyOf == null) return _fullTyped(t);
    final timeOf = plan.cursor == 'updated_at'
        ? t.columns['updated_at']?.get
        : null;
    final remote = <String, DateTime?>{};
    String? newest;
    String? last;
    while (true) {
      if (!_go()) return false;
      final rows = await reader.rows(t.name, [
        ..._scope(t),
        ('select', timeOf != null ? '$key,updated_at' : key),
        ('order', '$key.asc'),
        ('limit', '$pageSize'),
        if (last != null) (key, 'gt.$last'),
      ]);
      for (final row in rows) {
        remote['${row[key]}'] = _instant(row['updated_at']);
        if (timeOf != null) newest = _later(newest, row['updated_at']);
      }
      if (rows.length < pageSize) break;
      last = '${rows.last[key]}';
    }
    final local = <String, T>{
      for (final row in t.rows())
        if (t.global || t.shopIdOf(row) == shopId()) '${keyOf(row)}': row,
    };
    final pending = t.pull!.pending();
    final stale = <String>[];
    for (final MapEntry(key: id, value: at) in remote.entries) {
      if (pending.contains(id)) continue;
      final row = local[id];
      if (row == null ||
          (timeOf != null && !_same(at, _instant(timeOf(row))))) {
        stale.add(id);
      }
    }
    String? held;
    for (var i = 0; i < stale.length; i += refetchChunk) {
      if (!_go()) return false;
      final page = await _fetchAndStore(t, key, [
        ..._scope(t),
        (key, _inList(stale.skip(i).take(refetchChunk))),
      ]);
      if (page == null) return false;
      held = _earlier(held, page.held);
    }
    await _removeUnseen(t, key, remote.keys.toSet());
    if (newest != null && _later(_cursors.cursor(t.name), newest) == newest) {
      await _cursors.setCursor(t.name, newest);
    }
    // A row left out (changed here meanwhile) is pulled again next time.
    if (held != null) {
      final cursor = _earlier(_cursors.cursor(t.name), held);
      if (cursor != null) await _cursors.setCursor(t.name, cursor);
    }
    await _cursors.setReconciledAt(t.name, _clock());
    if (stale.isNotEmpty) {
      await mainLocalLog('LAN reconcile of ${t.name}: ${stale.length} fetched');
    }
    return true;
  }

  Future<bool> _incrementalTyped<T>(LanTable<T> t) async {
    final plan = lanPullPlans[t.name]!;
    final key = _keyOf(t);
    final cursor = DateTime.tryParse(_cursors.cursor(t.name)!);
    if (cursor == null) return _fullTyped(t);
    final since = cursor.toUtc().subtract(overlap).toIso8601String();
    final at = plan.cursor;
    String? held;
    // Keyset pages: after the last row's (cursor, key), so a row that
    // changes while paging can't shift the rest out of a page.
    (String, String)? last;
    while (true) {
      if (!_go()) return false;
      final page = await _fetchAndStore(t, key, [
        ..._scope(t),
        if (last case (final lastAt, final lastKey))
          (
            'or',
            '($at.gt.${_quoted(lastAt)},'
                'and($at.eq.${_quoted(lastAt)},$key.gt.${_quoted(lastKey)}))',
          )
        else
          (at, 'gt.$since'),
        ('order', '$at.asc,$key.asc'),
        ('limit', '$pageSize'),
      ]);
      if (page == null) return false;
      final rows = page.rows;
      held = _earlier(held, page.held);
      String? newest = _cursors.cursor(t.name);
      for (final row in rows) {
        newest = _later(newest, row[at]);
      }
      // Never past a row left out (changed here meanwhile).
      newest = _earlier(newest, held);
      if (newest != null) await _cursors.setCursor(t.name, newest);
      if (rows.length < pageSize) return true;
      final lastRow = rows.last;
      if (lastRow[at] == null) return true;
      last = ('${lastRow[at]}', '${lastRow[key]}');
    }
  }

  /// Fetches a page and stores it ([_store]), watching [t]'s box from
  /// before the fetch: a row this device changes meanwhile (the server's
  /// own till, outside the lock) is left out rather than overwritten
  /// with what Supabase had before the change.
  Future<_PulledPage?> _fetchAndStore<T>(
    LanTable<T> t,
    String key,
    List<(String, String)> query,
  ) async {
    final before = PendingDeltas.queueKeys(t.name);
    final local = _LocalChanges(t.watch());
    try {
      final rows = await reader.rows(t.name, query);
      return await _store(t, rows, before, key, local);
    } finally {
      await local.close();
    }
  }

  /// Stores a page under the delta lock. Null: a queued delta of this
  /// table left its queue since the page was asked for (it may be in the
  /// page already), so nothing is stored. Rows [local] saw change here
  /// since the fetch began are left out; the page's `held` is the
  /// earliest cursor among them, which the cursor never passes.
  Future<_PulledPage?> _store<T>(
    LanTable<T> t,
    List<Map<String, dynamic>> rows,
    Set<Object?> deltasBefore,
    String key,
    _LocalChanges local,
  ) {
    final store = t.pull!;
    final fromJson = store.fromJson ?? t.writes!.fromJson;
    final find = t.writes?.find;
    final at = lanPullPlans[t.name]!.cursor;
    return exclusive(() async {
      if (!PendingDeltas.stillQueued(t.name, deltasBefore)) {
        await mainLocalLog(
          'LAN pull of ${t.name}: a queued change was sent meanwhile (or '
          'is out); pulling it again next time',
        );
        return null;
      }
      final changedHere = await local.close();
      final pending = store.pending();
      final fresh = <T>[];
      String? held;
      for (final json in rows) {
        final id = '${json[key]}';
        if (pending.contains(id)) continue;
        if (changedHere.contains(id)) {
          held = _earlier(held, json[at] ?? '');
          continue;
        }
        final T row;
        try {
          row = fromJson(json);
        } catch (e) {
          await mainLocalLog('LAN pull of ${t.name}: row $id unreadable: $e');
          continue;
        }
        final stored = find?.call(id);
        if (stored != null) {
          t.writes?.carryOver?.call(stored, row);
          store.adopt?.call(stored, row);
        }
        fresh.add(row);
      }
      PendingDeltas.reapply(t.name, fresh);
      for (final row in fresh) {
        await store.put(row);
      }
      if (held != null) {
        await mainLocalLog(
          'LAN pull of ${t.name}: rows changed here meanwhile; '
          'pulling them again next time',
        );
      }
      return _PulledPage(rows, held);
    });
  }

  /// After a full pull or a reconcile: rows of this store Supabase no
  /// longer has. Supabase is asked about them once more first: one the
  /// server's own sync sent after they were listed is still there.
  Future<void> _removeUnseen<T>(
    LanTable<T> t,
    String key,
    Set<String> seen,
  ) async {
    final keyOf = t.columns[key]?.get;
    if (keyOf == null) return;
    final store = t.pull!;
    List<String> unseen() {
      final pending = store.pending();
      return [
        for (final row in t.rows())
          if (t.global || t.shopIdOf(row) == shopId())
            if ('${keyOf(row)}' case final id
                when !seen.contains(id) && !pending.contains(id))
              id,
      ];
    }

    final candidates = unseen();
    if (candidates.isEmpty) return;
    final present = <String>{};
    for (var i = 0; i < candidates.length; i += refetchChunk) {
      if (!_go()) return;
      final rows = await reader.rows(t.name, [
        ..._scope(t),
        ('select', key),
        (key, _inList(candidates.skip(i).take(refetchChunk))),
      ]);
      present.addAll(rows.map((r) => '${r[key]}'));
    }
    await exclusive(() async {
      final gone = [
        for (final id in unseen())
          if (candidates.contains(id) && !present.contains(id)) id,
      ];
      for (final id in gone) {
        await store.remove(id);
        if (PendingDeltas.tables.contains(t.name)) {
          await onRemoteDeleted?.call(t.name, id);
        }
      }
      if (gone.isNotEmpty) {
        await mainLocalLog('LAN pull of ${t.name}: ${gone.length} removed');
      }
    });
  }

  /// PostgREST's `in.(…)`, each value quoted.
  static String _inList(Iterable<String> ids) =>
      'in.(${ids.map((id) => '"${id.replaceAll('"', r'\"')}"').join(',')})';

  static DateTime? _instant(Object? value) => switch (value) {
    DateTime d => d,
    String s => DateTime.tryParse(s),
    _ => null,
  };

  static bool _same(DateTime? a, DateTime? b) =>
      a == null || b == null ? a == b : a.isAtSameMomentAs(b);

  /// A value for PostgREST's `or=(…)`, double-quoted.
  static String _quoted(String value) =>
      '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

  /// The earlier of two cursor values; an unreadable one ('' for a row
  /// with none) counts as the earliest.
  static String? _earlier(String? a, Object? b) {
    if (b is! String) return a;
    if (a == null) return b;
    final ta = DateTime.tryParse(a);
    final tb = DateTime.tryParse(b);
    if (tb == null) return b;
    if (ta == null) return a;
    return tb.isBefore(ta) ? b : a;
  }

  static String? _later(String? a, Object? b) {
    if (b is! String) return a;
    final tb = DateTime.tryParse(b);
    if (tb == null) return a;
    if (a == null) return b;
    final ta = DateTime.tryParse(a);
    return ta == null || tb.isAfter(ta) ? b : a;
  }
}

/// A page fetched and stored: its rows, and the earliest cursor value of
/// those left out because this device changed them meanwhile.
class _PulledPage {
  const _PulledPage(this.rows, this.held);

  final List<Map<String, dynamic>> rows;
  final String? held;
}

/// The keys of a box's changes seen while a page is fetched.
class _LocalChanges {
  _LocalChanges(Stream<Object?>? changes) {
    _subscription = changes?.listen((event) {
      if (event is BoxEvent) keys.add('${event.key}');
    });
  }

  final keys = <String>{};
  StreamSubscription<Object?>? _subscription;

  /// Stops watching, after the changes already made are delivered.
  Future<Set<String>> close() async {
    final subscription = _subscription;
    if (subscription != null) {
      _subscription = null;
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
    }
    return keys;
  }
}
