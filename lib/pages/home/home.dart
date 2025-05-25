import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/dashboard.dart';
import 'package:stockitt/pages/dashboard/employee_auth_page/emp_auth.dart';
import 'package:stockitt/pages/products/products_page.dart';
import 'package:stockitt/pages/sales/sales_page/sales_page.dart';
import 'package:stockitt/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockitt/providers/nav_provider.dart';
import 'package:stockitt/services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<TempShopClass?> shopFuture;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    shopFuture = getUserShop();
    localUserFuture = getUserEmp();
  }

  Future<TempUserClass?> getUserEmp() async {
    var emp =
        await returnLocalDatabase(
          context,
          listen: false,
        ).getUser();
    return emp;
  }

  late Future<TempUserClass?> localUserFuture;

  Future<TempShopClass?> getUserShop() async {
    var shop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!.id);
    return shop;
  }

  @override
  Widget build(BuildContext context) {
    final navProv = Provider.of<NavProvider>(context);
    final theme = returnTheme(context);

    return FutureBuilder<TempShopClass?>(
      future: shopFuture,
      builder: (context, shopSnapshot) {
        if (shopSnapshot.connectionState ==
            ConnectionState.waiting) {
          return returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading');
        } else if (shopSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: EmptyWidgetDisplayOnly(
                title: 'An Error Occurred',
                subText:
                    'We couldn\'t load your data. Check your internet.',
                icon: Icons.clear,
                theme: theme,
                height: 30,
              ),
            ),
          );
        } else if (shopSnapshot.data == null &&
            !_navigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _navigated = true;
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopBannerScreen(),
                ),
                (route) =>
                    false, // removes all previous routes
              );
            }
          });
          return const Scaffold();
        } else {
          // Shop exists, now check local user
          return FutureBuilder<TempUserClass?>(
            future: localUserFuture,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return returnCompProvider(
                  context,
                  listen: false,
                ).showLoader('Loading');
              } else if (userSnapshot.hasError) {
                return Scaffold(
                  body: EmptyWidgetDisplayOnly(
                    title: 'An Error Occurred',
                    subText:
                        'We couldn\'t load your employee data.',
                    icon: Icons.clear,
                    theme: theme,
                    height: 30,
                  ),
                );
              } else if (userSnapshot.data == null &&
                  !_navigated) {
                WidgetsBinding.instance.addPostFrameCallback((
                  _,
                ) {
                  if (mounted) {
                    setState(() {
                      _navigated = true;
                    });
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmpAuth(),
                      ),
                      (route) =>
                          false, // removes all previous routes
                    );
                  }
                });
                return const Scaffold();
              } else {
                // All good, set providers and show normal page
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                      if (mounted) {
                        returnShopProvider(
                          context,
                          listen: false,
                        ).setShop(shopSnapshot.data!);
                        returnUserProvider(
                          context,
                          listen: false,
                        ).fetchCurrentUser();
                      }
                    });

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
            },
          );
        }
      },
    );
  }
}
