import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Items deleted on this device, per table, kept for [keepFor]: keyed
/// `table:uuid`, valued by when (ms since epoch). The LAN server drops a
/// delta whose item is in here instead of refusing it as "not held yet"
/// (Supabase ignores a delta for a deleted row the same way).
///
/// No adapter: a plain `Box<int>`. Shop data: cleared by
/// `clearAllShopData`. Old entries are pruned on start.
class LanDeletedItemsFunc {
  static final LanDeletedItemsFunc instance = LanDeletedItemsFunc._internal();
  factory LanDeletedItemsFunc() => instance;
  LanDeletedItemsFunc._internal();

  static const Duration keepFor = Duration(days: 30);

  late Box<int> deletedItemsBox;
  final String deletedItemsBoxName = 'lanDeletedItemsBoxStockall';

  Future<void> init() async {
    try {
      deletedItemsBox = await openBoxSafely<int>(deletedItemsBoxName);
      await prune();
      await mainLocalLog('✅ LAN Deleted Items Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Deleted Items Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  static String _key(String table, String uuid) => '$table:$uuid';

  bool _open() => Hive.isBoxOpen(deletedItemsBoxName);

  /// Whether [uuid] of [table] was deleted here in the last [keepFor].
  bool contains(String table, String uuid, {DateTime? now}) {
    if (!_open()) return false;
    final at = deletedItemsBox.get(_key(table, uuid));
    if (at == null) return false;
    final cutoff = (now ?? DateTime.now()).subtract(keepFor);
    return at >= cutoff.millisecondsSinceEpoch;
  }

  /// Never throws: a delete must not fail because of this record.
  Future<void> add(String table, String uuid, {DateTime? now}) async {
    if (!_open()) return;
    try {
      await deletedItemsBox.put(
        _key(table, uuid),
        (now ?? DateTime.now()).millisecondsSinceEpoch,
      );
    } catch (e) {
      await mainLocalLog('LAN deleted items: could not record $table: $e');
    }
  }

  Future<void> prune({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(keepFor)
        .millisecondsSinceEpoch;
    final old = [
      for (final key in deletedItemsBox.keys)
        if ((deletedItemsBox.get(key) ?? 0) < cutoff) key,
    ];
    await deletedItemsBox.deleteAll(old);
  }

  Future<void> clearDeletedItems() async {
    await deletedItemsBox.clear();
  }
}
