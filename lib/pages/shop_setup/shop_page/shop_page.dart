import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/shop_setup/shop_page/platforms/shop_page_desktop.dart';
import 'package:stockall/pages/shop_setup/shop_page/platforms/shop_page_mobile.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ShopPageMobile();
        } else {
          return ShopPageDesktop();
        }
      },
    );
  }
}
