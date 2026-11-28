import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Each shop's secret `lan_key` (from Supabase `shops.lan_key`, or from a
/// LAN login), keyed by shop id. It keys the `tv=2` mDNS shop tag. Shop
/// data: cleared by `clearAllShopData`.
class LanShopKeysFunc {
  static final LanShopKeysFunc instance = LanShopKeysFunc._internal();
  factory LanShopKeysFunc() => instance;
  LanShopKeysFunc._internal();

  late Box<String> shopKeysBox;
  final String shopKeysBoxName = 'lanShopKeysBoxStockall';

  Future<void> init() async {
    try {
      shopKeysBox = await openBoxSafely<String>(shopKeysBoxName);
      await mainLocalLog('✅ LAN Shop Keys Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Shop Keys Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  String? get(int shopId) {
    final key = shopKeysBox.get('$shopId');
    return key == null || key.isEmpty ? null : key;
  }

  Future<void> put(int shopId, String key) async {
    await shopKeysBox.put('$shopId', key);
  }

  Future<void> clearShopKeys() async {
    await shopKeysBox.clear();
  }
}
