import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop_class.dart';
// import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/dashboard.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';
// import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';
import 'package:stockall/pages/products/products_page.dart';
import 'package:stockall/pages/profile/edit/edit.dart';
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
  // bool _navigated = false;
  // bool _providersInitialized = false;

  @override
  void initState() {
    super.initState();
    shopFuture = getUserShop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // returnCompProvider(
        //   context,
        //   listen: false,
        // ).setVisible();
        _safeHandlePostFrameLogic();
      }
    });

    // localUserFuture = getUserEmp();
  }

  Future<void> _safeHandlePostFrameLogic() async {
    if (!mounted) return;
    final userProvider = returnUserProvider(
      context,
      listen: false,
    );
    final user = await userProvider.fetchCurrentUser(
      context,
    );
    if (!mounted) return;

    if (user != null && user.pin == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (_) => Edit(
                user: user,
                action: 'PIN',
                main: true,
              ),
        ),
        (route) => false,
      );
    }
  }

  void _handleNoShop() {
    if (!mounted) return;
    returnNavProvider(context, listen: false).verify();
  }

  late Future<TempShopClass?> shopFuture;
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

    return Stack(
      children: [
        FutureBuilder<TempShopClass?>(
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
                  child: EmptyWidgetDisplay(
                    title: 'An Error Occurred',
                    subText:
                        'We couldn\'t load your data. Check your internet.',
                    icon: Icons.clear,
                    theme: theme,
                    height: 30,
                    buttonText: 'Reload Page',
                    action: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Home();
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (shopSnapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((
                _,
              ) async {
                if (mounted) {
                  _handleNoShop();
                }
              });
              return ShopBannerScreen();
            } else {
              switch (navProv.currentPage) {
                case 0:
                  return Dashboard(
                    shopId: shopSnapshot.data!.shopId!,
                  );
                case 1:
                  return const ProductsPage();
                case 2:
                  return const SalesPage();
                default:
                  return Dashboard(
                    shopId: shopSnapshot.data!.shopId!,
                  );
              }
            }
          },
        ),
        Visibility(
          visible: returnNavProvider(context).isNotVerified,
          child: EmpAuth(
            action: () {
              _handleNoShop();
            },
          ),
        ),
      ],
    );
  }
}
