import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/buttons/toggle_total_price.dart';
import 'package:stockall/components/cart_queue/cart_queue_mobile.dart';
import 'package:stockall/components/discount_setter.dart/discount_setter_widget.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/my_calculator.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/cart_item_main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page2/make_sales_two.dart';

class MakeSalesMobile extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isMain;
  final bool? isInvoice;
  const MakeSalesMobile({
    super.key,
    required this.searchController,
    this.isMain,
    this.isInvoice,
  });

  @override
  State<MakeSalesMobile> createState() =>
      _MakeSalesMobileState();
}

class _MakeSalesMobileState extends State<MakeSalesMobile> {
  bool isLoading = false;
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController priceController =
      TextEditingController();
  final discountPercentController = TextEditingController();

  String formatSellingPriceEdit(TempCartItem cartItem) {
    if (priceController.text.isNotEmpty) {
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
      return (qqty * (cartItem.item.sellingPrice!))
          .toString();
    }
  }

  double currentValue = 0;
  double qqty = 0;
  bool useWholeSalePriceTemp = false;
  void editCartItem({
    required double productQuantity,
    required BuildContext context,
    required Function()? updateAction,
    required TempCartItem cartItem,
  }) {
    var theme = returnTheme(context, listen: false);
    setState(() {
      useWholeSalePriceTemp = cartItem.useWholeSalePrice;
    });
    quantityController.text = cartItem.quantity.toString();
    double qqty = cartItem.quantity.toDouble();
    cartItem.setCustomPrice
        ? priceController.text =
            cartItem.customPrice.toString().split('.')[0]
        : priceController.text = "";

    returnSalesProvider().toggleSetTotalPrice(
      cartItem.setTotalPrice,
    );
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
                title: Text(
                  'Edit Cart Item',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible:
                            (returnSalesProviderContext(
                                  context,
                                ).isSetCustomPrice() ||
                                cartItem.setCustomPrice) &&
                            (cartItem.item.setCustomPrice ||
                                cartItem
                                        .item
                                        .sellingPrice ==
                                    null) &&
                            !useWholeSalePriceTemp,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          spacing: 10,
                          children: [
                            Expanded(
                              child: ToggleTotalPriceWidget(
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: 450,
                                child: MoneyTextfield(
                                  title:
                                      returnSalesProviderContext(
                                            context,
                                          ).setTotalPrice
                                          ? 'Total Price'
                                          : 'Individual Price',
                                  hint: 'Enter Price',
                                  controller:
                                      priceController,
                                  theme: theme,
                                  onChanged: (p0) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 450,
                        child: EditCartTextField(
                          onChanged: (value) {
                            final parsedValue =
                                double.tryParse(
                                  value.replaceAll(',', ''),
                                ) ??
                                0;
                            if (cartItem.item.isManaged) {
                              if (parsedValue >
                                  (cartItem.item.quantity ??
                                      0)) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          "Only (${cartItem.item.quantity}) items available in stock.",
                                      title:
                                          'Quantity Limit Reached',
                                    );
                                  },
                                );
                                // Optionally reset to max or previous value
                                setState(() {
                                  quantityController.text =
                                      qqty.toString();
                                });
                              } else {
                                setState(() {
                                  qqty = parsedValue;
                                });
                              }
                            } else {
                              setState(() {
                                qqty = parsedValue;
                              });
                            }
                          },

                          title: 'Enter Item Quantity',
                          hint: 'Quantity',
                          controller: quantityController,
                          theme: theme,
                        ),
                      ),
                      Visibility(
                        visible:
                            !cartItem.setCustomPrice &&
                            cartItem.item.setCustomPrice &&
                            !useWholeSalePriceTemp,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            InkWell(
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
                          ],
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
                                  useWholeSalePriceTemp
                                      ? (qqty *
                                              (cartItem
                                                      .item
                                                      .wholeSalePrice ??
                                                  0))
                                          .toString()
                                      : priceController
                                          .text
                                          .isNotEmpty
                                      ? returnSalesProviderContext(
                                            context,
                                          ).setTotalPrice
                                          ? priceController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              )
                                          : (double.parse(
                                                    priceController.text.isNotEmpty
                                                        ? priceController.text.replaceAll(
                                                          ',',
                                                          '',
                                                        )
                                                        : '0',
                                                  ) *
                                                  qqty.toDouble())
                                              .toString()
                                      : (qqty *
                                              (cartItem
                                                      .item
                                                      .sellingPrice ??
                                                  0))
                                          .toString(),
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
                                        useWholeSalePriceTemp,
                                    toggle: () {
                                      setState(() {
                                        useWholeSalePriceTemp =
                                            !useWholeSalePriceTemp;
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
                                    if (qqty >=
                                        (cartItem
                                                .item
                                                .quantity ??
                                            0)) {
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
                                updateAction!();
                              }
                            },
                            buttonText: 'Update Item',
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
      priceController.text = '';
      if (context.mounted) {
        returnSalesProvider().closeCustomPrice();
        returnSalesProvider().toggleSetTotalPrice(false);
      }
    });
  }

  TextEditingController pName = TextEditingController();
  TextEditingController pQuantity = TextEditingController();
  TextEditingController costPriceC =
      TextEditingController();
  TextEditingController sellingPriceC =
      TextEditingController();
  TextEditingController wholeSalePriceC =
      TextEditingController();
  TextEditingController nameC = TextEditingController();
  bool resultOn = false;

  String formatSellingPrice() {
    if (sellingPriceC.text.isNotEmpty) {
      if (returnSalesProvider().setTotalPrice) {
        return sellingPriceC.text.replaceAll(',', '');
      } else {
        return (double.parse(
                  sellingPriceC.text.isNotEmpty
                      ? sellingPriceC.text.replaceAll(
                        ',',
                        '',
                      )
                      : '0',
                ) *
                qqty.toDouble())
            .toString();
      }
    } else {
      return '0.0';
    }
  }

  bool isNormalEdit = true;

  void makeCustomSale({
    required TempCartItem cartItem,
    required Function() closeAction,
  }) {
    SalesAuthAction().addCustomItemToCartAction(
      context: context,
      action: () {
        var theme = returnTheme(context, listen: false);
        if (returnData()
                .productList()
                .where(
                  (product) =>
                      product.uuid == cartItem.item.uuid,
                )
                .isEmpty &&
            returnSalesProvider()
                .currentCart()
                .cartItems
                .where(
                  (item) =>
                      item.item.uuid == cartItem.item.uuid,
                )
                .isNotEmpty) {
          isNormalEdit = false;
          nameC.text = cartItem.item.name;
          qqty = cartItem.quantity;
          pQuantity.text = cartItem.quantity.toString();
          sellingPriceC.text =
              (cartItem.customPrice ?? 0).toString();
          returnSalesProvider().toggleAddToStock(
            cartItem.addToStock,
            context,
          );
          returnSalesProvider().toggleSetTotalPrice(
            cartItem.setTotalPrice,
          );
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
                                theme
                                    .mobileTexts
                                    .h4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  GeneralTextField(
                                    title: 'Item Name',
                                    hint: 'Enter Item name',
                                    controller: nameC,
                                    lines: 1,
                                    theme: theme,
                                    onChanged: (value) {},
                                  ),

                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child:
                                            ToggleTotalPriceWidget(
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
                                          hint:
                                              'Enter Price',
                                          controller:
                                              sellingPriceC,
                                          theme: theme,
                                          onChanged: (p0) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
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
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                50.0,
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
                                                      .b3
                                                      .fontSize,
                                            ),
                                            'Total Cost',
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
                                            ),
                                            formatMoneyMid(
                                              amount:
                                                  double.tryParse(
                                                    formatSellingPrice(),
                                                  ) ??
                                                  0,
                                              context:
                                                  context,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                              SizedBox(
                                width: 450,
                                child: EditCartTextField(
                                  onChanged: (value) {
                                    double entered =
                                        double.tryParse(
                                          value.replaceAll(
                                            ',',
                                            '',
                                          ),
                                        ) ??
                                        0;

                                    if (value.isEmpty) {
                                      setState(() {
                                        pQuantity.text =
                                            '0';
                                      });
                                    }

                                    setState(() {
                                      qqty = entered;
                                    });
                                  },

                                  title:
                                      'Enter Item Quantity',
                                  hint: 'Quantity',
                                  controller: pQuantity,
                                  theme: theme,
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
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Add Item to your Stock?',
                                    ),
                                    InkWell(
                                      onTap: () {
                                        var salesProvider =
                                            returnSalesProvider();
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  salesProvider
                                                          .addToStock
                                                      ? 'This item will not be added to your stock after this sale, are you sure you want to proceed?'
                                                      : 'This item will be automatically added to your stock after this sale, are you sure you want to proceed?',
                                              title:
                                                  !salesProvider
                                                          .addToStock
                                                      ? 'Add to Stock?'
                                                      : 'Are you Sure?',
                                              action: () async {
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                                salesProvider.toggleAddToStock(
                                                  salesProvider
                                                          .addToStock
                                                      ? false
                                                      : true,
                                                  context,
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 50,
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  10,
                                              vertical: 5,
                                            ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                20,
                                              ),
                                          border: Border.all(
                                            color:
                                                returnSalesProviderContext(
                                                      context,
                                                    ).addToStock
                                                    ? theme
                                                        .lightModeColor
                                                        .prColor250
                                                    : Colors
                                                        .grey,
                                          ),
                                          color:
                                              returnSalesProviderContext(
                                                    context,
                                                  ).addToStock
                                                  ? theme
                                                      .lightModeColor
                                                      .prColor250
                                                  : Colors
                                                      .grey
                                                      .shade200,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              returnSalesProviderContext(
                                                    context,
                                                  ).addToStock
                                                  ? MainAxisAlignment
                                                      .end
                                                  : MainAxisAlignment
                                                      .start,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.all(
                                                    5,
                                                  ),
                                              decoration: BoxDecoration(
                                                shape:
                                                    BoxShape
                                                        .circle,
                                                color:
                                                    returnSalesProviderContext(
                                                          context,
                                                        ).addToStock
                                                        ? Colors.white
                                                        : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
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
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        onTap: () {
                                          setState(() {
                                            if (qqty > 0) {
                                              qqty--;
                                            }
                                            pQuantity.text =
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
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        onTap: () {
                                          setState(() {
                                            qqty++;
                                            pQuantity.text =
                                                qqty.toString();
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
                                    MainAxisAlignment
                                        .center,
                                spacing: 5,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                      costPriceC.clear();
                                      nameC.clear();
                                      pQuantity.clear();
                                      qqty = 0;
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  SmallButtonMain(
                                    theme: theme,
                                    action: () {
                                      var productIndex = returnData()
                                          .productList()
                                          .indexWhere((
                                            item,
                                          ) {
                                            return item.name
                                                    .toLowerCase() ==
                                                nameC.text
                                                    .toLowerCase();
                                          });
                                      var cartItems =
                                          returnSalesProvider()
                                              .currentCart()
                                              .cartItems;
                                      final index = cartItems
                                          .indexWhere((
                                            item,
                                          ) {
                                            return item
                                                    .item
                                                    .name
                                                    .toLowerCase() ==
                                                nameC.text
                                                    .toLowerCase();
                                          });
                                      if (nameC
                                          .text
                                          .isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Item Name must be set before item can be added to cart.',
                                              title:
                                                  'Item not set.',
                                            );
                                          },
                                        );
                                      } else if (index !=
                                              -1 &&
                                          isNormalEdit ==
                                              true) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Item Already Available in cart. Please Edit the Item to increase quantity or change prince.',
                                              title:
                                                  'Duplicate Item.',
                                            );
                                          },
                                        );
                                      } else if (pQuantity
                                              .text
                                              .isEmpty ||
                                          qqty == 0) {
                                        // Navigator.of(context).pop();

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
                                      } else if (productIndex !=
                                              -1 &&
                                          isNormalEdit ==
                                              true) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'This Item is already available in your Store. Please select the Item from your stock and proceed to make sale.',
                                              title:
                                                  'Duplicate Item.',
                                            );
                                          },
                                        );
                                      } else {
                                        if (sellingPriceC
                                            .text
                                            .isEmpty) {
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              context,
                                            ) {
                                              return InfoAlert(
                                                theme:
                                                    theme,
                                                message:
                                                    'Selling Price Must be set before sales can be recorded.',
                                                title:
                                                    'Selling Price not set.',
                                              );
                                            },
                                          );
                                        } else {
                                          cartItem.customPrice =
                                              double.tryParse(
                                                sellingPriceC
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              );
                                          cartItem.quantity =
                                              qqty.toDouble();
                                          cartItem.setCustomPrice =
                                              true;
                                          cartItem.setTotalPrice =
                                              returnSalesProvider()
                                                  .setTotalPrice;
                                          cartItem
                                                  .item
                                                  .name =
                                              nameC.text;
                                          cartItem
                                                  .item
                                                  .costPrice =
                                              (double.tryParse(
                                                    costPriceC
                                                        .text
                                                        .replaceAll(
                                                          ',',
                                                          '',
                                                        ),
                                                  ) ??
                                                  0);
                                          // cartItem.item.uuid =
                                          //     uuidGen();
                                          cartItem.addToStock =
                                              returnSalesProvider()
                                                  .addToStock;

                                          returnSalesProvider().addItemToCart(
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
                                                          cartItem.item.uuid,
                                                    )
                                                    .isEmpty,
                                          );
                                          closeAction();
                                        }
                                      }
                                    },
                                    buttonText:
                                        isNormalEdit == true
                                            ? 'Add To Cart'
                                            : 'Update Item',
                                  ),
                                ],
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

          nameC.clear();
          pQuantity.clear();
          costPriceC.clear();
          sellingPriceC.clear();
          if (context.mounted) {
            setState(() {
              resultOn = false;
              isNormalEdit = true;
            });
            if (!context.mounted) {
              return;
            }
            returnSalesProvider().closeCustomPrice();
            returnSalesProvider().toggleSetTotalPrice(
              false,
            );
          }
        });
      },
    );
  }

  bool showBottomPanel = false;

  List<TempProductClass> productsResult = [];
  String? searchResult;
  bool isFocus = false;
  bool listEmpty = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isInvoice != null &&
          returnSalesProvider()
              .currentCart()
              .cartItems
              .isEmpty) {
        returnSalesProvider().switchInvoiceSale(
          value: true,
          context: context,
        );
      } else if (widget.isInvoice == null &&
          returnSalesProvider()
              .currentCart()
              .cartItems
              .isEmpty) {
        returnSalesProvider().switchInvoiceSale(
          value: false,
          context: context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products = returnData().productList();
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),

      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: appBar(
            backAction:
                returnSalesProvider()
                        .currentCart()
                        .isReceiptEdit
                    ? () {
                      returnSalesProvider()
                          .cancelReceiptEdit(context);
                    }
                    : null,
            // isMain: widget.isMain,
            context: context,
            title:
                returnSalesProviderContext(
                      context,
                    ).currentCart().isReceiptEdit
                    ? 'Edit Receipt'
                    : returnSalesProviderContext(
                      context,
                    ).currentCart().isInvoice
                    ? 'Credit Sale'
                    : 'Cart Items',
            widget: Stack(
              children: [
                Visibility(
                  visible:
                      returnSalesProviderContext(
                        context,
                      ).currentCart().cartItems.isNotEmpty,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmationAlert(
                            theme: theme,
                            message:
                                'You are about to clear the items in your cart, are you sure you want to proceed?',
                            title: 'Are you sure?',
                            action: () {
                              returnSalesProvider()
                                  .clearCart();
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 35,
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.only(
                        // vertical: 10,
                        left: 10,
                        right: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Clear Cart',
                            ),
                            Icon(
                              size: 18,
                              color: Colors.grey.shade600,
                              Icons.clear,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      returnSalesProviderContext(
                        context,
                      ).currentCart().cartItems.isEmpty,
                  child: InkWell(
                    onTap: () {
                      if (returnSalesProvider()
                          .currentCart()
                          .isInvoice) {
                        returnSalesProvider()
                            .switchInvoiceSale(
                              context: context,
                              value: false,
                            );
                      } else {
                        returnSalesProvider()
                            .switchInvoiceSale(
                              context: context,
                              value: true,
                            );
                      }
                    },
                    child: SizedBox(
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 15.0,
                          top: 3,
                          bottom: 3,
                          left: 5,
                        ),
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
                                fontWeight: FontWeight.bold,
                              ),
                              'Sale Credit',
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .isInvoice
                                        ? theme
                                            .lightModeColor
                                            .prColor250
                                        : null,
                                border: Border.all(
                                  color:
                                      returnSalesProviderContext(
                                                context,
                                              )
                                              .currentCart()
                                              .isInvoice
                                          ? theme
                                              .lightModeColor
                                              .prColor250
                                          : Colors.grey,
                                ),
                              ),
                              child: Icon(
                                size: 14,
                                color:
                                    returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .isInvoice
                                        ? Colors.white
                                        : Colors
                                            .grey
                                            .shade400,
                                Icons.check,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Builder(
                builder: (context) {
                  if (products.isEmpty &&
                      returnSalesProviderContext(
                        context,
                      ).currentCart().cartItems.isEmpty) {
                    if (!authorization(
                      authorized:
                          Authorizations().addProduct,
                    )) {
                      return Column(
                        children: [
                          Expanded(
                            child: EmptyWidgetDisplayOnly(
                              title: 'No Items',
                              subText:
                                  'No Items have been added to your stock.',
                              theme: theme,
                              height: 30,
                              icon: Icons.clear,
                              altAction: () {
                                returnSalesProvider()
                                    .toggleAddToStock(
                                      false,
                                      context,
                                    );
                                makeCustomSale(
                                  closeAction: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  },
                                  cartItem: TempCartItem(
                                    useWholeSalePrice:
                                        false,
                                    setTotalPrice:
                                        returnSalesProvider()
                                            .setTotalPrice,
                                    item: TempProductClass(
                                      departmentName:
                                          returnDepartmentProvider()
                                              .currentDepartment()
                                              ?.name,
                                      departmentUuid:
                                          returnDepartmentProvider()
                                              .currentDepartment()
                                              ?.uuid,
                                      groupUnit: 'Others',
                                      qttyPerGroup: null,
                                      isManaged: false,
                                      uuid: uuidGen(),
                                      name: nameC.text,
                                      unit: 'Others',
                                      isRefundable: false,
                                      costPrice:
                                          double.tryParse(
                                            costPriceC.text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0,
                                      sellingPrice:
                                          double.tryParse(
                                            sellingPriceC
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      wholeSalePrice:
                                          double.tryParse(
                                            wholeSalePriceC
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      quantity: 0,
                                      shopId:
                                          returnShopProvider()
                                              .userShop()!
                                              .shopId!,
                                      setCustomPrice: true,
                                    ),
                                    addToStock: false,
                                    quantity: 0,
                                    discount: null,
                                    setCustomPrice: true,
                                  ),
                                );
                              },
                              altActionText:
                                  'Add Custom Item',
                              altIcon: Icons.add,
                            ),
                          ),
                          EmptyCartBottomWidget(
                            action: () {
                              returnSalesProvider()
                                  .toggleAddToStock(
                                    false,
                                    context,
                                  );
                              makeCustomSale(
                                closeAction: () {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                },
                                cartItem: TempCartItem(
                                  useWholeSalePrice: false,
                                  setTotalPrice:
                                      returnSalesProvider()
                                          .setTotalPrice,
                                  item: TempProductClass(
                                    departmentName:
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.name,
                                    departmentUuid:
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.uuid,
                                    groupUnit: 'Others',
                                    qttyPerGroup: null,
                                    isManaged: false,
                                    uuid: uuidGen(),
                                    name: nameC.text,
                                    unit: 'Others',
                                    isRefundable: false,
                                    costPrice:
                                        double.tryParse(
                                          costPriceC.text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0,
                                    sellingPrice:
                                        double.tryParse(
                                          sellingPriceC.text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ),
                                    wholeSalePrice:
                                        double.tryParse(
                                          wholeSalePriceC
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ),
                                    quantity: 0,
                                    shopId:
                                        returnShopProvider()
                                            .userShop()!
                                            .shopId!,
                                    setCustomPrice: true,
                                  ),
                                  addToStock: true,
                                  quantity: 0,
                                  discount: null,
                                  setCustomPrice: true,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                              child: SingleChildScrollView(
                                child: EmptyWidgetDisplay(
                                  title: 'No items',
                                  subText:
                                      'You currently do not have have any item. Add items to start making sales.',
                                  theme: theme,
                                  height: 30,
                                  svg: productIconSvg,
                                  buttonText: 'Add Item',
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddProduct();
                                        },
                                      ),
                                    ).then((_) {
                                      setState(() {});
                                    });
                                  },
                                  altAction: () {
                                    returnSalesProvider()
                                        .toggleAddToStock(
                                          false,
                                          context,
                                        );
                                    makeCustomSale(
                                      closeAction: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                      cartItem: TempCartItem(
                                        useWholeSalePrice:
                                            false,
                                        setTotalPrice:
                                            returnSalesProvider()
                                                .setTotalPrice,
                                        item: TempProductClass(
                                          departmentName:
                                              returnDepartmentProvider()
                                                  .currentDepartment()
                                                  ?.name,
                                          departmentUuid:
                                              returnDepartmentProvider()
                                                  .currentDepartment()
                                                  ?.uuid,
                                          groupUnit:
                                              'Others',
                                          qttyPerGroup:
                                              null,
                                          isManaged: false,
                                          uuid: uuidGen(),
                                          name: nameC.text,
                                          unit: 'Others',
                                          isRefundable:
                                              false,
                                          costPrice:
                                              double.tryParse(
                                                costPriceC
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0,
                                          sellingPrice:
                                              double.tryParse(
                                                sellingPriceC
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ),
                                          wholeSalePrice:
                                              double.tryParse(
                                                wholeSalePriceC
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ),
                                          quantity: 0,
                                          shopId:
                                              returnShopProvider()
                                                  .userShop()!
                                                  .shopId!,
                                          setCustomPrice:
                                              true,
                                        ),
                                        addToStock: true,
                                        quantity: 0,
                                        discount: null,
                                        setCustomPrice:
                                            true,
                                      ),
                                    );
                                  },
                                  altActionText:
                                      'Add Custom Item',
                                  altIcon: Icons.add,
                                ),
                              ),
                            ),
                          ),
                          EmptyCartBottomWidget(
                            action: () {
                              returnSalesProvider()
                                  .toggleAddToStock(
                                    false,
                                    context,
                                  );
                              makeCustomSale(
                                closeAction: () {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                },
                                cartItem: TempCartItem(
                                  useWholeSalePrice: false,
                                  setTotalPrice:
                                      returnSalesProvider()
                                          .setTotalPrice,
                                  item: TempProductClass(
                                    departmentName:
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.name,
                                    departmentUuid:
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.uuid,
                                    groupUnit: 'Others',
                                    qttyPerGroup: null,
                                    isManaged: false,
                                    uuid: uuidGen(),
                                    name: nameC.text,
                                    unit: 'Others',
                                    isRefundable: false,
                                    costPrice:
                                        double.tryParse(
                                          costPriceC.text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0,
                                    sellingPrice:
                                        double.tryParse(
                                          sellingPriceC.text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ),
                                    wholeSalePrice:
                                        double.tryParse(
                                          wholeSalePriceC
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ),
                                    quantity: 0,
                                    shopId:
                                        returnShopProvider()
                                            .userShop()!
                                            .shopId!,
                                    setCustomPrice: true,
                                  ),
                                  addToStock: true,
                                  quantity: 0,
                                  discount: null,
                                  setCustomPrice: true,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  } else {
                    return Stack(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 0.0,
                              ),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Expanded(
                                flex:
                                    returnSalesProviderContext(
                                          context,
                                        ).isSubStaffSelectionMobileOpen
                                        ? 3
                                        : 9,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Expanded(
                                        child: Builder(
                                          builder: (
                                            context,
                                          ) {
                                            List<
                                              TempCartItem
                                            >
                                            items =
                                                returnSalesProviderContext(
                                                      context,
                                                    )
                                                    .currentCart()
                                                    .cartItems
                                                    .reversed
                                                    .toList();

                                            if (items
                                                .isEmpty) {
                                              return SingleChildScrollView(
                                                child: EmptyWidgetDisplay(
                                                  title:
                                                      'Cart List Empty',
                                                  subText:
                                                      'Start Adding Items to Cart To make Sales',
                                                  buttonText:
                                                      'Add Item',
                                                  svg:
                                                      productIconSvg,
                                                  theme:
                                                      theme,
                                                  height:
                                                      35,
                                                  action: () {
                                                    showGeneralDialog(
                                                      context:
                                                          context,
                                                      pageBuilder: (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) {
                                                        return CustomBottomPanel(
                                                          searchController:
                                                              widget.searchController,
                                                          close: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            widget.searchController.clear();
                                                          },
                                                          // products:
                                                          //     products,
                                                        );
                                                      },
                                                    );
                                                  },
                                                  altAction: () {
                                                    returnSalesProvider().toggleAddToStock(
                                                      false,
                                                      context,
                                                    );
                                                    makeCustomSale(
                                                      closeAction: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      cartItem: TempCartItem(
                                                        useWholeSalePrice:
                                                            false,
                                                        setTotalPrice:
                                                            returnSalesProvider().setTotalPrice,
                                                        item: TempProductClass(
                                                          departmentName:
                                                              returnDepartmentProvider().currentDepartment()?.name,
                                                          departmentUuid:
                                                              returnDepartmentProvider().currentDepartment()?.uuid,
                                                          groupUnit:
                                                              'Others',
                                                          qttyPerGroup:
                                                              null,
                                                          isManaged:
                                                              false,
                                                          uuid:
                                                              uuidGen(),
                                                          name:
                                                              nameC.text,
                                                          unit:
                                                              'Others',
                                                          isRefundable:
                                                              false,
                                                          costPrice:
                                                              double.tryParse(
                                                                costPriceC.text.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0,
                                                          sellingPrice: double.tryParse(
                                                            sellingPriceC.text.replaceAll(
                                                              ',',
                                                              '',
                                                            ),
                                                          ),
                                                          wholeSalePrice: double.tryParse(
                                                            wholeSalePriceC.text.replaceAll(
                                                              ',',
                                                              '',
                                                            ),
                                                          ),
                                                          quantity:
                                                              0,
                                                          shopId:
                                                              returnShopProvider().userShop()!.shopId!,
                                                          setCustomPrice:
                                                              true,
                                                        ),
                                                        addToStock:
                                                            true,
                                                        quantity:
                                                            0,
                                                        discount:
                                                            null,
                                                        setCustomPrice:
                                                            true,
                                                      ),
                                                    );
                                                  },
                                                  altActionText:
                                                      'Add Custom Item',
                                                  altIcon:
                                                      Icons
                                                          .add,
                                                ),
                                              );
                                            } else {
                                              return ListView.builder(
                                                itemCount:
                                                    returnSalesProviderContext(
                                                          context,
                                                        )
                                                        .currentCart()
                                                        .cartItems
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  return CartItemMain(
                                                    deleteCartItem: () {
                                                      showDialog(
                                                        context:
                                                            context,
                                                        builder: (
                                                          confirmContext,
                                                        ) {
                                                          return ConfirmationAlert(
                                                            theme:
                                                                theme,
                                                            message:
                                                                'You want to remove an Item from the List, are you sure you want to proceed?',
                                                            title:
                                                                'Remove Item?',
                                                            action: () {
                                                              Navigator.of(
                                                                confirmContext,
                                                              ).pop();
                                                              returnSalesProvider().removeItemFromCart(
                                                                items[index],
                                                                context,
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                    editAction: () {
                                                      var salesProvider =
                                                          returnSalesProvider();

                                                      if (returnData()
                                                          .productList()
                                                          .where(
                                                            (
                                                              product,
                                                            ) =>
                                                                product.uuid ==
                                                                items[index].item.uuid,
                                                          )
                                                          .isNotEmpty) {
                                                        editCartItem(
                                                          productQuantity:
                                                              items[index].quantity,
                                                          context:
                                                              context,
                                                          updateAction: () {
                                                            items[index].useWholeSalePrice = useWholeSalePriceTemp;
                                                            salesProvider.editCartItemQuantity(
                                                              setTotalPrice:
                                                                  returnSalesProvider().setTotalPrice,
                                                              cartItem:
                                                                  items[index],
                                                              number: double.parse(
                                                                quantityController.text.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ),
                                                              customPrice: double.tryParse(
                                                                priceController.text.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ),
                                                              setCustomPrice:
                                                                  priceController.text.isNotEmpty,
                                                            );
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          cartItem:
                                                              items[index],
                                                        );
                                                      } else {
                                                        returnSalesProvider().toggleAddToStock(
                                                          false,
                                                          context,
                                                        );
                                                        makeCustomSale(
                                                          closeAction: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          cartItem:
                                                              items[index],
                                                        );
                                                      }
                                                    },
                                                    theme:
                                                        theme,
                                                    cartItem:
                                                        items[index],
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
                              Expanded(
                                flex:
                                    returnSalesProviderContext(
                                          context,
                                        ).isSubStaffSelectionMobileOpen
                                        ? 15
                                        : 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .grey
                                            .shade100,
                                    borderRadius:
                                        BorderRadius.only(
                                          topLeft:
                                              Radius.circular(
                                                30,
                                              ),
                                          topRight:
                                              Radius.circular(
                                                30,
                                              ),
                                        ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                          30,
                                          10,
                                          30,
                                          0,
                                        ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              SubWrapper(
                                                isVisible:
                                                    !SalesAuthAction().useBarcodeAction(
                                                      context:
                                                          context,
                                                    ),
                                                mainWidget: Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      SalesAuthAction().useBarcodeAction(
                                                        context:
                                                            context,
                                                        action: () async {
                                                          String?
                                                          result = await scanCode(
                                                            context,
                                                            'Failed',
                                                          );
                                                          if (result !=
                                                              null) {
                                                            var prod =
                                                                returnData()
                                                                    .productList()
                                                                    .where(
                                                                      (
                                                                        pro,
                                                                      ) =>
                                                                          pro.barcode ==
                                                                          result,
                                                                    )
                                                                    .toList();
                                                            if (prod.isNotEmpty) {
                                                              var pro =
                                                                  prod.first;
                                                              returnSalesProvider().addItemToCart(
                                                                // ignore: use_build_context_synchronously
                                                                context:
                                                                    context,
                                                                newItem: TempCartItem(
                                                                  useWholeSalePrice:
                                                                      false,
                                                                  setCustomPrice:
                                                                      false,
                                                                  item:
                                                                      pro,
                                                                  quantity:
                                                                      1,
                                                                  discount:
                                                                      null,
                                                                  addToStock:
                                                                      false,
                                                                  setTotalPrice:
                                                                      false,
                                                                ),
                                                                isCustomEdit:
                                                                    false,
                                                              );

                                                              setState(
                                                                () {},
                                                              );
                                                            } else {
                                                              showDialog(
                                                                // ignore: use_build_context_synchronously
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (
                                                                      _,
                                                                    ) => InfoAlert(
                                                                      title:
                                                                          "Item Not Registered",
                                                                      message:
                                                                          "No Item is registered with this barcode on your inventory.",
                                                                      theme: returnTheme(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      ),
                                                                    ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        vertical:
                                                            6,
                                                        horizontal:
                                                            10,
                                                      ),
                                                      child: Row(
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
                                                            'Scan Barcode',
                                                          ),
                                                          Icon(
                                                            size:
                                                                20,
                                                            color:
                                                                theme.lightModeColor.secColor200,
                                                            Icons.qr_code_scanner,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DiscountSetterWidget(
                                                discountPercentController:
                                                    discountPercentController,
                                                addListener:
                                                    () {},
                                                removeListener:
                                                    () {},
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Expanded(
                                                child: CartQueueMobile(
                                                  isFirst:
                                                      true,
                                                ),
                                              ),
                                              SubStaffToggleButtonMobile(
                                                isFirst:
                                                    true,
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible:
                                                returnSalesProviderContext(
                                                  context,
                                                ).isSubStaffSelectionMobileOpen,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                SubStaffSelectionWidget(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              spacing: 10,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      returnData()
                                                          .productList()
                                                          .isNotEmpty,
                                                  child: Expanded(
                                                    child: Ink(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            theme.lightModeColor.prColor300,
                                                        borderRadius: BorderRadius.circular(
                                                          5,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          showGeneralDialog(
                                                            context:
                                                                context,
                                                            pageBuilder: (
                                                              context,
                                                              animation,
                                                              secondaryAnimation,
                                                            ) {
                                                              return CustomBottomPanel(
                                                                searchController:
                                                                    widget.searchController,
                                                                close: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                            vertical:
                                                                8,
                                                          ),

                                                          child: Row(
                                                            spacing:
                                                                5,
                                                            mainAxisSize:
                                                                MainAxisSize.min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.center,
                                                            children: [
                                                              Visibility(
                                                                visible:
                                                                    MediaQuery.of(
                                                                      context,
                                                                    ).size.width >
                                                                    300,
                                                                child: Icon(
                                                                  color:
                                                                      Colors.white,
                                                                  size:
                                                                      15,
                                                                  Icons.add_rounded,
                                                                ),
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.white,
                                                                  fontWeight:
                                                                      FontWeight.w500,
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                ),
                                                                'Add Item',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: SubWrapper(
                                                    isVisible:
                                                        !SalesAuthAction().addCustomItemToCartAction(
                                                          context:
                                                              context,
                                                        ),
                                                    mainWidget: Ink(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          2,
                                                        ),
                                                        border: Border.all(
                                                          color:
                                                              theme.lightModeColor.prColor300,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          returnSalesProvider().toggleAddToStock(
                                                            false,
                                                            context,
                                                          );
                                                          makeCustomSale(
                                                            closeAction: () {
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                            },
                                                            cartItem: TempCartItem(
                                                              useWholeSalePrice:
                                                                  false,
                                                              setTotalPrice:
                                                                  returnSalesProvider().setTotalPrice,
                                                              item: TempProductClass(
                                                                departmentName:
                                                                    returnDepartmentProvider().currentDepartment()?.name,
                                                                departmentUuid:
                                                                    returnDepartmentProvider().currentDepartment()?.uuid,
                                                                groupUnit:
                                                                    'Others',
                                                                qttyPerGroup:
                                                                    null,
                                                                isManaged:
                                                                    false,
                                                                uuid:
                                                                    uuidGen(),
                                                                name:
                                                                    nameC.text,
                                                                unit:
                                                                    'Others',
                                                                isRefundable:
                                                                    false,
                                                                costPrice:
                                                                    double.tryParse(
                                                                      costPriceC.text.replaceAll(
                                                                        ',',
                                                                        '',
                                                                      ),
                                                                    ) ??
                                                                    0,
                                                                sellingPrice: double.tryParse(
                                                                  sellingPriceC.text.replaceAll(
                                                                    ',',
                                                                    '',
                                                                  ),
                                                                ),
                                                                wholeSalePrice: double.tryParse(
                                                                  wholeSalePriceC.text.replaceAll(
                                                                    ',',
                                                                    '',
                                                                  ),
                                                                ),
                                                                quantity:
                                                                    0,
                                                                shopId:
                                                                    returnShopProvider().userShop()!.shopId!,
                                                                setCustomPrice:
                                                                    true,
                                                              ),
                                                              addToStock:
                                                                  true,
                                                              quantity:
                                                                  0,
                                                              discount:
                                                                  null,
                                                              setCustomPrice:
                                                                  true,
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                            vertical:
                                                                7,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b3.fontSize,
                                                              ),
                                                              'Add Custom Item',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                                'Subtotal',
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                                formatMoneyBig(
                                                  amount:
                                                      returnSalesProviderContext(
                                                        context,
                                                      ).calcSubTotal(),
                                                  context:
                                                      context,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible:
                                                returnSalesProviderContext(
                                                      context,
                                                    ).currentCart().discount !=
                                                    null ||
                                                returnSalesProviderContext(
                                                      context,
                                                    ).currentCart().fixedDiscount !=
                                                    null,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 0,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                          'Discount',
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              returnSalesProviderContext(
                                                                context,
                                                              ).currentCart().discount !=
                                                              null,
                                                          child: Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              // fontWeight: FontWeight.bold,
                                                            ),
                                                            ' (${returnSalesProviderContext(context).currentCart().discount?.toString()}%)',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                      '- ${formatMoney(returnSalesProviderContext(context).calcDiscountMain(), context)}',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                        'VAT',
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                        ' (${returnShopProvider().getVat()}%)',
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                    formatMoney(
                                                      returnSalesProviderContext(
                                                        context,
                                                      ).calcVatAmount(),
                                                      context,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 0,
                                          ),
                                          Row(
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
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
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
                                                      FontWeight
                                                          .bold,
                                                ),
                                                formatMoneyBig(
                                                  amount:
                                                      returnSalesProviderContext(
                                                        context,
                                                      ).calcFinalTotal(),
                                                  context:
                                                      context,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          MainButtonP(
                                            themeProvider:
                                                theme,
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return MakeSalesTwo(
                                                      totalAmount:
                                                          returnSalesProvider().calcFinalTotal(),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            text:
                                                'Proceed to Check Out',
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: showBottomPanel,
                          child: CustomBottomPanel(
                            // products: products,
                            searchController:
                                widget.searchController,
                            close: () {
                              setState(() {
                                showBottomPanel = false;
                                widget.searchController
                                    .clear();
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              Visibility(
                visible: false,
                // returnSalesProvider(
                //   context,
                // ).currentCart().cartItems.isNotEmpty,
                child: Align(
                  alignment: Alignment(0.9, 0.06),
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              35,
                              0,
                              0,
                              0,
                            ),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) {
                              return MyCalculator();
                            },
                          );
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  35,
                                  0,
                                  0,
                                  0,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Icon(
                              size: 30,
                              Icons.calculate_outlined,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubStaffToggleButtonMobile extends StatefulWidget {
  final bool isFirst;
  const SubStaffToggleButtonMobile({
    super.key,
    required this.isFirst,
  });

  @override
  State<SubStaffToggleButtonMobile> createState() =>
      _SubStaffToggleButtonMobileState();
}

class _SubStaffToggleButtonMobileState
    extends State<SubStaffToggleButtonMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnSalesProvider().toggleSubStaffSelectionMobile(
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:
          returnShopProvider(
            context: context,
          ).userShop()?.bulkSale ==
          true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color:
                widget.isFirst
                    ? Colors.white
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              returnSalesProvider()
                  .toggleSubStaffSelectionMobile(
                    !returnSalesProvider()
                        .isSubStaffSelectionMobileOpen,
                  );
            },
            child: Container(
              padding: EdgeInsets.all(7),

              child: Icon(
                size: 24,
                color:
                    widget.isFirst
                        ? Colors.grey
                        : Colors.grey.shade800,
                returnSalesProvider()
                        .isSubStaffSelectionMobileOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyCartBottomWidget extends StatelessWidget {
  final Function()? action;
  const EmptyCartBottomWidget({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              spacing: 5,
              children: [
                Expanded(
                  child: CartQueueMobile(isFirst: true),
                ),
                SubStaffToggleButtonMobile(isFirst: true),
              ],
            ),
            Visibility(
              visible:
                  returnSalesProviderContext(
                    context,
                  ).isSubStaffSelectionMobileOpen,
              child: Column(
                children: [
                  SizedBox(height: 2),
                  SubStaffSelectionWidget(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Material(
              color: Colors.transparent,
              child: SubWrapper(
                isVisible:
                    !SalesAuthAction()
                        .addCustomItemToCartAction(
                          context: context,
                        ),
                mainWidget: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color:
                          theme.lightModeColor.prColor300,
                    ),
                  ),
                  child: InkWell(
                    onTap: action,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      child: Center(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          'Add Custom Item',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
