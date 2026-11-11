import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/components/production_report_hub_view.dart';

class ProductionReportMobile extends StatelessWidget {
  const ProductionReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductionReportHubView(isDesktop: false);
  }
}
