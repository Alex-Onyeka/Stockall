import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
// import 'package:stockall/local_database/products/unsync_funcs/sales_products/sales_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/main.dart';

class ProductsFunc {
  static final ProductsFunc instance =
      ProductsFunc._internal();
  factory ProductsFunc() => instance;
  ProductsFunc._internal();
  late Box<TempProductClass> productBox;
  final String productBoxName = 'productBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(TempProductClassAdapter());
      productBox = await Hive.openBox(productBoxName);
      await CreatedProductFunc().init();
      await DeletedProductsFunc().init();
      await UpdatedProductsFunc().init();
      await QuantityUpdateFunc().init();
      await mainLocalLog('Product Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Products Func: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<TempProductClass> getProducts() {
    List<TempProductClass> products = productBox.values
        .toList();
    products.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return products;
  }

  TempProductClass? getSingleProduct({
    required String uuid,
  }) {
    List<TempProductClass> products = productBox.values
        .where((pro) => pro.uuid == uuid)
        .toList();
    if (products.isNotEmpty) {
      return products.first;
    } else {
      return null;
    }
  }

  Future<int> insertAllProducts(
    List<TempProductClass> products,
  ) async {
    await clearProducts();
    try {
      for (var product in products) {
        await productBox.put(product.uuid, product);
      }
      await mainLocalLog(
        "Offline Products inserted: ${products.length}",
      );
      await mainLocalLog(getProducts().length.toString());
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Products Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createProduct(
    TempProductClass product,
  ) async {
    try {
      await productBox.put(product.uuid, product);
      await mainLocalLog(
        'Offline Product inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Product Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateProduct(
    TempProductClass product,
  ) async {
    try {
      product.updatedAt = DateTime.now();
      await productBox.put(product.uuid, product);
      await mainLocalLog(
        'Offline Product Update Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Update Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteProduct(String uuid) async {
    try {
      await productBox.delete(uuid);
      await mainLocalLog('Offline Product Deleted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Product Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  // Future<int> deductQuantity({
  //   required bool isOnline,
  //   required String uuid,
  //   required double? quantity,
  // }) async {
  //   try {
  //     var product = productBox.get(uuid);
  //     if (product != null && product.isManaged) {
  //       if (product.isManaged) {
  //         final newQuantity =
  //             (product.quantity ?? 0) - (quantity ?? 0);

  //         // Make sure it never goes negative
  //         product.quantity =
  //             newQuantity < 0 ? 0 : newQuantity;

  //         // Save back into Hive explicitly
  //         await productBox.put(uuid, product);
  //         var containsCreated =
  //             CreatedProductFunc()
  //                 .getProducts()
  //                 .where(
  //                   (cProduct) =>
  //                       cProduct.product.uuid == uuid,
  //                 )
  //                 .toList();
  //         if (containsCreated.isNotEmpty) {
  //           await CreatedProductFunc().updateProduct(
  //             CreatedProducts(
  //               product: productBox.get(uuid)!,
  //             ),
  //           );
  //         } else {
  //           if (!isOnline) {
  //             await SalesProductFunc().createSalesProduct(
  //               SalesProducts(
  //                 productUuid: uuid,
  //                 quantity: quantity ?? 0,
  //               ),
  //             );
  //           }
  //         }
  //         await mainLocalLog(
  //           'Offline Product Quantity Deducted Successfully',
  //         );
  //         return 1;
  //       } else {
  //         await mainLocalLog('Offline Product Is Not Managed');
  //         return 0;
  //       }
  //     } else {
  //       await mainLocalLog('Product not found in box ❌');
  //       return 0;
  //     }
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Offline Product Deduct Failed: ${e.toString()}',
  //     );
  //     return 0;
  //   }
  // }

  // Future<int> incrementQuantity({
  //   required String uuid,
  //   required double? quantity,
  // }) async {
  //   try {
  //     var product = productBox.get(uuid);
  //     if (product != null) {
  //       final newQuantity =
  //           (product.quantity ?? 0) + (quantity ?? 0);

  //       // Make sure it never goes negative
  //       product.quantity =
  //           newQuantity < 0 ? 0 : newQuantity;

  //       // Save back into Hive explicitly
  //       await productBox.put(uuid, product);
  //       var salesProducts = SalesProductFunc()
  //           .getProducts()
  //           .where((sales) => sales.productUuid == uuid);
  //       if (salesProducts.isNotEmpty) {
  //         await SalesProductFunc()
  //             .deductSalesProductQuantity(
  //               SalesProducts(
  //                 quantity: quantity ?? 0,
  //                 productUuid: uuid,
  //               ),
  //             );
  //       }

  //       await mainLocalLog(
  //         'Offline Product Quantity Incremented Successfully',
  //       );
  //       return 1;
  //     } else {
  //       await mainLocalLog('Product not found in box ❌');
  //       return 0;
  //     }
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Offline Product Increment Failed: ${e.toString()}',
  //     );
  //     return 0;
  //   }
  // }

  Future<int> clearProducts() async {
    try {
      if (productBox.values.isNotEmpty) {
        await productBox.clear();
        await mainLocalLog('Offline Products Cleared');
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Products Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedProductFunc().getProducts().isEmpty &&
        UpdatedProductsFunc().getProducts().isEmpty &&
        DeletedProductsFunc().getProductIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
