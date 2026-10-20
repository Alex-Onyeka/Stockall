import 'package:flutter/material.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/components/storage_report_main_view.dart';

class StorageReportMainDesktop extends StatelessWidget {
  final String? initialSearch;

  const StorageReportMainDesktop({
    super.key,
    this.initialSearch,
  });

  @override
  Widget build(BuildContext context) {
    return StorageReportMainView(
      isDesktop: true,
      initialSearch: initialSearch,
    );
  }
}

