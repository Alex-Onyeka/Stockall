import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/platforms/product_units_page_mobile.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/platforms/product_units_page_desktop.dart';

class ProductUnitsPage extends StatefulWidget {
  final String productUuid;
  const ProductUnitsPage({
    super.key,
    required this.productUuid,
  });

  @override
  State<ProductUnitsPage> createState() =>
      _ProductUnitsPageState();
}

class _ProductUnitsPageState
    extends State<ProductUnitsPage> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return ProductUnitsPageMobile(
            productUuid: widget.productUuid,
            nameController: nameController,
            quantityController: quantityController,
          );
        } else {
          return ProductUnitsPageDesktop(
            nameController: nameController,
            quantityController: quantityController,
            productUuid: widget.productUuid,
          );
        }
      },
    );
  }
}
