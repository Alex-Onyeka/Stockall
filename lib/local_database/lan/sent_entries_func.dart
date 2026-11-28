import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Queue entries that have been sent (to the LAN server or Supabase) and
/// not yet acknowledged and removed, keyed `queueBox:uuid`, valued by when
/// (ms since epoch). A queue that merges new changes into an existing entry
/// must not merge into one of these: the receiver may already have applied
/// it (a lost answer), so the merged amount would be applied again, or the
/// entry is deleted on the answer and the merged change is lost.
///
/// An entry sent to a LAN server is also recorded in [sentToServerBox]
/// with that server's device id: the server may have applied it even
/// though no answer came back, so it is sent again only to that server
/// (which skips what it already applied), never to Supabase or another
/// server.
///
/// No adapters: plain boxes. Shop data: cleared by `clearAllShopData`.
class SentEntriesFunc {
  static final SentEntriesFunc instance = SentEntriesFunc._internal();
  factory SentEntriesFunc() => instance;
  SentEntriesFunc._internal();

  late Box<int> sentEntriesBox;
  late Box<String> sentToServerBox;
  final String sentEntriesBoxName = 'sentQueueEntriesBoxStockall';
  final String sentToServerBoxName = 'lanSentServerBoxStockall';

  Future<void> init() async {
    try {
      sentEntriesBox = await openBoxSafely<int>(sentEntriesBoxName);
      sentToServerBox = await openBoxSafely<String>(sentToServerBoxName);
      await mainLocalLog('✅ Sent Queue Entries Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Sent Queue Entries Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  bool _open() =>
      Hive.isBoxOpen(sentEntriesBoxName) && Hive.isBoxOpen(sentToServerBoxName);

  static String _key(String queue, String uuid) => '$queue:$uuid';

  bool isSent(String queue, Object? key) {
    return key != null &&
        _open() &&
        sentEntriesBox.containsKey(_key(queue, '$key'));
  }

  /// Before sending: from now on nothing merges into the entries under
  /// these queue keys. [toServer]: the LAN server's device id they are
  /// sent to (null: Supabase).
  Future<void> markSent(
    String queue,
    Iterable<Object?> keys, {
    String? toServer,
  }) async {
    if (!_open()) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final names = [
      for (final k in keys)
        if (k != null) _key(queue, '$k'),
    ];
    await sentEntriesBox.putAll({for (final n in names) n: now});
    if (toServer != null) {
      await sentToServerBox.putAll({for (final n in names) n: toServer});
    }
  }

  /// After the entries were acknowledged and removed from their queue.
  Future<void> unmark(String queue, Iterable<Object?> keys) async {
    if (!_open()) return;
    final names = [
      for (final k in keys)
        if (k != null) _key(queue, '$k'),
    ];
    await sentEntriesBox.deleteAll(names);
    await sentToServerBox.deleteAll(names);
  }

  /// The LAN server [key] was sent to without an answer, or null.
  String? serverOf(String queue, Object? key) {
    if (key == null || !_open()) return null;
    return sentToServerBox.get(_key(queue, '$key'));
  }

  /// When [key] of [queue] was sent, or null.
  DateTime? sentAt(String queue, Object? key) {
    if (key == null || !_open()) return null;
    final at = sentEntriesBox.get(_key(queue, '$key'));
    return at == null ? null : DateTime.fromMillisecondsSinceEpoch(at);
  }

  /// Whether any entry of [queue] is marked as sent.
  bool anySent(String queue) {
    if (!_open()) return false;
    final prefix = '$queue:';
    return sentEntriesBox.keys.any((k) => '$k'.startsWith(prefix));
  }

  /// The marked keys of [queue] (without the queue prefix).
  Set<String> sentKeys(String queue) {
    if (!_open()) return const {};
    final prefix = '$queue:';
    return {
      for (final k in sentEntriesBox.keys)
        if ('$k'.startsWith(prefix)) '$k'.substring(prefix.length),
    };
  }

  /// The entries sent to [serverDeviceId] without an answer, by queue.
  Map<String, Set<String>> heldFor(String serverDeviceId) {
    if (!_open()) return const {};
    final out = <String, Set<String>>{};
    for (final e in sentToServerBox.toMap().entries) {
      if (e.value != serverDeviceId) continue;
      final name = '${e.key}';
      final at = name.lastIndexOf(':');
      if (at <= 0) continue;
      out
          .putIfAbsent(name.substring(0, at), () => <String>{})
          .add(name.substring(at + 1));
    }
    return out;
  }

  Future<void> clearSentEntries() async {
    await sentEntriesBox.clear();
    if (Hive.isBoxOpen(sentToServerBoxName)) await sentToServerBox.clear();
  }
}
