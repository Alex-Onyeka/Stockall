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
    ).clearReceiptDate();

    returnData().clearFields();
  }

  // bool stillLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(returnShopProvider().userShop()?.name);
      // print('$currentUpdate');
      // if (returnShopProvider(
      //       context,
      //       listen: false,
      //     ).userShop()?.updateNumber !=
      //     currentUpdate) {
      //   returnShopProvider(
      //     context,
      //     listen: false,
      //   ).toggleUpdated(false);
      // } else {
      //   returnShopProvider(
      //     context,
      //     listen: false,
      //   ).toggleUpdated(true);
      // }

      _handlePostFrameLogic();
    });
    setState(() {});
  }

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
      context,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
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
