import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';

class ProductDetailsPage extends StatelessWidget {
  final TempProductClass product;
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
    );
  }
}
