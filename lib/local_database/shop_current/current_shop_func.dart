import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';

class CurrentShopFunc {
  static final CurrentShopFunc instance =
      CurrentShopFunc._internal();
  factory CurrentShopFunc() => instance;
  CurrentShopFunc._internal();
  late Box<TempCurrentShop> currentShopBox;
  final String currentShopBoxName =
      'currentShopBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(TempCurrentShopAdapter());

      currentShopBox = await Hive.openBox(
        currentShopBoxName,
      );
      print('✅ Current Shop Box Initialized');
    } catch (e) {
      print('❌ Error New: ${e.toString()}');
      try {
        if (Hive.isBoxOpen(currentShopBoxName)) {
          await Hive.box(currentShopBoxName).close();
        }

        await Hive.deleteBoxFromDisk(currentShopBoxName);
        print('🧹 Deleted Corrupted Current Shop Box');

        currentShopBox = await Hive.openBox(
          currentShopBoxName,
        );
        print('✅ Reinitialized Current Shop Box');
      } catch (innerError) {
        print('⚠️ Failed to recover Hive box: $innerError');
      }
    }
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
      print('Offline CurrentShop inserted Successfully');

      return 1;
    } catch (e) {
      print(
        'Offline Current Shop Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCurrentShop() async {
    try {
      if (currentShopBox.values.isNotEmpty) {
        await currentShopBox.clear();
        print('Offline Current Shop Cleared');
      }
      return 1;
    } catch (e) {
      print(
        '❌❌ Offline Current Shop Error: ${e.toString()}',
      );
      return 0;
    }
  }
}
