import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class CurrentShopFunc {
  static final CurrentShopFunc instance =
      CurrentShopFunc._internal();
  factory CurrentShopFunc() => instance;
  CurrentShopFunc._internal();
  late Box<TempCurrentShop> currentShopBox;
  final String currentShopBoxName =
      'currentShopBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      TempCurrentShopAdapter().typeId,
    )) {
      Hive.registerAdapter(TempCurrentShopAdapter());
    }
    currentShopBox = await openBoxSafely<TempCurrentShop>(
      currentShopBoxName,
    );
    await mainLocalLog('✅ Current Shop Box Initialized');
  }

  TempCurrentShop? getCurrentShop() {
    TempCurrentShop? shopId =
        currentShopBox.values.isNotEmpty
            ? currentShopBox.values.first
            : null;
    return shopId;
  }

  Future<int> createCurrentShop(
    TempCurrentShop shop,
  ) async {
    try {
      await clearCurrentShop();
      await currentShopBox.put(shop.currentShopId, shop);
      await mainLocalLog(
        'Offline CurrentShop inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Current Shop Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCurrentShop() async {
    try {
      if (currentShopBox.values.isNotEmpty) {
        await currentShopBox.clear();
        await mainLocalLog('Offline Current Shop Cleared');
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Current Shop Error: ${e.toString()}',
      );
      return 0;
    }
  }
}
