import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/updated/updated_storage_product.dart';

class UpdatedStorageProductsFunc {
  static final UpdatedStorageProductsFunc instance =
      UpdatedStorageProductsFunc._internal();
  factory UpdatedStorageProductsFunc() => instance;
  UpdatedStorageProductsFunc._internal();

  Box<UpdatedStorageProduct>? _updatedStorageProductBox;
  final String updatedStorageProductBoxName =
      'updatedStorageProductBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedStorageProductAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedStorageProductAdapter());
      print('Updated Storage Product Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedStorageProductBoxName)) {
      _updatedStorageProductBox =
          await Hive.openBox<UpdatedStorageProduct>(
            updatedStorageProductBoxName,
          );
      print('Updated Storage Product Box opened ✅');
    } else {
      _updatedStorageProductBox =
          Hive.box<UpdatedStorageProduct>(
            updatedStorageProductBoxName,
          );
      print(
        'Updated Storage Product Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedStorageProduct> get updatedStorageProductBox {
    if (_updatedStorageProductBox == null) {
      throw Exception(
        "Updated Storage Product Func not initialized. Call await updated Invoices Func.instance.init() first.",
      );
    }
    return _updatedStorageProductBox!;
  }

  List<UpdatedStorageProduct> getStorageProductIds() {
    return updatedStorageProductBox.values.toList();
  }

  Future<int> createUpdatedStorageProduct(
    UpdatedStorageProduct updatedStorageProduct,
  ) async {
    try {
      updatedStorageProduct
          .updatedStorageProduct
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedStorageProductBox.put(
        updatedStorageProduct.updatedStorageProduct.uuid,
        updatedStorageProduct,
      );
      print(
        'Offline updated Storage Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Storage Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedStorageProduct(
    UpdatedStorageProduct updatedStorageProduct,
  ) async {
    try {
      updatedStorageProduct
          .updatedStorageProduct
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedStorageProductBox.put(
        updatedStorageProduct.updatedStorageProduct.uuid,
        updatedStorageProduct,
      );
      print(
        'Offline updated Storage Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Storage Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedStorageProduct(
    String uuid,
  ) async {
    try {
      print(
        updatedStorageProductBox
            .containsKey(uuid)
            .toString(),
      );
      await updatedStorageProductBox.delete(uuid);
      print('Updated Storage Product Deleted');
      return 1;
    } catch (e) {
      print(
        'Storage Product Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedStorageProduct() async {
    try {
      await updatedStorageProductBox.clear();
      print('All Updated Storage Product cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Updated Storage Product ❌: $e',
      );
      return 0;
    }
  }
}
