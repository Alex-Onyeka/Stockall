import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class DiscountSetterWidget extends StatefulWidget {
  final TextEditingController discountPercentController;
  final Function()? addListener;
  final Function()? removeListener;
  const DiscountSetterWidget({
    super.key,
    required this.discountPercentController,
    required this.addListener,
    required this.removeListener,
  });

  @override
  State<DiscountSetterWidget> createState() =>
      _DiscountSetterWidgetState();
}

class _DiscountSetterWidgetState
    extends State<DiscountSetterWidget> {
  bool isFixed = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible: authorization(
        authorized: Authorizations().salesDiscount,
      ),
      child: SubWrapper(
        isVisible:
            !SalesAuthAction().applyDiscountAction(
              context: context,
            ),
        mainWidget: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      setDiscountAction(
                        context,
                        widget.discountPercentController,
                        widget.addListener,
                        widget.removeListener,
                      );
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
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            returnSalesProvider()
                                            .currentCart()
                                            .discount !=
                                        null ||
                                    returnSalesProvider()
                                            .currentCart()
                                            .fixedDiscount !=
                                        null
                                ? 'Cancel'
                                : 'Add Discount:',
                          ),
                          Visibility(
                            visible:
                                returnSalesProvider()
                                        .currentCart()
                                        .discount !=
                                    null ||
                                returnSalesProvider()
                                        .currentCart()
                                        .fixedDiscount !=
                                    null,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                7,
                                3,
                                4,
                                3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      2,
                                    ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(
                                          17,
                                          0,
                                          0,
                                          0,
                                        ),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  color:
                                      theme
                                          .lightModeColor
                                          .secColor200,
                                ),
                                '${returnSalesProviderContext(context).currentCart().discount?.toStringAsFixed(0) ?? formatCompactMoney(context: context, amount: returnSalesProviderContext(context).currentCart().fixedDiscount)}${returnSalesProviderContext(context).currentCart().discount != null ? '%' : ''}',
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Visibility(
                                visible:
                                    returnSalesProvider()
                                        .currentCart()
                                        .discount ==
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
                                    returnSalesProvider()
                                        .currentCart()
                                        .discount !=
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
                  returnSalesProvider()
                      .currentCart()
                      .isSettingDiscountOpen,
              child: DiscountSetterBody(
                addListener: widget.addListener,
                removeListener: widget.removeListener,
                isGeneral: false,
                discountPercentController:
                    widget.discountPercentController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountSetterBody extends StatefulWidget {
  final TextEditingController discountPercentController;
  final bool isGeneral;
  final Function()? addListener;
  final Function()? removeListener;
  const DiscountSetterBody({
    super.key,
    required this.discountPercentController,
    required this.isGeneral,
    required this.addListener,
    required this.removeListener,
  });

  @override
  State<DiscountSetterBody> createState() =>
      _DiscountSetterBodyState();
}

class _DiscountSetterBodyState
    extends State<DiscountSetterBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnShopProvider().switchDiscountIndex(0);
    });
  }

  // int genNum = 0;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 20,
            top: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            spacing: 5,
            children: [
              Visibility(
                visible:
                    !widget.isGeneral &&
                    returnShopProvider(
                          context: context,
                        ).currentDiscount() !=
                        null &&
                    returnSubcsription(
                          context,
                        ).subscription?.plan !=
                        0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        5,
                        10,
                        5,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Apply General Discount',
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      2,
                                    ),
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor300,
                              ),
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                borderRadius:
                                    BorderRadius.circular(
                                      2,
                                    ),
                                onTap: () {
                                  if ((returnShopProvider()
                                              .currentDiscount() ??
                                          0) >
                                      returnSalesProvider()
                                          .calcSubTotal()) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme:
                                              returnTheme(
                                                context,
                                                listen:
                                                    false,
                                              ),
                                          message:
                                              'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                          title:
                                              'Action not Allowed',
                                        );
                                      },
                                    );
                                  } else {
                                    if (returnShopProvider()
                                            .userShop()
                                            ?.fixedDiscount !=
                                        null) {
                                      if (screenWidth(
                                            context,
                                          ) >
                                          mobileScreen) {
                                        returnSalesProvider()
                                            .addFixedDiscount(
                                              returnShopProvider()
                                                      .currentDiscount() ??
                                                  0,
                                            );
                                        returnSalesProvider()
                                            .toggleSetDiscount(
                                              false,
                                              context,
                                            );
                                        widget
                                            .addListener!();
                                      } else {
                                        returnSalesProvider()
                                            .addFixedDiscount(
                                              returnShopProvider()
                                                      .currentDiscount() ??
                                                  0,
                                            );
                                        widget
                                            .addListener!();
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      }
                                    }
                                    if (returnShopProvider()
                                            .userShop()
                                            ?.percentDiscount !=
                                        null) {
                                      if (screenWidth(
                                            context,
                                          ) >
                                          mobileScreen) {
                                        returnSalesProvider()
                                            .addPercentageDiscount(
                                              returnShopProvider()
                                                      .currentDiscount() ??
                                                  0,
                                            );
                                        returnSalesProvider()
                                            .toggleSetDiscount(
                                              false,
                                              context,
                                            );
                                        widget
                                            .addListener!();
                                      } else {
                                        returnSalesProvider()
                                            .addPercentageDiscount(
                                              returnShopProvider()
                                                      .currentDiscount() ??
                                                  0,
                                            );
                                        widget
                                            .addListener!();
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),

                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    "${(formatCompactMoney(context: context, amount: returnShopProvider(context: context).userShop()?.fixedDiscount) ?? returnShopProvider(context: context).userShop()?.percentDiscount ?? 0).toString()}${returnShopProvider().userShop()?.fixedDiscount == null ? '%' : ''}",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 15),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DiscountSelectionTab(
                      genNum:
                          returnShopProvider(
                            context: context,
                          ).discountIndex,
                      title: 'Percentage',
                      action: () {
                        returnShopProvider()
                            .switchDiscountIndex(0);
                        widget.discountPercentController
                            .clear();
                      },
                      myNum: 0,
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: DiscountSelectionTab(
                      genNum:
                          returnShopProvider(
                            context: context,
                          ).discountIndex,
                      action: () {
                        returnShopProvider()
                            .switchDiscountIndex(1);
                        widget.discountPercentController
                            .clear();
                      },
                      title: 'Fixed Amount',
                      myNum: 1,
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: 10),
                  Visibility(
                    visible: !widget.isGeneral,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          if (screenWidth(context) >
                              mobileScreen) {
                            returnSalesProvider()
                                .toggleSetDiscount(
                                  false,
                                  context,
                                );
                            widget.discountPercentController
                                .clear();
                            widget.addListener!();
                          } else {
                            widget.addListener!();
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            size: 18,
                            Icons.clear,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Builder(
                builder: (context) {
                  if (returnShopProvider().discountIndex ==
                      0) {
                    return Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 5,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children:
                              returnSalesProvider()
                                  .returnSomeDiscounts(0, 4)
                                  .map(
                                    (dis) => Expanded(
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap: () {
                                            if ((double.tryParse(
                                                      dis,
                                                    ) ??
                                                    0) >
                                                returnSalesProvider()
                                                    .calcSubTotal()) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme: returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ),
                                                    message:
                                                        'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                                    title:
                                                        'Action not Allowed',
                                                  );
                                                },
                                              );
                                            } else {
                                              if (!widget
                                                  .isGeneral) {
                                                if (screenWidth(
                                                      context,
                                                    ) >
                                                    mobileScreen) {
                                                  returnSalesProvider().addPercentageDiscount(
                                                    double.parse(
                                                      dis,
                                                    ),
                                                  );
                                                  returnSalesProvider().toggleSetDiscount(
                                                    false,
                                                    context,
                                                  );
                                                  widget
                                                      .addListener!();
                                                } else {
                                                  returnSalesProvider().addPercentageDiscount(
                                                    double.parse(
                                                      dis,
                                                    ),
                                                  );
                                                  widget
                                                      .addListener!();
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              } else {
                                                returnShopProvider()
                                                    .setGeneralPercentageDiscountCache(
                                                      double.tryParse(
                                                        dis,
                                                      ),
                                                    );
                                              }
                                              widget
                                                  .discountPercentController
                                                  .clear();
                                              widget
                                                  .addListener!();
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    3,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).generalPercentDiscount ==
                                                            double.tryParse(dis)
                                                        ? theme.lightModeColor.secColor200
                                                        : Colors.grey.shade100,
                                              ),
                                            ),
                                            padding:
                                                EdgeInsets.all(
                                                  3,
                                                ),
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
                                                  color:
                                                      returnShopProvider(
                                                                context:
                                                                    context,
                                                              ).generalPercentDiscount ==
                                                              double.tryParse(dis)
                                                          ? theme.lightModeColor.secColor200
                                                          : null,
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
                              MainAxisAlignment
                                  .spaceBetween,
                          children:
                              returnSalesProvider()
                                  .returnSomeDiscounts(4, 8)
                                  .map(
                                    (dis) => Expanded(
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap: () {
                                            if ((double.tryParse(
                                                      dis,
                                                    ) ??
                                                    0) >
                                                returnSalesProvider()
                                                    .calcSubTotal()) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme: returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ),
                                                    message:
                                                        'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                                    title:
                                                        'Action not Allowed',
                                                  );
                                                },
                                              );
                                            } else {
                                              if (!widget
                                                  .isGeneral) {
                                                if (screenWidth(
                                                      context,
                                                    ) >
                                                    mobileScreen) {
                                                  returnSalesProvider().addPercentageDiscount(
                                                    double.parse(
                                                      dis,
                                                    ),
                                                  );
                                                  returnSalesProvider().toggleSetDiscount(
                                                    false,
                                                    context,
                                                  );
                                                  widget
                                                      .addListener!();
                                                } else {
                                                  returnSalesProvider().addPercentageDiscount(
                                                    double.parse(
                                                      dis,
                                                    ),
                                                  );
                                                  widget
                                                      .addListener!();
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              } else {
                                                returnShopProvider()
                                                    .setGeneralPercentageDiscountCache(
                                                      double.tryParse(
                                                        dis,
                                                      ),
                                                    );
                                              }
                                              widget
                                                  .discountPercentController
                                                  .clear();
                                              widget
                                                  .addListener!();
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    3,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).generalPercentDiscount ==
                                                            double.tryParse(dis)
                                                        ? theme.lightModeColor.secColor200
                                                        : Colors.grey.shade100,
                                              ),
                                            ),
                                            padding:
                                                EdgeInsets.all(
                                                  3,
                                                ),
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
                                                  color:
                                                      returnShopProvider(
                                                                context:
                                                                    context,
                                                              ).generalPercentDiscount ==
                                                              double.tryParse(dis)
                                                          ? theme.lightModeColor.secColor200
                                                          : null,
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
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 0,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left:
                                        widget.isGeneral
                                            ? 0
                                            : 20.0,
                                  ),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      if (value
                                          .isNotEmpty) {
                                        returnShopProvider()
                                            .setGeneralFixedDiscountCache(
                                              null,
                                            );
                                        if (int.parse(
                                              value,
                                            ) >
                                            100) {
                                          widget
                                              .discountPercentController
                                              .text = '100';
                                          // setState(() {});
                                        }
                                      }
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly,
                                    ],
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                    ),
                                    keyboardType:
                                        TextInputType
                                            .number,
                                    autocorrect: false,
                                    enableSuggestions:
                                        false,
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
                                                FontWeight
                                                    .bold,
                                            color:
                                                Colors.grey,
                                          ),
                                          '%',
                                        ),
                                      ),

                                      prefixIconConstraints:
                                          BoxConstraints(
                                            minHeight: 0,
                                            minWidth: 0,
                                          ),

                                      contentPadding:
                                          EdgeInsets.only(
                                            right: 10,
                                            left: 10,
                                            top: 10,
                                            bottom: 10,
                                          ),
                                      hintText:
                                          'Enter Discount',
                                      hintStyle: TextStyle(
                                        color:
                                            Colors
                                                .grey
                                                .shade500,
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                      enabledBorder:
                                          OutlineInputBorder(
                                            borderSide:
                                                BorderSide(
                                                  color:
                                                      Colors
                                                          .grey,
                                                  width: 1,
                                                ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  5,
                                                ),
                                          ),
                                      focusedBorder: OutlineInputBorder(
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
                                    onTap:
                                        widget
                                            .removeListener,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !widget.isGeneral,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        8.0,
                                      ),
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        color:
                                            theme
                                                .lightModeColor
                                                .secColor200,
                                      ),
                                      child: InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        onTap: () {
                                          if (widget
                                              .discountPercentController
                                              .text
                                              .isNotEmpty) {
                                            if ((double.tryParse(
                                                      widget
                                                          .discountPercentController
                                                          .text,
                                                    ) ??
                                                    0) >
                                                returnSalesProvider()
                                                    .calcSubTotal()) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme: returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ),
                                                    message:
                                                        'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                                    title:
                                                        'Action not Allowed',
                                                  );
                                                },
                                              );
                                            } else {
                                              returnSalesProvider().addPercentageDiscount(
                                                double.parse(
                                                  widget
                                                      .discountPercentController
                                                      .text,
                                                ),
                                              );
                                              if (screenWidth(
                                                    context,
                                                  ) >
                                                  mobileScreen) {
                                                returnSalesProvider()
                                                    .toggleSetDiscount(
                                                      false,
                                                      context,
                                                    );
                                              } else {
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                              }
                                              widget
                                                  .addListener!();
                                              widget
                                                  .discountPercentController
                                                  .clear();
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(
                                                8.0,
                                              ),
                                          child: Center(
                                            child: Icon(
                                              size: 13,
                                              color:
                                                  Colors
                                                      .white,
                                              Icons.send,
                                            ),
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
                    );
                  } else {
                    return Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 5,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children:
                              returnSalesProvider()
                                  .returnSomeFixedDiscounts(
                                    0,
                                    4,
                                  )
                                  .map(
                                    (dis) => Expanded(
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap: () {
                                            if (dis
                                                    .toDouble() >
                                                returnSalesProvider()
                                                    .calcSubTotal()) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme: returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ),
                                                    message:
                                                        'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                                    title:
                                                        'Action not Allowed',
                                                  );
                                                },
                                              );
                                            } else {
                                              if (!widget
                                                  .isGeneral) {
                                                if (screenWidth(
                                                      context,
                                                    ) >
                                                    mobileScreen) {
                                                  returnSalesProvider()
                                                      .addFixedDiscount(
                                                        dis.toDouble(),
                                                      );
                                                  returnSalesProvider().toggleSetDiscount(
                                                    false,
                                                    context,
                                                  );
                                                  widget
                                                      .addListener!();
                                                } else {
                                                  returnSalesProvider()
                                                      .addFixedDiscount(
                                                        dis.toDouble(),
                                                      );
                                                  widget
                                                      .addListener!();
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              } else {
                                                returnShopProvider()
                                                    .setGeneralFixedDiscountCache(
                                                      dis.toDouble(),
                                                    );
                                              }
                                              widget
                                                  .discountPercentController
                                                  .clear();
                                              widget
                                                  .addListener!();
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    3,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).generalFixedDiscount ==
                                                            dis.toDouble()
                                                        ? theme.lightModeColor.secColor200
                                                        : Colors.grey.shade100,
                                              ),
                                            ),
                                            padding:
                                                EdgeInsets.all(
                                                  3,
                                                ),
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
                                                  color:
                                                      returnShopProvider(
                                                                context:
                                                                    context,
                                                              ).generalFixedDiscount ==
                                                              dis.toDouble()
                                                          ? theme.lightModeColor.secColor200
                                                          : null,
                                                ),
                                                "${formatCompactMoney(context: context, amount: dis.toDouble())}",
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
                              MainAxisAlignment
                                  .spaceBetween,
                          children:
                              returnSalesProvider()
                                  .returnSomeFixedDiscounts(
                                    4,
                                    8,
                                  )
                                  .map(
                                    (dis) => Expanded(
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap: () {
                                            if (dis
                                                    .toDouble() >
                                                returnSalesProvider()
                                                    .calcSubTotal()) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme: returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ),
                                                    message:
                                                        'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                                    title:
                                                        'Action not Allowed',
                                                  );
                                                },
                                              );
                                            } else {
                                              if (!widget
                                                  .isGeneral) {
                                                if (screenWidth(
                                                      context,
                                                    ) >
                                                    mobileScreen) {
                                                  returnSalesProvider()
                                                      .addFixedDiscount(
                                                        dis.toDouble(),
                                                      );
                                                  returnSalesProvider().toggleSetDiscount(
                                                    false,
                                                    context,
                                                  );
                                                  widget
                                                      .addListener!();
                                                } else {
                                                  returnSalesProvider()
                                                      .addFixedDiscount(
                                                        dis.toDouble(),
                                                      );
                                                  widget
                                                      .addListener!();
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                                widget
                                                    .discountPercentController
                                                    .clear();
                                              } else {
                                                returnShopProvider()
                                                    .setGeneralFixedDiscountCache(
                                                      dis.toDouble(),
                                                    );
                                                widget
                                                    .discountPercentController
                                                    .clear();
                                                widget
                                                    .addListener!();
                                              }
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    3,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).generalFixedDiscount ==
                                                            dis.toDouble()
                                                        ? theme.lightModeColor.secColor200
                                                        : Colors.grey.shade100,
                                              ),
                                            ),
                                            padding:
                                                EdgeInsets.all(
                                                  3,
                                                ),
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
                                                  color:
                                                      returnShopProvider(
                                                                context:
                                                                    context,
                                                              ).generalFixedDiscount ==
                                                              dis.toDouble()
                                                          ? theme.lightModeColor.secColor200
                                                          : null,
                                                ),
                                                "${formatCompactMoney(context: context, amount: dis.toDouble())}",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        // SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 0,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left:
                                        widget.isGeneral
                                            ? 0
                                            : 20.0,
                                  ),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      if (widget
                                          .discountPercentController
                                          .text
                                          .isNotEmpty) {
                                        returnShopProvider()
                                            .setGeneralPercentageDiscountCache(
                                              null,
                                            );
                                        if (!widget
                                            .isGeneral) {
                                          var cost =
                                              returnSalesProvider()
                                                  .calcSubTotal();
                                          if (cost <
                                              double.parse(
                                                widget
                                                    .discountPercentController
                                                    .text,
                                              )) {
                                            widget
                                                .discountPercentController
                                                .text = cost
                                                .toStringAsFixed(
                                                  0,
                                                );
                                          }
                                        }
                                      }
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly,
                                    ],
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                    ),
                                    keyboardType:
                                        TextInputType
                                            .number,
                                    autocorrect: false,
                                    enableSuggestions:
                                        false,
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
                                                FontWeight
                                                    .bold,
                                            color:
                                                Colors.grey,
                                          ),
                                          currencySymbol(
                                            context:
                                                context,
                                          ),
                                        ),
                                      ),

                                      prefixIconConstraints:
                                          BoxConstraints(
                                            minHeight: 0,
                                            minWidth: 0,
                                          ),

                                      contentPadding:
                                          EdgeInsets.only(
                                            right: 10,
                                            left: 10,
                                            top: 10,
                                            bottom: 10,
                                          ),
                                      hintText:
                                          'Enter Amount',
                                      hintStyle: TextStyle(
                                        color:
                                            Colors
                                                .grey
                                                .shade500,
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                      enabledBorder:
                                          OutlineInputBorder(
                                            borderSide:
                                                BorderSide(
                                                  color:
                                                      Colors
                                                          .grey,
                                                  width: 1,
                                                ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  5,
                                                ),
                                          ),
                                      focusedBorder: OutlineInputBorder(
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
                                    onTap:
                                        widget
                                            .removeListener,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !widget.isGeneral,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        8.0,
                                      ),
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        color:
                                            theme
                                                .lightModeColor
                                                .secColor200,
                                      ),
                                      child: InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        onTap: () {
                                          if (widget
                                              .discountPercentController
                                              .text
                                              .isNotEmpty) {
                                            if (double.parse(
                                                  widget
                                                      .discountPercentController
                                                      .text,
                                                ) >
                                                returnSalesProvider()
                                                    .calcSubTotal()) {
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme: returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ),
                                                    message:
                                                        'You Cannot Add a discount amount that is more than the total cost of your cart.',
                                                    title:
                                                        'Action not Allowed',
                                                  );
                                                },
                                              );
                                            } else {
                                              returnSalesProvider().addFixedDiscount(
                                                double.parse(
                                                  widget
                                                      .discountPercentController
                                                      .text,
                                                ),
                                              );
                                              if (screenWidth(
                                                    context,
                                                  ) >
                                                  mobileScreen) {
                                                returnSalesProvider()
                                                    .toggleSetDiscount(
                                                      false,
                                                      context,
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
                                          }
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(
                                                8.0,
                                              ),
                                          child: Center(
                                            child: Icon(
                                              size: 13,
                                              color:
                                                  Colors
                                                      .white,
                                              Icons.send,
                                            ),
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
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiscountSelectionTab extends StatelessWidget {
  final String title;
  final Function() action;
  const DiscountSelectionTab({
    super.key,
    required this.myNum,
    required this.genNum,
    required this.theme,
    required this.title,
    required this.action,
  });

  final int myNum;
  final int genNum;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color:
                myNum == genNum
                    ? Color.fromARGB(55, 255, 168, 7)
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color:
                    myNum == genNum
                        ? Colors.amber
                        : Colors.transparent,
              ),
            ),
          ),
          child: Center(
            child: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight:
                    myNum == genNum
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
              title,
            ),
          ),
        ),
      ),
    );
  }
}

void setDiscountAction(
  BuildContext context,
  TextEditingController discountPercentController,
  Function()? addListener,
  Function()? removeListener,
) {
  var salesPFalse = returnSalesProvider();
  removeListener!();
  if (salesPFalse.currentCart().discount == null &&
      salesPFalse.currentCart().fixedDiscount == null) {
    if (salesPFalse.currentCart().isSettingDiscountOpen ==
        true) {
      salesPFalse.toggleSetDiscount(false, context);
    } else {
      if (screenWidth(context) < mobileScreen) {
        SalesAuthAction().applyDiscountAction(
          context: context,
          action: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  contentPadding: EdgeInsets.all(15),
                  backgroundColor: Colors.white,
                  content: SizedBox(
                    width:
                        BoxConstraints().maxWidth < 400
                            ? 350
                            : 500,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20.0,
                      ),
                      child: DiscountSetterBody(
                        addListener: addListener,
                        removeListener: removeListener,
                        isGeneral: false,
                        discountPercentController:
                            discountPercentController,
                      ),
                    ),
                  ),
                );
              },
            ).then((_) {
              discountPercentController.clear();
              addListener!();
            });
          },
        );
      } else {
        salesPFalse.toggleSetDiscount(true, context);
      }
    }
  } else {
    salesPFalse.addFixedDiscount(null);
    salesPFalse.addPercentageDiscount(null);
    addListener!();
  }
}
