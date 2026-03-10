import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';
// import 'package:path/path.dart';
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

class EventsLogDesktop extends StatefulWidget {
  const EventsLogDesktop({super.key});

  @override
  State<EventsLogDesktop> createState() =>
      _EventsLogDesktopState();
}

class _EventsLogDesktopState
    extends State<EventsLogDesktop> {
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
                      action: () {
                        AuthService().signOut(context);
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
                      },
                    );
                  },
                );
              },
              theme: theme,
              notifications:
                  returnNotificationProvider(
                    context,
                  ).notifications,
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
                      title: 'Event Logs',
                      widget: InkWell(
                        onTap: () async {
                          await returnEventsLogProvider()
                              .getEventLogs();
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
                                  returnEventsLogProvider(
                                            context:
                                                context,
                                          ).dateSet !=
                                          null
                                      ? formatDateTime(
                                        returnEventsLogProvider(
                                              context:
                                                  context,
                                            ).dateSet ??
                                            DateTime.now(),
                                      )
                                      : returnEventsLogProvider(
                                            context:
                                                context,
                                          ).rangeStartDate !=
                                          null
                                      ? '${formatDateTime(returnEventsLogProvider(context: context).rangeStartDate ?? DateTime.now())} - ${formatDateTime(returnEventsLogProvider(context: context).rangeEndDate ?? DateTime.now())}'
                                      : 'All Logs',
                                ),
                                InkWell(
                                  onTap: () {
                                    returnEventsLogProvider()
                                                    .dateSet ==
                                                null &&
                                            returnEventsLogProvider()
                                                    .rangeStartDate ==
                                                null
                                        ? mainDatePicker(
                                          context: context,
                                          theme: theme,
                                          singleDate: (
                                            value,
                                          ) {
                                            returnEventsLogProvider()
                                                .setDate(
                                                  value!,
                                                );
                                          },
                                          rangeDate: (
                                            firstDate,
                                            lastDate,
                                          ) {
                                            returnEventsLogProvider()
                                                .setRange(
                                                  firstDate!,
                                                  lastDate ??
                                                      DateTime.now(),
                                                );
                                          },
                                        )
                                        : returnEventsLogProvider()
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
                                          returnEventsLogProvider(
                                                        context:
                                                            context,
                                                      ).dateSet ==
                                                      null &&
                                                  returnEventsLogProvider(
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
                                          returnEventsLogProvider(
                                                        context:
                                                            context,
                                                      ).dateSet ==
                                                      null &&
                                                  returnEventsLogProvider(
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
                                if (returnEventsLogProvider(
                                  context: context,
                                ).returnLogs().isEmpty) {
                                  return Center(
                                    child: EmptyWidgetDisplayOnly(
                                      title:
                                          'No Event Log Found',
                                      subText:
                                          'No event has been performed for this date.',
                                      theme: theme,
                                      height: 30,
                                      icon: Icons.clear,
                                      altAction: () async {
                                        await returnEventsLogProvider()
                                            .getEventLogs();
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
                                        returnEventsLogProvider(
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
                                          returnEventsLogProvider(
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
  final TempEventLogClass log;
  const LogWidget({super.key, required this.log});

  @override
  State<LogWidget> createState() => _LogWidgetState();
}

class _LogWidgetState extends State<LogWidget> {
  int event() {
    if (widget.log.event == 'created') {
      return 1;
    } else if (widget.log.event == 'updated') {
      return 2;
    } else {
      return 3;
    }
  }

  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color:
                event() == 1
                    ? const Color.fromARGB(90, 76, 175, 79)
                    : event() == 2
                    ? const Color.fromARGB(90, 255, 193, 7)
                    : const Color.fromARGB(90, 244, 67, 54),
            width: 1.5,
          ),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
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
                        color:
                            event() == 1
                                ? const Color.fromARGB(
                                  255,
                                  72,
                                  204,
                                  76,
                                )
                                : event() == 2
                                ? Colors.amber
                                : Colors.red,
                      ),
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Event:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            widget.log.message ?? '',
                          ),
                        ],
                      ),
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 9,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Description:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            widget.log.title,
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity:
                          (widget.log.tableName !=
                                      'customers' &&
                                  widget.log.tableName !=
                                      'shops' &&
                                  widget.log.tableName !=
                                      'users')
                              ? 1
                              : 0,
                      child: MyDivider(),
                    ),
                    SizedBox(
                      width: 70,
                      child: Opacity(
                        opacity:
                            (widget.log.tableName !=
                                        'customers' &&
                                    widget.log.tableName !=
                                        'shops' &&
                                    widget.log.tableName !=
                                        'users')
                                ? 1
                                : 0,
                        child: Text(
                          style: TextStyle(
                            color:
                                widget.log.amount == null
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade800,
                            fontSize:
                                widget.log.amount == null
                                    ? theme
                                        .mobileTexts
                                        .b4
                                        .fontSize
                                    : theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                            fontStyle:
                                widget.log.amount == null
                                    ? FontStyle.italic
                                    : null,
                            fontWeight:
                                widget.log.amount == null
                                    ? null
                                    : FontWeight.bold,
                          ),
                          widget.log.amount != null
                              ? formatMoneyBig(
                                amount:
                                    widget.log.amount ?? 0,
                                context: context,
                              ).split('.').first
                              : 'Not Set',
                        ),
                      ),
                    ),
                    Icon(
                      size: 18,
                      color: Colors.grey.shade500,
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons
                              .keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
                Visibility(
                  visible: isOpen,
                  child: SizedBox(height: 3),
                ),
                Visibility(
                  visible: isOpen,
                  child: Divider(
                    color: Colors.grey.shade300,
                    height: 20,
                    thickness: 0.8,
                  ),
                ),
                Visibility(
                  visible: isOpen,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          MainAxisAlignment.end,
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
                ),
              ],
            ),
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
