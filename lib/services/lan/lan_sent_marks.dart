import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/services/lan/lan_transport.dart';
import 'package:stockall/services/remote/remote_client.dart';

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

  /// Before the send: the entries are marked as sent (nothing merges into
  /// them) and, when they go to a LAN server, as sent to it.
  static Future<void> markSending(
    String queue,
    Iterable<Object?> keys, {
    required String? to,
  }) => SentEntriesFunc().markSent(queue, keys, toServer: to);
}
