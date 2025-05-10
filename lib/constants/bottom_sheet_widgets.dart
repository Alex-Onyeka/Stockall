import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/buttons/small_button_main.dart';
import 'package:stockitt/components/text_fields/edit_cart_text_field.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/number_textfield.dart';
import 'package:stockitt/components/text_fields/text_field_barcode.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/constants/scan_barcode.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/add_product_one/add_product.dart';
import 'package:stockitt/pages/products/compnents/edit_product_tile.dart';
import 'package:stockitt/pages/products/compnents/product_tile_cart_search.dart';
import 'package:stockitt/pages/products/edit_product/edit_products_page.dart';
import 'package:stockitt/pages/products/product_details/product_details_page.dart';
import 'package:stockitt/providers/data_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

void unitsBottomSheet(
  BuildContext context,
  Function()? action,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> units = returnData(context).units;
          units.sort();

          return Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Units',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select Product Unit',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b2.fontSize,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        returnData(context).unitValueSet
                            ? Icons.check
                            : Icons.clear_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: units.length,
                      itemBuilder: (context, index) {
                        String unit = units[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(units[index]),
                            onTap: () {
                              Provider.of<DataProvider>(
                                context,
                                listen: false,
                              ).selectUnit(unit);
                            },
                            trailing: Checkbox(
                              shape: CircleBorder(
                                side: BorderSide(),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                              activeColor:
                                  returnTheme(context)
                                      .lightModeColor
                                      .prColor250,
                              value:
                                  returnData(
                                    context,
                                  ).selectedUnit ==
                                  unit,
                              onChanged: (value) {
                                Provider.of<DataProvider>(
                                  context,
                                  listen: false,
                                ).selectUnit(unit);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  action!();
}

//
//
//
//
// U N I T S  B O T T O M  S H E E T

void categoriesBottomSheet(
  BuildContext context,
  Function()? action,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> categories =
              returnData(context).categories;
          categories.sort();

          return Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select Product Category',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b2.fontSize,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        returnData(context).catValueSet
                            ? Icons.check
                            : Icons.clear_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(categories[index]),
                            onTap: () {
                              Provider.of<DataProvider>(
                                context,
                                listen: false,
                              ).selectCategory(category);
                            },
                            trailing: Checkbox(
                              shape: CircleBorder(
                                side: BorderSide(),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                              activeColor:
                                  returnTheme(context)
                                      .lightModeColor
                                      .prColor250,
                              value:
                                  returnData(
                                    context,
                                  ).selectedCategory ==
                                  category,
                              onChanged: (value) {
                                Provider.of<DataProvider>(
                                  context,
                                  listen: false,
                                ).selectCategory(category);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  action!();
}

//
//
//
//
// C O L O R S   B O T T O M  S H E E T

void colorsBottomSheet(
  BuildContext context,
  Function()? action,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> colors = returnData(context).colors;
          colors.sort();

          return Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Colors',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select Product Colors',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b2.fontSize,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        returnData(context).colorValueSet
                            ? Icons.check
                            : Icons.clear_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: colors.length,
                      itemBuilder: (context, index) {
                        String color = colors[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(colors[index]),
                            onTap: () {
                              Provider.of<DataProvider>(
                                context,
                                listen: false,
                              ).selectColor(color);
                            },
                            trailing: Checkbox(
                              shape: CircleBorder(
                                side: BorderSide(),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                              activeColor:
                                  returnTheme(context)
                                      .lightModeColor
                                      .prColor250,
                              value:
                                  returnData(
                                    context,
                                  ).selectedColor ==
                                  color,
                              onChanged: (value) {
                                Provider.of<DataProvider>(
                                  context,
                                  listen: false,
                                ).selectColor(color);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  action!();
}

//
//
//

//
//
//
//
// S I Z E  T Y P E   B O T T O M  S H E E T

void sizeTypeBottomSheet(
  BuildContext context,
  Function()? action,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> sizes = returnData(context).sizes;
          sizes.sort();

          return Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sizes - Name',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select Product Size Name',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b2.fontSize,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        returnData(context).sizeValueSet
                            ? Icons.check
                            : Icons.clear_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: sizes.length,
                      itemBuilder: (context, index) {
                        String size = sizes[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(size),
                            onTap: () {
                              Provider.of<DataProvider>(
                                context,
                                listen: false,
                              ).selectSize(size);
                            },
                            trailing: Checkbox(
                              shape: CircleBorder(
                                side: BorderSide(),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                              activeColor:
                                  returnTheme(context)
                                      .lightModeColor
                                      .prColor250,
                              value:
                                  returnData(
                                    context,
                                  ).selectedSize ==
                                  size,
                              onChanged: (value) {
                                Provider.of<DataProvider>(
                                  context,
                                  listen: false,
                                ).selectSize(size);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  action!();
}

//
//
//
//
// S I Z E  T Y P E   B O T T O M  S H E E T

void editProductBottomSheet(
  BuildContext context,
  Function()? action,
  TempProductClass product,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.47,
        maxChildSize: 0.47,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Action Menu',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select the action you want to Perform',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b2.fontSize,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(Icons.clear_rounded),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      spacing: 5,
                      children: [
                        ProductActionTile(
                          svg: editIconSvg,
                          text: 'View Product',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ProductDetailsPage(
                                    product: product,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        ProductActionTile(
                          svg: editIconSvg,
                          text: 'Edit Product',
                          action: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditProductsPage(
                                    product: product,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        ProductActionTile(
                          svg: addIconSvg,
                          text: 'Add New Product',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddProduct();
                                },
                              ),
                            );
                          },
                        ),
                        ProductActionTile(
                          svg: deleteIconSvg,
                          text: 'Delete Product',
                          action: () {
                            returnData(
                              context,
                              listen: false,
                            ).deleteProduct(product);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  action!();
}

//
//
//
//
// C A R T   B O T T O M  S H E E T

class CustomBottomPanel extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback close;
  const CustomBottomPanel({
    super.key,
    required this.searchController,
    required this.close,
  });

  @override
  State<CustomBottomPanel> createState() =>
      _CustomBottomPanelState();
}

class _CustomBottomPanelState
    extends State<CustomBottomPanel> {
  //
  //
  //
  void selectProduct(
    ThemeProvider theme,
    TempCartItem cartItem,
    Function() closeAction,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Enter Product Quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.h4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 450,
                    child: NumberTextfield(
                      onChanged: (value) {
                        setState(() {
                          cartItem.quantity =
                              double.tryParse(value) ?? 0;
                          qqty = int.parse(value);
                        });
                      },
                      title: 'Enter Product Quantity',
                      hint: 'Quantity',
                      controller: quantityController,
                      theme: theme,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: Colors.grey.shade100,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          'Total',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            fontWeight:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontWeightBold,
                          ),
                          formatLargeNumberDouble(
                            qqty *
                                (cartItem
                                        .item
                                        .sellingPrice -
                                    returnSalesProvider(
                                      context,
                                      listen: false,
                                    ).discountCheck(
                                      cartItem.item,
                                    )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      spacing: 15,
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            color: Colors.grey.shade100,
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(5),
                            onTap: () {
                              setState(() {
                                if (qqty > 1) qqty--;
                                quantityController.text =
                                    qqty.toString();
                              });
                            },
                            child: SizedBox(
                              height: 30,
                              width: 50,
                              child: Icon(Icons.remove),
                            ),
                          ),
                        ),
                        Text(
                          qqty.toString(),
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Ink(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            color: Colors.grey.shade100,
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(5),
                            onTap: () {
                              setState(() {
                                qqty++;
                                quantityController.text =
                                    qqty.toString();
                              });
                            },
                            child: SizedBox(
                              height: 30,
                              width: 50,
                              child: Center(
                                child: Icon(Icons.add),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SmallButtonMain(
                    theme: theme,
                    action: () {
                      cartItem.quantity = qqty.toDouble();
                      String result = returnSalesProvider(
                        context,
                        listen: false,
                      ).addItemToCart(cartItem);
                      Navigator.of(context).pop();
                      closeAction();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                    },
                    buttonText: 'Add To Cart',
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      qqty = 1;
      quantityController.text = '1';
    });
  }

  TextEditingController quantityController =
      TextEditingController(text: '1');
  int qqty = 1;
  List productResults = [];
  String? scanResult;
  String? searchResult;
  void clear() {
    searchResult = null;
    scanResult = '';
    productResults.clear();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      // elevation: 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Ink(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(55, 0, 0, 0),
                blurRadius: 5,
              ),
            ],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Container(
            height:
                MediaQuery.of(context).size.height * 0.9,

            padding: const EdgeInsets.fromLTRB(
              15,
              15,
              15,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Products to Cart',
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                  ).mobileTexts.b1.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Search For products to Add to Cart',
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                  ).mobileTexts.b2.fontSize,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          widget.close();
                          clear();
                        },
                        icon: Icon(Icons.clear_rounded),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: TextFieldBarcode(
                    searchController:
                        widget.searchController,
                    onChanged: (value) {
                      setState(() {
                        scanResult = null;
                        productResults.clear();
                        if (value == '') {
                          searchResult = null;
                        } else {
                          searchResult =
                              value.toLowerCase();
                        }
                      });
                    },
                    onPressedScan: () async {
                      productResults.clear();
                      searchResult = null;
                      String result = await scanCode(
                        context,
                        'Failed',
                      );
                      widget.searchController.text = result;
                      setState(() {
                        scanResult = result;
                        productResults.addAll(
                          returnData(
                            context,
                            listen: false,
                          ).searchProductsBarcode(
                            result,
                            context,
                          ),
                        );
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      var products = productResults;
                      if (products.isEmpty &&
                          scanResult != null) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            left: 30,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Product Not Registered In Your Stock',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else if (returnData(context)
                              .searchProductsName(
                                widget
                                    .searchController
                                    .text,
                                context,
                              )
                              .isEmpty &&
                          searchResult != null) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            left: 30,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Found 0 Product(s)',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        if (productResults.isNotEmpty) {
                          return ListView.builder(
                            padding: EdgeInsets.only(
                              top: 10,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product =
                                  products[index];
                              return ProductTileCartSearch(
                                action: () {
                                  selectProduct(
                                    theme,
                                    TempCartItem(
                                      item: product,
                                      quantity:
                                          double.tryParse(
                                            quantityController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                )
                                                .trim(),
                                          ) ??
                                          0.0,
                                    ),
                                    widget.close,
                                  );
                                },
                                theme: theme,
                                product: product,
                              );
                            },
                          );
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.only(
                              top: 10,
                            ),
                            itemCount:
                                returnData(context)
                                    .searchProductsName(
                                      widget
                                          .searchController
                                          .text,
                                      context,
                                    )
                                    .length,
                            itemBuilder: (context, index) {
                              final product =
                                  returnData(
                                    context,
                                  ).searchProductsName(
                                    widget
                                        .searchController
                                        .text,
                                    context,
                                  )[index];
                              return ProductTileCartSearch(
                                action: () {
                                  selectProduct(
                                    theme,
                                    TempCartItem(
                                      item: product,
                                      quantity:
                                          double.tryParse(
                                            quantityController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                )
                                                .trim(),
                                          ) ??
                                          0.0,
                                    ),
                                    widget.close,
                                  );
                                },
                                theme: theme,
                                product: product,
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
//
//
//
// E D I T   C A R T   I T E M   B O T T O M  S H E E T

void editCartItemBottomSheet(
  BuildContext context,
  Function()? updateAction,
  TempCartItem cartItem,
  TextEditingController numberController,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      numberController.text = cartItem.quantity.toString();
      return StatefulBuilder(
        builder: (context, setState) {
          double qqty =
              double.tryParse(numberController.text) ??
              cartItem.quantity.toDouble();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            builder: (context, scrollController) {
              var theme = returnTheme(context);
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(
                  30,
                  15,
                  30,
                  45,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Number',
                              style: TextStyle(
                                fontSize:
                                    returnTheme(context)
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Enter Item Number to Update',
                              style: TextStyle(
                                fontSize:
                                    returnTheme(context)
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            FocusScope.of(
                              context,
                            ).unfocus();
                          },
                          icon: Icon(Icons.clear_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Column(
                          spacing: 5,
                          children: [
                            EditCartTextField(
                              title: 'Enter Number',
                              hint: 'Start Typing',
                              controller: numberController,
                              theme: theme,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 15,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      onTap: () {
                                        setState(() {
                                          if (qqty > 1) {
                                            qqty--;
                                          }

                                          numberController
                                                  .text =
                                              qqty.toString();
                                        });
                                      },
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Icon(
                                          Icons.remove,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  qqty.toString(),
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .h4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      onTap: () {
                                        setState(() {
                                          qqty++;
                                          numberController
                                                  .text =
                                              qqty.toString();
                                        });
                                      },
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            MainButtonP(
                              themeProvider: theme,
                              action: updateAction,
                              text: 'Update Quantity',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

//
//
//

//
//
//
//
// C U S T O M E R   S E A R C H     B O T T O M  S H E E T

class CustomerSearchBottomSheet extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback close;
  const CustomerSearchBottomSheet({
    super.key,
    required this.searchController,
    required this.close,
  });

  @override
  State<CustomerSearchBottomSheet> createState() =>
      _CustomerSearchBottomSheetState();
}

class _CustomerSearchBottomSheetState
    extends State<CustomerSearchBottomSheet> {
  //
  //
  //

  List customerResults = [];

  String? searchResult;
  void clear() {
    searchResult = null;
    customerResults.clear();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      // elevation: 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Ink(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(55, 0, 0, 0),
                blurRadius: 5,
              ),
            ],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Container(
            height:
                MediaQuery.of(context).size.height * 0.9,

            padding: const EdgeInsets.fromLTRB(
              15,
              15,
              15,
              45,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add A Customer',
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                  ).mobileTexts.b1.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Search For Your Customers to Add to Sale',
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                  ).mobileTexts.b2.fontSize,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          widget.close();
                          clear();
                        },
                        icon: Icon(Icons.clear_rounded),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: GeneralTextField(
                    hint: "Enter Customers' Name",
                    lines: 1,
                    theme: theme,
                    title: 'Add Customer (Optional)',
                    controller: widget.searchController,
                    onChanged: (value) {
                      setState(() {
                        if (value == '') {
                          searchResult = null;
                        } else {
                          searchResult =
                              value.toLowerCase();
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      var customers = customerResults;
                      if (customers.isEmpty &&
                          searchResult == null) {
                        return Center(
                          child: Text('Empty List'),
                        );
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.only(top: 10),
                          itemCount:
                              returnData(context)
                                  .searchProductsName(
                                    widget
                                        .searchController
                                        .text,
                                    context,
                                  )
                                  .length,
                          itemBuilder: (context, index) {
                            final product =
                                returnData(
                                  context,
                                ).searchProductsName(
                                  widget
                                      .searchController
                                      .text,
                                  context,
                                )[index];
                            return ProductTileCartSearch(
                              action: () {},
                              theme: theme,
                              product: product,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
//
//
//

// A D D   N E W   C U S T O M E R   B O T T O M

void selectProduct(
  ThemeProvider theme,
  TempCartItem cartItem,
  Function() closeAction,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Enter Product Quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(
                //   width: 450,
                //   child: NumberTextfield(
                //     onChanged: (value) {
                //       setState(() {

                //       });
                //     },
                //     title: 'Enter Product Quantity',
                //     hint: 'Quantity',
                //     controller: quantityController,
                //     theme: theme,
                //   ),
                // ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                        ),
                        'Total',
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .b1
                                  .fontWeightBold,
                        ),
                        'THis',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 15,
                    children: [
                      Ink(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: Colors.grey.shade100,
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(5),
                          onTap: () {},
                          child: SizedBox(
                            height: 30,
                            width: 50,
                            child: Icon(Icons.remove),
                          ),
                        ),
                      ),
                      Text(
                        ' qqty.toString(),',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h4.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Ink(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: Colors.grey.shade100,
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(5),
                          onTap: () {},
                          child: SizedBox(
                            height: 30,
                            width: 50,
                            child: Center(
                              child: Icon(Icons.add),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SmallButtonMain(
                  theme: theme,
                  action: () {
                    String result = returnSalesProvider(
                      context,
                      listen: false,
                    ).addItemToCart(cartItem);
                    Navigator.of(context).pop();
                    closeAction();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  },
                  buttonText: 'Add To Cart',
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
