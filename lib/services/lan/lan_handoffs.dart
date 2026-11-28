import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handoffs. When the LAN server acknowledges a write,
/// the client's sync deletes the queue entry as it does after Supabase, but
/// the write may not have reached Supabase yet: the server sends it on its
/// own sync. So the client keeps a copy of the acknowledged request (the
/// LanHandoff box) until:
/// - the server says it has synced through it (`GET /v1/handoff/status`,
///   after a sync run and on the server's `synced` event), or
/// - the client, away from the LAN, replays it to Supabase itself, before
///   its normal queue, so nothing reaches Supabase before a record it
///   depends on.
///
/// A delta (the four quantity/account RPCs) is never replayed to Supabase:
/// its RPCs are not idempotent yet, so it waits for its server.
///
/// A refused write is one the LAN server refused for permission
/// while this device pushed the queue it kept as a server: no LAN server
/// takes it, so it goes straight to Supabase when this device is online.
///
/// A handoff to a server the shop has moved away from never
/// gets that server's confirmation: its REST writes are replayed to the
/// current server; its deltas end when that server says where the shop's
/// server is now (it delivers them itself), else they wait for it.
enum LanHandoffKind { rest, delta, refused }

class LanHandoff {
  LanHandoff({
    required this.kind,
    required this.method,
    required this.path,
    required this.query,
    required this.headers,
    required this.body,
    required this.serverDeviceId,
    required this.epoch,
    required this.serverTime,
    required this.handedAt,
    this.attempts = 0,
  });

  final LanHandoffKind kind;
  final String method;

  /// After `/rest/v1/`: `products`, `rpc/update_product_quantities`, …
  final String path;

  /// The raw query string (filters, `on_conflict`, `columns`, …).
  final String query;

  /// The PostgREST headers that change what the write does.
  final Map<String, String> headers;
  final String? body;

  /// The server that acknowledged it, and its record's epoch.
  final String serverDeviceId;
  final int epoch;

  /// The server's clock when it answered (ms since epoch); null if the
  /// answer had none (then only a replay ends it).
  final int? serverTime;
  final DateTime handedAt;

  /// Replays answered "a record it needs is missing" (23503).
  final int attempts;

  static const Set<String> _keptHeaders = {
    'content-type',
    'prefer',
    'accept',
    'content-profile',
    'accept-profile',
  };

  /// What to keep of a write the LAN server acknowledged; null for a
  /// request that needs no handoff: reads, other RPCs, and tables the
  /// server forwards to Supabase before answering (online-only, users).
  static LanHandoffKind? kindOf(String method, String restPath) {
    final m = method.toUpperCase();
    if (m != 'POST' && m != 'PATCH' && m != 'PUT' && m != 'DELETE') {
      return null;
    }
    if (restPath.startsWith('rpc/')) {
      final name = restPath.substring('rpc/'.length);
      return LanConstants.deltaRpcs.contains(name) ? LanHandoffKind.delta : null;
    }
    final table = restPath.split('/').first;
    if (table.isEmpty ||
        table == 'users' ||
        LanConstants.onlineOnlyTables.contains(table)) {
      return null;
    }
    return LanHandoffKind.rest;
  }

  static Map<String, String> keptHeaders(Map<String, String> headers) => {
    for (final e in headers.entries)
      if (_keptHeaders.contains(e.key.toLowerCase())) e.key.toLowerCase(): e.value,
  };

  bool isFrom(String deviceId, int epoch) =>
      serverDeviceId == deviceId && this.epoch == epoch;

  LanHandoff retried() => _copy(attempts: attempts + 1);

  LanHandoff _copy({String? body, int? attempts}) => LanHandoff(
    kind: kind,
    method: method,
    path: path,
    query: query,
    headers: headers,
    body: body ?? this.body,
    serverDeviceId: serverDeviceId,
    epoch: epoch,
    serverTime: serverTime,
    handedAt: handedAt,
    attempts: attempts ?? this.attempts,
  );

  /// An insert (or upsert) without its rows [wasDeleted] names: null when
  /// it names them all (nothing to send), itself when none. A row deleted
  /// since it was handed to the server must not be created again by a
  /// replay.
  LanHandoff? withoutDeleted(bool Function(String table, String uuid) wasDeleted) {
    final b = body;
    if (method != 'POST' || kind == LanHandoffKind.delta || b == null) {
      return this;
    }
    final table = path.split('/').first;
    final Object? decoded;
    try {
      decoded = jsonDecode(b);
    } catch (_) {
      return this;
    }
    bool deleted(Object? row) =>
        row is Map && row['uuid'] is String && wasDeleted(table, row['uuid']);
    if (decoded is Map) return deleted(decoded) ? null : this;
    if (decoded is! List) return this;
    final kept = [
      for (final row in decoded)
        if (!deleted(row)) row,
    ];
    if (kept.length == decoded.length) return this;
    if (kept.isEmpty) return null;
    return _copy(body: jsonEncode(kept));
  }

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'method': method,
    'path': path,
    'query': query,
    'headers': headers,
    'body': body,
    'server_device_id': serverDeviceId,
    'epoch': epoch,
    'server_time': serverTime,
    'handed_at': handedAt.toUtc().toIso8601String(),
    'attempts': attempts,
  };

  factory LanHandoff.fromJson(Map<String, dynamic> json) => LanHandoff(
    kind: LanHandoffKind.values.byName(json['kind'] as String),
    method: json['method'] as String,
    path: json['path'] as String,
    query: json['query'] as String? ?? '',
    headers: Map<String, String>.from(json['headers'] as Map? ?? const {}),
    body: json['body'] as String?,
    serverDeviceId: json['server_device_id'] as String,
    epoch: json['epoch'] as int,
    serverTime: json['server_time'] as int?,
    handedAt: DateTime.parse(json['handed_at'] as String),
    attempts: json['attempts'] as int? ?? 0,
  );
}

/// The server's answer to `GET /v1/handoff/status`.
class LanHandoffStatus {
  const LanHandoffStatus({
    required this.serverDeviceId,
    required this.epoch,
    required this.syncedThrough,
    this.handedOver = const [],
  });

  final String serverDeviceId;
  final int epoch;

  /// Former servers whose queues are all at this one.
  final List<({String device, int epoch})> handedOver;

  /// The last time (server clock, ms) the server's queues were all empty:
  /// everything it acknowledged before then has reached Supabase.
  final int? syncedThrough;

  static LanHandoffStatus? fromJson(Map<String, dynamic> json) {
    final device = json['server_device_id'];
    final epoch = json['epoch'];
    final through = json['synced_through'];
    if (device is! String || epoch is! int) return null;
    if (through != null && through is! int) return null;
    return LanHandoffStatus(
      serverDeviceId: device,
      epoch: epoch,
      syncedThrough: through as int?,
      handedOver: [
        for (final h in json['handed_over'] as List? ?? const [])
          if (h is Map && h['device'] is String && h['epoch'] is int)
            (device: h['device'] as String, epoch: h['epoch'] as int),
      ],
    );
  }
}

/// On the server: what `GET /v1/handoff/status` says. Writes are queued
/// before they are acknowledged, so when the queues are empty, everything
/// acknowledged so far has been sent to Supabase.
class LanHandoffStatusSource {
  LanHandoffStatusSource({
    required this.queuesEmpty,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool Function() queuesEmpty;
  final DateTime Function() _clock;
  int? _syncedThrough;

  int now() => _clock().millisecondsSinceEpoch;

  Map<String, dynamic> status({
    required String serverDeviceId,
    required int epoch,
  }) {
    final at = now();
    if (queuesEmpty()) _syncedThrough = at;
    return {
      'server_device_id': serverDeviceId,
      'epoch': epoch,
      'synced_through': _syncedThrough,
      'now': at,
    };
  }
}

/// Where a replay goes: a `SupabaseClient`'s REST endpoint and HTTP client
/// (which adds its key and session).
class LanHandoffTarget {
  const LanHandoffTarget({
    required this.restUrl,
    required this.headers,
    required this.client,
    this.lastWriteWins = false,
    this.quoteGuard = true,
  });

  /// Supabase itself: an update only applies where Supabase's row is older
  /// (last write wins on `updated_at`), so a replay never undoes a newer
  /// change another device made directly.
  factory LanHandoffTarget.supabase(SupabaseClient supabase) =>
      LanHandoffTarget(
        restUrl: supabase.rest.url,
        headers: supabase.rest.headers,
        client: supabase.rest.httpClient ?? http.Client(),
        lastWriteWins: true,
      );

  final String restUrl;
  final Map<String, String> headers;
  final http.Client client;
  final bool lastWriteWins;

  /// Whether the last-write-wins guard quotes its timestamp (PostgREST
  /// takes both; the LAN server's filters take it bare).
  final bool quoteGuard;

  /// The shop's current LAN server, through this device's LAN client:
  /// with the same last-write-wins guard. Its answers are recorded
  /// as new handoffs to that server.
  factory LanHandoffTarget.lan(SupabaseClient lan) => LanHandoffTarget(
    restUrl: lan.rest.url,
    headers: lan.rest.headers,
    client: lan.rest.httpClient ?? http.Client(),
    lastWriteWins: true,
    quoteGuard: false,
  );
}

class LanReplayResult {
  const LanReplayResult({
    required this.sent,
    required this.kept,
    required this.stopped,
  });

  /// Ended: reached the target, already there (23505), or refused for good.
  final int sent;

  /// Still held: deltas, and writes whose dependency is missing (23503).
  final int kept;

  /// The target could not be reached (or refused the session): the rest
  /// wait for the next run.
  final bool stopped;
}

class LanHandoffs {
  LanHandoffs({
    LanHandoffsFunc? store,
    bool Function(String table, String uuid)? wasDeleted,
  }) : _store = store ?? LanHandoffsFunc(),
       _wasDeleted = wasDeleted ?? LanDeletedItemsFunc().contains;

  final LanHandoffsFunc _store;

  /// Rows deleted on this device (its record of deleted items).
  final bool Function(String table, String uuid) _wasDeleted;

  bool get _ready => _store.isOpen;

  List<(int, LanHandoff)> all() {
    if (!_ready) return const [];
    final out = <(int, LanHandoff)>[];
    for (final e in _store.entries()) {
      try {
        out.add((
          e.key,
          LanHandoff.fromJson(jsonDecode(e.value) as Map<String, dynamic>),
        ));
      } catch (_) {
        // Unreadable: kept, never sent.
      }
    }
    return out;
  }

  /// A LAN answer to [method] [url]: keeps a handoff when it was a write
  /// the server acknowledged (2xx). Awaited before the answer is returned,
  /// so the queue entry is never deleted before its handoff exists.
  Future<void> recordAnswer({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    required List<int> body,
    required int status,
    required Map<String, String> answerHeaders,
    required String serverDeviceId,
    required int epoch,
  }) async {
    if (!_ready || status < 200 || status > 299) return;
    const prefix = '/rest/v1/';
    final path = url.path;
    if (!path.startsWith(prefix)) return;
    final restPath = path.substring(prefix.length);
    final kind = LanHandoff.kindOf(method, restPath);
    if (kind == null) return;
    final handoff = LanHandoff(
      kind: kind,
      method: method.toUpperCase(),
      path: restPath,
      query: url.query,
      headers: LanHandoff.keptHeaders(headers),
      body: body.isEmpty ? null : utf8.decode(body, allowMalformed: true),
      serverDeviceId: serverDeviceId,
      epoch: epoch,
      serverTime: int.tryParse(
        answerHeaders[LanConstants.serverTimeHeader] ?? '',
      ),
      handedAt: DateTime.now().toUtc(),
    );
    await _store.add(jsonEncode(handoff.toJson()));
  }

  /// A write the LAN server refused for permission, set aside to be sent
  /// to Supabase: the caller's queue is then told it succeeded.
  Future<bool> recordRefused({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    required List<int> body,
    required String serverDeviceId,
    required int epoch,
  }) async {
    if (!_ready) return false;
    const prefix = '/rest/v1/';
    final path = url.path;
    if (!path.startsWith(prefix)) return false;
    final restPath = path.substring(prefix.length);
    if (LanHandoff.kindOf(method, restPath) != LanHandoffKind.rest) {
      return false;
    }
    final handoff = LanHandoff(
      kind: LanHandoffKind.refused,
      method: method.toUpperCase(),
      path: restPath,
      query: url.query,
      headers: LanHandoff.keptHeaders(headers),
      body: body.isEmpty ? null : utf8.decode(body, allowMalformed: true),
      serverDeviceId: serverDeviceId,
      epoch: epoch,
      serverTime: null,
      handedAt: DateTime.now().toUtc(),
    );
    await _store.add(jsonEncode(handoff.toJson()));
    return true;
  }

  /// The writes refused for permission still held.
  List<LanHandoff> refused() => [
    for (final (_, h) in all())
      if (h.kind == LanHandoffKind.refused) h,
  ];

  /// Ends every handoff the server says reached Supabase, and the deltas
  /// of former servers it says handed over. Returns how many.
  /// Refused writes never end this way (no LAN server took them).
  Future<int> confirm(LanHandoffStatus status) async {
    if (!_ready) return 0;
    var ended = 0;
    for (final h in status.handedOver) {
      ended += await endDeltasFrom(h.device, h.epoch);
    }
    final through = status.syncedThrough;
    if (through == null) return ended;
    final done = [
      for (final (key, h) in all())
        if (h.kind != LanHandoffKind.refused &&
            h.isFrom(status.serverDeviceId, status.epoch) &&
            h.serverTime != null &&
            h.serverTime! <= through)
          key,
    ];
    await _store.deleteAll(done);
    return ended + done.length;
  }

  /// The deltas still held for [serverDeviceId] (any epoch): listed when
  /// it is force-cleared.
  List<LanHandoff> deltasFor(String serverDeviceId) => [
    for (final (_, h) in all())
      if (h.kind == LanHandoffKind.delta && h.serverDeviceId == serverDeviceId)
        h,
  ];

  /// Whether [h] was handed to a server the shop has moved away from, now
  /// that this device's server is [serverDeviceId] at [epoch]:
  /// another device at the same or an earlier epoch (a device follows only
  /// a server that outranks its record). Refused writes are not handoffs
  /// to a server.
  static bool isSuperseded(LanHandoff h, String serverDeviceId, int epoch) =>
      h.kind != LanHandoffKind.refused &&
      h.serverDeviceId != serverDeviceId &&
      h.epoch <= epoch;

  /// The server [serverDeviceId] at [epoch] said where the shop's server is
  /// now, or the new server says its queue is all there: it
  /// delivers the deltas it acknowledged itself (they are in Supabase, or
  /// in the queue it pushes to the new server), so this device's copies
  /// end. Returns how many.
  Future<int> endDeltasFrom(String serverDeviceId, int epoch) async {
    if (!_ready) return 0;
    final done = [
      for (final (key, h) in all())
        if (h.kind == LanHandoffKind.delta && h.isFrom(serverDeviceId, epoch))
          key,
    ];
    await _store.deleteAll(done);
    return done.length;
  }

  /// Sends the held writes to [target], oldest first (the order the queues
  /// sent them in, so a record goes before the ones that need it):
  /// - 2xx, or 23505 (already there): ended;
  /// - 23503 (a record it needs isn't there yet): kept, tried next time;
  /// - no answer, 401/403 or 5xx: stop, all kept;
  /// - any other refusal: ended, as the app's own sync drops it.
  /// An insert's rows deleted here since are left out; one with none left
  /// is ended unsent. Deltas are never replayed (they wait for their server). Refused
  /// writes go like the rest; [refusedOnly] sends only them (on the
  /// LAN, once everything else this device sent has reached Supabase).
  /// [only] sends just the handoffs it picks (those to a superseded
  /// server); the others count as kept.
  Future<LanReplayResult> replay(
    LanHandoffTarget target, {
    bool refusedOnly = false,
    bool Function(LanHandoff h)? only,
  }) async {
    var sent = 0;
    var kept = 0;
    for (final (key, h) in all()) {
      if (h.kind == LanHandoffKind.delta ||
          (refusedOnly && h.kind != LanHandoffKind.refused) ||
          (only != null && !only(h))) {
        kept++;
        continue;
      }
      final send = h.withoutDeleted(_wasDeleted);
      if (send == null) {
        await mainLocalLog(
          'LAN handoff dropped: ${h.method} ${h.path}: deleted here since',
        );
        await _store.deleteAll([key]);
        sent++;
        continue;
      }
      http.Response response;
      try {
        response = await _send(target, send);
      } catch (e) {
        await mainLocalLog('LAN handoff replay stopped: $e');
        return LanReplayResult(sent: sent, kept: kept, stopped: true);
      }
      final status = response.statusCode;
      final code = _code(response);
      if (status >= 200 && status <= 299 || code == '23505') {
        await _store.deleteAll([key]);
        sent++;
      } else if (code == '23503') {
        await _store.put(key, jsonEncode(h.retried().toJson()));
        kept++;
      } else if (status == 401 || status == 403 || status >= 500) {
        await mainLocalLog('LAN handoff replay stopped: HTTP $status $code');
        return LanReplayResult(sent: sent, kept: kept, stopped: true);
      } else {
        await mainLocalLog(
          'LAN handoff dropped: ${h.method} ${h.path} HTTP $status $code',
        );
        await _store.deleteAll([key]);
        sent++;
      }
    }
    return LanReplayResult(sent: sent, kept: kept, stopped: false);
  }

  /// Deltas held longer than [olderThan] (reported: they wait for their
  /// server).
  int staleDeltas({
    Duration olderThan = LanConstants.staleDeltaHandoff,
    DateTime? now,
  }) {
    final cutoff = (now ?? DateTime.now()).toUtc().subtract(olderThan);
    return all()
        .where(
          (e) =>
              e.$2.kind == LanHandoffKind.delta &&
              e.$2.handedAt.isBefore(cutoff),
        )
        .length;
  }

  Future<http.Response> _send(LanHandoffTarget target, LanHandoff h) {
    var query = h.query;
    final body = h.body;
    if (target.lastWriteWins && h.method == 'PATCH' && body != null) {
      final updatedAt = _updatedAt(body);
      if (updatedAt != null && !_hasParam(query, 'or')) {
        final at = target.quoteGuard ? '"$updatedAt"' : updatedAt;
        final guard =
            'or=${Uri.encodeQueryComponent('(updated_at.is.null,updated_at.lt.$at)')}';
        query = query.isEmpty ? guard : '$query&$guard';
      }
    }
    final url = Uri.parse(
      '${target.restUrl}/${h.path}${query.isEmpty ? '' : '?$query'}',
    );
    final request = http.Request(h.method, url)
      ..headers.addAll(target.headers)
      ..headers.addAll(h.headers);
    if (body != null) request.bodyBytes = utf8.encode(body);
    return target.client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(LanConstants.restTimeout);
  }

  static bool _hasParam(String query, String name) =>
      query.split('&').any((p) => p.split('=').first == name);

  static String? _updatedAt(String body) {
    try {
      final decoded = jsonDecode(body);
      final value = decoded is Map ? decoded['updated_at'] : null;
      return value is String && value.isNotEmpty ? value : null;
    } catch (_) {
      return null;
    }
  }

  static String? _code(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final code = decoded is Map ? decoded['code'] : null;
      return code is String ? code : null;
    } catch (_) {
      return null;
    }
  }
}
