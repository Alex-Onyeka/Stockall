import 'package:flutter/material.dart';
import 'package:stockall/pages/report/product_report/platforms/product_report_mobile.dart';

class ProductReportPage extends StatelessWidget {
  const ProductReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return ProductReportMobile();
        } else if (constraints.maxWidth >= 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
