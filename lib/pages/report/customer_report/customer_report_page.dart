import 'package:flutter/material.dart';
import 'package:stockall/pages/report/customer_report/platforms/customer_report_mobile.dart';

class CustomerReportPage extends StatelessWidget {
  const CustomerReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return CustomerReportMobile();
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
