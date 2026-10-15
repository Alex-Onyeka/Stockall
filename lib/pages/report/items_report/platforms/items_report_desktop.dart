import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/item_history_report/item_history_report_page.dart';
import 'package:stockall/pages/report/items_report_analysis/items_report_analysis_page.dart';
import 'package:stockall/pages/report/items_report_main/items_report_main_page.dart';

class ItemsReportDesktop extends StatelessWidget {
  const ItemsReportDesktop({super.key});

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
              subTitle:
                  'View your inventory items, summary, analysis and history',
              title: 'Items Report',
              theme: theme,
              bottomSpace: 40,
              topSpace: 30,
              isMain: true,
              iconSvg: reportIconSvg,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Reports List:',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .viewItemsReport,
                            ),
                            child: ReportListTile(
                              isActive: true,
                              theme: theme,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ItemsReportMainPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Search, filter and sort a detailed table of your inventory items',
                              title: 'Items Report Main',
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .viewItemsReport,
                            ),
                            child: ReportListTile(
                              isActive: true,
                              theme: theme,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ItemsReportAnalysisPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Aggregated stock position, inventory value, potential profit, and performance analysis',
                              title:
                                  'Items Report Analysis',
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .viewItemsReport,
                            ),
                            child: ReportListTile(
                              isActive: true,
                              theme: theme,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ItemHistoryReportPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Search, filter and sort a detailed table of your inventory history records',
                              title: 'Item History Report',
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
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
