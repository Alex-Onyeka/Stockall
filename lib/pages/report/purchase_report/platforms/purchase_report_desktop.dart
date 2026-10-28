import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/purchase_report_table_page.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/purchase_summary_page.dart';

class PurchaseReportDesktop extends StatelessWidget {
  const PurchaseReportDesktop({super.key});

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
              subTitle: 'View a breakdown of your purchase reports',
              title: 'Purchase Report',
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
                            visible:
                                !isStoreKeeper() &&
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .managePurchases,
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
                                            const PurchaseReportTablePage(),
                                  ),
                                );
                              },
                              subText:
                                  'View a complete tabular report of all purchases, payments and balances owed to suppliers',
                              title: 'Purchase Report Table',
                            ),
                          ),
                          Visibility(
                            visible:
                                !isStoreKeeper() &&
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .managePurchases,
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
                                            const PurchaseSummaryPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Aggregated overview of purchase spend, payments, balances and supplier performance',
                              title:
                                  'Purchase Summary and Analysis',
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
