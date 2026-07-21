import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/customer_report/customer_report_page.dart';
import 'package:stockall/pages/report/error_log/error_log.dart';
import 'package:stockall/pages/report/events_log/events_log.dart';
import 'package:stockall/pages/report/invoice_sales_report/invoice_sales_report.dart';
import 'package:stockall/pages/report/item_sales/item_sales_report.dart';
import 'package:stockall/pages/report/product_report/product_report_page.dart';
import 'package:stockall/pages/report/receipt_sales_report/receipt_sales_report.dart';
import 'package:stockall/providers/theme_provider.dart';

class ReportMobile extends StatelessWidget {
  const ReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage your business from report',
            title: 'Reports',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            isMain: true,
            iconSvg: reportIconSvg,
          ),
          SizedBox(height: 20),
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
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Reports List:',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        // Visibility(
                        //   visible:
                        //       !isStoreKeeper() &&
                        //       authorization(
                        //         authorized:
                        //             Authorizations()
                        //                 .viewGeneralReport,
                        //       ),
                        //   child: ReportListTile(
                        //     isActive: true,
                        //     theme: theme,
                        //     action: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) {
                        //             return GeneralReportPage();
                        //           },
                        //         ),
                        //       );
                        //     },
                        //     subText:
                        //         'View a Summary of your business Report',
                        //     title: 'General Overview',
                        //   ),
                        // ),
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
                                  builder: (context) {
                                    return ReceiptSalesReport();
                                  },
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your Receipt Sales, revenue and Profit',
                            title: 'Receipt Sales Report',
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
                                  builder: (context) {
                                    return InvoiceSalesReport();
                                  },
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your Invoice Sales, revenue and Profit',
                            title: 'Invoice Sales Report',
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
                                  builder: (context) {
                                    return ItemSalesReport();
                                  },
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your Item Sales, revenue and Profit',
                            title: 'Item Sales Report',
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
                                  builder: (context) {
                                    return ProductReportPage();
                                  },
                                ),
                              );
                            },
                            subText:
                                'View a Summary of your Stock and Inventory',
                            title: 'Items Report',
                          ),
                        ),
                        Visibility(
                          visible: !isStoreKeeper(),
                          child: ReportListTile(
                            isActive: true,
                            theme: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CustomerReportPage();
                                  },
                                ),
                              );
                            },
                            subText:
                                'View a detailed summary of your customers purchases.',
                            title: 'Customer Report',
                          ),
                        ),
                        SubWrapper(
                          mainWidget: Visibility(
                            visible: !isStoreKeeper(),
                            child: ReportListTile(
                              isActive: true,
                              theme: theme,
                              action: () {
                                ReportAuthAction()
                                    .viewEventsLogAction(
                                      context: context,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return EventsLog();
                                            },
                                          ),
                                        );
                                      },
                                    );
                              },
                              subText:
                                  'View a List of all Event Logs',
                              title: 'Events Log',
                            ),
                          ),
                          isVisible:
                              !ReportAuthAction()
                                  .viewEventsLogAction(),
                        ),
                        Visibility(
                          visible: !isStoreKeeper(),
                          child: ReportListTile(
                            isActive: true,
                            theme: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ErrorLog();
                                  },
                                ),
                              );
                            },
                            subText:
                                'View a List of all Error Logs',
                            title: 'Error Log',
                          ),
                        ),
                        ReportListTile(
                          isActive: false,
                          theme: theme,
                          action: () {},
                          subText:
                              'View a break down of employee activities',
                          title:
                              'Employee Report (Coming Soon)',
                        ),
                        ReportListTile(
                          isActive: false,
                          theme: theme,
                          action: () {},
                          subText:
                              'View a detailed breakdown of your expenses.',
                          title:
                              'Expenses Report (Coming Soon)',
                        ),
                        SizedBox(height: 30),
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

class ReportListTile extends StatelessWidget {
  final ThemeProvider theme;
  final String title;
  final String subText;
  final Function() action;
  final bool isActive;

  const ReportListTile({
    super.key,
    required this.theme,
    required this.title,
    required this.subText,
    required this.action,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:
                  isActive
                      ? const Color.fromARGB(22, 0, 0, 0)
                      : Colors.transparent,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: action,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    spacing: 10,
                    children: [
                      SvgPicture.asset(receiptIconSvg),
                      Flexible(
                        child: Column(
                          spacing: 5,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              title,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                color: Colors.grey,
                                // fontWeight:
                                //     FontWeight.bold,
                              ),
                              subText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  color: Colors.grey.shade400,
                  size: 20,
                  Icons.arrow_forward_ios_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
