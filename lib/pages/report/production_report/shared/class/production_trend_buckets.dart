import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

/// Trend buckets by business date, using the same closing time as the
/// report period. Intervals as the receipts trend. Same rules as
/// `PurchaseTrendBuilder`, for any production report row: the caller
/// gives the row's date, a new bucket and how a row adds to it.
class ProductionTrendBuckets {
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  /// First and last business day the chart covers. All time runs from
  /// the earliest row to today. Null without rows in an all-time
  /// period.
  static DateTimeRange? span({
    required Iterable<DateTime> dates,
    required ReceiptsReportPeriod period,
    required DateTime now,
    TimeOfDay? closingTime,
  }) {
    if (!period.isAllTime) {
      return DateTimeRange(start: period.start!, end: period.end!);
    }
    if (dates.isEmpty) return null;
    var first = ReceiptsTrendBuilder.businessDate(
      dates.first,
      closingTime: closingTime,
    );
    var last = _dateOnly(
      resolveBusinessDate(now, customClosingTime: closingTime),
    );
    for (final date in dates) {
      final d = ReceiptsTrendBuilder.businessDate(
        date,
        closingTime: closingTime,
      );
      if (d.isBefore(first)) first = d;
      if (d.isAfter(last)) last = d;
    }
    return DateTimeRange(start: first, end: last);
  }

  /// Buckets from the start to the end of the period, empty ones
  /// included. [rows] must already be in the period.
  static List<P> build<P, T>({
    required List<T> rows,
    required DateTime Function(T row) dateOf,
    required P Function(DateTime start) newPoint,
    required void Function(P point, T row) add,
    required ReceiptsReportPeriod period,
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    final range = span(
      dates: rows.map(dateOf),
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    if (range == null) return [];
    final interval = ReceiptsTrendBuilder.intervalFor(range.start, range.end);

    final points = <P>[];
    if (interval == ReceiptsTrendInterval.hourly) {
      final dayStart = fourAm(
        range.start,
        isUtc: false,
        customClosingTime: closingTime,
      );
      for (var h = 0; h < 24; h++) {
        points.add(newPoint(dayStart.add(Duration(hours: h))));
      }
      for (final r in rows) {
        final i = dateOf(r).toLocal().difference(dayStart).inHours.clamp(0, 23);
        add(points[i], r);
      }
      return points;
    }

    DateTime bucketOf(DateTime d) {
      switch (interval) {
        case ReceiptsTrendInterval.weekly:
          return _weekStart(d);
        case ReceiptsTrendInterval.monthly:
          return DateTime(d.year, d.month, 1);
        default:
          return d;
      }
    }

    DateTime next(DateTime d) {
      switch (interval) {
        case ReceiptsTrendInterval.weekly:
          return DateTime(d.year, d.month, d.day + 7);
        case ReceiptsTrendInterval.monthly:
          return DateTime(d.year, d.month + 1, 1);
        default:
          return DateTime(d.year, d.month, d.day + 1);
      }
    }

    final byStart = <DateTime, P>{};
    final last = bucketOf(range.end);
    for (var d = bucketOf(range.start); !d.isAfter(last); d = next(d)) {
      final p = newPoint(d);
      points.add(p);
      byStart[d] = p;
    }
    for (final r in rows) {
      final d = bucketOf(
        ReceiptsTrendBuilder.businessDate(dateOf(r), closingTime: closingTime),
      );
      final p = byStart[d];
      if (p != null) add(p, r);
    }
    return points;
  }
}
