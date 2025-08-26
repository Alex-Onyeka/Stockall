import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_and_revenue/platforms/sales_and_revenue_report_desktop.dart';
import 'package:stockall/pages/report/sales_and_revenue/platforms/sales_and_revenue_report_mobile.dart';

class SalesAndRevenueReport extends StatelessWidget {
  const SalesAndRevenueReport({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return SalesAndRevenueReportMobile();
        } else {
          return SalesAndRevenueReportDesktop();
        }
      },
    );
  }
}
