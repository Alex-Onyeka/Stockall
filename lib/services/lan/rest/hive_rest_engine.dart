import 'dart:convert';

import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_online_scope.dart';
import 'package:stockall/services/lan/rest/lan_rest_handler.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

/// Forwards a request that names other stores to Supabase, after checking
/// that [principal] belongs to each of [otherShops].
abstract class LanProxy {
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  );
}

/// The server's own RPCs for cart stock holds (`LanStockService`).
abstract class LanStockRpcs {
  bool handles(String name);
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal);
}

/// Why a request only Supabase can answer was refused while the server is
/// offline.
const String lanNeedsInternetMessage =
    'This needs the internet. The store server is offline right now; try '
    'again when it is back online.';

/// Why a write to another store was refused while the server is offline.
const String lanOtherShopOfflineMessage =
    'This change is for another store, so it needs the internet. The store '
    'server is offline right now; try again when it is back online.';

/// Answers the app's PostgREST queries from the server's Hive boxes.
///
/// Read pipeline: table → forced shop scope → candidates (a date-index
/// range when the query has a date window, otherwise every row) → typed
/// filters → department scope → order → count → offset/limit → `toJson`
/// for the returned page only → column projection.
///
/// Writes: another store → Supabase when online, refused otherwise;
/// this store → permission (any of the op's permissions) → matched
/// rows → department check → validation of every row → the table's
/// hooks (main box + the app's queues) → [onWrite].
class HiveRestEngine implements LanRestHandler {
  HiveRestEngine({
    required List<LanTable<dynamic>> tables,
    required this.shopId,
    required this.manageDepartments,
    bool Function()? isOnline,
    this.proxy,
    this.rpcs,
    this.onWrite,
    this.onlineOnlyTables = const {},
    this.onlineOnlyRpcs = const {},
    this.onMembersChanged,
    this.onDeleted,
    this.stock,
    this.storeMembers,
    this.onDenied,
  }) : _tables = {for (final t in tables) t.name: t},
       _isOnline = isOnline ?? (() => false);

  final Map<String, LanTable<dynamic>> _tables;

  /// The shop this server serves.
  final int Function() shopId;

  /// The served shop's `manage_departments` setting.
  final bool Function() manageDepartments;
  final bool Function() _isOnline;
  final LanProxy? proxy;

  /// The delta RPCs; null: every RPC is unknown.
  final LanDeltaRpcs? rpcs;

  /// Called after every write that changed the server's boxes (e.g. to
  /// start the server's own sync).
  final void Function()? onWrite;

  /// Tables and RPCs only Supabase has: forwarded when the server is
  /// online, refused with `LAN01` otherwise.
  final Set<String> onlineOnlyTables;
  final Set<String> onlineOnlyRpcs;

  /// Called after a forwarded change to a store's members or a user (so
  /// the server refreshes its LAN logins).
  final void Function()? onMembersChanged;

  /// Called for each row a LAN delete removed (e.g. to remember it, so a
  /// late delta for it is dropped rather than refused).
  final Future<void> Function(String table, String key)? onDeleted;

  /// Cart stock holds: answers the `lan_stock_*` and `lan_checkout`
  /// RPCs.
  final LanStockRpcs? stock;

  /// The served store's owner and members, for scoping what is forwarded
  /// to Supabase; by default from the `shops` and `users` tables.
  final LanStoreMembers Function()? storeMembers;

  /// Told of each RPC refused for permission (to log it).
  final void Function(String what, LanPrincipal principal)? onDenied;

  Iterable<String> get tableNames => _tables.keys;

  /// Stops watching the boxes and drops the indexes.
  Future<void> dispose() async {
    for (final table in _tables.values) {
      await table.dispose();
    }
  }

  @override
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal) async {
    if (principal.shopId != shopId()) {
      throw const PgError(403, 'LAN03', 'This session is for another store');
    }
    switch (request.op) {
      case PgOp.select:
      case PgOp.count:
        final table = _tables[request.table];
        if (table == null) {
          if (onlineOnlyTables.contains(request.table)) {
            return _online(request, principal, null);
          }
          throw PgError.unknownTable(request.table);
        }
        return _read(table, request, principal);
      case PgOp.rpc:
        final holds = stock;
        if (holds != null && holds.handles(request.table)) {
          // A device changes only its own holds.
          _requireCall(principal, request.table);
          return holds.handle(request, principal);
        }
        final deltas = rpcs;
        if (deltas != null && deltas.handles(request.table)) {
          _requireCall(principal, request.table);
          return deltas.handle(request);
        }
        if (onlineOnlyRpcs.contains(request.table)) {
          _requireCall(principal, request.table);
          return _online(request, principal, null);
        }
        throw PgError.unknownFunction(request.table);
      case PgOp.insert:
      case PgOp.upsert:
      case PgOp.update:
      case PgOp.delete:
        // A product's stock changes only between stock operations (holds,
        // checkouts, deltas, pulls).
        // One that goes to Supabase (another store's, or one only Supabase
        // can do) waits on the network, so never under the lock.
        final lock = rpcs;
        if (request.table == 'products' &&
            lock != null &&
            _writesHere(request)) {
          return lock.runExclusive(() => _write(request, principal));
        }
        return _write(request, principal);
    }
  }

  Future<PgResponse> _read(
    LanTable<dynamic> table,
    PgRequest request,
    LanPrincipal principal,
  ) {
    return table.withRowType(
      <X>(LanTable<X> typed) => _readTyped<X>(typed, request, principal),
    );
  }

  // --------------------------------------------------------------- writes

  Future<PgResponse> _write(PgRequest request, LanPrincipal principal) async {
    final own = shopId();

    // Another store: there are no local rows to change, so it goes to
    // Supabase when the server can reach it and is refused otherwise.
    final shops = _writeShops(request);
    final others = shops.where((s) => s != own).toSet();
    if (others.isNotEmpty) {
      if (shops.contains(own)) {
        throw const PgError(
          400,
          'LAN05',
          'One change cannot cover this store and another store',
        );
      }
      _requireWrite(principal, request.table, _opOf(request.op));
      final forward = proxy;
      if (forward == null || !_isOnline()) {
        throw const PgError(503, 'LAN01', lanOtherShopOfflineMessage);
      }
      return forward.forward(request, principal, others);
    }

    final table = _tables[request.table];
    if (table == null) {
      if (onlineOnlyTables.contains(request.table)) {
        return _online(request, principal, _opOf(request.op));
      }
      throw PgError.unknownTable(request.table);
    }
    if (_needsSupabase(table, request)) {
      return _online(request, principal, _opOf(request.op));
    }
    return table.withRowType(
      <X>(LanTable<X> typed) => _writeTyped<X>(typed, request, principal),
    );
  }

  /// Whether [_write] changes this server's rows rather than forwarding
  /// [request] to Supabase.
  bool _writesHere(PgRequest request) {
    final own = shopId();
    if (_writeShops(request).any((s) => s != own)) return false;
    final table = _tables[request.table];
    return table != null && !_needsSupabase(table, request);
  }

  /// A write only Supabase can do on this table (see [LanWrites.onlineOps]).
  bool _needsSupabase(LanTable<dynamic> table, PgRequest request) {
    final writes = table.writes;
    if (writes == null) return false;
    final ops = request.op == PgOp.upsert
        ? const [LanWriteOp.insert, LanWriteOp.update]
        : [_opOf(request.op)];
    if (ops.any(writes.onlineOps.contains)) return true;
    return request.op == PgOp.update &&
        request.rows.any((r) => r.keys.any(writes.onlineColumns.contains));
  }

  /// Forwards a request only Supabase can answer: after the permission
  /// check for a write ([op]), when the server is online; `LAN01`
  /// otherwise.
  Future<PgResponse> _online(
    PgRequest request,
    LanPrincipal principal,
    LanWriteOp? op,
  ) async {
    if (op != null) {
      _requireWrite(
        principal,
        request.table,
        op,
        ownRow: _ownUsersRow(request, principal),
      );
    }
    // Forwarded with the server's own Supabase session: limited to this
    // store's rows first.
    final store = (storeMembers ?? _storeMembersFromTables)();
    final scoped = LanOnlineScope.scope(
      request,
      principal,
      shopId: shopId(),
      store: store,
    );
    final forward = proxy;
    if (forward == null || !_isOnline()) {
      throw const PgError(503, 'LAN01', lanNeedsInternetMessage);
    }
    final own = shopId();
    final others = {
      ..._writeShops(scoped).where((s) => s != own),
    };
    final response = await forward.forward(scoped, principal, others);
    if (op != null &&
        response.status < 300 &&
        (request.table == 'users' || request.table == 'shops')) {
      onMembersChanged?.call();
    }
    final body = LanOnlineScope.filterAnswer(scoped, response.body, store);
    if (identical(body, response.body)) return response;
    return PgResponse(response.status, headers: response.headers, body: body);
  }

  /// The served store's owner and members, from its `shops` row and its
  /// `users` (the LAN logins).
  LanStoreMembers _storeMembersFromTables() {
    final own = shopId();
    var owner = '';
    final members = <String>{};
    final shops = _tables['shops'];
    if (shops != null) {
      shops.withRowType(<X>(LanTable<X> t) {
        for (final row in t.rows()) {
          if (t.shopIdOf(row) != own) continue;
          final json = t.toJson(row);
          owner = '${json['user_id'] ?? ''}';
          for (final e in json['employees'] as List? ?? const []) {
            members.add('$e');
          }
        }
        return null;
      });
    }
    final users = _tables['users'];
    if (users != null) {
      users.withRowType(<X>(LanTable<X> t) {
        for (final row in t.rows()) {
          final id = t.toJson(row)['user_id'];
          if (id is String && id.isNotEmpty) members.add(id);
        }
        return null;
      });
    }
    if (owner.isNotEmpty) members.add(owner);
    return LanStoreMembers(ownerId: owner, members: members);
  }

  /// The user updating their own `users` row, and only the columns the app
  /// lets everyone change (not their role, access or departments).
  static const Set<String> _ownUserColumns = {
    'password',
    'pin',
    'name',
    'last_name',
    'email',
    'phone',
  };

  bool _ownUsersRow(PgRequest request, LanPrincipal principal) {
    if (request.table != 'users' || request.op != PgOp.update) return false;
    final f = request.filters;
    return f.length == 1 &&
        f.single.column == 'user_id' &&
        f.single.op == PgFilterOp.eq &&
        f.single.value == principal.userId &&
        request.orGroups.isEmpty &&
        request.rows.every((r) => r.keys.every(_ownUserColumns.contains));
  }

  Future<PgResponse> _writeTyped<T>(
    LanTable<T> table,
    PgRequest request,
    LanPrincipal principal,
  ) async {
    final writes = table.writes;
    if (writes == null) {
      throw PgError(
        405,
        'LAN501',
        'Writes to ${table.name} through the LAN server are not available '
            'yet',
      );
    }
    final columns = request.columns;
    if (columns != null) {
      for (final c in columns) {
        _column(table, c);
      }
    }

    final List<T> written;
    switch (request.op) {
      case PgOp.insert:
      case PgOp.upsert:
        written = await _insert(table, writes, request, principal);
      case PgOp.update:
        written = await _update(table, writes, request, principal);
      case PgOp.delete:
        written = await _delete(table, writes, request, principal);
      default:
        throw StateError('not a write: ${request.op}');
    }

    if (written.isNotEmpty) {
      // Don't wait for the box watcher: the next read must see the write.
      table.invalidate();
      onWrite?.call();
    }
    return pgWriteResponse(request, [
      for (final row in written) _project(table, row, columns),
    ]);
  }

  /// One INSERT (or upsert) statement: every row is checked before any is
  /// stored, so a duplicate fails the whole batch as on Postgres.
  Future<List<T>> _insert<T>(
    LanTable<T> table,
    LanWrites<T> w,
    PgRequest request,
    LanPrincipal principal,
  ) async {
    final upsert = request.op == PgOp.upsert;
    if (w.insert == null || (upsert && w.update == null)) {
      throw _notHere(table, request.op);
    }
    if (!upsert) _requireWrite(principal, table.name, LanWriteOp.insert);
    if (upsert && (request.onConflict ?? w.key) != w.key) {
      throw PgError(
        400,
        'PGRST100',
        'on_conflict must be ${w.key} for ${table.name}',
      );
    }
    final visible = _departmentScope(table, principal);
    final batch = <String>{};
    final replaced = <T>{};
    final out = <(T fresh, T? old, Map<String, dynamic> json)>[];
    for (final json in request.rows) {
      final key = json[w.key];
      if (key is! String || key.trim().isEmpty) throw _notNull(table, w.key);
      if (!batch.add(key)) throw PgError.duplicate(table.name, '${w.key})=($key');
      final existing = w.find(key);
      if (existing == null) {
        if (upsert) _requireWrite(principal, table.name, LanWriteOp.insert);
        out.add((_fromJson(table, w, json), null, json));
        continue;
      }
      if (!upsert || table.shopIdOf(existing) != shopId()) {
        throw PgError.duplicate(table.name, '${w.key})=($key');
      }
      if (request.ignoreDuplicates) continue;
      _requireWrite(principal, table.name, LanWriteOp.update);
      if (visible != null && !visible(existing)) throw _hidden(table);
      replaced.add(existing);
      out.add((_merged(table, w, existing, json), existing, json));
    }
    _checkUnique(table, w, [for (final o in out) o.$1], replaced);
    for (final (fresh, old, json) in out) {
      if (old == null) {
        await w.insert!(fresh, json);
      } else {
        await w.update!(fresh, json);
      }
    }
    return [for (final o in out) o.$1];
  }

  Future<List<T>> _update<T>(
    LanTable<T> table,
    LanWrites<T> w,
    PgRequest request,
    LanPrincipal principal,
  ) async {
    final hook = w.update;
    if (hook == null) throw _notHere(table, request.op);
    _requireWrite(principal, table.name, LanWriteOp.update);
    final sent = request.body as Map<String, dynamic>;
    final patch = await w.prepareUpdate?.call(sent) ?? sent;
    final keyOf = _column(table, w.key).get;
    final visible = _departmentScope(table, principal);
    final matched = _match(table, request);
    final changes = <(T fresh, T old)>[];
    for (final old in matched) {
      if (visible != null && !visible(old)) throw _hidden(table);
      if (patch.containsKey(w.key) && patch[w.key] != keyOf(old)) {
        throw PgError(
          400,
          'PGRST100',
          'Changing ${table.name}.${w.key} is not supported',
        );
      }
      changes.add((_merged(table, w, old, patch), old));
    }
    _checkUnique(table, w, [for (final c in changes) c.$1], {
      for (final c in changes) c.$2,
    });
    for (final (fresh, _) in changes) {
      await hook(fresh, patch);
    }
    return [for (final c in changes) c.$1];
  }

  Future<List<T>> _delete<T>(
    LanTable<T> table,
    LanWrites<T> w,
    PgRequest request,
    LanPrincipal principal,
  ) async {
    final hook = w.delete;
    if (hook == null) throw _notHere(table, request.op);
    _requireWrite(principal, table.name, LanWriteOp.delete);
    final visible = _departmentScope(table, principal);
    final matched = _match(table, request);
    if (visible != null && !matched.every(visible)) throw _hidden(table);
    final keyOf = _column(table, w.key).get;
    for (final row in matched) {
      await hook(row);
      await onDeleted?.call(table.name, '${keyOf(row)}');
    }
    return matched;
  }

  /// The stored row with [patch] applied, as Postgres would store it: the
  /// columns sent replace the stored ones, the rest stay.
  T _merged<T>(
    LanTable<T> table,
    LanWrites<T> w,
    T old,
    Map<String, dynamic> patch,
  ) {
    // Through JSON, as Supabase would send it: some toJson put model
    // objects in lists (units_list) that only jsonEncode turns into maps.
    final stored =
        jsonDecode(jsonEncode(table.toJson(old))) as Map<String, dynamic>;
    final fresh = _fromJson(table, w, {...stored, ...patch});
    w.carryOver?.call(old, fresh);
    return fresh;
  }

  /// Unique columns other than the key (a NULL never collides). [replaced]
  /// rows are being overwritten by this statement.
  void _checkUnique<T>(
    LanTable<T> table,
    LanWrites<T> w,
    List<T> incoming,
    Set<T> replaced,
  ) {
    if (w.unique.isEmpty || incoming.isEmpty) return;
    final keyOf = _column(table, w.key).get;
    for (final column in w.unique) {
      final get = _column(table, column).get;
      final taken = <Object, Object?>{};
      for (final row in table.rows()) {
        if (replaced.contains(row)) continue;
        final value = get(row);
        if (value != null) taken[value] = keyOf(row);
      }
      for (final row in incoming) {
        final value = get(row);
        if (value == null) continue;
        if (taken.containsKey(value) && taken[value] != keyOf(row)) {
          throw PgError.duplicate(table.name, '$column)=($value');
        }
        taken[value] = keyOf(row);
      }
    }
  }

  T _fromJson<T>(LanTable<T> table, LanWrites<T> w, Map<String, dynamic> json) {
    try {
      return w.fromJson(json);
    } catch (e) {
      // A missing required column surfaces as a null cast, which Postgres
      // reports as a NOT NULL violation (the app drops such rows on 23502).
      final text = '$e';
      if (text.contains("'Null'")) {
        throw PgError(
          400,
          '23502',
          'null value in a required column of "${table.name}"',
          details: text,
        );
      }
      throw PgError(
        400,
        '22P02',
        'invalid input for "${table.name}"',
        details: text,
      );
    }
  }

  PgError _notNull(LanTable<dynamic> table, String column) {
    return PgError(
      400,
      '23502',
      'null value in column "$column" of relation "${table.name}" violates '
          'not-null constraint',
    );
  }

  PgError _notHere(LanTable<dynamic> table, PgOp op) {
    return PgError(
      405,
      'LAN501',
      '${op.name} on ${table.name} is not done through the LAN server',
    );
  }

  PgError _hidden(LanTable<dynamic> table) {
    return PgError(
      403,
      'LAN04',
      'This record belongs to a department you cannot access',
      details: table.name,
    );
  }

  /// The RPC's permissions ([LanAccessPolicy.rpcPermissions]).
  void _requireCall(LanPrincipal principal, String name) {
    if (LanAccessPolicy.canCall(principal, name)) return;
    onDenied?.call('rpc $name', principal);
    throw PgError(
      403,
      'LAN02',
      'You do not have permission for this change',
      details: 'rpc $name',
    );
  }

  void _requireWrite(
    LanPrincipal principal,
    String table,
    LanWriteOp op, {
    bool ownRow = false,
  }) {
    if (!LanAccessPolicy.canWrite(principal, table, op, ownRow: ownRow)) {
      throw PgError(
        403,
        'LAN02',
        'You do not have permission for this change',
        details: '${op.name} on $table',
      );
    }
  }

  static LanWriteOp _opOf(PgOp op) {
    switch (op) {
      case PgOp.update:
        return LanWriteOp.update;
      case PgOp.delete:
        return LanWriteOp.delete;
      default:
        return LanWriteOp.insert;
    }
  }

  /// The stores a write names: its rows' `shop_id` and its `shop_id`
  /// filters.
  Set<int> _writeShops(PgRequest request) {
    final shops = <int>{};
    for (final row in request.rows) {
      final value = row['shop_id'];
      final id = value is num
          ? value.toInt()
          : value is String
          ? int.tryParse(value)
          : null;
      if (id != null) shops.add(id);
    }
    shops.addAll(_requestedShops(request) ?? const <int>{});
    return shops;
  }

  Future<PgResponse> _readTyped<T>(
    LanTable<T> table,
    PgRequest request,
    LanPrincipal principal,
  ) async {
    final own = shopId();

    // 1. Shop scope. Local rows are only ever this shop's. A query that
    // names other shops goes to Supabase when the server can reach it;
    // otherwise it answers for this shop only.
    final requestedShops = table.global ? null : _requestedShops(request);
    if (requestedShops != null && requestedShops.any((s) => s != own)) {
      final forward = proxy;
      if (forward != null && _isOnline()) {
        return forward.forward(
          request,
          principal,
          requestedShops.where((s) => s != own).toSet(),
        );
      }
      if (!requestedShops.contains(own)) {
        return pgReadResponse(request, const [], total: 0);
      }
    }

    // 2. Unknown columns fail before any work.
    final orders = [
      for (final o in request.order) (o, _column(table, o.column)),
    ];
    final columns = request.columns;
    if (columns != null) {
      for (final c in columns) {
        _column(table, c);
      }
    }

    // 3–4. Candidates, filters, department scope.
    final matched = _match(
      table,
      request,
      also: _departmentScope(table, principal),
    );

    // 5. Order (stable: ties keep candidate order).
    var ordered = matched;
    if (orders.isNotEmpty) {
      final indexed = [
        for (var i = 0; i < matched.length; i++) (i, matched[i]),
      ];
      indexed.sort((a, b) {
        for (final (order, column) in orders) {
          final c = _compareForOrder(
            column.get(a.$2),
            column.get(b.$2),
            order,
          );
          if (c != 0) return c;
        }
        return a.$1.compareTo(b.$1);
      });
      ordered = [for (final e in indexed) e.$2];
    }

    // 6. Page, then JSON for the page only.
    final total = ordered.length;
    final start = (request.offset ?? 0).clamp(0, total);
    final end = request.limit == null
        ? total
        : (start + request.limit!).clamp(start, total);
    final page = <Map<String, dynamic>>[];
    if (request.op != PgOp.count) {
      for (var i = start; i < end; i++) {
        page.add(_project(table, ordered[i], columns));
      }
    }
    if (request.op == PgOp.count) {
      return pgReadResponse(request, const [], total: total);
    }
    return pgReadResponse(request, page, total: total);
  }

  /// This store's rows that pass every filter and [also]: candidates come
  /// from a binary-searched slice of a date index when the query bounds an
  /// indexed column, otherwise from every row.
  List<T> _match<T>(
    LanTable<T> table,
    PgRequest request, {
    bool Function(T row)? also,
  }) {
    final own = shopId();
    final filters = [
      for (final f in request.filters)
        if (f.column != 'shop_id' || table.global) _compile(table, f),
    ];
    final orGroups = [
      for (final group in request.orGroups)
        [for (final f in group) _compile(table, f)],
    ];
    final matched = <T>[];
    for (final row in _candidates(table, request.filters)) {
      if (!table.global && table.shopIdOf(row) != own) continue;
      if (!_all(filters, row)) continue;
      if (!orGroups.every((group) => _any(group, row))) continue;
      if (also != null && !also(row)) continue;
      matched.add(row);
    }
    return matched;
  }

  /// What [principal] may see of [table], or null when every row is
  /// visible (no department columns, or departments off for the store).
  bool Function(T row)? _departmentScope<T>(
    LanTable<T> table,
    LanPrincipal principal,
  ) {
    if (!table.hasDepartments || !manageDepartments()) return null;
    return (row) => LanAccessPolicy.canSeeDepartment(
      principal,
      manageDepartments: true,
      departmentUuid: table.departmentOf?.call(row),
      departmentUuids: table.departmentsOf?.call(row),
      includeUnassigned: table.includeUnassigned,
    );
  }

  /// The shops a query names through `shop_id` filters, or null if none.
  Set<int>? _requestedShops(PgRequest request) {
    Set<int>? shops;
    for (final f in request.filters) {
      if (f.column != 'shop_id') continue;
      final Set<int> named;
      if (f.op == PgFilterOp.eq) {
        named = {int.tryParse(f.value as String)}.whereType<int>().toSet();
      } else if (f.op == PgFilterOp.inList) {
        named = (f.value as List<String>)
            .map(int.tryParse)
            .whereType<int>()
            .toSet();
      } else {
        throw PgError(400, 'PGRST100', 'Unsupported shop_id filter: ${f.op}');
      }
      shops = shops == null ? named : shops.intersection(named);
    }
    return shops;
  }

  LanColumn<T> _column<T>(LanTable<T> table, String name) {
    final column = table.columns[name];
    if (column == null) {
      throw PgError(
        400,
        '42703',
        'column ${table.name}.$name does not exist',
      );
    }
    return column;
  }

  Iterable<T> _candidates<T>(LanTable<T> table, List<PgFilter> filters) {
    for (final column in table.dateIndexes) {
      int? lower;
      int? upper;
      var lowerInclusive = true;
      var upperInclusive = true;
      // Keep the tightest bound on each side; at the same instant an
      // exclusive bound is the tighter one.
      void tightenLower(int m, bool inclusive) {
        final l = lower;
        if (l == null || m > l || (m == l && !inclusive)) {
          lower = m;
          lowerInclusive = inclusive;
        }
      }

      void tightenUpper(int m, bool inclusive) {
        final u = upper;
        if (u == null || m < u || (m == u && !inclusive)) {
          upper = m;
          upperInclusive = inclusive;
        }
      }

      for (final f in filters) {
        if (f.column != column) continue;
        final micros = _timestamp(f.value)?.microsecondsSinceEpoch;
        if (micros == null) continue;
        switch (f.op) {
          case PgFilterOp.gte:
            tightenLower(micros, true);
          case PgFilterOp.gt:
            tightenLower(micros, false);
          case PgFilterOp.lte:
            tightenUpper(micros, true);
          case PgFilterOp.lt:
            tightenUpper(micros, false);
          case PgFilterOp.eq:
            tightenLower(micros, true);
            tightenUpper(micros, true);
          default:
            break;
        }
      }
      final l = lower;
      final u = upper;
      if (l == null && u == null) continue;
      final index = table.index(column);
      final from = l == null
          ? 0
          : _bound(index, l, inclusive: lowerInclusive, lowerBound: true);
      final to = u == null
          ? index.length
          : _bound(index, u, inclusive: upperInclusive, lowerBound: false);
      if (to <= from) return const [];
      return index.sublist(from, to).map((e) => e.row);
    }
    return table.rows();
  }

  /// For a lower bound: the first position whose value is `>=` (inclusive)
  /// or `>` (exclusive) [micros]. For an upper bound: the first position
  /// past every value `<=` (inclusive) or `<` (exclusive) it.
  int _bound<T>(
    List<LanIndexEntry<T>> index,
    int micros, {
    required bool inclusive,
    required bool lowerBound,
  }) {
    var lo = 0;
    var hi = index.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      final v = index[mid].micros;
      final goRight = lowerBound
          ? (inclusive ? v < micros : v <= micros)
          : (inclusive ? v <= micros : v < micros);
      if (goRight) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  Map<String, dynamic> _project<T>(
    LanTable<T> table,
    T row,
    List<String>? columns,
  ) {
    final json = table.toJson(row);
    if (columns == null) return json;
    return {
      for (final c in columns)
        c: json.containsKey(c) ? json[c] : _jsonValue(table.columns[c]!.get(row)),
    };
  }

  Object? _jsonValue(Object? value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    return value;
  }

  // ------------------------------------------------------------ filtering

  _Compiled<T> _compile<T>(LanTable<T> table, PgFilter filter) {
    final column = _column(table, filter.column);
    final type = column.type;
    final get = column.get;
    Object parse(String text) {
      final value = _parseValue(type, text);
      if (value == null) {
        throw PgError(
          400,
          '22P02',
          'invalid input for ${table.name}.${filter.column}: "$text"',
        );
      }
      return value;
    }

    switch (filter.op) {
      case PgFilterOp.isValue:
        final wanted = filter.value;
        return (row) => get(row) == wanted;
      case PgFilterOp.inList:
        if (type == LanColumnType.textArray) {
          throw PgError(400, 'PGRST100', 'in on an array column');
        }
        final values = [
          for (final v in filter.value as List<String>) parse(v),
        ];
        return (row) {
          final value = get(row);
          if (value == null) return false;
          return values.any((v) => _compare(type, value, v) == 0);
        };
      case PgFilterOp.contains:
        if (type != LanColumnType.textArray) {
          throw PgError(400, 'PGRST100', 'cs on a non-array column');
        }
        final wanted = filter.value as List<String>;
        return (row) {
          final value = get(row);
          return value is List && wanted.every(value.contains);
        };
      default:
        if (type == LanColumnType.textArray) {
          throw PgError(400, 'PGRST100', '${filter.op.name} on an array');
        }
        final operand = parse(filter.value as String);
        final op = filter.op;
        return (row) {
          final value = get(row);
          if (value == null) return false; // SQL: NULL never compares
          final c = _compare(type, value, operand);
          switch (op) {
            case PgFilterOp.eq:
              return c == 0;
            case PgFilterOp.neq:
              return c != 0;
            case PgFilterOp.gt:
              return c > 0;
            case PgFilterOp.gte:
              return c >= 0;
            case PgFilterOp.lt:
              return c < 0;
            case PgFilterOp.lte:
              return c <= 0;
            default:
              return false;
          }
        };
    }
  }

  bool _all<T>(List<_Compiled<T>> filters, T row) {
    for (final f in filters) {
      if (!f(row)) return false;
    }
    return true;
  }

  bool _any<T>(List<_Compiled<T>> filters, T row) {
    for (final f in filters) {
      if (f(row)) return true;
    }
    return false;
  }
}

typedef _Compiled<T> = bool Function(T row);

final RegExp _hasZone = RegExp(r'(Z|[+-]\d\d(:?\d\d)?)$');

/// Timestamps without a zone are read as UTC, as Supabase's UTC session
/// reads them for `timestamptz` columns.
DateTime? _timestamp(Object? text) {
  if (text is! String) return null;
  final normalized = text.contains(' ') && !text.contains('T')
      ? text.replaceFirst(' ', 'T')
      : text;
  return DateTime.tryParse(
    _hasZone.hasMatch(normalized) ? normalized : '${normalized}Z',
  );
}

Object? _parseValue(LanColumnType type, String text) {
  switch (type) {
    case LanColumnType.text:
      return text;
    case LanColumnType.number:
      return num.tryParse(text);
    case LanColumnType.boolean:
      return text == 'true'
          ? true
          : text == 'false'
          ? false
          : null;
    case LanColumnType.timestamp:
      return _timestamp(text);
    case LanColumnType.textArray:
      return null;
  }
}

int _compare(LanColumnType type, Object value, Object operand) {
  switch (type) {
    case LanColumnType.number:
      return (value as num).compareTo(operand as num);
    case LanColumnType.timestamp:
      return (value as DateTime).microsecondsSinceEpoch.compareTo(
        (operand as DateTime).microsecondsSinceEpoch,
      );
    case LanColumnType.boolean:
      return value == operand ? 0 : ((value as bool) ? 1 : -1);
    case LanColumnType.text:
    case LanColumnType.textArray:
      return '$value'.compareTo('$operand');
  }
}

int _compareForOrder(Object? a, Object? b, PgOrder order) {
  if (a == null || b == null) {
    if (a == null && b == null) return 0;
    // A null sorts first with nullsfirst, last with nullslast, whatever
    // the direction.
    final aFirst = a == null;
    return (aFirst == order.nullsFirst) ? -1 : 1;
  }
  int c;
  if (a is num && b is num) {
    c = a.compareTo(b);
  } else if (a is DateTime && b is DateTime) {
    c = a.microsecondsSinceEpoch.compareTo(b.microsecondsSinceEpoch);
  } else if (a is bool && b is bool) {
    c = a == b ? 0 : (a ? 1 : -1);
  } else {
    c = '$a'.compareTo('$b');
  }
  return order.ascending ? c : -c;
}
