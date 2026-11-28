import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// The delta-RPC entries the LAN server has applied, keyed by the
/// entry's key, valued by when (ms since epoch). A client that retries a
/// batch after a lost answer gets the entries it already sent skipped.
/// No adapter: a plain `Box<int>`. Kept over logout and store switch (a
/// client of the same store may still retry), and cleared when this device
/// serves another store ([forShop]). Entries older than [keepFor] are
/// pruned on start.
class LanAppliedDeltasFunc {
  static final LanAppliedDeltasFunc instance = LanAppliedDeltasFunc._internal();
  factory LanAppliedDeltasFunc() => instance;
  LanAppliedDeltasFunc._internal();

  static const Duration keepFor = Duration(days: 60);

  late Box<int> appliedDeltasBox;
  final String appliedDeltasBoxName = 'lanAppliedDeltasBoxStockall';

  Future<void> init() async {
    try {
      appliedDeltasBox = await openBoxSafely<int>(appliedDeltasBoxName);
      await prune();
      await mainLocalLog('✅ LAN Applied Deltas Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Applied Deltas Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// The store whose entries the box holds (an entry key never has this
  /// form).
  static const String shopMarker = '__shop';

  bool contains(String key) => appliedDeltasBox.containsKey(key);

  /// Before serving [shopId]: another store's entries are dropped.
  Future<void> forShop(int shopId) async {
    if (!Hive.isBoxOpen(appliedDeltasBoxName)) return;
    if (appliedDeltasBox.get(shopMarker) == shopId) return;
    await appliedDeltasBox.clear();
    await appliedDeltasBox.put(shopMarker, shopId);
  }

  Future<void> add(String key) async {
    await appliedDeltasBox.put(key, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> prune({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(keepFor)
        .millisecondsSinceEpoch;
    final old = [
      for (final key in appliedDeltasBox.keys)
        if (key != shopMarker && (appliedDeltasBox.get(key) ?? 0) < cutoff)
          key,
    ];
    await appliedDeltasBox.deleteAll(old);
  }

  Future<void> clearAppliedDeltas() async {
    await appliedDeltasBox.clear();
  }
}
