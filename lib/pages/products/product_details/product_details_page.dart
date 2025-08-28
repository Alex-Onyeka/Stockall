import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_mobile.dart';

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
        if (constraints.maxWidth < mobileScreen) {
          return ProductDetailsMobile(
            theme: theme,
            productId: productId,
          );
        } else {
          return ProductDetailsDesktop(
            theme: theme,
            productId: productId,
          );
        }
      },
    );
  }
}
