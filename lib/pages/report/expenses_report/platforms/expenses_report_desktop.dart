import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/expenses_report/platforms/expenses_report_tiles.dart';

class ExpensesReportDesktop extends StatelessWidget {
  const ExpensesReportDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      width: 800,
      mainWidget: Scaffold(
        body: Column(
          children: [
            TopBanner(
              turnOnBackNavButton: true,
              subTitle: 'View a breakdown of your expenses',
              title: 'Expenses Report',
              theme: theme,
              bottomSpace: 40,
              topSpace: 30,
              isMain: true,
              iconSvg: reportIconSvg,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Reports List:',
                            style: TextStyle(
                              fontSize: theme.mobileTexts.b1.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...expensesReportTiles(context, theme),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
