import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
// import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/buttons/toggle_total_price.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/categories/categories_page.dart';
import 'package:stockall/pages/products/compnents/product_tile_cart_search.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

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
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> units =
              returnData(context: context).units;
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
                          'Select Item Unit',
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
                        returnData(
                              context: context,
                            ).unitValueSet
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
                              title: Text(
                                style: TextStyle(
                                  fontSize:
                                      returnTheme(
                                            context,
                                            listen: false,
                                          )
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                units[index],
                              ),
                              onTap: () {
                                returnData().selectUnit(
                                  unit,
                                );
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
                                      context: context,
                                    ).selectedUnit ==
                                    unit,
                                onChanged: (value) {
                                  returnData().selectUnit(
                                    unit,
                                  );
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

void groupUnitsBottomSheet(
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
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> units =
              returnData(context: context).units;
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
                          'Group Units',
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                ).mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select Item Group Unit',
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
                        returnData(
                              context: context,
                            ).groupUnitValueSet
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
                              title: Text(
                                style: TextStyle(
                                  fontSize:
                                      returnTheme(
                                            context,
                                            listen: false,
                                          )
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                units[index],
                              ),
                              onTap: () {
                                returnData()
                                    .selectGroupUnit(
                                      unit: unit,
                                    );
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
                                      context: context,
                                    ).selectedGroupUnit ==
                                    unit,
                                onChanged: (value) {
                                  returnData()
                                      .selectGroupUnit(
                                        unit: unit,
                                      );
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
  var shopCat = returnCategoriesProvider().categories();

  // getCategories();

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
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 80,
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
                              'Category',
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
                              'Select Item Category',
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
                            returnData(
                                  context: context,
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
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (shopCat.isEmpty) {
                              return Material(
                                color: Colors.white,
                                child: EmptyWidgetDisplay(
                                  title: 'No Categories',
                                  subText:
                                      'You currently do not have any categories set, click to create category for your store.',
                                  buttonText:
                                      'Create Category',
                                  theme: returnTheme(
                                    context,
                                  ),
                                  height: 30,
                                  icon: Icons.book_outlined,
                                  action: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CategoriesPage();
                                        },
                                      ),
                                    );
                                  },
                                  altAction: () async {
                                    await returnCategoriesProvider()
                                        .getCategories(
                                          shopId(),
                                        );
                                  },
                                  altActionText: 'Refresh',
                                  altIcon: Icons.refresh,
                                ),
                              );
                            } else {
                              return ListView.builder(
                                controller:
                                    scrollController,
                                itemCount: shopCat.length,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  CategoryClass category =
                                      shopCat[index];
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
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(
                                          style: TextStyle(
                                            fontSize:
                                                returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    )
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                          shopCat[index]
                                              .name,
                                        ),
                                        onTap: () {
                                          returnData()
                                              .selectCategory(
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
                                            width: 1.2,
                                          ),
                                          activeColor:
                                              returnTheme(
                                                    context,
                                                  )
                                                  .lightModeColor
                                                  .prColor250,
                                          value:
                                              returnData(
                                                context:
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
                                              listen: false,
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
                      visible: shopCat.isNotEmpty,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  color:
                                      returnTheme(context)
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
                                        builder: (context) {
                                          return CategoriesPage();
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
                                          horizontal: 10,
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
                                                  Colors
                                                      .white,
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
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
                              color: Colors.transparent,
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
                                        horizontal: 10,
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
                                                    )
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          returnData(
                                                context:
                                                    context,
                                              ).catValueSet
                                              ? 'Select'
                                              : 'Cancel',
                                        ),
                                        Icon(
                                          size: 25,
                                          color:
                                              Colors.grey,

                                          returnData(
                                                context:
                                                    context,
                                              ).catValueSet
                                              ? Icons.check
                                              : Icons.clear,
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
                            theme: returnTheme(context),
                            action: () {
                              if (returnData()
                                      .catValueSet ==
                                  true) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CategoriesPage();
                                    },
                                  ),
                                );
                              }
                            },
                            buttonText:
                                returnData(
                                          context: context,
                                        ).catValueSet ==
                                        true
                                    ? 'Save Category'
                                    : 'Add New Category',
                          ),
                          SmallButtonMain(
                            theme: returnTheme(context),
                            action: () {
                              if (returnData()
                                      .catValueSet ==
                                  true) {
                                Navigator.of(context).pop();
                              } else {}
                            },
                            buttonText:
                                returnData(
                                          context: context,
                                        ).catValueSet ==
                                        true
                                    ? 'Save Category'
                                    : 'Add New Category',
                          ),
                        ],
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
          List<String> colors = returnData().colors;
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
                          'Select Item Colors',
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
                        returnData().colorValueSet
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
                                  returnData()
                                      .selectedColor ==
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
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<String> sizes =
              returnData(context: context).sizes;
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
                              'Select Item Size Name',
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
                            returnData(
                                  context: context,
                                ).sizeValueSet
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
                                        context: context,
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
// C A R T   B O T T O M  S H E E T

class CustomBottomPanel extends StatefulWidget {
  // final List<TempProductClass> products;
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
  FocusNode qttyNode = FocusNode();
  //
  //
  //
  void selectProduct({
    required ThemeProvider theme,
    required TempCartItem cartItem,
    required Function() closeAction,
    required TextEditingController priceController,
  }) {
    qttyNode.requestFocus();
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap:
              () =>
                  FocusManager.instance.primaryFocus
                      ?.unfocus(),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                insetPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                backgroundColor: Colors.white,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter Item Sales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.grey.shade300),
                  ],
                ),

                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible:
                            returnSalesProviderContext(
                              context,
                            ).isSetCustomPrice() &&
                            (cartItem.item.setCustomPrice ||
                                cartItem
                                        .item
                                        .sellingPrice ==
                                    null) &&
                            !cartItem.useWholeSalePrice,
                        child: Row(
                          spacing: 10,
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ToggleTotalPriceWidget(
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: MoneyTextfield(
                                title:
                                    returnSalesProviderContext(
                                          context,
                                        ).setTotalPrice
                                        ? 'Total Price'
                                        : 'Individual Price',
                                hint: 'Enter Price',
                                controller: priceController,
                                theme: theme,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    cartItem.setCustomPrice =
                                        true;
                                  } else {
                                    cartItem.setCustomPrice =
                                        false;
                                  }
                                  print(
                                    cartItem.setCustomPrice,
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 450,
                        child: EditCartTextField(
                          focusNode: qttyNode,
                          onSubmitted: (value) {
                            if (cartItem
                                        .item
                                        .sellingPrice ==
                                    null &&
                                priceController
                                    .text
                                    .isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'Custom Price Must be set before Item can be added to cart.',
                                    title:
                                        'Custom Price Not Set',
                                  );
                                },
                              ).then((_) {
                                qttyNode.requestFocus();
                              });
                            } else {
                              if (quantityController
                                      .text
                                      .isEmpty ||
                                  qqty == 0) {
                                // Navigator.of(context).pop();

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Item quantity cannot be set to (0)',
                                      title:
                                          'Invalid Quantity',
                                    );
                                  },
                                ).then((_) {
                                  qttyNode.requestFocus();
                                });
                                ;
                              } else {
                                if (priceController
                                    .text
                                    .isNotEmpty) {
                                  cartItem.customPrice =
                                      double.tryParse(
                                        priceController.text
                                            .replaceAll(
                                              ',',
                                              '',
                                            ),
                                      );
                                  cartItem.setCustomPrice =
                                      true;
                                } else {
                                  cartItem.setCustomPrice =
                                      false;
                                }
                                cartItem.setTotalPrice =
                                    returnSalesProvider()
                                        .setTotalPrice;
                                cartItem.quantity =
                                    qqty.toDouble();
                                returnSalesProvider()
                                    .addItemToCart(
                                      context: context,
                                      newItem: cartItem,
                                      isCustomEdit:
                                          returnData()
                                              .productList()
                                              .where(
                                                (product) =>
                                                    product
                                                        .uuid ==
                                                    cartItem
                                                        .item
                                                        .uuid,
                                              )
                                              .isEmpty,
                                    );
                                Navigator.of(context).pop();
                                closeAction();
                              }
                            }
                          },
                          onChanged: (value) {
                            double entered =
                                double.tryParse(
                                  value.replaceAll(',', ''),
                                ) ??
                                0;
                            if (cartItem.item.isManaged) {
                              if (!returnSalesProvider()
                                  .canAddProductToCart(
                                    product: cartItem.item,
                                    quantityToAdd:
                                        entered +
                                        cartItem.quantity,
                                  )) {
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
                                ).then((_) {
                                  qttyNode.requestFocus();
                                });

                                Future.delayed(
                                  Duration(
                                    milliseconds: 300,
                                  ),
                                  () {
                                    setState(() {
                                      qqty = 0;
                                      quantityController
                                          .text = '0';
                                    });
                                  },
                                );

                                return;
                              }
                            }

                            if (value.isEmpty) {
                              setState(() {
                                quantityController.text =
                                    '0';
                              });
                            }

                            setState(() {
                              qqty = entered;
                              // cartItem.quantity = qqty;
                            });
                          },

                          title: 'Enter Item Quantity',
                          hint: 'Quantity',
                          controller: quantityController,
                          theme: theme,
                        ),
                      ),
                      Visibility(
                        visible:
                            cartItem.item.setCustomPrice &&
                            !cartItem.useWholeSalePrice,
                        child: SizedBox(height: 20),
                      ),
                      Visibility(
                        visible:
                            cartItem.item.setCustomPrice &&
                            !cartItem.useWholeSalePrice,
                        child: InkWell(
                          onTap: () {
                            returnSalesProvider()
                                .toggleSetCustomPrice();
                            priceController.clear();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 5,
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
                                  returnSalesProviderContext(
                                        context,
                                      ).isSetCustomPrice()
                                      ? 'Cancel Custom Price'
                                      : 'Set Custom Price',
                                ),
                                Stack(
                                  children: [
                                    Visibility(
                                      visible:
                                          returnSalesProviderContext(
                                            context,
                                          ).isSetCustomPrice() ==
                                          false,
                                      child:
                                          SvgPicture.asset(
                                            editIconSvg,
                                            height: 20,
                                          ),
                                    ),
                                    Visibility(
                                      visible:
                                          returnSalesProviderContext(
                                            context,
                                          ).isSetCustomPrice() ==
                                          true,
                                      child: Icon(
                                        Icons.clear,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
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
                              formatMoneyMid(
                                amount: double.parse(
                                  formatSellingPrice(
                                    cartItem,
                                  ),
                                ),
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible:
                            returnShopProvider()
                                .userShop()
                                ?.wholeSale ==
                            true,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Use Whole Sale Price?',
                                  ),
                                  MyToggleButton(
                                    boolValue:
                                        cartItem
                                            .useWholeSalePrice,
                                    toggle: () {
                                      var salesProvider =
                                          returnSalesProvider();
                                      salesProvider
                                          .toggleWholeSale(
                                            cartItem:
                                                cartItem,
                                            context:
                                                context,
                                          );
                                      priceController
                                          .clear();
                                      salesProvider
                                          .closeCustomPrice();
                                    },
                                    theme: theme,
                                  ),
                                ],
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
                                    BorderRadius.circular(
                                      5,
                                    ),
                                color: Colors.grey.shade100,
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                onTap: () {
                                  setState(() {
                                    if (qqty > 0) qqty--;
                                    quantityController
                                            .text =
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
                              formatLargeNumberDouble(qqty),
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
                                    BorderRadius.circular(
                                      5,
                                    ),
                                color: Colors.grey.shade100,
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                onTap: () {
                                  if (cartItem
                                      .item
                                      .isManaged) {
                                    if (!returnSalesProvider()
                                        .canAddProductToCart(
                                          product:
                                              cartItem.item,
                                          quantityToAdd:
                                              qqty + 1,
                                        )) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (
                                              _,
                                            ) => InfoAlert(
                                              title:
                                                  "Quantity Limit Reached",
                                              message:
                                                  "Only (${cartItem.item.quantity}) items available in stock.",
                                              theme: theme,
                                            ),
                                      );
                                      return;
                                    }
                                  }
                                  setState(() {
                                    qqty++;
                                    quantityController
                                            .text =
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
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              quantityController.clear();
                              qqty = 0;
                            },
                            child: Text('Cancel'),
                          ),
                          SmallButtonMain(
                            theme: theme,
                            action: () {
                              if (cartItem
                                          .item
                                          .sellingPrice ==
                                      null &&
                                  priceController
                                      .text
                                      .isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Custom Price Must be set before Item can be added to cart.',
                                      title:
                                          'Custom Price Not Set',
                                    );
                                  },
                                );
                              } else {
                                if (quantityController
                                        .text
                                        .isEmpty ||
                                    qqty == 0) {
                                  // Navigator.of(context).pop();

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Item quantity cannot be set to (0)',
                                        title:
                                            'Invalid Quantity',
                                      );
                                    },
                                  );
                                } else {
                                  if (priceController
                                      .text
                                      .isNotEmpty) {
                                    cartItem.customPrice =
                                        double.tryParse(
                                          priceController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        );
                                    cartItem.setCustomPrice =
                                        true;
                                  } else {
                                    cartItem.setCustomPrice =
                                        false;
                                  }
                                  cartItem.setTotalPrice =
                                      returnSalesProvider()
                                          .setTotalPrice;
                                  cartItem.quantity =
                                      qqty.toDouble();
                                  returnSalesProvider().addItemToCart(
                                    context: context,
                                    newItem: cartItem,
                                    isCustomEdit:
                                        returnData()
                                            .productList()
                                            .where(
                                              (product) =>
                                                  product
                                                      .uuid ==
                                                  cartItem
                                                      .item
                                                      .uuid,
                                            )
                                            .isEmpty,
                                  );
                                  Navigator.of(
                                    context,
                                  ).pop();
                                  closeAction();
                                }
                              }
                            },
                            buttonText: 'Add To Cart',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((value) {
      qqty = 0;
      quantityController.text = '';
      priceController.clear();
      widget.searchController.clear();
      if (context.mounted) {
        returnSalesProvider().closeCustomPrice();
        returnSalesProvider().toggleSetTotalPrice(false);
      }
    });
  }

  TextEditingController quantityController =
      TextEditingController(text: '');
  TextEditingController priceController =
      TextEditingController();
  double qqty = 0;
  List<TempProductClass> productResults = [];
  String? scanResult;
  String? searchResult;
  void clear() {
    searchResult = null;
    scanResult = '';
    productResults.clear();
  }

  FocusNode mainSearchNode = FocusNode();

  String formatSellingPrice(TempCartItem cartItem) {
    if (cartItem.useWholeSalePrice) {
      return (qqty * (cartItem.item.wholeSalePrice ?? 0))
          .toString();
    } else if (priceController.text.isNotEmpty) {
      if (returnSalesProvider().setTotalPrice) {
        return priceController.text.replaceAll(',', '');
      } else {
        return (double.parse(
                  priceController.text.isNotEmpty
                      ? priceController.text.replaceAll(
                        ',',
                        '',
                      )
                      : '0',
                ) *
                qqty.toDouble())
            .toString();
      }
    } else {
      return (qqty * (cartItem.item.sellingPrice ?? 0))
          .toString();
    }
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

            padding:
                screenWidth(context) < mobileScreen
                    ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                    : const EdgeInsets.fromLTRB(
                      15,
                      15,
                      15,
                      40,
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          screenWidth(context) <
                                  mobileScreen
                              ? 0
                              : screenWidth(context) >
                                      mobileScreen &&
                                  screenWidth(context) <
                                      tabletScreen
                              ? 20
                              : 100,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              39,
                              4,
                              1,
                              41,
                            ),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {});
                                      },
                                      child: Text(
                                        'Add Item to Cart',
                                        style: TextStyle(
                                          fontSize:
                                              returnTheme(
                                                    context,
                                                  )
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Search For items',
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
                                InkWell(
                                  onTap: () {
                                    widget.close();
                                    widget.searchController
                                        .clear();
                                    clear();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      10,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade800,
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
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFieldBarcode(
                                    node: mainSearchNode,
                                    clearTextField: () {
                                      setState(() {});
                                    },
                                    searchController:
                                        widget
                                            .searchController,
                                    onChanged: (
                                      value,
                                    ) async {
                                      setState(() {
                                        scanResult = null;
                                        productResults
                                            .clear();
                                      });
                                      if (value == '') {
                                        setState(() {
                                          searchResult =
                                              null;
                                        });
                                      } else {
                                        setState(() {
                                          searchResult =
                                              value
                                                  .toLowerCase();
                                        });
                                        var items = returnData()
                                            .productList()
                                            .where(
                                              (product) =>
                                                  product
                                                      .barcode
                                                      ?.toLowerCase() ==
                                                  value
                                                      .toLowerCase(),
                                            );
                                        if (items
                                            .isNotEmpty) {
                                          SalesAuthAction().useBarcodeAction(
                                            context:
                                                context,
                                            action: () async {
                                              await playBeep();
                                            },
                                            failAction: () {
                                              widget
                                                  .searchController
                                                  .clear();
                                            },
                                          );
                                        }
                                      }
                                    },
                                    onPressedScan: () async {
                                      SalesAuthAction().useBarcodeAction(
                                        context: context,
                                        action: () async {
                                          productResults
                                              .clear();
                                          searchResult =
                                              null;
                                          String? result =
                                              await scanCode(
                                                context,
                                                'Failed',
                                              );
                                          setState(() {});
                                          if (result !=
                                              null) {
                                            widget
                                                .searchController
                                                .text = result;
                                          }
                                          var items = returnData()
                                              .productList()
                                              .where(
                                                (product) =>
                                                    product
                                                        .barcode ==
                                                    result,
                                              );
                                          if (items
                                              .isNotEmpty) {
                                            setState(() {
                                              scanResult =
                                                  result;
                                              productResults
                                                  .addAll(
                                                    items,
                                                  );
                                            });
                                            await playBeep();
                                          }
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      Platform.isWindows,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 2),
                                      IconButton(
                                        onPressed: () async {
                                          mainSearchNode
                                              .requestFocus();
                                          try {
                                            if (Platform
                                                .isWindows) {
                                              await Process.start(
                                                'cmd',
                                                [
                                                  '/c',
                                                  'start',
                                                  '',
                                                  'osk',
                                                ],
                                                mode:
                                                    ProcessStartMode
                                                        .detached,
                                              );
                                            }
                                          } catch (e) {
                                            print(
                                              'Error Opening Keyboard: ${e.toString()}',
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          size: 25,
                                          Icons
                                              .keyboard_alt_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                var products =
                                    productResults;
                                if (products.isEmpty &&
                                    scanResult != null) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          top: 20.0,
                                          left: 30,
                                        ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
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
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Item Not Registered In Your Stock',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (returnData()
                                        .productList()
                                        .where(
                                          (product) =>
                                              product.name
                                                  .toLowerCase()
                                                  .contains(
                                                    widget
                                                        .searchController
                                                        .text
                                                        .toLowerCase(),
                                                  ) ||
                                              (product.barcode !=
                                                      null &&
                                                  product
                                                      .barcode!
                                                      .toLowerCase()
                                                      .contains(
                                                        widget.searchController.text.toLowerCase(),
                                                      )),
                                        )
                                        .isEmpty &&
                                    searchResult != null) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          top: 20.0,
                                          left: 30,
                                        ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
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
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Found 0 Item(s)',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  if (productResults
                                      .isNotEmpty) {
                                    return RefreshIndicator(
                                      onRefresh: () async {
                                        await returnData()
                                            .getProducts(
                                              returnShopProvider()
                                                  .userShop()!
                                                  .shopId!,
                                            );
                                        setState(() {});
                                      },
                                      backgroundColor:
                                          Colors.white,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      displacement: 10,
                                      child: ListView.builder(
                                        padding:
                                            EdgeInsets.only(
                                              top: 10,
                                            ),
                                        itemCount:
                                            products.length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          final product =
                                              products[index];
                                          return ProductTileCartSearch(
                                            action: () {
                                              if (!product
                                                  .isManaged) {
                                                if (returnSalesProvider()
                                                    .currentCart()
                                                    .cartItems
                                                    .where(
                                                      (
                                                        item,
                                                      ) =>
                                                          item.item.uuid! ==
                                                          product.uuid,
                                                    )
                                                    .isNotEmpty) {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .useWholeSalePrice,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .quantity,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                } else {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          false,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          double.tryParse(
                                                            quantityController.text
                                                                .replaceAll(
                                                                  ',',
                                                                  '',
                                                                )
                                                                .trim(),
                                                          ) ??
                                                          0.0,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                }
                                              } else {
                                                if (product
                                                        .quantity ==
                                                    0) {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      var theme = Provider.of<
                                                        ThemeProvider
                                                      >(
                                                        context,
                                                      );
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'Item Quantity is Zero, Therefore, this item cannot be sold',
                                                        title:
                                                            'Item out of Stock',
                                                      );
                                                    },
                                                  );
                                                } else if (returnSalesProvider()
                                                    .currentCart()
                                                    .cartItems
                                                    .where(
                                                      (
                                                        item,
                                                      ) =>
                                                          item.item.uuid! ==
                                                          product.uuid,
                                                    )
                                                    .isNotEmpty) {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .useWholeSalePrice,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .quantity,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                } else {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          false,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          double.tryParse(
                                                            quantityController.text
                                                                .replaceAll(
                                                                  ',',
                                                                  '',
                                                                )
                                                                .trim(),
                                                          ) ??
                                                          0.0,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                }
                                              }
                                            },
                                            theme: theme,
                                            product:
                                                product,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return RefreshIndicator(
                                      onRefresh: () async {
                                        await returnData()
                                            .getProducts(
                                              returnShopProvider()
                                                  .userShop()!
                                                  .shopId!,
                                            );
                                        setState(() {});
                                      },
                                      backgroundColor:
                                          Colors.white,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      displacement: 15,
                                      child: ListView.builder(
                                        padding:
                                            EdgeInsets.only(
                                              top: 10,
                                            ),
                                        itemCount:
                                            returnData()
                                                .productList()
                                                .where(
                                                  (
                                                    product,
                                                  ) =>
                                                      product.name.toLowerCase().contains(
                                                        widget.searchController.text.toLowerCase(),
                                                      ) ||
                                                      (product.barcode !=
                                                              null &&
                                                          product.barcode!.toLowerCase().contains(
                                                            widget.searchController.text.toLowerCase(),
                                                          )),
                                                )
                                                .length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          final product =
                                              returnData()
                                                  .productList()
                                                  .where(
                                                    (
                                                      product,
                                                    ) =>
                                                        product.name.toLowerCase().contains(
                                                          widget.searchController.text.toLowerCase(),
                                                        ) ||
                                                        (product.barcode !=
                                                                null &&
                                                            product.barcode!.toLowerCase().contains(
                                                              widget.searchController.text.toLowerCase(),
                                                            )),
                                                  )
                                                  .toList()[index];
                                          return ProductTileCartSearch(
                                            action: () {
                                              if (!product
                                                  .isManaged) {
                                                if (returnSalesProvider()
                                                    .currentCart()
                                                    .cartItems
                                                    .where(
                                                      (
                                                        item,
                                                      ) =>
                                                          item.item.uuid! ==
                                                          product.uuid,
                                                    )
                                                    .isNotEmpty) {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .useWholeSalePrice,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .quantity,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                } else {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          false,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          double.tryParse(
                                                            quantityController.text
                                                                .replaceAll(
                                                                  ',',
                                                                  '',
                                                                )
                                                                .trim(),
                                                          ) ??
                                                          0.0,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                }
                                              } else {
                                                if (product
                                                        .quantity ==
                                                    0) {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      var theme = Provider.of<
                                                        ThemeProvider
                                                      >(
                                                        context,
                                                      );
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'Item Quantity is Zero, Therefore, this item cannot be sold',
                                                        title:
                                                            'Item out of Stock',
                                                      );
                                                    },
                                                  );
                                                } else if (returnSalesProvider()
                                                    .currentCart()
                                                    .cartItems
                                                    .where(
                                                      (
                                                        item,
                                                      ) =>
                                                          item.item.uuid! ==
                                                          product.uuid,
                                                    )
                                                    .isNotEmpty) {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .useWholeSalePrice,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          returnSalesProvider()
                                                              .currentCart()
                                                              .cartItems
                                                              .firstWhere(
                                                                (
                                                                  item,
                                                                ) =>
                                                                    item.item.uuid! ==
                                                                    product.uuid!,
                                                              )
                                                              .quantity,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                } else {
                                                  selectProduct(
                                                    theme:
                                                        theme,
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      useWholeSalePrice:
                                                          false,
                                                      addToStock:
                                                          false,
                                                      discount:
                                                          product.discount,
                                                      item:
                                                          product,
                                                      quantity:
                                                          double.tryParse(
                                                            quantityController.text
                                                                .replaceAll(
                                                                  ',',
                                                                  '',
                                                                )
                                                                .trim(),
                                                          ) ??
                                                          0.0,
                                                    ),
                                                    closeAction:
                                                        widget.close,
                                                    priceController:
                                                        priceController,
                                                  );
                                                }
                                              }
                                            },
                                            theme: theme,
                                            product:
                                                product,
                                          );
                                        },
                                      ),
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
  TextEditingController priceController,
) async {
  numberController.text = cartItem.quantity.toString();
  double qqty = cartItem.quantity.toDouble();
  cartItem.setCustomPrice
      ? priceController.text =
          cartItem.customPrice.toString()
      : priceController.text = "";
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
                                            'Total item quantity can\'t be exceeded',
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
                                        width: 60,
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
                                                    'Total item quantity can\'t be exceeded',
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
                                        width: 60,
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
                              text: 'Update Item',
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
              'Enter Item Quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  action: () async {
                    String result =
                        await returnSalesProvider()
                            .addItemToCart(
                              context: context,
                              newItem: cartItem,
                              isCustomEdit:
                                  returnData()
                                      .productList()
                                      .where(
                                        (product) =>
                                            product.uuid ==
                                            cartItem
                                                .item
                                                .uuid,
                                      )
                                      .isEmpty,
                            );
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

class CountryBottomSheet extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback close;
  final String currentSetting;
  // final List<String>? list;
  final Future future;
  const CountryBottomSheet({
    super.key,
    required this.searchController,
    required this.close,
    required this.future,
    required this.currentSetting,
  });

  @override
  State<CountryBottomSheet> createState() =>
      _CountryBottomSheetState();
}

class _CountryBottomSheetState
    extends State<CountryBottomSheet> {
  //
  //
  //

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
                            'Select Your ${widget.currentSetting}',
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                  ).mobileTexts.b1.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Search For ${widget.currentSetting} to Select',
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
                  child: GeneralTextfieldOnly(
                    hint:
                        'Search for ${widget.currentSetting.toLowerCase()} names',
                    lines: 1,
                    theme: theme,
                    controller: widget.searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: widget.future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Scaffold(
                          body: returnCompProvider(
                            context,
                            listen: false,
                          ).showLoader(message: 'Loading'),
                        );
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: EmptyWidgetDisplay(
                            title: 'An Error Occured',
                            subText:
                                'Please check your internet and try again.',
                            buttonText: 'Close',
                            theme: theme,
                            height: 30,
                            action: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icons.clear,
                            altAction: () async {
                              // await returnShopProvider()
                              //     .fetchShopCategories(
                              //       shopId(),
                              //     );
                            },
                            altActionText: 'Refresh',
                            altIcon: Icons.refresh,
                          ),
                        );
                      } else {
                        var items = snapshot.data!;
                        if (items.isEmpty) {
                          return Scaffold(
                            body: EmptyWidgetDisplay(
                              title: 'Empty List',
                              subText:
                                  'There are no results for this Location.',
                              buttonText: 'Close',
                              theme: theme,
                              height: 30,
                              action: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icons.clear,
                              altAction: () async {
                                await returnData()
                                    .getProducts(shopId());
                              },
                              altActionText: 'Refresh',
                              altIcon: Icons.refresh,
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              var item = items[index];
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
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(item),
                                    onTap: () {},
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
                                          returnTheme(
                                                context,
                                              )
                                              .lightModeColor
                                              .prColor250,
                                      value: true,
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ),
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
