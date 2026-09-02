import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductTileCartSearch extends StatefulWidget {
  final TempProductClass product;
  final Function()? action;
  // final Funcion()? action;
  const ProductTileCartSearch({
    super.key,
    required this.theme,
    required this.product,
    required this.action,
  });

  final ThemeProvider theme;

  @override
  State<ProductTileCartSearch> createState() =>
      _ProductTileCartSearchState();
}

class _ProductTileCartSearchState
    extends State<ProductTileCartSearch> {
  bool isManaged() {
    return widget.product.isManaged;
  }

  final quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantityController.text = '0';
  }

  double quantity = 0;

  void addQuantity() {
    if (widget.product.canSelectForCart() &&
        !widget.product.isExpired() &&
        (widget.product.quantity ?? 0) >
            (returnSalesProvider()
                    .totalItemQuantityInAllCarts(
                      product: widget.product,
                    ) +
                quantity)) {
      setState(() {
        quantity++;
        quantityController.text = quantity.toString();
      });
    }
  }

  void deductQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
        quantityController.text = quantity.toString();
      });
    }
  }

  void addItemToCart() {
    if (widget.product.canSelectForCart() &&
        !widget.product.isExpired() &&
        (widget.product.quantity ?? 0) >
            (returnSalesProvider()
                    .totalItemQuantityInAllCarts(
                      product: widget.product,
                    ) +
                quantity)) {}
  }

  @override
  Widget build(BuildContext context) {
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
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(5),
            onTap: widget.action,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),

              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.grey.shade200,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
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
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          widget
                                              .product
                                              .name,
                                        ),
                                        Text(
                                          [
                                            if (widget
                                                    .product
                                                    .color !=
                                                null)
                                              widget
                                                  .product
                                                  .color,
                                            if (widget
                                                    .product
                                                    .sizeType !=
                                                null)
                                              widget
                                                  .product
                                                  .sizeType,
                                            if (widget
                                                    .product
                                                    .size !=
                                                null)
                                              widget
                                                  .product
                                                  .size,
                                          ].join('  |  '),
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b4
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                    right: 0.0,
                                  ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isManaged()
                                          ? getDayDifference(
                                                        widget.product.expiryDate ??
                                                            DateTime.now(),
                                                      ) <
                                                      1 &&
                                                  widget.product.expiryDate !=
                                                      null
                                              ? const Color.fromARGB(
                                                255,
                                                255,
                                                232,
                                                231,
                                              )
                                              : widget.product.quantity !=
                                                      0 &&
                                                  (widget.product.quantity ??
                                                          0) >
                                                      widget
                                                          .product
                                                          .lowQtty!
                                              ? Colors
                                                  .grey
                                                  .shade100
                                              : widget.product.quantity !=
                                                      0 &&
                                                  (widget.product.quantity ??
                                                          0) <=
                                                      widget
                                                          .product
                                                          .lowQtty!
                                              ? const Color.fromARGB(
                                                255,
                                                255,
                                                249,
                                                227,
                                              )
                                              : const Color.fromARGB(
                                                255,
                                                255,
                                                232,
                                                231,
                                              )
                                          : Colors
                                              .grey
                                              .shade100,
                                  border: Border.all(
                                    color:
                                        isManaged()
                                            ? getDayDifference(
                                                          widget.product.expiryDate ??
                                                              DateTime.now(),
                                                        ) <
                                                        1 &&
                                                    widget.product.expiryDate !=
                                                        null
                                                ? const Color.fromARGB(
                                                  255,
                                                  255,
                                                  142,
                                                  134,
                                                )
                                                : widget.product.quantity !=
                                                        0 &&
                                                    (widget.product.quantity ??
                                                            0) >
                                                        widget.product.lowQtty!
                                                ? Colors
                                                    .grey
                                                    .shade700
                                                : widget.product.quantity !=
                                                        0 &&
                                                    (widget.product.quantity ??
                                                            0) <=
                                                        widget.product.lowQtty!
                                                ? const Color.fromARGB(
                                                  255,
                                                  255,
                                                  229,
                                                  62,
                                                )
                                                : const Color.fromARGB(
                                                  255,
                                                  255,
                                                  142,
                                                  134,
                                                )
                                            : Colors
                                                .grey
                                                .shade700,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 3,
                                      ),
                                  child: Text(
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          isManaged()
                                              ? getDayDifference(
                                                            widget.product.expiryDate ??
                                                                DateTime.now(),
                                                          ) <
                                                          1 &&
                                                      widget.product.expiryDate !=
                                                          null
                                                  ? const Color.fromARGB(
                                                    255,
                                                    255,
                                                    142,
                                                    134,
                                                  )
                                                  : widget.product.quantity !=
                                                          0 &&
                                                      (widget.product.quantity ??
                                                              0) >
                                                          widget.product.lowQtty!
                                                  ? Colors
                                                      .grey
                                                      .shade700
                                                  : widget.product.quantity !=
                                                          0 &&
                                                      (widget.product.quantity ??
                                                              0) <=
                                                          widget.product.lowQtty!
                                                  ? const Color.fromARGB(
                                                    255,
                                                    132,
                                                    115,
                                                    1,
                                                  )
                                                  : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    142,
                                                    134,
                                                  )
                                              : Colors
                                                  .grey
                                                  .shade700,
                                    ),
                                    widget
                                                .product
                                                .expiryDate !=
                                            null
                                        ? getDayDifference(
                                                  widget.product.expiryDate ??
                                                      DateTime.now(),
                                                ) >=
                                                1
                                            ? widget.product.quantity ==
                                                    0
                                                ? 'Out of Stock'
                                                : widget
                                                        .product
                                                        .quantity ==
                                                    null
                                                ? 'Qtty Not Set'
                                                : authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .viewItemQuantity,
                                                )
                                                ? formatLargeNumberDouble(
                                                  widget.product.quantity ??
                                                      0,
                                                )
                                                : 'Restricted'
                                            : 'Item Expired'
                                        : widget
                                                .product
                                                .quantity ==
                                            0
                                        ? 'Out of Stock'
                                        : widget
                                                .product
                                                .quantity ==
                                            null
                                        ? 'Qtty Not Set'
                                        : authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewItemQuantity,
                                        )
                                        ? formatLargeNumberDouble(
                                          widget
                                                  .product
                                                  .quantity ??
                                              0,
                                        )
                                        : 'Restricted',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                spacing: 5,
                                children: [
                                  Expanded(
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            widget
                                                .theme
                                                .lightModeColor
                                                .prColor300,
                                      ),
                                      widget
                                                  .product
                                                  .discount ==
                                              null
                                          ? (widget
                                                      .product
                                                      .sellingPrice !=
                                                  null
                                              ? formatMoneyMid(
                                                amount:
                                                    widget
                                                        .product
                                                        .sellingPrice ??
                                                    0,
                                                context:
                                                    context,
                                              )
                                              : 'Price Not Set')
                                          : formatMoneyMid(
                                            amount:
                                                ((widget.product.sellingPrice ??
                                                        0.0) -
                                                    ((widget.product.sellingPrice ??
                                                            0.0) *
                                                        (widget.product.discount! /
                                                            100))),
                                            context:
                                                context,
                                          ),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        widget
                                            .product
                                            .discount !=
                                        null,
                                    child: Text('/'),
                                  ),
                                  Visibility(
                                    visible:
                                        widget
                                            .product
                                            .discount !=
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
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      formatMoneyMid(
                                        amount:
                                            widget
                                                .product
                                                .sellingPrice ??
                                            0,
                                        context: context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Row(
                            //       spacing: 3,
                            //       mainAxisSize:
                            //           MainAxisSize.min,
                            //       children: [
                            //         InkWell(
                            //           mouseCursor:
                            //               SystemMouseCursors
                            //                   .click,
                            //           onTap: () {
                            //             deductQuantity();
                            //           },
                            //           child: Padding(
                            //             padding:
                            //                 const EdgeInsets.symmetric(
                            //                   vertical: 5.0,
                            //                   horizontal: 5,
                            //                 ),
                            //             child: Icon(
                            //               size: 22,
                            //               Icons
                            //                   .keyboard_arrow_left_rounded,
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           height: 35,
                            //           width: 45,
                            //           child: NumberTextField(
                            //             title: 'title',
                            //             hint: '#',
                            //             controller:
                            //                 quantityController,
                            //             theme: widget.theme,
                            //             autoFocus: false,
                            //             onChanged: (value) {
                            //               var qtty =
                            //                   double.tryParse(
                            //                     quantityController
                            //                         .text
                            //                         .replaceAll(
                            //                           ',',
                            //                           '',
                            //                         ),
                            //                   ) ??
                            //                   0;
                            //               if (widget.product
                            //                       .canSelectForCart() &&
                            //                   !widget
                            //                       .product
                            //                       .isExpired() &&
                            //                   (widget.product.quantity ??
                            //                           0) >
                            //                       (returnSalesProvider().totalItemQuantityInAllCarts(
                            //                             product:
                            //                                 widget.product,
                            //                           ) +
                            //                           qtty)) {
                            //               } else {
                            //                 setState(() {
                            //                   quantity = 0;
                            //                   quantityController
                            //                           .text =
                            //                       '0';
                            //                 });
                            //               }
                            //             },
                            //             showTitle: false,
                            //           ),
                            //         ),
                            //         InkWell(
                            //           mouseCursor:
                            //               SystemMouseCursors
                            //                   .click,
                            //           onTap: () {
                            //             addQuantity();
                            //           },
                            //           child: Padding(
                            //             padding:
                            //                 const EdgeInsets.symmetric(
                            //                   vertical: 5.0,
                            //                   horizontal: 5,
                            //                 ),
                            //             child: Icon(
                            //               size: 22,
                            //               Icons
                            //                   .keyboard_arrow_right_rounded,
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     Ink(
                            //       decoration: BoxDecoration(
                            //         borderRadius:
                            //             BorderRadius.circular(
                            //               3,
                            //             ),
                            //         gradient:
                            //             returnTheme(context)
                            //                 .lightModeColor
                            //                 .prGradient,
                            //       ),
                            //       child: InkWell(
                            //         mouseCursor:
                            //             SystemMouseCursors
                            //                 .click,
                            //         onTap: () {
                            //           deductQuantity();
                            //         },
                            //         child: Container(
                            //           padding:
                            //               const EdgeInsets.symmetric(
                            //                 vertical: 7.0,
                            //                 horizontal: 11,
                            //               ),
                            //           child: Icon(
                            //             size: 12,
                            //             color: Colors.white,
                            //             Icons.send,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
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
      ),
    );
  }
}
