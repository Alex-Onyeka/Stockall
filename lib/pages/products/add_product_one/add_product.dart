import 'package:flutter/material.dart';
import 'package:stockitt/pages/products/add_product_one/platforms/add_product_mobile.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController brandController =
      TextEditingController();
  TextEditingController categoryController =
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
    brandController.dispose();
    nameController.dispose();
    categoryController.dispose();
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
              discountController: discountController,
              sizeController: sizeController,
              quantityController: quantityController,
              categoryController: categoryController,
              costController: costController,
              sellingController: sellingController,
              brandController: brandController,
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
