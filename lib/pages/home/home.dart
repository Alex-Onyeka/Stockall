import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/classes/user_and_shop_data.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/dashboard.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';
import 'package:stockall/pages/products/products_page.dart';
import 'package:stockall/pages/sales/sales_page/sales_page.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<TempShopClass?> shopFuture;
  bool _navigated = false;
  bool _providersInitialized = false;

  late Future<UserAndShopData> combinedFuture;

  @override
  void initState() {
    super.initState();
    combinedFuture = loadUserAndShop();
  }

  Future<UserAndShopData> loadUserAndShop() async {
    final shop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!.id);
    final user =
        await returnLocalDatabase(
          context,
          listen: false,
        ).getUser();
    return UserAndShopData(user: user, shop: shop);
  }

  @override
  Widget build(BuildContext context) {
    final navProv = Provider.of<NavProvider>(context);
    // final theme = returnTheme(context);

    return FutureBuilder<UserAndShopData>(
      future: combinedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('An Error Occured'),
              //  EmptyWidgetDisplayOnly(
              //   title: 'An Error Occurred',
              //   subText:
              //       'We couldn\'t load your data. Check your internet.',
              //   icon: Icons.clear,
              //   theme: theme,
              //   height: 30,
              // ),
            ),
          );
        }

        final user = snapshot.data!.user;
        final shop = snapshot.data!.shop;

        if (shop == null && !_navigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _navigated = true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopBannerScreen(),
                ),
                (route) => false,
              );
            }
          });
          return const Scaffold();
        }

        if (user == null && !_navigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _navigated = true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => EmpAuth(),
                ),
                (route) => false,
              );
            }
          });
          return const Scaffold();
        }

        if (!_providersInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              returnShopProvider(
                context,
                listen: false,
              ).setShop(shop!);
              returnUserProvider(
                context,
                listen: false,
              ).fetchCurrentUser();
              _providersInitialized = true;
            }
          });
        }

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
      },
    );
  }
}
