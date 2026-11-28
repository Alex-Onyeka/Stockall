import 'dart:async';

import 'package:stockall/main.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/sync/lan_puller.dart';

/// When the LAN server pulls from Supabase and refreshes its logins, while
/// it serves. Started and stopped with the server.
///
/// On each tick (and right after the server's own sync, and when the
/// interface changes), when online:
/// - the logins (`users`) are refreshed every [credentialsEvery];
/// - the busy tables ([fastTables]) are pulled every [fastEvery], the
///   others (with the store's settings and the permissions) every
///   [slowEvery], each by its cursor;
/// - each table is reconciled once its day is up ([LanPuller.reconcileDue]);
/// - when the interface comes back after being down: everything at once
///   ([LanPuller.catchUp], which also backfills if none completed yet),
///   and the logins.
///
/// Nothing is pulled while offline or while the server's own sync runs
/// (the puller checks again before each page). A failure is logged; the
/// step runs again when it is next due.
class LanServerScheduler {
  LanServerScheduler({
    required this.puller,
    required this.refreshCredentials,
    required this.online,
    required this.syncing,
    this.tickEvery = LanConstants.pullTick,
    this.fastEvery = LanConstants.pullFastEvery,
    this.slowEvery = LanConstants.pullSlowEvery,
    this.credentialsEvery = LanConstants.credentialsEvery,
    this.afterSyncDelay = LanConstants.pullAfterSyncDelay,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Pulled every [fastEvery]: what LAN clients sell from and work on.
  static const Set<String> fastTables = {
    'products',
    'customers',
    'storage_products',
    'production_materials',
    'production_items',
    'orders',
    'invoices',
  };

  final LanPuller puller;
  final Future<void> Function() refreshCredentials;
  final bool Function() online;
  final bool Function() syncing;
  final Duration tickEvery;
  final Duration fastEvery;
  final Duration slowEvery;
  final Duration credentialsEvery;
  final Duration afterSyncDelay;
  final DateTime Function() _clock;

  Timer? _ticker;
  Timer? _soon;
  bool _stopped = false;
  Future<void>? _running;
  bool _again = false;

  bool? _wasOnline;

  /// The interface came back; the catch-up waits for a pass that can pull.
  bool _catchUpDue = false;
  DateTime? _fastAt;
  DateTime? _slowAt;
  DateTime? _credentialsAt;

  /// When the server starts, just after its catch-up was started: the
  /// first scheduled pulls and login refresh are a full interval away.
  void start() {
    final now = _clock();
    _wasOnline = online();
    if (_wasOnline!) {
      _fastAt = now;
      _slowAt = now;
      _credentialsAt = now;
    }
    _ticker = Timer.periodic(tickEvery, (_) => unawaited(tick()));
  }

  void stop() {
    _stopped = true;
    _ticker?.cancel();
    _ticker = null;
    _soon?.cancel();
    _soon = null;
  }

  /// The server's own sync finished: Supabase now has its changes (and
  /// the stock the RPCs worked out). The busy tables are pulled shortly.
  void afterSync() {
    if (_stopped) return;
    _fastAt = null;
    _soon?.cancel();
    _soon = Timer(afterSyncDelay, () {
      _soon = null;
      unawaited(tick());
    });
  }

  /// One pass. A call while one runs runs once more after it.
  Future<void> tick() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final run = _pass().whenComplete(() {
      _running = null;
      if (_again && !_stopped) {
        _again = false;
        unawaited(tick());
      }
    });
    _running = run;
    return run;
  }

  bool _due(DateTime? at, Duration every, DateTime now) =>
      at == null || now.difference(at) >= every;

  Future<void> _pass() async {
    if (_stopped) return;
    final up = online();
    final cameBack = up && _wasOnline == false;
    _wasOnline = up;
    if (!up) return;
    if (cameBack) _catchUpDue = true;
    final now = _clock();

    if (cameBack || _due(_credentialsAt, credentialsEvery, now)) {
      _credentialsAt = now;
      try {
        await refreshCredentials();
      } catch (e) {
        await mainLocalLog('LAN login refresh failed: $e');
      }
    }
    if (_stopped || syncing()) return;

    if (_catchUpDue) {
      _catchUpDue = false;
      _fastAt = now;
      _slowAt = now;
      await _run('catch-up', puller.catchUp);
      return;
    }
    final names = puller.tableNames;
    final pull = <String>[
      if (_due(_fastAt, fastEvery, now))
        ...names.where(fastTables.contains),
      if (_due(_slowAt, slowEvery, now))
        ...names.where((n) => !fastTables.contains(n)),
    ];
    if (_due(_fastAt, fastEvery, now)) _fastAt = now;
    if (_due(_slowAt, slowEvery, now)) _slowAt = now;
    if (pull.isNotEmpty) {
      await _run('pull', () => puller.pullIncremental(pull));
    }
    for (final name in names) {
      if (_stopped || !online() || syncing()) return;
      if (puller.reconcileDue(name)) {
        await _run('reconcile of $name', () => puller.reconcile(name));
      }
    }
  }

  Future<void> _run(String what, Future<bool> Function() body) async {
    try {
      if (!await body()) {
        await mainLocalLog('LAN $what incomplete; again when next due');
      }
    } catch (e) {
      await mainLocalLog('LAN $what failed: $e');
    }
  }
}
