import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

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

    // Start from the first day of the month
    DateTime start = DateTime(month.year, month.month, 1);

    // Adjust the start day to the previous Sunday (or whichever start of the week you'd prefer)
    start = start.subtract(
      Duration(days: start.weekday),
    ); // Set to the start of the week

    while (start.month <= month.month) {
      // End is always 6 days after start, making a 7-day week
      DateTime end = start.add(Duration(days: 6));

      // If end goes to the next month, we limit it to the last day of the current month
      if (end.month != month.month) {
        end = DateTime(
          month.year,
          month.month + 1,
          0,
        ); // Set to the last day of the month
      }

      // If the start date is in the current month, add the week
      if (start.month == month.month) {
        weeks.add({'start': start, 'end': end});
      }

      // Move to the next week
      start = end.add(Duration(days: 1));
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
      appBar: AppBar(
        title: Text('Calendar with Range Selection'),
      ),
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
                Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      style: TextStyle(
                        color:
                            theme.lightModeColor.prColor300,
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      isWeekMode
                          ? "Switch to Days"
                          : "Switch to Weeks",
                    ),

                    InkWell(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      onTap: () {
                        setState(() {
                          isWeekMode = !isWeekMode;
                          calendarFormat =
                              isWeekMode
                                  ? CalendarFormat.month
                                  : CalendarFormat.month;
                        });
                      },
                      child: Container(
                        height: 25,
                        width: 50,
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
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
                                    ? Colors.grey.shade600
                                    : Colors.white,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment(
                            isWeekMode ? 1 : -1,
                            0,
                          ),
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isWeekMode)
            Expanded(
              child: ListView.builder(
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

                  return InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        "Week ${index + 1}: ${formatDateRange(start, end)}",
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
            ),
        ],
      ),
    );
  }
}
