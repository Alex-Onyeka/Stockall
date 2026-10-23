import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/platforms/item_sales_report_main_desktop.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/platforms/item_sales_report_main_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ItemSalesReportMainPage extends StatelessWidget {
  final ItemSalesFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ItemSalesReportMainPage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ItemSalesReportMainMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        } else {
          return ItemSalesReportMainDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        }
      },
    );
  }
}
