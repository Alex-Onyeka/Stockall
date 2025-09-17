import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:uuid/uuid.dart';

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
        await productBox.put(product.id, product);
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
    final uuid = Uuid();
    product.uuid ??= uuid.v4();

    // Ensure createdAt is always set
    product.createdAt ??= DateTime.now();
    try {
      if (product.id != null) {
        await productBox.put(product.id, product);
        print('Offline Product inserted Successfully');
      } else {
        final products = getProducts();
        int newId = 1;

        if (products.isNotEmpty) {
          final maxId = products
              .map((p) => p.id ?? 0)
              .reduce((a, b) => a > b ? a : b);
          newId = maxId + 1;
        }
        product.id = newId;
        product.createdAt = DateTime.now();
        await productBox.put(newId, product);
        print('Offline Product inserted with id $newId');
      }

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
      await productBox.put(product.id, product);
      print('Offline Product Update Successful');
      return 1;
    } catch (e) {
      print('Update Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      await productBox.delete(id);
      print('Offline Product Deleted Success');
      return 1;
    } catch (e) {
      print(
        'Offline Product Delete Failed: ${e.toString()}',
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
