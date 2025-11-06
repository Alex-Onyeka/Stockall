import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop_logos/temp_shop_logos.dart';
import 'package:stockall/main.dart';

class CreatedShopLogosFunc {
  static final CreatedShopLogosFunc instance =
      CreatedShopLogosFunc._internal();
  factory CreatedShopLogosFunc() => instance;
  CreatedShopLogosFunc._internal();

  Box<TempShopLogos>? _createdShopLogosBox;
  final String createdShopLogosBoxName =
      'createdShopLogosBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(createdShopLogosBoxName);
    if (!Hive.isAdapterRegistered(
      TempShopLogosAdapter().typeId,
    )) {
      Hive.registerAdapter(TempShopLogosAdapter());
      print('Temp Shop Logos Adapter registered ✅');
    }

    if (!Hive.isBoxOpen(createdShopLogosBoxName)) {
      _createdShopLogosBox =
          await Hive.openBox<TempShopLogos>(
            createdShopLogosBoxName,
          );
      print('Created Products Box opened ✅');
    } else {
      _createdShopLogosBox = Hive.box<TempShopLogos>(
        createdShopLogosBoxName,
      );
      print(
        'Created Shop Logos Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<TempShopLogos> get createdShopLogosBox {
    if (_createdShopLogosBox == null) {
      throw Exception(
        "Created ShopLogos Func not initialized. Call await CreatedShopLogosFunc.instance.init() first.",
      );
    }
    return _createdShopLogosBox!;
  }

  TempShopLogos? getCreatedLogo() {
    TempShopLogos? logo =
        createdShopLogosBox.values.isNotEmpty
            ? createdShopLogosBox.values.first
            : null;
    return logo;
  }

  Future<int> createCreatedShopLogo(
    TempShopLogos createdLogo,
    BuildContext context,
  ) async {
    try {
      await clearCreatedLogos();
      await createdShopLogosBox.put(
        returnShopProvider(
          context,
          listen: false,
        ).userShop()!.shopId!,
        createdLogo,
      );
      print('Offline Created Logo inserted successfully ✅');
      return 1;
    } catch (e) {
      print('Offline Created Logo insertion failed ❌: $e');
      return 0;
    }
  }

  Future<int> clearCreatedLogos() async {
    try {
      await createdShopLogosBox.clear();
      print('All Created Logos cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Logos ❌: $e');
      return 0;
    }
  }
}
