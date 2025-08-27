import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/customer_report/customer_report_page.dart';
import 'package:stockall/pages/report/general_report/general_report_page.dart';
import 'package:stockall/pages/report/product_report/product_report_page.dart';
import 'package:stockall/pages/report/sales_and_revenue/sales_and_revenue_report.dart';
import 'package:stockall/providers/theme_provider.dart';
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
                    await AuthService().signOut(
                      safeContext,
                    );
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
                ).notifications.isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications,
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
                            await AuthService().signOut(
                              safeContext,
                            );
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
                        ).notifications.isEmpty
                        ? []
                        : returnNotificationProvider(
                          context,
                        ).notifications,
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    body: Column(
                      children: [
                        TopBanner(
                          turnOn: false,
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
                                  SizedBox(height: 15),
                                  Column(
                                    spacing: 10,
                                    children: [
                                      ReportListTile(
                                        isActive: true,
                                        theme: theme,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return GeneralReportPage();
                                              },
                                            ),
                                          );
                                        },
                                        subText:
                                            'Veiw A Summary of your business Report',
                                        title:
                                            'General Overview',
                                      ),
                                      ReportListTile(
                                        isActive: true,
                                        theme: theme,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return SalesAndRevenueReport();
                                              },
                                            ),
                                          );
                                        },
                                        subText:
                                            'Veiw a breakdown of your Sales, revenue and Profit',
                                        title:
                                            'Sales and Revenue',
                                      ),
                                      ReportListTile(
                                        isActive: true,
                                        theme: theme,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ProductReportPage();
                                              },
                                            ),
                                          );
                                        },
                                        subText:
                                            'Veiw A Summary of your Stock and Inventory',
                                        title:
                                            'Items Report',
                                      ),
                                      ReportListTile(
                                        isActive: true,
                                        theme: theme,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return CustomerReportPage();
                                              },
                                            ),
                                          );
                                        },
                                        subText:
                                            'View a detailed summary your customers purchases.',
                                        title:
                                            'Customer Report',
                                      ),
                                      ReportListTile(
                                        isActive: false,
                                        theme: theme,
                                        action: () {},
                                        subText:
                                            'Veiw A break down of employee activities',
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
            ).showLoader('Logging Out...'),
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
    return Ink(
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
    );
  }
}
