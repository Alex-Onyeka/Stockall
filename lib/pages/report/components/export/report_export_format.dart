// Value formatting for report exports (PDF, Excel and roll).
//
// The screen helpers in constants/calculations.dart shorten big amounts
// to M/B and allow three decimals. A printed or exported report needs the
// full figure, so these are separate: money always has two decimals and
// the sign goes before the currency (-₦500.00).

import 'package:intl/intl.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';

class ExportFormatter {
  final String currency;

  ExportFormatter({required this.currency});

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _integer = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _decimal = NumberFormat('#,##0.###', 'en_US');
  static final DateFormat _date = DateFormat('MMM d, yyyy', 'en_US');
  static final DateFormat _time = DateFormat('hh:mm a', 'en_US');

  // -0.0 and values that round to zero print without a minus sign.
  static bool _negative(num v, int decimals) {
    final factor = decimals == 0 ? 1 : (decimals == 2 ? 100 : 1000);
    return (v * factor).round() < 0;
  }

  String money(num v) {
    if (v.isNaN || v.isInfinite) return '';
    final sign = _negative(v, 2) ? '-' : '';
    return '$sign$currency${_money.format(v.abs())}';
  }

  String integer(num v) {
    if (v.isNaN || v.isInfinite) return '';
    final sign = _negative(v, 0) ? '-' : '';
    return '$sign${_integer.format(v.abs())}';
  }

  /// Up to three decimals, no trailing zeros: 1,250 / 2.5 / 0.125.
  String number(num v) {
    if (v.isNaN || v.isInfinite) return '';
    final sign = _negative(v, 3) ? '-' : '';
    return '$sign${_decimal.format(v.abs())}';
  }

  String quantity(num v) => number(v);

  /// [v] is already a percentage: 12.5 -> "12.5%".
  String percent(num v) {
    if (v.isNaN || v.isInfinite) return '';
    var fixed = v.toStringAsFixed(2);
    if (fixed.contains('.')) {
      fixed = fixed
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    if (fixed == '-0') fixed = '0';
    return '$fixed%';
  }

  String date(DateTime d) => _date.format(d);

  String time(DateTime d) => _time.format(d);

  String dateTime(DateTime d) => '${date(d)} | ${time(d)}';

  /// Text for one cell. Null and unusable values give ''.
  String format(Object? value, ExportFormat format) {
    if (value == null) return '';
    switch (format) {
      case ExportFormat.text:
        return value is DateTime ? dateTime(value) : value.toString();
      case ExportFormat.integer:
        return value is num ? integer(value) : value.toString();
      case ExportFormat.number:
        return value is num ? number(value) : value.toString();
      case ExportFormat.quantity:
        return value is num ? quantity(value) : value.toString();
      case ExportFormat.money:
        return value is num ? money(value) : value.toString();
      case ExportFormat.percent:
        return value is num ? percent(value) : value.toString();
      case ExportFormat.date:
        return value is DateTime ? date(value) : value.toString();
      case ExportFormat.time:
        return value is DateTime ? time(value) : value.toString();
      case ExportFormat.dateTime:
        return value is DateTime ? dateTime(value) : value.toString();
    }
  }
}

// ---------------------------------------------------------------------
// Excel number formats
// ---------------------------------------------------------------------

/// Money with the shop currency as a literal: "₦"#,##0.00;-"₦"#,##0.00
String excelMoneyFormat(String currency) {
  if (currency.isEmpty) return '#,##0.00;-#,##0.00';
  final quoted = '"${currency.replaceAll('"', '')}"';
  return '$quoted#,##0.00;-$quoted#,##0.00';
}

const String excelIntegerFormat = '#,##0';
const String excelDecimalFormat = '#,##0.###';

/// Percentages are stored as fractions (12.5% -> 0.125).
const String excelPercentFormat = '0.00%';
const String excelDateFormat = 'dd mmm yyyy';
const String excelTimeFormat = 'hh:mm AM/PM';
const String excelDateTimeFormat = 'dd mmm yyyy hh:mm AM/PM';

/// The Excel number format for one value. Whole numbers drop the
/// decimals so a quantity of 12 doesn't show as "12.".
String? excelNumberFormat(
  ExportFormat format,
  Object? value, {
  required String currency,
}) {
  switch (format) {
    case ExportFormat.money:
      return excelMoneyFormat(currency);
    case ExportFormat.integer:
      return excelIntegerFormat;
    case ExportFormat.number:
    case ExportFormat.quantity:
      if (value is num && value == value.roundToDouble()) {
        return excelIntegerFormat;
      }
      return excelDecimalFormat;
    case ExportFormat.percent:
      return excelPercentFormat;
    case ExportFormat.date:
      return excelDateFormat;
    case ExportFormat.time:
      return excelTimeFormat;
    case ExportFormat.dateTime:
      return excelDateTimeFormat;
    case ExportFormat.text:
      return null;
  }
}
