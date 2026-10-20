import 'package:flutter/material.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/components/storage_report_main_view.dart';

class StorageReportMainMobile extends StatelessWidget {
  final String? initialSearch;

  const StorageReportMainMobile({
    super.key,
    this.initialSearch,
  });

  @override
  Widget build(BuildContext context) {
    return StorageReportMainView(
      isDesktop: false,
      initialSearch: initialSearch,
    );
  }
}
