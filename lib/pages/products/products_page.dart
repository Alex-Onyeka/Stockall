import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/platforms/product_page_mobile.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool isEmpty = true;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: GestureDetector(
        onTap:
            () =>
                FocusManager.instance.primaryFocus
                    ?.unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 500) {
              return ProductPageMobile(
                theme: theme,
                isEmpty: isEmpty,
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 700,
                    child: ProductPageMobile(
                      theme: theme,
                      isEmpty: isEmpty,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
