import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/classes/temp_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class CartItemMain extends StatefulWidget {
  final TempCartItem cartItem;
  final Function()? editAction;
  final Function()? deleteCartItem;
  const CartItemMain({
    super.key,
    required this.theme,
    required this.cartItem,
    required this.editAction,
    required this.deleteCartItem,
  });

  final ThemeProvider theme;

  @override
  State<CartItemMain> createState() => _CartItemMainState();
}

class _CartItemMainState extends State<CartItemMain> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
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
          borderRadius: BorderRadius.circular(5),
          elevation: 0,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),

            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
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
                          Flexible(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Column(
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
                                              FontWeight
                                                  .bold,
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
                                              FontWeight
                                                  .w600,
                                          color:
                                              widget
                                                  .theme
                                                  .lightModeColor
                                                  .secColor200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed:
                                widget.deleteCartItem,
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
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                                formatMoneyMid(
                                  widget.cartItem
                                      .totalCost(),
                                  context,
                                ),
                                // '${widget.cartItem.customPrice != null ? formatMoneyMid(widget.cartItem.customPrice ?? 0, context) : (widget.cartItem.customPrice) ?? (widget.cartItem.item.discount == null ? formatMoneyMid(widget.cartItem.totalCost(), context) : formatMoneyMid((widget.cartItem.totalCost() * (1 - (widget.cartItem.item.discount! / 100))), context))}',
                              ),
                              Visibility(
                                visible:
                                    widget
                                            .cartItem
                                            .item
                                            .discount !=
                                        null &&
                                    widget
                                            .cartItem
                                            .customPrice ==
                                        null,
                                child: Text('/'),
                              ),
                              Visibility(
                                visible:
                                    widget
                                            .cartItem
                                            .item
                                            .discount !=
                                        null &&
                                    widget
                                            .cartItem
                                            .customPrice ==
                                        null,
                                child: Text(
                                  style: TextStyle(
                                    decoration:
                                        TextDecoration
                                            .lineThrough,
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                  formatMoneyMid(
                                    widget.cartItem
                                        .totalCost(),
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            child: Ink(
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
                                onTap: widget.editAction,
                                child: Container(
                                  height: 30,
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),

                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      Center(
                                        child: Text(
                                          style: TextStyle(
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          widget
                                              .cartItem
                                              .quantity
                                              .toStringAsFixed(
                                                1,
                                              ),
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        height: 16,
                                        editIconSvg,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
