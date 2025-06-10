import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/pages/dashboard/platforms/dashboard_mobile.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return DashboardMobile(shopId: widget.shopId);
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
