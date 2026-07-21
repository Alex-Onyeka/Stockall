import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/item_sales/platforms/item_sales_report_desktop.dart';
import 'package:stockall/pages/report/item_sales/platforms/item_sales_report_mobile.dart';

class ItemSalesReport extends StatelessWidget {
  const ItemSalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ItemSalesReportMobile();
        } else {
          return ItemSalesReportDesktop();
        }
      },
    );
  }
}
