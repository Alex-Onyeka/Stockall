import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/sales_report/platforms/sales_report_desktop.dart';
import 'package:stockall/pages/report/sales_report_/sales_report/platforms/sales_report_mobile.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const SalesReportMobile();
        } else {
          return const SalesReportDesktop();
        }
      },
    );
  }
}
