import 'package:flutter/material.dart';
import 'package:stockitt/pages/report/general_report/platforms/general_report_mobile.dart';

class GeneralReportPage extends StatelessWidget {
  const GeneralReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return GeneralReportMobile();
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
