import 'package:flutter/material.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/item_sales_report_main_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/receipts_report_main_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/receipts_report_summary_page.dart';

class SalesReportMobile extends StatelessWidget {
  const SalesReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            turnOnBackNavButton: true,
            subTitle:
                'View a breakdown of your sales reports',
            title: 'Sales Report',
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
                                        .viewReceiptSalesReport,
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
                                          const ReceiptsReportMainPage(),
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your Receipt Sales, revenue and Profit',
                            title: 'Receipts Report',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              authorization(
                                authorized:
                                    Authorizations()
                                        .viewReceiptSalesReport,
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
                                          const ReceiptsReportSummaryPage(),
                                ),
                              );
                            },
                            subText:
                                'Aggregated summary, sales channels, payment methods, and financial breakdown',
                            title: 'Receipt Report Summary',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              authorization(
                                authorized:
                                    Authorizations()
                                        .viewItemSalesReport,
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
                                          const ItemSalesReportMainPage(),
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your Item Sales, revenue and Profit',
                            title: 'Item Sales Report',
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
    );
  }
}
