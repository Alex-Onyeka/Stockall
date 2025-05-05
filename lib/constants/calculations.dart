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
