import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';

class CartFunc {
  static final CartFunc instance = CartFunc._internal();
  factory CartFunc() => instance;
  CartFunc._internal();
  late Box<TempMainCart> cartBox;
  final String cartBoxName = 'cartBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempMainCartAdapter());
    Hive.registerAdapter(TempCartAdapter());
    Hive.registerAdapter(TempCartItemAdapter());
    cartBox = await Hive.openBox(cartBoxName);
    print('MainCart Box Initialized');
  }

  List<TempMainCart> getMainCart() {
    List<TempMainCart> carts = cartBox.values.toList();
    return carts;
  }

  // Future<int> insertAllMainCart(
  //   List<TempMainCart> mainCart,
  // ) async {
  //   await clearMainCart();
  //   try {

  //         await cartBox.put(mainCart., mainCart);
  //       print('Offline MainCarts Insert Success');
  //       return 1;
  //   } catch (e) {
  //     print(
  //       'Offline MainCarts Insert Failed: ${e.toString()}',
  //     );
  //     return 0;
  //   }
  // }

  Future<int> createMainCart(TempMainCart mainCart) async {
    try {
      await cartBox.put(mainCart.mainCartId, mainCart);
      print('Offline MainCart Created');
      return 1;
    } catch (e) {
      print(
        'Offline MainCart Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateMainCart(TempMainCart mainCart) async {
    try {
      await cartBox.put(mainCart.mainCartId, mainCart);
      print('Offline MainCart Updated');
      return 1;
    } catch (e) {
      print(
        'Offline MainCart Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteMainCart(String uuid) async {
    try {
      await cartBox.delete(uuid);
      print('Offline MainCart Deleted');
      return 1;
    } catch (e) {
      print(
        'Offline MainCart Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMainCart() async {
    try {
      await cartBox.clear();
      print('Offline MainCart Cleared');
      return 1;
    } catch (e) {
      print('MainCart Clear Failed: ${e.toString()}');
      return 0;
    }
  }
}
