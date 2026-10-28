import 'package:flutter/material.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/customer_report/customer_report_page.dart';
import 'package:stockall/pages/report/error_log/error_log.dart';
import 'package:stockall/pages/report/events_log/events_log.dart';
import 'package:stockall/pages/report/invoice_credit_report/invoice_credit_report_page.dart';
import 'package:stockall/pages/report/items_report_/items_report/items_report_page.dart';
import 'package:stockall/pages/report/order_report/order_report_page.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_page.dart';
import 'package:stockall/pages/report/sales_report_/sales_report/sales_report_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report/storage_report_page.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b1.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Reports List:',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Visibility(
                          visible: authorization(
                            authorized: Authorizations().viewItemsReport,
                          ),
                          child: ReportListTile(
                            isActive: true,
                            theme: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ItemsReportPage(),
                                ),
                              );
                            },
                            subText:
                                'View your stock summary, items main report, analysis and history',
                            title: 'Items Report',
                          ),
                        ),
                        Visibility(
                          visible:
                              authorization(
                                authorized: Authorizations().viewStorageReport,
                              ) &&
                              shop(context)?.manageInventoryStorage == true,
                          child: ReportListTile(
                            isActive: true,
                            theme: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const StorageReportPage(),
                                ),
                              );
                            },
                            subText:
                                'View your Storage stock summary, items main report, analysis and history',
                            title: 'Storage Report',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              (authorization(
                                    authorized:
                                        Authorizations().viewReceiptSalesReport,
                                  ) ||
                                  authorization(
                                    authorized:
                                        Authorizations().viewItemSalesReport,
                                  )),
                          child: ReportListTile(
                            isActive: true,
                            theme: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SalesReportPage(),
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your Receipt and Item Sales reports',
                            title: 'Sales Report',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              authorization(
                                authorized:
                                    Authorizations().viewInvoiceSalesReport,
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
                                          const InvoiceCreditReportPage(),
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your invoice and credit reports',
                            title: 'Invoice/Credit Report',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              authorization(
                                authorized:
                                    Authorizations().viewInvoiceSalesReport,
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
                                  builder: (context) => const OrderReportPage(),
                                ),
                              );
                            },
                            subText: 'View a breakdown of your order reports',
                            title: 'Order Report',
                          ),
                        ),
                        Visibility(
                          visible:
                              !isStoreKeeper() &&
                              authorization(
                                authorized: Authorizations().managePurchases,
                              ),
                          child: ReportListTile(
                            isActive: true,
                            theme: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const PurchaseReportPage(),
                                ),
                              );
                            },
                            subText:
                                'View a breakdown of your purchases, payments and balances owed to suppliers',
                            title: 'Purchase Report',
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
                                ReportAuthAction().viewEventsLogAction(
                                  context: context,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return EventsLog();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              subText: 'View a List of all Event Logs',
                              title: 'Events Log',
                            ),
                          ),
                          isVisible: !ReportAuthAction().viewEventsLogAction(),
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
                            subText: 'View a List of all Error Logs',
                            title: 'Error Log',
                          ),
                        ),
                        ReportListTile(
                          isActive: false,
                          theme: theme,
                          action: () {},
                          subText: 'View a break down of Staff activities',
                          title: 'Staff Report (Coming Soon)',
                        ),
                        ReportListTile(
                          isActive: false,
                          theme: theme,
                          action: () {},
                          subText:
                              'View a detailed breakdown of your expenses.',
                          title: 'Expenses Report (Coming Soon)',
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
