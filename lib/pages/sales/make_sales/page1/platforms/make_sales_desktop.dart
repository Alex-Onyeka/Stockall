import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/buttons/toggle_total_price.dart';
import 'package:stockall/components/cart_queue/cart_queue_desktop.dart';
import 'package:stockall/components/discount_setter.dart/discount_setter_widget.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/my_calculator.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/cart_item_main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/select_sub_staff_list_widget.dart';
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
  TextEditingController discountPercentController =
      TextEditingController();
  // final nameController = TextEditingController();

  String formatSellingPriceEdit(TempCartItem cartItem) {
    if (priceController.text.isNotEmpty) {
      if (returnSalesProvider().setTotalPrice) {
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

  final FocusNode qttyNode = FocusNode();

  double currentValue = 0;
  double qqty = 0;
  void editCartItem({
    required double productQuantity,
    required BuildContext context,
    required Function()? updateAction,
    required TempCartItem cartItem,
  }) {
    returnSalesProvider().removeListenerScanBarcode();
    qttyNode.requestFocus();
    var theme = returnTheme(context, listen: false);
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
        return StatefulBuilder(
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
                child: SizedBox(
                  width:
                      screenWidth(context) > 450
                          ? 450
                          : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible:
                            (returnSalesProviderContext(
                                      context,
                                    ).isSetCustomPrice() ||
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
                          focusNode: qttyNode,
                          onSubmitted: (_) {
                            if (quantityController
                                    .text
                                    .isEmpty ||
                                qqty == 0) {
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
                              ).then((context) {
                                qttyNode.requestFocus();
                              });
                            } else {
                              updateAction!();
                            }
                          },
                          onChanged: (value) {
                            final parsedValue =
                                double.tryParse(value) ?? 0;
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
                            cartItem.item.setCustomPrice,
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
                                  priceController
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
              ),
            );
          },
        );
      },
    ).then((value) {
      qqty = 0;
      quantityController.text = '';
      returnSalesProvider().addListenerScanBarcode();
      // nameController.text = '';
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
  TextEditingController nameC = TextEditingController();
  bool resultOn = false;

  String formatSellingPrice() {
    if (sellingPriceC.text.isNotEmpty) {
      if (returnSalesProviderContext(
        context,
      ).setTotalPrice) {
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

  bool isNormalEdit = true;

  FocusNode nameEditNode = FocusNode();

  void makeCustomSale({
    required TempCartItem cartItem,
    required Function() closeAction,
  }) {
    SalesAuthAction().addCustomItemToCartAction(
      context: context,
      action: () {
        var theme = returnTheme(context, listen: false);
        if (returnData().productList
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
          pQuantity.text = cartItem.quantity
              .toStringAsFixed(0);
          sellingPriceC.text = (cartItem.customPrice ?? 0)
              .toStringAsFixed(0);
          returnSalesProvider().toggleAddToStock(
            cartItem.addToStock,
            context,
          );
          returnSalesProvider().toggleSetTotalPrice(
            cartItem.setTotalPrice,
          );
        }
        returnSalesProvider().removeListenerScanBarcode();
        nameEditNode.requestFocus();
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
                                    focusNode: nameEditNode,
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
                                          value,
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
                              Column(
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
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Add Item to your Stock?',
                                        ),
                                        MyToggleButton(
                                          boolValue:
                                              returnSalesProvider()
                                                  .addToStock,
                                          toggle: () {
                                            var salesProvider =
                                                returnSalesProvider();
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
                                                      salesProvider.addToStock
                                                          ? 'This item will not be added to your stock after this sale, are you sure you want to proceed?'
                                                          : 'This item will be automatically added to your stock after this sale, are you sure you want to proceed?',
                                                  title:
                                                      !salesProvider.addToStock
                                                          ? 'Add to Stock?'
                                                          : 'Are you Sure?',
                                                  action: () async {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                    salesProvider.toggleAddToStock(
                                                      salesProvider.addToStock
                                                          ? false
                                                          : true,
                                                      context,
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          theme: theme,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                      // var sugP =
                                      //     returnSuggestionProvider(
                                      //       context,
                                      //       listen: false,
                                      //     );
                                      var productIndex = returnData()
                                          .productList
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
                                                    .productList
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
          returnSalesProvider().addListenerScanBarcode();
          returnSalesProvider().requestFocusScanBarcode();

          nameC.clear();
          pQuantity.clear();
          costPriceC.clear();
          sellingPriceC.clear();
          if (context.mounted) {
            setState(() {
              resultOn = false;
              isNormalEdit = true;
            });
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      returnSalesProvider().requestFocusScanBarcode();
      returnSalesProvider().toggleSetDiscount(
        false,
        context,
      );

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
      for (var cart
          in returnSalesProvider()
              .currentMainCart()
              .cartQueue) {
        await returnMultiDisplayProvider().updateWindow(
          cartClass: AltCartClass(
            cartId: cart.id!,
            currency:
                returnShopProvider().userShop()!.currency,
            cartItems: cart.cartItems.reversed.toList(),
            vat:
                returnShopProvider().userShop()!.applyVAT!
                    ? vat
                    : 0,
            fixedDiscount: cart.fixedDiscount,
            percentDiscount: cart.discount,
          ),
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnMultiDisplayProvider().updateWindow(
        showCart: false,
        cartClass: AltCartClass(
          cartId: returnSalesProvider().currentCart().id!,
          currency:
              returnShopProvider().userShop()!.currency,
          cartItems:
              returnSalesProvider()
                  .currentCart()
                  .cartItems
                  .reversed
                  .toList(),
          fixedDiscount:
              returnSalesProvider()
                  .currentCart()
                  .fixedDiscount,
          percentDiscount:
              returnSalesProvider().currentCart().discount,
          vat:
              returnShopProvider().userShop()!.applyVAT!
                  ? vat
                  : 0,
        ),
      );
    });
    // _node.dispose();
    qttyNode.dispose();
    nameEditNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products = returnData().productList;
    return GestureDetector(
      onTap:
          () =>
              returnSalesProvider()
                  .requestFocusScanBarcode(),
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
                    vertical: 15,
                    horizontal: 10,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
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
                      // spacing: 15,
                      children: [
                        Visibility(
                          visible:
                              screenWidth(context) >
                              tabletScreen,
                          child: Expanded(
                            flex: 4,
                            child: MyCalculatorDesktop(),
                          ),
                        ),
                        Visibility(
                          visible:
                              screenWidth(context) >
                              tabletScreen,
                          child: SizedBox(width: 15),
                        ),
                        Expanded(
                          flex: 10,
                          child: DesktopPageContainer(
                            widget: Scaffold(
                              appBar: appBar(
                                backAction:
                                    returnSalesProvider()
                                            .currentCart()
                                            .isReceiptEdit
                                        ? () {
                                          returnSalesProvider()
                                              .cancelReceiptEdit(
                                                context,
                                              );
                                        }
                                        : null,
                                // isMain: widget.isMain,
                                context: context,
                                title:
                                    returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .isReceiptEdit
                                        ? 'Edit Receipt'
                                        : returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .isInvoice
                                        ? 'Credit Sale'
                                        : 'Cart Items',
                                widget: Stack(
                                  children: [
                                    Visibility(
                                      visible:
                                          returnSalesProviderContext(
                                                context,
                                              )
                                              .currentCart()
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
                                                  returnSalesProvider()
                                                      .clearCart();
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
                                                  size: 18,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade600,
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
                                          returnSalesProviderContext(
                                                context,
                                              )
                                              .currentCart()
                                              .cartItems
                                              .isEmpty,
                                      child: InkWell(
                                        onTap: () {
                                          if (returnSalesProvider()
                                              .currentCart()
                                              .isInvoice) {
                                            returnSalesProvider()
                                                .switchInvoiceSale(
                                                  context:
                                                      context,
                                                  value:
                                                      false,
                                                );
                                          } else {
                                            returnSalesProvider()
                                                .switchInvoiceSale(
                                                  context:
                                                      context,
                                                  value:
                                                      true,
                                                );
                                          }
                                        },
                                        child: SizedBox(
                                          height: 35,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                  right:
                                                      15.0,
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
                                                        returnSalesProviderContext(
                                                              context,
                                                            ).currentCart().isInvoice
                                                            ? theme.lightModeColor.prColor250
                                                            : null,
                                                    border: Border.all(
                                                      color:
                                                          returnSalesProviderContext(
                                                                context,
                                                              ).currentCart().isInvoice
                                                              ? theme.lightModeColor.prColor250
                                                              : Colors.grey,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    size:
                                                        14,
                                                    color:
                                                        returnSalesProviderContext(
                                                              context,
                                                            ).currentCart().isInvoice
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
                                      returnSalesProviderContext(
                                            context,
                                          )
                                          .currentCart()
                                          .cartItems
                                          .isEmpty) {
                                    if (!authorization(
                                      authorized:
                                          Authorizations()
                                              .addProduct,
                                    )) {
                                      return EmptyWidgetDisplayOnly(
                                        title:
                                            'No Products',
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
                                              setTotalPrice:
                                                  returnSalesProvider()
                                                      .setTotalPrice,
                                              item: TempProductClass(
                                                isManaged:
                                                    false,
                                                uuid:
                                                    uuidGen(),
                                                name:
                                                    nameC
                                                        .text,
                                                unit:
                                                    'Others',
                                                isRefundable:
                                                    false,
                                                costPrice:
                                                    double.tryParse(
                                                      costPriceC
                                                          .text,
                                                    ) ??
                                                    0,
                                                sellingPrice:
                                                    double.tryParse(
                                                      sellingPriceC
                                                          .text,
                                                    ),
                                                quantity: 0,
                                                shopId:
                                                    returnShopProvider()
                                                        .userShop()!
                                                        .shopId!,
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
                                        altIcon: Icons.add,
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
                                              theme: theme,
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
                                                ).then((_) {
                                                  setState(
                                                    () {},
                                                  );
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
                                                    setTotalPrice:
                                                        returnSalesProvider().setTotalPrice,
                                                    item: TempProductClass(
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
                                                            costPriceC.text,
                                                          ) ??
                                                          0,
                                                      sellingPrice: double.tryParse(
                                                        sellingPriceC.text,
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
                                                  Icons.add,
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
                                                height: 10,
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
                                                                returnSalesProviderContext(
                                                                  context,
                                                                ).currentCart().cartItems.reversed.toList();

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
                                                                      returnSalesProvider().removeListenerScanBarcode();
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
                                                                      ).then(
                                                                        (
                                                                          _,
                                                                        ) {
                                                                          returnSalesProvider().addListenerScanBarcode();
                                                                          setState(
                                                                            () {
                                                                              returnSalesProvider().requestFocusScanBarcode();
                                                                            },
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
                                                                          setTotalPrice:
                                                                              returnSalesProvider().setTotalPrice,
                                                                          item: TempProductClass(
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
                                                                                  costPriceC.text,
                                                                                ) ??
                                                                                0,
                                                                            sellingPrice: double.tryParse(
                                                                              sellingPriceC.text,
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
                                                                        Icons.add,
                                                                  ),
                                                                ],
                                                              );
                                                            } else {
                                                              return ListView.builder(
                                                                itemCount:
                                                                    returnSalesProviderContext(
                                                                      context,
                                                                    ).currentCart().cartItems.length,
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

                                                                      if (returnData().productList
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
                                                                            salesProvider.editCartItemQuantity(
                                                                              setTotalPrice:
                                                                                  returnSalesProvider().setTotalPrice,
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
                                        Visibility(
                                          visible:
                                              returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .cartItems
                                                  .isNotEmpty &&
                                              screenWidth(
                                                    context,
                                                  ) <
                                                  tabletScreen,
                                          child: Align(
                                            alignment:
                                                Alignment(
                                                  0.9,
                                                  0.1,
                                                ),
                                            child: Material(
                                              color:
                                                  Colors
                                                      .transparent,
                                              child: Ink(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                      blurRadius:
                                                          10,
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
                                                    height:
                                                        60,
                                                    width:
                                                        60,
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
                                                          blurRadius:
                                                              10,
                                                        ),
                                                      ],
                                                      color:
                                                          Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        size:
                                                            30,
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
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          flex:
                              screenWidth(context) <
                                      tabletScreen
                                  ? 6
                                  : 5,
                          child: Container(
                            height: double.infinity,
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
                                    20,
                                    15,
                                    15,
                                  ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                  children: [
                                    Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 5,
                                          ),
                                      width:
                                          double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              8,
                                            ),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          CartQueueDesktop(
                                            theme: theme,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Visibility(
                                            child: SubWrapper(
                                              isVisible:
                                                  !SalesAuthAction().numberOfCartsAction(
                                                    context:
                                                        context,
                                                  ),
                                              mainWidget: Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.lightModeColor.prColor300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await returnSalesProvider().addNewCart(
                                                        context,
                                                        TempCart(
                                                          cartItems:
                                                              [],
                                                          isInvoice:
                                                              false,
                                                        ),
                                                      );
                                                      returnSalesProvider()
                                                          .requestFocusScanBarcode();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          5,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        color:
                                                            Colors.white,
                                                        size:
                                                            15,
                                                        Icons.add,
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
                                    SubStaffSelectionWidget(),
                                    ProjectDisplayWidget(),
                                    SizedBox(height: 10),
                                    SubWrapper(
                                      isVisible:
                                          !SalesAuthAction()
                                              .useBarcodeAction(
                                                context:
                                                    context,
                                              ),
                                      mainWidget: TextFieldBarcode(
                                        node:
                                            returnSalesProvider()
                                                .scanBarcodeCartPageNode,
                                        hintText:
                                            'Scan Barcode',
                                        clearTextField: () {
                                          setState(() {});
                                        },
                                        searchController:
                                            widget
                                                .searchController,
                                        onChanged: (value) {
                                          SalesAuthAction().useBarcodeAction(
                                            context:
                                                context,
                                            action: () async {
                                              if (value
                                                  .isNotEmpty) {
                                                var items = returnData().productList.where(
                                                  (
                                                    product,
                                                  ) =>
                                                      product.barcode?.toLowerCase() ==
                                                          value.toLowerCase() ||
                                                      product.name.toLowerCase() ==
                                                          value.toLowerCase(),
                                                );
                                                if (items
                                                    .isNotEmpty) {
                                                  returnSalesProvider().addItemToCart(
                                                    context:
                                                        context,
                                                    newItem: TempCartItem(
                                                      setCustomPrice:
                                                          false,
                                                      item:
                                                          items.first,
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

                                                  widget
                                                      .searchController
                                                      .clear();
                                                  await playBeep();
                                                  setState(
                                                    () {},
                                                  );
                                                  returnSalesProvider()
                                                      .requestFocusScanBarcode();
                                                }
                                              }
                                            },
                                            failAction: () {
                                              widget
                                                  .searchController
                                                  .clear();
                                            },
                                          );
                                        },
                                        onPressedScan:
                                            () async {},
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Material(
                                      color:
                                          Colors
                                              .transparent,
                                      child: Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        spacing: 10,
                                        children: [
                                          Visibility(
                                            visible:
                                                returnData()
                                                    .productList
                                                    .isNotEmpty,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .prColor300,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  returnSalesProvider()
                                                      .removeListenerScanBarcode();
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
                                                  ).then((
                                                    _,
                                                  ) {
                                                    returnSalesProvider()
                                                        .addListenerScanBarcode();
                                                    setState(() {
                                                      returnSalesProvider()
                                                          .requestFocusScanBarcode();
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        11,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        color:
                                                            Colors.white,
                                                      ),
                                                      'Add Item',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SubWrapper(
                                            isVisible:
                                                !SalesAuthAction()
                                                    .addCustomItemToCartAction(
                                                      context:
                                                          context,
                                                    ),
                                            mainWidget: Ink(
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
                                                      setTotalPrice:
                                                          returnSalesProvider().setTotalPrice,
                                                      item: TempProductClass(
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
                                                              costPriceC.text,
                                                            ) ??
                                                            0,
                                                        sellingPrice: double.tryParse(
                                                          sellingPriceC.text,
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
                                                        9,
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
                                                    .b4
                                                    .fontSize,
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
                                                  )
                                                  .currentCart()
                                                  .discount !=
                                              null ||
                                          returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .fixedDiscount !=
                                              null,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 5,
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
                                                      ' (${returnSalesProviderContext(context).currentCart().discount?.toStringAsFixed(0)}%)',
                                                    ),
                                                  ),
                                                ],
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
                                                '- ${formatMoney(returnSalesProviderContext(context).calcDiscountMain(), context)}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(height: 5),
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
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
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
                                                    .b2
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
                                                    .b2
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
                                    SizedBox(height: 5),

                                    DiscountSetterWidget(
                                      discountPercentController:
                                          discountPercentController,
                                      addListener: () {
                                        returnSalesProvider()
                                            .requestFocusScanBarcode();
                                        returnSalesProvider()
                                            .addListenerScanBarcode();
                                      },
                                      removeListener: () {
                                        var number = 2;
                                        for (
                                          var i = 0;
                                          i < number;
                                          i++
                                        ) {
                                          if (returnSalesProvider()
                                              .scanBarcodeCartPageNode
                                              .hasFocus) {
                                            returnSalesProvider()
                                                .removeListenerScanBarcode();
                                          }
                                          print(
                                            "${returnSalesProvider().scanBarcodeCartPageNode.hasFocus} Beans",
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    MainButtonP(
                                      themeProvider: theme,
                                      action: () {
                                        returnSalesProvider()
                                            .removeListenerScanBarcode();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return MakeSalesTwo(
                                                totalAmount:
                                                    returnSalesProvider()
                                                        .calcFinalTotal(),
                                              );
                                            },
                                          ),
                                        ).then((_) {
                                          if (context
                                              .mounted) {
                                            returnSalesProvider()
                                                .addListenerScanBarcode();
                                            setState(() {
                                              returnSalesProvider()
                                                  .requestFocusScanBarcode();
                                            });
                                          }
                                        });
                                      },
                                      text: 'Proceed',
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
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
    // return Scaffold(appBar: AppBar());
  }
}

class SubStaffSelectionWidget extends StatefulWidget {
  const SubStaffSelectionWidget({super.key});

  @override
  State<SubStaffSelectionWidget> createState() =>
      _SubStaffSelectionWidgetState();
}

class _SubStaffSelectionWidgetState
    extends State<SubStaffSelectionWidget> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          returnShopProvider(
                context: context,
              ).userShop()?.bulkSale ==
              true &&
          subPlans
              .firstWhere(
                (pl) =>
                    pl.plan ==
                    returnSubcsription(
                      context,
                    ).subscription?.plan,
              )
              .salesAuth
              .bulkSale,
      child: Column(
        children: [
          SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        6,
                        15,
                        6,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                              // color: Colors.white,
                            ),
                            returnSalesProviderContext(
                                      context,
                                    )
                                    .currentMainCart()
                                    .cartName() ??
                                'Default ${returnSalesProviderContext(context).mainCartQueue.indexOf(returnSalesProviderContext(context).currentMainCart()) + 1}',
                          ),
                          Row(
                            spacing: 3,
                            children: [
                              InkWell(
                                onTap: () {
                                  returnSalesProvider()
                                      .addNewMainCart(
                                        context,
                                      );
                                },
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                child: Padding(
                                  padding:
                                      EdgeInsetsGeometry.symmetric(
                                        vertical: 8,
                                        horizontal: 10,
                                      ),
                                  child: Icon(
                                    size: 20,
                                    Icons.add,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    screenWidth(context) >
                                    mobileScreen,
                                child: Icon(
                                  (screenWidth(context) <
                                              mobileScreen
                                          ? returnSalesProviderContext(
                                            context,
                                          ).isSubStaffSelectionMobileOpen
                                          : isOpen)
                                      ? Icons
                                          .keyboard_arrow_up_outlined
                                      : Icons
                                          .keyboard_arrow_down_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        screenWidth(context) < mobileScreen
                            ? returnSalesProviderContext(
                              context,
                            ).isSubStaffSelectionMobileOpen
                            : isOpen,
                    child: SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          15,
                          0,
                          15,
                          10,
                        ),
                        child: Column(
                          children: [
                            Divider(),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children:
                                    returnSalesProviderContext(
                                          context,
                                        ).mainCartQueue
                                        .map(
                                          (cart) => InkWell(
                                            onTap: () {
                                              returnSalesProvider()
                                                  .selectMainCart(
                                                    cart.mainCartId!,
                                                  );
                                            },
                                            child: Padding(
                                              padding:
                                                  EdgeInsetsGeometry.fromLTRB(
                                                    8,
                                                    2,
                                                    2,
                                                    2,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Icon(
                                                        size:
                                                            14,
                                                        color:
                                                            Colors.grey.shade400,
                                                        Icons.book,
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              returnSalesProviderContext(
                                                                        context,
                                                                      ).currentMainCart().mainCartId ==
                                                                      cart.mainCartId
                                                                  ? FontWeight.bold
                                                                  : null,
                                                        ),
                                                        cart.cartName() ??
                                                            'Default  ${returnSalesProviderContext(context).mainCartQueue.indexOf(cart) + 1}',
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        40,
                                                    child: Row(
                                                      spacing:
                                                          5,
                                                      children: [
                                                        Visibility(
                                                          visible:
                                                              returnSalesProviderContext(
                                                                    context,
                                                                  ).mainCartQueue.length >
                                                                  1 ||
                                                              cart.subStaff !=
                                                                  null,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              if (cart.subStaff ==
                                                                  null) {
                                                                if (returnSalesProvider().mainCartQueue.length >
                                                                    1) {
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
                                                                            'You are about to Delete Entire Bulk Sale Terminal, This action can not be reversed are you sure you want to proceed?',
                                                                        title:
                                                                            'Are you sure?',
                                                                        action: () {
                                                                          returnSalesProvider().deleteMainCart(
                                                                            cart.mainCartId!,
                                                                          );
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop();
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              } else {
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
                                                                          'You are about to Remove this Staff from this Bulk Sale Terminal, This action can not be reversed are you sure you want to proceed?',
                                                                      title:
                                                                          'Remove Staff',
                                                                      action: () {
                                                                        returnSalesProvider().removeStaffFromMainCart(
                                                                          cart.mainCartId!,
                                                                        );
                                                                        print(
                                                                          cart.subStaff?.staffName,
                                                                        );
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop();
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            icon: Icon(
                                                              size:
                                                                  18,
                                                              color:
                                                                  Colors.red,
                                                              Icons.clear,
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              cart.subStaff ==
                                                              null,
                                                          child: InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (
                                                                  templateDialog,
                                                                ) {
                                                                  return DialogTemplate(
                                                                    theme:
                                                                        theme,
                                                                    message:
                                                                        'Select a Sub Staff to add to this.',
                                                                    topRightWidget:
                                                                        screenWidth(
                                                                                  context,
                                                                                ) >
                                                                                mobileScreen
                                                                            ? IconButton(
                                                                              onPressed: () {
                                                                                returnSubStaffProvider().getSubStaffs();
                                                                              },
                                                                              icon: Icon(
                                                                                size:
                                                                                    20,
                                                                                color:
                                                                                    Colors.grey,
                                                                                Icons.refresh_outlined,
                                                                              ),
                                                                            )
                                                                            : null,
                                                                    title:
                                                                        'Select Sub Staff',
                                                                    action: () {
                                                                      if (returnSalesProvider().selectedSubStaff !=
                                                                          null) {
                                                                        returnSalesProvider().addSubStaffToMainCart(
                                                                          cart.mainCartId!,
                                                                        );
                                                                        Navigator.of(
                                                                          templateDialog,
                                                                        ).pop();
                                                                      }
                                                                    },
                                                                    widget: SelectSubStaffListWidget(
                                                                      staff:
                                                                          cart.subStaff,
                                                                    ),
                                                                  );
                                                                },
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  returnSalesProvider().selectSubStaff();
                                                                },
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsetsGeometry.all(
                                                                8,
                                                              ),
                                                              child: Icon(
                                                                size:
                                                                    18,
                                                                color:
                                                                    Colors.grey,
                                                                Icons.edit,
                                                              ),
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
                                        )
                                        .toList(),
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectDisplayWidget extends StatelessWidget {
  const ProjectDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          !returnMultiDisplayProviderContext(
            context,
          ).checkIfWindowExists(
            returnSalesProviderContext(context).cartIdCache,
          ),
      child: Column(
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                type: MaterialType.transparency,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: theme.lightModeColor.prColor300,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(3),
                    onTap: () async {
                      returnSalesProvider().createWindow();
                      print(
                        returnMultiDisplayProvider()
                            .windows,
                      );
                      print(
                        returnMultiDisplayProvider()
                            .displayIds,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 7,
                      ),

                      child: Row(
                        spacing: 4,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                            'Project',
                          ),
                          Icon(
                            size: 16,
                            color: Colors.white,
                            Icons.screen_share_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
