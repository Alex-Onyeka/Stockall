import 'package:flutter/material.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/components/items_report_main_view.dart';

class ItemsReportMainDesktop extends StatelessWidget {
  final String? initialCategoryKey;
  final String? initialDepartmentKey;
  final String? initialSearch;

  const ItemsReportMainDesktop({
    super.key,
    this.initialCategoryKey,
    this.initialDepartmentKey,
    this.initialSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ItemsReportMainView(
      isDesktop: true,
      initialCategoryKey: initialCategoryKey,
      initialDepartmentKey: initialDepartmentKey,
      initialSearch: initialSearch,
    );
  }
}
