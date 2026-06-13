import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/services/auth_service.dart';

class ErrorLogDesktop extends StatefulWidget {
  const ErrorLogDesktop({super.key});

  @override
  State<ErrorLogDesktop> createState() =>
      _ErrorLogDesktopState();
}

class _ErrorLogDesktopState extends State<ErrorLogDesktop> {
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
      body: Row(
        spacing: 15,
        children: [
          Visibility(
            visible: screenWidth(context) > mobileScreen,
            child: MyDrawerWidget(
              globalKey: _scaffoldKey,
              action: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message: 'You are about to Logout',
                      title: 'Are you Sure?',
                      action: () async {
                        var res = await AuthService()
                            .signOut(
                              context: context,
                              allowLogout: false,
                            );
                        if (res == 1) {
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AuthScreensPage();
                                },
                              ),
                            );
                            returnNavProvider(
                              context,
                              listen: false,
                            ).navigate(0);
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
                  ).notifications(),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      39,
                      4,
                      1,
                      41,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Scaffold(
                    appBar: appBar(
                      context: context,
                      title: 'Error Logs',
                      widget: InkWell(
                        onTap: () async {
                          await returnErrorLogProvider()
                              .getErrorLogs();
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 10,
                              ),
                          child: Row(
                            spacing: 3,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(size: 16, Icons.refresh),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                ),
                                'Refresh',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 20,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  returnErrorLogProvider(
                                            context:
                                                context,
                                          ).dateSet !=
                                          null
                                      ? formatDateTime(
                                        returnErrorLogProvider(
                                              context:
                                                  context,
                                            ).dateSet ??
                                            DateTime.now(),
                                      )
                                      : returnErrorLogProvider(
                                            context:
                                                context,
                                          ).rangeStartDate !=
                                          null
                                      ? '${formatDateTime(returnErrorLogProvider(context: context).rangeStartDate ?? DateTime.now())} - ${formatDateTime(returnErrorLogProvider(context: context).rangeEndDate ?? DateTime.now())}'
                                      : 'All Logs',
                                ),
                                InkWell(
                                  onTap: () {
                                    returnErrorLogProvider()
                                                    .dateSet ==
                                                null &&
                                            returnErrorLogProvider()
                                                    .rangeStartDate ==
                                                null
                                        ? mainDatePicker(
                                          context: context,
                                          theme: theme,
                                          singleDate: (
                                            value,
                                          ) {
                                            returnErrorLogProvider()
                                                .setDate(
                                                  value!,
                                                );
                                          },
                                          rangeDate: (
                                            firstDate,
                                            lastDate,
                                          ) {
                                            returnErrorLogProvider()
                                                .setRange(
                                                  firstDate!,
                                                  lastDate ??
                                                      DateTime.now(),
                                                );
                                          },
                                        )
                                        : returnErrorLogProvider()
                                            .clearDate();
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          10.0,
                                        ),
                                    child: Row(
                                      spacing: 4,
                                      children: [
                                        Icon(
                                          size: 16,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .prColor300,
                                          returnErrorLogProvider(
                                                        context:
                                                            context,
                                                      ).dateSet ==
                                                      null &&
                                                  returnErrorLogProvider(
                                                        context:
                                                            context,
                                                      ).rangeStartDate ==
                                                      null
                                              ? Icons
                                                  .calendar_month
                                              : Icons.clear,
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                          ),
                                          returnErrorLogProvider(
                                                        context:
                                                            context,
                                                      ).dateSet ==
                                                      null &&
                                                  returnErrorLogProvider(
                                                        context:
                                                            context,
                                                      ).rangeStartDate ==
                                                      null
                                              ? 'Set Date'
                                              : 'Clear',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                            child: Builder(
                              builder: (context) {
                                if (returnErrorLogProvider(
                                  context: context,
                                ).returnLogs().isEmpty) {
                                  return Center(
                                    child: EmptyWidgetDisplayOnly(
                                      title:
                                          'No Error Log Found',
                                      subText:
                                          'No error has been performed for this date.',
                                      theme: theme,
                                      height: 30,
                                      icon: Icons.clear,
                                      altAction: () async {
                                        await returnErrorLogProvider()
                                            .getErrorLogs();
                                      },
                                      altActionText:
                                          'Refresh',
                                      altIcon:
                                          Icons.refresh,
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    itemCount:
                                        returnErrorLogProvider(
                                              context:
                                                  context,
                                            )
                                            .returnLogs()
                                            .length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      var log =
                                          returnErrorLogProvider(
                                            context:
                                                context,
                                          ).returnLogs()[index];
                                      return LogWidget(
                                        log: log,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isLoading,
                    child: returnCompProvider(
                      context,
                      listen: false,
                    ).showLoader(message: 'Loading'),
                  ),
                ],
              ),
            ),
          ),
          RightSideBar(theme: theme),
        ],
      ),
    );
  }
}

class LogWidget extends StatefulWidget {
  final TempErrorLogClass log;
  const LogWidget({super.key, required this.log});

  @override
  State<LogWidget> createState() => _LogWidgetState();
}

class _LogWidgetState extends State<LogWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: const Color.fromARGB(90, 244, 67, 54),
            width: 1.5,
          ),
          color: Colors.white,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  MyDivider(),
                  Expanded(
                    flex: 9,
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      widget.log.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Divider(
                color: Colors.grey.shade300,
                height: 20,
                thickness: 0.8,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Creator:',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          widget.log.staffName ?? '',
                        ),
                      ],
                    ),
                    MyDivider(),
                    Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Date:',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          formatDateTimeTime(
                            widget.log.createdAt ??
                                DateTime.now(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDivider extends StatelessWidget {
  const MyDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 1,
      color: const Color.fromARGB(66, 158, 158, 158),
    );
  }
}
