import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
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
  // C A T E G O R Y  D A T A
  // bool barCodeSet = false;

  // String? barcode;

  // Future<void> scanBarcode() async {
  //   try {
  //     String barcodeScanRes =
  //         await FlutterBarcodeScanner.scanBarcode(
  //           '#ffbf00',
  //           'Cancel',
  //           true,
  //           ScanMode.BARCODE,
  //         );

  //     if (barcodeScanRes == '-1') {
  //       barcode = 'This failed';
  //     } else {
  //       barcode = barcodeScanRes;
  //     }
  //   } catch (e) {
  //     barcode = 'Failed... Try Again';
  //   }
  //   notifyListeners();
  // }

  //
  //
  //
}
