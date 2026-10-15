import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/platforms/product_prices_page_desktop.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/platforms/product_prices_page_mobile.dart';

class ProductPricesPage extends StatefulWidget {
  final String productUuid;
  const ProductPricesPage({super.key, required this.productUuid});

  @override
  State<ProductPricesPage> createState() => _ProductPricesPageState();
}

class _ProductPricesPageState extends State<ProductPricesPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return ProductPricesPageMobile(
            productUuid: widget.productUuid,
            nameController: nameController,
            priceController: priceController,
          );
        } else {
          return ProductPricesPageDesktop(
            nameController: nameController,
            priceController: priceController,
            productUuid: widget.productUuid,
          );
        }
      },
    );
  }
}
