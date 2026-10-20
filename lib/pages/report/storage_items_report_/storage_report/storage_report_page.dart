import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report/platforms/items_report_mobile.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report/platforms/storage_report_desktop.dart';

class StorageReportPage extends StatelessWidget {
  const StorageReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const StorageReportMobile();
        } else {
          return const StorageReportDesktop();
        }
      },
    );
  }
}
