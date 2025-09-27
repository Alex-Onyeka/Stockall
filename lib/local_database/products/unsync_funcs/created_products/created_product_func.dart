import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';

class CreatedProductFunc {
  static final CreatedProductFunc instance =
      CreatedProductFunc._internal();
  factory CreatedProductFunc() => instance;
  CreatedProductFunc._internal();

  Box<CreatedProducts>? _createdProductsBox;
  final String createdProductsBoxName =
      'createdProductsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedProductsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedProductsAdapter());
      print('CreatedProductsAdapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdProductsBoxName)) {
      _createdProductsBox =
          await Hive.openBox<CreatedProducts>(
            createdProductsBoxName,
          );
      print('Created Products Box opened ✅');
    } else {
      _createdProductsBox = Hive.box<CreatedProducts>(
        createdProductsBoxName,
      );
      print('Created Products Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<CreatedProducts> get createdProductsBox {
    if (_createdProductsBox == null) {
      throw Exception(
        "CreatedProductFunc not initialized. Call await CreatedProductFunc.instance.init() first.",
      );
    }
    return _createdProductsBox!;
  }

  List<CreatedProducts> getProducts() {
    return createdProductsBox.values.toList();
  }

  Future<int> insertAllProducts(
    List<CreatedProducts> createdProducts,
  ) async {
    try {
      for (var product in createdProducts) {
        await createdProductsBox.put(
          product.product.uuid,
          product,
        );
      }
      print("Offline Created Products inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Products insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createProduct(
    CreatedProducts createdProduct,
  ) async {
    try {
      await createdProductsBox.put(
        createdProduct.product.uuid,
        createdProduct,
      );
      print(
        'Offline Created Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateProduct(
    CreatedProducts createdProduct,
  ) async {
    try {
      print(
        createdProductsBox
            .containsKey(createdProduct.product.uuid)
            .toString(),
      );
      await createdProductsBox.put(
        createdProduct.product.uuid,
        createdProduct,
      );
      print('Product Deleted');
      return 1;
    } catch (e) {
      print('Product Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteProduct(String uuid) async {
    try {
      print(
        createdProductsBox.containsKey(uuid).toString(),
      );
      await createdProductsBox.delete(uuid);
      print('Product Deleted');
      return 1;
    } catch (e) {
      print('Product Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearProducts() async {
    try {
      await createdProductsBox.clear();
      print('All Created Products cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Products ❌: $e');
      return 0;
    }
  }
}
