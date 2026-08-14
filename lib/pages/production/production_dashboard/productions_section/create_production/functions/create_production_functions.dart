import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/components/select_total_cost_widget.dart';

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

  void selectItemForProduction({
    required BuildContext firstContext,
  }) {
    var theme = returnTheme(firstContext, listen: false);
    final searchController = TextEditingController();
    ProductionItem? selectedItem;
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
                if (selectedItem != null) {
                  addSelectedItemToCart(
                    secondContext: secondContext,
                    selectedItem: selectedItem,
                  );
                }
              },
              widget: SizedBox(
                height: screenHeight(statefulContext) - 200,
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
                              if (returnProductionItemsProvider()
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
                                      await returnProductionItemsProvider()
                                          .getProductionItems();
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
                                      returnProductionItemsProvider()
                                          .productionItemList()
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
  }) {
    var theme = returnTheme(secondContext, listen: false);

    showDialog(
      context: secondContext,
      builder: (thirdContext) {
        bool useGroupUnit = false;
        final quantityController = TextEditingController();
        if (editItem != null) {
          quantityController.text =
              editItem.quantity.toString();
          useGroupUnit = editItem.useGroupQuantity ?? false;
        }

        Future<void> onSubmit() async {
          if (quantityController.text.isNotEmpty &&
              quantityController.text != '0') {
            var tempCartItem = ProductionsCartItem(
              originalUseGroupQuantity:
                  editItem?.originalUseGroupQuantity ??
                  selectedItem?.useGroupUnit,
              originalCostPerItem:
                  editItem?.originalCostPerItem ??
                  selectedItem?.costPrice ??
                  0,
              setCustomPrice: false,
              customPrice: null,
              uuid: editItem?.uuid ?? uuidGen(),
              itemUuid:
                  editItem?.itemUuid ?? selectedItem?.uuid,
              name:
                  editItem?.name ??
                  selectedItem?.name ??
                  'Not Set',
              quantity:
                  double.tryParse(
                    quantityController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ) ??
                  0,
              addToStock: false,
              useGroupQuantity: useGroupUnit,
              costPrice: costPriceConversion(
                originalCostPrice:
                    editItem?.originalCostPerItem ??
                    selectedItem?.costPrice,
                isGroup: useGroupUnit,
                quantity:
                    double.tryParse(
                      quantityController.text.replaceAll(
                        ',',
                        '',
                      ),
                    ) ??
                    0,
                qttyPerItem:
                    editItem?.getQttyPerGroup() ??
                    selectedItem?.qttyPerGroup,
              ),
              groupUnit:
                  editItem?.groupUnit ??
                  selectedItem?.groupUnit ??
                  'Group(s)',
              qttyPerGroup:
                  editItem?.qttyPerGroup ??
                  selectedItem?.qttyPerGroup ??
                  1,
              unit:
                  editItem?.unit ??
                  selectedItem?.unit ??
                  'Unit(s)',
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
                    Visibility(
                      visible:
                          (editItem
                                  ?.originalUseGroupQuantity ??
                              selectedItem?.useGroupUnit) ==
                          true,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 200,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 10.0,
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
                                      FontWeight.bold,
                                ),
                                'Add Group?',
                              ),
                              MyToggleButton(
                                theme: theme,
                                toggle: () {
                                  setState2(() {
                                    useGroupUnit =
                                        !useGroupUnit;
                                  });
                                },
                                boolValue: useGroupUnit,
                              ),
                            ],
                          ),
                        ),
                      ),
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
                                  amount: costPriceConversion(
                                    originalCostPrice:
                                        editItem
                                            ?.originalCostPerItem ??
                                        selectedItem
                                            ?.costPrice,
                                    isGroup: useGroupUnit,
                                    quantity:
                                        double.tryParse(
                                          quantityController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0,
                                    qttyPerItem:
                                        editItem
                                            ?.getQttyPerGroup() ??
                                        selectedItem
                                            ?.qttyPerGroup,
                                  ),
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
                                (editItem != null
                                    ? editItem
                                        .getUnitForSales(
                                          useGroup:
                                              useGroupUnit,
                                        )
                                    : selectedItem
                                            ?.getUnitForSales(
                                              useGroup:
                                                  useGroupUnit,
                                            ) ??
                                        'Unit(s)'),
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
                height: screenHeight(statefulContext) - 200,
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
        bool useGroupUnit = false;
        final quantityController = TextEditingController();
        final unitController = TextEditingController();
        String? customUnit;
        if (editMaterialItem != null) {
          quantityController.text =
              editMaterialItem.quantity.toString();
          useGroupUnit =
              editMaterialItem.useGroupQuantity ?? false;
          customUnit = editMaterialItem.customUnit;
        }

        Future<void> onSubmit() async {
          if (quantityController.text.isNotEmpty &&
              quantityController.text != '0') {
            var tempCartItem = ProductionMaterialCartItem(
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
              customUnit: customUnit,
              originalCostPerItem:
                  editMaterialItem?.originalCostPerItem ??
                  selectedMaterial?.costPrice ??
                  0,
              setCustomPrice: false,
              customPrice: null,
              uuid: uuidGen(),
              materialItemUuid:
                  editMaterialItem?.materialItemUuid ??
                  selectedMaterial?.uuid ??
                  'Not Set',
              name:
                  editMaterialItem?.name ??
                  selectedMaterial?.name ??
                  'Not Set',
              quantity:
                  double.tryParse(
                    quantityController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ) ??
                  0,
              addToStock: false,
              useGroupQuantity: useGroupUnit,
              costPrice: costPriceConversion(
                originalCostPrice:
                    editMaterialItem?.originalCostPerItem ??
                    selectedMaterial?.costPrice,
                isGroup: useGroupUnit,
                quantity:
                    double.tryParse(
                      quantityController.text.replaceAll(
                        ',',
                        '',
                      ),
                    ) ??
                    0,
                qttyPerItem:
                    editMaterialItem?.getQttyPerGroup() ??
                    selectedMaterial?.qttyPerGroup,
              ),
              groupUnit:
                  editMaterialItem?.groupUnit ??
                  selectedMaterial?.groupUnit ??
                  'Group(s)',
              qttyPerGroup:
                  editMaterialItem?.qttyPerGroup ??
                  selectedMaterial?.qttyPerGroup ??
                  0,
              unit:
                  editMaterialItem?.unit ??
                  selectedMaterial?.unit ??
                  'Unit(s)',
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
                        setState2(() {});
                      },
                      onSubmitted: (p0) {
                        onSubmit();
                      },
                    ),
                    Visibility(
                      visible:
                          ((editMaterialItem
                                      ?.originalUseGroupQuantity ??
                                  selectedMaterial
                                      ?.useGroupUnit) ==
                              true),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 200,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 10.0,
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
                                      FontWeight.bold,
                                ),
                                'Add Group?',
                              ),
                              MyToggleButton(
                                theme: theme,
                                toggle: () {
                                  setState2(() {
                                    useGroupUnit =
                                        !useGroupUnit;
                                    customUnit = null;
                                  });
                                },
                                boolValue: useGroupUnit,
                              ),
                            ],
                          ),
                        ),
                      ),
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
                                    amount: costPriceConversion(
                                      originalCostPrice:
                                          editMaterialItem
                                              ?.originalCostPerItem ??
                                          selectedMaterial
                                              ?.costPrice,
                                      isGroup: useGroupUnit,
                                      quantity:
                                          double.tryParse(
                                            quantityController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0,
                                      qttyPerItem:
                                          editMaterialItem
                                              ?.getQttyPerGroup() ??
                                          selectedMaterial
                                              ?.qttyPerGroup,
                                    ),
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
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
                              Material(
                                type:
                                    MaterialType
                                        .transparency,
                                child: InkWell(
                                  onTap: () {
                                    if (customUnit !=
                                        null) {
                                      setState2(() {
                                        customUnit = null;
                                      });
                                    } else {
                                      setCustomUnitForMaterial(
                                        context: context,
                                        selectUnit: (
                                          value,
                                        ) {
                                          setState2(() {
                                            customUnit =
                                                value;
                                            useGroupUnit =
                                                false;
                                          });
                                          Navigator.of(
                                            context,
                                          ).pop();
                                        },
                                        setUnitCustom: () {
                                          setState2(() {
                                            customUnit =
                                                unitController
                                                    .text;
                                            useGroupUnit =
                                                false;
                                          });
                                          unitController
                                              .clear();
                                          Navigator.of(
                                            context,
                                          ).pop();
                                          Navigator.of(
                                            secondContext,
                                          ).pop();
                                        },
                                        unitController:
                                            unitController,
                                      );
                                    }
                                  },
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                          8.0,
                                          5,
                                          2,
                                          5,
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
                                          customUnit ??
                                              (editMaterialItem !=
                                                      null
                                                  ? editMaterialItem.getUnitForSales(
                                                    useGroup:
                                                        useGroupUnit,
                                                  )
                                                  : selectedMaterial?.getUnitForSales(
                                                        useGroup:
                                                            useGroupUnit,
                                                      ) ??
                                                      'Unit(s)'),
                                        ),
                                        Icon(
                                          size: 16,
                                          customUnit != null
                                              ? Icons.clear
                                              : Icons.edit,
                                        ),
                                      ],
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
                  height: screenHeight(context) - 180,
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
