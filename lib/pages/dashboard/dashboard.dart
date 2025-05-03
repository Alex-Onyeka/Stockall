import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/pages/dashboard/platforms/dashboard_desktop.dart';
import 'package:stockitt/pages/dashboard/platforms/dashboard_mobile.dart';
import 'package:stockitt/pages/dashboard/platforms/dashboard_tablet.dart';
import 'package:stockitt/providers/nav_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    Provider.of<NavProvider>(
      context,
      listen: false,
    ).navigate(0);
  }

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
