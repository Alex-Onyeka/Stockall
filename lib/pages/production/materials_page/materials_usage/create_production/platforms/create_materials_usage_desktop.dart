import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/materials_usage_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_production/components/material_usage_cart_item_tile.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_production/functions/create_materials_usage_functions.dart';

class CreateMaterialsUsageDesktop extends StatefulWidget {
  const CreateMaterialsUsageDesktop({super.key});

  @override
  State<CreateMaterialsUsageDesktop> createState() =>
      _CreateMaterialsUsageDesktopState();
}

class _CreateMaterialsUsageDesktopState
    extends State<CreateMaterialsUsageDesktop> {
  bool isLoading = false;
  bool showSuccess = false;
  void createMaterialsUsageRecord() {
    var theme = returnTheme(context, listen: false);
    if (returnMaterialsUsageActionProvider()
            .getMaterialsUsageCart()
            ?.cartItems
            .isNotEmpty ==
        true) {
      showDialog(
        context: context,
        builder: (confirmContext) {
          return ConfirmationAlert(
            theme: theme,
            message:
                'You are about to ${returnMaterialsUsageActionProvider().getMaterialsUsageCart()?.isEdit == true ? "Update a" : "Record a New"} Materail Usage Record. Are you sure you want to proceed?',
            title:
                '${returnMaterialsUsageActionProvider().getMaterialsUsageCart()?.isEdit == true ? "Update" : "Record New"} Materail Usage Record',
            action: () async {
              Navigator.of(confirmContext).pop();
              setState(() {
                isLoading = true;
              });
              var res =
                  await returnMaterialsUsageActionProvider()
                      .createMaterialsUsageAction();
              setState(() {
                isLoading = false;
              });
              if (res == 1) {
                setState(() {
                  showSuccess = true;
                });
                // returnMaterialsUsageActionProvider()
                //     .resetMaterialsUsageCart();
                await Future.delayed(
                  (Duration(seconds: 2)),
                );
                if (returnMaterialsUsageActionProvider()
                        .getMaterialsUsageCart()
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
    var actionProvider =
        returnMaterialsUsageActionProvider();
    MaterialsUsageCart? cartItem =
        returnMaterialsUsageActionProvider(
          context: context,
        ).getMaterialsUsageCart();
    List<MaterialsUsageCartItem> items =
        returnMaterialsUsageActionProvider(
          context: context,
        ).getMaterials();
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
                    if (cartItem?.isEdit == true) {
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
                    '${returnMaterialsUsageActionProvider().getMaterialsUsageCart()?.isEdit == true ? 'Update' : 'Create'} Material Usage Record',
                  ),
                  Text(
                    style:
                        theme
                            .mobileTexts
                            .b3
                            .textStyleNormal,
                    "${returnMaterialsUsageActionProvider().getMaterialsUsageCart()?.isEdit == true ? 'Update' : 'Create New'} Material Usage Record",
                  ),
                ],
              ),
              Opacity(
                opacity:
                    (cartItem?.cartItems.isNotEmpty == true)
                        ? 1
                        : 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      clearMaterialsUsageCartOrCancelUpdateFunction(
                        context: context,
                        isEdit: cartItem?.isEdit,
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
                            returnMaterialsUsageActionProvider()
                                        .getMaterialsUsageCart()
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
                          '${returnMaterialsUsageActionProvider().getMaterialsUsageCart()?.isEdit == true ? 'Updating' : 'Creating'} Material Usage Record',
                    );
                  } else if (showSuccess) {
                    return returnCompProvider(
                      context,
                    ).showSuccess(
                      'Material Usage Record ${returnMaterialsUsageActionProvider().getMaterialsUsageCart()?.isEdit == true ? 'Updated' : 'Created'} Successfully',
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
                        child: Center(
                          child: EmptyWidgetDisplay(
                            title: 'Cart Not Set',
                            buttonText: 'Initialize Cart',
                            subText:
                                'Click on the Button Below To Initialize Cart',
                            theme: theme,
                            action: () {
                              actionProvider
                                  .initMaterialsUsageCart();
                            },
                            altAction: () {},
                            altIcon: null,
                          ),
                        ),
                      );
                    } else {
                      return ListView(
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  0,
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
                                Visibility(
                                  visible: !cartItem.isEdit,
                                  child: Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: InkWell(
                                      onTap: () {
                                        CreateMaterialsUsageFunctions()
                                            .selectItemForMaterialsUsageCart(
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
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              if (items.isEmpty) {
                                return SizedBox(
                                  height: 400,
                                  child: Center(
                                    child: Material(
                                      type:
                                          MaterialType
                                              .transparency,
                                      child: EmptyWidgetDisplay(
                                        title:
                                            'No Material Added',
                                        subText:
                                            'Click on the Button Below to add Material Usage Record',
                                        theme: theme,
                                        height: 0,
                                        // icon: Icons.clear,
                                        action: () {
                                          CreateMaterialsUsageFunctions()
                                              .selectItemForMaterialsUsageCart(
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
                                      items.reversed
                                          .map(
                                            (
                                              item,
                                            ) => MaterialUsageCartItemTile(
                                              materialsUsageCartItem:
                                                  item,
                                              editAction: () {
                                                CreateMaterialsUsageFunctions().addSelectedMaterialToCart(
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
                MainButtonP(
                  themeProvider: theme,
                  action: () async {
                    createMaterialsUsageRecord();
                  },
                  text:
                      '${cartItem?.isEdit == true ? "Update" : 'Create'} Usage Record(s)',
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

void clearMaterialsUsageCartOrCancelUpdateFunction({
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
            returnMaterialsUsageActionProvider()
                .resetMaterialsUsageCart();
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
          returnMaterialsUsageActionProvider()
              .resetMaterialsUsageCart();
          Navigator.of(confirmContext).pop();
          Navigator.of(context).pop();
        },
      );
    },
  );
}
