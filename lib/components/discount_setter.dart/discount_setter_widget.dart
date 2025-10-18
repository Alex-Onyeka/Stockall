import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class DiscountSetterWidget extends StatefulWidget {
  final TextEditingController discountPercentController;
  const DiscountSetterWidget({
    super.key,
    required this.discountPercentController,
  });

  @override
  State<DiscountSetterWidget> createState() =>
      _DiscountSetterWidgetState();
}

class _DiscountSetterWidgetState
    extends State<DiscountSetterWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  var salesPFalse = returnSalesProvider(
                    context,
                    listen: false,
                  );
                  if (salesPFalse.currentCart().discount ==
                      null) {
                    if (salesPFalse
                            .currentCart()
                            .isSettingDiscountOpen ==
                        true) {
                      salesPFalse.toggleSetDiscount(false);
                    } else {
                      if (screenWidth(context) <
                          mobileScreen) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              insetPadding:
                                  EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                              contentPadding:
                                  EdgeInsets.all(15),
                              backgroundColor: Colors.white,
                              content: SizedBox(
                                width:
                                    BoxConstraints()
                                                .maxWidth <
                                            400
                                        ? 350
                                        : 500,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(
                                        bottom: 20.0,
                                      ),
                                  child: DiscountSetterBody(
                                    discountPercentController:
                                        widget
                                            .discountPercentController,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).then((_) {
                          setState(() {
                            widget.discountPercentController
                                .clear();
                          });
                        });
                      } else {
                        salesPFalse.toggleSetDiscount(true);
                      }
                    }
                  } else {
                    salesPFalse.addGeneralDiscount(null);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  child: Row(
                    spacing: 5,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        returnSalesProvider(
                                  context,
                                ).currentCart().discount !=
                                null
                            ? 'Remove Discount'
                            : 'Add Discount:',
                      ),
                      Stack(
                        children: [
                          Visibility(
                            visible:
                                returnSalesProvider(
                                  context,
                                ).currentCart().discount ==
                                null,
                            child: Icon(
                              size: 18,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              Icons.discount_outlined,
                            ),
                          ),
                          Visibility(
                            visible:
                                returnSalesProvider(
                                  context,
                                ).currentCart().discount !=
                                null,
                            child: Icon(
                              size: 20,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              Icons.clear,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible:
              returnSalesProvider(
                context,
              ).currentCart().isSettingDiscountOpen,
          child: DiscountSetterBody(
            discountPercentController:
                widget.discountPercentController,
          ),
        ),
      ],
    );
  }
}

class DiscountSetterBody extends StatefulWidget {
  final TextEditingController discountPercentController;
  const DiscountSetterBody({
    super.key,
    required this.discountPercentController,
  });

  @override
  State<DiscountSetterBody> createState() =>
      _DiscountSetterBodyState();
}

class _DiscountSetterBodyState
    extends State<DiscountSetterBody> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            spacing: 5,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: 0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Icon(size: 18, Icons.clear),
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Select Discount',
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (screenWidth(context) >
                            mobileScreen) {
                          returnSalesProvider(
                            context,
                            listen: false,
                          ).toggleSetDiscount(false);
                          widget.discountPercentController
                              .clear();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Icon(size: 18, Icons.clear),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                color: Colors.grey.shade100,
                height: 2,
                width: double.infinity,
              ),
              SizedBox(height: 5),
              Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children:
                        returnSalesProvider(context)
                            .returnSomeDiscounts(0, 4)
                            .map(
                              (dis) => Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (screenWidth(
                                            context,
                                          ) >
                                          mobileScreen) {
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).addGeneralDiscount(
                                          double.parse(dis),
                                        );
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).toggleSetDiscount(
                                          false,
                                        );
                                      } else {
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).addGeneralDiscount(
                                          double.parse(dis),
                                        );
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      }
                                      widget
                                          .discountPercentController
                                          .clear();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              3,
                                            ),
                                        border: Border.all(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade100,
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.all(3),
                                      child: Center(
                                        child: Text(
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
                                          '$dis%',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children:
                        returnSalesProvider(context)
                            .returnSomeDiscounts(4, 8)
                            .map(
                              (dis) => Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (screenWidth(
                                            context,
                                          ) >
                                          mobileScreen) {
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).addGeneralDiscount(
                                          double.parse(dis),
                                        );
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).toggleSetDiscount(
                                          false,
                                        );
                                      } else {
                                        returnSalesProvider(
                                          context,
                                          listen: false,
                                        ).addGeneralDiscount(
                                          double.parse(dis),
                                        );
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      }
                                      widget
                                          .discountPercentController
                                          .clear();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              3,
                                            ),
                                        border: Border.all(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade100,
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.all(3),
                                      child: Center(
                                        child: Text(
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
                                          '$dis%',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  spacing: 0,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                        ),
                        child: TextFormField(
                          // inputFormatters: [
                          //   FilteringTextInputFormatter
                          //       .digitsOnly,
                          // ],
                          onChanged: (value) {
                            if (value != '') {
                              if (value == '.') {
                                widget
                                    .discountPercentController
                                    .text = '100';
                              } else {
                                if (value
                                    .toString()
                                    .contains('..')) {
                                  widget
                                      .discountPercentController
                                      .text = '100';
                                } else {
                                  if (double.parse(value) >
                                      100) {
                                    setState(() {
                                      widget
                                          .discountPercentController
                                          .text = '100';
                                    });
                                  }
                                }
                              }
                            }
                          },
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                          keyboardType:
                              TextInputType.number,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    left: 10.0,
                                    right: 5,
                                  ),
                              child: Text(
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                '%',
                              ),
                            ),

                            prefixIconConstraints:
                                BoxConstraints(
                                  minHeight: 0,
                                  minWidth: 0,
                                ),

                            contentPadding: EdgeInsets.only(
                              right: 10,
                              left: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            hintText: 'Enter Discount',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                ),
                            focusedBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    width: 1.3,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                          ),
                          controller:
                              widget
                                  .discountPercentController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(5),
                            onTap: () {
                              if (widget
                                  .discountPercentController
                                  .text
                                  .isNotEmpty) {
                                returnSalesProvider(
                                  context,
                                  listen: false,
                                ).addGeneralDiscount(
                                  double.parse(
                                    widget
                                        .discountPercentController
                                        .text,
                                  ),
                                );
                                if (screenWidth(context) >
                                    mobileScreen) {
                                  returnSalesProvider(
                                    context,
                                    listen: false,
                                  ).toggleSetDiscount(
                                    false,
                                  );
                                  widget
                                      .discountPercentController
                                      .clear();
                                } else {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                }
                                widget
                                    .discountPercentController
                                    .clear();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Center(
                                child: Icon(
                                  size: 13,
                                  color: Colors.white,
                                  Icons.send,
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
            ],
          ),
        ),
      ],
    );
  }
}
