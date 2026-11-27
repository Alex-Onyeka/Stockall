import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/total_products/total_products_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: GestureDetector(
        onTap:
            () =>
                FocusManager.instance.primaryFocus
                    ?.unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (returnData().isSelectProducts) {
              return;
            }
            returnNavProvider(
              context,
              listen: false,
            ).navigate(0);
          },
          child: TotalProductsPage(
            theme: theme,
            isMainTab: true,
          ),
        ),
      ),
    );
  }
}
