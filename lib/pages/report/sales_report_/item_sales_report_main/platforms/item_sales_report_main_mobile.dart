import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/components/item_sales_report_main_view.dart';

class ItemSalesReportMainMobile extends StatelessWidget {
  const ItemSalesReportMainMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemSalesReportMainView(isDesktop: false);
  }
}
