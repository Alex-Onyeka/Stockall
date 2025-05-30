import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime, DateTime)? onDaySelected;
  final Function(DateTime, DateTime)? actionWeek;
  final bool? isMain;
  const CalendarWidget({
    super.key,
    required this.onDaySelected,
    required this.actionWeek,
    this.isMain,
  });

  @override
  State<CalendarWidget> createState() =>
      _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  bool isWeekMode = false;

  DateTime? selectedDay;
  DateTime? focusedDay;
  DateTime? startOfWeek;
  DateTime? endOfWeek;

  List<Map<String, DateTime>> getWeeksInMonth(
    DateTime month,
  ) {
    List<Map<String, DateTime>> weeks = [];

    DateTime firstDayOfMonth = DateTime(
      month.year,
      month.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      month.year,
      month.month + 1,
      0,
    );

    // Adjust to previous Monday
    int daysToSubtract =
        firstDayOfMonth.weekday - DateTime.monday;
    if (daysToSubtract < 0) daysToSubtract += 7;
    DateTime start = firstDayOfMonth.subtract(
      Duration(days: daysToSubtract),
    );

    while (start.isBefore(lastDayOfMonth)) {
      DateTime end = start.add(Duration(days: 6));
      if (end.isAfter(lastDayOfMonth)) {
        end = lastDayOfMonth;
      }

      weeks.add({'start': start, 'end': end});
      start = start.add(Duration(days: 7));
    }

    return weeks;
  }

  String formatDateRange(DateTime start, DateTime end) {
    return "${start.day} ${monthName(start.month)} - ${end.day} ${monthName(end.month)}";
  }

  String monthName(int month) {
    return [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month];
  }

  void resetToToday() {
    setState(() {
      focusedDay = DateTime.now();
      selectedDay = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      resetToToday();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      child: Center(child: Text('Reset')),
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      widget.isMain == null ? true : false,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isWeekMode = !isWeekMode;
                        calendarFormat =
                            CalendarFormat.month;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            style: TextStyle(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            isWeekMode
                                ? "Switch to Days"
                                : "Switch to Weeks",
                          ),
                          SizedBox(width: 10),
                          Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(20),
                              color:
                                  !isWeekMode
                                      ? Colors.grey.shade400
                                      : theme
                                          .lightModeColor
                                          .prColor300,
                              border: Border.all(
                                color:
                                    !isWeekMode
                                        ? Colors
                                            .grey
                                            .shade600
                                        : Colors.white,
                              ),
                            ),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  isWeekMode = !isWeekMode;
                                  calendarFormat =
                                      CalendarFormat.month;
                                });
                              },
                              child: Container(
                                height: 25,
                                width: 50,
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                child: Align(
                                  alignment: Alignment(
                                    isWeekMode ? 1 : -1,
                                    0,
                                  ),
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    decoration:
                                        BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          color:
                                              Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isWeekMode)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 20),
                itemCount:
                    getWeeksInMonth(
                      focusedDay ?? DateTime.now(),
                    ).length,
                itemBuilder: (context, index) {
                  final week =
                      getWeeksInMonth(
                        focusedDay ?? DateTime.now(),
                      )[index];
                  final start = week['start'] as DateTime;
                  final end = week['end'] as DateTime;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          widget.actionWeek!(start, end);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                    ),
                                    "${index + 1}st Week : ",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                    ),
                                    " ${formatDateRange(start, end)}",
                                  ),
                                ],
                              ),
                              Icon(
                                size: 18,
                                color: Colors.grey.shade500,
                                Icons
                                    .arrow_forward_ios_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (!isWeekMode)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay ?? DateTime.now(),
              selectedDayPredicate:
                  (day) => isSameDay(selectedDay, day),
              calendarFormat: calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
                widget.onDaySelected!(
                  selectedDay,
                  focusedDay,
                );
              },
              onPageChanged: (newFocusedDay) {
                setState(() {
                  focusedDay = newFocusedDay;
                });
              },
              availableCalendarFormats: {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              onFormatChanged: (format) {
                if (format != CalendarFormat.month &&
                    format != CalendarFormat.week) {
                  setState(() {
                    calendarFormat = CalendarFormat.month;
                  });
                }
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
        ],
      ),
    );
  }
}
