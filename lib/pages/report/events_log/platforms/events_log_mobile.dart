import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/main.dart';

class EventsLogMobile extends StatefulWidget {
  const EventsLogMobile({super.key});

  @override
  State<EventsLogMobile> createState() =>
      _EventsLogMobileState();
}

class _EventsLogMobileState extends State<EventsLogMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnEventsLogProvider().getEventLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 0,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'Events Log',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 20.0,
          left: 0,
        ),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3.0,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      returnEventsLogProvider(
                                context: context,
                              ).dateSet !=
                              null
                          ? formatDateTime(
                            returnEventsLogProvider(
                                  context: context,
                                ).dateSet ??
                                DateTime.now(),
                          )
                          : 'All Logs',
                    ),
                    InkWell(
                      onTap: () {
                        returnEventsLogProvider().dateSet ==
                                    null &&
                                returnEventsLogProvider()
                                        .rangeStartDate ==
                                    null
                            ? mainDatePicker(
                              context: context,
                              theme: theme,
                              singleDate: (value) {
                                returnEventsLogProvider()
                                    .setDate(value!);
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
                        padding: const EdgeInsets.all(10.0),
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
                                  ? Icons.calendar_month
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
              child: Builder(
                builder: (context) {
                  var logs =
                      returnEventsLogProvider(
                        context: context,
                      ).returnLogs();
                  if (logs.isEmpty) {
                    return Center(
                      child: EmptyWidgetDisplayOnly(
                        title: 'No Event Log Found',
                        subText:
                            'No event has been performed for this date.',
                        theme: theme,
                        height: 25,
                        icon: Icons.clear,
                        altAction: () async {
                          await returnEventsLogProvider()
                              .getEventLogs();
                        },
                        altActionText: 'Refresh',
                        altIcon: Icons.refresh,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await returnEventsLogProvider()
                                    .getEventLogs();
                              },
                              backgroundColor: Colors.white,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              displacement: 10,
                              child: ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  TempEventLogClass log =
                                      logs[index];
                                  return LogWidgetMobile(
                                    log: log,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogWidgetMobile extends StatefulWidget {
  final TempEventLogClass log;
  const LogWidgetMobile({super.key, required this.log});

  @override
  State<LogWidgetMobile> createState() =>
      _LogWidgetMobileState();
}

class _LogWidgetMobileState extends State<LogWidgetMobile> {
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
                  spacing: 6,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
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
                    MyDividerMobile(),
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
                      child: MyDividerMobile(),
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
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 1,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Event Description:',
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
                        ],
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                        height: 0,
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
                                    fontWeight:
                                        FontWeight.bold,
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
                                  widget.log.staffName ??
                                      '',
                                ),
                              ],
                            ),
                            MyDividerMobile(),
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
                                    fontWeight:
                                        FontWeight.bold,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyDividerMobile extends StatelessWidget {
  const MyDividerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 1,
      color: const Color.fromARGB(66, 158, 158, 158),
    );
  }
}
