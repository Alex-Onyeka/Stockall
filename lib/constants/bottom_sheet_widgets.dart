import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
// import 'package:stockall/classes/temp_product_class.dart';
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
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/right_bar_section.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/purchase_action_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

void selectProductPurchase({
  TempProductClass? product,
  TempStorageProducts? storageProduct,
  required Function() closeAction,
  required TextEditingController priceController,
  required TextEditingController quantityController,
  required BuildContext context,
  PurchaseListItem? purchaseItem,
}) {
  var theme = returnTheme(context, listen: false);
  bool setCustomPrice = false;
  bool isGroupTemp = false;

  bool useGroupUnit() {
    if (shop(context)?.manageInventoryStorage == true) {
      return storageProduct?.useGroupUnit ?? false;
    } else {
      return product?.useGroupUnit ?? false;
    }
  }

  if (purchaseItem != null) {
    isGroupTemp = purchaseItem.isGroup;
    if (purchaseItem.customPrice != null) {
      priceController.text =
          '${purchaseItem.customPrice ?? ''}';
      setCustomPrice = true;
    }
    quantityController.text =
        (purchaseItem.quantity).toString();
  } else {
    if (useGroupUnit()) {
      isGroupTemp = true;
    } else {
      isGroupTemp = false;
    }
  }
  double amount() {
    if (purchaseItem == null) {
      if (setCustomPrice) {
        return (double.tryParse(
              priceController.text.replaceAll(',', ''),
            ) ??
            0);
      } else {
        if (returnShopProvider()
                .userShop()
                ?.manageInventoryStorage ==
            true) {
          return isGroupTemp
              ? ((storageProduct?.costPrice ?? 0) *
                  (double.tryParse(
                        quantityController.text.replaceAll(
                          ',',
                          '',
                        ),
                      ) ??
                      0) *
                  (storageProduct?.qttyPerGroup ?? 1))
              : (storageProduct?.costPrice ?? 0) *
                  (double.tryParse(
                        quantityController.text.replaceAll(
                          ',',
                          '',
                        ),
                      ) ??
                      0);
        } else {
          return isGroupTemp
              ? ((product?.costPrice ?? 0) *
                  (double.tryParse(
                        quantityController.text.replaceAll(
                          ',',
                          '',
                        ),
                      ) ??
                      0) *
                  (product?.qttyPerGroup ?? 1))
              : (product?.costPrice ?? 0) *
                  (double.tryParse(
                        quantityController.text.replaceAll(
                          ',',
                          '',
                        ),
                      ) ??
                      0);
        }
      }
    } else {
      if (setCustomPrice) {
        return (double.tryParse(
              priceController.text.replaceAll(',', ''),
            ) ??
            0);
      } else {
        return isGroupTemp
            ? ((purchaseItem.originalPrice ?? 0) *
                (double.tryParse(
                      quantityController.text.replaceAll(
                        ',',
                        '',
                      ),
                    ) ??
                    0) *
                (purchaseItem.qttyPerGroup ?? 1))
            : (purchaseItem.originalPrice ?? 0) *
                (double.tryParse(
                      quantityController.text.replaceAll(
                        ',',
                        '',
                      ),
                    ) ??
                    0);
      }
    }
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
                    'Enter Item Purchase Details',
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
                    SizedBox(
                      width: 450,
                      child: EditCartTextField(
                        title: 'Enter Item Quantity',
                        hint: 'Quantity',
                        controller: quantityController,
                        theme: theme,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    Visibility(
                      visible: useGroupUnit(),
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
                                  'Use Group Quantity?',
                                ),
                                MyToggleButton(
                                  boolValue: isGroupTemp,
                                  toggle: () {
                                    setState(() {
                                      isGroupTemp =
                                          !isGroupTemp;
                                    });
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
                    Builder(
                      builder: (context) {
                        if (setCustomPrice) {
                          return Column(
                            children: [
                              Row(
                                spacing: 10,
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: MoneyTextfield(
                                      title: 'Custom Price',
                                      hint: 'Enter Price',
                                      controller:
                                          priceController,
                                      theme: theme,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    // SizedBox(height: 20),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        setState(() {
                          setCustomPrice = !setCustomPrice;
                        });
                        priceController.clear();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                fontWeight: FontWeight.bold,
                              ),
                              setCustomPrice
                                  ? 'Cancel Custom Price'
                                  : 'Set Custom Price',
                            ),
                            Stack(
                              children: [
                                Visibility(
                                  visible:
                                      setCustomPrice ==
                                      false,
                                  child: SvgPicture.asset(
                                    editIconSvg,
                                    height: 20,
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      setCustomPrice ==
                                      true,
                                  child: Icon(Icons.clear),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                            formatMoneyMid(
                              amount: amount(),
                              context: context,
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
                              SystemMouseCursors.click,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        SmallButtonMain(
                          theme: theme,
                          action: () {
                            if (quantityController
                                .text
                                .isNotEmpty) {
                              if (!setCustomPrice ||
                                  (setCustomPrice &&
                                      priceController
                                          .text
                                          .isNotEmpty)) {
                                if (purchaseItem != null) {
                                  returnPurchaseActionProvider().updateItem(
                                    item: PurchaseListItem(
                                      unit:
                                          isGroupTemp
                                              ? product
                                                  ?.groupUnit
                                              : product
                                                  ?.unit,
                                      qttyPerGroup:
                                          product
                                              ?.qttyPerGroup ??
                                          storageProduct
                                              ?.qttyPerGroup,
                                      storageItemUuid:
                                          purchaseItem
                                              .storageItemUuid,
                                      originalPrice:
                                          purchaseItem
                                              .originalPrice,
                                      itemName:
                                          purchaseItem
                                              .itemName,
                                      customPrice:
                                          double.tryParse(
                                            priceController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      itemUuid:
                                          purchaseItem
                                              .itemUuid,
                                      totalPrice: amount(),
                                      quantity:
                                          (double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0),
                                      isGroup: isGroupTemp,
                                    ),
                                  );
                                } else {
                                  returnPurchaseActionProvider().addItemToList(
                                    item: PurchaseListItem(
                                      unit:
                                          isGroupTemp
                                              ? product
                                                  ?.groupUnit
                                              : product
                                                  ?.unit,
                                      qttyPerGroup:
                                          product
                                              ?.qttyPerGroup ??
                                          storageProduct
                                              ?.qttyPerGroup,
                                      originalPrice:
                                          product
                                              ?.costPrice ??
                                          storageProduct
                                              ?.costPrice,
                                      itemName:
                                          returnShopProvider()
                                                      .userShop()
                                                      ?.manageInventoryStorage ==
                                                  true
                                              ? storageProduct
                                                      ?.name ??
                                                  'Item Name'
                                              : product
                                                      ?.name ??
                                                  'Item Name',
                                      customPrice:
                                          double.tryParse(
                                            priceController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      itemUuid:
                                          product?.uuid,
                                      storageItemUuid:
                                          storageProduct
                                              ?.uuid,
                                      totalPrice: amount(),
                                      quantity:
                                          (double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0),
                                      isGroup: isGroupTemp,
                                    ),
                                  );
                                  Navigator.of(
                                    context,
                                  ).pop();
                                }
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          buttonText: 'Add Item',
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
    quantityController.clear();
    priceController.clear();
  });
}

void selectProductsForPurchaseBottomSheet({
  required BuildContext context,
  Function()? action,
  required TextEditingController searchController,
  required TextEditingController priceController,
  required TextEditingController quantityController,
}) async {
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
        initialChildSize: 0.95,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<TempProductClass> products = [];
          List<TempStorageProducts> storageProducts = [];
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage !=
              true) {
            products =
                returnData(
                  context: context,
                ).productListMain.where((item) {
                  if (returnPurchaseActionProvider()
                      .purchaseListItems
                      .where(
                        (purch) =>
                            purch.itemUuid == item.uuid,
                      )
                      .isEmpty) {
                    return true;
                  } else {
                    return false;
                  }
                }).toList();
            products.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
          } else {
            storageProducts =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where((item) {
                      if (returnPurchaseActionProvider()
                          .purchaseListItems
                          .where(
                            (purch) =>
                                purch.storageItemUuid ==
                                item.uuid,
                          )
                          .isEmpty) {
                        return true;
                      } else {
                        return false;
                      }
                    })
                    .toList();

            storageProducts.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
          }

          return StatefulBuilder(
            builder:
                (context, setState) => Container(
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
                          Expanded(
                            child: Text(
                              'Select Items',
                              style: TextStyle(
                                fontSize:
                                    returnTheme(context)
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              width: 200,
                              child: GeneralTextfieldOnly(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                hint: 'Search Name',
                                controller:
                                    searchController,
                                lines: 1,
                                theme: returnTheme(
                                  context,
                                  listen: false,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                    FocusScope.of(
                                      context,
                                    ).unfocus();
                                  },
                                  icon: Icon(Icons.check),
                                ),
                              ],
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
                          child: ListView(
                            controller: scrollController,
                            children:
                                returnShopProvider()
                                            .userShop()
                                            ?.manageInventoryStorage ==
                                        true
                                    ? storageProducts
                                        .where(
                                          (prod) => prod
                                              .name
                                              .toLowerCase()
                                              .contains(
                                                searchController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .map(
                                          (
                                            pro,
                                          ) => Container(
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
                                                  style: TextStyle(
                                                    fontSize:
                                                        returnTheme(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  pro.name,
                                                ),
                                                onTap: () {
                                                  selectProductPurchase(
                                                    storageProduct:
                                                        pro,
                                                    closeAction:
                                                        () {},
                                                    priceController:
                                                        priceController,
                                                    quantityController:
                                                        quantityController,
                                                    context:
                                                        context,
                                                  );
                                                },
                                                trailing: Icon(
                                                  size: 18,
                                                  Icons.add,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList()
                                    : products
                                        .where(
                                          (prod) => prod
                                              .name
                                              .toLowerCase()
                                              .contains(
                                                searchController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .map(
                                          (
                                            pro,
                                          ) => Container(
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
                                                  style: TextStyle(
                                                    fontSize:
                                                        returnTheme(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  pro.name,
                                                ),
                                                onTap: () {
                                                  selectProductPurchase(
                                                    product:
                                                        pro,
                                                    closeAction:
                                                        () {},
                                                    priceController:
                                                        priceController,
                                                    quantityController:
                                                        quantityController,
                                                    context:
                                                        context,
                                                  );
                                                },
                                                trailing: Icon(
                                                  size: 18,
                                                  Icons.add,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      );
    },
  ).then((_) {
    searchController.clear();
  });
  action!();
}

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
  required TempCartItem cartItem,
  required Function() closeAction,
  required TextEditingController priceController,
  required TextEditingController quantityController,
  required TextEditingController searchController,
  required FocusNode qttyNode,
  required FocusNode priceNode,
  required BuildContext context,
  // required double qttyTemp
}) {
  bool isOnscreenKeyboardClicked = false;
  int currentFocus = 1;
  double qqty = 0;
  bool useWholeSalePriceTemp = false;
  bool useGroupQuantityTemp = false;
  bool useGroupUnit() {
    return cartItem.item.useGroupUnit ?? false;
  }

  double existingQtty = cartItem.quantity;
  if (isEdit) {
    useWholeSalePriceTemp = cartItem.useWholeSalePrice;
    useGroupQuantityTemp =
        cartItem.useGroupQuantity ?? false;
    if (useGroupQuantityTemp) {
      existingQtty =
          (existingQtty * (cartItem.qttyPerGroup ?? 1));
    }
    // returnSalesProvider().removeListenerScanBarcode();
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

  String formatSellingPrice(TempCartItem cartItem) {
    // if (isEdit) {
    //   if (useGroupQuantityTemp == true) {
    //     if (useWholeSalePriceTemp) {
    //       return ((qqty * cartItem.getQttyPerGroup()) *
    //               (cartItem.getItem()?.wholeSalePrice ?? 0))
    //           .toString();
    //     } else if (priceController.text.isNotEmpty) {
    //       if (returnSalesProvider().setTotalPrice) {
    //         return priceController.text.replaceAll(',', '');
    //       } else {
    //         return (double.parse(
    //                   priceController.text.isNotEmpty
    //                       ? priceController.text.replaceAll(
    //                         ',',
    //                         '',
    //                       )
    //                       : '0',
    //                 ) *
    //                 (qqty.toDouble() *
    //                     cartItem.getQttyPerGroup()))
    //             .toString();
    //       }
    //     } else {
    //       return ((qqty * cartItem.getQttyPerGroup()) *
    //               (cartItem.getItem()?.sellingPrice ?? 0))
    //           .toString();
    //     }
    //   } else {
    //     if (useWholeSalePriceTemp) {
    //       return (qqty *
    //               (cartItem.getItem()?.wholeSalePrice ?? 0))
    //           .toString();
    //     } else if (priceController.text.isNotEmpty) {
    //       if (returnSalesProvider().setTotalPrice) {
    //         return priceController.text.replaceAll(',', '');
    //       } else {
    //         return (double.parse(
    //                   priceController.text.isNotEmpty
    //                       ? priceController.text.replaceAll(
    //                         ',',
    //                         '',
    //                       )
    //                       : '0',
    //                 ) *
    //                 qqty.toDouble())
    //             .toString();
    //       }
    //     } else {
    //       return (qqty *
    //               (cartItem.getItem()?.sellingPrice ?? 0))
    //           .toString();
    //     }
    //   }
    // } else {
    if (useGroupQuantityTemp) {
      if (useWholeSalePriceTemp) {
        return ((qqty * cartItem.getQttyPerGroup()) *
                (cartItem.getItem()?.wholeSalePrice ?? 0))
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
                  (qqty.toDouble() *
                      cartItem.getQttyPerGroup()))
              .toString();
        }
      } else {
        return ((qqty * cartItem.getQttyPerGroup()) *
                (cartItem.getItem()?.sellingPrice ?? 0))
            .toString();
      }
    } else {
      if (useWholeSalePriceTemp) {
        return (qqty *
                (cartItem.getItem()?.wholeSalePrice ?? 0))
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
        return (qqty *
                (cartItem.getItem()?.sellingPrice ?? 0))
            .toString();
      }
    }
    // }
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
                            SizedBox(
                              width:
                                  screenWidth(context) >
                                          tabletScreenSmall
                                      ? 450
                                      : null,
                              child: EditCartTextField(
                                onTap: () {
                                  setState(() {
                                    currentFocus = 1;
                                  });
                                },
                                focusNode: qttyNode,
                                onChanged: (value) {
                                  double entered =
                                      double.tryParse(
                                        value.replaceAll(
                                          ',',
                                          '',
                                        ),
                                      ) ??
                                      0;
                                  if (cartItem
                                          .getItem()
                                          ?.isManaged ??
                                      false) {
                                    if (!returnSalesProvider()
                                        .canAddProductToCart(
                                          // isEdit: isEdit,
                                          newCartItem:
                                              cartItem,
                                          quantityToAdd:
                                              entered,
                                          useGroupUnit:
                                              useGroupQuantityTemp,
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
                                                  "Only ${returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem)} available in stock.",
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
                                    qqty = entered;
                                  });
                                },

                                title:
                                    'Enter Item Quantity',
                                hint: 'Quantity',
                                controller:
                                    quantityController,
                                theme: theme,
                              ),
                            ),
                            Visibility(
                              visible: useGroupUnit(),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(
                                          maxWidth: 230,
                                        ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,
                                          ),
                                          'Use Group Quantity?',
                                        ),
                                        MyToggleButton(
                                          boolValue:
                                              // isEdit
                                              //     ?
                                              useGroupQuantityTemp,
                                          //     :
                                          // cartItem
                                          //     .useGroupQuantity ??
                                          // false,
                                          toggle: () {
                                            // var salesProvider =
                                            //     returnSalesProvider();

                                            // if (isEdit) {
                                            setState(() {
                                              if (useGroupQuantityTemp) {
                                                useGroupQuantityTemp =
                                                    false;
                                              } else {
                                                useGroupQuantityTemp =
                                                    true;
                                              }
                                            });
                                          },
                                          theme: theme,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  cartItem
                                              .getItem()
                                              ?.sellingPrice ==
                                          null
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
                                  SizedBox(height: 30),
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
                                            if (value
                                                .isNotEmpty) {
                                              cartItem.setCustomPrice =
                                                  true;
                                            } else {
                                              cartItem.setCustomPrice =
                                                  false;
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Visibility(
                              visible:
                                  // isEdit
                                  //     ? (cartItem
                                  //                 .getItem()
                                  //                 ?.setCustomPrice ??
                                  //             false) &&
                                  //         !useWholeSalePriceTemp
                                  //     :
                                  (cartItem
                                          .getItem()
                                          ?.setCustomPrice ??
                                      false) &&
                                  !useWholeSalePriceTemp,
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  returnSalesProvider()
                                      .toggleSetCustomPrice();
                                  priceController.clear();
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
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
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .secColor200,
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
                            Visibility(
                              visible:
                                  returnShopProvider()
                                      .userShop()
                                      ?.wholeSale ==
                                  true,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 230,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Use Whole Sale Price?',
                                        ),
                                        MyToggleButton(
                                          boolValue:
                                              // isEdit
                                              //     ? useWholeSalePriceTemp
                                              //     :
                                              useWholeSalePriceTemp,
                                          toggle: () {
                                            var salesProvider =
                                                returnSalesProvider();

                                            // if (isEdit) {
                                            setState(() {
                                              useWholeSalePriceTemp =
                                                  !useWholeSalePriceTemp;
                                            });
                                            // } else {
                                            // salesProvider
                                            //     .toggleWholeSale(
                                            //       cartItem:
                                            //           cartItem,
                                            //       context:
                                            //           context,
                                            //     );
                                            // }
                                            priceController
                                                .clear();
                                            salesProvider
                                                .closeCustomPrice();
                                          },
                                          theme: theme,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                                          if (!returnSalesProvider()
                                              .canAddProductToCart(
                                                // isEdit:
                                                //     isEdit,
                                                newCartItem:
                                                    cartItem,
                                                quantityToAdd:
                                                    entered,
                                                useGroupUnit:
                                                    useGroupQuantityTemp,
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
                                                        "Only ${returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem)} available in stock.",
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
                                                ?.sellingPrice ==
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
                                        double getQtty() {
                                          if (useGroupQuantityTemp) {
                                            return (qqty *
                                                cartItem
                                                    .quantity);
                                          } else {
                                            return qqty;
                                          }
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
                                              cartItem.useWholeSalePrice =
                                                  useWholeSalePriceTemp;
                                              cartItem.useGroupQuantity =
                                                  useGroupQuantityTemp;
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
                                            cartItem.useWholeSalePrice =
                                                useWholeSalePriceTemp;
                                            cartItem.useGroupQuantity =
                                                useGroupQuantityTemp;
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
                                              .isAddMultipleItemsToCart) {
                                            cartItem.useGroupQuantity =
                                                useGroupQuantityTemp;
                                            cartItem.useWholeSalePrice =
                                                useWholeSalePriceTemp;
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
                                                    useGroupQuantityTemp;
                                                cartItem.useWholeSalePrice =
                                                    useWholeSalePriceTemp;
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
                                                  useGroupQuantityTemp;
                                              cartItem.useWholeSalePrice =
                                                  useWholeSalePriceTemp;
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
                                          double entered =
                                              double.tryParse(
                                                controller
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
                                              // isEdit:
                                              //     isEdit,
                                              newCartItem:
                                                  cartItem,
                                              quantityToAdd:
                                                  entered,
                                              useGroupUnit:
                                                  useGroupQuantityTemp,
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
                                                          "Only ${returnSalesProvider().remainingQttyInAllCarts(newCartItem: cartItem)} available in stock.",
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
                                          currentFocus == 1
                                              ? quantityController
                                              : priceController,
                                        );
                                      } else {
                                        removeDigit(
                                          currentFocus == 1
                                              ? quantityController
                                              : priceController,
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
                                                            product,
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
