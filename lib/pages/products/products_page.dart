import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/platforms/product_page_desktop.dart';
import 'package:stockall/pages/products/platforms/product_page_mobile.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

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
      final userShop = await returnShopProvider(
        context,
        listen: false,
      ).getUserShop(AuthService().currentUser!.id);
      if (context.mounted && userShop == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ShopBannerScreen(),
          ),
          (route) => false,
        );
      } else {
        if (context.mounted) {
          final provider = returnUserProvider(
            context,
            listen: false,
          );

          await provider.fetchCurrentUser(context);
        }
      }

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
              if (constraints.maxWidth < 550) {
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
