import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/platforms/shop_dashboard_desktop.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/platforms/shop_dashboard_mobile.dart';

class ShopDashboard extends StatefulWidget {
  const ShopDashboard({super.key});

  @override
  State<ShopDashboard> createState() =>
      _ShopDashboardState();
}

class _ShopDashboardState extends State<ShopDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      returnShopDashboardProvider().clearDate();
      // if (returnShopDashboardProvider()
      //     .allReceipts
      //     .isEmpty) {
      //   await returnShopDashboardProvider().fetchAllData();
      // }
      await returnShopDashboardProvider().fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return ShopDashboardMobile();
        } else {
          return ShopDashboardDesktop();
        }
      },
    );
  }
}
