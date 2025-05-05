import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';

class DataProvider extends ChangeNotifier {
  List<TempProductClass> products = [
    TempProductClass(
      name: 'Airpod Pro 2nd Gen',
      desc: 'A very Nice Product',
      brand: 'Gucci',
      category: 'Gadgets',
      unit: 'Number',
      isRefundable: false,
      sizeType: 'Small Medium',
      size: '42',
      costPrice: 10000,
      quantity: 20,
      sellingPrice: 12500,
      discount: 15,
      color: 'Red',
    ),
    TempProductClass(
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
      name: 'Notebook',
      desc: '200-page ruled notebook',
      brand: 'Cambridge',
      category: 'Stationery',
      barcode: '4234567890123',
      unit: 'pcs',
      isRefundable: false,
      color: null,
      sizeType: null,
      size: null,
      costPrice: 500,
      sellingPrice: 800,
      discount: 0,
      quantity: 100,
    ),
    TempProductClass(
      name: 'Coffee Mug',
      desc: null,
      brand: 'IKEA',
      category: 'Kitchenware',
      barcode: '5234567890123',
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
      quantity: 25,
    ),
    TempProductClass(
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
      name: 'Shampoo',
      desc: 'Anti-dandruff shampoo 250ml',
      brand: 'Head & Shoulders',
      category: 'Personal Care',
      barcode: '8234567890123',
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
      name: 'Wrist Watch',
      desc: 'Analog watch with leather strap',
      brand: 'Fossil',
      category: 'Watches',
      barcode: '9234567890123',
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
      quantity: 50,
    ),
  ];

  void deleteProduct(TempProductClass product) {
    products.remove(product);
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
    'Numbers',
    'Guages',
    'Lite',
    'Length',
    'Kg',
    'Number',
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
}
