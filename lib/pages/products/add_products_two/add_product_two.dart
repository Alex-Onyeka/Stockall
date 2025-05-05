import 'package:flutter/material.dart';
import 'package:stockitt/pages/products/add_products_two/platforms/add_products_two_mobile.dart';

class AddProductTwo extends StatefulWidget {
  const AddProductTwo({super.key});

  @override
  State<AddProductTwo> createState() =>
      _AddProductTwoState();
}

class _AddProductTwoState extends State<AddProductTwo> {
  TextEditingController categoryController =
      TextEditingController();
  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return AddProductsTwoMobile(
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
