import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/platforms/production_report_desktop.dart';
import 'package:stockall/pages/report/production_report/platforms/production_report_mobile.dart';

class ProductionReportPage extends StatelessWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const ProductionReportMobile();
        } else {
          return const ProductionReportDesktop();
        }
      },
    );
  }
}
