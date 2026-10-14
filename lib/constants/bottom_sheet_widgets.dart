import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/buttons/toggle_total_price.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/on_screen_keyboard_pin.dart/on_screen_keyboard_pin.dart';
import 'package:stockall/components/pin_code_widget/my_pin_code_widget.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/constants/sales_docket_print_download.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/categories/categories_page.dart';
import 'package:stockall/pages/products/compnents/product_tile_cart_search.dart';
import 'package:stockall/pages/products/product_details/platforms/components/price_selection_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/right_bar_section.dart';
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
                      mouseCursor: SystemMouseCursors.click,
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
                      mouseCursor: SystemMouseCursors.click,
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
                              'Select Item Category(s)',
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
                          mouseCursor:
                              SystemMouseCursors.click,
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
                                              .selectCategories(
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
                                          value: returnData(
                                                context:
                                                    context,
                                              )
                                              .selectedCategories
                                              .contains(
                                                category
                                                    .uuid,
                                              ),
                                          onChanged: (
                                            value,
                                          ) {
                                            Provider.of<
                                              DataProvider
                                            >(
                                              context,
                                              listen: false,
                                            ).selectCategories(
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
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
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
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
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
                      mouseCursor: SystemMouseCursors.click,
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
                          mouseCursor:
                              SystemMouseCursors.click,
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

void selectProductSales({
  required bool isEdit,
  required ThemeProvider theme,
  required TempCartItem cartItemTemp,
  required Function() closeAction,
  required TextEditingController priceController,
  required TextEditingController quantityController,
  required TextEditingController searchController,
  required FocusNode qttyNode,
  required FocusNode priceNode,
  required BuildContext context,
  required bool useTempCart,
}) {
  bool isOnscreenKeyboardClicked = false;
  int currentFocus = 1;
  double qqty = 0;
  // bool useWholeSalePriceTemp = false;
  TempCartItem cartItem = cartItemTemp.copyWith();

  bool isPercentageWastage = false;
  // Unit fixed (#) wastage is entered in; null follows the sale
  // unit until one is picked.
  String? wastageUnitUuid;

  String? unitUuid;
  String? priceUuid;
  int quantityTypeTemp = 1;
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final wastageController = TextEditingController();
  final bool is2DItem = cartItem.item.quantityType == 2;
  final double? originalWidth =
      cartItem.item.widthDimension;
  final double? originalHeight =
      cartItem.item.heightDimension;
  bool isAreaUnit = false;

  double? parseDimension(TextEditingController controller) {
    return double.tryParse(
      controller.text.replaceAll(',', '').trim(),
    );
  }

  // Width/height used for this line: the entered value in
  // dimensions mode (original when left empty), the original
  // in whole mode, and null for non-2D items.
  double? resolvedWidth() {
    if (!is2DItem || isAreaUnit) return null;
    if (quantityTypeTemp == 2 &&
        widthController.text.trim().isNotEmpty) {
      return parseDimension(widthController);
    }
    return originalWidth;
  }

  double? resolvedHeight() {
    if (!is2DItem || isAreaUnit) return null;
    if (quantityTypeTemp == 2 &&
        heightController.text.trim().isNotEmpty) {
      return parseDimension(heightController);
    }
    return originalHeight;
  }

  // Returns an error message, or null when the entered
  // dimensions are valid.
  String? checkDimension(
    TextEditingController controller,
    String label,
    double? original,
  ) {
    if (controller.text.trim().isEmpty) {
      return original == null
          ? '$label is required for this item.'
          : null;
    }
    final value = parseDimension(controller);
    if (value == null || value <= 0) {
      return '$label must be a number greater than 0.';
    }
    if (original != null && value > original) {
      return '$label cannot be larger than the item\'s $label (${formatDimension(original)}).';
    }
    return null;
  }

  String? dimensionsError() {
    if (!is2DItem || isAreaUnit || quantityTypeTemp != 2) {
      return null;
    }
    return checkDimension(
          widthController,
          'Width',
          originalWidth,
        ) ??
        checkDimension(
          heightController,
          'Height',
          originalHeight,
        );
  }

  // Wastage is entered for 2D items that manage it, except in
  // order carts (orders don't apply wastage).
  bool showWastage() {
    return is2DItem &&
        cartItem.item.manageSalesWastage == true &&
        returnSalesProvider()
                .currentCart()
                .cartItemTypeIndex !=
            3;
  }

  // Unit the wastage is saved with: the picked unit, else the
  // sale unit. % wastage is a share of the sale quantity, so it
  // always takes the sale unit.
  String? selectedWastageUnit() {
    if (isPercentageWastage) return unitUuid;
    return wastageUnitUuid ?? unitUuid;
  }

  // Name of the item's base area unit, for stock messages.
  String areaUnitLabel() {
    final areaUnits = cartItem.getUnitsList().where(
      (item) =>
          item.dimensionType ==
              ProductUnitsClass.areaUnit &&
          item.conversion == 1,
    );
    return areaUnits.isNotEmpty
        ? areaUnits.first.name
        : 'sq. units';
  }

  String? wastageError() {
    if (!showWastage() ||
        wastageController.text.trim().isEmpty) {
      return null;
    }
    final value = double.tryParse(
      wastageController.text.replaceAll(',', '').trim(),
    );
    if (value == null || value < 0) {
      return 'Wastage must be a number of 0 or more.';
    }
    if (isPercentageWastage && value > 100) {
      return 'Wastage percent cannot be more than 100.';
    }
    return null;
  }

  void selectUnit(String unit) {
    unitUuid = unit;
  }

  List<ProductUnitsClass> tempUnitList =
      cartItem.getUnitListFinal();

  ProductUnitsClass getPrimaryUnit() {
    var items = tempUnitList.where(
      (item) => item.uuid == unitUuid,
    );
    if (items.isEmpty) {
      var items = tempUnitList.where(
        (item) => item.isPrimary,
      );
      if (items.isNotEmpty) {
        return items.first;
      } else {
        return ProductUnitsClass(
          uuid: uuidGen(),
          staffUuid: currentUser().userId,
          createdAt: DateTime.now(),
          staffName: currentUser().name,
          conversion: 1,
          name:
              cartItem.item.unit == 'Others'
                  ? 'Unit(s)'
                  : cartItem.item.unit,
          isPrimary: true,
          productUuid: cartItem.item.uuid!,
        );
      }
    } else {
      return items.first;
    }
  }

  unitUuid = cartItem.unitUuid ?? getPrimaryUnit().uuid;
  isAreaUnit =
      is2DItem &&
      getPrimaryUnit().dimensionType ==
          ProductUnitsClass.areaUnit;

  // Editing a line sold at a custom size reopens it in
  // dimensions mode with the values filled in.
  if (is2DItem &&
      !isAreaUnit &&
      cartItem.widthDimension != null &&
      cartItem.heightDimension != null &&
      (cartItem.widthDimension != originalWidth ||
          cartItem.heightDimension != originalHeight)) {
    quantityTypeTemp = 2;
    widthController.text = formatDimension(
      cartItem.widthDimension!,
    ).replaceAll(',', '');
    heightController.text = formatDimension(
      cartItem.heightDimension!,
    ).replaceAll(',', '');
  }

  double getPrimaryUnitQuantityMultiplied({
    BuildContext? context,
    double? newQuantity,
  }) {
    return getPrimaryUnit().getQuantityEquivMultiplied(
      index: 1,
      context: context,
      product: cartItem.item,
      newQuantity: newQuantity,
      customWidth: resolvedWidth(),
      customHeight: resolvedHeight(),
    );
  }

  double existingQtty = getPrimaryUnit()
      .getQuantityEquivMultiplied(
        index: 1,
        product: cartItem.item,
        newQuantity: cartItem.quantity,
        customWidth: cartItem.widthDimension,
        customHeight: cartItem.heightDimension,
      );
  void setUnitListFinal() {
    cartItem.getItem()?.unitsList?.clear();
    cartItem.getItem()?.unitsList?.addAll(
      tempUnitList.map((item) => item.copyWith()).toList(),
    );
    // print(cartItem.getSelectedUnit().name);
    cartItem.unitUuid = unitUuid;
    if (showWastage()) {
      cartItem.wastageAmount = double.tryParse(
        wastageController.text.replaceAll(',', ''),
      );
      cartItem.isPercentageWastage = isPercentageWastage;
      cartItem.wastageUnitUuid = selectedWastageUnit();
      cartItem.manageSalesWastage = true;
    }
    // print(cartItem.getSelectedUnit().name);
  }

  //
  //
  //
  //
  //

  void selectPrice(String price) {
    priceUuid = price;
  }

  List<ProductPricesClass> tempPriceList =
      cartItem.getPriceListFinal();

  ProductPricesClass getPrimaryPrice() {
    var items = tempPriceList.where(
      (item) => item.uuid == priceUuid,
    );
    if (items.isEmpty) {
      var items = tempPriceList.where(
        (item) => item.isPrimary,
      );
      if (items.isNotEmpty) {
        return items.first;
      } else {
        return ProductPricesClass(
          priceType: 1,
          uuid: uuidGen(),
          staffUuid: currentUser().userId,
          createdAt: DateTime.now(),
          staffName: currentUser().name,
          priceValue: cartItem.item.sellingPrice ?? 0,
          name: 'Price',
          isPrimary: true,
          itemUuid: cartItem.item.uuid!,
        );
      }
    } else {
      return items.first;
    }
  }

  priceUuid = cartItem.priceUuid ?? getPrimaryPrice().uuid;

  double getCurrentSellingPrice() {
    var tempPrice = getPrimaryPrice().priceValue;
    var tempQty =
        is2DItem && !isAreaUnit
            ? getPrimaryUnit().conversion *
                cartItem.item.dimensionArea()
            : getPrimaryUnit().conversion;
    return tempPrice * tempQty;
  }

  void setPriceListFinal() {
    cartItem.getItem()?.pricesList?.clear();
    cartItem.getItem()?.pricesList?.addAll(
      tempPriceList.map((item) => item.copyWith()).toList(),
    );
    // print(cartItem.getSelectedUnit().name);
    cartItem.priceUuid = priceUuid;
    if (priceController.text.isNotEmpty) {
      cartItem.setCustomPrice = true;
    } else {
      cartItem.setCustomPrice = false;
    }
    // print(cartItem.getSelectedUnit().name);
  }

  //
  //
  //
  //
  //

  if (isEdit) {
    // useWholeSalePriceTemp = cartItem.useWholeSalePrice;
    isPercentageWastage =
        cartItemTemp.isPercentageWastage ?? false;
    wastageController.text =
        cartItem.wastageAmount?.toString() ?? '';
    // Reopen in the unit the wastage was entered in. Older lines
    // kept a fixed amount in area: show it in the item's area
    // unit, or converted to the sale unit if there is none.
    if (cartItem.wastageUnitUuid != null) {
      wastageUnitUuid = cartItem.wastageUnitUuid;
    } else if (!isPercentageWastage &&
        cartItem.wastageAmount != null) {
      final areaUnit =
          tempUnitList
              .where(
                (unit) =>
                    unit.dimensionType ==
                        ProductUnitsClass.areaUnit &&
                    unit.conversion == 1,
              )
              .firstOrNull;
      if (areaUnit != null) {
        wastageUnitUuid = areaUnit.uuid;
      } else {
        final areaPerSaleUnit =
            cartItem
                .copyWith(wastageUnitUuid: unitUuid)
                .wastageAreaPerUnit();
        if (areaPerSaleUnit > 0) {
          wastageController.text = formatDimension(
            cartItem.wastageAmount! / areaPerSaleUnit,
          ).replaceAll(',', '');
        }
        wastageUnitUuid = unitUuid;
      }
    }
    qttyNode.requestFocus();
    quantityController.text = cartItem.quantity.toString();
    qqty = cartItem.quantity.toDouble();
    if (cartItem.setCustomPrice) {
      priceController.text =
          cartItem.customPrice.toString();
      returnSalesProvider().toggleSetCustomPrice();
    } else {
      priceController.text = "";
    }

    returnSalesProvider().toggleSetTotalPrice(
      cartItem.setTotalPrice,
    );
  }
  qttyNode.requestFocus();

  // The line as it will be added, from the values entered so
  // far. The price preview, stock check and wastage message all
  // read it, so they match the cart line.
  TempCartItem previewLine() {
    return cartItem.previewWith(
          quantity: qqty,
          unitUuid: unitUuid,
          priceUuid: priceUuid,
          units: tempUnitList,
          prices: tempPriceList,
          width: resolvedWidth(),
          height: resolvedHeight(),
          customPrice:
              priceController.text.isNotEmpty
                  ? double.tryParse(
                    priceController.text.replaceAll(
                      ',',
                      '',
                    ),
                  )
                  : null,
          setTotalPrice:
              returnSalesProvider().setTotalPrice,
          wastageAmount:
              showWastage()
                  ? double.tryParse(
                    wastageController.text
                        .replaceAll(',', '')
                        .trim(),
                  )
                  : cartItem.wastageAmount,
          isPercentageWastage:
              showWastage()
                  ? isPercentageWastage
                  : cartItem.isPercentageWastage,
          wastageUnitUuid:
              showWastage()
                  ? selectedWastageUnit()
                  : cartItem.wastageUnitUuid,
        );
  }

  // Quantity taken from stock and billed: area + wastage.
  double billedQuantity() => previewLine().getStockQuantity();

  // Priced by the same totalCost() the cart line will use.
  String formatSellingPrice(TempCartItem cartItem) {
    return previewLine().totalCost().toString();
  }

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
                child: SizedBox(
                  width:
                      screenWidth(context) >
                              tabletScreenSmall
                          ? screenWidth(context) * 0.7
                          : screenWidth(context) * 0.85,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            EditCartTextField(
                              onTap: () {
                                setState(() {
                                  currentFocus = 1;
                                  isOnscreenKeyboardClicked =
                                      false;
                                });
                              },
                              focusNode: qttyNode,
                              onChanged: (value) {
                                double entered =
                                    getPrimaryUnitQuantityMultiplied(
                                      newQuantity:
                                          double.tryParse(
                                            value
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0,
                                    );
                                if (cartItem
                                        .getItem()
                                        ?.isManaged ??
                                    false) {
                                  // In custom dimensions mode, do not prematurely wipe out
                                  // quantity while custom width/height are still being entered.
                                  // Final check is performed when adding to cart.
                                  if (quantityTypeTemp !=
                                          2 &&
                                      !returnSalesProvider()
                                          .canAddProductToCart(
                                            isEdit: isEdit,
                                            newCartItem:
                                                cartItem,
                                            quantityToAdd:
                                                entered,
                                            // useGroupUnit:
                                            //     useGroupQuantityTemp,
                                          )) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => InfoAlert(
                                            title:
                                                "Quantity Limit Reached",
                                            message:
                                                "Only ${getPrimaryUnit().getQuantityEquivDivided(index: 1, newQuantity: returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem, isEdit: isEdit), product: cartItem.item)} ${getPrimaryUnit().name} available in stock.",
                                            theme: theme,
                                          ),
                                    ).then((_) {
                                      qttyNode
                                          .requestFocus();
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
                                    quantityController
                                        .text = '0';
                                  });
                                }

                                setState(() {
                                  qqty =
                                      (double.tryParse(
                                            value
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0);
                                });
                              },

                              title: 'Enter Item Quantity',
                              hint: 'Quantity',
                              controller:
                                  quantityController,
                              theme: theme,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 10.0,
                                  ),
                              child: Builder(
                                builder: (context) {
                                  if (quantityTypeTemp ==
                                      1) {
                                    return Container();
                                  } else {
                                    return Row(
                                      spacing: 10,
                                      children: [
                                        Expanded(
                                          child: EditCartTextField(
                                            onTap: () {
                                              setState(() {
                                                currentFocus =
                                                    3;
                                                isOnscreenKeyboardClicked =
                                                    false;
                                              });
                                            },
                                            // Empty uses the item's
                                            // original width.
                                            onChanged: (
                                              value,
                                            ) {
                                              setState(() {
                                                if ((double.tryParse(
                                                          widthController.text.replaceAll(
                                                            ',',
                                                            '',
                                                          ),
                                                        ) ??
                                                        0) >
                                                    (originalWidth ??
                                                        0)) {
                                                  widthController
                                                          .text =
                                                      '0';
                                                }
                                              });
                                            },
                                            title:
                                                '${getPrimaryUnit().name} Width',
                                            hint:
                                                originalWidth !=
                                                        null
                                                    ? 'Max ${formatDimension(originalWidth)}'
                                                    : 'Enter Width',
                                            controller:
                                                widthController,
                                            theme: theme,
                                          ),
                                        ),
                                        Expanded(
                                          child: EditCartTextField(
                                            onTap: () {
                                              setState(() {
                                                currentFocus =
                                                    4;
                                                isOnscreenKeyboardClicked =
                                                    false;
                                              });
                                            },
                                            // Empty uses the item's
                                            // original height.
                                            onChanged: (
                                              value,
                                            ) {
                                              setState(() {
                                                if ((double.tryParse(
                                                          heightController.text.replaceAll(
                                                            ',',
                                                            '',
                                                          ),
                                                        ) ??
                                                        0) >
                                                    (originalHeight ??
                                                        0)) {
                                                  heightController
                                                          .text =
                                                      '0';
                                                }
                                              });
                                            },
                                            title:
                                                '${getPrimaryUnit().name} Height',
                                            hint:
                                                originalHeight !=
                                                        null
                                                    ? 'Max ${formatDimension(originalHeight)}'
                                                    : 'Enter Height',
                                            controller:
                                                heightController,
                                            theme: theme,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 15),
                            Visibility(
                              visible:
                                  cartItemTemp
                                          .item
                                          .quantityType ==
                                      2 &&
                                  !isAreaUnit,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                spacing: 5,
                                children: [
                                  Material(
                                    color:
                                        Colors.transparent,
                                    child: InkWell(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onTap: () {
                                        setState(() {
                                          quantityTypeTemp =
                                              1;
                                          widthController
                                              .clear();
                                          heightController
                                              .clear();
                                        });
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                        child: Row(
                                          spacing: 6,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      quantityTypeTemp !=
                                                              1
                                                          ? Colors.grey
                                                          : Colors.transparent,
                                                ),
                                                color:
                                                    quantityTypeTemp ==
                                                            1
                                                        ? theme.lightModeColor.prColor250
                                                        : Colors.transparent,
                                                shape:
                                                    BoxShape
                                                        .circle,
                                              ),
                                              child: Icon(
                                                size: 14,
                                                color:
                                                    Colors
                                                        .white,
                                                Icons.check,
                                              ),
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Enter Whole',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color:
                                        Colors.transparent,
                                    child: InkWell(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onTap: () {
                                        setState(() {
                                          quantityTypeTemp =
                                              2;
                                          // quantityController
                                          //     .clear();
                                        });
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 6,
                                            ),
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      quantityTypeTemp !=
                                                              2
                                                          ? Colors.grey
                                                          : Colors.transparent,
                                                ),
                                                color:
                                                    quantityTypeTemp ==
                                                            2
                                                        ? theme.lightModeColor.prColor250
                                                        : Colors.transparent,
                                                shape:
                                                    BoxShape
                                                        .circle,
                                              ),
                                              child: Icon(
                                                size: 14,
                                                color:
                                                    Colors
                                                        .white,
                                                Icons.check,
                                              ),
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Enter Dimensions',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            UnitSelectionWidget(
                              unitList: tempUnitList,
                              product: null,
                              storageProduct: null,
                              productionItem: null,
                              material: null,
                              theme: theme,
                              unitUuid:
                                  getPrimaryUnit().uuid,
                              setUnitUuid: (d) {
                                setState(() {
                                  selectUnit(d ?? '');
                                  isAreaUnit =
                                      is2DItem &&
                                      getPrimaryUnit()
                                              .dimensionType ==
                                          ProductUnitsClass
                                              .areaUnit;
                                  if (isAreaUnit) {
                                    quantityTypeTemp = 1;
                                    widthController.clear();
                                    heightController
                                        .clear();
                                  }
                                });
                                if (getPrimaryUnitQuantityMultiplied(
                                      newQuantity:
                                          (double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0),
                                    ) >
                                    (cartItemTemp.item
                                            .getActualQuantity() ??
                                        0)) {
                                  quantityController.text =
                                      '0';
                                  qqty = 0;
                                }
                              },
                            ),

                            Visibility(
                              visible:
                                  cartItemTemp
                                          .getPrimaryPrice()
                                          .priceValue !=
                                      0 &&
                                  priceController
                                      .text
                                      .isEmpty &&
                                  !returnSalesProviderContext(
                                    context,
                                  ).isSetCustomPrice() &&
                                  authorization(
                                    authorized:
                                        Authorizations()
                                            .selectMultiplePriceDuringSales,
                                  ),
                              child: PriceSelectionWidget(
                                priceList: tempPriceList,
                                // product: cartItem.item,
                                conversion:
                                    is2DItem && !isAreaUnit
                                        ? getPrimaryUnit()
                                                .conversion *
                                            cartItem.item
                                                .dimensionArea()
                                        : getPrimaryUnit()
                                            .conversion,
                                theme: theme,
                                priceUuid:
                                    getPrimaryPrice().uuid,
                                setPriceUuid: (d) {
                                  setState(() {
                                    selectPrice(d ?? '');
                                  });
                                },
                              ),
                            ),
                            Visibility(
                              visible:
                                  cartItem
                                              .getItem()
                                              ?.getPrimaryPrice()
                                              .priceValue ==
                                          0
                                      ? true
                                      : returnSalesProviderContext(
                                            context,
                                          ).isSetCustomPrice() &&
                                          (cartItem
                                                  .getItem()
                                                  ?.setCustomPrice ??
                                              false),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,
                                    children: [
                                      Expanded(
                                        child:
                                            ToggleTotalPriceWidget(
                                              theme: theme,
                                            ),
                                      ),
                                      Expanded(
                                        child: MoneyTextfield(
                                          onTap: () async {
                                            setState(() {
                                              currentFocus =
                                                  2;
                                            });
                                          },
                                          focusNode:
                                              priceNode,
                                          title:
                                              returnSalesProviderContext(
                                                    context,
                                                  ).setTotalPrice
                                                  ? 'Total Price'
                                                  : 'Individual Price',
                                          hint:
                                              'Enter Price',
                                          controller:
                                              priceController,
                                          theme: theme,
                                          onChanged: (
                                            value,
                                          ) {
                                            // if (value
                                            //     .isNotEmpty) {
                                            //   cartItem.setCustomPrice =
                                            //       true;
                                            // } else {
                                            //   cartItem.setCustomPrice =
                                            //       false;
                                            // }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Visibility(
                              visible:
                                  (cartItem
                                          .getItem()
                                          ?.setCustomPrice ??
                                      false) &&
                                  authorization(
                                    authorized:
                                        Authorizations()
                                            .setCustomPriceDuringSales,
                                  ),
                              child: Column(
                                children: [
                                  InkWell(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onTap: () {
                                      returnSalesProvider()
                                          .toggleSetCustomPrice();
                                      priceController
                                          .clear();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
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
                                                  FontWeight
                                                      .bold,
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
                                                child: SvgPicture.asset(
                                                  color:
                                                      theme
                                                          .lightModeColor
                                                          .secColor200,
                                                  editIconSvg,
                                                  height:
                                                      20,
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    returnSalesProviderContext(
                                                      context,
                                                    ).isSetCustomPrice() ==
                                                    true,
                                                child: Icon(
                                                  color:
                                                      theme
                                                          .lightModeColor
                                                          .secColor200,
                                                  Icons
                                                      .clear,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              margin: EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: Visibility(
                                visible: showWastage(),
                                child: SizedBox(
                                  height: 38,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: EditCartTextField(
                                          discount:
                                              isPercentageWastage,
                                          showTitle: false,
                                          onTap: () {
                                            setState(() {
                                              isOnscreenKeyboardClicked =
                                                  false;
                                            });
                                          },
                                          // focusNode: qttyNode,
                                          onChanged: (
                                            value,
                                          ) {
                                            setState(() {});
                                          },

                                          title: '',
                                          hint:
                                              'Enter Wastage ${isPercentageWastage ? 'Percent' : 'Amount'}',
                                          controller:
                                              wastageController,
                                          theme: theme,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                        spacing: 5,
                                        children: [
                                          WastageTypeButton(
                                            myBoolValue:
                                                true,
                                            isPercentageWastage:
                                                isPercentageWastage,
                                            symbol: '%',
                                            toggleIsPercentageWastage: () {
                                              setState(() {
                                                isPercentageWastage =
                                                    true;
                                                wastageController
                                                    .clear();
                                              });
                                            },
                                          ),
                                          WastageTypeButton(
                                            myBoolValue:
                                                false,
                                            isPercentageWastage:
                                                isPercentageWastage,
                                            symbol: '#',
                                            toggleIsPercentageWastage: () {
                                              setState(() {
                                                isPercentageWastage =
                                                    false;
                                                wastageController
                                                    .clear();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // A fixed amount can be entered in any
                            // of the item's units.
                            Visibility(
                              visible:
                                  showWastage() &&
                                  !isPercentageWastage,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: Column(
                                  spacing: 5,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Wastage Unit:',
                                    ),
                                    UnitSelectionWidget(
                                      unitList: tempUnitList,
                                      product: null,
                                      storageProduct: null,
                                      productionItem: null,
                                      material: null,
                                      theme: theme,
                                      showSelectUnitText: false,
                                      unitUuid:
                                          selectedWastageUnit(),
                                      setUnitUuid: (d) {
                                        setState(() {
                                          wastageUnitUuid = d;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                color: Colors.grey.shade100,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
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
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                spacing: 15,
                                children: [
                                  Ink(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      color:
                                          Colors
                                              .grey
                                              .shade100,
                                    ),
                                    child: InkWell(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      onTap: () {
                                        setState(() {
                                          if (qqty > 0) {
                                            qqty--;
                                            quantityController
                                                    .text =
                                                qqty.toString();
                                            isOnscreenKeyboardClicked =
                                                false;
                                          }
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
                                  Text(
                                    formatLargeNumberDouble(
                                      qqty,
                                    ),
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
                                  Ink(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      color:
                                          Colors
                                              .grey
                                              .shade100,
                                    ),
                                    child: InkWell(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      onTap: () {
                                        setState(() {
                                          qqty++;
                                          quantityController
                                                  .text =
                                              qqty.toString();
                                          isOnscreenKeyboardClicked =
                                              false;
                                        });
                                        double entered =
                                            double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ) ??
                                            0;
                                        if (cartItem
                                                .getItem()
                                                ?.isManaged ??
                                            false) {
                                          if (!returnSalesProvider().canAddProductToCart(
                                            isEdit: isEdit,
                                            newCartItem:
                                                cartItem,
                                            quantityToAdd:
                                                getPrimaryUnitQuantityMultiplied(
                                                  newQuantity:
                                                      entered,
                                                ),
                                            // useGroupUnit:
                                            //     useGroupQuantityTemp,
                                          )) {
                                            showDialog(
                                              context:
                                                  context,
                                              builder:
                                                  (
                                                    _,
                                                  ) => InfoAlert(
                                                    title:
                                                        "Quantity Limit Reached",
                                                    message:
                                                        "Only ${getPrimaryUnit().getQuantityEquivDivided(index: 1, newQuantity: returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem, isEdit: isEdit), product: cartItem.item)} ${getPrimaryUnit().name} available in stock.",
                                                    theme:
                                                        theme,
                                                  ),
                                            ).then((_) {
                                              qttyNode
                                                  .requestFocus();
                                            });

                                            Future.delayed(
                                              Duration(
                                                milliseconds:
                                                    300,
                                              ),
                                              () {
                                                setState(() {
                                                  qqty = 0;
                                                  quantityController
                                                          .text =
                                                      '0';
                                                });
                                              },
                                            );

                                            return;
                                          }
                                        }

                                        if (quantityController
                                            .text
                                            .isEmpty) {
                                          setState(() {
                                            quantityController
                                                .text = '0';
                                          });
                                        }

                                        setState(() {
                                          qqty = entered;
                                        });
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
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                    quantityController
                                        .clear();
                                    qqty = 0;
                                  },
                                  child: Text('Cancel'),
                                ),
                                SmallButtonMain(
                                  theme: theme,
                                  action: () async {
                                    if (cartItem
                                                .getItem()
                                                ?.getPrimaryPrice()
                                                .priceValue ==
                                            0 &&
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
                                    } else if (priceController
                                            .text
                                            .isNotEmpty &&
                                        !authorization(
                                              authorized:
                                                  Authorizations()
                                                      .sellBelowLowestSellingPrice,
                                            ) &
                                            (getCurrentSellingPrice() >
                                                (double.tryParse(
                                                      priceController.text.replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                    ) ??
                                                    0))) {
                                      showDialog(
                                        context: context,
                                        builder: (
                                          errorContext,
                                        ) {
                                          return InfoAlert(
                                            theme: theme,
                                            message:
                                                'You are not allowed to Sell This Item below the Currently Selected Selling Price (${getCurrentSellingPrice()}). Please Adjust Custom Price.',
                                            title:
                                                'Custom Price Not Allowed',
                                          );
                                        },
                                      );
                                    } else {
                                      if (quantityController
                                              .text
                                              .isEmpty ||
                                          qqty == 0) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Item quantity cannot be set to (0)',
                                              title:
                                                  'Invalid Quantity',
                                            );
                                          },
                                        );
                                      } else if (dimensionsError() !=
                                          null) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  dimensionsError()!,
                                              title:
                                                  'Invalid Dimensions',
                                            );
                                          },
                                        );
                                      } else if (wastageError() !=
                                          null) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  wastageError()!,
                                              title:
                                                  'Invalid Wastage',
                                            );
                                          },
                                        );
                                      } else if (is2DItem &&
                                          (cartItem
                                                  .getItem()
                                                  ?.isManaged ??
                                              false) &&
                                          !returnSalesProvider()
                                              .canAddProductToCart(
                                                isEdit:
                                                    isEdit,
                                                newCartItem:
                                                    cartItem,
                                                quantityToAdd:
                                                    billedQuantity(),
                                              )) {
                                        // Dimensions and wastage can
                                        // change after the quantity
                                        // was checked.
                                        final preview =
                                            previewLine();
                                        final cutArea =
                                            preview
                                                .getRealQuantity();
                                        final wastage =
                                            preview
                                                .wastageArea();
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              title:
                                                  'Quantity Limit Reached',
                                              message:
                                                  wastage >
                                                          0
                                                      ? wastageStockMessage(
                                                        cutArea:
                                                            cutArea,
                                                        wastageArea:
                                                            wastage,
                                                        availableArea: returnSalesProvider().remainingQttyInAllCarts(
                                                          newCartItem:
                                                              cartItem,
                                                          isEdit:
                                                              isEdit,
                                                        ),
                                                        unit:
                                                            areaUnitLabel(),
                                                      )
                                                      : "Only ${getPrimaryUnit().getQuantityEquivDivided(index: 1, newQuantity: returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem, isEdit: isEdit), product: cartItem.item)} ${getPrimaryUnit().name} available in stock.",
                                            );
                                          },
                                        );
                                      } else {
                                        setUnitListFinal();
                                        setPriceListFinal();
                                        cartItem.widthDimension =
                                            resolvedWidth();
                                        cartItem.heightDimension =
                                            resolvedHeight();
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
                                          // cartItem.setCustomPrice =
                                          //     true;
                                        } else {
                                          // cartItem.setCustomPrice =
                                          //     false;
                                        }
                                        double getQtty() {
                                          return getPrimaryUnitQuantityMultiplied(
                                            newQuantity:
                                                qqty,
                                          );
                                        }

                                        if (isEdit) {
                                          if (returnShopProvider()
                                                      .userShop()
                                                      ?.trackCart ==
                                                  true &&
                                              existingQtty >
                                                  getQtty()) {
                                            var res =
                                                await pinCodeAction(
                                                  context:
                                                      context,
                                                  isMain:
                                                      false,
                                                );
                                            if (res) {
                                              cartItem.useGroupQuantity =
                                                  true;

                                              returnSalesProvider().editCartItemQuantity(
                                                setTotalPrice:
                                                    returnSalesProvider()
                                                        .setTotalPrice,
                                                cartItem:
                                                    cartItem,
                                                number: double.parse(
                                                  quantityController
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ),
                                                customPrice: double.tryParse(
                                                  priceController
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ),
                                                setCustomPrice:
                                                    priceController
                                                        .text
                                                        .isNotEmpty,
                                              );
                                              Navigator.of(
                                                context,
                                              ).pop();
                                            }
                                          } else {
                                            cartItem.useGroupQuantity =
                                                true;
                                            returnSalesProvider().editCartItemQuantity(
                                              setTotalPrice:
                                                  returnSalesProvider()
                                                      .setTotalPrice,
                                              cartItem:
                                                  cartItem,
                                              number: double.parse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ),
                                              customPrice: double.tryParse(
                                                priceController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ),
                                              setCustomPrice:
                                                  priceController
                                                      .text
                                                      .isNotEmpty,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          }
                                        } else {
                                          cartItem.setTotalPrice =
                                              returnSalesProvider()
                                                  .setTotalPrice;
                                          cartItem.quantity =
                                              qqty.toDouble();
                                          if (returnSalesProvider()
                                                  .isAddMultipleItemsToCart &&
                                              useTempCart ==
                                                  true) {
                                            cartItem.useGroupQuantity =
                                                true;
                                            returnSalesProvider()
                                                .addItemToTempCart(
                                                  item:
                                                      cartItem,
                                                );
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          } else {
                                            if (returnShopProvider()
                                                        .userShop()
                                                        ?.printSalesDocket ==
                                                    true &&
                                                returnCompProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).getContinuousPrintDocket() &&
                                                screenWidth(
                                                      context,
                                                    ) >
                                                    tabletScreenSmall) {
                                              var tempCartItem =
                                                  cartItem.copyWith(
                                                    quantity:
                                                        qqty.toDouble(),
                                                  );

                                              var res =
                                                  kIsWeb
                                                      ? await downloadDocket(
                                                        setTotal:
                                                            false,
                                                        items: [
                                                          tempCartItem,
                                                        ],
                                                        cart:
                                                            returnSalesProvider().currentCart(),
                                                        // ignore: use_build_context_synchronously
                                                        context:
                                                            context,
                                                        fileName:
                                                            'Docket Slip${DateTime.now().microsecondsSinceEpoch.toString().substring(0, 5)}',
                                                        waiter:
                                                            returnSalesProvider().currentMainCart().subStaff?.staffName ??
                                                            'Not Set',
                                                      )
                                                      : await printDocket(
                                                        setTotal:
                                                            false,
                                                        items: [
                                                          tempCartItem,
                                                        ],
                                                        cart:
                                                            returnSalesProvider().currentCart(),
                                                        // ignore: use_build_context_synchronously
                                                        context:
                                                            context,
                                                        fileName:
                                                            'Docket Slip${DateTime.now().microsecondsSinceEpoch.toString().substring(0, 5)}',
                                                        waiter:
                                                            returnSalesProvider().currentMainCart().subStaff?.staffName ??
                                                            'Not Set',
                                                      );
                                              if (res) {
                                                cartItem.useGroupQuantity =
                                                    true;
                                                returnSalesProvider().addItemToCart(
                                                  // isEdit:
                                                  //     isEdit,
                                                  // ignore: use_build_context_synchronously
                                                  context:
                                                      context,
                                                  newItem:
                                                      cartItem,
                                                  isCustomEdit:
                                                      returnData()
                                                          .productList()
                                                          .where(
                                                            (
                                                              product,
                                                            ) =>
                                                                product.uuid ==
                                                                cartItem.getItem()?.uuid,
                                                          )
                                                          .isEmpty,
                                                );
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                                closeAction();
                                              }
                                            } else {
                                              cartItem.useGroupQuantity =
                                                  true;
                                              returnSalesProvider().addItemToCart(
                                                // isEdit:
                                                //     isEdit,
                                                // ignore: use_build_context_synchronously
                                                context:
                                                    context,
                                                newItem:
                                                    cartItem,
                                                isCustomEdit:
                                                    returnData()
                                                        .productList()
                                                        .where(
                                                          (
                                                            product,
                                                          ) =>
                                                              product.uuid ==
                                                              cartItem.getItem()?.uuid,
                                                        )
                                                        .isEmpty,
                                              );
                                              Navigator.of(
                                                context,
                                              ).pop();
                                              closeAction();
                                            }
                                          }
                                        }
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
                      Visibility(
                        visible:
                            screenWidth(context) >
                            tabletScreenSmall,
                        child: Expanded(
                          child: Row(
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                color: Colors.grey.shade400,
                                width: 1,
                                height: 400,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(
                                    15,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                          10,
                                        ),
                                    color: Colors.white,
                                  ),
                                  child: OnScreenKeyboardPin(
                                    action: (value) {
                                      TextEditingController
                                      currentController() {
                                        switch (currentFocus) {
                                          case 1:
                                            return quantityController;
                                          case 2:
                                            return priceController;
                                          case 3:
                                            return widthController;
                                          case 4:
                                            return heightController;
                                          default:
                                            return quantityController;
                                        }
                                      }

                                      void addDigit(
                                        String digit,
                                        TextEditingController
                                        controller,
                                      ) {
                                        if (currentFocus ==
                                            1) {
                                          if (isOnscreenKeyboardClicked ==
                                              false) {
                                            controller
                                                    .text =
                                                digit;
                                            isOnscreenKeyboardClicked =
                                                true;
                                          } else {
                                            controller
                                                    .text +=
                                                digit;
                                          }
                                          double
                                          entered = getPrimaryUnitQuantityMultiplied(
                                            newQuantity:
                                                double.tryParse(
                                                  controller
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ) ??
                                                0,
                                          );
                                          if (cartItem
                                                  .getItem()
                                                  ?.isManaged ??
                                              false) {
                                            if (quantityTypeTemp !=
                                                    2 &&
                                                !returnSalesProvider().canAddProductToCart(
                                                  isEdit:
                                                      isEdit,
                                                  newCartItem:
                                                      cartItem,
                                                  quantityToAdd:
                                                      entered,
                                                  // useGroupUnit:
                                                  //     useGroupQuantityTemp,
                                                )) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder:
                                                    (
                                                      _,
                                                    ) => InfoAlert(
                                                      title:
                                                          "Quantity Limit Reached",
                                                      message:
                                                          "Only ${getPrimaryUnit().getQuantityEquivDivided(index: 1, newQuantity: returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem, isEdit: isEdit), product: cartItem.item)} ${getPrimaryUnit().name} available in stock.",
                                                      theme:
                                                          theme,
                                                    ),
                                              ).then((_) {
                                                qttyNode
                                                    .requestFocus();
                                              });

                                              Future.delayed(
                                                Duration(
                                                  milliseconds:
                                                      100,
                                                ),
                                                () {
                                                  setState(() {
                                                    qqty =
                                                        0;
                                                    quantityController.text =
                                                        '0';
                                                  });
                                                },
                                              );

                                              return;
                                            } else {
                                              if (controller
                                                  .text
                                                  .isEmpty) {
                                                setState(() {
                                                  quantityController
                                                          .text =
                                                      '0';
                                                });
                                              }

                                              // controller
                                              //         .text +=
                                              //     digit;
                                              double
                                              newVal =
                                                  double.tryParse(
                                                    controller
                                                        .text,
                                                  ) ??
                                                  0;
                                              setState(() {
                                                qqty =
                                                    newVal;
                                              });
                                              controller
                                                  .selection = TextSelection.fromPosition(
                                                TextPosition(
                                                  offset:
                                                      controller
                                                          .text
                                                          .length,
                                                ),
                                              );
                                            }
                                          } else {
                                            if (controller
                                                .text
                                                .isEmpty) {
                                              setState(() {
                                                quantityController
                                                        .text =
                                                    '0';
                                              });
                                            }

                                            // controller
                                            //         .text +=
                                            //     digit;
                                            double newVal =
                                                double.tryParse(
                                                  controller
                                                      .text,
                                                ) ??
                                                0;
                                            setState(() {
                                              qqty = newVal;
                                            });

                                            controller
                                                .selection = TextSelection.fromPosition(
                                              TextPosition(
                                                offset:
                                                    controller
                                                        .text
                                                        .length,
                                              ),
                                            );
                                          }
                                        } else if (currentFocus ==
                                                3 ||
                                            currentFocus ==
                                                4) {
                                          if (isOnscreenKeyboardClicked ==
                                              false) {
                                            controller
                                                    .text =
                                                digit;
                                            isOnscreenKeyboardClicked =
                                                true;
                                          } else {
                                            controller
                                                    .text +=
                                                digit;
                                          }
                                          double? maxDim =
                                              currentFocus ==
                                                      3
                                                  ? originalWidth
                                                  : originalHeight;
                                          double parsedDim =
                                              double.tryParse(
                                                controller
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0;
                                          if (maxDim !=
                                                  null &&
                                              parsedDim >
                                                  maxDim) {
                                            controller
                                                .text = '0';
                                          }
                                          controller
                                              .selection = TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  controller
                                                      .text
                                                      .length,
                                            ),
                                          );
                                        } else {
                                          controller.text +=
                                              digit;
                                          controller
                                              .selection = TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  controller
                                                      .text
                                                      .length,
                                            ),
                                          );
                                        }
                                      }

                                      void removeDigit(
                                        TextEditingController
                                        controller,
                                      ) {
                                        if (controller
                                            .text
                                            .isNotEmpty) {
                                          controller
                                              .text = controller
                                              .text
                                              .substring(
                                                0,
                                                controller
                                                        .text
                                                        .length -
                                                    1,
                                              );
                                          if (currentFocus ==
                                              1) {
                                            double newVal =
                                                double.tryParse(
                                                  controller
                                                      .text,
                                                ) ??
                                                0;
                                            setState(() {
                                              qqty = newVal;
                                            });
                                          }

                                          controller
                                              .selection = TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  controller
                                                      .text
                                                      .length,
                                            ),
                                          );
                                        }
                                      }

                                      if (value != '00') {
                                        addDigit(
                                          value,
                                          currentController(),
                                        );
                                      } else {
                                        removeDigit(
                                          currentController(),
                                        );
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
    searchController.clear();
    if (context.mounted) {
      returnSalesProvider().closeCustomPrice();
      returnSalesProvider().toggleSetTotalPrice(false);
    }
  });
}

class WastageTypeButton extends StatelessWidget {
  final bool isPercentageWastage;
  final Function() toggleIsPercentageWastage;
  final String symbol;
  final bool myBoolValue;
  const WastageTypeButton({
    super.key,
    required this.isPercentageWastage,
    required this.toggleIsPercentageWastage,
    required this.symbol,
    required this.myBoolValue,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.grey.shade100,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: toggleIsPercentageWastage,
          borderRadius: BorderRadius.circular(3),
          child: Container(
            padding: EdgeInsets.fromLTRB(7, 7, 7, 7),

            child: Center(
              child: Row(
                spacing: 2,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    symbol,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isPercentageWastage == myBoolValue
                              ? theme
                                  .lightModeColor
                                  .prColor250
                              : null,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
//
// C A R T   B O T T O M  S H E E T

class CustomBottomPanel extends StatefulWidget {
  final TextEditingController searchController;
  final Function() close;
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
  FocusNode priceNode = FocusNode();

  bool isExpanded = false;
  //
  //
  //

  TextEditingController quantityController =
      TextEditingController(text: '');
  TextEditingController priceController =
      TextEditingController();
  FocusNode mainSearchNode = FocusNode();

  CategoryClass? selectedCat;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      // elevation: 1,
      child: Ink(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
        ),
        child: SafeArea(
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.99,
            padding:
                screenWidth(context) < mobileScreen
                    ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                    : const EdgeInsets.fromLTRB(
                      10,
                      10,
                      10,
                      10,
                    ),
            child: Column(
              children: [
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
                              : returnCategoriesProvider()
                                  .categoriesMain
                                  .isEmpty
                              ? 100
                              : 50,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            screenWidth(context) <
                                    mobileScreen
                                ? null
                                : BorderRadius.circular(15),
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
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
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
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onTap: () {
                                    widget.close();
                                    widget.searchController
                                        .clear();
                                    // clear();
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
                                          context: context,
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
                                      setState(() {});
                                    },
                                    onPressedScan: () async {
                                      SalesAuthAction().useBarcodeAction(
                                        context: context,
                                        action: () async {
                                          // productResults
                                          //     .clear();
                                          // searchResult =
                                          //     null;
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
                                            await playBeep();
                                          }
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (!kIsWeb &&
                                        screenWidth(
                                              context,
                                            ) >
                                            mobileScreen) {
                                      return Row(
                                        children: [
                                          SizedBox(
                                            width: 2,
                                          ),
                                          IconButton(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onPressed: () async {
                                              mainSearchNode
                                                  .requestFocus();
                                              await showOnScreenKeyboard();
                                            },
                                            icon: Icon(
                                              size: 25,
                                              Icons
                                                  .keyboard_alt_outlined,
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                                Visibility(
                                  visible:
                                      screenWidth(
                                        context,
                                      ) <=
                                      tabletScreenSmall,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          left: 10.0,
                                        ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                      spacing: 3,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Add List',
                                        ),
                                        MyToggleButton(
                                          theme: theme,
                                          toggle: () {
                                            returnSalesProvider()
                                                .toggleAddMultipleItemsToCart();
                                          },
                                          boolValue:
                                              returnSalesProviderContext(
                                                context,
                                              ).isAddMultipleItemsToCart,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible:
                                screenWidth(context) <=
                                    tabletScreenSmall &&
                                returnCategoriesProvider()
                                    .categoriesMain
                                    .isNotEmpty,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                5,
                                8,
                                5,
                                0,
                              ),
                              padding: EdgeInsets.only(
                                bottom: 8,
                                top: 8,
                              ),
                              height: 40,
                              width:
                                  screenWidth(context) - 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        Colors
                                            .grey
                                            .shade300,
                                  ),
                                  top: BorderSide(
                                    color:
                                        Colors
                                            .grey
                                            .shade300,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection:
                                      Axis.horizontal,
                                  children:
                                      returnCategoriesProvider().categoriesMain.map((
                                        cat,
                                      ) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                    3,
                                              ),
                                          child: Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedCat ==
                                                            cat
                                                        ? theme.lightModeColor.tertColor200
                                                        : theme.lightModeColor.tertColor100,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      2,
                                                    ),
                                              ),
                                              child: InkWell(
                                                mouseCursor:
                                                    SystemMouseCursors
                                                        .click,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedCat ==
                                                        cat) {
                                                      selectedCat =
                                                          null;
                                                    } else {
                                                      selectedCat =
                                                          cat;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  // constraints: BoxConstraints(
                                                  //   maxWidth:
                                                  //       250,
                                                  //   minWidth:
                                                  //       50,
                                                  // ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        5,
                                                    horizontal:
                                                        10,
                                                  ),
                                                  child: Text(
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          selectedCat ==
                                                                  cat
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      color:
                                                          selectedCat ==
                                                                  cat
                                                              ? Colors.white
                                                              : Colors.black,
                                                    ),
                                                    cutLongText(
                                                      cat.name,
                                                      20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment(
                                      0,
                                      1,
                                    ),
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          var products =
                                              selectedCat ==
                                                      null
                                                  ? returnData().productList().where(
                                                    (
                                                      item,
                                                    ) =>
                                                        item.barcode ==
                                                            widget.searchController.text ||
                                                        item.name.toLowerCase().contains(
                                                          widget.searchController.text.toLowerCase(),
                                                        ),
                                                  )
                                                  : returnData().productList().where(
                                                    (
                                                      itemm,
                                                    ) =>
                                                        itemm.categories?.contains(
                                                              selectedCat?.uuid,
                                                            ) ==
                                                            true &&
                                                        (itemm.barcode ==
                                                                widget.searchController.text ||
                                                            itemm.name.toLowerCase().contains(
                                                              widget.searchController.text.toLowerCase(),
                                                            )),
                                                  );

                                          if (products
                                              .isEmpty) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    top:
                                                        20.0,
                                                    left:
                                                        30,
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
                                                              theme.mobileTexts.b1.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        'Found 0 Item(s)',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return RefreshIndicator(
                                              onRefresh: () async {
                                                await returnData().getProducts(
                                                  returnShopProvider()
                                                      .userShop()!
                                                      .shopId!,
                                                );
                                                setState(
                                                  () {},
                                                );
                                              },
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              displacement:
                                                  15,
                                              child: ListView.builder(
                                                padding:
                                                    EdgeInsets.only(
                                                      top:
                                                          10,
                                                    ),
                                                itemCount:
                                                    products
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  final product =
                                                      products
                                                          .toList()[index];
                                                  return ProductTileCartSearch(
                                                    action: () {
                                                      addItemToCartFromCartItemList(
                                                        useTempCart:
                                                            true,
                                                        closeAction: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        context:
                                                            context,
                                                        priceController:
                                                            priceController,
                                                        priceNode:
                                                            priceNode,
                                                        product:
                                                            product.copyWith(),
                                                        qttyNode:
                                                            qttyNode,
                                                        quantityController:
                                                            quantityController,
                                                        searchController:
                                                            widget.searchController,
                                                      );
                                                    },
                                                    theme:
                                                        theme,
                                                    product:
                                                        product,
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      Visibility(
                                        visible:
                                            returnSalesProviderContext(
                                              context,
                                            ).isAddMultipleItemsToCart &&
                                            screenWidth(
                                                  context,
                                                ) <=
                                                tabletScreenSmall,
                                        child: SizedBox(
                                          height:
                                              screenHeight(
                                                context,
                                              ) *
                                              (isExpanded
                                                  ? 0.7
                                                  : 0.4),
                                          child: MultipleTemporaryCartItems(
                                            expandAction: () {
                                              setState(() {
                                                isExpanded =
                                                    !isExpanded;
                                              });
                                            },
                                            isExpanded:
                                                isExpanded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      screenWidth(context) >
                                      tabletScreenSmall,
                                  child: Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(
                                                horizontal:
                                                    20,
                                              ),
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                          width: 2,
                                          height:
                                              double
                                                  .infinity,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height:
                                                double
                                                    .infinity,
                                            padding:
                                                EdgeInsets.all(
                                                  10,
                                                ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                        5.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Visibility(
                                                        visible:
                                                            returnCategoriesProvider().categoriesMain.isNotEmpty,
                                                        child: Expanded(
                                                          child: Row(
                                                            spacing:
                                                                3,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                'Selected Category:',
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.fromLTRB(
                                                                  7,
                                                                  3,
                                                                  7,
                                                                  5,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors.grey.shade200,
                                                                ),
                                                                child: Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                  selectedCat?.name ??
                                                                      'None',
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    selectedCat !=
                                                                    null,
                                                                child: Material(
                                                                  color:
                                                                      Colors.transparent,
                                                                  child: InkWell(
                                                                    mouseCursor:
                                                                        SystemMouseCursors.click,
                                                                    onTap: () {
                                                                      setState(
                                                                        () {
                                                                          selectedCat =
                                                                              null;
                                                                        },
                                                                      );
                                                                    },
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            4.0,
                                                                        horizontal:
                                                                            10,
                                                                      ),
                                                                      child: Icon(
                                                                        size:
                                                                            15,
                                                                        Icons.clear,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            'Add Multiple',
                                                          ),
                                                          MyToggleButton(
                                                            theme:
                                                                theme,
                                                            toggle: () {
                                                              returnSalesProvider().toggleAddMultipleItemsToCart();
                                                            },
                                                            boolValue:
                                                                returnSalesProviderContext(
                                                                  context,
                                                                ).isAddMultipleItemsToCart,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Divider(),
                                                Visibility(
                                                  visible:
                                                      returnCategoriesProvider()
                                                          .categoriesMain
                                                          .isNotEmpty,
                                                  child: Expanded(
                                                    flex: 1,
                                                    child: SingleChildScrollView(
                                                      child: Wrap(
                                                        alignment:
                                                            WrapAlignment.start,
                                                        runSpacing:
                                                            10,
                                                        spacing:
                                                            10,
                                                        children:
                                                            returnCategoriesProvider().categoriesMain.map((
                                                              cat,
                                                            ) {
                                                              return Material(
                                                                color:
                                                                    Colors.transparent,
                                                                child: Ink(
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        selectedCat ==
                                                                                cat
                                                                            ? theme.lightModeColor.tertColor200
                                                                            : theme.lightModeColor.tertColor100,
                                                                    borderRadius: BorderRadius.circular(
                                                                      2,
                                                                    ),
                                                                  ),
                                                                  child: InkWell(
                                                                    mouseCursor:
                                                                        SystemMouseCursors.click,
                                                                    borderRadius: BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                        () {
                                                                          if (selectedCat ==
                                                                              cat) {
                                                                            selectedCat =
                                                                                null;
                                                                          } else {
                                                                            selectedCat =
                                                                                cat;
                                                                          }
                                                                        },
                                                                      );
                                                                    },
                                                                    child: Container(
                                                                      constraints: BoxConstraints(
                                                                        maxWidth:
                                                                            250,
                                                                        minWidth:
                                                                            50,
                                                                      ),
                                                                      padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            17,
                                                                        horizontal:
                                                                            25,
                                                                      ),
                                                                      child: Text(
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                              selectedCat ==
                                                                                      cat
                                                                                  ? FontWeight.bold
                                                                                  : FontWeight.normal,
                                                                          fontSize:
                                                                              theme.mobileTexts.b2.fontSize,
                                                                          color:
                                                                              selectedCat ==
                                                                                      cat
                                                                                  ? Colors.white
                                                                                  : Colors.black,
                                                                        ),
                                                                        cutLongText(
                                                                          cat.name,
                                                                          20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Builder(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    if (returnSalesProviderContext(
                                                      context,
                                                    ).isAddMultipleItemsToCart) {
                                                      return Expanded(
                                                        flex:
                                                            isExpanded
                                                                ? 7
                                                                : 1,
                                                        child: MultipleTemporaryCartItems(
                                                          expandAction: () {
                                                            setState(
                                                              () {
                                                                isExpanded =
                                                                    !isExpanded;
                                                              },
                                                            );
                                                          },
                                                          isExpanded:
                                                              isExpanded,
                                                        ),
                                                      );
                                                    } else {
                                                      return SizedBox();
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

class MultipleTemporaryCartItems extends StatelessWidget {
  final Function()? expandAction;
  final bool isExpanded;
  const MultipleTemporaryCartItems({
    super.key,
    required this.expandAction,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'SELECTED ITEMS:',
              ),
              Visibility(
                visible:
                    screenWidth(context) < tabletScreenSmall
                        ? true
                        : returnCategoriesProvider()
                            .categoriesMain
                            .isNotEmpty,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: expandAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            isExpanded
                                ? 'Colapse'
                                : 'Expand',
                          ),
                          Icon(
                            !isExpanded
                                ? Icons
                                    .keyboard_double_arrow_up_rounded
                                : Icons
                                    .keyboard_double_arrow_down_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children:
                  returnSalesProviderContext(
                    context,
                  ).tempCartItems.reversed.map((item) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 5,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  "${formatLargeNumberDouble(item.quantity)} - ",
                                ),
                                Flexible(
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    item.getItem()?.name ??
                                        'Item Name',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            formatMoneyBig(
                              amount: item.revenue(),
                              context: context,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (
                                    confirmContext,
                                  ) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'Are you sure you want to remove this item from Temporary Selected?',
                                      title:
                                          'Remove Item From List',
                                      action: () {
                                        Navigator.of(
                                          confirmContext,
                                        ).pop();
                                        returnSalesProvider()
                                            .deleteItemFromTempCart(
                                              item: item,
                                            );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding:
                                    EdgeInsetsGeometry.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                child: Icon(
                                  size: 20,
                                  Icons.clear,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
          SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: Row(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade200,
                    ),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        if (returnSalesProvider()
                            .tempCartItems
                            .isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to clear Temporary Cart List. Are you sure you want to proceed?',
                                title: 'Clear List',
                                action: () {
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                  returnSalesProvider()
                                      .clearTempCartList();
                                },
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            'Clear',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color:
                          theme
                              .lightModeColor
                              .errorColor200,
                    ),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () async {
                        if (returnSalesProvider()
                            .tempCartItems
                            .isNotEmpty) {
                          if (returnShopProvider()
                                      .userShop()
                                      ?.printSalesDocket ==
                                  true &&
                              returnCompProvider(
                                context,
                                listen: false,
                              ).getContinuousPrintDocket() &&
                              screenWidth(context) >
                                  tabletScreenSmall) {
                            var res =
                                kIsWeb
                                    ? await downloadDocket(
                                      setTotal: false,
                                      items:
                                          returnSalesProvider()
                                              .tempCartItems,
                                      cart:
                                          returnSalesProvider()
                                              .currentCart(),
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      fileName:
                                          'Docket Slip${DateTime.now().microsecondsSinceEpoch.toString().substring(0, 5)}',
                                      waiter:
                                          returnSalesProvider()
                                              .currentMainCart()
                                              .subStaff
                                              ?.staffName ??
                                          'Not Set',
                                    )
                                    : await printDocket(
                                      setTotal: false,
                                      items:
                                          returnSalesProvider()
                                              .tempCartItems,
                                      cart:
                                          returnSalesProvider()
                                              .currentCart(),
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      fileName:
                                          'Docket Slip${DateTime.now().microsecondsSinceEpoch.toString().substring(0, 5)}',
                                      waiter:
                                          returnSalesProvider()
                                              .currentMainCart()
                                              .subStaff
                                              ?.staffName ??
                                          'Not Set',
                                    );
                            if (res) {
                              await returnSalesProvider()
                                  .addMultipleItemsToCart(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                  );
                              // Navigator.of(
                              //   // ignore: use_build_context_synchronously
                              //   confirmContext,
                              // ).pop();
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                context,
                              ).pop();
                              returnSalesProvider()
                                  .clearTempCartList();
                            }
                          } else {
                            await returnSalesProvider()
                                .addMultipleItemsToCart(
                                  context: context,
                                );
                            // Navigator.of(
                            //   confirmContext,
                            // ).pop();
                            Navigator.of(
                              // ignore: use_build_context_synchronously
                              context,
                            ).pop();
                            returnSalesProvider()
                                .clearTempCartList();
                          }
                          //     },
                          //   );
                          // },
                          // );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),

                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            'Add To Cart',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}

Future<void> showOnScreenKeyboard() async {
  try {
    if (Platform.isWindows) {
      await Process.start('cmd', [
        '/c',
        'start',
        '',
        'osk',
      ], mode: ProcessStartMode.detached);
    }
  } catch (e) {
    await mainLocalLog(
      'Error Opening Keyboard: ${e.toString()}',
    );
  }
}

//
//
//
//

// A D D   N E W   C U S T O M E R   B O T T O M

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
                        mouseCursor:
                            SystemMouseCursors.click,
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
