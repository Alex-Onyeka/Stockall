import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/buttons/small_button_main.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/text_fields/edit_cart_text_field.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
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
import 'package:stockitt/pages/shop_setup/create_category/create_category.dart';
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
                          child: Material(
                            color: Colors.white,
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
                                  color:
                                      Colors.grey.shade400,
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

late Future<List<String>> categoriesFuture;
//
//
//
//
// U N I T S  B O T T O M  S H E E T

void categoriesBottomSheet(
  BuildContext context,
  Function()? action,
) async {
  Future<List<String>> getCategories() async {
    var tempCat = returnShopProvider(
      context,
      listen: false,
    ).fetchShopCategories(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );
    categoriesFuture = tempCat;
    return tempCat;
  }

  getCategories();

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
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Material(
              color: Colors.white,
              child: Ink(
                color: Colors.white,
                child: FutureBuilder(
                  future: categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return returnCompProvider(
                        context,
                        listen: false,
                      ).showLoader('Loading');
                    } else if (snapshot.hasError) {
                      return EmptyWidgetDisplayOnly(
                        title: 'An Error Occured',
                        subText:
                            'Please check your internet and try again.',
                        theme: returnTheme(context),
                        height: 30,
                        icon: Icons.clear,
                      );
                    } else {
                      return Column(
                        children: [
                          Center(
                            child: Container(
                              height: 4,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Category',
                                    style: TextStyle(
                                      fontSize:
                                          returnTheme(
                                                context,
                                              )
                                              .mobileTexts
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Select Product Category',
                                    style: TextStyle(
                                      fontSize:
                                          returnTheme(
                                                context,
                                              )
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                  FocusScope.of(
                                    context,
                                  ).unfocus();
                                },
                                icon: Icon(
                                  returnData(
                                        context,
                                      ).catValueSet
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
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                border: Border.all(
                                  color:
                                      Colors.grey.shade300,
                                ),
                              ),
                              child: Builder(
                                builder: (context) {
                                  if (snapshot
                                          .connectionState ==
                                      ConnectionState
                                          .waiting) {
                                    return returnCompProvider(
                                      context,
                                      listen: false,
                                    ).showLoader('Loading');
                                  } else if (snapshot
                                      .hasError) {
                                    return SingleChildScrollView(
                                      child: EmptyWidgetDisplayOnly(
                                        title: 'Error ',
                                        subText:
                                            'Error Fetching Categories',
                                        theme: returnTheme(
                                          context,
                                        ),
                                        height: 30,
                                        icon: Icons.clear,
                                      ),
                                    );
                                  } else if (snapshot
                                      .data!
                                      .isEmpty) {
                                    return Material(
                                      color: Colors.white,
                                      child: EmptyWidgetDisplay(
                                        title:
                                            'No Categories',
                                        subText:
                                            'You currently do not have any categories set, click to create category for your store.',
                                        buttonText:
                                            'Create Category',
                                        theme: returnTheme(
                                          context,
                                        ),
                                        height: 35,
                                        icon:
                                            Icons
                                                .book_outlined,
                                        action: () {
                                          Navigator.of(
                                            context,
                                          ).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return CreateCategory();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    var categories =
                                        snapshot.data!;
                                    return ListView.builder(
                                      controller:
                                          scrollController,
                                      itemCount:
                                          categories.length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        String category =
                                            categories[index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade300,
                                              ),
                                            ),
                                          ),
                                          child: Material(
                                            color:
                                                Colors
                                                    .white,
                                            child: ListTile(
                                              title: Text(
                                                categories[index],
                                              ),
                                              onTap: () {
                                                Provider.of<
                                                  DataProvider
                                                >(
                                                  context,
                                                  listen:
                                                      false,
                                                ).selectCategory(
                                                  category,
                                                );
                                              },
                                              trailing: Checkbox(
                                                shape: CircleBorder(
                                                  side:
                                                      BorderSide(),
                                                ),
                                                side: BorderSide(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade400,
                                                  width:
                                                      1.2,
                                                ),
                                                activeColor:
                                                    returnTheme(
                                                      context,
                                                    ).lightModeColor.prColor250,
                                                value:
                                                    returnData(
                                                      context,
                                                    ).selectedCategory ==
                                                    category,
                                                onChanged: (
                                                  value,
                                                ) {
                                                  Provider.of<
                                                    DataProvider
                                                  >(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).selectCategory(
                                                    category,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Visibility(
                            visible:
                                snapshot.data!.isNotEmpty,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        color:
                                            returnTheme(
                                                  context,
                                                )
                                                .lightModeColor
                                                .prColor300,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                          ).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return CreateCategory();
                                              },
                                            ),
                                          );
                                        },
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(
                                                vertical: 7,
                                                horizontal:
                                                    10,
                                              ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                                  3,
                                                ),
                                            border: Border.all(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade400,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              spacing: 5,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontSize:
                                                        returnTheme(
                                                          context,
                                                        ).mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Add New',
                                                ),
                                                Icon(
                                                  size: 25,
                                                  color:
                                                      Colors
                                                          .white,

                                                  Icons.add,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              vertical: 7,
                                              horizontal:
                                                  10,
                                            ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                3,
                                              ),
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            spacing: 8,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      returnTheme(
                                                        context,
                                                      ).mobileTexts.b2.fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                returnData(
                                                      context,
                                                    ).catValueSet
                                                    ? 'Select'
                                                    : 'Cancel',
                                              ),
                                              Icon(
                                                size: 25,
                                                color:
                                                    Colors
                                                        .grey,

                                                returnData(
                                                      context,
                                                    ).catValueSet
                                                    ? Icons
                                                        .check
                                                    : Icons
                                                        .clear,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: false,
                            child: Row(
                              children: [
                                SmallButtonMain(
                                  theme: returnTheme(
                                    context,
                                  ),
                                  action: () {
                                    if (returnData(
                                          context,
                                          listen: false,
                                        ).catValueSet ==
                                        true) {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    } else {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return CreateCategory();
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  buttonText:
                                      returnData(
                                                context,
                                              ).catValueSet ==
                                              true
                                          ? 'Save Category'
                                          : 'Add New Category',
                                ),
                                SmallButtonMain(
                                  theme: returnTheme(
                                    context,
                                  ),
                                  action: () {
                                    if (returnData(
                                          context,
                                          listen: false,
                                        ).catValueSet ==
                                        true) {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    } else {}
                                  },
                                  buttonText:
                                      returnData(
                                                context,
                                              ).catValueSet ==
                                              true
                                          ? 'Save Category'
                                          : 'Add New Category',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
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
          // sizes.sort();

          return Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              30,
              45,
            ),
            child: Material(
              color: Colors.white,
              child: Ink(
                color: Colors.white,
                child: Column(
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
                                    returnTheme(context)
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select Product Size Name',
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
                          borderRadius:
                              BorderRadius.circular(10),
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
                                    color:
                                        Colors
                                            .grey
                                            .shade300,
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
                                    color:
                                        Colors
                                            .grey
                                            .shade400,
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
                                    Provider.of<
                                      DataProvider
                                    >(
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
              ),
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
                                    productId: product.id!,
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
  final List<TempProductClass> products;
  final TextEditingController searchController;
  final VoidCallback close;
  const CustomBottomPanel({
    super.key,
    required this.searchController,
    required this.close,
    required this.products,
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
                    child: EditCartTextField(
                      onChanged: (value) {
                        double entered =
                            double.tryParse(value) ?? 0;
                        if ((entered + cartItem.quantity) >
                            cartItem.item.quantity) {
                          showDialog(
                            context: context,
                            builder:
                                (_) => InfoAlert(
                                  title:
                                      "Quantity Limit Reached",
                                  message:
                                      "Only ${cartItem.item.quantity} available in stock.",
                                  theme: theme,
                                ),
                          );

                          Future.delayed(
                            Duration(milliseconds: 300),
                            () {
                              setState(() {
                                qqty = 1;
                                quantityController.text =
                                    '1';
                              });
                            },
                          );

                          return;
                        }

                        setState(() {
                          qqty = entered;
                          // cartItem.quantity = qqty;
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
                              if (qqty +
                                      cartItem.quantity >=
                                  cartItem.item.quantity) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => InfoAlert(
                                        title:
                                            "Quantity Limit Reached",
                                        message:
                                            "Only ${cartItem.item.quantity} available in stock.",
                                        theme: theme,
                                      ),
                                );
                                return;
                              }
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
                      returnSalesProvider(
                        context,
                        listen: false,
                      ).addItemToCart(cartItem);
                      Navigator.of(context).pop();
                      closeAction();
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
      qqty = 0;
      quantityController.text = '0';
    });
  }

  TextEditingController quantityController =
      TextEditingController(text: '0');
  double qqty = 0;
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
                      InkWell(
                        onTap: () {
                          widget.close();
                          clear();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade800,
                          ),
                          child: Icon(
                            color: Colors.white,
                            Icons.clear_rounded,
                          ),
                        ),
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
                      String? result = await scanCode(
                        context,
                        'Failed',
                      );
                      widget.searchController.text = result;
                      setState(() {
                        scanResult = result;
                        productResults.addAll(
                          widget.products.where(
                            (product) =>
                                product.barcode == result,
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
                      } else if (widget.products
                              .where(
                                (product) => product.name
                                    .toLowerCase()
                                    .contains(
                                      widget
                                          .searchController
                                          .text
                                          .toLowerCase(),
                                    ),
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
                                  if (product.quantity ==
                                      0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        var theme =
                                            Provider.of<
                                              ThemeProvider
                                            >(context);
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'Product Quantity is Zero, there this product cannot be sold',
                                          title:
                                              'Product Out of Stock',
                                        );
                                      },
                                    );
                                  } else if (returnSalesProvider(
                                        context,
                                        listen: false,
                                      ).cartItems
                                      .where(
                                        (item) =>
                                            item.item.id! ==
                                            product.id,
                                      )
                                      .isNotEmpty) {
                                    selectProduct(
                                      theme,
                                      TempCartItem(
                                        discount:
                                            product
                                                .discount,
                                        item: product,
                                        quantity:
                                            returnSalesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      item
                                                          .item
                                                          .id! ==
                                                      product
                                                          .id!,
                                                )
                                                .quantity,
                                      ),
                                      widget.close,
                                    );
                                  } else {
                                    selectProduct(
                                      theme,
                                      TempCartItem(
                                        discount:
                                            product
                                                .discount,
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
                                  }
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
                                widget.products
                                    .where(
                                      (product) => product
                                          .name
                                          .toLowerCase()
                                          .contains(
                                            widget
                                                .searchController
                                                .text
                                                .toLowerCase(),
                                          ),
                                    )
                                    .length,
                            itemBuilder: (context, index) {
                              final product =
                                  widget.products
                                      .where(
                                        (product) => product
                                            .name
                                            .toLowerCase()
                                            .contains(
                                              widget
                                                  .searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .toList()[index];
                              return ProductTileCartSearch(
                                action: () {
                                  if (product.quantity ==
                                      0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        var theme =
                                            Provider.of<
                                              ThemeProvider
                                            >(context);
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'Product Quantity is Zero, there this product cannot be sold',
                                          title:
                                              'Product out of Stock',
                                        );
                                      },
                                    );
                                  } else if (returnSalesProvider(
                                        context,
                                        listen: false,
                                      ).cartItems
                                      .where(
                                        (item) =>
                                            item.item.id! ==
                                            product.id,
                                      )
                                      .isNotEmpty) {
                                    selectProduct(
                                      theme,
                                      TempCartItem(
                                        discount:
                                            product
                                                .discount,
                                        item: product,
                                        quantity:
                                            returnSalesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      item
                                                          .item
                                                          .id! ==
                                                      product
                                                          .id!,
                                                )
                                                .quantity,
                                      ),
                                      widget.close,
                                    );
                                  } else {
                                    selectProduct(
                                      theme,
                                      TempCartItem(
                                        discount:
                                            product
                                                .discount,
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
                                  }
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
  double productQuantity,
  BuildContext context,
  Function()? updateAction,
  TempCartItem cartItem,
  TextEditingController numberController,
) async {
  numberController.text = cartItem.quantity.toString();
  double qqty = cartItem.quantity.toDouble();
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
      return StatefulBuilder(
        builder: (context, setState) {
          // double currentValue = 0;
          // double qqty =
          //     double.tryParse(numberController.text) ??
          //     cartItem.quantity.toDouble();
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
                              onChanged: (value) {
                                final parsedValue =
                                    double.tryParse(
                                      value,
                                    ) ??
                                    0;
                                if (parsedValue >
                                    productQuantity) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      var theme =
                                          Provider.of<
                                            ThemeProvider
                                          >(context);
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Total product quantity can\'t be exceeded',
                                        title:
                                            'Quantity Exceeded',
                                      );
                                    },
                                  );
                                  // Optionally reset to max or previous value
                                  setState(() {
                                    numberController.text =
                                        qqty.toString();
                                  });
                                } else {
                                  setState(() {
                                    qqty = parsedValue;
                                  });
                                }
                              },
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
                                        width: 50,
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
                                        if (qqty >=
                                            productQuantity) {
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              context,
                                            ) {
                                              var theme =
                                                  Provider.of<
                                                    ThemeProvider
                                                  >(
                                                    context,
                                                  );
                                              return InfoAlert(
                                                theme:
                                                    theme,
                                                message:
                                                    'Total product quantity can\'t be exceeded',
                                                title:
                                                    'Quantity Exceeded',
                                              );
                                            },
                                          );
                                        } else {
                                          setState(() {
                                            qqty++;
                                            numberController
                                                    .text =
                                                qqty.toString();
                                          });
                                        }
                                      },
                                      child: SizedBox(
                                        height: 30,
                                        width: 50,
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

// void editProductQuantity(
//   double productQuantity,
//   BuildContext context,
//   Function()? updateAction,
//   TextEditingController numberController,
// ) async {
//   numberController.text = cartItem.quantity.toString();
//   double qqty = cartItem.quantity.toDouble();
//   await showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(20),
//       ),
//     ),
//     backgroundColor: Colors.white,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           // double currentValue = 0;
//           // double qqty =
//           //     double.tryParse(numberController.text) ??
//           //     cartItem.quantity.toDouble();
//           return DraggableScrollableSheet(
//             expand: false,
//             initialChildSize: 0.9,
//             maxChildSize: 0.9,
//             minChildSize: 0.3,
//             builder: (context, scrollController) {
//               var theme = returnTheme(context);
//               return Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.fromLTRB(
//                   30,
//                   15,
//                   30,
//                   45,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Center(
//                       child: Container(
//                         height: 4,
//                         width: 70,
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               BorderRadius.circular(5),
//                           color: Colors.grey.shade400,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment:
//                           MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Edit Number',
//                               style: TextStyle(
//                                 fontSize:
//                                     returnTheme(context)
//                                         .mobileTexts
//                                         .b1
//                                         .fontSize,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'Enter Item Number to Update',
//                               style: TextStyle(
//                                 fontSize:
//                                     returnTheme(context)
//                                         .mobileTexts
//                                         .b2
//                                         .fontSize,
//                               ),
//                             ),
//                           ],
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             FocusScope.of(
//                               context,
//                             ).unfocus();
//                           },
//                           icon: Icon(Icons.clear_rounded),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius:
//                               BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           spacing: 5,
//                           children: [
//                             EditCartTextField(
//                               title: 'Enter Number',
//                               hint: 'Start Typing',
//                               controller: numberController,
//                               theme: theme,
//                               onChanged: (value) {
//                                 final parsedValue =
//                                     double.tryParse(
//                                       value,
//                                     ) ??
//                                     0;
//                                 if (parsedValue >
//                                     productQuantity) {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       var theme =
//                                           Provider.of<
//                                             ThemeProvider
//                                           >(context);
//                                       return InfoAlert(
//                                         theme: theme,
//                                         message:
//                                             'Total product quantity can\'t be exceeded',
//                                         title:
//                                             'Quantity Exceeded',
//                                       );
//                                     },
//                                   );
//                                   // Optionally reset to max or previous value
//                                   setState(() {
//                                     numberController.text =
//                                         qqty.toString();
//                                   });
//                                 } else {
//                                   setState(() {
//                                     qqty = parsedValue;
//                                   });
//                                 }
//                               },
//                             ),
//                             SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment:
//                                   MainAxisAlignment.center,
//                               spacing: 15,
//                               children: [
//                                 Material(
//                                   color: Colors.transparent,
//                                   child: Ink(
//                                     decoration: BoxDecoration(
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                             5,
//                                           ),
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade200,
//                                     ),
//                                     child: InkWell(
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                             5,
//                                           ),
//                                       onTap: () {
//                                         setState(() {
//                                           if (qqty > 1) {
//                                             qqty--;
//                                           }

//                                           numberController
//                                                   .text =
//                                               qqty.toString();
//                                         });
//                                       },
//                                       child: SizedBox(
//                                         height: 30,
//                                         width: 30,
//                                         child: Icon(
//                                           Icons.remove,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   qqty.toString(),
//                                   style: TextStyle(
//                                     fontSize:
//                                         theme
//                                             .mobileTexts
//                                             .h4
//                                             .fontSize,
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                 ),
//                                 Material(
//                                   color: Colors.transparent,
//                                   child: Ink(
//                                     decoration: BoxDecoration(
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                             5,
//                                           ),
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade200,
//                                     ),
//                                     child: InkWell(
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                             5,
//                                           ),
//                                       onTap: () {
//                                         if (qqty >=
//                                             productQuantity) {
//                                           showDialog(
//                                             context:
//                                                 context,
//                                             builder: (
//                                               context,
//                                             ) {
//                                               var theme =
//                                                   Provider.of<
//                                                     ThemeProvider
//                                                   >(
//                                                     context,
//                                                   );
//                                               return InfoAlert(
//                                                 theme:
//                                                     theme,
//                                                 message:
//                                                     'Total product quantity can\'t be exceeded',
//                                                 title:
//                                                     'Quantity Exceeded',
//                                               );
//                                             },
//                                           );
//                                         } else {
//                                           setState(() {
//                                             qqty++;
//                                             numberController
//                                                     .text =
//                                                 qqty.toString();
//                                           });
//                                         }
//                                       },
//                                       child: SizedBox(
//                                         height: 30,
//                                         width: 30,
//                                         child: Center(
//                                           child: Icon(
//                                             Icons.add,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 20),
//                             MainButtonP(
//                               themeProvider: theme,
//                               action: updateAction,
//                               text: 'Update Quantity',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       );
//     },
//   );
// }
