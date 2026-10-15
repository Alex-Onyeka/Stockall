import 'package:flutter/material.dart';
import 'package:stockall/pages/report/items_report_main/components/items_report_main_view.dart';

class ItemsReportMainMobile extends StatelessWidget {
  const ItemsReportMainMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemsReportMainView(isDesktop: false);
  }
}
