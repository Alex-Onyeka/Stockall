import 'package:flutter/material.dart';
import 'package:stockall/pages/shop_setup/banner_screen/platforms/shop_banner_screen_desktop.dart';
import 'package:stockall/pages/shop_setup/banner_screen/platforms/shop_banner_screen_mobile.dart';

class ShopBannerScreen extends StatefulWidget {
  const ShopBannerScreen({super.key});

  @override
  State<ShopBannerScreen> createState() =>
      _ShopBannerScreenState();
}

class _ShopBannerScreenState
    extends State<ShopBannerScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return ShopBannerScreenMobile();
        } else {
          return ShopBannerScreenDesktop();
        }
      },
    );
  }
}
