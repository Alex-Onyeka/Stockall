import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/production_unit_snapshot.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/components/select_total_cost_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';

class CreateProductionFunctions {
  void setTotalCostValue({required BuildContext context}) {
    var theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (firstContext) {
        final totalController = TextEditingController();
        int currentSelection =
            returnProductionsActionProvider(
              context: firstContext,
            ).getProductionsCart()?.selectCostPriceToUse ??
            1;
        totalController.text =
            '${returnProductionsActionProvider().getProductionsCart()?.customPrice ?? ''}';

        return StatefulBuilder(
          builder:
              (context, setState) => DialogTemplate(
                theme: theme,
                message:
                    'Select The Cost for this Production',
                title: 'Set Total Cost',
                action: () {
                  if (currentSelection == 3 &&
                      totalController.text.isEmpty) {
                  } else {
                    returnProductionsActionProvider()
                        .setTotalCost(
                          customCost: double.tryParse(
                            totalController.text.replaceAll(
                              ',',
                              '',
                            ),
                          ),
                          selection: currentSelection,
                        );
                    Navigator.of(context).pop();
                  }
                },
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    SelectTotalCostWidget(
                      index: 1,
                      subText:
                          'Set the Total Cost from the Total Cost of the Produced Items',
                      title:
                          'Set Total Produced Cost - ${formatMoneyBig(amount: returnProductionsActionProvider().getProductionsCart()?.productionsCartItem?.costPrice ?? 0, context: context)}',
                      currentSelection: currentSelection,
                      action: () {
                        setState(() {
                          currentSelection = 1;
                        });
                        totalController.clear();
                      },
                    ),
                    SelectTotalCostWidget(
                      title:
                          'Set Total Materials Cost - ${formatMoneyBig(amount: returnProductionsActionProvider().getProductionsCart()?.materialsCartItems.map((item) => (item.costPrice ?? 0)).fold(0.0, (a, b) => (a ?? 0) + b) ?? 0, context: context)}',
                      index: 2,
                      currentSelection: currentSelection,
                      subText:
                          'Set The total Cost From The total Cost of the Materials Used',
                      action: () {
                        setState(() {
                          currentSelection = 2;
                        });
                        totalController.clear();
                      },
                    ),
                    SelectTotalCostWidget(
                      title: 'Set Custom Cost',
                      subText:
                          'Set The Total Cost From a Custom Amount you Choose.',
                      index: 3,
                      currentSelection: currentSelection,
                      action: () {
                        setState(() {
                          currentSelection = 3;
                        });
                      },
                    ),
                    Visibility(
                      visible: currentSelection == 3,
                      child: Column(
                        children: [
                          SizedBox(height: 5),
                          MoneyTextfield(
                            autoFocus: true,
                            title: 'Enter Total',
                            hint: 'Enter Custom Total',
                            controller: totalController,
                            theme: theme,
                            showTitle: false,
                            onSubmitted: (p0) {
                              if (currentSelection == 3 &&
                                  totalController
                                      .text
                                      .isEmpty) {
                              } else {
                                returnProductionsActionProvider()
                                    .setTotalCost(
                                      customCost:
                                          double.tryParse(
                                            totalController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      selection:
                                          currentSelection,
                                    );
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  // void selectSalesItemForProduction({
  //   required BuildContext firstContext,
  // }) {
  //   var theme = returnTheme(firstContext, listen: false);
  //   final searchController = TextEditingController();

  //   showDialog(
  //     context: firstContext,
  //     builder: (secondContext) {
  //       return StatefulBuilder(
  //         builder: (statefulContext, setState) {
  //           return DialogTemplate(
  //             theme: theme,
  //             message: 'Select an Item From the List Below',
  //             title: 'Select Item',
  //             action: () {
  //               if (selectedItem != null) {
  //                 addSelectedItemToCart(
  //                   secondContext: secondContext,
  //                   selectedItem: selectedItem,
  //                 );
  //               }
  //             },
  //             widget: SizedBox(
  //               height: screenHeight(statefulContext) - 200,
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment:
  //                         MainAxisAlignment.center,
  //                     children: [
  //                       Expanded(
  //                         child: ConstrainedBox(
  //                           constraints: BoxConstraints(
  //                             maxWidth: 400,
  //                             maxHeight: 40,
  //                           ),
  //                           child: GeneralTextfieldOnly(
  //                             autoFocus: true,
  //                             onChanged: (p0) {
  //                               setState(() {});
  //                             },
  //                             hint: 'Search Name',
  //                             controller: searchController,
  //                             lines: 1,
  //                             theme: theme,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 5),
  //                   Expanded(
  //                     child: SingleChildScrollView(
  //                       child: Padding(
  //                         padding:
  //                             const EdgeInsets.symmetric(
  //                               horizontal: 5.0,
  //                               vertical: 10,
  //                             ),
  //                         child: Builder(
  //                           builder: (context) {
  //                             if (returnData()
  //                                 .productList()
  //                                 .where(
  //                                   (item) => item.name
  //                                       .toLowerCase()
  //                                       .contains(
  //                                         searchController
  //                                             .text
  //                                             .toLowerCase(),
  //                                       ),
  //                                 )
  //                                 .isEmpty) {
  //                               return SizedBox(
  //                                 height: 400,
  //                                 child: EmptyWidgetDisplayOnly(
  //                                   title: 'No Item Found',
  //                                   subText:
  //                                       'No item was found.',
  //                                   theme: theme,
  //                                   height: 30,
  //                                   altAction: () async {
  //                                     await returnData()
  //                                         .getProducts(
  //                                           shopId(),
  //                                         );
  //                                     setState(() {});
  //                                   },
  //                                   altActionText:
  //                                       'Refresh',
  //                                   icon: Icons.clear,
  //                                 ),
  //                               );
  //                             } else {
  //                               return Column(
  //                                 spacing: 5,
  //                                 children:
  //                                     returnData()
  //                                         .productList()
  //                                         .where(
  //                                           (item) => item
  //                                               .name
  //                                               .toLowerCase()
  //                                               .contains(
  //                                                 searchController
  //                                                     .text
  //                                                     .toLowerCase(),
  //                                               ),
  //                                         )
  //                                         .map(
  //                                           (
  //                                             item,
  //                                           ) => Material(
  //                                             color:
  //                                                 Colors
  //                                                     .transparent,
  //                                             child: InkWell(
  //                                               mouseCursor:
  //                                                   SystemMouseCursors
  //                                                       .click,
  //                                               onTap: () {
  //                                                 setState(() {
  //                                                   if (selectedItem?.uuid ==
  //                                                       item.uuid) {
  //                                                     selectedItem =
  //                                                         null;
  //                                                   } else {
  //                                                     selectedItem =
  //                                                         item;
  //                                                   }
  //                                                 });
  //                                               },
  //                                               child: Padding(
  //                                                 padding: const EdgeInsets.symmetric(
  //                                                   vertical:
  //                                                       9.0,
  //                                                   horizontal:
  //                                                       10,
  //                                                 ),
  //                                                 child: Row(
  //                                                   mainAxisAlignment:
  //                                                       MainAxisAlignment.spaceBetween,
  //                                                   children: [
  //                                                     Text(
  //                                                       style: TextStyle(
  //                                                         fontSize:
  //                                                             theme.mobileTexts.b3.fontSize,
  //                                                         fontWeight:
  //                                                             FontWeight.bold,
  //                                                       ),
  //                                                       item.name,
  //                                                     ),
  //                                                     Row(
  //                                                       spacing:
  //                                                           15,
  //                                                       children: [
  //                                                         Text(
  //                                                           style: TextStyle(
  //                                                             fontSize:
  //                                                                 theme.mobileTexts.b3.fontSize,
  //                                                             fontWeight:
  //                                                                 FontWeight.bold,
  //                                                           ),
  //                                                           '${item.quantity ?? 0}',
  //                                                         ),
  //                                                         Container(
  //                                                           padding: EdgeInsets.all(
  //                                                             2,
  //                                                           ),
  //                                                           decoration: BoxDecoration(
  //                                                             shape:
  //                                                                 BoxShape.circle,
  //                                                             border: Border.all(
  //                                                               color:
  //                                                                   Colors.grey,
  //                                                             ),
  //                                                           ),
  //                                                           child: Container(
  //                                                             padding: EdgeInsets.all(
  //                                                               5,
  //                                                             ),
  //                                                             decoration: BoxDecoration(
  //                                                               shape:
  //                                                                   BoxShape.circle,
  //                                                               color:
  //                                                                   selectedItem?.uuid ==
  //                                                                           item.uuid
  //                                                                       ? theme.lightModeColor.prColor250
  //                                                                       : Colors.transparent,
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                       ],
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         )
  //                                         .toList(),
  //                               );
  //                             }
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void selectItemForProduction({
    required BuildContext firstContext,
  }) {
    var theme = returnTheme(firstContext, listen: false);
    final searchController = TextEditingController();
    ProductionItem? selectedItem;
    TempProductClass? selectedSalesItem;
    bool useProductionItems =
        returnShopProvider()
            .userShop()
            ?.manageProductionItems ??
        false;
    showDialog(
      context: firstContext,
      builder: (secondContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return DialogTemplate(
              theme: theme,
              message: 'Select an Item From the List Below',
              title: 'Select Item',
              action: () {
                if (useProductionItems) {
                  if (selectedItem != null) {
                    addSelectedItemToCart(
                      secondContext: secondContext,
                      selectedItem: selectedItem,
                    );
                  }
                } else {
                  addSelectedItemToCart(
                    secondContext: secondContext,
                    selectedSalesItem: selectedSalesItem,
                  );
                }
              },
              widget: SizedBox(
                height: screenHeight(statefulContext) - 270,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 400,
                              maxHeight: 40,
                            ),
                            child: GeneralTextfieldOnly(
                              autoFocus: true,
                              onChanged: (p0) {
                                setState(() {});
                              },
                              hint: 'Search Name',
                              controller: searchController,
                              lines: 1,
                              theme: theme,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 10,
                              ),
                          child: Builder(
                            builder: (context) {
                              List<TempProductClass>
                              salesProducts =
                                  returnData()
                                      .productList()
                                      .where(
                                        (item) => item.name
                                            .toLowerCase()
                                            .contains(
                                              searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .toList();

                              List<ProductionItem>
                              productionItems =
                                  returnProductionItemsProvider()
                                      .productionItemList()
                                      .where(
                                        (item) => item.name
                                            .toLowerCase()
                                            .contains(
                                              searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .toList();

                              if (useProductionItems
                                  ? productionItems.isEmpty
                                  : salesProducts.isEmpty) {
                                return SizedBox(
                                  height: 400,
                                  child: EmptyWidgetDisplayOnly(
                                    title: 'No Item Found',
                                    subText:
                                        'No item was found.',
                                    theme: theme,
                                    height: 30,
                                    altAction: () async {
                                      useProductionItems
                                          ? await returnProductionItemsProvider()
                                              .getProductionItems()
                                          : await returnData()
                                              .getProducts(
                                                shopId(),
                                              );
                                      setState(() {});
                                    },
                                    altActionText:
                                        'Refresh',
                                    icon: Icons.clear,
                                  ),
                                );
                              } else {
                                return Column(
                                  spacing: 5,
                                  children:
                                      useProductionItems
                                          ? productionItems
                                              .map(
                                                (
                                                  item,
                                                ) => Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  child: InkWell(
                                                    mouseCursor:
                                                        SystemMouseCursors.click,
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedItem?.uuid ==
                                                            item.uuid) {
                                                          selectedItem =
                                                              null;
                                                        } else {
                                                          selectedItem =
                                                              item;
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        vertical:
                                                            9.0,
                                                        horizontal:
                                                            10,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            item.name,
                                                          ),
                                                          Row(
                                                            spacing:
                                                                15,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                '${formatLargeNumberDouble(item.getPrimaryUnit().getQuantityEquivDivided(index: 2, quantityTwo: item.quantity ?? 0))} ${cutLongText(item.getPrimaryUnit().name, 8)}',
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.all(
                                                                  2,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape.circle,
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors.grey,
                                                                  ),
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(
                                                                    5,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    shape:
                                                                        BoxShape.circle,
                                                                    color:
                                                                        selectedItem?.uuid ==
                                                                                item.uuid
                                                                            ? theme.lightModeColor.prColor250
                                                                            : Colors.transparent,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList()
                                          : salesProducts
                                              .map(
                                                (
                                                  item,
                                                ) => Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  child: InkWell(
                                                    mouseCursor:
                                                        SystemMouseCursors.click,
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedSalesItem?.uuid ==
                                                            item.uuid) {
                                                          selectedSalesItem =
                                                              null;
                                                        } else {
                                                          selectedSalesItem =
                                                              item;
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        vertical:
                                                            9.0,
                                                        horizontal:
                                                            10,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            item.name,
                                                          ),
                                                          Row(
                                                            spacing:
                                                                15,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                '${formatLargeNumberDouble(item.getPrimaryUnit().getQuantityEquivDivided(index: 1, quantityTwo: item.quantity ?? 0))} ${cutLongText(item.getPrimaryUnit().name, 8)}',
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.all(
                                                                  2,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape.circle,
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors.grey,
                                                                  ),
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(
                                                                    5,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    shape:
                                                                        BoxShape.circle,
                                                                    color:
                                                                        selectedSalesItem?.uuid ==
                                                                                item.uuid
                                                                            ? theme.lightModeColor.prColor250
                                                                            : Colors.transparent,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void addSelectedItemToCart({
    required BuildContext secondContext,
    ProductionsCartItem? editItem,
    ProductionItem? selectedItem,
    TempProductClass? selectedSalesItem,
  }) {
    var theme = returnTheme(secondContext, listen: false);
    bool useProductionitems =
        returnShopProvider()
            .userShop()
            ?.manageProductionItems ??
        false;

    showDialog(
      context: secondContext,
      builder: (thirdContext) {
        final productionItemUnits =
            returnProductionItemsProvider()
                .productionItemListMain
                .where(
                  (item) => item.uuid == editItem?.itemUuid,
                )
                .toList();
        final salesItemUnits =
            returnData().productListMain
                .where(
                  (item) =>
                      item.uuid == editItem?.salesItemUuid,
                )
                .toList();
        final sourceUnits =
            (editItem?.unitsList?.isNotEmpty == true
                ? editItem!.unitsList
                : null) ??
            (useProductionitems
                ? selectedItem?.getUnitsList() ??
                    (productionItemUnits.isEmpty
                        ? null
                        : productionItemUnits.first
                            .getUnitsList())
                : selectedSalesItem?.getUnitsList() ??
                    (salesItemUnits.isEmpty
                        ? null
                        : salesItemUnits.first
                            .getUnitsList())) ??
            [];
        final units =
            sourceUnits
                .map((unit) => unit.copyWith())
                .toList();
        String? selectedUnitUuid =
            editItem?.unitUuid ??
            legacyProductionUnitUuid(
              unitsList: units,
              useGroupQuantity: editItem?.useGroupQuantity,
              groupUnit: editItem?.groupUnit,
            );
        if (selectedUnitUuid == null) {
          final primaryUnits = units.where(
            (unit) => unit.isPrimary,
          );
          if (primaryUnits.isNotEmpty) {
            selectedUnitUuid = primaryUnits.first.uuid;
          }
        }
        ProductUnitsClass? currentUnit() {
          for (final unit in units) {
            if (unit.uuid == selectedUnitUuid) return unit;
          }
          return null;
        }

        final quantityController = TextEditingController();
        if (editItem != null) {
          quantityController.text =
              editItem.quantity.toString();
        }

        Future<void> onSubmit() async {
          if (quantityController.text.isNotEmpty &&
              quantityController.text != '0' &&
              selectedUnitUuid != null) {
            final selectedUnit = units.firstWhere(
              (unit) => unit.uuid == selectedUnitUuid,
            );
            final primaryUnits =
                units
                    .where((unit) => unit.isPrimary)
                    .toList();
            final primaryUnitName =
                primaryUnits.isEmpty
                    ? 'Unit(s)'
                    : primaryUnits.first.name;
            final quantity =
                double.tryParse(
                  quantityController.text.replaceAll(
                    ',',
                    '',
                  ),
                ) ??
                0;
            if (!selectedUnit.conversion.isFinite ||
                selectedUnit.conversion <= 0 ||
                !quantity.isFinite ||
                quantity <= 0) {
              return;
            }
            final originalCost =
                editItem?.originalCostPerItem ??
                (useProductionitems
                    ? selectedItem?.costPrice
                    : selectedSalesItem?.costPrice) ??
                0;
            var tempCartItem = ProductionsCartItem(
              originalUseGroupQuantity:
                  editItem?.originalUseGroupQuantity ??
                  (useProductionitems
                      ? selectedItem?.useGroupUnit
                      : selectedSalesItem?.useGroupUnit),
              originalCostPerItem:
                  editItem?.originalCostPerItem ??
                  (useProductionitems
                      ? selectedItem?.costPrice ?? 0
                      : selectedSalesItem?.costPrice ?? 0),
              setCustomPrice: false,
              customPrice: null,
              uuid: editItem?.uuid ?? uuidGen(),
              itemUuid:
                  useProductionitems
                      ? (editItem?.itemUuid ??
                          selectedItem?.uuid)
                      : null,
              salesItemUuid:
                  useProductionitems
                      ? null
                      : editItem?.salesItemUuid ??
                          selectedSalesItem?.uuid,
              name:
                  editItem?.name ??
                  (useProductionitems
                      ? selectedItem?.name
                      : selectedSalesItem?.name) ??
                  'Not Set',
              quantity: quantity,
              addToStock: false,
              useGroupQuantity: !selectedUnit.isPrimary,
              costPrice:
                  originalCost * quantity * selectedUnit.conversion,
              groupUnit:
                  selectedUnit.isPrimary
                      ? null
                      : selectedUnit.name,
              qttyPerGroup: selectedUnit.conversion,
              unit: primaryUnitName,
              unitUuid: selectedUnit.uuid,
              unitsList: units,
            );
            await returnProductionsActionProvider()
                .addItemToCart(item: tempCartItem);
            if (editItem == null) {
              Navigator.of(thirdContext).pop();
            }
            Navigator.of(secondContext).pop();
          }
        }

        return DialogTemplate(
          theme: theme,
          message:
              'You are about to Select this item for Production. Are you sure you want to proceed?',
          title: 'Set Item Quantity',
          action: () async {
            onSubmit();
          },
          widget: StatefulBuilder(
            builder:
                (context, setState2) => Column(
                  spacing: 15,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditCartTextField(
                      controller: quantityController,
                      autoFocus: true,
                      hint: 'Enter Quantity',
                      theme: theme,
                      title: 'Quantity',
                      showTitle: false,
                      onChanged: (p0) {
                        setState2(() {});
                      },
                      onSubmitted: (p0) {
                        onSubmit();
                      },
                    ),
                    UnitSelectionWidget(
                      product: null,
                      storageProduct: null,
                      productionItem: null,
                      material: null,
                      theme: theme,
                      unitUuid: selectedUnitUuid,
                      unitList: units,
                      setUnitUuid: (value) {
                        setState2(() {
                          selectedUnitUuid = value;
                        });
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          2,
                        ),
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
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
                                      FontWeight.normal,
                                ),
                                'Total Quantity:',
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
                                formatLargeNumberDouble(
                                  double.tryParse(
                                        quantityController
                                            .text
                                            .replaceAll(
                                              ',',
                                              '',
                                            ),
                                      ) ??
                                      0,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
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
                                      FontWeight.normal,
                                ),
                                'Total Cost Price:',
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
                                      (editItem
                                              ?.originalCostPerItem ??
                                          (useProductionitems
                                              ? selectedItem
                                                  ?.costPrice
                                              : selectedSalesItem
                                                  ?.costPrice) ??
                                          0) *
                                      (double.tryParse(
                                            quantityController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0) *
                                      (currentUnit()
                                              ?.conversion ??
                                          1),
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
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
                                      FontWeight.normal,
                                ),
                                'Unit:',
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
                                currentUnit()?.name ??
                                    'Unit(s)',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }

  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //

  void selectItemForProductionMaterials({
    required BuildContext firstContext,
  }) {
    var theme = returnTheme(firstContext, listen: false);
    final searchController = TextEditingController();
    MaterialClass? selectedMaterial;
    showDialog(
      context: firstContext,
      builder: (secondContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return DialogTemplate(
              theme: theme,
              message:
                  'Select a Material From the List Below',
              title: 'Select Material',
              action: () {
                if (selectedMaterial != null) {
                  addSelectedMaterialToCart(
                    secondContext: secondContext,
                    selectedMaterial: selectedMaterial,
                  );
                }
              },
              widget: SizedBox(
                height: screenHeight(statefulContext) - 270,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 400,
                              maxHeight: 40,
                            ),
                            child: GeneralTextfieldOnly(
                              autoFocus: true,
                              onChanged: (p0) {
                                setState(() {});
                              },
                              hint: 'Search Name',
                              controller: searchController,
                              lines: 1,
                              theme: theme,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 10,
                              ),
                          child: Builder(
                            builder: (context) {
                              if (returnMaterialsProvider()
                                  .materialList()
                                  .where(
                                    (item) => item.name
                                        .toLowerCase()
                                        .contains(
                                          searchController
                                              .text
                                              .toLowerCase(),
                                        ),
                                  )
                                  .isEmpty) {
                                return SizedBox(
                                  height: 400,
                                  child: EmptyWidgetDisplayOnly(
                                    title: 'No Item Found',
                                    subText:
                                        'No item was found.',
                                    theme: theme,
                                    height: 30,
                                    altAction: () async {
                                      await returnMaterialsProvider()
                                          .getMaterials();
                                      setState(() {});
                                    },
                                    altActionText:
                                        'Refresh',
                                    icon: Icons.clear,
                                  ),
                                );
                              } else {
                                return Column(
                                  spacing: 5,
                                  children:
                                      returnMaterialsProvider()
                                          .materialList()
                                          .where(
                                            (item) => item
                                                .name
                                                .toLowerCase()
                                                .contains(
                                                  searchController
                                                      .text
                                                      .toLowerCase(),
                                                ),
                                          )
                                          .map(
                                            (
                                              item,
                                            ) => Material(
                                              color:
                                                  Colors
                                                      .transparent,
                                              child: InkWell(
                                                mouseCursor:
                                                    SystemMouseCursors
                                                        .click,
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedMaterial?.uuid ==
                                                        item.uuid) {
                                                      selectedMaterial =
                                                          null;
                                                    } else {
                                                      selectedMaterial =
                                                          item;
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical:
                                                        9.0,
                                                    horizontal:
                                                        10,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        item.name,
                                                      ),
                                                      Row(
                                                        spacing:
                                                            15,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            '${item.quantity ?? 0}',
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.all(
                                                              2,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                5,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                                color:
                                                                    selectedMaterial?.uuid ==
                                                                            item.uuid
                                                                        ? theme.lightModeColor.prColor250
                                                                        : Colors.transparent,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void addSelectedMaterialToCart({
    required BuildContext secondContext,
    ProductionMaterialCartItem? editMaterialItem,
    MaterialClass? selectedMaterial,
  }) {
    var theme = returnTheme(secondContext, listen: false);

    showDialog(
      context: secondContext,
      builder: (thirdContext) {
        final existingMaterial =
            returnMaterialsProvider().materialListMain
                .where(
                  (item) =>
                      item.uuid ==
                      (editMaterialItem?.materialItemUuid ??
                          selectedMaterial?.uuid),
                )
                .toList();
        final units =
            ((editMaterialItem?.unitsList?.isNotEmpty ==
                            true
                        ? editMaterialItem!.unitsList
                        : null) ??
                    selectedMaterial?.getUnitsList() ??
                    (existingMaterial.isEmpty
                        ? null
                        : existingMaterial.first
                            .getUnitsList()) ??
                    [])
                .map((unit) => unit.copyWith())
                .toList();
        String? selectedUnitUuid =
            editMaterialItem?.unitUuid ??
            legacyProductionUnitUuid(
              unitsList: units,
              useGroupQuantity:
                  editMaterialItem?.useGroupQuantity,
              groupUnit: editMaterialItem?.groupUnit,
            );
        if (selectedUnitUuid == null && units.isNotEmpty) {
          final primaryUnits =
              units
                  .where((unit) => unit.isPrimary)
                  .toList();
          selectedUnitUuid =
              primaryUnits.isEmpty
                  ? units.first.uuid
                  : primaryUnits.first.uuid;
        }
        ProductUnitsClass? currentUnit() {
          for (final unit in units) {
            if (unit.uuid == selectedUnitUuid) return unit;
          }
          return null;
        }

        bool useGroupUnit =
            currentUnit()?.isPrimary == false;
        final quantityController = TextEditingController();
        if (editMaterialItem != null) {
          quantityController.text =
              editMaterialItem.quantity.toString();
        }

        bool hasEnoughManagedStock(double enteredQuantity) {
          final materialUuid =
              editMaterialItem?.materialItemUuid ??
              selectedMaterial?.uuid;
          final isManaged =
              editMaterialItem?.isManaged ??
              selectedMaterial?.isManaged ??
              false;
          if (!isManaged || materialUuid == null)
            return true;

          final materials = returnMaterialsProvider()
              .materialListMain
              .where((item) => item.uuid == materialUuid);
          if (materials.isEmpty) return false;

          final cartItems =
              returnProductionsActionProvider()
                  .getProductionsCart()
                  ?.getMaterialsCartItemsAll() ??
              [];
          final otherCartDemand = cartItems
              .where(
                (item) =>
                    item.materialItemUuid == materialUuid &&
                    item.uuid != editMaterialItem?.uuid &&
                    item.isManaged != false,
              )
              .fold<double>(
                0,
                (total, item) =>
                    total + item.getRealQuantity(),
              );
          final available =
              (materials.first.quantity ?? 0) -
              otherCartDemand +
              (editMaterialItem?.getRealQuantity() ?? 0);
          return enteredQuantity *
                  (currentUnit()?.conversion ?? 0) <=
              available;
        }

        void validateEnteredStock() {
          final enteredQuantity =
              double.tryParse(
                quantityController.text.replaceAll(',', ''),
              ) ??
              0;
          if (enteredQuantity > 0 &&
              !hasEnoughManagedStock(enteredQuantity)) {
            quantityController.text = '0';
          }
        }

        Future<void> onSubmit() async {
          if (quantityController.text.isNotEmpty &&
              quantityController.text != '0' &&
              currentUnit() != null) {
            final unit = currentUnit()!;
            final quantity =
                double.tryParse(
                  quantityController.text.replaceAll(
                    ',',
                    '',
                  ),
                ) ??
                0;
            if (!unit.conversion.isFinite ||
                unit.conversion <= 0 ||
                !quantity.isFinite ||
                quantity <= 0 ||
                !hasEnoughManagedStock(quantity)) {
              if (quantity > 0 &&
                  !hasEnoughManagedStock(quantity)) {
                quantityController.text = '0';
              }
              return;
            }
            final originalCost =
                editMaterialItem?.originalCostPerItem ??
                selectedMaterial?.costPrice ??
                0;
            final primaryUnits =
                units
                    .where((item) => item.isPrimary)
                    .toList();
            var tempCartItem = ProductionMaterialCartItem(
              isManaged:
                  editMaterialItem?.isManaged ??
                  selectedMaterial?.isManaged ??
                  false,
              productionItemName:
                  returnProductionsActionProvider()
                      .getProductionsCart()
                      ?.productionsCartItem
                      ?.name,
              productionItemId:
                  returnProductionsActionProvider()
                      .getProductionsCart()
                      ?.productionsCartItem
                      ?.uuid,
              originalUseGroupQuantity:
                  editMaterialItem
                      ?.originalUseGroupQuantity ??
                  selectedMaterial?.useGroupUnit,
              customUnit: null,
              originalCostPerItem:
                  editMaterialItem?.originalCostPerItem ??
                  selectedMaterial?.costPrice ??
                  0,
              setCustomPrice: false,
              customPrice: null,
              uuid: editMaterialItem?.uuid ?? uuidGen(),
              materialItemUuid:
                  editMaterialItem?.materialItemUuid ??
                  selectedMaterial?.uuid ??
                  'Not Set',
              name:
                  editMaterialItem?.name ??
                  selectedMaterial?.name ??
                  'Not Set',
              quantity: quantity,
              addToStock: false,
              useGroupQuantity: !unit.isPrimary,
              costPrice:
                  originalCost * quantity * unit.conversion,
              groupUnit: unit.isPrimary ? null : unit.name,
              qttyPerGroup: unit.conversion,
              unit:
                  primaryUnits.isEmpty
                      ? 'Unit(s)'
                      : primaryUnits.first.name,
              unitUuid: unit.uuid,
              unitsList: units,
            );
            await returnProductionsActionProvider()
                .addMaterialItemToCart(item: tempCartItem);
            if (editMaterialItem == null) {
              Navigator.of(thirdContext).pop();
            }
            Navigator.of(secondContext).pop();
          }
        }

        return DialogTemplate(
          theme: theme,
          message:
              'You are about to Select this item for Production. Are you sure you want to proceed?',
          title: 'Set Item Quantity',
          action: () async {
            onSubmit();
          },
          widget: StatefulBuilder(
            builder:
                (context, setState2) => Column(
                  spacing: 15,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditCartTextField(
                      controller: quantityController,
                      autoFocus: true,
                      hint: 'Enter Quantity',
                      theme: theme,
                      title: 'Quantity',
                      showTitle: false,
                      onChanged: (p0) {
                        validateEnteredStock();
                        setState2(() {});
                      },
                      onSubmitted: (p0) {
                        onSubmit();
                      },
                    ),
                    UnitSelectionWidget(
                      product: null,
                      storageProduct: null,
                      productionItem: null,
                      material: null,
                      theme: theme,
                      unitUuid: selectedUnitUuid,
                      unitList: units,
                      setUnitUuid: (value) {
                        setState2(() {
                          selectedUnitUuid = value;
                          useGroupUnit =
                              currentUnit()?.isPrimary ==
                              false;
                        });
                        validateEnteredStock();
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          2,
                        ),
                      ),
                      child: Column(
                        // spacing: 5,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
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
                                        FontWeight.normal,
                                  ),
                                  'Total Quantity:',
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
                                  formatLargeNumberDouble(
                                    double.tryParse(
                                          quantityController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
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
                                        FontWeight.normal,
                                  ),
                                  'Total Cost Price:',
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
                                        (editMaterialItem
                                                ?.originalCostPerItem ??
                                            selectedMaterial
                                                ?.costPrice ??
                                            0) *
                                        (double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ) ??
                                            0) *
                                        (currentUnit()
                                                ?.conversion ??
                                            1),
                                    context: context,
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
          ),
        );
      },
    );
  }

  void setCustomUnitForMaterial({
    required BuildContext context,
    required Function(String value) selectUnit,
    required Function() setUnitCustom,
    required TextEditingController unitController,
  }) {
    var theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (firstContextt) {
        bool isSearch = false;
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder:
              (context, setState) => DialogTemplate(
                theme: theme,
                message:
                    'Select A unit from the List To set Custom Unit',
                title: 'Select Custom Unit',
                action: () {},
                topLeftWidget: InkWell(
                  onTap: () {
                    setState(() {
                      isSearch = !isSearch;
                    });
                  },
                  mouseCursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      size: 20,
                      isSearch ? Icons.clear : Icons.search,
                    ),
                  ),
                ),
                topRightWidget: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (secondContext) {
                        return DialogTemplate(
                          theme: theme,
                          message:
                              'Enter Any Custom unit of your Choice.',
                          title: 'Enter Custom Unit',
                          action: setUnitCustom,
                          widget: Padding(
                            padding:
                                EdgeInsetsGeometry.symmetric(
                                  horizontal: 15,
                                ),
                            child: GeneralTextfieldOnly(
                              autoFocus: true,
                              hint: 'Enter Unit',
                              controller: unitController,
                              lines: 1,
                              theme: theme,
                              onSubmitted: (value) {
                                setUnitCustom();
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  mouseCursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 3,
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
                          'Add',
                        ),
                        Icon(size: 16, Icons.add),
                      ],
                    ),
                  ),
                ),
                showBottomActionButtons: false,
                widget: SizedBox(
                  height: screenHeight(context) - 250,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Visibility(
                          visible: isSearch,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 350,
                              maxHeight: 35,
                            ),
                            child: GeneralTextfieldOnly(
                              autoFocus: true,
                              hint: 'Search Unit',
                              controller: searchController,
                              lines: 1,
                              theme: theme,
                              onChanged: (p0) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children:
                                  returnData().units
                                      .where(
                                        (item) => item
                                            .toLowerCase()
                                            .contains(
                                              searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .map(
                                        (item) => Material(
                                          type:
                                              MaterialType
                                                  .transparency,
                                          child: InkWell(
                                            onTap: () {
                                              selectUnit(
                                                item,
                                              );
                                            },
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.symmetric(
                                                    vertical:
                                                        4,
                                                  ),
                                              padding:
                                                  EdgeInsets.symmetric(
                                                    vertical:
                                                        10,
                                                    horizontal:
                                                        15,
                                                  ),
                                              decoration:
                                                  BoxDecoration(),
                                              child: Row(
                                                spacing: 5,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight: FontWeight(
                                                          600,
                                                        ),
                                                      ),
                                                      item,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }
}

double quantityConversion({
  required bool isGroup,
  required double quantity,
  required double? qttyPerItem,
}) {
  if (isGroup) {
    return quantity * (qttyPerItem ?? 1);
  } else {
    return quantity;
  }
}

double costPriceConversion({
  required double? originalCostPrice,
  required bool isGroup,
  required double quantity,
  required double? qttyPerItem,
}) {
  return (originalCostPrice ?? 0) *
      quantityConversion(
        isGroup: isGroup,
        quantity: quantity,
        qttyPerItem: qttyPerItem,
      );
}
