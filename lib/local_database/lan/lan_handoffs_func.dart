import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// The LanHandoff box: writes the LAN server acknowledged that may not have
/// reached Supabase yet (each a JSON `LanHandoff`), in the order they were
/// sent. No adapter: a plain `Box<String>` with auto-increment keys. Shop
/// data: cleared by `clearAllShopData`, like the queues it continues.
class LanHandoffsFunc {
  static final LanHandoffsFunc instance = LanHandoffsFunc._internal();
  factory LanHandoffsFunc() => instance;
  LanHandoffsFunc._internal();

  late Box<String> handoffsBox;
  final String handoffsBoxName = 'lanHandoffsBoxStockall';

  Future<void> init() async {
    try {
      handoffsBox = await openBoxSafely<String>(handoffsBoxName);
      await mainLocalLog('✅ LAN Handoffs Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Handoffs Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  bool get isOpen => Hive.isBoxOpen(handoffsBoxName);

  /// Oldest first.
  List<MapEntry<int, String>> entries() {
    final keys = handoffsBox.keys.whereType<int>().toList()..sort();
    return [
      for (final key in keys)
        if (handoffsBox.get(key) case final value?) MapEntry(key, value),
    ];
  }

  Future<int> add(String json) => handoffsBox.add(json);

  Future<void> put(int key, String json) => handoffsBox.put(key, json);

  Future<void> deleteAll(Iterable<int> keys) => handoffsBox.deleteAll(keys);

  Future<void> clearHandoffs() async {
    await handoffsBox.clear();
  }
}
