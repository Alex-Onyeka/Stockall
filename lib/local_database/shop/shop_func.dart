import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/services/auth_service.dart';

class ShopFunc {
  static final ShopFunc instance = ShopFunc._internal();
  factory ShopFunc() => instance;
  ShopFunc._internal();
  late Box<TempShopClass> shopBox;
  final String shopBoxName = 'shopBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempShopClassAdapter());
    shopBox = await Hive.openBox(shopBoxName);
    await UpdatedShopFunc().init();
    print('Shop Box Initialized');
  }

  List<TempShopClass> getShops() {
    if (shopBox.values.isEmpty) return [];

    try {
      return shopBox.values
          .where(
            (shop) => shop.employees!.contains(
              AuthService().currentUser,
            ),
          )
          .toList();
    } catch (e) {
      print('No Shop Match ${e.toString()}');
      return [];
    }
  }

  Future<int> insertShops(List<TempShopClass> shops) async {
    await clearShop();
    try {
      if (shops.isNotEmpty) {
        for (final shop in shops) {
          await shopBox.put(shop.shopId, shop);
        }
        print('Shop Insert Success');
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      print('Shop Insert Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> updateShop(TempShopClass? shop) async {
    try {
      if (shop != null) {
        shop.updatedAt = DateTime.now();
        await shopBox.put(shop.shopId, shop);
        print('Shop Update Success');
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      print('Shop Update Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearShop() async {
    try {
      await shopBox.clear();
      print('Offline Shop Cleared');
      return 1;
    } catch (e) {
      print('Offline Shop Clear Failed: ${e.toString()}');
      return 0;
    }
  }
}
