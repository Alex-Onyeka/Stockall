import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/shop_setup_two_desktop.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/shop_setup_two_mobile.dart';

class ShopSetupTwo extends StatelessWidget {
  final TempShopClass? shop;
  const ShopSetupTwo({super.key, this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return ShopSetupTwoMobile(shop: shop);
          } else {
            return ShopSetupTwoDesktop(shop: shop);
          }
        },
      ),
    );
  }
}
