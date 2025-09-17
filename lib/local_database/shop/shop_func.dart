import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';

class ShopFunc {
  static final ShopFunc instance = ShopFunc._internal();
  factory ShopFunc() => instance;
  ShopFunc._internal();
  late Box<TempShopClass> shopBox;
  final String shopBoxName = 'shopBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempShopClassAdapter());
    shopBox = await Hive.openBox(shopBoxName);
    print('Shop Box Initialized');
  }

  TempShopClass? getShop() {
    return shopBox.values.isNotEmpty
        ? shopBox.values.first
        : null;
  }

  Future<int> insertShop(TempShopClass shop) async {
    try {
      await shopBox.put(shop.shopId, shop);
      print('Shop Insert Success');
      return 1;
    } catch (e) {
      print('Shop Insert Failed: ${e.toString()}');
      return 0;
    }
  }
}
