import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/sales_page/platforms/sales_page_mobile.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
  }

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
        clearDate();
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
    return PopScope(
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
            return SalesPageMobile();
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return UnsupportedPlatform();
            // return Scaffold();
          } else {
            return UnsupportedPlatform();
            // return Scaffold();
          }
        },
      ),
    );
  }
}
