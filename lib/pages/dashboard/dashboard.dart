import 'package:flutter/material.dart';
import 'package:stockitt/pages/dashboard/platforms/dashboard_desktop.dart';
import 'package:stockitt/pages/dashboard/platforms/dashboard_mobile.dart';
import 'package:stockitt/pages/dashboard/platforms/dashboard_tablet.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

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
          if (constraints.maxWidth < 500) {
            return DashboardMobile();
          } else if (constraints.maxWidth > 500 &&
              constraints.maxWidth < 1000) {
            return DashboardTablet();
          } else {
            return DashboardDesktop();
          }
        },
      ),
    );
  }
}
