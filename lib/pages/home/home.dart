import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/dashboard/dashboard.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';
import 'package:stockall/pages/products/products_page.dart';
import 'package:stockall/pages/profile/edit/edit.dart';
import 'package:stockall/pages/sales/sales_page/sales_page.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // bool _handledNoShop = false;

  TempUserClass? user;

  late Future<TempUserClass?> userFuture;
  Future<TempUserClass?> getUser() async {
    var user = await returnUserProvider(
      context,
      listen: false,
    ).fetchCurrentUser(context);
    await mainLocalLog(user?.email);
    return user;
  }

  void _handleNoShop() {
    if (!context.mounted) return;
    returnNavProvider(context, listen: false).verify();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return BasePage();
        },
      ),
    );
  }

  late Future<TempShopClass?> shopFuture;
  Future<TempShopClass?> getUserShop() async {
    try {
      await mainLocalLog('About to get Stores');
      var shop = await returnShopProvider().getUserShops();
      await mainLocalLog('Stores Gotten: ${shop.length}');

      var mainShop = returnShopProvider().userShop();
      await mainLocalLog('Current Shop: ${mainShop?.name}');
      return mainShop;
    } catch (e) {
      await mainLocalLog(
        "Error With Shop: ${e.toString()}",
      );
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // getSubscription();
    userFuture = getUser();
    shopFuture = getUserShop();
    listPrinters();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (returnShopProvider()
              .userShop()
              ?.manageDepartments !=
          true) {
        returnDepartmentProvider().clearDepartments();
      }
    });
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
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState ==
              ConnectionState.waiting) {
            return returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Loading...');
          } else if (userSnapshot.hasError) {
            return Scaffold(
              body: Center(
                child: EmptyWidgetDisplay(
                  title: 'An Error Occurred',
                  subText:
                      'We couldn\'t load your User data. Please Check your internet.',
                  icon: Icons.clear,
                  theme: theme,
                  height: 30,
                  buttonText: 'Reload Page',
                  action: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return BasePage();
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            if (userSnapshot.data != null &&
                userSnapshot.data!.pin == null) {
              return Edit(
                user: userSnapshot.data!,
                action: 'PIN',
                main: true,
              );
            } else if (userSnapshot.data == null) {
              return Scaffold(
                body: Center(
                  child: EmptyWidgetDisplay(
                    title: 'An Error Occurred',
                    subText:
                        'We couldn\'t Find your User data. Check your internet.',
                    icon: Icons.clear,
                    theme: theme,
                    height: 30,
                    buttonText: 'Reload Page',
                    action: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return BasePage();
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
                        ).showLoader(message: 'Loading...');
                      } else if (shopSnapshot.hasError) {
                        return Scaffold(
                          body: Center(
                            child: EmptyWidgetDisplay(
                              title: 'An Error Occurred',
                              subText:
                                  'We couldn\'t load your Shop data. Check your internet.',
                              icon: Icons.clear,
                              theme: theme,
                              height: 30,
                              buttonText: 'Reload Page',
                              action: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BasePage();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } else if (returnShopProvider()
                              .userShop() ==
                          null) {
                        return ShopBannerScreen();
                      } else {
                        if (!returnNavProvider(
                          context,
                        ).isNotVerified) {
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
                        } else {
                          return EmpAuth(
                            action: () {
                              _handleNoShop();
                            },
                          );
                        }
                      }
                    },
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
                if (!returnNavProvider(
                  context,
                ).isNotVerified) {
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
                } else {
                  return EmpAuth(
                    action: () {
                      _handleNoShop();
                    },
                  );
                }
              },
            ),
          ),
        ],
      );
    }
  }
}
