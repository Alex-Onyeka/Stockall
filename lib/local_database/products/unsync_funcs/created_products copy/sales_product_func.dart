import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/sales_product/sales_products.dart';

class SalesProductFunc {
  static final SalesProductFunc instance =
      SalesProductFunc._internal();
  factory SalesProductFunc() => instance;
  SalesProductFunc._internal();

  Box<SalesProducts>? _salesProductsBox;
  final String salesProductsBoxName =
      'salesProductsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      SalesProductsAdapter().typeId,
    )) {
      Hive.registerAdapter(SalesProductsAdapter());
      print('SalesProductsAdapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(salesProductsBoxName)) {
      _salesProductsBox = await Hive.openBox<SalesProducts>(
        salesProductsBoxName,
      );
      print('Sales Products Box opened ✅');
    } else {
      _salesProductsBox = Hive.box<SalesProducts>(
        salesProductsBoxName,
      );
      print('Sales Products Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<SalesProducts> get salesProductsBox {
    if (_salesProductsBox == null) {
      throw Exception(
        "SalesProductFunc not initialized. Call await SalesProductFunc.instance.init() first.",
      );
    }
    return _salesProductsBox!;
  }

  List<SalesProducts> getProducts() {
    return salesProductsBox.values.toList();
  }

  // Future<int> insertAllProducts(
  //   List<SalesProducts> salesProducts,
  // ) async {
  //   try {
  //     for (var product in salesProducts) {
  //       await salesProductsBox.put(
  //         product.productUuid,
  //         product,
  //       );
  //     }
  //     print("Offline Sales Products inserted ✅");
  //     return 1;
  //   } catch (e) {
  //     print(
  //       'Offline Sales Products insertion failed ❌: $e',
  //     );
  //     return 0;
  //   }
  // }

  Future<int> createSalesProduct(
    SalesProducts salesProduct,
  ) async {
    try {
      var salesProducts = getProducts().where(
        (sales) =>
            sales.productUuid == salesProduct.productUuid,
      );
      if (salesProducts.isEmpty) {
        await salesProductsBox.put(
          salesProduct.productUuid,
          salesProduct,
        );
        print(
          'Offline Sales Product inserted successfully ✅',
        );
      } else {
        salesProducts.first.quantity =
            salesProducts.first.quantity +
            salesProduct.quantity;
        print(
          'Offline Sales Product Updated successfully: New Quantity ${salesProducts.first.quantity} ✅',
        );
      }

      return 1;
    } catch (e) {
      print('Offline Sales Product insertion failed ❌: $e');
      return 0;
    }
  }

  Future<int> deductSalesProductQuantity(
    SalesProducts salesProduct,
  ) async {
    try {
      var salesProducts = getProducts().where(
        (sales) =>
            sales.productUuid == salesProduct.productUuid,
      );
      if (salesProducts.isNotEmpty) {
        var product = salesProducts.first;
        if (product.quantity - salesProduct.quantity <= 0) {
          await deleteProduct(product.productUuid);
          print('Sales Product Deleted Successfully');
        } else {
          salesProducts.first.quantity =
              salesProducts.first.quantity -
              salesProduct.quantity;
          print(
            'Offline Sales Product Delecremented successfully: New Quantity ${salesProduct.quantity} ✅',
          );
        }
      }
      return 1;
    } catch (e) {
      print('Offline Sales Product insertion failed ❌: $e');
      return 0;
    }
  }

  // Future<int> updateProduct(
  //   SalesProducts salesProduct,
  // ) async {
  //   try {
  //     print(
  //       salesProductsBox
  //           .containsKey(salesProduct.productUuid)
  //           .toString(),
  //     );
  //     await salesProductsBox.put(
  //       salesProduct.productUuid,
  //       salesProduct,
  //     );
  //     print('Sales Product Deleted');
  //     return 1;
  //   } catch (e) {
  //     print('Sales Product Delete Failed: ${e.toString()}');
  //     return 0;
  //   }
  // }

  Future<int> deleteProduct(String uuid) async {
    try {
      print(salesProductsBox.containsKey(uuid).toString());
      await salesProductsBox.delete(uuid);
      print('Product Updated');
      return 1;
    } catch (e) {
      print('Product Update Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearProducts() async {
    try {
      await salesProductsBox.clear();
      print('All Sales Products cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Sales Products ❌: $e');
      return 0;
    }
  }
}
