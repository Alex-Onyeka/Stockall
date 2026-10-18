import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/item_sales_report_main/platforms/item_sales_report_main_desktop.dart';
import 'package:stockall/pages/report/item_sales_report_main/platforms/item_sales_report_main_mobile.dart';

class ItemSalesReportMainPage extends StatelessWidget {
  const ItemSalesReportMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ItemSalesReportMainMobile();
        } else {
          return const ItemSalesReportMainDesktop();
        }
      },
    );
  }
}
