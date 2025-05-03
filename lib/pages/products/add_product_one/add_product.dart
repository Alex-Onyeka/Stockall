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
  TextEditingController descController =
      TextEditingController();
  TextEditingController brandController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return AddProductMobile(
              brandController: brandController,
              descController: descController,
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
