import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';

class UpdatedProductsFunc {
  static final UpdatedProductsFunc instance =
      UpdatedProductsFunc._internal();
  factory UpdatedProductsFunc() => instance;
  UpdatedProductsFunc._internal();

  Box<UpdatedProducts>? _updatedProductsBox;
  final String updatedProductsBoxName =
      'updatedProductsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedProductsAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedProductsAdapter());
      print('Updated Products Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedProductsBoxName)) {
      _updatedProductsBox =
          await Hive.openBox<UpdatedProducts>(
            updatedProductsBoxName,
          );
      print('Updated Products Box opened ✅');
    } else {
      _updatedProductsBox = Hive.box<UpdatedProducts>(
        updatedProductsBoxName,
      );
      print('Updated Products Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<UpdatedProducts> get updatedProductsBox {
    if (_updatedProductsBox == null) {
      throw Exception(
        "Updated Products Func not initialized. Call await updated Products Func.instance.init() first.",
      );
    }
    return _updatedProductsBox!;
  }

  List<UpdatedProducts> getProducts() {
    return updatedProductsBox.values.toList();
  }

  Future<int> createUpdatedProduct(
    UpdatedProducts updatedProduct,
  ) async {
    try {
      updatedProduct.product.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedProductsBox.put(
        updatedProduct.product.uuid,
        updatedProduct,
      );
      print(
        'Offline updated Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedProduct(
    UpdatedProducts updatedProduct,
  ) async {
    try {
      updatedProduct.product.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedProductsBox.put(
        updatedProduct.product.uuid,
        updatedProduct,
      );
      print(
        'Offline updated Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedProduct(String uuid) async {
    try {
      print(
        updatedProductsBox.containsKey(uuid).toString(),
      );
      await updatedProductsBox.delete(uuid);
      print('Updated Product Deleted');
      return 1;
    } catch (e) {
      print('Product Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearupdatedProducts() async {
    try {
      await updatedProductsBox.clear();
      print('All updated Products cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Products ❌: $e');
      return 0;
    }
  }
}
