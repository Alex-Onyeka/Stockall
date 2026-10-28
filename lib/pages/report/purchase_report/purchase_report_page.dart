import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/purchase_report/platforms/purchase_report_desktop.dart';
import 'package:stockall/pages/report/purchase_report/platforms/purchase_report_mobile.dart';

class PurchaseReportPage extends StatelessWidget {
  const PurchaseReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const PurchaseReportMobile();
        } else {
          return const PurchaseReportDesktop();
        }
      },
    );
  }
}
