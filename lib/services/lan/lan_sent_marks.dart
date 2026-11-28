import 'dart:async';

import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/services/lan/lan_transport.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Where the stock and account queues may send an entry. An entry sent to
/// a LAN server without an answer may already be applied there, so it is
/// sent again only to that server (which skips what it already applied):
/// never to Supabase (off the LAN) or to another server, where it would
/// be applied a second time. It waits for its server like a delta
/// handoff, and is listed when that server is force-cleared.
class LanSentMarks {
  LanSentMarks._();

  /// The LAN server's device id when the queues go to it now; null when
  /// they go to Supabase. Replaceable in tests.
  static String? Function() target = appTarget;

  /// A LAN server whose id isn't known: entries sent to it go nowhere
  /// else.
  static const String unknownServer = '?';

  static String? appTarget() {
    if (!RemoteRouter.usingLan) return null;
    try {
      final transport = LanTransport();
      return transport.clientServerView?.serverDeviceId ?? unknownServer;
    } catch (_) {
      return unknownServer;
    }
  }

  /// Whether [key] of [queue] may be sent to [to] (a [target] value).
  static bool maySend(String queue, Object? key, {required String? to}) {
    final server = SentEntriesFunc().serverOf(queue, key);
    return server == null || server == to;
  }

  /// [entries] (by queue key) without those that must wait for a server
  /// other than [to].
  static Map<K, V> sendable<K, V>(
    String queue,
    Map<K, V> entries, {
    required String? to,
  }) {
    return {
      for (final e in entries.entries)
        if (maySend(queue, e.key, to: to)) e.key: e.value,
    };
  }

  /// Whether [error], from a send of entries to [to] (a [target] value)
  /// whose answer had HTTP [status] (null: none seen), ends their marks:
  /// - Supabase: any HTTP answer (success or error) ends the request; only
  ///   a network failure leaves them out;
  /// - a LAN server: a refusal (4xx) means they were not applied; a
  ///   server error (5xx) or no answer (timeout, network) may follow a
  ///   write, so they stay marked for it.
  /// An HTTP error answer arrives as a [PostgrestException], which doesn't
  /// carry the status (its code is the Postgres or LAN one): the LAN
  /// client notes it ([noteStatus]).
  static bool endsMarks(Object error, {required String? to, int? status}) {
    if (error is! PostgrestException) return false;
    if (to == null) return true;
    return status != null && status >= 400 && status < 500;
  }

  static final Object _answerKey = Object();

  /// Runs [run], the send of [keys] of [queue] to [to]. On a failure,
  /// their marks end when [endsMarks] says so (else they stay), and the
  /// error goes on.
  static Future<T> send<T>(
    String queue,
    Iterable<Object?> keys, {
    required String? to,
    required Future<T> Function() run,
  }) async {
    final answer = _Answer();
    try {
      // Awaited inside the zone: a PostgREST builder sends only when
      // awaited, so its request (and the status noted) is in it too.
      return await runZoned(
        () async => await run(),
        zoneValues: {_answerKey: answer},
      );
    } catch (e) {
      if (endsMarks(e, to: to, status: answer.status)) {
        await SentEntriesFunc().unmark(queue, keys);
      }
      rethrow;
    }
  }

  /// The HTTP status of an answer to a request made inside [send] (the
  /// LAN client calls it with every answer).
  static void noteStatus(int status) {
    final answer = Zone.current[_answerKey];
    if (answer is _Answer) answer.status = status;
  }

  /// Before the send: the entries are marked as sent (nothing merges into
  /// them) and, when they go to a LAN server, as sent to it.
  static Future<void> markSending(
    String queue,
    Iterable<Object?> keys, {
    required String? to,
  }) => SentEntriesFunc().markSent(queue, keys, toServer: to);
}

class _Answer {
  int? status;
}
