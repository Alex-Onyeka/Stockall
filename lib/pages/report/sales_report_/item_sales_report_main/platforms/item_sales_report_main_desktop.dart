import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/components/item_sales_report_main_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ItemSalesReportMainDesktop extends StatelessWidget {
  final ItemSalesFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ItemSalesReportMainDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return ItemSalesReportMainView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
    );
  }
}
