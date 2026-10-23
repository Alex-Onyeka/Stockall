import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/platforms/item_sales_analysis_desktop.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/platforms/item_sales_analysis_mobile.dart';

/// Opens on today's business day with no filters. Reached only
/// from its Sales Reports tile.
class ItemSalesAnalysisPage extends StatelessWidget {
  const ItemSalesAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ItemSalesAnalysisMobile();
        } else {
          return const ItemSalesAnalysisDesktop();
        }
      },
    );
  }
}
