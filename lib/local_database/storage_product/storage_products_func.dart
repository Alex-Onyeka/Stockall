import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/created/created_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/deleted/deleted_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/updated/updated_storage_products_func.dart';
import 'package:stockall/main.dart';

class StorageProductsFunc {
  static final StorageProductsFunc instance =
      StorageProductsFunc._internal();
  factory StorageProductsFunc() => instance;
  StorageProductsFunc._internal();
  late Box<TempStorageProducts> storageProductsBox;
  final String storageProductsBoxName =
      'StorageProductsStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempStorageProductsAdapter());
    storageProductsBox = await Hive.openBox(
      storageProductsBoxName,
    );
    await CreatedStorageProductsFunc().init();
    await DeletedStorageProductsFunc().init();
    await UpdatedStorageProductsFunc().init();
    await mainLocalLog('Storage Products Box Initialized');
  }

  List<TempStorageProducts> getStorageProducts() {
    List<TempStorageProducts> storageProducts =
        storageProductsBox.values.toList();
    storageProducts.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return storageProducts;
  }

  Future<int> insertAllStorageProducts(
    List<TempStorageProducts> storageProducts,
  ) async {
    await clearStorageProducts();
    try {
      for (var rec in storageProducts) {
        await storageProductsBox.put(rec.uuid, rec);
      }
      await mainLocalLog(
        'Offline Storage Products Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Products Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createStorageProduct(
    TempStorageProducts storageProduct,
  ) async {
    try {
      await storageProductsBox.put(
        storageProduct.uuid,
        storageProduct,
      );
      await mainLocalLog(
        'Offline Storage Products Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Products Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateStorageProduct(
    TempStorageProducts storageProduct,
  ) async {
    try {
      await storageProductsBox.put(
        storageProduct.uuid,
        storageProduct,
      );
      await mainLocalLog(
        'Offline Storage Products Updated',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Products Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteStorageProduct(String uuid) async {
    try {
      await storageProductsBox.delete(uuid);
      await mainLocalLog('Offline Storage Product Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Product Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearStorageProducts() async {
    try {
      await storageProductsBox.clear();
      await mainLocalLog(
        'Offline Storage Products Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Storage Products Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedStorageProductsFunc()
            .getStorageProducts()
            .isEmpty &&
        UpdatedStorageProductsFunc()
            .getStorageProductIds()
            .isEmpty &&
        DeletedStorageProductsFunc()
            .getStorageProductIds()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
