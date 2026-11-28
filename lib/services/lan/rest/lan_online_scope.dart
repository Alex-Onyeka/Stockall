import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

/// Who belongs to the store the server serves.
class LanStoreMembers {
  const LanStoreMembers({
    required this.ownerId,
    required this.members,
    this.departments = const {},
  });

  /// The store's owner (may be empty when unknown).
  final String ownerId;

  /// Every member, the owner included.
  final Set<String> members;

  /// The uuids of the store's departments.
  final Set<String> departments;
}

/// Narrows a request the LAN server forwards to Supabase to rows of the
/// store it serves. The server forwards with its own Supabase session
/// (usually the owner's), whose access can be wider than the person on
/// the till: every forwarded read or write is limited here to what that
/// person may reach in the app.
///
/// - `users` writes: an insert links only to this store (no other
///   store's `shop_id`, only this store's departments) and never makes an
///   `Owner`; an update or delete names exactly one member of this store
///   by `user_id=eq.`; the owner's row only by the owner; no upsert.
/// - `notifications`: forced to this store's `shop_id`.
/// - `subscription`, `subscription_payments`: forced to the store owner's
///   `user_id` (they have no `shop_id`).
/// - `app_version`, `utility_constants`: shared by every store; read only.
/// - RPCs: `mark_all_notifications_viewed` only for this store;
///   `get_this_month_subscription_payments` answers are filtered to the
///   owner (see [filterAnswer]).
class LanOnlineScope {
  LanOnlineScope._();

  static const Set<String> _globalReadOnly = {'app_version', 'utility_constants'};
  static const Set<String> _ownerScoped = {
    'subscription',
    'subscription_payments',
  };

  /// The request to forward, or a 403 [PgError].
  static PgRequest scope(
    PgRequest request,
    LanPrincipal principal, {
    required int shopId,
    required LanStoreMembers store,
  }) {
    final table = request.table;
    final isWrite =
        request.op == PgOp.insert ||
        request.op == PgOp.upsert ||
        request.op == PgOp.update ||
        request.op == PgOp.delete;
    if (request.op == PgOp.rpc) return _scopeRpc(request, shopId);
    if (table == 'users') {
      return isWrite
          ? _scopeUserWrite(request, principal, store, shopId)
          : request;
    }
    if (_globalReadOnly.contains(table)) {
      if (isWrite) throw _denied('$table is read only over the store network');
      return request;
    }
    if (table == 'notifications') {
      return _forceColumn(request, 'shop_id', '$shopId');
    }
    if (_ownerScoped.contains(table)) {
      if (store.ownerId.isEmpty) {
        throw _denied('The store owner is not known to the store server');
      }
      return _forceColumn(request, 'user_id', store.ownerId);
    }
    return request;
  }

  /// An answer from Supabase, limited to this store where the request
  /// couldn't be (an RPC with no store argument).
  static Object? filterAnswer(
    PgRequest request,
    Object? body,
    LanStoreMembers store,
  ) {
    if (request.op != PgOp.rpc ||
        request.table != 'get_this_month_subscription_payments' ||
        body is! List) {
      return body;
    }
    return [
      for (final row in body)
        if (row is Map && row['user_id'] == store.ownerId) row,
    ];
  }

  static PgRequest _scopeRpc(PgRequest request, int shopId) {
    if (request.table == 'mark_all_notifications_viewed') {
      final body = request.body;
      final given = body is Map ? body['p_shop_id'] : null;
      if ('$given' != '$shopId') {
        throw _denied('Notifications of another store');
      }
    }
    return request;
  }

  /// Every row an insert sends: not an owner, and tied to no other store.
  static PgRequest _scopeUserInsert(
    PgRequest request,
    int shopId,
    LanStoreMembers store,
  ) {
    final body = request.body;
    final rows = body is List ? body : [body];
    for (final row in rows) {
      if (row is! Map) throw _denied('A new user must be a row');
      final role = row['role'];
      if (role is String && role.trim().toLowerCase() == 'owner') {
        throw _denied('A store owner can\'t be added over the store network');
      }
      if (row.containsKey('shop_id') && '${row['shop_id']}' != '$shopId') {
        throw _denied('A new user can only join this store');
      }
      final departments = <Object?>[
        row['department_uuid'],
        ...?(row['department_uuids'] as List?),
      ];
      for (final d in departments) {
        if (d == null || (d is String && d.isEmpty)) continue;
        if (!store.departments.contains('$d')) {
          throw _denied('A new user can only join this store\'s departments');
        }
      }
    }
    return request;
  }

  static PgRequest _scopeUserWrite(
    PgRequest request,
    LanPrincipal principal,
    LanStoreMembers store,
    int shopId,
  ) {
    switch (request.op) {
      case PgOp.insert:
        return _scopeUserInsert(request, shopId, store);
      case PgOp.upsert:
        throw _denied('Users can\'t be upserted over the store network');
      default:
        break;
    }
    final filters = request.filters;
    if (request.orGroups.isNotEmpty ||
        filters.length != 1 ||
        filters.single.column != 'user_id' ||
        filters.single.op != PgFilterOp.eq ||
        filters.single.value is! String) {
      throw _denied('A user change must name one user by user_id');
    }
    final target = filters.single.value as String;
    if (!store.members.contains(target)) {
      throw _denied('That user is not a member of this store');
    }
    if (target == store.ownerId && principal.userId != store.ownerId) {
      throw _denied('Only the owner can change the owner\'s account');
    }
    return request;
  }

  /// Every row a write sends must carry [value] in [column] (when it names
  /// the column at all); reads, updates and deletes get the filter added.
  static PgRequest _forceColumn(
    PgRequest request,
    String column,
    String value,
  ) {
    for (final f in request.filters) {
      if (f.column == column && (f.op != PgFilterOp.eq || '${f.value}' != value)) {
        throw _denied('Rows of another store');
      }
    }
    if (request.op == PgOp.insert || request.op == PgOp.upsert) {
      for (final row in request.rows) {
        if (row[column] == null || '${row[column]}' != value) {
          throw _denied('Rows of another store');
        }
      }
      return request;
    }
    for (final row in request.rows) {
      if (row.containsKey(column) && '${row[column]}' != value) {
        throw _denied('Rows can\'t be moved to another store');
      }
    }
    return request.withEq(column, value);
  }

  static PgError _denied(String message) => PgError(403, 'LAN03', message);
}
