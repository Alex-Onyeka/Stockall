import 'package:flutter/material.dart';
import 'package:stockitt/components/bar_chart/horizontal_stroke.dart';
import 'package:stockitt/components/bar_chart/vertical_stroke.dart';
import 'package:intl/intl.dart';

class DailyBarChart extends StatefulWidget {
  final double height;
  final double width;
  const DailyBarChart({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  State<DailyBarChart> createState() =>
      _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart> {
  List<double> values = [];

  void setValues(double number) {
    values.clear(); // Optional: clear old values if needed

    double step =
        number / 4; // 4 equal steps between 6 values

    for (int i = 0; i < 5; i++) {
      values.add(number - (step * i));
    }
  }

  List<Map<String, dynamic>> days = [];

  void generateLast7Days() {
    List<Map<String, dynamic>> temp = [];
    days.clear();
    DateTime today = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      DateTime currentDay = today.subtract(
        Duration(days: i),
      );
      String dayName = DateFormat(
        'EEE',
      ).format(currentDay); // 'Mon', 'Tue', etc.
      int date = currentDay.day;

      temp.add({'day': dayName, 'date': date});
    }
    days.addAll(temp);
  }

  @override
  void initState() {
    super.initState();
    setValues(300);
    generateLast7Days();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(15),
        // border: Border.all(color: Colors.grey),
      ),
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 50,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                VerticalStroke(
                  value: 5555.342,
                  day:
                      days[0]['day'] +
                      ' ' +
                      '${days[0]['date']}',
                  height: 6055.342,
                ),
                VerticalStroke(
                  value: 6055.342,
                  day: days[1]['day'],
                  height: 6055.342,
                ),
                VerticalStroke(
                  value: 2055.342,
                  day: days[2]['day'],
                  height: 6055.342,
                ),
                VerticalStroke(
                  value: 1055.342,
                  day: days[3]['day'],
                  height: 6055.342,
                ),
                VerticalStroke(
                  value: 1055.342,
                  day: days[4]['day'],
                  height: 6055.342,
                ),
                VerticalStroke(
                  value: 1055.342,
                  day: days[5]['day'],
                  height: 6055.342,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                HorizontalStroke(value: values[0]),
                HorizontalStroke(value: values[1]),
                HorizontalStroke(value: values[2]),
                HorizontalStroke(value: values[3]),
                HorizontalStroke(value: values[4]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
