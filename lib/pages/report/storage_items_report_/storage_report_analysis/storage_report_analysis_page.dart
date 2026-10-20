import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/platforms/storage_report_analysis_desktop.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/platforms/storage_report_analysis_mobile.dart';

class StorageReportAnalysisPage extends StatelessWidget {
  const StorageReportAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const StorageReportAnalysisMobile();
        } else {
          return const StorageReportAnalysisDesktop();
        }
      },
    );
  }
}
