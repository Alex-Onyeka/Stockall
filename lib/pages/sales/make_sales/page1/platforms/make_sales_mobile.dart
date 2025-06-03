// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:storrec/classes/temp_cart_item.dart';
import 'package:storrec/classes/temp_product_class.dart';
import 'package:storrec/components/alert_dialogues/confirmation_alert.dart';
import 'package:storrec/components/buttons/main_button_p.dart';
import 'package:storrec/components/buttons/small_button_main.dart';
import 'package:storrec/components/major/empty_widget_display.dart';
import 'package:storrec/components/major/empty_widget_display_only.dart';
import 'package:storrec/constants/app_bar.dart';
import 'package:storrec/constants/bottom_sheet_widgets.dart';
import 'package:storrec/constants/calculations.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/products/add_product_one/add_product.dart';
import 'package:storrec/pages/products/compnents/cart_item_main.dart';
import 'package:storrec/pages/sales/make_sales/page2/make_sales_two.dart';

class MakeSalesMobile extends StatefulWidget {
  final TextEditingController searchController;
  const MakeSalesMobile({
    super.key,
    required this.searchController,
  });

  @override
  State<MakeSalesMobile> createState() =>
      _MakeSalesMobileState();
}

class _MakeSalesMobileState extends State<MakeSalesMobile> {
  TextEditingController numberController =
      TextEditingController();

  bool showBottomPanel = false;

  List<TempProductClass> productsResult = [];
  String? searchResult;
  bool isFocus = false;
  bool listEmpty = true;

  late Future<List<TempProductClass>> _productsFuture;
  @override
  void initState() {
    super.initState();
    // returnData(
    //   context,
    //   listen: false,
    // ).toggleFloatingAction(context);
    _productsFuture = getProductList(context);
  }

  Future<List<TempProductClass>> getProductList(
    BuildContext context,
  ) async {
    return await returnData(
      context,
      listen: false,
    ).getProducts(shopId(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productsFuture = getProductList(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),

      child: Scaffold(
        appBar: appBar(
          context: context,
          title: 'Cart Items',
          widget: Visibility(
            visible:
                returnSalesProvider(
                  context,
                ).cartItems.isNotEmpty,
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
                        returnSalesProvider(
                          context,
                          listen: false,
                        ).clearCart();
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
                              theme.mobileTexts.b3.fontSize,
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
        ),
        body: FutureBuilder(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return returnCompProvider(
                context,
                listen: false,
              ).showLoader('Loading');
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: EmptyWidgetDisplayOnly(
                  title: 'An Error Occoured',
                  subText:
                      'Check your internet connection and Try again',
                  theme: theme,
                  height: 30,
                  icon: Icons.clear,
                ),
              );
            } else {
              var products = snapshot.data!;
              if (products.isEmpty) {
                if (returnLocalDatabase(
                      context,
                      listen: false,
                    ).currentEmployee!.role ==
                    'Cashier') {
                  return EmptyWidgetDisplayOnly(
                    title: 'No Products',
                    subText:
                        'No Products have been added to your stock.',
                    theme: theme,
                    height: 30,
                    icon: Icons.clear,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        EmptyWidgetDisplay(
                          title: 'No products',
                          subText:
                              'You currently do not have have any product. Add products to start making sales.',
                          theme: theme,
                          height: 30,
                          svg: productIconSvg,
                          buttonText: 'Add Product',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddProduct();
                                },
                              ),
                            ).then((_) {
                              setState(() {
                                _productsFuture =
                                    getProductList(context);
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }
              } else {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Expanded(
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
                                      builder: (context) {
                                        List<TempCartItem>
                                        items =
                                            returnSalesProvider(
                                                  context,
                                                )
                                                .cartItems
                                                .reversed
                                                .toList();

                                        if (items.isEmpty) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
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
                                                height: 40,
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
                                                        products:
                                                            products,
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        } else {
                                          return ListView.builder(
                                            itemCount:
                                                returnSalesProvider(
                                                      context,
                                                    )
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
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                editAction: () {
                                                  editCartItemBottomSheet(
                                                    items[index]
                                                        .item
                                                        .quantity,
                                                    context,
                                                    () {
                                                      returnSalesProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).editCartItemQuantity(
                                                        items[index],
                                                        double.parse(
                                                          numberController.text,
                                                        ),
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    items[index],
                                                    numberController,
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
                          Visibility(
                            visible:
                                returnSalesProvider(
                                  context,
                                ).cartItems.isNotEmpty,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 0.0,
                                  ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100,
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
                                        30,
                                        30,
                                        0,
                                      ),
                                  child: Column(
                                    children: [
                                      Material(
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
                                                      widget
                                                          .searchController,
                                                  close: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                  },
                                                  products:
                                                      products,
                                                );
                                              },
                                            );
                                          },
                                          buttonText:
                                              'Add New Item',
                                        ),
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
                                            'N${formatLargeNumberDouble(returnSalesProvider(context).calcTotalMain(returnSalesProvider(context).cartItems))}',
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
                                            '- N${formatLargeNumberDouble(returnSalesProvider(context).calcDiscountMain(returnSalesProvider(context).cartItems))}',
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
                                            'N${formatLargeNumberDouble(returnSalesProvider(context).calcFinalTotalMain(returnSalesProvider(context).cartItems))}',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
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
                                        },
                                        text: 'Check Out',
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
                    Visibility(
                      visible: showBottomPanel,
                      child: CustomBottomPanel(
                        products: products,
                        searchController:
                            widget.searchController,
                        close: () {
                          setState(() {
                            showBottomPanel = false;
                            widget.searchController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}
