import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/main.dart';

class ErrorLogMobile extends StatefulWidget {
  const ErrorLogMobile({super.key});

  @override
  State<ErrorLogMobile> createState() =>
      _ErrorLogMobileState();
}

class _ErrorLogMobileState extends State<ErrorLogMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnErrorLogProvider().getErrorLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        leading: IconButton(
          mouseCursor: SystemMouseCursors.click,
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
              'Error Log',
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
                      returnErrorLogProvider(
                                context: context,
                              ).dateSet !=
                              null
                          ? formatDateTime(
                            returnErrorLogProvider(
                                  context: context,
                                ).dateSet ??
                                DateTime.now(),
                          )
                          : 'All Logs',
                    ),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        returnErrorLogProvider().dateSet ==
                                    null &&
                                returnErrorLogProvider()
                                        .rangeStartDate ==
                                    null
                            ? mainDatePicker(
                              context: context,
                              theme: theme,
                              singleDate: (value) {
                                returnErrorLogProvider()
                                    .setDate(value!);
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
              child: Builder(
                builder: (context) {
                  var logs =
                      returnErrorLogProvider(
                        context: context,
                      ).returnLogs();
                  if (logs.isEmpty) {
                    return Center(
                      child: EmptyWidgetDisplayOnly(
                        title: 'No Error Log Found',
                        subText:
                            'No error has been performed for this date.',
                        theme: theme,
                        height: 25,
                        icon: Icons.clear,
                        altAction: () async {
                          await returnErrorLogProvider()
                              .getErrorLogs();
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
                                await returnErrorLogProvider()
                                    .getErrorLogs();
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
                                  TempErrorLogClass log =
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
  final TempErrorLogClass log;
  const LogWidgetMobile({super.key, required this.log});

  @override
  State<LogWidgetMobile> createState() =>
      _LogWidgetMobileState();
}

class _LogWidgetMobileState extends State<LogWidgetMobile> {
  // bool isOpen = false;
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
                spacing: 6,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  MyDividerMobile(),
                  Expanded(
                    flex: 4,
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
              Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
            ],
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
