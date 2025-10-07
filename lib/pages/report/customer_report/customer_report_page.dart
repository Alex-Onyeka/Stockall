import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/customer_report/platforms/customer_report_desktop.dart';
import 'package:stockall/pages/report/customer_report/platforms/customer_report_mobile.dart';

class CustomerReportPage extends StatelessWidget {
  const CustomerReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return CustomerReportMobile();
        } else {
          return CustomerReportDesktop();
        }
      },
    );
  }
}
