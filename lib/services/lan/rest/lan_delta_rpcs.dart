import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

/// Which delta-RPC entries the server has applied.
abstract class LanAppliedDeltas {
  bool contains(String key);
  Future<void> add(String key);
}

/// Where an entry's item is, as far as the server can tell.
enum LanItemPlace {
  /// In this store's box: the change applies here.
  here,

  /// Known to belong to another store: the entry is skipped.
  otherStore,

  /// Deleted here recently, or Supabase has no such row: the entry is
  /// dropped, as Supabase ignores a delta for a deleted row.
  deleted,

  /// Not known here (not pulled yet, or gone): the batch is refused with a
  /// retryable error and the client keeps it queued.
  unknown,
}

/// What Supabase says about an item the server doesn't hold.
enum LanRemoteAnswer {
  /// Supabase has the row ([LanRemoteRow.shopId] is its store).
  found,

  /// Supabase answered and has no such row: deleted (or never created).
  missing,

  /// No answer (offline, an error, an odd reply): nothing can be concluded.
  unknown,
}

class LanRemoteRow {
  const LanRemoteRow(this.answer, {this.shopId});

  static const LanRemoteRow unknown = LanRemoteRow(LanRemoteAnswer.unknown);
  static const LanRemoteRow missing = LanRemoteRow(LanRemoteAnswer.missing);

  final LanRemoteAnswer answer;
  final int? shopId;
}

/// One entry of an `updates` array.
class LanDeltaEntry {
  const LanDeltaEntry({
    required this.hiveUuid,
    required this.itemUuid,
    required this.amount,
    required this.isIncrement,
    required this.raw,
  });

  factory LanDeltaEntry.fromJson(Map<String, dynamic> json) => LanDeltaEntry(
    hiveUuid: json['hiveUuid'] as String?,
    itemUuid: json['itemUuid'] as String,
    amount: (json['amount'] as num).toDouble(),
    isIncrement: json['isIncrement'] as bool,
    raw: Map<String, dynamic>.from(json['raw'] as Map),
  );

  Map<String, dynamic> toJson() => {
    'hiveUuid': hiveUuid,
    'itemUuid': itemUuid,
    'amount': amount,
    'isIncrement': isIncrement,
    'raw': raw,
  };

  /// The client's queue-entry uuid, when it sent one.
  final String? hiveUuid;
  final String itemUuid;

  /// Always >= 0; [isIncrement] gives the direction.
  final double amount;
  final bool isIncrement;
  final Map<String, dynamic> raw;

  double get signed => isIncrement ? amount : -amount;
}

/// One delta RPC: the shape of its entries, how the server applies an entry
/// to its own row, and how it queues the same change for its own sync to
/// Supabase (so Supabase gets it once, from the server).
class LanDeltaRpc {
  const LanDeltaRpc({
    required this.name,
    required this.itemKey,
    required this.amountKey,
    required this.locate,
    required this.next,
    required this.write,
    required this.queue,
    required this.queueUuid,
    required this.queueBox,
    required this.queueEmpty,
    this.lookup,
    this.keyIncludesAmount = false,
    this.returnsEntries = false,
  });

  final String name;

  /// The Hive box of the app's queue [queue] adds to, and whether it is
  /// empty.
  final String queueBox;
  final bool Function() queueEmpty;

  /// The entry key naming the row: `itemUuid`, `materialItemUuid`, …
  final String itemKey;

  /// `quantity`, or `amount` for customer accounts.
  final String amountKey;

  /// What Supabase says about an item this server doesn't hold. Asked
  /// before the lock is taken, so no network call waits inside it;
  /// [LanRemoteRow.unknown] without asking when the server holds the item
  /// or it was deleted here.
  final Future<LanRemoteRow> Function(String itemUuid)? lookup;

  /// Where the entry's item is, given what [lookup] answered
  /// ([LanRemoteRow.unknown] when it wasn't asked).
  final Future<LanItemPlace> Function(String itemUuid, LanRemoteRow remote)
  locate;

  /// The row's new amount after [entry], from the row as it is now (only
  /// for [LanItemPlace.here]); null when the row doesn't change.
  final double? Function(LanDeltaEntry entry) next;

  /// Sets the row's amount to [value]. Absolute, so writing it again after
  /// a crash changes nothing more.
  final Future<void> Function(LanDeltaEntry entry, double value) write;

  /// Puts the server's queue entry [uuid] for [entry] (by key, never
  /// merged, so putting it again after a crash changes nothing more).
  final Future<void> Function(LanDeltaEntry entry, String uuid) queue;

  /// The uuid of the queue entry [queue] puts for a new entry.
  final String Function(LanDeltaEntry entry) queueUuid;

  /// The client's queue merges entries for the same item, so one
  /// `hiveUuid` can carry a different amount on a retry: the amount and
  /// direction are part of the key.
  final bool keyIncludesAmount;

  /// `update_product_quantities` answers with the entries (the client
  /// reads `hiveUuid` from each); the others answer nothing.
  final bool returnsEntries;
}

/// What [LanDeltaRpcs.applyHoldingLock] did with a batch.
class LanDeltaBatch {
  const LanDeltaBatch({
    required this.done,
    required this.notHereYet,
    required this.changedItems,
  });

  /// Applied now, applied before, or dropped (another store's or deleted
  /// item): the client may forget these.
  final List<LanDeltaEntry> done;

  /// Left out: the server can't place their item yet.
  final List<LanDeltaEntry> notHereYet;

  /// Items whose row changed here.
  final Set<String> changedItems;
}

/// Where an entry being applied is written first: what it will set the
/// row to and the queue entry it will add. An entry left here was cut off
/// by a crash; [LanDeltaRpcs.recover] finishes it.
abstract class LanDeltaJournal {
  Map<String, Map<String, dynamic>> pending();
  Future<void> put(String id, Map<String, dynamic> record);
  Future<void> remove(String id);
}

/// A journal kept in memory (when none is stored).
class LanMemoryDeltaJournal implements LanDeltaJournal {
  final _records = <String, Map<String, dynamic>>{};

  @override
  Map<String, Map<String, dynamic>> pending() => Map.of(_records);

  @override
  Future<void> put(String id, Map<String, dynamic> record) async {
    _records[id] = record;
  }

  @override
  Future<void> remove(String id) async {
    _records.remove(id);
  }
}

/// The four delta RPCs, applied on the server's Hive, idempotently by the
/// entry's `hiveUuid`, one batch at a time.
class LanDeltaRpcs {
  LanDeltaRpcs({
    required List<LanDeltaRpc> rpcs,
    required this.applied,
    LanDeltaJournal? journal,
    this.onApplied,
    DateTime Function()? clock,
    @visibleForTesting this.afterStep,
  }) : _rpcs = {for (final r in rpcs) r.name: r},
       journal = journal ?? LanMemoryDeltaJournal(),
       _clock = clock ?? DateTime.now;

  final Map<String, LanDeltaRpc> _rpcs;
  final LanAppliedDeltas applied;
  final LanDeltaJournal journal;
  final DateTime Function() _clock;

  /// Called after each step of applying an entry (`journal`, `item`,
  /// `queue`, `applied`), to simulate a crash between them.
  final Future<void> Function(String step)? afterStep;

  /// Called after a batch changed something (e.g. to start the server's
  /// sync).
  final void Function()? onApplied;

  Future<void> _tail = Future.value();

  /// What [LanDeltaRpc.lookup] answered, by `rpc:item`, for a batch about
  /// to take the lock.
  final _prepared = <String, (LanRemoteRow, DateTime)>{};
  static const Duration _preparedFor = Duration(minutes: 1);

  bool handles(String name) => _rpcs.containsKey(name);

  Future<PgResponse> handle(PgRequest request) async {
    final rpc = _rpcs[request.table];
    if (rpc == null) throw PgError.unknownFunction(request.table);
    // Parse everything before changing anything.
    final entries = _parse(rpc, request.body);
    await _lookUp(rpc, entries);
    return _locked(() => _apply(rpc, entries));
  }

  /// Asks Supabase about the items of [body] (`{"updates": [...]}`) of RPC
  /// [name] that this server doesn't hold, before a caller takes the lock
  /// to apply it with [applyHoldingLock].
  Future<void> prepare(String name, Object? body) async {
    final rpc = _rpcs[name];
    if (rpc == null) throw PgError.unknownFunction(name);
    await _lookUp(rpc, _parse(rpc, body));
  }

  Future<void> _lookUp(LanDeltaRpc rpc, List<LanDeltaEntry> entries) async {
    final lookup = rpc.lookup;
    if (lookup == null) return;
    final now = _clock();
    _prepared.removeWhere((_, v) => now.difference(v.$2) > _preparedFor);
    for (final entry in entries) {
      final key = _key(rpc, entry);
      if (key != null && applied.contains(key)) continue;
      final remote = await lookup(entry.itemUuid);
      if (remote.answer == LanRemoteAnswer.unknown) continue;
      _prepared['${rpc.name}:${entry.itemUuid}'] = (remote, now);
    }
  }

  LanRemoteRow _remoteOf(LanDeltaRpc rpc, String itemUuid) {
    final hit = _prepared['${rpc.name}:$itemUuid'];
    if (hit == null || _clock().difference(hit.$2) > _preparedFor) {
      return LanRemoteRow.unknown;
    }
    return hit.$1;
  }

  /// Finishes the entries a crash cut off (see [LanDeltaJournal]): each
  /// row set to the amount it was to get, its queue entry put and the
  /// entry marked applied. Every step is safe to repeat. Run before
  /// anything else changes these rows (at start, before the app runs).
  Future<int> recover() async {
    var done = 0;
    for (final MapEntry(key: id, value: record) in journal.pending().entries) {
      final rpc = _rpcs[record['rpc']];
      if (rpc != null) {
        final entry = LanDeltaEntry.fromJson(
          Map<String, dynamic>.from(record['entry'] as Map),
        );
        final value = (record['value'] as num?)?.toDouble();
        if (value != null) await rpc.write(entry, value);
        await rpc.queue(entry, record['queue'] as String);
        if (record['key'] case final String key) await applied.add(key);
        done++;
      }
      await journal.remove(id);
    }
    return done;
  }

  /// Runs [body] on its own, between delta batches: the server's pulls
  /// from Supabase store rows (and add back queued deltas) under it, so a
  /// pull never interleaves with an apply.
  Future<R> runExclusive<R>(Future<R> Function() body) => _locked(body);

  /// Runs batches one after another, so two clients' deltas to the same
  /// item never interleave.
  Future<R> _locked<R>(Future<R> Function() body) {
    final result = _tail.then((_) => body());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// For a caller already holding the lock (a checkout): applies
  /// [body] (`{"updates": [...]}`) of RPC [name]. With [skipUnknown],
  /// entries whose item the server can't place yet are left out (not
  /// marked applied, so the client sends them again later) instead of
  /// refusing the batch.
  Future<LanDeltaBatch> applyHoldingLock(
    String name,
    Object? body, {
    bool skipUnknown = false,
  }) {
    final rpc = _rpcs[name];
    if (rpc == null) throw PgError.unknownFunction(name);
    return _applyEntries(rpc, _parse(rpc, body), skipUnknown: skipUnknown);
  }

  Future<PgResponse> _apply(LanDeltaRpc rpc, List<LanDeltaEntry> entries) async {
    await _applyEntries(rpc, entries);
    if (!rpc.returnsEntries) return const PgResponse(204);
    return PgResponse(
      200,
      body: [
        for (final e in entries)
          {'hiveUuid': e.hiveUuid, rpc.itemKey: e.itemUuid},
      ],
    );
  }

  Future<LanDeltaBatch> _applyEntries(
    LanDeltaRpc rpc,
    List<LanDeltaEntry> entries, {
    bool skipUnknown = false,
  }) async {
    // Locate every item first: if one is unknown, nothing is applied, so a
    // retry is safe even for entries without a hiveUuid.
    final pending = <(LanDeltaEntry, String?, LanItemPlace)>[];
    final unknown = <LanDeltaEntry>[];
    final done = <LanDeltaEntry>[];
    for (final entry in entries) {
      final key = _key(rpc, entry);
      if (key != null && applied.contains(key)) {
        done.add(entry);
        continue;
      }
      final place = await rpc.locate(
        entry.itemUuid,
        _remoteOf(rpc, entry.itemUuid),
      );
      if (place == LanItemPlace.unknown) {
        unknown.add(entry);
        if (skipUnknown) continue;
      }
      pending.add((entry, key, place));
    }
    if (unknown.isNotEmpty && !skipUnknown) {
      throw PgError.itemNotHereYet(rpc.name, [
        for (final e in unknown) e.itemUuid,
      ]);
    }

    var changed = false;
    final here = <String>{};
    for (final (entry, key, place) in pending) {
      if (place == LanItemPlace.here) {
        // Journaled first: a crash part way leaves what to finish.
        final uuid = rpc.queueUuid(entry);
        final value = rpc.next(entry);
        await journal.put(uuid, {
          'rpc': rpc.name,
          'key': key,
          'entry': entry.toJson(),
          'value': value,
          'queue': uuid,
        });
        await afterStep?.call('journal');
        if (value != null) await rpc.write(entry, value);
        await afterStep?.call('item');
        await rpc.queue(entry, uuid);
        await afterStep?.call('queue');
        if (key != null) await applied.add(key);
        await afterStep?.call('applied');
        await journal.remove(uuid);
        here.add(entry.itemUuid);
        changed = true;
      } else if (key != null) {
        await applied.add(key);
      }
      done.add(entry);
    }
    if (changed) onApplied?.call();
    return LanDeltaBatch(done: done, notHereYet: unknown, changedItems: here);
  }

  String? _key(LanDeltaRpc rpc, LanDeltaEntry entry) {
    final id = entry.hiveUuid;
    if (id == null) return null;
    if (!rpc.keyIncludesAmount) return '${rpc.name}:$id';
    return '${rpc.name}:$id:${entry.amount}:${entry.isIncrement}';
  }

  List<LanDeltaEntry> _parse(LanDeltaRpc rpc, Object? body) {
    final updates = body is Map<String, dynamic> ? body['updates'] : null;
    if (updates is! List) {
      throw PgError(400, '22P02', '${rpc.name} expects {"updates": [...]}');
    }
    return [
      for (final item in updates)
        () {
          if (item is! Map<String, dynamic>) {
            throw PgError(400, '22P02', '${rpc.name}: an update is not an object');
          }
          final itemUuid = item[rpc.itemKey];
          final amount = item[rpc.amountKey];
          final isIncrement = item['isIncrement'] ?? true;
          final hiveUuid = item['hiveUuid'];
          if (itemUuid is! String ||
              itemUuid.isEmpty ||
              amount is! num ||
              isIncrement is! bool ||
              (hiveUuid != null && hiveUuid is! String)) {
            throw PgError(
              400,
              '22P02',
              '${rpc.name}: bad update',
              details: '$item',
            );
          }
          return LanDeltaEntry(
            hiveUuid: hiveUuid as String?,
            itemUuid: itemUuid,
            // The app always sends the absolute amount and a direction.
            amount: amount.toDouble().abs(),
            isIncrement: amount < 0 ? !isIncrement : isIncrement,
            raw: item,
          );
        }(),
    ];
  }
}
