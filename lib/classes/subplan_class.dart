import 'package:stockall/constants/subscription/calculator_auth.dart';
import 'package:stockall/constants/subscription/employee_auth.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';

class SubplanClass {
  final int plan;
  final double price;
  final int onlineDataBackupDuration;
  final String planName;
  final String planDesc;
  final ItemsAuth itemsAuth;
  final SalesAuth salesAuth;
  final CustomerAuth customerAuth;
  final ExpensesAuth expensesAuth;
  final ReportAuth reportAuth;
  final EmployeesAuth employeesAuth;
  final CalculatorAuth calculatorAuth;
  final GeneralSettingsAuth generalSettingsAuth;
  final MultipleStoresAuth multipleStoresAuth;

  SubplanClass({
    required this.plan,
    required this.price,
    required this.onlineDataBackupDuration,
    required this.planName,
    required this.planDesc,
    required this.itemsAuth,
    required this.salesAuth,
    required this.customerAuth,
    required this.expensesAuth,
    required this.reportAuth,
    required this.employeesAuth,
    required this.calculatorAuth,
    required this.generalSettingsAuth,
    required this.multipleStoresAuth,
  });
}
