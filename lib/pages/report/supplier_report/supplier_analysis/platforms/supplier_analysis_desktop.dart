import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/components/supplier_analysis_view.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';

class SupplierAnalysisDesktop extends StatelessWidget {
  final String supplierKey;
  final ReceiptsReportPeriod? initialPeriod;
  final SupplierReportEnv? env;

  const SupplierAnalysisDesktop({
    super.key,
    required this.supplierKey,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return SupplierAnalysisView(
      isDesktop: true,
      supplierKey: supplierKey,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
