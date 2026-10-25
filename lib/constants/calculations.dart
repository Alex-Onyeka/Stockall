import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:uuid/uuid.dart';

String randomCode({int? length}) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();

  return "#${String.fromCharCodes(Iterable.generate(length ?? 4, (_) => chars.codeUnitAt(random.nextInt(chars.length))))}";
}

TimeOfDay? _getShopClosingTime(
  TimeOfDay? customClosingTime,
) {
  if (customClosingTime != null) return customClosingTime;
  try {
    final shop = returnShopProvider().userShop();
    if (shop?.closeSaleTimeString != null) {
      return parseTimeOfDay(shop!.closeSaleTimeString!);
    }
  } catch (_) {
    // Uninitialized provider / test environment: fallback to null (standard calendar day)
  }
  return null;
}

DateTime resolveBusinessDate(
  DateTime now, {
  TimeOfDay? customClosingTime,
}) {
  final cTime = _getShopClosingTime(customClosingTime);

  final closingToday =
      now.isUtc
          ? DateTime.utc(
            now.year,
            now.month,
            now.day,
            cTime?.hour ?? 0,
            cTime?.minute ?? 0,
          )
          : DateTime(
            now.year,
            now.month,
            now.day,
            cTime?.hour ?? 0,
            cTime?.minute ?? 0,
          );

  if (now.isBefore(closingToday)) {
    return now.subtract(const Duration(days: 1));
  }

  return now;
}

DateTime fourAm(
  DateTime date, {
  bool? isUtc,
  TimeOfDay? customClosingTime,
}) {
  final cTime = _getShopClosingTime(customClosingTime);

  final useUtc = isUtc ?? date.isUtc;

  if (useUtc) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      cTime?.hour ?? 0,
      cTime?.minute ?? 0,
    );
  }

  return DateTime(
    date.year,
    date.month,
    date.day,
    cTime?.hour ?? 0,
    cTime?.minute ?? 0,
  );
}

DateTime fourAmNextDay(
  DateTime date, {
  bool? isUtc,
  TimeOfDay? customClosingTime,
}) {
  return fourAm(
    date,
    isUtc: isUtc,
    customClosingTime: customClosingTime,
  ).add(const Duration(days: 1));
}

/// Checks whether [dateTime] falls within the business-day boundaries
/// defined by [dateSet] or [rangeStartDate]..[rangeEndDate].
///
/// Uses half-open interval `[start, end)` to prevent double-counting
/// at exact boundaries. Respects custom closing time ([cTime]) and
/// preserves timezone consistency so records are never shifted by
/// cross-timezone conversion offsets.
bool isDateTimeInBusinessWindow({
  required DateTime? dateTime,
  DateTime? dateSet,
  DateTime? rangeStartDate,
  DateTime? rangeEndDate,
  TimeOfDay? customClosingTime,
}) {
  if (dateTime == null) return false;
  if (dateSet == null &&
      rangeStartDate == null &&
      rangeEndDate == null) {
    return true;
  }

  final isUtc = dateTime.isUtc;
  if (dateSet != null) {
    final start = fourAm(
      dateSet,
      isUtc: isUtc,
      customClosingTime: customClosingTime,
    );
    final end = fourAmNextDay(
      dateSet,
      isUtc: isUtc,
      customClosingTime: customClosingTime,
    );
    return !dateTime.isBefore(start) &&
        dateTime.isBefore(end);
  } else if (rangeStartDate != null) {
    final start = fourAm(
      rangeStartDate,
      isUtc: isUtc,
      customClosingTime: customClosingTime,
    );
    final end = fourAmNextDay(
      rangeEndDate ?? rangeStartDate,
      isUtc: isUtc,
      customClosingTime: customClosingTime,
    );
    return !dateTime.isBefore(start) &&
        dateTime.isBefore(end);
  }
  return true;
}

DateTime endOfDay(DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    23,
    59,
    59,
    999,
  );
}

DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String addZeroAfterDecimalPoint(String value) {
  if (value.contains('.')) {
    return value;
  } else {
    return "$value.0";
  }
}

String formatLargeNumber(String numberString) {
  final number = double.tryParse(
    numberString.replaceAll(',', ''),
  );
  if (number == null) return numberString;

  // Format with commas
  final formatter = NumberFormat('#,###.###');
  return addZeroAfterDecimalPoint(formatter.format(number));
}

String formatLargeNumberDouble(num number) {
  final formatter = NumberFormat('#,###.###');
  return addZeroAfterDecimalPoint(formatter.format(number));
}

// Width/height values without a trailing ".0" (4, 1.5).
String formatDimension(num number) {
  final formatter = NumberFormat('#,###.###');
  return formatter.format(number);
}

// " (W x H)" for 2D lines, '' when either value is missing.
String dimensionUnitShortName(String? unit) {
  if (unit == null || unit.trim().isEmpty) return '';
  final lower = unit.toLowerCase().trim();
  if (lower.contains('centi') || lower == 'cm') return 'cm';
  if (lower.contains('milli') || lower == 'mm') return 'mm';
  if (lower.contains('meter') || lower == 'm') return 'm';
  if (lower.contains('inch') || lower == 'in') return 'in';
  if (lower.contains('foot') ||
      lower.contains('feet') ||
      lower == 'ft')
    return 'ft';
  if (lower.contains('yard') || lower == 'yd') return 'yd';
  return unit.trim();
}

// " (W x H)" or " (Wunit x Hunit)" for 2D lines, '' when either value is missing.
// " (W x H)" or " (Wunit x Hunit)" for 2D lines, '' when either value is missing.
String formatDimensionsLabel(
  double? width,
  double? height, {
  String? unit,
}) {
  if (width == null || height == null) {
    return '';
  }
  final u = dimensionUnitShortName(unit);
  final suffix = u.isNotEmpty ? u : '';
  return ' (${formatDimension(width)}$suffix x ${formatDimension(height)}$suffix)';
}

// Strips dimension labels like " (50 x 50)" or " (50cm x 50cm)" from a unit string.
String stripDimensionLabel(String unit) {
  return unit
      .replaceAll(RegExp(r'\s*\([^)]*x[^)]*\)\s*'), ' ')
      .trim();
}

// Formats the history unit string.
// If selected unit differs from primary unit, displays:
//   "SelectedUnit (PrimaryQty PrimaryUnit)"
// e.g. "bottles (0.2 Crates)" or "Slabs (0.5 M²)"
// If selected unit == primary unit, displays:
//   "SelectedUnit"
// e.g. "Crates" or "M²"
String formatHistoryUnit({
  required String selectedUnit,
  required String primaryUnit,
  required double primaryQuantity,
}) {
  final cleanSelected = stripDimensionLabel(
    selectedUnit.trim() == 'Others'
        ? 'Unit(s)'
        : selectedUnit.trim(),
  );
  final cleanPrimary = stripDimensionLabel(
    primaryUnit.trim() == 'Others'
        ? 'Unit(s)'
        : primaryUnit.trim(),
  );

  if (cleanSelected.isEmpty) return cleanPrimary;
  if (cleanPrimary.isEmpty ||
      cleanSelected.toLowerCase() ==
          cleanPrimary.toLowerCase()) {
    return cleanSelected;
  }

  return '$cleanSelected (${formatDimension(primaryQuantity.abs())} $cleanPrimary)';
}

String returnHistoryQuantity({
  required double? quantityChange,
  required bool? isIncreased,
  required String? unit,
  String? primaryUnit,
  String? oldValue,
  String? newValue,
}) {
  var displayUnit = unit ?? '';
  if (primaryUnit != null &&
      primaryUnit.trim().isNotEmpty &&
      primaryUnit.trim() != 'Others') {
    final cleanPrim = stripDimensionLabel(
      primaryUnit.trim() == 'Others'
          ? 'Unit(s)'
          : primaryUnit.trim(),
    );
    final cleanSelected = stripDimensionLabel(
      displayUnit.trim() == 'Others'
          ? 'Unit(s)'
          : displayUnit.trim(),
    );

    if (cleanSelected.toLowerCase() ==
        cleanPrim.toLowerCase()) {
      displayUnit = cleanSelected;
    } else {
      final alreadyHasPrimary =
          displayUnit.contains('(') &&
          displayUnit.toLowerCase().contains(
            cleanPrim.toLowerCase(),
          );
      if (!alreadyHasPrimary) {
        final oldVal =
            oldValue != null
                ? double.tryParse(
                  oldValue.replaceAll(',', ''),
                )
                : null;
        final newVal =
            newValue != null
                ? double.tryParse(
                  newValue.replaceAll(',', ''),
                )
                : null;
        if (oldVal != null &&
            newVal != null &&
            (newVal - oldVal).abs() > 1e-9) {
          final diff = (newVal - oldVal).abs();
          displayUnit = formatHistoryUnit(
            selectedUnit: cleanSelected,
            primaryUnit: cleanPrim,
            primaryQuantity: diff,
          );
        } else if (displayUnit.contains(
          RegExp(r'\([^)]*x[^)]*\)'),
        )) {
          displayUnit = cleanSelected;
        }
      }
    }
  }

  final quantity = quantityChange ?? 0;

  if (quantity == 0) {
    return '${formatDimension(quantity.abs())} $displayUnit'
        .trim();
  }

  if (isIncreased == false) {
    return '-${formatDimension(quantity.abs())} $displayUnit'
        .trim();
  }

  return '+${formatDimension(quantity.abs())} $displayUnit'
      .trim();
}

// Extra area used up as wastage on a 2D line: a percent of
// [baseArea], or a fixed area for the whole line. 0 when unset.
double computeWastageArea({
  required double baseArea,
  required double? amount,
  required bool? isPercentage,
}) {
  if (amount == null ||
      !amount.isFinite ||
      amount <= 0 ||
      baseArea <= 0) {
    return 0;
  }
  if (isPercentage == true) {
    return baseArea * (amount / 100);
  }
  return amount;
}

// Shown when a 2D line fits in stock without its wastage but
// not with it.
String wastageStockMessage({
  required double cutArea,
  required double wastageArea,
  required double availableArea,
  required String unit,
}) {
  final available = availableArea < 0 ? 0 : availableArea;
  return 'Not enough stock after wastage. This sale needs '
      '${formatDimension(cutArea + wastageArea)} $unit '
      '(${formatDimension(cutArea)} $unit + '
      '${formatDimension(wastageArea)} $unit wastage), '
      'but only ${formatDimension(available)} $unit is available.';
}

String formatLargeNumberDoubleWidgetDecimal(num number) {
  final formatter = NumberFormat('#,##0.0');
  return formatter.format(number);
}

String formatDateWithTime(DateTime date) {
  return "${formatDateTime(date)} | ${formatTime(date)}";
}

String formatDateTime(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatTimeOfDay(TimeOfDay time) {
  final hour =
      time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';

  return '$hour:$minute $period';
}

String formatDateWithoutYear(DateTime date) {
  return DateFormat('E, MMM d').format(date);
}

String formatMonthAndDay(DateTime date) {
  return DateFormat('MMM d').format(date);
}

String formatDateTimeTime(DateTime date) {
  return DateFormat('E, d : hh:mm a').format(date);
}

String formatDateWithDay(DateTime date) {
  return DateFormat('E, MMM d, yyyy').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

String? timeOfDayToPostgres(TimeOfDay? time) {
  if (time == null) {
    return null;
  } else {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return "$hour:$minute:00";
  }
}

TimeOfDay parseTimeOfDay(String time) {
  final parts = time.split(":");

  return TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );
}

String cutLongText(String text, int length) {
  if (text.length > length) {
    return '${text.substring(0, length)}...';
  }
  return text;
}

String formatMoney(num amount, BuildContext context) {
  if (amount < 1000000) {
    return "${currencySymbol(context: context)}${formatLargeNumberDouble(amount)}";
  } else {
    String symbol = currencySymbol(context: context);
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = formatLargeNumberDouble(value);
    return '$symbol$formatted $suffix';
  }
}

String formatMoneyMid({
  required num amount,
  required BuildContext context,
  bool? isR,
}) {
  if (amount < 100000000) {
    return "${currencySymbol(context: context, isR: isR)}${formatLargeNumberDouble(amount)}";
  } else {
    String symbol = currencySymbol(
      context: context,
      isR: isR,
    );
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = formatLargeNumberDouble(value);
    return '$symbol$formatted $suffix';
  }
}

String formatMoneyAlt({
  required num amount,
  required String currency,
  bool? isR,
}) {
  if (amount < 100000000) {
    return "$currency${formatLargeNumberDouble(amount)}";
  } else {
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = formatLargeNumberDouble(value);
    return '$currency$formatted $suffix';
  }
}

String formatMoneyBig({
  required num amount,
  required BuildContext context,
  bool? isR,
}) {
  if (amount < 1000000000) {
    // return NumberFormat.currency(
    //   locale: 'en_NG',
    //   symbol: currencySymbol(context: context, isR: isR),
    //   decimalDigits: 1,
    // ).format(amount);
    return "${currencySymbol(context: context, isR: isR)}${formatLargeNumberDouble(amount)}";
  } else {
    String symbol = currencySymbol(
      context: context,
      isR: isR,
    );
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = formatLargeNumberDouble(value);
    return '$symbol$formatted $suffix';
  }
}

String? formatCompactMoney({
  double? amount,
  required BuildContext context,
}) {
  final formatter = NumberFormat.compact(locale: 'en');
  return amount == null
      ? null
      : '${currencySymbol(context: context)}${formatter.format(amount)}';
}

var uuid = Uuid();

String uuidGen() {
  return uuid.v4();
}

double? calculateMarkup({
  required double costPrice,
  required double sellingPrice,
}) {
  if (costPrice <= 0) return null;
  return ((sellingPrice - costPrice) / costPrice) * 100;
}

double? calculateMargin({
  required double costPrice,
  required double sellingPrice,
}) {
  if (sellingPrice <= 0) return null;
  return ((sellingPrice - costPrice) / sellingPrice) * 100;
}

double? calculateSellingPriceFromMarkup({
  required double costPrice,
  required double markup,
}) {
  if (costPrice <= 0) return null;
  return costPrice * (1 + (markup / 100));
}

double? calculateSellingPriceFromMargin({
  required double costPrice,
  required double margin,
}) {
  if (costPrice <= 0 || margin >= 100) return null;
  return costPrice / (1 - (margin / 100));
}

String formatPercentage(double value) {
  if (value.isNaN || value.isInfinite) return '';
  String fixed = value.toStringAsFixed(2);
  if (fixed.contains('.')) {
    fixed = fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return fixed;
}

