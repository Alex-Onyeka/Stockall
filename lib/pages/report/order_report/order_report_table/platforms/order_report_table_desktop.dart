import 'package:flutter/material.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/components/order_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class OrderReportTableDesktop extends StatelessWidget {
  final OrderReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const OrderReportTableDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return OrderReportTableView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
    );
  }
}
