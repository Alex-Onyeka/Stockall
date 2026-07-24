import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/main.dart';

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
    try {
      if (!Hive.isAdapterRegistered(
        CreatedProductsAdapter().typeId,
      )) {
        Hive.registerAdapter(CreatedProductsAdapter());
        await mainLocalLog(
          'Created Products Adapter registered ✅',
        );
      }

      // Open the box only if it isn’t already open
      await _openBox();
    } catch (e, s) {
      await Hive.deleteBoxFromDisk(
        'createdProductsBoxStockall',
      );
      await mainLocalLog(
        'Error Initializing Created Products Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
      await _openBox();
    }
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(createdProductsBoxName)) {
      _createdProductsBox =
          await Hive.openBox<CreatedProducts>(
            createdProductsBoxName,
          );
      await mainLocalLog('Created Products Box opened ✅');
    } else {
      _createdProductsBox = Hive.box<CreatedProducts>(
        createdProductsBoxName,
      );
      await mainLocalLog(
        'Created Products Box already open, reused ✅',
      );
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
      await mainLocalLog(
        "Offline Created Products inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
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
      await mainLocalLog(
        'Offline Created Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateProduct(
    CreatedProducts createdProduct,
  ) async {
    try {
      await mainLocalLog(
        createdProductsBox
            .containsKey(createdProduct.product.uuid)
            .toString(),
      );
      await createdProductsBox.put(
        createdProduct.product.uuid,
        createdProduct,
      );
      await mainLocalLog(
        'Offline Created Product Updated Successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌Offline Created Product Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteProduct(String uuid) async {
    try {
      await mainLocalLog(
        createdProductsBox.containsKey(uuid).toString(),
      );
      await createdProductsBox.delete(uuid);
      await mainLocalLog('Product Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Product Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProducts() async {
    try {
      await createdProductsBox.clear();
      await mainLocalLog('All Created Products cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Products ❌: $e',
      );
      return 0;
    }
  }
}
