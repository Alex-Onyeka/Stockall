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

DateTime resolveBusinessDate(DateTime now) {
  final shop = returnShopProvider().userShop();

  final cTime =
      shop?.closeSaleTimeString != null
          ? parseTimeOfDay(shop!.closeSaleTimeString!)
          : null;

  final closingToday = DateTime(
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

DateTime fourAm(DateTime date) {
  final shop = returnShopProvider().userShop();

  final cTime =
      shop?.closeSaleTimeString != null
          ? parseTimeOfDay(shop!.closeSaleTimeString!)
          : null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    cTime?.hour ?? 0,
    cTime?.minute ?? 0,
  );
}

DateTime fourAmNextDay(DateTime date) {
  return fourAm(date).add(const Duration(days: 1));
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
