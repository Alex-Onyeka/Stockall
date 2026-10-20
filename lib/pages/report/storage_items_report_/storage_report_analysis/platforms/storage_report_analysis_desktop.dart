import 'package:flutter/material.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/components/storage_report_analysis_view.dart';

class StorageReportAnalysisDesktop extends StatelessWidget {
  const StorageReportAnalysisDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageReportAnalysisView(isDesktop: true);
  }
}
