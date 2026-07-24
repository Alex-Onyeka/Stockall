import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/main.dart';

class ShopFunc {
  static final ShopFunc instance = ShopFunc._internal();
  factory ShopFunc() => instance;
  ShopFunc._internal();
  late Box<TempShopClass> shopBox;
  final String shopBoxName = 'shopBoxStockall';

  Future<void> init() async {
    try {
      // await Hive.deleteBoxFromDisk(shopBoxName);
      Hive.registerAdapter(TempShopClassAdapter());
      shopBox = await Hive.openBox(shopBoxName);
      await UpdatedShopFunc().init();
      await mainLocalLog('Shop Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Shops Func: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<TempShopClass> getShops() {
    if (shopBox.values.isEmpty) return [];
    var user = UserFunc().getUser(
      AuthService().currentUser!,
    );
    if (user == null) {
      // await mainLocalLog('Offline User not found');
      return [];
    }

    try {
      if (user.role == 'Owner') {
        return shopBox.values
            .where(
              (shop) =>
                  shop.userId == AuthService().currentUser,
            )
            .toList();
      } else {
        return shopBox.values
            .where(
              (shop) => shop.employees!.contains(
                AuthService().currentUser,
              ),
            )
            .toList();
      }
    } catch (e) {
      // await mainLocalLog('No Shop Match ${e.toString()}');
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
        await mainLocalLog('Shop Insert Success');
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        'Shop Insert Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateShop(TempShopClass? shop) async {
    try {
      if (shop != null) {
        shop.updatedAt = DateTime.now();
        await shopBox.put(shop.shopId, shop);
        await mainLocalLog('Shop Update Success');
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        'Shop Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> setHeadQuarters(TempShopClass shop) async {
    try {
      // shop.isHeadQuarters = true;
      // shop.updatedAt = DateTime.now();
      updateShop(shop);
      for (var sho in getShops().where(
        (sh) => sh.shopId != shop.shopId,
      )) {
        sho.isHeadQuarters = false;
        sho.updatedAt = DateTime.now();
        updateShop(sho);
      }
      await mainLocalLog(
        "Setting HeadQuarters Failed Offline And Updating Other Shops Success",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Setting HeadQuarters Failed Offline: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int> clearShop() async {
    try {
      await shopBox.clear();
      await mainLocalLog('Offline Shop Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Shop Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
