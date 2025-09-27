import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/products_summary_tab.dart';

class ItemsSummary extends StatefulWidget {
  final TextEditingController? searchController;
  final Function(String)? searchAction;
  final bool? onSearch;
  final String? mainTitle;
  final String? subTitle;
  final String? hintText;
  final bool secondRow;
  final bool firsRow;
  final String? title1;
  final String? title2;
  final String? title3;
  final String? title4;
  final double? value1;
  final double? value2;
  final double? value3;
  final double? value4;
  final Color? color1;
  final Color? color2;
  final Color? color3;
  final Color? color4;
  final Function()? scanAction;
  final bool? isMoney1;
  final bool? isMoney2;
  final bool? isMoney3;
  final bool? isMoney4;
  final bool? isFilter;
  final bool? isProduct;
  final Function()? filterAction;
  final bool? isDateSet;
  final bool? setDate;
  final Function()? clearTextField;
  final String? title0;
  final Color? color0;
  final bool? isMoney0;
  final double? value0;
  final String? title00;
  final Color? color00;
  final bool? isMoney00;
  final double? value00;
  final bool? show0;
  final bool? show00;
  final Function()? refreshAction;

  const ItemsSummary({
    this.isDateSet,
    this.setDate,
    this.searchController,
    this.searchAction,
    super.key,
    required this.secondRow,
    required this.title1,
    required this.title2,
    this.title3,
    this.title4,
    required this.value1,
    required this.value2,
    this.value3,
    this.value4,
    required this.color1,
    required this.color2,
    this.color3,
    this.color4,
    required this.firsRow,
    this.scanAction,
    this.hintText,
    this.mainTitle,
    this.subTitle,
    this.isMoney1,
    this.isMoney2,
    this.isMoney3,
    this.isMoney4,
    this.onSearch,
    this.isFilter,
    this.isProduct,
    this.filterAction,
    this.clearTextField,
    this.value0,
    this.title0,
    this.color0,
    this.isMoney0,
    this.value00,
    this.title00,
    this.color00,
    this.isMoney00,
    this.show0,
    this.show00,
    this.refreshAction,
  });

  @override
  State<ItemsSummary> createState() => _ItemsSummaryState();
}

class _ItemsSummaryState extends State<ItemsSummary> {
  double returnDouble() {
    if (widget.value1.toString().length > 6 ||
        widget.value2.toString().length > 6 ||
        widget.value3.toString().length > 6 ||
        widget.value4.toString().length > 6) {
      return 17;
    } else {
      return 10;
    }
  }

  bool isFocus = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(returnDouble()),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 244, 244, 244),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -5),
            blurRadius: 3,
            color: const Color.fromARGB(41, 0, 0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                mainAxisAlignment:
                    widget.isFilter != null ||
                            widget.isProduct != null
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.mainTitle ?? '',
                      ),
                      Visibility(
                        visible: true,
                        child: Text(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.normal,
                          ),
                          widget.subTitle ?? '',
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Visibility(
                        visible: widget.isFilter ?? false,
                        child: MaterialButton(
                          onPressed: widget.filterAction,
                          child: Row(
                            spacing: 3,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Colors.grey.shade700,
                                ),
                                (widget.isDateSet != null &&
                                            widget
                                                .isDateSet!) ||
                                        (widget.setDate !=
                                                null &&
                                            widget.setDate!)
                                    ? 'Clear Date'
                                    : 'Set Date',
                              ),
                              Icon(
                                size: 20,
                                color:
                                    theme
                                        .lightModeColor
                                        .secColor100,
                                (widget.isDateSet != null &&
                                            widget
                                                .isDateSet!) ||
                                        (widget.setDate !=
                                                null &&
                                            widget.setDate!)
                                    ? Icons.clear
                                    : Icons
                                        .date_range_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible:
                                widget.refreshAction !=
                                null,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                onTap: widget.refreshAction,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        10,
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
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Refresh',
                                      ),
                                      Icon(
                                        size: 18,
                                        Icons
                                            .refresh_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible:
                                widget.isProduct != null &&
                                        authorization(
                                          authorized:
                                              Authorizations()
                                                  .addProduct,
                                          context: context,
                                        )
                                    ? true
                                    : false,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AddProduct();
                                      },
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        10,
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
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Add Item',
                                      ),
                                      Icon(
                                        size: 18,
                                        Icons.add,
                                        color: Colors.amber,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Visibility(
                          //   visible:
                          //       widget.isProduct != null &&
                          //               authorization(
                          //                 authorized:
                          //                     Authorizations()
                          //                         .addProduct,
                          //                 context: context,
                          //               )
                          //           ? true
                          //           : false,
                          //   child: MaterialButton(
                          //     onPressed: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) {
                          //             return AddProduct();
                          //           },
                          //         ),
                          //       );
                          //     },
                          //     child: Row(
                          //       spacing: 3,
                          //       children: [
                          //         Text(
                          //           style: TextStyle(
                          //             fontSize:
                          //                 theme
                          //                     .mobileTexts
                          //                     .b2
                          //                     .fontSize,
                          //             fontWeight:
                          //                 FontWeight.normal,
                          //             color:
                          //                 Colors
                          //                     .grey
                          //                     .shade700,
                          //           ),
                          //           'Add Item',
                          //         ),
                          //         Icon(
                          //           size: 20,
                          //           color:
                          //               theme
                          //                   .lightModeColor
                          //                   .secColor100,
                          //           Icons.add,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Visibility(
              //   visible: widget.onSearch ?? true,
              //   child: SizedBox(height: 10),
              // ),
              Visibility(
                visible: widget.onSearch ?? true,
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width -
                      ((returnDouble() * 2) + 40),
                  child: TextFieldBarcode(
                    clearTextField:
                        widget.clearTextField ?? () {},
                    searchController:
                        widget.searchController ??
                        TextEditingController(),
                    onChanged: widget.searchAction,
                    onPressedScan: widget.scanAction,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: widget.firsRow,
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: widget.show0 != null,
                          child: Expanded(
                            child: ProductSummaryTab(
                              isMoney: widget.isMoney0,
                              color:
                                  widget.color0 ??
                                  Colors.amber,
                              title: widget.title0 ?? '',
                              value: widget.value0 ?? 0,
                            ),
                          ),
                        ),

                        Expanded(
                          child: ProductSummaryTab(
                            isMoney: widget.isMoney1,
                            color:
                                widget.color1 ??
                                Colors.amber,
                            title: widget.title1 ?? '',
                            value: widget.value1 ?? 0,
                          ),
                        ),

                        Expanded(
                          child: ProductSummaryTab(
                            isMoney: widget.isMoney2,
                            color:
                                widget.color2 ??
                                Colors.amber,
                            title: widget.title2 ?? '',
                            value: widget.value2 ?? 0,
                          ),
                        ),
                        Visibility(
                          visible: widget.show00 != null,
                          child: Expanded(
                            child: ProductSummaryTab(
                              isMoney: widget.isMoney00,
                              color:
                                  widget.color00 ??
                                  Colors.amber,
                              title: widget.title00 ?? '',
                              value: widget.value00 ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.secondRow,
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: ProductSummaryTab(
                              isMoney: widget.isMoney3,
                              color:
                                  widget.color3 ??
                                  Colors.amber,
                              title: widget.title3 ?? '',
                              value: widget.value3 ?? 0,
                            ),
                          ),
                          Expanded(
                            child: ProductSummaryTab(
                              isMoney: widget.isMoney4,
                              color:
                                  widget.color4 ??
                                  Colors.amber,
                              title: widget.title4 ?? '',
                              value: widget.value4 ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
