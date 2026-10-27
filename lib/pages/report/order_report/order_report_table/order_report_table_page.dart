import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/platforms/order_report_table_desktop.dart';
import 'package:stockall/pages/report/order_report/order_report_table/platforms/order_report_table_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class OrderReportTablePage extends StatelessWidget {
  final OrderReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const OrderReportTablePage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return OrderReportTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        } else {
          return OrderReportTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        }
      },
    );
  }
}
