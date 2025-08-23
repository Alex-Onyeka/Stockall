import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/product_suggestions_class.dart';
import 'package:stockall/classes/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/buttons/toggle_total_price.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/my_calculator.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/cart_item_main.dart';
import 'package:stockall/pages/sales/make_sales/page2/make_sales_two.dart';

class MakeSalesDesktop extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isMain;
  final bool? isInvoice;
  const MakeSalesDesktop({
    super.key,
    required this.searchController,
    this.isMain,
    this.isInvoice,
  });

  @override
  State<MakeSalesDesktop> createState() =>
      _MakeSalesDesktopState();
}

class _MakeSalesDesktopState
    extends State<MakeSalesDesktop> {
  bool isLoading = false;
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController priceController =
      TextEditingController();

  String formatSellingPriceEdit(TempCartItem cartItem) {
    if (priceController.text.isNotEmpty) {
      if (returnSalesProvider(context).setTotalPrice) {
        return priceController.text.replaceAll(',', '');
      } else {
        return (int.parse(
                  priceController.text.isNotEmpty
                      ? priceController.text.replaceAll(
                        ',',
                        '',
                      )
                      : '0',
                ) *
                qqty.toInt())
            .toString();
      }
    } else {
      return (qqty * (cartItem.item.sellingPrice!))
          .toString();
    }
  }

  double currentValue = 0;
  double qqty = 0;
  void editCartItem({
    required double productQuantity,
    required BuildContext context,
    required Function()? updateAction,
    required TempCartItem cartItem,
  }) {
    var theme = returnTheme(context, listen: false);
    quantityController.text = cartItem.quantity.toString();
    double qqty = cartItem.quantity.toDouble();
    cartItem.setCustomPrice
        ? priceController.text =
            cartItem.customPrice.toString().split('.')[0]
        : priceController.text = "";

    returnSalesProvider(
      context,
      listen: false,
    ).toggleSetTotalPrice(cartItem.setTotalPrice);
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
                            (returnSalesProvider(
                                      context,
                                    ).isSetCustomPrice ||
                                    cartItem
                                        .setCustomPrice) &&
                                cartItem
                                    .item
                                    .setCustomPrice ||
                            cartItem.item.sellingPrice ==
                                null,
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
                                      returnSalesProvider(
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
                                double.tryParse(value) ?? 0;
                            if (cartItem.item.isManaged) {
                              if (parsedValue >
                                      (cartItem
                                              .item
                                              .quantity ??
                                          0) &&
                                  cartItem.item.id! > 80) {
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
                            cartItem.item.setCustomPrice,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                returnSalesProvider(
                                  context,
                                  listen: false,
                                ).toggleSetCustomPrice();
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
                                      returnSalesProvider(
                                            context,
                                          ).isSetCustomPrice
                                          ? 'Cancel Custom Price'
                                          : 'Set Custom Price',
                                    ),
                                    Stack(
                                      children: [
                                        Visibility(
                                          visible:
                                              returnSalesProvider(
                                                context,
                                              ).isSetCustomPrice ==
                                              false,
                                          child:
                                              SvgPicture.asset(
                                                editIconSvg,
                                                height: 20,
                                              ),
                                        ),
                                        Visibility(
                                          visible:
                                              returnSalesProvider(
                                                context,
                                              ).isSetCustomPrice ==
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
                                  priceController
                                          .text
                                          .isNotEmpty
                                      ? returnSalesProvider(
                                            context,
                                          ).setTotalPrice
                                          ? priceController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              )
                                          : (int.parse(
                                                    priceController.text.isNotEmpty
                                                        ? priceController.text.replaceAll(
                                                          ',',
                                                          '',
                                                        )
                                                        : '0',
                                                  ) *
                                                  qqty.toInt())
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

                              // priceController.text.isEmpty
                              //     ? formatMoneyMid(
                              //       qqty *
                              //           (returnSalesProvider(
                              //             context,
                              //             listen: false,
                              //           ).discountCheck(
                              //             cartItem.item,
                              //           )),
                              //       context,
                              //     )
                              //     : formatMoneyMid(
                              //       double.tryParse(
                              //             priceController.text
                              //                 .replaceAll(
                              //                   ',',
                              //                   '',
                              //                 ),
                              //           ) ??
                              //           0,
                              //       context,
                              //     ),
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
                                                0) &&
                                        cartItem.item.id! >
                                            80) {
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
        returnSalesProvider(
          context,
          listen: false,
        ).closeCustomPrice();
        returnSalesProvider(
          context,
          listen: false,
        ).toggleSetTotalPrice(false);
      }
    });
  }

  TextEditingController pName = TextEditingController();
  TextEditingController pQuantity = TextEditingController();
  TextEditingController costPriceC =
      TextEditingController();
  TextEditingController sellingPriceC =
      TextEditingController();
  TextEditingController nameC = TextEditingController();
  bool resultOn = false;

  String formatSellingPrice() {
    if (sellingPriceC.text.isNotEmpty) {
      if (returnSalesProvider(context).setTotalPrice) {
        return sellingPriceC.text.replaceAll(',', '');
      } else {
        return (int.parse(
                  sellingPriceC.text.isNotEmpty
                      ? sellingPriceC.text.replaceAll(
                        ',',
                        '',
                      )
                      : '0',
                ) *
                qqty.toInt())
            .toString();
      }
    } else {
      return '0.0';
    }
  }

  void makeCustomSale({
    required TempCartItem cartItem,
    required Function() closeAction,
  }) {
    var theme = returnTheme(context, listen: false);
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
                                onChanged: (value) {
                                  final suggestions =
                                      returnSuggestionProvider(
                                        context,
                                        listen: false,
                                      ).suggestions;

                                  if (nameC
                                      .text
                                      .isNotEmpty) {
                                    final hasMatch =
                                        suggestions.any(
                                          (item) => item
                                              .name!
                                              .toLowerCase()
                                              .contains(
                                                value
                                                    .toLowerCase(),
                                              ),
                                        );

                                    setState(() {
                                      resultOn = hasMatch;
                                    });
                                  } else {
                                    setState(() {
                                      resultOn = false;
                                    });
                                  }
                                },
                              ),

                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                spacing: 10,
                                children: [
                                  // Expanded(
                                  //   child: MoneyTextfield(
                                  //     title:
                                  //         'Cost Price (Optional)',
                                  //     hint: 'Enter Price',
                                  //     controller:
                                  //         costPriceC,
                                  //     theme: theme,
                                  //     onChanged: (p0) {
                                  //       setState(() {});
                                  //     },
                                  //   ),
                                  // ),
                                  Expanded(
                                    child:
                                        ToggleTotalPriceWidget(
                                          theme: theme,
                                        ),
                                  ),
                                  Expanded(
                                    child: MoneyTextfield(
                                      title:
                                          returnSalesProvider(
                                                context,
                                              ).setTotalPrice
                                              ? 'Total Price'
                                              : 'Individual Price',
                                      hint: 'Enter Price',
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
                                      Colors.grey.shade200,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 50.0,
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
                                          context: context,
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
                                      value,
                                    ) ??
                                    0;

                                if (value.isEmpty) {
                                  setState(() {
                                    pQuantity.text = '0';
                                  });
                                }

                                setState(() {
                                  qqty = entered;
                                });
                              },

                              title: 'Enter Item Quantity',
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
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        );
                                    showDialog(
                                      context: context,
                                      builder: (context) {
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
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            20,
                                          ),
                                      border: Border.all(
                                        color:
                                            returnSalesProvider(
                                                  context,
                                                ).addToStock
                                                ? theme
                                                    .lightModeColor
                                                    .prColor250
                                                : Colors
                                                    .grey,
                                      ),
                                      color:
                                          returnSalesProvider(
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
                                          returnSalesProvider(
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
                                                returnSalesProvider(
                                                      context,
                                                    ).addToStock
                                                    ? Colors
                                                        .white
                                                    : Colors
                                                        .grey
                                                        .shade600,
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
                                  MainAxisAlignment.center,
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
                                MainAxisAlignment.center,
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
                                  var sugP =
                                      returnSuggestionProvider(
                                        context,
                                        listen: false,
                                      );
                                  var productIndex = returnData(
                                    context,
                                    listen: false,
                                  ).productList.indexWhere((
                                    item,
                                  ) {
                                    return item.name
                                            .toLowerCase() ==
                                        nameC.text
                                            .toLowerCase();
                                  });
                                  var cartItems =
                                      returnSalesProvider(
                                        context,
                                        listen: false,
                                      ).cartItems;
                                  final index = cartItems
                                      .indexWhere((item) {
                                        return item
                                                .item
                                                .name
                                                .toLowerCase() ==
                                            nameC.text
                                                .toLowerCase();
                                      });
                                  if (nameC.text.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'Item Name must be set before item can be added to cart.',
                                          title:
                                              'Item not set.',
                                        );
                                      },
                                    );
                                  } else if (index != -1) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
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
                                  } else if (productIndex !=
                                      -1) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
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
                                        context: context,
                                        builder: (context) {
                                          return InfoAlert(
                                            theme: theme,
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
                                          returnSalesProvider(
                                            context,
                                            listen: false,
                                          ).setTotalPrice;
                                      cartItem.item.name =
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
                                      cartItem.item.id =
                                          returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .cartItems
                                                  .isNotEmpty
                                              ? returnSalesProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      )
                                                      .cartItems
                                                      .where(
                                                        (
                                                          item,
                                                        ) =>
                                                            item.item.id! <
                                                            100,
                                                      )
                                                      .isNotEmpty
                                                  ? returnSalesProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          )
                                                          .cartItems
                                                          .where(
                                                            (
                                                              item,
                                                            ) =>
                                                                item.item.id! <
                                                                100,
                                                          )
                                                          .last
                                                          .item
                                                          .id! +
                                                      1
                                                  : 1
                                              : 1;
                                      cartItem.addToStock =
                                          returnSalesProvider(
                                            context,
                                            listen: false,
                                          ).addToStock;

                                      returnSalesProvider(
                                        context,
                                        listen: false,
                                      ).addItemToCart(
                                        cartItem,
                                      );
                                      sugP.addTempSugg(
                                        ProductSuggestion(
                                          createdAt:
                                              DateTime.now(),
                                          shopId: shopId(
                                            context,
                                          ),
                                          costPrice:
                                              double.tryParse(
                                                costPriceC
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ),
                                          name: nameC.text,
                                          id:
                                              cartItem
                                                  .item
                                                  .id,
                                        ),
                                      );
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
                      Visibility(
                        visible: resultOn,
                        child: Positioned(
                          top: 80,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width:
                                  MediaQuery.of(
                                    context,
                                  ).size.width -
                                  60,
                              padding: EdgeInsets.fromLTRB(
                                20,
                                5,
                                20,
                                20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 5,
                                    color:
                                        const Color.fromARGB(
                                          27,
                                          0,
                                          0,
                                          0,
                                        ),
                                  ),
                                ],
                              ),
                              child: Column(
                                // crossAxisAlignment:
                                //     CrossAxisAlignment.end,
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
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
                                                  .b2
                                                  .fontSize,
                                        ),
                                        'Suggestion Results',
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            resultOn =
                                                false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 180,
                                    child: ListView.builder(
                                      itemCount:
                                          returnSuggestionProvider(
                                                context,
                                              ).suggestions
                                              .where(
                                                (
                                                  sugg,
                                                ) => sugg
                                                    .name!
                                                    .toLowerCase()
                                                    .contains(
                                                      nameC
                                                          .text
                                                          .toLowerCase(),
                                                    ),
                                              )
                                              .length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        var suggestions =
                                            returnSuggestionProvider(
                                                  context,
                                                )
                                                .suggestions
                                                .where(
                                                  (
                                                    sugg,
                                                  ) => sugg
                                                      .name!
                                                      .toLowerCase()
                                                      .contains(
                                                        nameC.text.toLowerCase(),
                                                      ),
                                                )
                                                .toList();

                                        var suggestion =
                                            suggestions[index];
                                        return Material(
                                          color:
                                              Colors
                                                  .transparent,
                                          child: Ink(
                                            child: InkWell(
                                              onTap: () {
                                                nameC.text =
                                                    suggestion
                                                        .name!;
                                                costPriceC
                                                        .text =
                                                    suggestion.costPrice ==
                                                            null
                                                        ? '0'
                                                        : suggestion.costPrice.toString().split(
                                                          '.',
                                                        )[0];

                                                setState(() {
                                                  resultOn =
                                                      false;
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                ),
                                                padding:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          10,
                                                    ),

                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b2.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      suggestion
                                                          .name!,
                                                    ),
                                                    Row(
                                                      spacing:
                                                          5,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b1.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          '${currencySymbol(context: context)} ${suggestion.costPrice ?? 0}',
                                                        ),
                                                        Icon(
                                                          size:
                                                              20,
                                                          Icons.add,
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            var sugP = returnSuggestionProvider(
                                                              context,
                                                              listen:
                                                                  false,
                                                            );
                                                            var safeContext =
                                                                context;
                                                            showDialog(
                                                              context:
                                                                  context,
                                                              builder: (
                                                                context,
                                                              ) {
                                                                return ConfirmationAlert(
                                                                  theme:
                                                                      theme,
                                                                  message:
                                                                      'Are you sure you want to delete your item suggestion?',
                                                                  title:
                                                                      isLoading
                                                                          ? 'Deleting'
                                                                          : 'Are you sure?',
                                                                  action: () async {
                                                                    Navigator.of(
                                                                      safeContext,
                                                                    ).pop();
                                                                    setState(
                                                                      () {
                                                                        isLoading =
                                                                            true;
                                                                      },
                                                                    );
                                                                    await sugP.deleteSuggestion(
                                                                      suggestion.id!,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        isLoading =
                                                                            false;
                                                                      },
                                                                    );

                                                                    if (context.mounted) {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: Icon(
                                                            size:
                                                                20,
                                                            color: const Color.fromARGB(
                                                              255,
                                                              191,
                                                              76,
                                                              67,
                                                            ),
                                                            Icons.delete_outline_rounded,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
        });
        returnSalesProvider(
          context,
          listen: false,
        ).closeCustomPrice();
        returnSalesProvider(
          context,
          listen: false,
        ).toggleSetTotalPrice(false);
      }
    });
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
          returnSalesProvider(
            context,
            listen: false,
          ).cartItems.isEmpty) {
        returnSalesProvider(
          context,
          listen: false,
        ).onInvoice();
      } else if (widget.isInvoice == null &&
          returnSalesProvider(
            context,
            listen: false,
          ).cartItems.isEmpty) {
        returnSalesProvider(
          context,
          listen: false,
        ).offInvoice();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products = returnData(context).productList;
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),

      child: PopScope(
        canPop: false,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backGroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                color: const Color.fromARGB(
                  201,
                  255,
                  255,
                  255,
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          46,
                          0,
                          0,
                          0,
                        ),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Scaffold(
                    body: Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Visibility(
                            visible:
                                screenWidth(context) > 900,
                            child: MyCalculatorDesktop(),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Stack(
                            children: [
                              Scaffold(
                                appBar: appBar(
                                  // isMain: widget.isMain,
                                  context: context,
                                  title:
                                      returnSalesProvider(
                                            context,
                                          ).isInvoice
                                          ? 'Credit Sale'
                                          : 'Cart Items',
                                  widget: Stack(
                                    children: [
                                      Visibility(
                                        visible:
                                            returnSalesProvider(
                                                  context,
                                                )
                                                .cartItems
                                                .isNotEmpty,
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                context,
                                              ) {
                                                return ConfirmationAlert(
                                                  theme:
                                                      theme,
                                                  message:
                                                      'You are about to clear the items in your cart, are you sure you want to proceed?',
                                                  title:
                                                      'Are you sure?',
                                                  action: () {
                                                    returnSalesProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).clearCart();
                                                    returnSuggestionProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).clearSuggestions();
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 35,
                                            margin:
                                                EdgeInsets.only(
                                                  right: 10,
                                                ),
                                            padding:
                                                EdgeInsets.only(
                                                  // vertical: 10,
                                                  left: 10,
                                                  right: 5,
                                                ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade100,
                                              ),
                                            ),
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Clear Cart',
                                                  ),
                                                  Icon(
                                                    size:
                                                        18,
                                                    color:
                                                        Colors.grey.shade600,
                                                    Icons
                                                        .clear,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            returnSalesProvider(
                                                  context,
                                                )
                                                .cartItems
                                                .isEmpty,
                                        child: InkWell(
                                          onTap: () {
                                            returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).switchInvoiceSale();
                                          },
                                          child: SizedBox(
                                            height: 35,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    right:
                                                        15.0,
                                                    top: 3,
                                                    bottom:
                                                        3,
                                                    left: 5,
                                                  ),
                                              child: Row(
                                                spacing: 5,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Sale Credit',
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(
                                                          2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
                                                      color:
                                                          returnSalesProvider(
                                                                context,
                                                              ).isInvoice
                                                              ? theme.lightModeColor.prColor250
                                                              : null,
                                                      border: Border.all(
                                                        color:
                                                            returnSalesProvider(
                                                                  context,
                                                                ).isInvoice
                                                                ? theme.lightModeColor.prColor250
                                                                : Colors.grey,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      size:
                                                          14,
                                                      color:
                                                          returnSalesProvider(
                                                                context,
                                                              ).isInvoice
                                                              ? Colors.white
                                                              : Colors.grey.shade400,
                                                      Icons
                                                          .check,
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
                                body: Builder(
                                  builder: (context) {
                                    if (products.isEmpty &&
                                        returnSalesProvider(
                                              context,
                                            )
                                            .cartItems
                                            .isEmpty) {
                                      if (!authorization(
                                        authorized:
                                            Authorizations()
                                                .addProduct,
                                        context: context,
                                      )) {
                                        return EmptyWidgetDisplayOnly(
                                          title: 'No Items',
                                          subText:
                                              'No Items have been added to your stock.',
                                          theme: theme,
                                          height: 30,
                                          icon: Icons.clear,
                                          altAction: () {
                                            returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).toggleAddToStock(
                                              true,
                                            );
                                            makeCustomSale(
                                              closeAction: () {
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                              },
                                              cartItem: TempCartItem(
                                                setTotalPrice:
                                                    returnSalesProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).setTotalPrice,
                                                item: TempProductClass(
                                                  isManaged:
                                                      false,
                                                  id: 111,
                                                  name:
                                                      nameC
                                                          .text,
                                                  unit:
                                                      'Others',
                                                  isRefundable:
                                                      false,
                                                  costPrice:
                                                      double.tryParse(
                                                        costPriceC.text,
                                                      ) ??
                                                      0,
                                                  sellingPrice: double.tryParse(
                                                    sellingPriceC
                                                        .text,
                                                  ),
                                                  quantity:
                                                      0,
                                                  shopId:
                                                      returnShopProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).userShop!.shopId!,
                                                  setCustomPrice:
                                                      true,
                                                ),
                                                addToStock:
                                                    false,
                                                quantity: 0,
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
                                              Icons.add,
                                        );
                                      } else {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                    10.0,
                                              ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              EmptyWidgetDisplay(
                                                title:
                                                    'No items',
                                                subText:
                                                    'You currently do not have have any item. Add items to start making sales.',
                                                theme:
                                                    theme,
                                                height: 30,
                                                svg:
                                                    productIconSvg,
                                                buttonText:
                                                    'Add Item',
                                                action: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return AddProduct();
                                                      },
                                                    ),
                                                  ).then((
                                                    _,
                                                  ) {
                                                    setState(
                                                      () {},
                                                    );
                                                  });
                                                },
                                                altAction: () {
                                                  returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).toggleAddToStock(
                                                    true,
                                                  );
                                                  makeCustomSale(
                                                    closeAction: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    cartItem: TempCartItem(
                                                      setTotalPrice:
                                                          returnSalesProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).setTotalPrice,
                                                      item: TempProductClass(
                                                        isManaged:
                                                            false,
                                                        id:
                                                            000,
                                                        name:
                                                            nameC.text,
                                                        unit:
                                                            'Others',
                                                        isRefundable:
                                                            false,
                                                        costPrice:
                                                            double.tryParse(
                                                              costPriceC.text,
                                                            ) ??
                                                            0,
                                                        sellingPrice: double.tryParse(
                                                          sellingPriceC.text,
                                                        ),
                                                        quantity:
                                                            0,
                                                        shopId:
                                                            returnShopProvider(
                                                              context,
                                                              listen:
                                                                  false,
                                                            ).userShop!.shopId!,
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
                                            ],
                                          ),
                                        );
                                      }
                                    } else {
                                      return Stack(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      0.0,
                                                ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      10,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal:
                                                          10.0,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              10,
                                                        ),
                                                        Expanded(
                                                          child: Builder(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              List<
                                                                TempCartItem
                                                              >
                                                              items =
                                                                  returnSalesProvider(
                                                                    context,
                                                                  ).cartItems.reversed.toList();

                                                              if (items.isEmpty) {
                                                                return Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.center,
                                                                  children: [
                                                                    EmptyWidgetDisplay(
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
                                                                        returnSalesProvider(
                                                                          context,
                                                                          listen:
                                                                              false,
                                                                        ).toggleAddToStock(
                                                                          true,
                                                                        );
                                                                        makeCustomSale(
                                                                          closeAction: () {
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                          },
                                                                          cartItem: TempCartItem(
                                                                            setTotalPrice:
                                                                                returnSalesProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).setTotalPrice,
                                                                            item: TempProductClass(
                                                                              isManaged:
                                                                                  false,
                                                                              id:
                                                                                  000,
                                                                              name:
                                                                                  nameC.text,
                                                                              unit:
                                                                                  'Others',
                                                                              isRefundable:
                                                                                  false,
                                                                              costPrice:
                                                                                  double.tryParse(
                                                                                    costPriceC.text,
                                                                                  ) ??
                                                                                  0,
                                                                              sellingPrice: double.tryParse(
                                                                                sellingPriceC.text,
                                                                              ),
                                                                              quantity:
                                                                                  0,
                                                                              shopId:
                                                                                  returnShopProvider(
                                                                                    context,
                                                                                    listen:
                                                                                        false,
                                                                                  ).userShop!.shopId!,
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
                                                                          Icons.add,
                                                                    ),
                                                                  ],
                                                                );
                                                              } else {
                                                                return ListView.builder(
                                                                  itemCount:
                                                                      returnSalesProvider(
                                                                        context,
                                                                      ).cartItems.length,
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
                                                                            context,
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
                                                                                  context,
                                                                                ).pop();
                                                                                returnSalesProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).removeItemFromCart(
                                                                                  items[index],
                                                                                );
                                                                                returnSuggestionProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).deleteTempSugg(
                                                                                  items[index].item.id!,
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      editAction: () {
                                                                        var salesProvider = returnSalesProvider(
                                                                          context,
                                                                          listen:
                                                                              false,
                                                                        );

                                                                        editCartItem(
                                                                          productQuantity:
                                                                              items[index].quantity,
                                                                          context:
                                                                              context,
                                                                          updateAction: () {
                                                                            salesProvider.editCartItemQuantity(
                                                                              setTotalPrice:
                                                                                  returnSalesProvider(
                                                                                    context,
                                                                                    listen:
                                                                                        false,
                                                                                  ).setTotalPrice,
                                                                              cartItem:
                                                                                  items[index],
                                                                              number: double.parse(
                                                                                quantityController.text,
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

                                                                            // Delay pop to avoid context issues

                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                          },
                                                                          cartItem:
                                                                              items[index],
                                                                        );
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
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                showBottomPanel,
                                            child: CustomBottomPanel(
                                              // products: products,
                                              searchController:
                                                  widget
                                                      .searchController,
                                              close: () {
                                                setState(() {
                                                  showBottomPanel =
                                                      false;
                                                  widget
                                                      .searchController
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
                              ),
                              Visibility(
                                visible:
                                    returnSalesProvider(
                                          context,
                                        )
                                        .cartItems
                                        .isNotEmpty &&
                                    screenWidth(context) <
                                        800,
                                child: Align(
                                  alignment: Alignment(
                                    0.9,
                                    0.1,
                                  ),
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              15,
                                            ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                const Color.fromARGB(
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
                                        borderRadius:
                                            BorderRadius.circular(
                                              15,
                                            ),
                                        onTap: () {
                                          showGeneralDialog(
                                            context:
                                                context,
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
                                                BorderRadius.circular(
                                                  15,
                                                ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    const Color.fromARGB(
                                                      35,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                blurRadius:
                                                    10,
                                              ),
                                            ],
                                            color:
                                                Colors
                                                    .white,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              size: 30,
                                              Icons
                                                  .calculate_outlined,
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
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.only(
                                    topLeft:
                                        Radius.circular(15),
                                    topRight:
                                        Radius.circular(15),
                                  ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    15,
                                    50,
                                    15,
                                    15,
                                  ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.start,
                                children: [
                                  Material(
                                    color:
                                        Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      spacing: 10,
                                      children: [
                                        Expanded(
                                          child: SmallButtonMain(
                                            theme: theme,
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
                                                    },
                                                    // products:
                                                    //     products,
                                                  );
                                                },
                                              );
                                            },
                                            buttonText:
                                                'Add Item',
                                          ),
                                        ),
                                        Expanded(
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    5,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .prColor300,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                returnSalesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).toggleAddToStock(
                                                  true,
                                                );
                                                makeCustomSale(
                                                  closeAction: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                  },
                                                  cartItem: TempCartItem(
                                                    setTotalPrice:
                                                        returnSalesProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).setTotalPrice,
                                                    item: TempProductClass(
                                                      isManaged:
                                                          false,
                                                      id: 000,
                                                      name:
                                                          nameC.text,
                                                      unit:
                                                          'Others',
                                                      isRefundable:
                                                          false,
                                                      costPrice:
                                                          double.tryParse(
                                                            costPriceC.text,
                                                          ) ??
                                                          0,
                                                      sellingPrice: double.tryParse(
                                                        sellingPriceC.text,
                                                      ),
                                                      quantity:
                                                          0,
                                                      shopId:
                                                          returnShopProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).userShop!.shopId!,
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
                                                padding:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          9,
                                                    ),
                                                child: Center(
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b2.fontSize,
                                                    ),
                                                    'Add Custom Item',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
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
                                        ),
                                        'Subtotal',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        formatMoneyBig(
                                          amount: returnSalesProvider(
                                            context,
                                          ).calcTotalMain(
                                            returnSalesProvider(
                                              context,
                                            ).cartItems,
                                          ),
                                          context: context,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
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
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        'Discount',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        '- ${formatMoney(returnSalesProvider(context).calcDiscountMain(returnSalesProvider(context).cartItems), context)}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
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
                                                  .h4
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
                                                  .h4
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        formatMoneyBig(
                                          amount: returnSalesProvider(
                                            context,
                                          ).calcFinalTotalMain(
                                            returnSalesProvider(
                                              context,
                                            ).cartItems,
                                          ),
                                          context: context,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  MainButtonP(
                                    themeProvider: theme,
                                    action: () {
                                      if (returnSalesProvider(
                                            context,
                                          )
                                          .cartItems
                                          .isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return MakeSalesTwo(
                                                totalAmount: returnSalesProvider(
                                                  context,
                                                ).calcFinalTotalMain(
                                                  returnSalesProvider(
                                                    context,
                                                  ).cartItems,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                    text:
                                        'Proceed to Check Out',
                                  ),
                                  SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
