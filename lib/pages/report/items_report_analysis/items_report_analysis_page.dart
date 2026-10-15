import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/items_report_analysis/platforms/items_report_analysis_desktop.dart';
import 'package:stockall/pages/report/items_report_analysis/platforms/items_report_analysis_mobile.dart';

class ItemsReportAnalysisPage extends StatelessWidget {
  const ItemsReportAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ItemsReportAnalysisMobile();
        } else {
          return const ItemsReportAnalysisDesktop();
        }
      },
    );
  }
}
