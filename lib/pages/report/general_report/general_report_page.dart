import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/general_report/platforms/general_report_desktop.dart';
import 'package:stockall/pages/report/general_report/platforms/general_report_mobile.dart';

class GeneralReportPage extends StatelessWidget {
  const GeneralReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return GeneralReportMobile();
        } else {
          return GeneralReportDesktop();
        }
      },
    );
  }
}
