import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<void> createProduct(
    TempProductClass product,
    BuildContext context,
  ) async {
    // var data =
    await supabase
        .from('products')
        .insert(product.toJson())
        .select()
        .single();
    print('Product added successfully');
    // final newProduct = TempProductClass.fromJson(data);

    // productList.add(newProduct);
    if (context.mounted) {
      print('Mounted');
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }

    clearFields();
  }

  bool isStartDate = true;

  DateTime? startDate;
  DateTime? endDate;

  void changeDateBoolToTrue() {
    isStartDate = true;
    notifyListeners();
  }

  void clearStartDate() {
    startDate = null;
    notifyListeners();
  }

  void changeDateBoolToFalse() {
    isStartDate = false;
    notifyListeners();
  }

  void clearEndDate() {
    endDate = null;
    notifyListeners();
  }

  void setBothDates(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (isStartDate) {
      startDate = date;
    } else {
      endDate = date;
    }
    notifyListeners();
  }

  List<TempProductClass> productList = [];

  Future<List<TempProductClass>> getProducts(
    int shopId,
  ) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .order('name', ascending: true);
    print('Products gotten');
    productList =
        (data as List)
            .map((json) => TempProductClass.fromJson(json))
            .toList();
    notifyListeners();
    return productList;
  }

  Future<List<TempProductClass>> searchProductName(
    BuildContext context,
    String name,
  ) async {
    var temp = await getProducts(shopId(context));
    final tempData =
        temp
            .where((product) => product.name.contains(name))
            .toList();

    return tempData;
  }

  Future<List<TempProductClass>> getLowProducts(
    int shopId,
  ) async {
    final data = await getProducts(shopId);

    final tempData = data.where(
      (product) => product.quantity < product.lowQtty!,
    );

    return tempData.toList();
  }

  Future<void> updateProduct({
    required TempProductClass product,
    required BuildContext context,
  }) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('products')
        .update(
          product.toJson(),
        ) // use the toJson() method of the class
        .eq(
          'id',
          product.id!,
        ); // use the id from the object
    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    notifyListeners();
  }

  Future<bool> updatePrices({
    required int productId,
    required double newCostPrice,
    required double? newSellingPrice,
    required BuildContext context,
  }) async {
    final response =
        await supabase
            .from('products')
            .update({
              'cost_price': newCostPrice,
              'selling_price': newSellingPrice,
            })
            .eq('id', productId)
            .maybeSingle();
    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    // var newRes = TempProductClass.fromJson(response!);
    // int index = productList.indexWhere(
    //   (c) => c.id == newRes.id,
    // );
    // if (index != -1) {
    //   productList[index] = newRes;
    //   notifyListeners();
    // }
    notifyListeners();
    return response != null;
  }

  Future<bool> updateQuantity({
    required int productId,
    required double newQuantity,
    required BuildContext context,
  }) async {
    final response =
        await supabase
            .from('products')
            .update({'quantity': newQuantity})
            .eq('id', productId)
            .maybeSingle();
    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    notifyListeners();
    return response != null;
  }

  Future<bool> updateDiscount({
    required int productId,
    required double? newDiscount,
    DateTime? statDate,
    DateTime? endDate,
    required BuildContext context,
  }) async {
    final response =
        await supabase
            .from('products')
            .update({
              'discount': newDiscount,
              'starting_date':
                  startDate
                      ?.toIso8601String()
                      .split('T')
                      .first,
              'ending_date':
                  endDate
                      ?.toIso8601String()
                      .split('T')
                      .first,
            })
            .eq('id', productId)
            .maybeSingle();

    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    notifyListeners();
    return response != null;
  }

  Future<void> deleteProductMain(
    int productId,
    BuildContext context,
  ) async {
    await supabase
        .from('products')
        .delete()
        .eq('id', productId);

    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    notifyListeners();
  }

  String name = '';
  String desc = '';
  String brand = '';
  String category = '';
  String unit = '';
  bool isRefundable = false;
  bool setCustomPrice = false;
  String sizeType = '';
  String size = '';
  double costPrice = 0;
  double quantity = 0;
  double sellingPrice = 0;
  double? discount;
  String color = '';
  String barcode = '';

  List<TempProductClass> products = [
    TempProductClass(
      setCustomPrice: false,
      shopId: 1,
      id: 1,
      name: 'Airpod Pro 2nd Gen',
      brand: 'Gucci',
      category: 'Gadgets',
      unit: 'Number',
      isRefundable: false,
      barcode: ']C1CT:557C40DLLQ80S3',
      sizeType: 'Small Medium',
      size: '42',
      costPrice: 10000,
      quantity: 20,
      sellingPrice: 12500,
      discount: 15,
      color: 'Red',
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 2,
      id: 2,
      name: 'Red T-Shirt',
      brand: 'H&M',
      category: 'Clothing',
      barcode: '1234567890123',
      unit: 'pcs',
      isRefundable: true,
      color: 'Red',
      sizeType: 'Medium',
      size: 'M',
      costPrice: 3500,
      sellingPrice: 5000,
      discount: 10,
      quantity: 20,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 3,
      id: 3,
      name: 'Bluetooth Speaker',
      brand: 'JBL',
      category: 'Electronics',
      barcode: '2234567890123',
      unit: 'pcs',
      isRefundable: false,
      color: 'Black',
      sizeType: null,
      size: null,
      costPrice: 15000,
      sellingPrice: 20000,
      discount: 5,
      quantity: 15,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 1,
      id: 4,
      name: 'Running Shoes',
      brand: 'Nike',
      category: 'Footwear',
      barcode: '3234567890123',
      unit: 'pair',
      isRefundable: true,
      color: 'Blue',
      sizeType: 'US',
      size: '42',
      costPrice: 25000,
      sellingPrice: 40000,
      discount: null,
      quantity: 10,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 1,
      id: 5,
      name: 'Notebook',
      brand: 'Cambridge',
      category: 'Stationery',
      barcode: ']C1CT:557C40DLLQ80S3',
      unit: 'pcs',
      isRefundable: false,
      color: null,
      sizeType: null,
      size: null,
      costPrice: 500,
      sellingPrice: 800,
      discount: 5,
      quantity: 100,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 2,
      id: 6,
      name: 'Coffee Mug',
      brand: 'IKEA',
      category: 'Kitchenware',
      barcode: ']C1CT:557C40DLLQ80S3',
      unit: 'pcs',
      isRefundable: true,
      color: 'White',
      sizeType: null,
      size: null,
      costPrice: 700,
      sellingPrice: 1200,
      discount: 15,
      quantity: 30,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 3,
      id: 7,
      name: 'Laptop Bag',
      brand: 'Samsonite',
      category: 'Accessories',
      barcode: '6234567890123',
      unit: 'pcs',
      isRefundable: true,
      color: 'Grey',
      sizeType: 'Standard',
      size: null,
      costPrice: 10000,
      sellingPrice: 15000,
      discount: 10,
      quantity: 0,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 2,
      id: 8,
      name: 'LED Bulb',
      brand: 'Philips',
      category: 'Electronics',
      barcode: '7234567890123',
      unit: 'pcs',
      isRefundable: false,
      color: null,
      sizeType: null,
      size: null,
      costPrice: 300,
      sellingPrice: 500,
      discount: null,
      quantity: 200,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 3,
      id: 9,
      name: 'Shampoo',
      brand: 'Head & Shoulders',
      category: 'Personal Care',
      barcode: ']C1CT:557C40DLLQ80S3',
      unit: 'bottle',
      isRefundable: false,
      color: null,
      sizeType: null,
      size: null,
      costPrice: 1200,
      sellingPrice: 1800,
      discount: 20,
      quantity: 60,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 2,
      id: 10,
      name: 'Wrist Watch',
      brand: 'Fossil',
      category: 'Watches',
      barcode: '5060340392345',
      unit: 'pcs',
      isRefundable: true,
      color: 'Brown',
      sizeType: 'Men',
      size: null,
      costPrice: 20000,
      sellingPrice: 30000,
      discount: 25,
      quantity: 8,
    ),
    TempProductClass(
      setCustomPrice: false,
      shopId: 3,
      id: 10,
      name: 'Face Mask Pack',
      brand: null,
      category: 'Health',
      barcode: null,
      unit: 'pack',
      isRefundable: false,
      color: 'Blue',
      sizeType: null,
      size: null,
      costPrice: 1000,
      sellingPrice: 1500,
      discount: 5,
      quantity: 4,
    ),
  ];

  List<TempProductClass> sortProductsByName(
    List<TempProductClass> products,
  ) {
    products.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return products;
  }

  List<TempProductClass> returnOwnProducts(
    BuildContext context,
  ) {
    return sortProductsByName(products)
        .where(
          (element) =>
              element.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).userShop!.shopId!,
        )
        .toList();
  }

  List<TempProductClass> searchProductsName(
    String text,
    BuildContext context,
  ) {
    List<TempProductClass> tempProducts =
        returnOwnProducts(context)
            .where(
              (product) => product.name
                  .toLowerCase()
                  .contains(text.toLowerCase()),
            )
            .toList();

    return tempProducts;
  }

  List<TempProductClass> searchProductsBarcode(
    String text,
    BuildContext context,
  ) {
    return returnOwnProducts(context)
        .where(
          (product) =>
              product.barcode != null &&
              product.barcode!.contains(text),
        )
        .toList();
  }

  int totalInStock(BuildContext context) {
    int totalNum = 0;
    for (var product in returnOwnProducts(context)) {
      if (product.quantity != 0) {
        totalNum += 1;
      }
    }
    return totalNum;
  }

  int totalOutOfStock(BuildContext context) {
    int totalNum = 0;
    for (var product in returnOwnProducts(context)) {
      if (product.quantity == 0) {
        totalNum += 1;
      }
    }
    return totalNum;
  }

  void deleteProduct(TempProductClass product) {
    products.remove(product);
    notifyListeners();
  }

  void addProduct(TempProductClass product) {
    products.add(product);
    notifyListeners();
  }

  void clearFields() {
    isProductRefundable = false;
    setCustomPrice = false;
    isRefundable = false;
    selectedCategory = null;
    selectedColor = null;
    selectedSize = null;
    selectedUnit = null;
    inStock = false;
    catValueSet = false;
    isOpen = false;
    unitValueSet = false;
    colorValueSet = false;
    sizeValueSet = false;
    clearEndDate();
    clearStartDate();
    notifyListeners();
  }

  bool isProductRefundable = false;
  void toggleRefundable() {
    isProductRefundable = !isProductRefundable;
    notifyListeners();
  }

  void toggleSetCustomPrice() {
    setCustomPrice = !setCustomPrice;
    notifyListeners();
  }

  bool inStock = false;
  void toggleStock() {
    inStock = !inStock;
    notifyListeners();
  }
  //
  //
  //

  //
  //
  //
  //
  //
  //
  // C A T E G O R Y  D A T A
  bool catValueSet = false;
  List<String> categories = [
    'Appliances',
    'Automotive',
    'Baby Products',
    'Beverages',
    'Books',
    'Clothing',
    'Computers',
    'Cosmetics',
    'Dairy',
    'Electronics',
    'Footwear',
    'Furniture',
    'Groceries',
    'Hardware',
    'Health',
    'Home Essentials',
    'Household Supplies',
    'Jewelry',
    'Kitchenware',
    'Meat & Seafood',
    'Medicines',
    'Mobile Phones',
    'Office Supplies',
    'Personal Care',
    'Pet Supplies',
    'Snacks',
    'Sports Equipment',
    'Stationery',
    'Toys',
    'Vegetables',
    'Others',
  ];

  String? selectedCategory;

  bool isOpen = false;

  void toggleCatOpen() {
    isOpen = !isOpen;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (selectedCategory == null) {
      selectedCategory = category;
      catValueSet = true;
    } else if (selectedCategory != category) {
      selectedCategory = category;
      catValueSet = true;
    } else {
      selectedCategory = null;
      catValueSet = false;
    }
    notifyListeners();
  }

  //
  //
  //

  //
  //
  //
  //
  //
  //
  // U N I T   D A T A

  bool unitValueSet = false;

  List<String> units = [
    'bags',
    'barrels',
    'bottles',
    'boxes',
    'bundles',
    'cans',
    'cartons',
    'dozens',
    'gallons',
    'items',
    'jars',
    'kg',
    'lb',
    'liters',
    'mg',
    'ml',
    'packs',
    'pairs',
    'pieces',
    'reams',
    'rolls',
    'sachets',
    'sheets',
    'sets',
    'sticks',
    'tins',
    'trays',
    'tubes',
    'units',
    'Others',
  ];

  String? selectedUnit;

  void selectUnit(String unit) {
    if (selectedUnit == null) {
      selectedUnit = unit;
      unitValueSet = true;
    } else if (selectedUnit != unit) {
      selectedUnit = unit;
      unitValueSet = true;
    } else {
      selectedUnit = null;
      unitValueSet = false;
    }
    notifyListeners();
  }

  //
  //
  //

  //
  //
  //
  //
  //
  //
  // C O L O R S  D A T A

  bool colorValueSet = false;

  List<String> colors = [
    'Red',
    'Yellow',
    'Blue',
    'Green',
    'Purple',
    'Pink',
    'Brown',
    'Indigo',
    'Violet',
    'Orange',
    'Others',
  ];

  String? selectedColor;

  void selectColor(String color) {
    if (selectedColor == null) {
      selectedColor = color;
      colorValueSet = true;
    } else if (selectedColor != color) {
      selectedColor = color;
      colorValueSet = true;
    } else {
      selectedColor = null;
      colorValueSet = false;
    }
    notifyListeners();
  }

  //
  //
  //

  //
  //
  //
  //
  //
  //
  // C O L O R S  D A T A

  bool sizeValueSet = false;

  List<String> sizes = [
    'XX Small',
    'X Small',
    'Small',
    'Medium Small',
    'Medium',
    'Medium Large',
    'Large',
    'X Large',
    'XX Large',
    'XXX Large',
    'Others',
  ];

  String? selectedSize;

  void selectSize(String size) {
    if (selectedSize == null) {
      selectedSize = size;
      sizeValueSet = true;
    } else if (selectedSize != size) {
      selectedSize = size;
      sizeValueSet = true;
    } else {
      selectedSize = null;
      sizeValueSet = false;
    }
    notifyListeners();
  }

  //
  //
  //

  //
  //
  //

  //
  //
  //
  //
  //
  //
  // F L O A T I N G   A C T I O N   B U T T O N

  bool isFloatingButtonVisible = true;

  void hideFloatingActionButtonWithDelay() {
    Future.delayed(Duration(seconds: 5), () {
      isFloatingButtonVisible = false;
      notifyListeners();
    });
  }

  void showFloatingActionButton() {
    isFloatingButtonVisible = true;
    notifyListeners();
  }

  void toggleFloatingAction(BuildContext context) {
    Future.microtask(() {
      if (!context.mounted) return;

      // final uiProvider = returnData(context, listen: false);

      if (!isFloatingButtonVisible) {
        showFloatingActionButton();
        hideFloatingActionButtonWithDelay();
      } else {
        hideFloatingActionButtonWithDelay();
      }
    });
  }
}
