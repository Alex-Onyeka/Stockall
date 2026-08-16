import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductionItemCartItem extends StatelessWidget {
  final ProductionsCartItem? productionsCartItem;
  final ThemeProvider theme;
  final Function()? editAction;
  const ProductionItemCartItem({
    super.key,
    required this.productionsCartItem,
    required this.theme,
    this.editAction,
  });

  @override
  Widget build(BuildContext context) {
    ProductionsCartItem item =
        productionsCartItem ??
        ProductionsCartItem(
          salesItemUuid: 'salesItemUuid',
          originalUseGroupQuantity: false,
          uuid: uuidGen(),
          originalCostPerItem: 0,
          itemUuid: 'itemUuid',
          name: 'name',
          quantity: 2,
          addToStock: false,
          useGroupQuantity: false,
          setCustomPrice: false,
        );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (screenWidth(context) < mobileScreen) {
          return ProductionItemCartItemleMobile(
            productionsCartItem: item,
            theme: theme,
            editAction: editAction,
          );
        } else {
          return ProductionItemCartItemleDesktop(
            productionsCartItem: item,
            theme: theme,
            editAction: editAction,
          );
        }
      },
    );
  }
}

class ProductionItemCartItemleMobile
    extends StatelessWidget {
  final ProductionsCartItem productionsCartItem;
  final ThemeProvider theme;
  final Function()? editAction;
  const ProductionItemCartItemleMobile({
    super.key,
    required this.productionsCartItem,
    required this.theme,
    this.editAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(25, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: Icon(
                  size: 18,
                  color: theme.lightModeColor.prColor250,
                  Icons.view_in_ar_rounded,
                ),
              ),
              Text(
                style: TextStyle(
                  color: theme.lightModeColor.greyColor200,
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.w500,
                ),
                formatMoneyBig(
                  amount:
                      productionsCartItem.costPrice ?? 0,
                  context: context,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  style: TextStyle(
                    color:
                        theme.lightModeColor.greyColor200,
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),

                  productionsCartItem.name,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(
              // left: 10.0,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 3,
                  children: [
                    Text(
                      style: TextStyle(
                        color:
                            theme
                                .lightModeColor
                                .greyColor200,
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight:
                            theme
                                .mobileTexts
                                .h3
                                .fontWeightBold,
                      ),
                      formatLargeNumber(
                        productionsCartItem.quantity
                            .toString(),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        color:
                            theme
                                .lightModeColor
                                .greyColor200,
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      productionsCartItem.getUnit(),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: editAction,
                        mouseCursor:
                            SystemMouseCursors.click,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 5,
                              ),
                          child: Icon(
                            color: Colors.grey.shade600,
                            size: 22,
                            Icons.edit,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to remove this item from the cart. Are you sure you want to proceed?',
                                title:
                                    'Remove Item From Cart',
                                action: () {
                                  returnProductionsActionProvider()
                                      .removeProductionItemFromCart();
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                },
                              );
                            },
                          );
                        },
                        mouseCursor:
                            SystemMouseCursors.click,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 5,
                              ),
                          child: Icon(
                            color: Colors.red.shade300,
                            size: 22,
                            Icons.clear,
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
    );
  }
}

class ProductionItemCartItemleDesktop
    extends StatelessWidget {
  final ProductionsCartItem productionsCartItem;
  final ThemeProvider theme;
  final Function()? editAction;
  const ProductionItemCartItemleDesktop({
    super.key,
    required this.theme,
    required this.productionsCartItem,
    this.editAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(25, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 8,
            children: [
              Visibility(
                visible:
                    MediaQuery.of(context).size.width > 335,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: Icon(
                    size: 22,
                    color: theme.lightModeColor.prColor250,
                    Icons.view_in_ar_rounded,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  style: TextStyle(
                    color:
                        theme.lightModeColor.greyColor200,
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),

                  productionsCartItem.name,
                ),
              ),
              Text(
                style: TextStyle(
                  color: theme.lightModeColor.greyColor200,
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                formatMoneyBig(
                  amount:
                      productionsCartItem.costPrice ?? 0,
                  context: context,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Text(
                      style: TextStyle(
                        color:
                            theme
                                .lightModeColor
                                .greyColor200,
                        fontSize:
                            theme.mobileTexts.h3.fontSize,
                        fontWeight:
                            theme
                                .mobileTexts
                                .h3
                                .fontWeightBold,
                      ),
                      formatLargeNumber(
                        productionsCartItem.quantity
                            .toString(),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        color:
                            theme
                                .lightModeColor
                                .greyColor200,
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      productionsCartItem.getUnit(),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: editAction,
                        mouseCursor:
                            SystemMouseCursors.click,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 5,
                              ),
                          child: Icon(
                            color: Colors.grey.shade600,
                            size: 22,
                            Icons.edit,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to remove this item from the cart. Are you sure you want to proceed?',
                                title:
                                    'Remove Item From Cart',
                                action: () {
                                  returnProductionsActionProvider()
                                      .removeProductionItemFromCart();
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                },
                              );
                            },
                          );
                        },
                        mouseCursor:
                            SystemMouseCursors.click,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 5,
                              ),
                          child: Icon(
                            color: Colors.red.shade300,
                            size: 22,
                            Icons.clear,
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
    );
  }
}
