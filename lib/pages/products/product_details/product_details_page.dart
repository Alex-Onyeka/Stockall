import 'package:flutter/material.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/products/product_details/platforms/product_details_mobile.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return ProductDetailsMobile(
            theme: theme,
            productId: productId,
          );
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
