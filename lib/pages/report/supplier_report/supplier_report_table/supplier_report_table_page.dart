import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/platforms/supplier_report_table_desktop.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/platforms/supplier_report_table_mobile.dart';

/// Supplier Report: one row per supplier. [initialFilters] and
/// [initialPeriod] open it on a given set; without a period it
/// opens on all time (today without the View Date permission).
class SupplierReportTablePage extends StatelessWidget {
  final SupplierReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [SupplierReportEnv.live] is used.
  final SupplierReportEnv? env;

  const SupplierReportTablePage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return SupplierReportTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return SupplierReportTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
