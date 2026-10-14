import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/manage_item_wastage.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/quantity_type_selection_widget.dart';

class SelectProductQuantityTypeSection
    extends StatelessWidget {
  final int quantityType;
  final Function(int index) switchQuantityType;
  final TextEditingController widthController;
  final TextEditingController heightController;
  const SelectProductQuantityTypeSection({
    super.key,
    required this.quantityType,
    required this.switchQuantityType,
    required this.widthController,
    required this.heightController,
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
            margin: EdgeInsets.only(bottom: 10),
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
                        title: 'Max-Width *',
                        controller: widthController,
                      ),
                    ),
                    Expanded(
                      child: EditCartTextField(
                        theme: theme,
                        hint: 'Enter Max-Height',
                        title: 'Max-Height *',
                        controller: heightController,
                      ),
                    ),
                  ],
                ),
                ManageItemWastage(theme: theme),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
