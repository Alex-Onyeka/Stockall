import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/categories_provider.dart';
import 'package:stockall/providers/customers_provider.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:stockall/providers/production_folder/materials_provider.dart';
import 'package:stockall/providers/production_folder/production_items_provider.dart';
import 'package:stockall/providers/storage_product_provider.dart';
import 'package:stockall/providers/suppliers_provider.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/sync/lan_puller.dart';

/// The LAN server's side of invalidate events: every change to a
/// served table's box, whatever made it (a LAN write, the server's own
/// screens, a pull from Supabase), is collected for [window], then sent as
/// one `{type: invalidate, tables: [...]}` event.
class LanInvalidator {
  LanInvalidator({
    required Iterable<LanTable<dynamic>> tables,
    required this.send,
    this.window = LanConstants.invalidateBatch,
    Timer Function(Duration, void Function())? timer,
  }) : _tables = tables.toList(),
       _timerOf = timer ?? Timer.new;

  final List<LanTable<dynamic>> _tables;
  final void Function(Map<String, dynamic> event) send;
  final Duration window;
  final Timer Function(Duration, void Function()) _timerOf;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  final Set<String> _changed = {};
  Timer? _timer;

  void start() {
    if (_subscriptions.isNotEmpty) return;
    for (final table in _tables) {
      final Stream<Object?>? changes;
      try {
        changes = table.watch();
      } catch (e) {
        // A box that failed to open: that table is never announced.
        unawaited(mainLocalLog('LAN invalidate: ${table.name} not watched: $e'));
        continue;
      }
      if (changes == null) continue;
      _subscriptions.add(changes.listen((_) => _add(table.name)));
    }
  }

  void _add(String table) {
    _changed.add(table);
    _timer ??= _timerOf(window, _flush);
  }

  void _flush() {
    _timer = null;
    if (_changed.isEmpty) return;
    final tables = _changed.toList()..sort();
    _changed.clear();
    send({'type': 'invalidate', 'tables': tables});
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _changed.clear();
    final subscriptions = List.of(_subscriptions);
    _subscriptions.clear();
    for (final s in subscriptions) {
      await s.cancel();
    }
  }
}

/// A LAN client's side of invalidate events.
///
/// - Every invalidated table is published on [stream] (screens holding a
///   date window of receipts, invoices, … reload from it).
/// - The tables the app keeps current with an incremental fetch are
///   refreshed in the background, each at most once per [minGap]: a change
///   inside the gap is picked up by one refresh at its end.
/// - After the connection comes back, every table counts as invalidated
///   once ([receiveAll]).
class LanInvalidations {
  static final LanInvalidations _instance = LanInvalidations._internal();
  factory LanInvalidations() => _instance;
  LanInvalidations._internal();

  final StreamController<Set<String>> _controller =
      StreamController<Set<String>>.broadcast();

  /// The tables of each invalidate event.
  Stream<Set<String>> get stream => _controller.stream;

  /// What refreshes each table (replaceable in tests).
  Map<String, Future<void> Function()>? _refreshers;
  Map<String, Future<void> Function()> get refreshers =>
      _refreshers ??= appRefreshers();
  set refreshers(Map<String, Future<void> Function()> value) =>
      _refreshers = value;

  Duration minGap = LanConstants.invalidateRefreshGap;
  DateTime Function() clock = DateTime.now;
  Timer Function(Duration, void Function()) timer = Timer.new;

  final Map<String, DateTime> _last = {};
  final Map<String, Timer> _later = {};

  /// One invalidate event's tables.
  void receive(Iterable<String> tables) {
    final names = tables.toSet();
    if (names.isEmpty) return;
    _controller.add(names);
    for (final name in names) {
      if (refreshers.containsKey(name)) _refresh(name);
    }
  }

  /// Every table (after a reconnect: changes may have been missed).
  void receiveAll() => receive({...lanPullPlans.keys, ...refreshers.keys});

  void _refresh(String table) {
    if (_later.containsKey(table)) return;
    final last = _last[table];
    final since = last == null ? null : clock().difference(last);
    if (since != null && since < minGap) {
      _later[table] = timer(minGap - since, () {
        _later.remove(table);
        _run(table);
      });
      return;
    }
    _run(table);
  }

  void _run(String table) {
    final refresh = refreshers[table];
    if (refresh == null) return;
    _last[table] = clock();
    unawaited(
      Future.sync(refresh).catchError((Object e) async {
        await mainLocalLog('LAN refresh of $table failed: $e');
      }),
    );
  }

  @visibleForTesting
  void reset() {
    for (final t in _later.values) {
      t.cancel();
    }
    _later.clear();
    _last.clear();
    _refreshers = null;
    minGap = LanConstants.invalidateRefreshGap;
    clock = DateTime.now;
    timer = Timer.new;
  }

  /// The app's incremental fetches, by table. Each reads the LAN server
  /// (the route is the LAN) and, as before, skips while its own queues
  /// hold changes.
  static Map<String, Future<void> Function()> appRefreshers() {
    int? shop() => LanRoutingDeps.currentShopId();
    return {
      'products': () => returnData().syncProductsIncremental(),
      'customers': () async {
        if (shop() case final id?) await CustomersProvider().fetchCustomers(id);
      },
      'categories': () async {
        if (shop() case final id?) await CategoriesProvider().getCategories(id);
      },
      'departments': () => DepartmentProvider().getDepartments(),
      'suppliers': () async {
        if (shop() case final id?) await SuppliersProvider().fetchSuppliers(id);
      },
      'storage_products': () async {
        if (shop() case final id?) {
          await StorageProductProvider().getStorageProducts(id);
        }
      },
      'production_materials': () => MaterialsProvider().getMaterials(),
      'production_items': () => ProductionItemsProvider().getProductionItems(),
    };
  }
}
