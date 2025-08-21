import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_desktop.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_mobile.dart';

class ShopSetupPage extends StatelessWidget {
  final TempShopClass? shop;
  const ShopSetupPage({super.key, this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return ShopSetupMobile(shop: shop);
          } else {
            return ShopSetupDesktop(shop: shop);
          }
        },
      ),
    );
  }
}
