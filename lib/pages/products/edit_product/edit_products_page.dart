import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/pages/products/edit_product/platforms/edit_product_mobile.dart';

class EditProductsPage extends StatefulWidget {
  final TempProductClass product;
  const EditProductsPage({
    super.key,
    required this.product,
  });

  @override
  State<EditProductsPage> createState() =>
      _EditProductsPageState();
}

class _EditProductsPageState
    extends State<EditProductsPage> {
  TextEditingController categoryController =
      TextEditingController();
  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  TextEditingController nameController =
      TextEditingController();
  TextEditingController brandController =
      TextEditingController();
  TextEditingController sizeController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product.name;
    brandController.text = widget.product.brand ?? '';
    costController.text =
        widget.product.costPrice.toString();
    sellingController.text =
        widget.product.sellingPrice.toString();
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
            return EditProductMobile(
              product: widget.product,
              brandController: brandController,
              nameController: nameController,
              quantityController: quantityController,
              sizeController: sizeController,
              categoryController: categoryController,
              costController: costController,
              sellingController: sellingController,
            );
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}
