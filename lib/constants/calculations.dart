import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/constants/constants_main.dart';

String formatLargeNumber(String numberString) {
  final number = int.tryParse(
    numberString.replaceAll(',', ''),
  );
  if (number == null) return numberString;

  // Format with commas
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

String formatLargeNumberDouble(num number) {
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

String formatLargeNumberDoubleWidgetDecimal(num number) {
  final formatter = NumberFormat('#,##0.0');
  return formatter.format(number);
}

String formatDateTime(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
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

String cutLongText(String text, int length) {
  if (text.length > length) {
    return '${text.substring(0, length)}...';
  }
  return text;
}

// String formatMoney(num amount) {
//   if (amount < 1000000) {
//     return NumberFormat.currency(
//       locale: 'en_NG', // Nigerian locale
//       symbol: '₦',
//       decimalDigits: 1,
//     ).format(amount);
//   } else {
//     return NumberFormat.compactCurrency(
//       locale: 'en_NG',
//       symbol: '₦',
//       decimalDigits: 1,
//     ).format(amount);
//   }
// }

String formatMoney(num amount, BuildContext context) {
  if (amount < 1000000) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: currencySymbol(context),
      decimalDigits: 1,
    ).format(amount);
  } else {
    String symbol = currencySymbol(context);
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = value.toStringAsFixed(
      1,
    ); // Ensures .0 is included
    return '$symbol$formatted $suffix';
  }
}

String formatMoneyMid(num amount, BuildContext context) {
  if (amount < 100000000) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: currencySymbol(context),
      decimalDigits: 1,
    ).format(amount);
  } else {
    String symbol = currencySymbol(context);
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = value.toStringAsFixed(
      1,
    ); // Ensures .0 is included
    return '$symbol$formatted $suffix';
  }
}

String formatMoneyBig(num amount, BuildContext context) {
  if (amount < 1000000000) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: currencySymbol(context),
      decimalDigits: 1,
    ).format(amount);
  } else {
    String symbol = currencySymbol(context);
    String suffix = '';
    double value = amount.toDouble();

    if (value >= 1_000_000_000) {
      value = value / 1_000_000_000;
      suffix = 'B';
    } else if (value >= 1_000_000) {
      value = value / 1_000_000;
      suffix = 'M';
    }

    String formatted = value.toStringAsFixed(
      1,
    ); // Ensures .0 is included
    return '$symbol$formatted $suffix';
  }
}
