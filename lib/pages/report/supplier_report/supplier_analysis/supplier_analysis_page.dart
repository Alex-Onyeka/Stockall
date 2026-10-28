import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/platforms/supplier_analysis_desktop.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/platforms/supplier_analysis_mobile.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';

/// Supplier Analysis: one supplier's purchases in a period.
/// [supplierKey] is the supplier's uuid. Without [initialPeriod]
/// it opens on all time (today without the View Date
/// permission).
class SupplierAnalysisPage extends StatelessWidget {
  final String supplierKey;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [SupplierReportEnv.live] is used.
  final SupplierReportEnv? env;

  const SupplierAnalysisPage({
    super.key,
    required this.supplierKey,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return SupplierAnalysisMobile(
            supplierKey: supplierKey,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return SupplierAnalysisDesktop(
            supplierKey: supplierKey,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
