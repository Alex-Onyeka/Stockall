import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/platforms/storage_report_main_desktop.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/platforms/storage_report_main_mobile.dart';

class StorageReportMainPage extends StatelessWidget {
  final String? initialSearch;

  const StorageReportMainPage({
    super.key,
    this.initialSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return StorageReportMainMobile(
            initialSearch: initialSearch,
          );
        } else {
          return StorageReportMainDesktop(
            initialSearch: initialSearch,
          );
        }
      },
    );
  }
}

