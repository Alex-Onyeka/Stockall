import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';

class DeletedProductsFunc {
  static final DeletedProductsFunc instance =
      DeletedProductsFunc._internal();
  factory DeletedProductsFunc() => instance;
  DeletedProductsFunc._internal();

  Box<DeletedProducts>? _deletedProductsBox;
  final String deletedProductsBoxName =
      'deletedProductsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedProductsAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedProductsAdapter());
      print('deletedProductsAdapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedProductsBoxName)) {
      _deletedProductsBox =
          await Hive.openBox<DeletedProducts>(
            deletedProductsBoxName,
          );
      print('Deleted Products Box opened ✅');
    } else {
      _deletedProductsBox = Hive.box<DeletedProducts>(
        deletedProductsBoxName,
      );
      print('Deleted Products Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<DeletedProducts> get deletedProductsBox {
    if (_deletedProductsBox == null) {
      throw Exception(
        "Deleted Products Func not initialized. Call await Deleted Products Func.instance.init() first.",
      );
    }
    return _deletedProductsBox!;
  }

  List<DeletedProducts> getProductIds() {
    return deletedProductsBox.values.toList();
  }

  Future<int> insertAllDeletedProducts(
    List<DeletedProducts> deletedProducts,
  ) async {
    try {
      for (var product in deletedProducts) {
        await deletedProductsBox.add(product);
      }
      print("Offline Deleted Products inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Products insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedProduct(
    DeletedProducts deletedProduct,
  ) async {
    try {
      await deletedProductsBox.add(deletedProduct);
      print(
        'Offline Deleted Product inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Product insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedProducts() async {
    try {
      await deletedProductsBox.clear();
      print('All Deleted Products cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Products ❌: $e');
      return 0;
    }
  }
}
