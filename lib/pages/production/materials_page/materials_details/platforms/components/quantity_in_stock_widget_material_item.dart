import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/update_material_item_quantity.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';

Widget quantityInStockWidgetMaterialItem({
  required BuildContext context,
  required MaterialClass material,
  required int shopI,
}) {
  var theme = returnTheme(context, listen: false);
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey.shade300),
      color: const Color.fromARGB(255, 255, 255, 255),
    ),
    child: Column(
      spacing: 5,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'Quantity Section'.toUpperCase(),
            ),
          ],
        ),
        UnitsGridSectionWidgetMaterialItem(material: material),
        Visibility(
          visible: material.canUpdateQuantity(),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  child: EditButton(
                    theme: theme,
                    action: () {
                      updateMaterialItemQuantity(context, material);
                    },
                    text: 'Edit Qtty',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class UnitsGridSectionWidgetMaterialItem extends StatefulWidget {
  final MaterialClass material;
  const UnitsGridSectionWidgetMaterialItem({super.key, required this.material});

  @override
  State<UnitsGridSectionWidgetMaterialItem> createState() =>
      _UnitsGridSectionWidgetMaterialItemState();
}

class _UnitsGridSectionWidgetMaterialItemState
    extends State<UnitsGridSectionWidgetMaterialItem> {
  int getNumberOfUnits() {
    return widget.material.getUnitsList().length;
  }

  int getFirstEndRand() {
    return widget.material.getUnitsList().length > 2 ? 2 : 1;
  }

  int getSecondEndRand() {
    return widget.material.getUnitsList().length > 4 ? 4 : 3;
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.material.getUnitsList();

    return Column(
      children: List.generate((units.length / 2).ceil(), (rowIndex) {
        final start = rowIndex * 2;
        final end = (start + 2).clamp(0, units.length);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            spacing: 5,
            children:
                units
                    .sublist(start, end)
                    .map(
                      (item) => Expanded(
                        child: QuantityWidgetMaterialItemDetails(unit: item),
                      ),
                    )
                    .toList(),
          ),
        );
      }),
    );
  }
}

class QuantityWidgetMaterialItemDetails extends StatelessWidget {
  final ProductUnitsClass unit;
  const QuantityWidgetMaterialItemDetails({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color:
                  unit.isPrimary
                      ? theme.lightModeColor.prColor300
                      : Colors.grey.shade300,
            ),
            color:
                unit.isPrimary
                    ? theme.lightModeColor.prColor300
                    : Colors.grey.shade100,
          ),
          child: Row(
            spacing: 5,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: unit.isPrimary ? Colors.grey.shade200 : null,
                ),
                "${unit.name}:",
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color: unit.isPrimary ? Colors.grey.shade200 : null,
                ),
                formatLargeNumberDouble(
                  unit.getQuantityEquivDivided(context: context, index: 3),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: unit.isPrimary,
          child: Align(
            alignment: AlignmentGeometry.xy(1, 1),
            child: Icon(size: 13, color: Colors.white, Icons.check),
          ),
        ),
      ],
    );
  }
}
