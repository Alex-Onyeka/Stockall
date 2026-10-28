import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/order_report/platforms/order_report_desktop.dart';
import 'package:stockall/pages/report/order_report/platforms/order_report_mobile.dart';

class OrderReportPage extends StatelessWidget {
  const OrderReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const OrderReportMobile();
        } else {
          return const OrderReportDesktop();
        }
      },
    );
  }
}
