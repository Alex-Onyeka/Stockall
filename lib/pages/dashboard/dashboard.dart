import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/platforms/dashboard_mobile.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

class Dashboard extends StatefulWidget {
  final int? shopId;
  const Dashboard({super.key, required this.shopId});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<NavProvider>(
  //     context,
  //     listen: false,
  //   ).navigate(0);
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   offOverlays();
  // }

  // void offOverlays() {
  //   returnCompProvider(
  //     context,
  //     listen: false,
  //   ).turnOffLoader();
  // }

  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();

    returnData(context, listen: false).clearFields();
  }

  // bool stillLoading = true;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        final userShop = await returnShopProvider(
          context,
          listen: false,
        ).getUserShop(AuthService().currentUser!.id);
        if (context.mounted && userShop == null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ShopBannerScreen(),
            ),
            (route) => false,
          );
        } else {
          clearDate();

          if (context.mounted) {
            final provider = returnUserProvider(
              context,
              listen: false,
            );

            await provider.fetchCurrentUser(context);
          }
        }

        // setState(() {
        //   stillLoading = false;
        // });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return DashboardMobile(
              shopId: widget.shopId,
              // stillLoading: stillLoading,
            );
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return UnsupportedPlatform();
            // return DashboardTablet();
          } else {
            return UnsupportedPlatform();
            // return DashboardDesktop();
          }
        },
      ),
    );
  }
}
