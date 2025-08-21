import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/platforms/dashboard_desktop.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.name,
      );
      print('$currentUpdate');
      if (returnShopProvider(
            context,
            listen: false,
          ).userShop!.updateNumber !=
          currentUpdate) {
        returnShopProvider(
          context,
          listen: false,
        ).toggleUpdated(false);
      } else {
        returnShopProvider(
          context,
          listen: false,
        ).toggleUpdated(true);
      }

      _handlePostFrameLogic();
    });
    setState(() {});
  }

  Future<void> _handlePostFrameLogic() async {
    final userProvider = returnUserProvider(
      context,
      listen: false,
    );
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );

    final userShop = await shopProvider.getUserShop(
      AuthService().currentUser!.id,
    );

    if (!mounted) return;

    if (userShop == null) {
      // Navigate and return immediately
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ShopBannerScreen(),
        ),
        (route) => false,
      );
      return; // 🔁 Make sure nothing else runs
    }

    clearDate(); // ✅ safe to run only if not navigating

    if (!mounted) return;

    await userProvider.fetchCurrentUser(context);
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
          } else {
            return DashboardDesktop(
              shopId: widget.shopId,
              // stillLoading: stillLoading,
            );
            // return DashboardDesktop();
          }
        },
      ),
    );
  }
}
