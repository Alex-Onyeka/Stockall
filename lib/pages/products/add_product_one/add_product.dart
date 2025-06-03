import 'package:flutter/material.dart';
import 'package:storrec/classes/temp_product_class.dart';
import 'package:storrec/pages/products/add_product_one/platforms/add_product_mobile.dart';

class AddProduct extends StatefulWidget {
  final TempProductClass? product;
  const AddProduct({super.key, this.product});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController nameController =
      TextEditingController();

  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  TextEditingController sizeController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController discountController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    costController.dispose();
    sellingController.dispose();
    discountController.dispose();
    quantityController.dispose();
    sizeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return AddProductMobile(
              product: widget.product,
              discountController: discountController,
              sizeController: sizeController,
              quantityController: quantityController,
              costController: costController,
              sellingController: sellingController,
              nameController: nameController,
            );
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}
