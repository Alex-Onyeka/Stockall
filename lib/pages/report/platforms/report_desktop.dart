import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/customer_report_table_page.dart';
import 'package:stockall/pages/report/error_log/error_log.dart';
import 'package:stockall/pages/report/events_log/events_log.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_page.dart';
import 'package:stockall/pages/report/general_report/general_report_page.dart';
import 'package:stockall/pages/report/invoice_credit_report/invoice_credit_report_page.dart';
import 'package:stockall/pages/report/items_report_/items_report/items_report_page.dart';
import 'package:stockall/pages/report/order_report/order_report_page.dart';
import 'package:stockall/pages/report/production_report/class/production_report_hub_logic.dart';
import 'package:stockall/pages/report/production_report/production_report_page.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_page.dart';
import 'package:stockall/pages/report/sales_report_/sales_report/sales_report_page.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/staff_report_table_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report/storage_report_page.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/supplier_report_table_page.dart';
import 'package:stockall/services/auth_service.dart';

class ReportDesktop extends StatefulWidget {
  const ReportDesktop({super.key});

  @override
  State<ReportDesktop> createState() =>
      _ReportDesktopState();
}

class _ReportDesktopState extends State<ReportDesktop> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerWidgetDesktopMain(
        action: () {
          var safeContext = context;
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message: 'You are about to Logout',
                title: 'Are you Sure?',
                action: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  if (safeContext.mounted) {
                    var res = await AuthService().signOut(
                      context: safeContext,
                      allowLogout: false,
                    );
                    if (res == 0 && safeContext.mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
              );
            },
          );
        },
        theme: theme,
        notifications:
            returnNotificationProvider(
                  context,
                ).notifications().isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications(),
        globalKey: _scaffoldKey,
      ),
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              MyDrawerWidget(
                globalKey: _scaffoldKey,
                action: () {
                  var safeContext = context;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            isLoading = true;
                          });
                          if (safeContext.mounted) {
                            var res = await AuthService()
                                .signOut(
                                  context: safeContext,
                                  allowLogout: false,
                                );
                            if (res == 0 &&
                                safeContext.mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                      );
                    },
                  );
                },
                theme: theme,
                notifications:
                    returnNotificationProvider(
                          context,
                        ).notifications().isEmpty
                        ? []
                        : returnNotificationProvider(
                          context,
                        ).notifications(),
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    body: Column(
                      children: [
                        TopBanner(
                          turnOnBackNavButton: false,
                          subTitle:
                              'Manage your business from report',
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
                            padding:
                                const EdgeInsets.symmetric(
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
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Reports List:',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Visibility(
                                        visible:
                                            !isStoreKeeper() &&
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .viewGeneralReport,
                                            ),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const GeneralReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'See revenue, costs and profit for any period',
                                          title:
                                              'General Report',
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
                                                    (
                                                      context,
                                                    ) =>
                                                        const ItemsReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View your stock summary, items main report, analysis and history',
                                          title:
                                              'Items Report',
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .viewStorageReport,
                                            ) &&
                                            shop(
                                                  context,
                                                )?.manageInventoryStorage ==
                                                true,
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const StorageReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View your Storage stock summary, items main report, analysis and history',
                                          title:
                                              'Storage Report',
                                        ),
                                      ),
                                      Visibility(
                                        visible: ProductionReportHub.tileVisible(
                                          manageProductions:
                                              shop(
                                                context,
                                              )?.manageProductions ==
                                              true,
                                          planAllowsProductions:
                                              GeneralSettingsAuthAction()
                                                  .manageProductions(
                                                    context: null,
                                                  ),
                                          canViewProductions: authorization(
                                            authorized:
                                                Authorizations()
                                                    .viewProductions,
                                          ),
                                        ),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const ProductionReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View your materials, material usage, produced items and production records',
                                          title:
                                              'Production Report',
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            !isStoreKeeper() &&
                                            (authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .viewReceiptSalesReport,
                                                ) ||
                                                authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .viewItemSalesReport,
                                                )),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const SalesReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a breakdown of your Receipt and Item Sales reports',
                                          title:
                                              'Sales Report',
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
                                                    (
                                                      context,
                                                    ) =>
                                                        const InvoiceCreditReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a breakdown of your invoice and credit reports',
                                          title:
                                              'Invoice/Credit Report',
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
                                            SalesAuthAction()
                                                .manageOrdersAction(
                                                  context:
                                                      context,
                                                ),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const OrderReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a breakdown of your order reports',
                                          title:
                                              'Order Report',
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
                                                    (
                                                      context,
                                                    ) =>
                                                        const PurchaseReportPage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a breakdown of your purchases, payments and balances owed to suppliers',
                                          title:
                                              'Purchase Report',
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
                                                    (
                                                      context,
                                                    ) =>
                                                        const SupplierReportTablePage(),
                                              ),
                                            );
                                          },
                                          subText:
                                              "View your suppliers, what you've bought from each, and what you still owe",
                                          title:
                                              'Supplier Report',
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            !isStoreKeeper(),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return const CustomerReportTablePage();
                                                },
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a detailed summary of your customers purchases.',
                                          title:
                                              'Customer Report',
                                        ),
                                      ),
                                      SubWrapper(
                                        mainWidget: Visibility(
                                          visible:
                                              !isStoreKeeper(),
                                          child: ReportListTile(
                                            isActive: true,
                                            theme: theme,
                                            action: () {
                                              ReportAuthAction().viewEventsLogAction(
                                                context:
                                                    context,
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
                                                'View A List of all events.',
                                            title:
                                                'Events Log',
                                          ),
                                        ),
                                        isVisible:
                                            !ReportAuthAction()
                                                .viewEventsLogAction(),
                                      ),
                                      Visibility(
                                        visible:
                                            !isStoreKeeper(),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return ErrorLog();
                                                },
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a List of all Error Logs',
                                          title:
                                              'Error Log',
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            !isStoreKeeper(),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return const StaffReportTablePage();
                                                },
                                              ),
                                            );
                                          },
                                          subText:
                                              'See what each staff member sold, bought and spent',
                                          title:
                                              'Staff Report',
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            !isStoreKeeper() &&
                                            ReportAuthAction()
                                                .viewExpensesReportAction(
                                                  context:
                                                      context,
                                                ),
                                        child: ReportListTile(
                                          isActive: true,
                                          theme: theme,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return const ExpensesReportPage();
                                                },
                                              ),
                                            );
                                          },
                                          subText:
                                              'View a detailed breakdown of your expenses.',
                                          title:
                                              'Expenses Report',
                                        ),
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
                  ),
                ),
              ),
              RightSideBar(theme: theme),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
      ),
    );
  }
}
