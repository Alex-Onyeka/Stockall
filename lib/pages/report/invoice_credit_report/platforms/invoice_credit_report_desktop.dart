import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/invoice_report_table_page.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/invoice_summary_page.dart';
import 'package:stockall/pages/report/order_report/order_report_table/order_report_table_page.dart';
import 'package:stockall/pages/report/order_report/order_summary/order_summary_page.dart';

class InvoiceCreditReportDesktop extends StatelessWidget {
  const InvoiceCreditReportDesktop({super.key});

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
                  'View a breakdown of your invoice and credit reports',
              title: 'Invoice/Credit Report',
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
                                            const InvoiceReportTablePage(),
                                  ),
                                );
                              },
                              subText:
                                  'View a complete tabular report of all invoices, payments, balances, and profits',
                              title: 'Invoice Report Table',
                            ),
                          ),
                          Visibility(
                            visible:
                                !isStoreKeeper() &&
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .viewInvoiceSalesReport,
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
                                            const InvoiceSummaryPage(),
                                  ),
                                );
                              },
                              subText:
                                  'Aggregated overview of invoice sales, collections, balances, profits, and performance',
                              title:
                                  'Invoice Summary and Analysis',
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
                          // Visibility(
                          //   visible: !isStoreKeeper() &&
                          //       authorization(
                          //         authorized: Authorizations()
                          //             .viewInvoiceSalesReport,
                          //       ),
                          //   child: ReportListTile(
                          //     isActive: true,
                          //     theme: theme,
                          //     action: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               InvoiceSalesReport(),
                          //         ),
                          //       );
                          //     },
                          //     subText:
                          //         'View a breakdown of your Invoice Sales, revenue and Profit',
                          //     title: 'Invoice Sales Report',
                          //   ),
                          // ),
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
