import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_and_revenue/platforms/sales_and_revenue_report_mobile.dart';

class SalesAndRevenueReport extends StatelessWidget {
  const SalesAndRevenueReport({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return SalesAndRevenueReportMobile();
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
