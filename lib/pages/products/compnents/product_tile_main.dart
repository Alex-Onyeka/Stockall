import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/constants/bottom_sheet_widgets.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/pages/products/product_details/product_details_page.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProductTileMain extends StatefulWidget {
  final TempProductClass product;
  const ProductTileMain({
    super.key,
    required this.theme,
    required this.product,
  });

  final ThemeProvider theme;

  @override
  State<ProductTileMain> createState() =>
      _ProductTileMainState();
}

class _ProductTileMainState extends State<ProductTileMain> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          Container(
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
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ProductDetailsPage(
                          productId: widget.product.id!,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),

                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
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
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
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
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    editProductBottomSheet(
                                      context,
                                      () {},
                                      widget.product,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
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
                                              FontWeight
                                                  .bold,
                                          color:
                                              widget
                                                  .theme
                                                  .lightModeColor
                                                  .prColor300,
                                        ),
                                        'N${widget.product.discount == null ? formatLargeNumberDouble(widget.product.sellingPrice) : formatLargeNumberDouble((widget.product.sellingPrice * (1 - (widget.product.discount! / 100))))}',
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
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors.grey,
                                        ),
                                        'N${formatLargeNumberDouble(widget.product.sellingPrice)}',
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                        right: 0.0,
                                      ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          widget.product.quantity !=
                                                      0 &&
                                                  widget.product.quantity >
                                                      10
                                              ? Colors
                                                  .grey
                                                  .shade100
                                              : widget.product.quantity !=
                                                      0 &&
                                                  widget.product.quantity <=
                                                      10
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
                                              ),
                                      border: Border.all(
                                        color:
                                            widget.product.quantity !=
                                                        0 &&
                                                    widget.product.quantity >
                                                        10
                                                ? Colors
                                                    .grey
                                                    .shade700
                                                : widget.product.quantity !=
                                                        0 &&
                                                    widget.product.quantity <=
                                                        10
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
                                                ),
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
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              widget.product.quantity !=
                                                          0 &&
                                                      widget.product.quantity >
                                                          10
                                                  ? Colors
                                                      .grey
                                                      .shade700
                                                  : widget.product.quantity !=
                                                          0 &&
                                                      widget.product.quantity <=
                                                          10
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
                                                  ),
                                        ),
                                        widget
                                                    .product
                                                    .quantity ==
                                                0
                                            ? 'Out of Stock'
                                            : '${widget.product.quantity.toStringAsFixed(0)} in Stock',
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
          ),
          Visibility(
            visible: widget.product.discount != null,
            child: Align(
              alignment: Alignment(0.7, 0),
              child: Container(
                padding: EdgeInsets.fromLTRB(6, 5, 6, 7),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    190,
                    139,
                    18,
                    10,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize:
                        widget
                            .theme
                            .mobileTexts
                            .b4
                            .fontSize,
                  ),
                  '${widget.product.discount ?? '0'}%',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
