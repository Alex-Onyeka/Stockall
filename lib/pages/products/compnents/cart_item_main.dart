import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/providers/theme_provider.dart';

class CartItemMain extends StatefulWidget {
  final TempCartItem cartItem;
  const CartItemMain({
    super.key,
    required this.theme,
    required this.cartItem,
  });

  final ThemeProvider theme;

  @override
  State<CartItemMain> createState() => _CartItemMainState();
}

class _CartItemMainState extends State<CartItemMain> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                41,
                158,
                158,
                158,
              ),
              blurRadius: 5,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 0,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(Icons.shopping_bag_outlined),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    widget
                                        .cartItem
                                        .item
                                        .name,
                                  ),
                                  Text(
                                    [
                                      if (widget
                                              .cartItem
                                              .item
                                              .color !=
                                          null)
                                        widget
                                            .cartItem
                                            .item
                                            .color,
                                      if (widget
                                              .cartItem
                                              .item
                                              .sizeType !=
                                          null)
                                        widget
                                            .cartItem
                                            .item
                                            .sizeType,
                                      if (widget
                                              .cartItem
                                              .item
                                              .size !=
                                          null)
                                        widget
                                            .cartItem
                                            .item
                                            .size,
                                    ].join('  |  '),
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          widget
                                              .theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.delete_outline,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Visibility(
                                visible: true,
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        widget
                                            .theme
                                            .lightModeColor
                                            .prColor300,
                                  ),
                                  'N${formatLargeNumberDouble(widget.cartItem.totalCost())}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
