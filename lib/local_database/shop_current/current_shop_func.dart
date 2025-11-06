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
    // await Hive.deleteBoxFromDisk(currentShopBoxName);
    Hive.registerAdapter(TempCurrentShopAdapter());
    currentShopBox = await Hive.openBox(currentShopBoxName);
    print('Current Shop Box Initialized ✅');
  }

  TempCurrentShop? getCurrentShop() {
    TempCurrentShop? shop =
        currentShopBox.values.isNotEmpty
            ? currentShopBox.values.first
            : null;
    return shop;
  }

  Future<int> createCurrentShop(
    TempCurrentShop shop,
  ) async {
    try {
      await clearCurrentShop();
      await currentShopBox.put(
        shop.currentShop.shopId!,
        shop,
      );
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
        print('Current Shop Cleared');
      }
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }
}
