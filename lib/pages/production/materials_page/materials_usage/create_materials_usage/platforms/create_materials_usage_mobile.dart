import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/materials_usage_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/components/material_usage_cart_item_tile.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/functions/create_materials_usage_functions.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/platforms/create_materials_usage_desktop.dart';

class CreateMaterialsUsageMobile extends StatefulWidget {
  const CreateMaterialsUsageMobile({super.key});

  @override
  State<CreateMaterialsUsageMobile> createState() =>
      _CreateProductionMobileState();
}

class _CreateProductionMobileState
    extends State<CreateMaterialsUsageMobile> {
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
    return PopScope(
      canPop: cartItem?.isEdit == true ? false : true,
      child: Scaffold(
        appBar: appBar(
          context: context,
          title:
              '${cartItem?.isEdit == true ? 'Update' : 'Create'} Material Usage',
          backAction: () {
            if (cartItem?.isEdit == true) {
              cancelUpdate(context: context);
            } else {
              Navigator.of(context).pop();
            }
          },
          widget: Opacity(
            opacity:
                (cartItem?.cartItems.isNotEmpty == true)
                    ? 1
                    : 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
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
                          cartItem?.isEdit == true
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
          ),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return returnCompProvider(
                  context,
                ).showLoader(
                  message:
                      '${cartItem?.isEdit == true ? 'Updating' : 'Creating'} Material Usage Record',
                );
              } else if (showSuccess) {
                return returnCompProvider(
                  context,
                ).showSuccess(
                  'Material Usage Record ${cartItem?.isEdit == true ? 'Updated' : 'Created'} Successfully',
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (cartItem == null) {
                              return Container(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                      10,
                                      10,
                                      10,
                                      10,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
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
                                    buttonText:
                                        'Initialize Cart',
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
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Materials',
                                        ),
                                        Material(
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
                                              padding: const EdgeInsets.symmetric(
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
                                                          theme.lightModeColor.secColor200,
                                                    ),
                                                    'Add Material',
                                                  ),
                                                  Icon(
                                                    size:
                                                        16,
                                                    color:
                                                        theme.lightModeColor.secColor200,
                                                    Icons
                                                        .add,
                                                  ),
                                                ],
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
                                                theme:
                                                    theme,
                                                height: 0,
                                                // icon: Icons.clear,
                                                action: () {
                                                  CreateMaterialsUsageFunctions().selectItemForMaterialsUsageCart(
                                                    firstContext:
                                                        context,
                                                  );
                                                },
                                                buttonText:
                                                    'Add New Material',
                                                altAction:
                                                    () {},
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
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
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
            },
          ),
        ),
      ),
    );
  }
}
