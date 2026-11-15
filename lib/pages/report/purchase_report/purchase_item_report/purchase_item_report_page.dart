import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/components/purchase_item_report_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class PurchaseItemReportPage extends StatelessWidget {
  final PurchaseItemFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseItemReportPage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PurchaseItemReportView(
          isDesktop: constraints.maxWidth > mobileScreen,
          initialFilters: initialFilters,
          initialPeriod: initialPeriod,
          env: env,
        );
      },
    );
  }
}
