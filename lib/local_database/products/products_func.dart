import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/sales_product/sales_products.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products%20copy/sales_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';

class ProductsFunc {
  static final ProductsFunc instance =
      ProductsFunc._internal();
  factory ProductsFunc() => instance;
  ProductsFunc._internal();
  late Box<TempProductClass> productBox;
  final String productBoxName = 'productBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempProductClassAdapter());
    productBox = await Hive.openBox(productBoxName);
    await CreatedProductFunc().init();
    await DeletedProductsFunc().init();
    await UpdatedProductsFunc().init();
    await SalesProductFunc().init();
    print('Product Box Initialized');
  }

  List<TempProductClass> getProducts() {
    List<TempProductClass> products =
        productBox.values.toList();
    products.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return products;
  }

  Future<int> insertAllProducts(
    List<TempProductClass> products,
  ) async {
    await clearProducts();
    try {
      for (var product in products) {
        await productBox.put(product.uuid, product);
      }
      print("Offline Products inserted");
      return 1;
    } catch (e) {
      print(
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
      print('Offline Product inserted Successfully');

      return 1;
    } catch (e) {
      print(
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
      print('Offline Product Update Successful');
      return 1;
    } catch (e) {
      print('Update Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteProduct(String uuid) async {
    try {
      await productBox.delete(uuid);
      print('Offline Product Deleted Success');
      return 1;
    } catch (e) {
      print(
        'Offline Product Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deductQuantity({
    required bool isOnline,
    required String uuid,
    required double? quantity,
  }) async {
    try {
      var product = productBox.get(uuid);
      if (product != null && product.isManaged) {
        if (product.isManaged) {
          final newQuantity =
              (product.quantity ?? 0) - (quantity ?? 0);

          // Make sure it never goes negative
          product.quantity =
              newQuantity < 0 ? 0 : newQuantity;

          // Save back into Hive explicitly
          await productBox.put(uuid, product);
          var containsCreated =
              CreatedProductFunc()
                  .getProducts()
                  .where(
                    (cProduct) =>
                        cProduct.product.uuid == uuid,
                  )
                  .toList();
          if (containsCreated.isNotEmpty) {
            await CreatedProductFunc().updateProduct(
              CreatedProducts(
                product: productBox.get(uuid)!,
              ),
            );
            // if (!isOnline) {
            //   await SalesProductFunc().createSalesProduct(
            //     SalesProducts(
            //       productUuid: uuid,
            //       quantity: quantity ?? 0,
            //     ),
            //   );
            // }
          } else {
            if (!isOnline) {
              await SalesProductFunc().createSalesProduct(
                SalesProducts(
                  productUuid: uuid,
                  quantity: quantity ?? 0,
                ),
              );
            }
          }
          print(
            'Offline Product Quantity Deducted Successfully',
          );
          return 1;
        } else {
          print('Offline Product Is Not Managed');
          return 0;
        }
      } else {
        print('Product not found in box ❌');
        return 0;
      }
    } catch (e) {
      print(
        'Offline Product Deduct Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> incrementQuantity({
    required String uuid,
    required double? quantity,
  }) async {
    try {
      var product = productBox.get(uuid);
      if (product != null) {
        final newQuantity =
            (product.quantity ?? 0) + (quantity ?? 0);

        // Make sure it never goes negative
        product.quantity =
            newQuantity < 0 ? 0 : newQuantity;

        // Save back into Hive explicitly
        await productBox.put(uuid, product);
        var salesProducts = SalesProductFunc()
            .getProducts()
            .where((sales) => sales.productUuid == uuid);
        if (salesProducts.isNotEmpty) {
          await SalesProductFunc()
              .deductSalesProductQuantity(
                SalesProducts(
                  quantity: quantity ?? 0,
                  productUuid: uuid,
                ),
              );
        }

        print(
          'Offline Product Quantity Incremented Successfully',
        );
        return 1;
      } else {
        print('Product not found in box ❌');
        return 0;
      }
    } catch (e) {
      print(
        'Offline Product Increment Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProducts() async {
    try {
      if (productBox.values.isNotEmpty) {
        await productBox.clear();
        print('Products Cleared');
      }
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }
}
