import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop_owner/shop_owner.dart';
import 'package:stockall/main.dart';

class ShopOwnerFunc {
  static final ShopOwnerFunc instance =
      ShopOwnerFunc._internal();
  factory ShopOwnerFunc() => instance;
  ShopOwnerFunc._internal();
  late Box<ShopOwner> shopOwnerBox;
  final String shopOwnerBoxName = 'shopOwnerBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(shopOwnerBoxName);
    try {
      Hive.registerAdapter(ShopOwnerAdapter());
      shopOwnerBox = await Hive.openBox(shopOwnerBoxName);
      await mainLocalLog('Shop Owner Box Initialized');
    } catch (e) {
      await mainLocalLog(
        '❌ Error New Shop Owner: ${e.toString()}',
      );
      // try {
      //   if (Hive.isBoxOpen(shopOwnerBoxName)) {
      //     await Hive.box(shopOwnerBoxName).close();
      //   }

      //   await Hive.deleteBoxFromDisk(shopOwnerBoxName);
      //   await mainLocalLog(
      //     '🧹 Deleted Corrupted Current Logged In User Box',
      //   );

      //   shopOwnerBox = await Hive.openBox(
      //     shopOwnerBoxName,
      //   );
      //   await mainLocalLog('✅ Reinitialized Logged In User Box');
      // } catch (innerError) {
      //   await mainLocalLog(
      //     '⚠️ Failed to recover Hive box Logged In User: $innerError',
      //   );
      // }
    }
  }

  ShopOwner? getShopOwnerUser() {
    return shopOwnerBox.values.isNotEmpty
        ? shopOwnerBox.values.first
        : null;
  }

  Future<int> insertShopOwner(ShopOwner user) async {
    await clearShopOwner();
    try {
      await shopOwnerBox.put(user.shopOwner!.userId, user);
      await mainLocalLog('Shop Owner inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Shop Owner Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearShopOwner() async {
    try {
      await shopOwnerBox.clear();
      await mainLocalLog('Shop Owner Cleared Successfully');
      return 1;
    } catch (e) {
      await mainLocalLog('Error Clearing Shop Owner');
      return 0;
    }
  }
}
