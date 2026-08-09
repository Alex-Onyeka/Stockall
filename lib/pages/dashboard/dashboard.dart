import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/platforms/dashboard_desktop.dart';
import 'package:stockall/pages/dashboard/platforms/dashboard_mobile.dart';

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
    ).clearDate();

    returnData().clearFields();
  }

  // bool stillLoading = true;

  Future<void> _handlePostFrameLogic() async {
    await returnNavProvider(
      context,
      listen: false,
    ).validate(context);
    clearDate();
    if (!mounted) return;
  }

  Future<void> getMainReceipts() async {
    await returnReceiptProvider(
      context,
      listen: false,
    ).loadReceipts(
      returnShopProvider().userShop()!.shopId!,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await mainLocalLog(
        returnShopProvider().userShop()?.name,
      );
      _handlePostFrameLogic();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen + 50) {
            return DashboardMobile();
          } else {
            return DashboardDesktop();
          }
        },
      ),
    );
  }
}
