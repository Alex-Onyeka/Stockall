import 'package:flutter/material.dart';
import 'package:stockitt/pages/products/add_products_three/platforms/add_products_three_mobile.dart';

class AddProductsThree extends StatefulWidget {
  const AddProductsThree({super.key});

  @override
  State<AddProductsThree> createState() =>
      _AddProductsThreeState();
}

class _AddProductsThreeState
    extends State<AddProductsThree> {
  TextEditingController sizeController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return AddProductsThreeMobile(
              sizeController: sizeController,
              quantityController: quantityController,
            );
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}
