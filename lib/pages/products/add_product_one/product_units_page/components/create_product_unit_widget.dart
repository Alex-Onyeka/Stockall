import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/components/unit_type_selection_widget.dart';

class CreateProductUnitWidget extends StatefulWidget {
  final TextEditingController quantityController;
  final TextEditingController nameController;
  final String productUuid;
  final bool isDimensional;
  final Function() setStateAction;
  const CreateProductUnitWidget({
    super.key,
    required this.productUuid,
    this.isDimensional = false,
    required this.quantityController,
    required this.nameController,
    required this.setStateAction,
  });

  @override
  State<CreateProductUnitWidget> createState() =>
      _CreateProductUnitWidgetState();
}

class _CreateProductUnitWidgetState
    extends State<CreateProductUnitWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          addProductUnitAction(
            context: context,
            nameController: widget.nameController,
            productUuid: widget.productUuid,
            isDimensional: widget.isDimensional,
            quantityController: widget.quantityController,
            setStateAction: widget.setStateAction,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 15,
          ),
          child: Row(
            spacing: 5,
            children: [
              Text(
                style: theme.mobileTexts.b3.textStyleBold,
                "Add Unit",
              ),
              Icon(color: Colors.grey, size: 20, Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}

void addProductUnitAction({
  required BuildContext context,
  required TextEditingController quantityController,
  required TextEditingController nameController,
  required String productUuid,
  bool isDimensional = false,
  ProductUnitsClass? unit,
  required Function() setStateAction,
}) {
  var theme = returnTheme(context, listen: false);
  if (unit != null) {
    quantityController.text = unit.conversion.toString();
    nameController.text = unit.name;
  }
  var dimensionType =
      unit?.dimensionType ?? ProductUnitsClass.sheetUnit;

  void addAction() {
    final conversion = double.tryParse(
      quantityController.text.replaceAll(',', '').trim(),
    );
    if (nameController.text.trim().isEmpty ||
        conversion == null ||
        !conversion.isFinite ||
        conversion <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: theme,
            message:
                'Enter a unit name and a positive conversion.',
            title: 'Invalid Unit Details',
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (mainDialog) {
          return ConfirmationAlert(
            theme: theme,
            message: 'Are you sure you want to proceed?',
            title: 'Proceed with action?',
            action: () async {
              Navigator.of(mainDialog).pop();
              unit?.name = nameController.text.trim();
              unit?.conversion = conversion;
              if (unit != null) {
                unit.dimensionType =
                    isDimensional ? dimensionType : null;
              }
              var unitListSingle = ProductUnitsClass(
                uuid: uuidGen(),
                staffUuid: currentUser().userId!,
                createdAt: DateTime.now(),
                staffName: currentUser().name,
                conversion: conversion,
                name: nameController.text.trim(),
                isPrimary:
                    returnData().tempUnitsList.isEmpty
                        ? true
                        : false,
                productUuid: productUuid,
                dimensionType:
                    isDimensional ? dimensionType : null,
              );
              returnData().createOrUpdateUnitList(
                unitListSingle: unit ?? unitListSingle,
              );
              Navigator.of(mainDialog).pop();
            },
          );
        },
      );
    }
  }

  String? tempUnit;

  void setTempUnit() {
    tempUnit = returnData().selectedUnit ?? unit?.name;
    nameController.text = tempUnit ?? unit?.name ?? '';
  }

  ItemsAuthAction().applyVariationsAction(
    context: context,
    action: () {
      showDialog(
        context: context,
        builder: (confirmDialog) {
          return StatefulBuilder(
            builder: (context, setState) {
              return DialogTemplate(
                theme: theme,
                message: 'Enter Product Unit Name',
                title:
                    '${unit == null ? 'Create' : 'Update'} Product Unit',
                action: () async {
                  addAction();
                },
                widget: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Container(
                    color: const Color.fromARGB(
                      47,
                      255,
                      255,
                      255,
                    ),
                    // height: 150,
                    // width: 500,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            if (isDimensional) ...[
                              UnitTypeSelectionWidget(
                                theme: theme,
                                currentSelection:
                                    dimensionType,
                                setUnitType: (index) {
                                  {
                                    setState(() {
                                      dimensionType =
                                          (index ?? 1);
                                    });
                                  }
                                },
                              ),
                            ],
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              spacing: 5,
                              children: [
                                Expanded(
                                  child: GeneralTextField(
                                    title:
                                        'Product Unit Name *',
                                    hint: 'Enter Name',
                                    controller:
                                        nameController,
                                    lines: 1,
                                    theme: theme,
                                  ),
                                ),
                                Material(
                                  type:
                                      MaterialType
                                          .transparency,
                                  child: InkWell(
                                    onTap: () {
                                      unitsBottomSheet(
                                        context,
                                        () {
                                          setState(() {
                                            setTempUnit();
                                          });
                                        },
                                      );
                                    },
                                    borderRadius:
                                        BorderRadius.circular(
                                          5,
                                        ),
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(
                                            8,
                                            6,
                                            5,
                                            6,
                                          ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade400,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                      ),
                                      child: Row(
                                        spacing: 3,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Select',
                                          ),
                                          Icon(
                                            Icons
                                                .keyboard_arrow_down,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            EditCartTextField(
                              title:
                                  isDimensional &&
                                          dimensionType ==
                                              ProductUnitsClass
                                                  .areaUnit
                                      ? 'Area conversion *'
                                      : isDimensional
                                      ? 'Slabs / sheets per Unit *'
                                      : 'Conversion',
                              autoFocus: false,
                              hint: 'Enter Conversion',
                              controller:
                                  quantityController,
                              theme: theme,
                              onSubmitted: (p0) {
                                addAction();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ).then((_) {
        quantityController.clear();
        nameController.clear();
        returnData().clearUnit();
        setStateAction();
      });
    },
  );
}
