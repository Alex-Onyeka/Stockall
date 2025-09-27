import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/platforms/product_page_desktop.dart';
import 'package:stockall/pages/products/platforms/product_page_mobile.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnNavProvider(
        context,
        listen: false,
      ).validate(context);

      setState(() {
        // stillLoading = false;
      });
    });
  }

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
            returnNavProvider(
              context,
              listen: false,
            ).navigate(0);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < mobileScreen) {
                return ProductPageMobile(theme: theme);
              } else {
                return ProductPageDesktop(theme: theme);
              }
            },
          ),
        ),
      ),
    );
  }
}
