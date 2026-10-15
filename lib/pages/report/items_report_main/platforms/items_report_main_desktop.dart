import 'package:flutter/material.dart';
import 'package:stockall/pages/report/items_report_main/components/items_report_main_view.dart';

class ItemsReportMainDesktop extends StatelessWidget {
  const ItemsReportMainDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemsReportMainView(isDesktop: true);
  }
}
