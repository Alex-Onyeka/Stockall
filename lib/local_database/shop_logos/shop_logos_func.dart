import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop_logos/temp_shop_logos.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/main.dart';

class ShopLogosFunc {
  static final ShopLogosFunc instance =
      ShopLogosFunc._internal();
  factory ShopLogosFunc() => instance;
  ShopLogosFunc._internal();
  late Box<TempShopLogos> shopLogosBox;
  final String shopLogosBoxName = 'shopLogosBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(shopLogosBoxName);
    Hive.registerAdapter(TempShopLogosAdapter());
    shopLogosBox = await Hive.openBox(shopLogosBoxName);
    await CreatedShopLogosFunc().init();
    print('Shop Logos Box Initialized ✅');
  }

  TempShopLogos? getLogo() {
    TempShopLogos? logo =
        shopLogosBox.values.isNotEmpty
            ? shopLogosBox.values.first
            : null;
    return logo;
  }

  Future<int> createLogo(
    TempShopLogos logo,
    BuildContext context,
  ) async {
    try {
      await clearLogos();
      await shopLogosBox.put(
        returnShopProvider().userShop()!.shopId!,
        logo,
      );
      print('Offline Logo inserted Successfully');

      return 1;
    } catch (e) {
      print(
        'Offline Logo Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearLogos() async {
    try {
      if (shopLogosBox.values.isNotEmpty) {
        await shopLogosBox.clear();
        print('Logos Cleared');
      }
      return 1;
    } catch (e) {
      print('❌❌ Logo Clear Error: ${e.toString()}');
      return 0;
    }
  }
}
