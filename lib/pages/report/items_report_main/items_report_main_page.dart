import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/items_report_main/platforms/items_report_main_desktop.dart';
import 'package:stockall/pages/report/items_report_main/platforms/items_report_main_mobile.dart';

class ItemsReportMainPage extends StatelessWidget {
  final String? initialCategoryKey;
  final String? initialDepartmentKey;
  final String? initialSearch;

  const ItemsReportMainPage({
    super.key,
    this.initialCategoryKey,
    this.initialDepartmentKey,
    this.initialSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ItemsReportMainMobile(
            initialCategoryKey: initialCategoryKey,
            initialDepartmentKey: initialDepartmentKey,
            initialSearch: initialSearch,
          );
        } else {
          return ItemsReportMainDesktop(
            initialCategoryKey: initialCategoryKey,
            initialDepartmentKey: initialDepartmentKey,
            initialSearch: initialSearch,
          );
        }
      },
    );
  }
}
