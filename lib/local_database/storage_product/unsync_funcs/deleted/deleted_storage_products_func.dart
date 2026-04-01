import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/deleted_storage_products/deleted_storage_product.dart';

class DeletedStorageProductsFunc {
  static final DeletedStorageProductsFunc instance =
      DeletedStorageProductsFunc._internal();
  factory DeletedStorageProductsFunc() => instance;
  DeletedStorageProductsFunc._internal();

  Box<DeletedStorageProduct>? _deletedStorageProductBox;
  final String deletedStorageProductBoxName =
      'deletedStorageProductBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedStorageProductAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedStorageProductAdapter());
      print(
        'Deleted Storage Products Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedStorageProductBoxName)) {
      _deletedStorageProductBox =
          await Hive.openBox<DeletedStorageProduct>(
            deletedStorageProductBoxName,
          );
      print('Deleted Storage Products Box opened ✅');
    } else {
      _deletedStorageProductBox =
          Hive.box<DeletedStorageProduct>(
            deletedStorageProductBoxName,
          );
      print(
        'Deleted Storage Products Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedStorageProduct> get deletedStorageProductBox {
    if (_deletedStorageProductBox == null) {
      throw Exception(
        "Deleted Storage Products Func not initialized. Call await Deleted Invoices Func.instance.init() first.",
      );
    }
    return _deletedStorageProductBox!;
  }

  List<DeletedStorageProduct> getStorageProductIds() {
    return deletedStorageProductBox.values.toList();
  }

  Future<int> insertAllDeletedStorageProduct(
    List<DeletedStorageProduct> deletedStorageProduct,
  ) async {
    try {
      for (var invoice in deletedStorageProduct) {
        await deletedStorageProductBox.add(invoice);
      }
      print("Offline Deleted Storage Products inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Storage Products insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedStorageProduct(
    DeletedStorageProduct deletedStorageProduct,
  ) async {
    try {
      await deletedStorageProductBox.add(
        deletedStorageProduct,
      );
      print(
        'Offline Deleted Storage Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Storage Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedStorageProduct(
    String uuid,
  ) async {
    try {
      await deletedStorageProductBox.delete(uuid);
      print('Delete Storage Product cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while Deleting Deleted Storage Product ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedStorageProduct() async {
    try {
      await deletedStorageProductBox.clear();
      print('All Deleted Storage Products cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Deleted Storage Products ❌: $e',
      );
      return 0;
    }
  }
}
