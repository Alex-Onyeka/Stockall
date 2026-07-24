import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/created_storage_products/created_storage_products.dart';
import 'package:stockall/main.dart';

class CreatedStorageProductsFunc {
  static final CreatedStorageProductsFunc instance =
      CreatedStorageProductsFunc._internal();
  factory CreatedStorageProductsFunc() => instance;
  CreatedStorageProductsFunc._internal();

  Box<CreatedStorageProducts>? _createdStorageProductsBox;
  final String createdStorageProductsBoxName =
      'createdStorageProductsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedStorageProductsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedStorageProductsAdapter());
      await mainLocalLog(
        'Created Storage Products Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdStorageProductsBoxName)) {
      _createdStorageProductsBox =
          await Hive.openBox<CreatedStorageProducts>(
            createdStorageProductsBoxName,
          );
      await mainLocalLog(
        'Created Storage Products Box opened ✅',
      );
    } else {
      _createdStorageProductsBox =
          Hive.box<CreatedStorageProducts>(
            createdStorageProductsBoxName,
          );
      await mainLocalLog(
        'Created Storage Products Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedStorageProducts>
  get createdStorageProductsBox {
    if (_createdStorageProductsBox == null) {
      throw Exception(
        "Created Storage Products Func not initialized. Call await CreatedStorageProductsFunc.instance.init() first.",
      );
    }
    return _createdStorageProductsBox!;
  }

  List<CreatedStorageProducts> getStorageProducts() {
    List<CreatedStorageProducts> storageProducts =
        createdStorageProductsBox.values.toList();
    storageProducts.sort(
      (a, b) => a.storageProduct.name
          .toLowerCase()
          .compareTo(b.storageProduct.name.toLowerCase()),
    );
    return storageProducts;
  }

  Future<int> insertAllStorageProducts(
    List<CreatedStorageProducts> createdStorageProducts,
  ) async {
    try {
      for (var storageP in createdStorageProducts) {
        await createdStorageProductsBox.put(
          storageP.storageProduct.uuid,
          storageP,
        );
      }
      await mainLocalLog(
        "Offline Created Storage Products inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Storage Products insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createStorageProduct(
    CreatedStorageProducts createdStorageProduct,
  ) async {
    try {
      await createdStorageProductsBox.put(
        createdStorageProduct.storageProduct.uuid,
        createdStorageProduct,
      );
      await mainLocalLog(
        'Offline Created Storage Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Storage Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCreatedStorageProduct(
    CreatedStorageProducts createdStorageProduct,
  ) async {
    try {
      await createdStorageProductsBox.put(
        createdStorageProduct.storageProduct.uuid,
        createdStorageProduct,
      );
      await mainLocalLog(
        'Offline Created Storage Product Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Storage Product Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteCreatedStorageProduct(
    String uuid,
  ) async {
    try {
      await mainLocalLog(
        createdStorageProductsBox
            .containsKey(uuid)
            .toString(),
      );
      await createdStorageProductsBox.delete(uuid);
      await mainLocalLog('Created Storage Product Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Storage Product Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCreatedStorageProducts() async {
    try {
      await createdStorageProductsBox.clear();
      await mainLocalLog(
        'All Created Storage Products cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Storage Products ❌: $e',
      );
      return 0;
    }
  }
}
