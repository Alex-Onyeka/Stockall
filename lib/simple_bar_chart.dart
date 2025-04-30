import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 8,
                color: Colors.blue,
                width: 20,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 10,
                color: Colors.green,
                width: 20,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 14,
                color: Colors.red,
                width: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    switch (value.toInt()) {
      case 0:
        return Text('Mon', style: style);
      case 1:
        return Text('Tue', style: style);
      case 2:
        return Text('Wed', style: style);
      default:
        return Text('', style: style);
    }
  }
}
