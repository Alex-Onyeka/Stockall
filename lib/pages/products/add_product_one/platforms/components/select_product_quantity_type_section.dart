import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/dimension_unit_dialog.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/manage_item_wastage.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/quantity_type_selection_widget.dart';

class SelectProductQuantityTypeSection
    extends StatelessWidget {
  final int quantityType;
  final Function(int index) switchQuantityType;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final bool showManageSalesWastage;
  const SelectProductQuantityTypeSection({
    super.key,
    required this.quantityType,
    required this.switchQuantityType,
    required this.widthController,
    required this.heightController,
    this.showManageSalesWastage = true,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: QuantityTypeSelectionWidget(
            theme: theme,
            selectedIndex: quantityType,
            setQuantityIndex: (index) {
              switchQuantityType(index ?? 1);
            },
          ),
        ),
        Visibility(
          visible: quantityType == 2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 15,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: EditCartTextField(
                        theme: theme,
                        hint: 'Enter Max-Width',
                        title: 'Max-Width (Optional)',
                        controller: widthController,
                      ),
                    ),
                    Expanded(
                      child: EditCartTextField(
                        theme: theme,
                        hint: 'Enter Max-Height',
                        title: 'Max-Height (Optional)',
                        controller: heightController,
                      ),
                    ),
                  ],
                ),
                MainDropdown(
                  theme: theme,
                  isOpen: false,
                  valueSet:
                      returnData(
                        context: context,
                      ).selectedDimensionUnit !=
                      null,
                  onTap: () {
                    FocusManager.instance.primaryFocus
                        ?.unfocus();
                    final data = returnData(
                      context: context,
                      listen: false,
                    );
                    final activeBaseUnit = data.useMultipleUnits
                        ? (data.tempUnitsList
                                .where((u) => (u.conversion - 1.0).abs() < 1e-6)
                                .firstOrNull
                                ?.name ??
                            data.tempUnitsList
                                .where((u) => u.isPrimary)
                                .firstOrNull
                                ?.name ??
                            data.selectedUnit)
                        : (data.singleUnitName() ?? data.selectedUnit);
                    final parsedMaxWidth = double.tryParse(
                      widthController.text.replaceAll(',', '').trim(),
                    );
                    final parsedMaxHeight = double.tryParse(
                      heightController.text.replaceAll(',', '').trim(),
                    );
                    showDimensionUnitAction(
                      context: context,
                      baseUnit: activeBaseUnit,
                      maxWidth: parsedMaxWidth,
                      maxHeight: parsedMaxHeight,
                      initialUnit: data.selectedDimensionUnit,
                      initialConversion: data.selectedDimensionConversion,
                      onSave: (unit, conversion) {
                        data.selectDimensionUnit(
                          unit,
                          conversion: conversion,
                        );
                      },
                      onClear: () {
                        data.clearDimensionUnit();
                      },
                    );
                  },
                  title: 'Dimension Unit (Optional)',
                  hint: () {
                    final unit =
                        returnData(
                          context: context,
                        ).selectedDimensionUnit;
                    final conv =
                        returnData(
                          context: context,
                        ).selectedDimensionConversion;
                    if (unit != null) {
                      if (conv != null && conv > 0) {
                        return '$unit (÷${formatLargeNumberDouble(conv)})';
                      }
                      return unit;
                    }
                    return 'Select Dimension Unit';
                  }(),
                ),
                if (showManageSalesWastage)
                  ManageItemWastage(theme: theme),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
