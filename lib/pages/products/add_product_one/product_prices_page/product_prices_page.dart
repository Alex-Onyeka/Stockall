import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/platforms/product_prices_page_desktop.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/platforms/product_prices_page_mobile.dart';

class ProductPricesPage extends StatefulWidget {
  final String productUuid;
  final double? costPrice;
  const ProductPricesPage({
    super.key,
    required this.productUuid,
    this.costPrice,
  });

  @override
  State<ProductPricesPage> createState() =>
      _ProductPricesPageState();
}

class _ProductPricesPageState
    extends State<ProductPricesPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  double? _resolveCostPrice(BuildContext context) {
    if (widget.costPrice != null && widget.costPrice! > 0) {
      return widget.costPrice;
    }
    try {
      final matches = returnData(
        context: context,
        listen: false,
      ).productListMain.where(
        (p) => p.uuid == widget.productUuid,
      );
      if (matches.isNotEmpty &&
          matches.first.costPrice > 0) {
        return matches.first.costPrice;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCost = _resolveCostPrice(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return ProductPricesPageMobile(
            productUuid: widget.productUuid,
            nameController: nameController,
            priceController: priceController,
            costPrice: effectiveCost,
          );
        } else {
          return ProductPricesPageDesktop(
            nameController: nameController,
            priceController: priceController,
            productUuid: widget.productUuid,
            costPrice: effectiveCost,
          );
        }
      },
    );
  }
}
