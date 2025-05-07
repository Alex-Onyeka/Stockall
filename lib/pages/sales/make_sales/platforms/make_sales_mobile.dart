import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/buttons/floating_action_butto.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/bottom_sheet_widgets.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/compnents/cart_item_main.dart';

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
  double calcTotal(List<TempCartItem> items) {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.totalCost();
    }
    return tempTotal;
  }

  bool showBottomPanel = false;
  TextEditingController searchController =
      TextEditingController();

  List<TempProductClass> productsResult = [];
  String? searchResult;
  bool isFocus = false;
  bool listEmpty = true;
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
                                return SizedBox(
                                  child: Center(
                                    child: Text(
                                      'Empty List',
                                    ),
                                  ),
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
                  Padding(
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
                              'N${formatLargeNumberDouble(calcTotal(returnSalesProvider(context).cartItems))}',
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
                              'N${formatLargeNumberDouble(calcTotal(returnSalesProvider(context).cartItems))}',
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
                                fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.bold,
                              ),
                              'N${formatLargeNumberDouble(calcTotal(returnSalesProvider(context).cartItems))}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  MainButtonP(
                    themeProvider: theme,
                    action: () {},
                    text: 'Check Out',
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Visibility(
              visible: showBottomPanel,
              child: CustomBottomPanel(
                searchController: searchController,
                close: () {
                  setState(() {
                    showBottomPanel = false;
                    searchController.clear();
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
