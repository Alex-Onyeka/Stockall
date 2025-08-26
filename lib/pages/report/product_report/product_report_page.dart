import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/product_report/platforms/product_report_desktop.dart';
import 'package:stockall/pages/report/product_report/platforms/product_report_mobile.dart';

class ProductReportPage extends StatelessWidget {
  const ProductReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ProductReportMobile();
        } else {
          return ProductReportDesktop();
        }
      },
    );
  }
}
