import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/storage_item_history_report_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/storage_item_history_summary_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/storage_report_analysis_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/storage_report_main_page.dart';

class StorageReportDesktop extends StatelessWidget {
  const StorageReportDesktop({super.key});

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
                  'View your storage inventory items, summary, analysis and history',
              title: 'Storage Report',
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
                                      .viewStorageReport,
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
                                            const StorageReportMainPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Search, filter and sort a detailed table of your storage items',
                              title: 'Storage Report Main',
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .viewStorageReport,
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
                                            const StorageReportAnalysisPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Aggregated storage position, stock cost value, and movement performance',
                              title: 'Storage Report Analysis',
                            ),
                          ),
                          Visibility(
                            visible:
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .viewStorageReport,
                                ) &&
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .viewItemsHistory,
                                ) &&
                                ItemsAuthAction()
                                    .trackItemHistoryAction(
                                      context: null,
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
                                            const StorageItemHistoryReportPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Search, filter and sort a detailed table of your storage history records',
                              title: 'Storage Item History Table',
                            ),
                          ),
                          Visibility(
                            visible:
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .viewStorageReport,
                                ) &&
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .viewItemsHistory,
                                ) &&
                                ItemsAuthAction()
                                    .trackItemHistoryAction(
                                      context: null,
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
                                            const StorageItemHistorySummaryPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Aggregated view of storage transfers, returns and restocks over a selected period',
                              title: 'Storage Item History Summary',
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
