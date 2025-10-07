import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';

class UpdatedShopFunc {
  static final UpdatedShopFunc instance =
      UpdatedShopFunc._internal();
  factory UpdatedShopFunc() => instance;
  UpdatedShopFunc._internal();

  Box<UpdatedShop>? _updatedShopBox;
  final String updatedShopBoxName =
      'updatedShopBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedShopAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedShopAdapter());
      print('Updated Shop Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedShopBoxName)) {
      _updatedShopBox = await Hive.openBox<UpdatedShop>(
        updatedShopBoxName,
      );
      print('Updated Shop Box opened ✅');
    } else {
      _updatedShopBox = Hive.box<UpdatedShop>(
        updatedShopBoxName,
      );
      print('Updated Shop Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<UpdatedShop> get updatedShopBox {
    if (_updatedShopBox == null) {
      throw Exception(
        "Updated Shop Func not initialized. Call await updated Shop Func.instance.init() first.",
      );
    }
    return _updatedShopBox!;
  }

  List<UpdatedShop> getUpdatedShop() {
    return updatedShopBox.values.toList();
  }

  Future<int> createUpdatedShop(
    UpdatedShop updatedShop,
  ) async {
    try {
      updatedShop.shop.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedShopBox.put(
        updatedShop.shop.shopId,
        updatedShop,
      );
      print('Offline updated Shop inserted successfully ✅');
      return 1;
    } catch (e) {
      print('Offline updated Shop insertion failed ❌: $e');
      return 0;
    }
  }

  // Future<int> updateUpdatedShop(
  //   UpdatedShop updatedShop,
  // ) async {
  //   try {
  //     updatedShop.shop.updatedAt = DateTime.now()
  //         .toUtc()
  //         .add(const Duration(hours: 1));
  //     await updatedShopBox.put(
  //       updatedShop.shop.shopId,
  //       updatedShop,
  //     );
  //     print('Offline updated Shop inserted successfully ✅');
  //     return 1;
  //   } catch (e) {
  //     print('Offline updated Shop insertion failed ❌: $e');
  //     return 0;
  //   }
  // }

  Future<int> deleteUpdatedShop(int shopId) async {
    try {
      print(updatedShopBox.containsKey(shopId).toString());
      await updatedShopBox.delete(shopId);
      print('Updated Shop Deleted');
      return 1;
    } catch (e) {
      print('Shop Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearUpdatedShop() async {
    try {
      await updatedShopBox.clear();
      print('All updated Shop cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Shop ❌: $e');
      return 0;
    }
  }
}
