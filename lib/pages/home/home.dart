import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/dashboard.dart';
import 'package:stockitt/pages/products/products_page.dart';
import 'package:stockitt/pages/sales/sales_page/sales_page.dart';
import 'package:stockitt/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockitt/providers/nav_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    setShop();
  }

  TempShopClass? myShop;

  Future<void> setShop() async {
    var tempShop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(userId());
    setState(() {
      myShop = tempShop;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProv = Provider.of<NavProvider>(context);

    // If userShop is null and we haven't navigated yet
    if (myShop == null && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShopBannerScreen(),
          ),
        );
      });
      // Return empty widget to avoid build errors
      return const SizedBox.shrink();
    }

    // If userShop is available, show proper page
    switch (navProv.currentPage) {
      case 0:
        return const Dashboard();
      case 1:
        return const ProductsPage();
      case 2:
        return const SalesPage();
      default:
        return const Dashboard();
    }
  }
}
