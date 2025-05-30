import 'package:flutter/cupertino.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';

class ReportProvider extends ChangeNotifier {
  bool setDate = false;
  bool isDateSet = false;
  String? dateSet;

  void openDatePicker() {
    setDate = true;
    notifyListeners();
  }

  void setDay(BuildContext context, DateTime day) {
    returnExpensesProvider(
      context,
      listen: false,
    ).setExpenseDay(day);
    returnReceiptProvider(
      context,
      listen: false,
    ).setReceiptDay(day);
    setDate = false;
    isDateSet = true;
    dateSet = 'For ${formatDateTime(day)}';
    notifyListeners();
  }

  void setWeek(
    BuildContext context,
    DateTime weekStart,
    DateTime endOfWeek,
  ) {
    returnExpensesProvider(
      context,
      listen: false,
    ).setExpenseWeek(weekStart, endOfWeek);
    returnReceiptProvider(
      context,
      listen: false,
    ).setReceiptWeek(weekStart, endOfWeek);
    setDate = false;
    isDateSet = true;
    dateSet =
        '${formatDateWithoutYear(weekStart)} - ${formatDateWithoutYear(endOfWeek)}';
    notifyListeners();
  }

  void clearDate(BuildContext context) {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenseDate();
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
    setDate = false;
    isDateSet = false;
    dateSet = null;
    notifyListeners();
  }
}
