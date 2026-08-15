import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';
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

class CreateMaterialsUsageFunctions {
  //
  //
  //
  void selectItemForMaterialsUsageCart({
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
    MaterialsUsageCartItem? editMaterialItem,
    MaterialClass? selectedMaterial,
  }) {
    var theme = returnTheme(secondContext, listen: false);

    showDialog(
      context: secondContext,
      builder: (thirdContext) {
        bool useGroupUnit = false;
        final quantityController = TextEditingController();
        final unitController = TextEditingController();
        final customCostController =
            TextEditingController();
        int currentSelection = 1;
        String? customUnit;
        if (editMaterialItem != null) {
          quantityController.text =
              editMaterialItem.quantity.toString();
          useGroupUnit =
              editMaterialItem.useGroupQuantity ?? false;
          customUnit = editMaterialItem.customUnit;
          customCostController.text =
              (editMaterialItem.customPrice)?.toString() ??
              '';
          currentSelection =
              editMaterialItem.selectedCostInt;
        }

        void checkIsManagedAndClearTextFieldAction(
          bool isTextFieldUse,
        ) {
          bool isManaged =
              (editMaterialItem?.isManaged ??
                  selectedMaterial?.isManaged ??
                  false);
          var materials = returnMaterialsProvider()
              .materialListMain
              .where(
                (item) =>
                    item.uuid ==
                    (editMaterialItem?.materialItemUuid ??
                        selectedMaterial?.uuid),
              );
          double quantity = 0;
          if (materials.isNotEmpty) {
            quantity = (materials.first.quantity ?? 0);
          }

          if (isManaged &&
              (quantityConversion(
                    isGroup:
                        isTextFieldUse
                            ? useGroupUnit
                            : !useGroupUnit,
                    quantity:
                        double.tryParse(
                          quantityController.text
                              .replaceAll(',', ''),
                        ) ??
                        0,
                    qttyPerItem:
                        editMaterialItem?.qttyPerGroup ??
                        selectedMaterial?.qttyPerGroup,
                  ) >
                  quantity)) {
            quantityController.text = '0';
          }
        }

        Future<void> onSubmit() async {
          if (quantityController.text.isNotEmpty &&
              quantityController.text != '0') {
            var tempCartItem = MaterialsUsageCartItem(
              isManaged:
                  editMaterialItem?.isManaged ??
                  selectedMaterial?.isManaged,
              productionItemName: null,
              productionItemId: null,
              originalUseGroupQuantity:
                  editMaterialItem
                      ?.originalUseGroupQuantity ??
                  selectedMaterial?.useGroupUnit,
              customUnit: customUnit,
              originalCostPerItem:
                  editMaterialItem?.originalCostPerItem ??
                  selectedMaterial?.costPrice ??
                  0,
              selectedCostInt: currentSelection,
              customPrice: double.tryParse(
                customCostController.text.replaceAll(
                  ',',
                  '',
                ),
              ),
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
                    currentSelection == 1
                        ? (editMaterialItem
                                ?.originalCostPerItem ??
                            selectedMaterial?.costPrice)
                        : double.tryParse(
                              customCostController.text
                                  .replaceAll(',', ''),
                            ) ??
                            0,
                isGroup:
                    currentSelection == 1
                        ? useGroupUnit
                        : false,
                quantity:
                    currentSelection == 1
                        ? double.tryParse(
                              quantityController.text
                                  .replaceAll(',', ''),
                            ) ??
                            0
                        : 1,
                qttyPerItem:
                    currentSelection == 1
                        ? (editMaterialItem
                                ?.getQttyPerGroup() ??
                            selectedMaterial?.qttyPerGroup)
                        : 1,
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
            await returnMaterialsUsageActionProvider()
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
                        checkIsManagedAndClearTextFieldAction(
                          true,
                        );

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
                                  checkIsManagedAndClearTextFieldAction(
                                    false,
                                  );

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
                    Column(
                      spacing: 5,
                      children: [
                        SelectTotalCostWidget(
                          title: 'Set Material Item Cost',
                          index: 1,
                          currentSelection:
                              currentSelection,
                          subText:
                              'Set The total Cost From The total Cost of the Materials Used',
                          action: () {
                            setState2(() {
                              currentSelection = 1;
                            });
                            customCostController.clear();
                          },
                        ),
                        SelectTotalCostWidget(
                          title: 'Set Custom Cost',
                          index: 2,
                          currentSelection:
                              currentSelection,
                          subText:
                              'Set a Custom Cost amount for this material Usage Record.',
                          action: () {
                            setState2(() {
                              currentSelection = 2;
                            });
                          },
                        ),
                        Visibility(
                          visible: currentSelection == 2,
                          child: Column(
                            children: [
                              SizedBox(height: 5),
                              MoneyTextfield(
                                autoFocus: true,
                                title: 'Enter Total',
                                hint: 'Enter Custom Total',
                                controller:
                                    customCostController,
                                theme: theme,
                                showTitle: false,
                                onChanged: (p0) {
                                  setState2(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                          currentSelection ==
                                                  1
                                              ? (editMaterialItem
                                                      ?.originalCostPerItem ??
                                                  selectedMaterial
                                                      ?.costPrice)
                                              : double.tryParse(
                                                    customCostController
                                                        .text
                                                        .replaceAll(
                                                          ',',
                                                          '',
                                                        ),
                                                  ) ??
                                                  0,
                                      isGroup:
                                          currentSelection ==
                                                  1
                                              ? useGroupUnit
                                              : false,
                                      quantity:
                                          currentSelection ==
                                                  1
                                              ? double.tryParse(
                                                    quantityController
                                                        .text
                                                        .replaceAll(
                                                          ',',
                                                          '',
                                                        ),
                                                  ) ??
                                                  0
                                              : 1,
                                      qttyPerItem:
                                          currentSelection ==
                                                  1
                                              ? (editMaterialItem
                                                      ?.getQttyPerGroup() ??
                                                  selectedMaterial
                                                      ?.qttyPerGroup)
                                              : 1,
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
