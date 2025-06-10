import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/main.dart';
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
      final provider = returnUserProvider(
        context,
        listen: false,
      );

      // final localProvider = returnLocalDatabase(
      //   context,
      //   listen: false,
      // );

      await provider.fetchCurrentUser(context);

      setState(() {});
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
              if (constraints.maxWidth < 550) {
                return ProductPageMobile(theme: theme);
              } else {
                return UnsupportedPlatform();
                // return Row(
                //   mainAxisAlignment:
                //       MainAxisAlignment.center,
                //   children: [
                //     SizedBox(
                //       width: 700,
                //       child: ProductPageMobile(
                //         theme: theme,
                //       ),
                //     ),
                //   ],
                // );
              }
            },
          ),
        ),
      ),
    );
  }
}
