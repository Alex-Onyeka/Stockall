import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/components/production_item_cart_item.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/components/production_materials_cart_item_tile.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/functions/create_production_functions.dart';

class CreateProductionDesktop extends StatefulWidget {
  const CreateProductionDesktop({super.key});

  @override
  State<CreateProductionDesktop> createState() =>
      _CreateProductionDesktopState();
}

class _CreateProductionDesktopState
    extends State<CreateProductionDesktop> {
  bool isLoading = false;
  bool showSuccess = false;
  void createProductionRecord() {
    var theme = returnTheme(context, listen: false);
    if (returnProductionsActionProvider()
            .getProductionsCart()
            ?.productionsCartItem !=
        null) {
      showDialog(
        context: context,
        builder: (confirmContext) {
          return ConfirmationAlert(
            theme: theme,
            message:
                'You are about to ${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? "Update a" : "Record a New"} Production. Are you sure you want to proceed?',
            title:
                '${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? "Update" : "Record New"} Production',
            action: () async {
              Navigator.of(confirmContext).pop();
              setState(() {
                isLoading = true;
              });
              var res =
                  await returnProductionRecordsProvider()
                      .createProductionRecord();
              setState(() {
                isLoading = false;
              });
              if (res != null) {
                setState(() {
                  showSuccess = true;
                });
                returnProductionsActionProvider()
                    .resetProductionCart();
                await Future.delayed(
                  (Duration(seconds: 2)),
                );
                if (returnProductionsActionProvider()
                        .getProductionsCart()
                        ?.isEdit ==
                    true) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    showSuccess = false;
                  });
                }
              }
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var cartActionProv = returnProductionsActionProvider();
    ProductionsCart? cartItem =
        returnProductionsActionProvider(
          context: context,
        ).getProductionsCart();
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      width: 900,
      mainWidget: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    if (returnProductionsActionProvider()
                            .getProductionsCart()
                            ?.isEdit ==
                        true) {
                      cancelUpdate(context: context);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 20,
                    ),
                    child: Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ),
              ),
              Column(
                spacing: 2,
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          theme
                              .lightModeColor
                              .shadesColorBlack,
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight:
                          theme
                              .mobileTexts
                              .h4
                              .fontWeightBold,
                    ),
                    '${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? 'Update' : 'Create'} Production',
                  ),
                  Text(
                    style:
                        theme
                            .mobileTexts
                            .b3
                            .textStyleNormal,
                    "${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? 'Update' : 'Create New'} Production",
                  ),
                ],
              ),
              Opacity(
                opacity:
                    (cartItem
                                    ?.materialsCartItems
                                    .isNotEmpty ==
                                true ||
                            cartItem?.productionsCartItem !=
                                null)
                        ? 1
                        : 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      clearCartOrCancelUpdateFunction(
                        context: context,
                        isEdit:
                            returnProductionsActionProvider()
                                .getProductionsCart()
                                ?.isEdit,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.only(
                        right: 10,
                        left: 10,
                        top: 5,
                        bottom: 5,
                      ),
                      decoration: BoxDecoration(),
                      child: Row(
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            returnProductionsActionProvider()
                                        .getProductionsCart()
                                        ?.isEdit ==
                                    true
                                ? "Cancel"
                                : 'Clear Cart',
                          ),
                          Icon(size: 17, Icons.clear),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return returnCompProvider(
                      context,
                    ).showLoader(
                      message:
                          '${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? 'Updating' : 'Creating'} Production',
                    );
                  } else if (showSuccess) {
                    return returnCompProvider(
                      context,
                    ).showSuccess(
                      'Production ${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? 'Updated' : 'Created'} Successfully',
                    );
                  } else {
                    if (cartItem == null) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          10,
                          10,
                          10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color:
                              theme
                                  .lightModeColor
                                  .prColor50,
                          border: Border.all(
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                          ),
                        ),
                        child: EmptyWidgetDisplay(
                          title: 'Cart Not Set',
                          buttonText: 'Initialize Cart',
                          subText:
                              'Click on the Button Below To Initialize Cart',
                          theme: theme,
                          action: () {
                            cartActionProv
                                .initProductionsCart();
                          },
                          altAction: () {},
                          altIcon: null,
                        ),
                      );
                    } else {
                      return ListView(
                        children: [
                          Container(
                            height: 180,
                            padding:
                                const EdgeInsets.fromLTRB(
                                  10,
                                  10,
                                  10,
                                  10,
                                ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(5),
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor50,
                              border: Border.all(
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor300,
                              ),
                            ),
                            child: Builder(
                              builder: (context) {
                                if (cartItem
                                        .productionsCartItem ==
                                    null) {
                                  return EmptyWidgetDisplay(
                                    title: 'Item Not Set',
                                    buttonText:
                                        'Select Item',
                                    subText:
                                        'Click on the Button Below to select an Item to Produce',
                                    theme: theme,
                                    action: () {
                                      CreateProductionFunctions()
                                          .selectItemForProduction(
                                            firstContext:
                                                context,
                                          );
                                    },
                                    altAction: () {},
                                    altIcon: null,
                                  );
                                } else {
                                  return ProductionItemCartItem(
                                    productionsCartItem:
                                        cartItem
                                            .productionsCartItem,
                                    theme: theme,
                                    editAction: () {
                                      CreateProductionFunctions()
                                          .addSelectedItemToCart(
                                            secondContext:
                                                context,
                                            editItem:
                                                cartItem
                                                    .productionsCartItem,
                                          );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(
                            color: Colors.grey.shade400,
                            thickness: 0.3,
                          ),
                          Padding(
                            padding:
                                EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  5,
                                  10,
                                  10,
                                ),
                            child: Row(
                              spacing: 10,
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
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
                                  ),
                                  'Materials',
                                ),
                                Row(
                                  spacing: 5,
                                  children: [
                                    Material(
                                      type:
                                          MaterialType
                                              .transparency,
                                      child: InkWell(
                                        onTap: () {
                                          CreateProductionFunctions()
                                              .selectItemForProductionMaterials(
                                                firstContext:
                                                    context,
                                              );
                                        },
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical:
                                                    10.0,
                                                horizontal:
                                                    12,
                                              ),
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
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
                                                          .normal,
                                                  color:
                                                      theme
                                                          .lightModeColor
                                                          .secColor200,
                                                ),
                                                'Add Material',
                                              ),
                                              Icon(
                                                size: 16,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                Icons.add,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          cartItem
                                              .materialsCartItems
                                              .isNotEmpty,
                                      child: Material(
                                        type:
                                            MaterialType
                                                .transparency,
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                confirmContext,
                                              ) {
                                                return ConfirmationAlert(
                                                  theme:
                                                      theme,
                                                  message:
                                                      'You are about to Clear Every Materials from the cart. Are you sure you want to proceed?',
                                                  title:
                                                      'Clear Materials',
                                                  action: () {
                                                    cartActionProv
                                                        .clearProductionMaterials();
                                                    Navigator.of(
                                                      confirmContext,
                                                    ).pop();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      10.0,
                                                  horizontal:
                                                      12,
                                                ),
                                            child: Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              spacing: 5,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        Colors.grey,
                                                  ),
                                                  'Clear',
                                                ),
                                                Icon(
                                                  size: 16,
                                                  color:
                                                      Colors
                                                          .grey,
                                                  Icons
                                                      .clear,
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
                          Builder(
                            builder: (context) {
                              if (cartItem
                                  .materialsCartItems
                                  .isEmpty) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Material(
                                      type:
                                          MaterialType
                                              .transparency,
                                      child: EmptyWidgetDisplay(
                                        title:
                                            'No Material Added',
                                        subText:
                                            'Click on the Button Below to add Production Materials',
                                        theme: theme,
                                        height: 0,
                                        // icon: Icons.clear,
                                        action: () {
                                          CreateProductionFunctions()
                                              .selectItemForProductionMaterials(
                                                firstContext:
                                                    context,
                                              );
                                        },
                                        buttonText:
                                            'Add New Material',
                                        altAction: () {},
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Column(
                                  spacing: 5,
                                  children:
                                      cartItem
                                          .materialsCartItems
                                          .reversed
                                          .map(
                                            (
                                              item,
                                            ) => ProductionMaterialCartItemTile(
                                              productionMaterialCartItem:
                                                  item,
                                              editAction: () {
                                                CreateProductionFunctions().addSelectedMaterialToCart(
                                                  secondContext:
                                                      context,
                                                  selectedMaterial:
                                                      null,
                                                  editMaterialItem:
                                                      item,
                                                );
                                              },
                                            ),
                                          )
                                          .toList(),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              spacing: 5,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          CreateProductionFunctions()
                              .setTotalCostValue(
                                context: context,
                              );
                        },
                        mouseCursor:
                            SystemMouseCursors.click,
                        child: Padding(
                          padding:
                              EdgeInsetsGeometry.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Total Cost (${cartItem?.selectCostPriceToUse == 1
                                        ? 'Item'
                                        : cartItem?.selectCostPriceToUse == 2
                                        ? 'Materials'
                                        : 'Custom'}):',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    formatMoneyBig(
                                      amount:
                                          cartItem
                                              ?.getCostPrice() ??
                                          0,
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(size: 18, Icons.edit),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                MainButtonP(
                  themeProvider: theme,
                  action: () async {
                    createProductionRecord();
                  },
                  text:
                      '${returnProductionsActionProvider().getProductionsCart()?.isEdit == true ? "Update" : 'Create'} Production',
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

void clearCartOrCancelUpdateFunction({
  required BuildContext context,
  required bool? isEdit,
}) {
  var theme = returnTheme(context, listen: false);
  if (isEdit != true) {
    showDialog(
      context: context,
      builder: (confirmContext) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to Clear Every Items from the cart. Are you sure you want to proceed?',
          title: 'Clear Cart',
          action: () {
            returnProductionsActionProvider()
                .resetProductionCart();
            Navigator.of(confirmContext).pop();
          },
        );
      },
    );
  } else {
    cancelUpdate(context: context);
  }
}

void cancelUpdate({required BuildContext context}) {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (confirmContext) {
      return ConfirmationAlert(
        theme: theme,
        message:
            'You are about to Cancel This update. Are you sure you want to proceed?',
        title: 'Cancel Update',
        action: () {
          returnProductionsActionProvider()
              .resetProductionCart();
          Navigator.of(confirmContext).pop();
          Navigator.of(context).pop();
        },
      );
    },
  );
}
