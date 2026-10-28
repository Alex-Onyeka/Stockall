import 'package:flutter/material.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/order_report/order_report_table/order_report_table_page.dart';
import 'package:stockall/pages/report/order_report/order_summary/order_summary_page.dart';

class OrderReportMobile extends StatelessWidget {
  const OrderReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            turnOnBackNavButton: true,
            subTitle:
                'View a breakdown of your order reports',
            title: 'Order Report',
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
                                        .viewInvoiceSalesReport,
                              ) &&
                              SalesAuthAction().manageOrdersAction(
                                context: context,
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
                                          const OrderReportTablePage(),
                                ),
                              );
                            },
                            subText:
                                'View a complete tabular report of all orders, deliveries, payments, balances, and profits',
                            title: 'Order Report Table',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              authorization(
                                authorized:
                                    Authorizations()
                                        .viewInvoiceSalesReport,
                              ) &&
                              SalesAuthAction().manageOrdersAction(
                                context: context,
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
                                          const OrderSummaryPage(),
                                ),
                              );
                            },
                            subText:
                                'Aggregated overview of order deliveries, undelivered value, payments, balances, and performance',
                            title:
                                'Order Summary and Analysis',
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
