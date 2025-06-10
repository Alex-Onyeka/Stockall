import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/dashboard.dart';
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
  bool _navigated = false;
  // bool _providersInitialized = false;

  @override
  void initState() {
    super.initState();
    shopFuture = getUserShop();
    // localUserFuture = getUserEmp();
  }

  // late Future<TempUserClass?> localUserFuture;
  // Future<TempUserClass?> getUserEmp() async {
  //   var emp =
  //       await returnLocalDatabase(
  //         context,
  //         listen: false,
  //       ).getUser();
  //   return emp;
  // }

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

    return FutureBuilder<TempShopClass?>(
      future: shopFuture,
      builder: (context, shopSnapshot) {
        if (shopSnapshot.connectionState ==
            ConnectionState.waiting) {
          return returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading');
          // return Scaffold(
          //   body: Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // );
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
                (route) => false,
              );
            }
          });
          return const Scaffold();
        } else {
          // return FutureBuilder<TempUserClass?>(
          //   future: localUserFuture,
          //   builder: (context, userSnapshot) {
          //     if (userSnapshot.connectionState ==
          //         ConnectionState.waiting) {
          //       return returnCompProvider(
          //         context,
          //         listen: false,
          //       ).showLoader('Loading');
          //       // return Scaffold(
          //       //   body: Center(
          //       //     child: CircularProgressIndicator(),
          //       //   ),
          //       // );
          //     } else if (userSnapshot.hasError) {
          //       return Scaffold(
          //         body: EmptyWidgetDisplay(
          //           title: 'An Error Occurred',
          //           subText:
          //               'We couldn\'t load your employee data.',
          //           icon: Icons.clear,
          //           theme: theme,
          //           height: 30,
          //           buttonText: 'Reload Page',
          //           action: () {
          //             Navigator.pushReplacement(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) {
          //                   return Home();
          //                 },
          //               ),
          //             );
          //           },
          //         ),
          //       );
          //     } else if (userSnapshot.data == null &&
          //         !_navigated) {
          //       // WidgetsBinding.instance
          //       //     .addPostFrameCallback((_) {
          //       //       if (mounted) {
          //       //         setState(() {
          //       //           _navigated = true;
          //       //         });
          //       //         Navigator.pushAndRemoveUntil(
          //       //           context,
          //       //           MaterialPageRoute(
          //       //             builder: (context) => EmpAuth(),
          //       //           ),
          //       //           (route) => false,
          //       //         );
          //       //       }
          //       //     });
          //       return EmpAuth();
          //     } else if (!_providersInitialized &&
          //         shopSnapshot.data != null &&
          //         userSnapshot.data != null) {
          //       // Only set providers once
          //       WidgetsBinding.instance
          //           .addPostFrameCallback((_) {
          //             if (mounted) {
          //               returnShopProvider(
          //                 context,
          //                 listen: false,
          //               ).setShop(shopSnapshot.data!);
          //               returnUserProvider(
          //                 context,
          //                 listen: false,
          //               ).fetchCurrentUser(context);
          //               _providersInitialized = true;
          //             }
          //           });
          //     }

          //     // Show the actual content
          //     switch (navProv.currentPage) {
          //       case 0:
          //         return Dashboard(
          //           shopId: shopSnapshot.data!.shopId!,
          //         );
          //       case 1:
          //         return const ProductsPage();
          //       case 2:
          //         return const SalesPage();
          //       default:
          //         return Dashboard(
          //           shopId: shopSnapshot.data!.shopId!,
          //         );
          //     }
          //   },
          // );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              returnShopProvider(
                context,
                listen: false,
              ).setShop(shopSnapshot.data!);
              returnUserProvider(
                context,
                listen: false,
              ).fetchCurrentUser(context);
              // _providersInitialized = true;
            }
          });

          // Show the actual content
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
    );
  }
}
