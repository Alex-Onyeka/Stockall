import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

// Trend chart of the purchase analysis, shared by the reports that
// chart amounts per business day / week / month (Spend and Paid).

/// Axis and tooltip label of a bucket starting at [d].
String reportTrendBucketLabel(ReceiptsTrendInterval? interval, DateTime d) {
  switch (interval) {
    case ReceiptsTrendInterval.hourly:
      return DateFormat('ha').format(d);
    case ReceiptsTrendInterval.monthly:
      return DateFormat('MMM yy').format(d);
    case ReceiptsTrendInterval.daily:
    case ReceiptsTrendInterval.weekly:
    case null:
      return formatMonthAndDay(d);
  }
}

String reportTrendIntervalLabel(ReceiptsTrendInterval? interval) {
  switch (interval) {
    case ReceiptsTrendInterval.hourly:
      return 'Hourly';
    case ReceiptsTrendInterval.daily:
    case null:
      return 'Daily';
    case ReceiptsTrendInterval.weekly:
      return 'Weekly (from Monday)';
    case ReceiptsTrendInterval.monthly:
      return 'Monthly';
  }
}

/// Bottom axis titles for buckets starting at [starts]: about six
/// labels, whatever the number of buckets.
Widget Function(double, TitleMeta) reportTrendBottomTitle(
  List<DateTime> starts,
  ReceiptsTrendInterval? interval,
) {
  return (value, meta) {
    final i = value.round();
    if (i < 0 || i >= starts.length || value != i) {
      return const SizedBox.shrink();
    }
    final step = math.max(1, (starts.length / 6).ceil());
    if (i % step != 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        reportTrendBucketLabel(interval, starts[i]),
        style: const TextStyle(fontSize: 9),
      ),
    );
  };
}

/// Colour squares with their labels.
class ReportChartLegend extends StatelessWidget {
  final List<(String, Color)> items;

  const ReportChartLegend({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (label, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
      ],
    );
  }
}

/// One line of a [ReportTrendChart]: a value per bucket.
class ReportTrendSeries {
  final String label;
  final Color color;
  final List<double> values;

  const ReportTrendSeries({
    required this.label,
    required this.color,
    required this.values,
  });
}

/// Legend plus a line per series over the buckets in [starts].
/// Every series has one value per bucket. Callers show their own
/// empty state when there are no buckets.
class ReportTrendChart extends StatelessWidget {
  final List<DateTime> starts;
  final ReceiptsTrendInterval? interval;
  final List<ReportTrendSeries> series;
  final String Function(num amount) money;
  final double height;

  const ReportTrendChart({
    super.key,
    required this.starts,
    required this.interval,
    required this.series,
    required this.money,
    this.height = 220,
  });

  String _compact(double v) => NumberFormat.compact().format(v);

  @override
  Widget build(BuildContext context) {
    double maxY = 0;
    // Below 0 only when a series goes negative (net profit), so
    // charts without negatives keep minY 0.
    double minY = 0;
    for (final s in series) {
      for (final v in s.values) {
        maxY = math.max(maxY, v);
        minY = math.min(minY, v);
      }
    }
    if (maxY == 0) maxY = 1;

    LineChartBarData line(ReportTrendSeries s) {
      return LineChartBarData(
        spots: [
          for (var i = 0; i < s.values.length; i++)
            FlSpot(i.toDouble(), s.values[i]),
        ],
        color: s.color,
        barWidth: 2,
        isCurved: false,
        dotData: FlDotData(show: starts.length <= 31),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        ReportChartLegend(items: [for (final s in series) (s.label, s.color)]),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minY * 1.1,
              maxY: maxY * 1.1,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget:
                        (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _compact(value),
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: reportTrendBottomTitle(starts, interval),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  getTooltipItems:
                      (spots) =>
                          spots.map((s) {
                            final label = series[s.barIndex].label;
                            final when = reportTrendBucketLabel(
                              interval,
                              starts[s.x.round()],
                            );
                            return LineTooltipItem(
                              '$when\n$label: ${money(s.y)}',
                              TextStyle(
                                fontSize: 10,
                                color: s.bar.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                ),
              ),
              lineBarsData: [for (final s in series) line(s)],
            ),
          ),
        ),
      ],
    );
  }
}
