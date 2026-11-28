import 'dart:async';

import 'package:hive/hive.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';

/// How a column's values compare, so a filter's text is parsed once per
/// query instead of once per row.
enum LanColumnType { text, number, boolean, timestamp, textArray }

/// A typed accessor: reads a column straight from the Hive object, so
/// filtering and sorting never call `toJson`.
class LanColumn<T> {
  const LanColumn(this.type, this.get);

  final LanColumnType type;
  final Object? Function(T row) get;
}

/// One row of a sorted date index.
class LanIndexEntry<T> {
  const LanIndexEntry(this.micros, this.row);
  final int micros;
  final T row;
}

/// How the LAN server stores rows it pulls from Supabase: the main
/// box only, no queue (Supabase already has them).
class LanPullStore<T> {
  const LanPullStore({
    required this.put,
    required this.remove,
    required this.pending,
    this.fromJson,
    this.adopt,
  });

  /// For tables with no writes (the permissions catalogue).
  final T Function(Map<String, dynamic> json)? fromJson;

  /// Keeps what the server added to its stored row when the pulled row
  /// lacks it (the default unit and price pinned on read), so a pull
  /// never makes clients see new uuids.
  final void Function(T stored, T pulled)? adopt;

  /// Stores the row under its uuid.
  final Future<void> Function(T row) put;
  final Future<void> Function(String uuid) remove;

  /// Uuids with local work still queued (a create, an update or a delete):
  /// a pull never overwrites or removes those rows.
  final Set<String> Function() pending;
}

/// One of the app's sync queues, for [LanWrites.queues]: the box's name,
/// and whether it is empty. Hive opens each queue box with its element type
/// [E] and gives it back only under that type.
MapEntry<String, bool Function()> lanQueue<E>(String box) =>
    MapEntry(box, () => Hive.box<E>(box).isEmpty);

/// How the server writes a table: the model's `fromJson`, the main box,
/// and the app's own queues (`Created*` / `Updated*` / `Deleted*`, with
/// the same rules as the app's offline path), so the server's
/// `syncData()` pushes each change to Supabase as if its own UI had made
/// it. Side effects the client already did itself (item history, event
/// logs, customer rewards) are not repeated.
class LanWrites<T> {
  const LanWrites({
    required this.fromJson,
    required this.find,
    this.insert,
    this.update,
    this.delete,
    this.key = 'uuid',
    this.unique = const [],
    this.carryOver,
    this.onlineOps = const {},
    this.onlineColumns = const {},
    this.prepareUpdate,
    this.pull,
    this.queues = const {},
  });

  final T Function(Map<String, dynamic> json) fromJson;

  /// The app's sync queues the write hooks add to: each box's name, and
  /// whether it is empty (see [lanQueue]). The server tells its tills that
  /// what it took has reached Supabase only once every one is empty (see
  /// `lanQueues`).
  final Map<String, bool Function()> queues;

  /// How pulled rows are stored; null: the table is not pulled.
  final LanPullStore<T>? pull;

  /// The primary key column (`uuid`; `invoice_uuid` for invoices).
  final String key;

  /// Other columns Supabase keeps unique. A NULL never collides.
  final List<String> unique;

  /// The stored row with this key, if any.
  final T? Function(String key) find;

  /// [json] / [patch] are what the client sent, e.g. whether it carried
  /// `quantity`. A null hook: the op is not done on the server (405), unless
  /// it is in [onlineOps].
  final Future<void> Function(T row, Map<String, dynamic> json)? insert;
  final Future<void> Function(T row, Map<String, dynamic> patch)? update;
  final Future<void> Function(T row)? delete;

  /// Ops only Supabase can do (creating a store, changing users): sent to
  /// Supabase when the server is online, refused with `LAN01` otherwise.
  final Set<LanWriteOp> onlineOps;

  /// An update touching any of these columns is such an op too (a store's
  /// members and owner: they decide who can log in).
  final Set<String> onlineColumns;

  /// Rewrites an update's patch before it is applied (the shop's logo
  /// URL, see `LanLogoStorage`).
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> patch)?
  prepareUpdate;

  /// Whether any op is done on the server (safe to call through a
  /// `LanWrites<dynamic>`, unlike reading the hooks).
  bool get isLocal => insert != null || update != null || delete != null;

  /// Copies the fields `toJson` leaves out (`id`, …) from the stored row
  /// to its updated copy, so an update over the LAN keeps them.
  final void Function(T from, T to)? carryOver;
}

/// A table the LAN server answers from its own Hive box: the read side
/// and, with [writes], the write side.
class LanTable<T> {
  LanTable({
    required this.name,
    required Iterable<T> Function() rows,
    required this.toJson,
    required this.shopIdOf,
    required this.columns,
    this.dateIndexes = const {},
    this.departmentOf,
    this.departmentsOf,
    this.includeUnassigned = false,
    this.writes,
    this.global = false,
    Stream<Object?> Function()? changes,
    LanPullStore<T>? pull,
  }) : _rows = rows,
       _changes = changes,
       _pull = pull {
    for (final column in dateIndexes) {
      assert(
        columns[column]?.type == LanColumnType.timestamp,
        '$name.$column is indexed but not a timestamp column',
      );
    }
  }

  final String name;
  final Iterable<T> Function() _rows;

  /// The row as the client expects it (the model's full `toJson`). Only
  /// called for rows that are returned.
  final Map<String, dynamic> Function(T row) toJson;
  final int? Function(T row) shopIdOf;
  final Map<String, LanColumn<T>> columns;

  /// Timestamp columns kept as sorted indexes, for date-window reads.
  final Set<String> dateIndexes;

  /// The record's department (for `LanAccessPolicy.canSeeDepartment`).
  final String? Function(T row)? departmentOf;
  final List<String>? Function(T row)? departmentsOf;

  /// Staff in a department also see records in no department, as the app
  /// shows them with `includeUnassignedWhenDeptSelected` (products,
  /// customers).
  final bool includeUnassigned;

  /// Null: read-only over the LAN.
  final LanWrites<T>? writes;

  /// Not per store (the permissions catalogue): every row is served and
  /// [shopIdOf] is not used.
  final bool global;

  final LanPullStore<T>? _pull;

  /// How pulled rows are stored: the writes' store, or (read-only tables)
  /// the table's own.
  LanPullStore<T>? get pull => writes?.pull ?? _pull;

  final Stream<Object?> Function()? _changes;
  StreamSubscription<Object?>? _subscription;
  final Map<String, List<LanIndexEntry<T>>> _indexes = {};

  bool get hasDepartments => departmentOf != null || departmentsOf != null;

  /// Calls [body] with this table's real row type, so code holding a
  /// `LanTable<dynamic>` can use the typed accessors (calling a
  /// `(TempProductClass) => …` through `(dynamic) => …` fails at runtime).
  R withRowType<R>(R Function<X>(LanTable<X> table) body) => body<T>(this);

  Iterable<T> rows() => _rows();

  /// A new stream of the box's changes (the server's invalidate
  /// events); null when the table isn't watched.
  Stream<Object?>? watch() => _changes?.call();

  /// Drops every index; the next date-window read rebuilds it. Called on
  /// any change to the box (and directly by writes).
  void invalidate() => _indexes.clear();

  /// Rows sorted by [column] ascending; rows with no value are left out
  /// (a NULL never matches a comparison).
  List<LanIndexEntry<T>> index(String column) {
    _subscription ??= _changes?.call().listen((_) => invalidate());
    return _indexes.putIfAbsent(column, () {
      final get = columns[column]!.get;
      final entries = <LanIndexEntry<T>>[];
      for (final row in _rows()) {
        final value = get(row);
        if (value is DateTime) {
          entries.add(LanIndexEntry(value.microsecondsSinceEpoch, row));
        }
      }
      entries.sort((a, b) => a.micros.compareTo(b.micros));
      return entries;
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _indexes.clear();
  }
}
