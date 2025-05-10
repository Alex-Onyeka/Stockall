import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/buttons/floating_action_butto.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/constants/bottom_sheet_widgets.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/compnents/cart_item_main.dart';
import 'package:stockitt/pages/sales/make_sales/page2/make_sales_two.dart';

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
  @override
  void initState() {
    super.initState();

    returnData(
      context,
      listen: false,
    ).toggleFloatingAction(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 10,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    listEmpty = !listEmpty;
                  });
                },
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Cart Items',
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Visibility(
          visible: !showBottomPanel,
          child: FloatingActionButtonMain(
            theme: theme,
            action: () {
              setState(() {
                showBottomPanel = true;
              });
            },
            color: theme.lightModeColor.prColor300,
            text: 'Add Item',
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              List<TempCartItem> items =
                                  returnSalesProvider(
                                    context,
                                  ).cartItems;

                              if (items.isEmpty) {
                                return EmptyWidgetDisplay(
                                  title: 'Cart List Empty',
                                  subText:
                                      'Start Adding Items to Cart To make Sales',
                                  buttonText: 'Add Item',
                                  svg: productIconSvg,
                                  theme: theme,
                                  height: 40,
                                  action: () {
                                    setState(() {
                                      showBottomPanel =
                                          true;
                                    });
                                  },
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
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).removeItemFromCart(
                                          items[index],
                                        );
                                      },
                                      editAction: () {
                                        editCartItemBottomSheet(
                                          context,
                                          () {
                                            returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).editCartItemQuantity(
                                              items[index],
                                              double.parse(
                                                numberController
                                                    .text,
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
                                      theme: theme,
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
                  Visibility(
                    visible:
                        returnSalesProvider(
                          context,
                        ).cartItems.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 15),
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
                                      FontWeight.bold,
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
                                      FontWeight.bold,
                                ),
                                'N${formatLargeNumberDouble(returnSalesProvider(context).calcFinalTotalMain(returnSalesProvider(context).cartItems))}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible:
                        returnSalesProvider(
                          context,
                        ).cartItems.isNotEmpty,
                    child: MainButtonP(
                      themeProvider: theme,
                      action: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MakeSalesTwo();
                            },
                          ),
                        );
                      },
                      text: 'Check Out',
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Visibility(
              visible: showBottomPanel,
              child: CustomBottomPanel(
                searchController: widget.searchController,
                close: () {
                  setState(() {
                    showBottomPanel = false;
                    widget.searchController.clear();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
