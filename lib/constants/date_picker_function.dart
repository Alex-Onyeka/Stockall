import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/providers/theme_provider.dart';

Future<dynamic> mainDatePicker({
  required BuildContext context,
  required ThemeProvider theme,
  Function(DateTime? date)? singleDate,
  Function(DateTime? firstDate, DateTime? lastDate)?
  rangeDate,
}) {
  return showDialog(
    context: context,
    builder: (dateContext) {
      return DialogTemplate(
        theme: theme,
        showBottomActionButtons: false,
        message: 'Select to view single date a date range',
        title: 'Select Date',
        topRightWidget: IconButton(
          onPressed: () {
            Navigator.of(dateContext).pop();
          },
          icon: Icon(size: 20, Icons.clear),
        ),
        action: () {},
        widget: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            MainButtonP(
              themeProvider: theme,
              action: () {
                Navigator.of(dateContext).pop();
                myDatePickerAction(theme, context).then((
                  value,
                ) {
                  value != null
                      ? singleDate != null
                          ? singleDate(value)
                          : {}
                      : {};
                });
              },
              text: 'Select Single Day',
            ),
            MainButtonTransparent(
              themeProvider: theme,
              constraints: BoxConstraints(),
              text: 'Select Range',
              action: () {
                Navigator.of(dateContext).pop();
                showDialog(
                  context: context,
                  builder: (rangeDialog) {
                    DateTime? firstDate;
                    DateTime? lastDate;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return DialogTemplate(
                          theme: theme,
                          message:
                              'Select Beginning and end date of Range.',
                          title: 'Select Range',
                          action: () {
                            if (firstDate != null) {
                              rangeDate != null
                                  ? rangeDate(
                                    firstDate,
                                    lastDate?.add(
                                      Duration(
                                        hours: 23,
                                        minutes: 59,
                                        seconds: 59,
                                      ),
                                    ),
                                  )
                                  : {};
                              Navigator.of(
                                rangeDialog,
                              ).pop();
                            }
                          },
                          topRightWidget: IconButton(
                            onPressed: () {
                              Navigator.of(
                                rangeDialog,
                              ).pop();
                            },
                            icon: Icon(
                              size: 20,
                              Icons.clear,
                            ),
                          ),
                          widget: Padding(
                            padding: const EdgeInsets.only(
                              top: 15.0,
                            ),
                            child: Row(
                              spacing: 10,
                              mainAxisSize:
                                  MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      onTap: () {
                                        myDatePickerAction(
                                          theme,
                                          context,
                                        ).then((value) {
                                          setState(() {
                                            firstDate =
                                                value;
                                          });
                                        });
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsetsGeometry.symmetric(
                                              vertical: 10,
                                              horizontal:
                                                  10,
                                            ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                5,
                                              ),
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            firstDate !=
                                                    null
                                                ? formatDateTime(
                                                  firstDate!,
                                                )
                                                : 'Start',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Material(
                                    color:
                                        Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      onTap: () {
                                        myDatePickerAction(
                                          theme,
                                          context,
                                        ).then((value) {
                                          setState(() {
                                            lastDate =
                                                value;
                                          });
                                        });
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsetsGeometry.symmetric(
                                              vertical: 10,
                                              horizontal:
                                                  10,
                                            ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                5,
                                              ),
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            lastDate != null
                                                ? formatDateTime(
                                                  lastDate!,
                                                )
                                                : 'End',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<DateTime?> myDatePickerAction(
  ThemeProvider theme,
  BuildContext context,
) {
  return showDatePicker(
    confirmText: 'Select',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.orange,
            onPrimary: Colors.white,
            secondary: Colors.orange,
          ),
          datePickerTheme: DatePickerThemeData(
            dividerColor: Colors.grey.shade300,
            headerHeadlineStyle: TextStyle(
              fontSize: theme.mobileTexts.h2.fontSize,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(
                10,
              ),
            ),
            todayForegroundColor: WidgetStatePropertyAll(
              Colors.orange,
            ),
            weekdayStyle: TextStyle(
              fontSize: theme.mobileTexts.b2.fontSize,
            ),
            dayStyle: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            confirmButtonStyle: ButtonStyle(
              overlayColor: WidgetStatePropertyAll(
                const Color.fromARGB(35, 255, 254, 254),
              ),
              foregroundColor: WidgetStatePropertyAll(
                Colors.white,
              ),
              backgroundColor: WidgetStatePropertyAll(
                theme.lightModeColor.prColor300,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadiusGeometry.circular(5),
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  // fontWeight:
                  //     FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            cancelButtonStyle: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(
                Colors.grey.shade800,
              ),
              backgroundColor: WidgetStatePropertyAll(
                Colors.grey.shade300,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadiusGeometry.circular(5),
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                ),
              ),
            ),
          ),
        ),
        child: child!,
      );
    },
    context: context,
    firstDate: DateTime(2000, 9, 7, 17, 30),
    lastDate: DateTime(2100, 9, 7, 17, 30),
  );
}
