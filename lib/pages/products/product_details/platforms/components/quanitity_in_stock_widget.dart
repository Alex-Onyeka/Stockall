import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/update_item_quantity.dart';

Widget quantityInStockWidget(
  BuildContext context,
  TempProductClass product,
  int shopI,
) {
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
        UnitsGridSectionWidget(product: product),
        Visibility(
          visible: product.canUpdateQuantity(),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  child: EditButton(
                    theme: theme,
                    action: () {
                      updateItemQuantity(context, product);
                    },
                    text: 'Edit Unit Qtty',
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

class UnitsGridSectionWidget extends StatefulWidget {
  final TempProductClass product;
  const UnitsGridSectionWidget({
    super.key,
    required this.product,
  });

  @override
  State<UnitsGridSectionWidget> createState() =>
      _UnitsGridSectionWidgetState();
}

class _UnitsGridSectionWidgetState
    extends State<UnitsGridSectionWidget> {
  int getNumberOfUnits() {
    return widget.product.getUnitsList().length;
  }

  int getFirstEndRand() {
    return widget.product.getUnitsList().length > 2 ? 2 : 1;
  }

  int getSecondEndRand() {
    return widget.product.getUnitsList().length > 4 ? 4 : 3;
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.product.getUnitsList();

    return Column(
      children: List.generate((units.length / 2).ceil(), (
        rowIndex,
      ) {
        final start = rowIndex * 2;
        final end = (start + 2).clamp(0, units.length);

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 3.0,
          ),
          child: Row(
            spacing: 5,
            children:
                units
                    .sublist(start, end)
                    .map(
                      (item) => Expanded(
                        child: QuantityWidgetProductDetails(
                          unit: item,
                        ),
                      ),
                    )
                    .toList(),
          ),
        );
      }),
    );
  }
}

class QuantityWidgetProductDetails extends StatelessWidget {
  final ProductUnitsClass unit;
  const QuantityWidgetProductDetails({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 8,
          ),
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
                  color:
                      unit.isPrimary
                          ? Colors.grey.shade200
                          : null,
                ),
                "${unit.name}:",
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      unit.isPrimary
                          ? Colors.grey.shade200
                          : null,
                ),
                formatLargeNumberDouble(
                  unit.getQuantityEquivDivided(
                    context: context,
                    index: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: unit.isPrimary,
          child: Align(
            alignment: AlignmentGeometry.xy(1, 1),
            child: Icon(
              size: 13,
              color: Colors.white,
              Icons.check,
            ),
          ),
        ),
      ],
    );
  }
}
