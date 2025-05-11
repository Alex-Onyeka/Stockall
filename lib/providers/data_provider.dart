import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/main.dart';

class DataProvider extends ChangeNotifier {
  String name = '';
  String desc = '';
  String brand = '';
  String category = '';
  String unit = '';
  bool isRefundable = false;
  String sizeType = '';
  String size = '';
  double costPrice = 15;
  double quantity = 15;
  double sellingPrice = 15;
  double discount = 15;
  String color = '';
  String barcode = '';

  List<TempProductClass> products = [
    TempProductClass(
      shopId: 1,
      id: 1,
      name: 'Airpod Pro 2nd Gen',
      desc: 'A very Nice Product',
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
      shopId: 2,
      id: 2,
      name: 'Red T-Shirt',
      desc: 'Comfortable cotton t-shirt',
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
      shopId: 3,
      id: 3,
      name: 'Bluetooth Speaker',
      desc: 'Portable wireless speaker',
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
      shopId: 1,
      id: 4,
      name: 'Running Shoes',
      desc: 'Lightweight shoes for running',
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
      shopId: 1,
      id: 5,
      name: 'Notebook',
      desc: '200-page ruled notebook',
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
      shopId: 2,
      id: 6,
      name: 'Coffee Mug',
      desc: null,
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
      shopId: 3,
      id: 7,
      name: 'Laptop Bag',
      desc: 'Water-resistant laptop backpack',
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
      shopId: 2,
      id: 8,
      name: 'LED Bulb',
      desc: '9W LED energy-saving bulb',
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
      shopId: 3,
      id: 9,
      name: 'Shampoo',
      desc: 'Anti-dandruff shampoo 250ml',
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
      shopId: 2,
      id: 10,
      name: 'Wrist Watch',
      desc: 'Analog watch with leather strap',
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
      shopId: 3,
      id: 10,
      name: 'Face Mask Pack',
      desc: 'Pack of 50 disposable masks',
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

  int currentSelect = 0;
  void changeSelected(int number) {
    currentSelect = number;
    notifyListeners();
  }

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
              element.shopId == currentShop(context).shopId,
        )
        .toList();
  }

  List<TempProductClass> filterProducts(
    BuildContext context,
  ) {
    switch (currentSelect) {
      case 1:
        return returnOwnProducts(
          context,
        ).where((p) => p.quantity != 0).toList();
      case 2:
        return returnOwnProducts(context)
            .where(
              (p) => p.quantity <= 10 && p.quantity != 0,
            )
            .toList();
      case 3:
        return returnOwnProducts(
          context,
        ).where((p) => p.quantity == 0).toList();
      case 0:
      default:
        return returnOwnProducts(context);
    }
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
    notifyListeners();
  }

  bool isProductRefundable = false;
  void toggleRefundable() {
    isProductRefundable = !isProductRefundable;
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
    'Clothess',
    'Shoess',
    'Drinkss',
    'Electronicss',
    'Bookss',
    'Digital Gaddgetss',
    'Foods',
    'Clothes.',
    'Shoes.',
    'Drinks.',
    'Electronics.',
    'Books.',
    'Digital Gaddgets.',
    'Food.',
    'Clothes',
    'Shoes',
    'Drinks',
    'Electronics',
    'Books',
    'Digital Gaddgets',
    'Food',
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
    'Lites',
    'Lengths',
    'Kgs',
    'currentSelects',
    'Guages',
    'Lite',
    'Length',
    'Kg',
    'currentSelect',
    'Guage',
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
