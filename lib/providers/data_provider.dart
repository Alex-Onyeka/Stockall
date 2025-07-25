import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider extends ChangeNotifier {
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    print('Loading: ${value.toString()}');
    notifyListeners();
  }

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
    print('Item added successfully');
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

  DateTime? expiryDate;
  void setExpDate(DateTime date) {
    expiryDate = date;
    notifyListeners();
  }

  void clearExpDate() {
    expiryDate = null;
    notifyListeners();
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

  void setBothDates({
    DateTime? start,
    DateTime? end,
    DateTime? expDate,
  }) {
    startDate = start;
    endDate = end;
    expiryDate = expDate;
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

  void clearProducts() {
    productList.clear();
    notifyListeners();
  }

  Future<List<TempProductClass>> getProducts(
    int shopId,
  ) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .order('name', ascending: true);
    print('Items gotten');
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
      (product) =>
          product.quantity != null &&
          product.quantity! < product.lowQtty!,
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
    notifyListeners();
    return response != null;
  }

  Future<bool> updateQuantity({
    required int productId,
    required double? newQuantity,
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

  Future<bool> updateIsManaged({
    required int productId,
    required BuildContext context,
    required bool value,
    required int? qtty,
  }) async {
    final response =
        await supabase
            .from('products')
            .update({'is_managed': value, 'quantity': qtty})
            .eq('id', productId)
            .maybeSingle();
    print(response?['is_managed']);
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
  bool isManaged = true;
  String sizeType = '';
  String size = '';
  double costPrice = 0;
  double quantity = 0;
  double sellingPrice = 0;
  double? discount;
  String color = '';
  String barcode = '';

  void clearFields() {
    isProductRefundable = false;
    setCustomPrice = false;
    isRefundable = false;
    selectedCategory = null;
    selectedColor = null;
    selectedSize = null;
    inStock = false;
    catValueSet = false;
    isManaged = true;
    isOpen = false;
    unitValueSet = false;
    colorValueSet = false;
    sizeValueSet = false;
    clearEndDate();
    clearStartDate();
    clearExpDate();
    clearExpenseUnit();
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

  void toggleIsManaged() {
    isManaged = !isManaged;
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
    'Baby Items',
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
    'Length',
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

  void clearExpenseUnit() {
    selectedUnit = null;
    notifyListeners();
  }

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
