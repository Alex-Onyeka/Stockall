import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/sales_products/sales_products.dart';

class SalesProductsFunc {
  static final SalesProductsFunc instance =
      SalesProductsFunc._internal();
  factory SalesProductsFunc() => instance;
  SalesProductsFunc._internal();

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
      print('Sales Products Adapter registered ✅');
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
        "Sales Product Func not initialized. Call await SalesProductFunc.instance.init() first.",
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
  //       await salesProductsBox.add(product);
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

  Future<void> createSalesProduct(
    SalesProducts salesProduct,
  ) async {
    if (salesProductsBox.containsKey(
      salesProduct.productUuid,
    )) {
      final existingProduct = salesProductsBox.get(
        salesProduct.productUuid,
      );

      if (existingProduct != null) {
        existingProduct.quantity =
            (existingProduct.quantity ?? 0) +
            (salesProduct.quantity ?? 0);

        await existingProduct.save();
        print(
          "✅ Updated quantity to: ${salesProduct.quantity}, for ${salesProduct.productUuid}",
        );
      }
    } else {
      // Insert as new if it doesn’t exist
      await salesProductsBox.put(
        salesProduct.productUuid,
        salesProduct,
      );
      print(
        "🆕 Inserted new product ${salesProduct.productUuid}",
      );
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
