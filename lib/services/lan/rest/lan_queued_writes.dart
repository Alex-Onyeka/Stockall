import 'package:hive/hive.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';

/// Write hooks for a table whose app code follows the usual offline path,
/// written against the boxes by name (some Funcs keep theirs private):
/// - insert: main box, then the created queue;
/// - update: main box; a record still in the created queue has that entry
///   refreshed, otherwise it goes to the updated queue;
/// - delete: main box; a record still in the created queue just leaves it,
///   otherwise it goes to the deleted queue; any updated entry is dropped.
///
/// Queue entries are keyed by the record's uuid, as the Funcs key them (a
/// few Funcs `add()` their updated or deleted entries; their syncs read the
/// values, so a uuid key works with them too and lets a later write
/// replace the entry instead of piling up).
///
/// Without [updated], updates are not done locally (405); without
/// [deleted], deletes aren't.
///
/// [createdUuid], [updatedUuid] and [deletedUuid] read the record's uuid
/// from a queue entry, so a pull can tell which rows have local work
/// queued: several Funcs key their entries with `add()`, so the
/// keys alone can't be trusted. Without one, that queue's keys are used.
LanWrites<T> queuedWrites<T, C, U, D>({
  required T Function(Map<String, dynamic> json) fromJson,
  required String main,
  required String? Function(T row) uuidOf,
  required String created,
  required C Function(T row, Map<String, dynamic> json, C? pending) toCreated,
  String? updated,
  U Function(T row, Map<String, dynamic> patch, U? pending)? toUpdated,
  String? deleted,
  D Function(T row)? toDeleted,
  String key = 'uuid',
  List<String> unique = const [],
  void Function(T from, T to)? carryOver,
  Set<LanWriteOp> onlineOps = const {},
  Set<String> onlineColumns = const {},
  String? Function(C entry)? createdUuid,
  String? Function(U entry)? updatedUuid,
  String? Function(D entry)? deletedUuid,
  void Function(T stored, T pulled)? pullAdopt,
}) {
  Box<T> mainBox() => Hive.box<T>(main);
  Box<C> createdBox() => Hive.box<C>(created);
  String uuid(T row) => uuidOf(row)!;

  Set<String> uuidsIn<E>(Box<E> box, String? Function(E entry)? read) {
    if (read == null) return box.keys.whereType<String>().toSet();
    return {
      for (final entry in box.values)
        if (read(entry) case final id?) id,
    };
  }

  return LanWrites<T>(
    fromJson: fromJson,
    key: key,
    unique: unique,
    carryOver: carryOver,
    onlineOps: onlineOps,
    onlineColumns: onlineColumns,
    queues: {
      created: () => createdBox().isEmpty,
      if (updated != null) updated: () => Hive.box<U>(updated).isEmpty,
      if (deleted != null) deleted: () => Hive.box<D>(deleted).isEmpty,
    },
    find: (k) => mainBox().get(k),
    pull: LanPullStore<T>(
      put: (row) => mainBox().put(uuid(row), row),
      remove: (id) => mainBox().delete(id),
      adopt: pullAdopt,
      pending: () => {
        ...uuidsIn(createdBox(), createdUuid),
        if (updated != null) ...uuidsIn(Hive.box<U>(updated), updatedUuid),
        if (deleted != null) ...uuidsIn(Hive.box<D>(deleted), deletedUuid),
      },
    ),
    insert: (row, json) async {
      await mainBox().put(uuid(row), row);
      await createdBox().put(uuid(row), toCreated(row, json, null));
    },
    update: updated == null || toUpdated == null
        ? null
        : (row, patch) async {
            final id = uuid(row);
            await mainBox().put(id, row);
            final pendingCreate = createdBox().get(id);
            if (pendingCreate != null) {
              await createdBox().put(id, toCreated(row, patch, pendingCreate));
            } else {
              final box = Hive.box<U>(updated);
              await box.put(id, toUpdated(row, patch, box.get(id)));
            }
          },
    delete: deleted == null || toDeleted == null
        ? null
        : (row) async {
            final id = uuid(row);
            await mainBox().delete(id);
            if (createdBox().containsKey(id)) {
              await createdBox().delete(id);
            } else {
              await Hive.box<D>(deleted).put(id, toDeleted(row));
            }
            if (updated != null) await Hive.box<U>(updated).delete(id);
          },
  );
}

/// Histories and logs: the app only ever inserts them.
LanWrites<T> appendOnlyWrites<T, C>({
  required T Function(Map<String, dynamic> json) fromJson,
  required String main,
  required String? Function(T row) uuidOf,
  required String created,
  required C Function(T row) toCreated,
  String? Function(C entry)? createdUuid,
}) {
  return queuedWrites<T, C, Object, Object>(
    fromJson: fromJson,
    main: main,
    uuidOf: uuidOf,
    created: created,
    toCreated: (row, json, pending) => toCreated(row),
    createdUuid: createdUuid,
  );
}
