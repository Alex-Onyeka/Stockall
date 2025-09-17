import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/dashboard.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';
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
  bool _handledNoShop = false;

  TempUserClass? user;

  @override
  void initState() {
    super.initState();
    shopFuture = getUserShop();
    userFuture = getUser();
  }

  late Future<TempUserClass?> userFuture;
  Future<TempUserClass?> getUser() async {
    var user = await returnUserProvider(
      context,
      listen: false,
    ).fetchCurrentUser(context);
    return user;
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
    ).getUserShop(AuthService().currentUserId!);
    return shop;
  }

  @override
  Widget build(BuildContext context) {
    final navProv = Provider.of<NavProvider>(context);
    final theme = returnTheme(context);

    if (returnUserProvider(
              context,
              listen: false,
            ).currentUserMain ==
            null ||
        shop(context) == null) {
      return FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return returnCompProvider(
              context,
              listen: false,
            ).showLoader('Loading...');
          } else if (snapshot.hasError) {
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
          } else {
            if (snapshot.data != null &&
                snapshot.data!.pin == null) {
              return Edit(
                user: snapshot.data!,
                action: 'PIN',
                main: true,
              );
            } else if (snapshot.data == null) {
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
            } else {
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
                        ).showLoader('Loading...');
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
                      } else if (shopSnapshot.data ==
                          null) {
                        if (!_handledNoShop) {
                          _handledNoShop = true;
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) {
                                if (mounted) {
                                  _handleNoShop();
                                }
                              });
                        }
                        return ShopBannerScreen();
                      } else {
                        switch (navProv.currentPage) {
                          case 0:
                            return Dashboard(
                              shopId:
                                  shop(context)?.shopId!,
                            );
                          case 1:
                            return const ProductsPage();
                          case 2:
                            return const SalesPage();
                          default:
                            return Dashboard(
                              shopId:
                                  shop(context)?.shopId!,
                            );
                        }
                      }
                    },
                  ),
                  Visibility(
                    visible:
                        returnNavProvider(
                          context,
                        ).isNotVerified,
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
        },
      );
    } else {
      return Stack(
        children: [
          Scaffold(
            body: Builder(
              builder: (context) {
                switch (navProv.currentPage) {
                  case 0:
                    return Dashboard(
                      shopId: shop(context)?.shopId!,
                    );
                  case 1:
                    return const ProductsPage();
                  case 2:
                    return const SalesPage();
                  default:
                    return Dashboard(
                      shopId: shop(context)?.shopId!,
                    );
                }
              },
            ),
          ),
          Visibility(
            visible:
                returnNavProvider(context).isNotVerified,
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
}
