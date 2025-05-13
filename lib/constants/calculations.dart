import 'package:intl/intl.dart';

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
  return DateFormat('MMM d').format(date);
}

String formatDateTimeTime(DateTime date) {
  return DateFormat('E, d : hh:mm a').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}
