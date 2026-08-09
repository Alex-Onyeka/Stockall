import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class ProductionsCartFunc {
  static final ProductionsCartFunc instance =
      ProductionsCartFunc._internal();
  factory ProductionsCartFunc() => instance;
  ProductionsCartFunc._internal();
  late Box<ProductionsCart> productionsCartBox;
  final String productionsCartBoxName =
      'productionsCartBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(ProductionsCartAdapter());
    Hive.registerAdapter(ProductionsCartItemAdapter());
    Hive.registerAdapter(
      ProductionMaterialCartItemAdapter(),
    );
    productionsCartBox = await Hive.openBox(
      productionsCartBoxName,
    );
    await initProductionCart();
    await mainLocalLog(
      'Main Productions Cart Box Initialized',
    );
  }

  ProductionsCart? getProductionsCart() {
    List<ProductionsCart> productionsCarts =
        productionsCartBox.values.toList();
    return productionsCarts.isEmpty
        ? null
        : productionsCarts.first;
  }

  Future<void> initProductionCart() async {
    if (getProductionsCart() == null) {
      await updateProductionsCart();
    }
  }

  Future<int> createProductionsCart(
    ProductionsCart productionsCart,
  ) async {
    try {
      await productionsCartBox.put(
        productionsCart.uuid,
        productionsCart,
      );
      await mainLocalLog(
        'Offline Productions Cart Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Productions Cart Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateProductionsCart({
    ProductionsCart? productionsCart,
  }) async {
    try {
      ProductionsCart newItem =
          productionsCart ?? newProductionsCart;
      await productionsCartBox.put(newItem.uuid, newItem);
      await mainLocalLog(
        'Offline Productions Cart ${productionsCart == null ? "Resetted" : 'Updated'}',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Productions Cart ${productionsCart == null ? "Reseting" : 'Update'} Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  ProductionsCart newProductionsCart = ProductionsCart(
    productionsCartItem: null,
    staffName: currentUser().name,
    staffId: currentUser().userId,
    departmentName: currentDepartment()?.name,
    departmentUuid: currentDepartment()?.uuid,
    customDate: null,
    timeOfDay: null,
    comment: null,
    materialsCartItems: [],
    createdDate: DateTime.now(),
    uuid: uuidGen(),
    customPrice: null,
    productionUuidEdit: null,
  );

  Future<int> clearProductionsCart() async {
    try {
      await productionsCartBox.clear();
      await mainLocalLog(
        'Offline Productions Cart Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Productions Cart Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
