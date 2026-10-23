import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/components/item_sales_analysis_view.dart';

class ItemSalesAnalysisMobile extends StatelessWidget {
  const ItemSalesAnalysisMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemSalesAnalysisView(isDesktop: false);
  }
}
