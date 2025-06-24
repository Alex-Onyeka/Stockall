import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:url_launcher/url_launcher.dart';

void openWhatsApp() async {
  final phone = '2347048507587'; // your number
  final message = Uri.encodeComponent(
    "Hello, Stockall Solutions; ",
  );
  final url = 'https://wa.me/$phone?text=$message';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    print('Could not launch $url');
  }
}

void phoneCall() async {
  final Uri uri = Uri(
    scheme: 'tel',
    path: '+2347048507587',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch +2347048507587';
  }
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
  );
  return emailRegex.hasMatch(email);
}

int getDayDifference(DateTime inputDate) {
  final today = DateTime.now();
  final todayDateOnly = DateTime(
    today.year,
    today.month,
    today.day,
  );
  final inputDateOnly = DateTime(
    inputDate.year,
    inputDate.month,
    inputDate.day,
  );
  return inputDateOnly.difference(todayDateOnly).inDays;
}

List<Map<String, dynamic>> employees = [
  {
    'position': 'Owner',
    'auths': [
      'Add Products',
      'Update Products',
      'Delete Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'View Daily Sales',
      'View Weekly Sales',
      'Make Refund',
      'Delete Sales',
      'Add Employee',
      'Update Employee',
      'Delete Employee',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
      'Manager Shop',
    ],
  },
  {
    'position': 'General Manager',
    'auths': [
      'Add Products',
      'Update Products',
      'Delete Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'View Daily Sales',
      'View Weekly Sales',
      'Make Refund',
      'Delete Sales',
      'Add Employee',
      'Update Employee',
      'Delete Employee',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
    ],
  },
  {
    'position': 'Manager',
    'auths': [
      'Add Products',
      'Update Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'View Daily Sales',
      'View Weekly Sales',
      'Make Refund',
      'Delete Sales',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
    ],
  },
  {
    'position': 'Asst. Manager',
    'auths': [
      'Add Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'View Daily Sales',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
    ],
  },
  {
    'position': 'Cashier',
    'auths': [
      'Add Customers',
      'Make Sale',
      'View Products',
      'View Daily Sales',
      'Add Expenses',
      'Update Expenses',
    ],
  },
];

class Authorizations {
  String addProduct = 'Add Products';
  String updateProduct = 'Update Products';
  String deleteProduct = 'Delete Products';
  String addCustomer = 'Add Customers';
  String updateCustomer = 'Update Customers';
  String deleteCustomer = 'Delete Customers';
  String makeSale = 'Make Sale';
  String deleteSale = 'Delete Sales';
  String makeRefund = 'Make Refund';
  String viewDailySale = 'View Daily Sales';
  String viewWeeklySales = 'View Weekly Sales';
  String addEmployee = 'Add Employee';
  String updateEmployee = 'Update Employees';
  String deleteEmployee = 'Delete Employees';
  String addExpense = 'Add Expenses';
  String updateExpenses = 'Update Expenses';
  String deleteExpenses = 'Delete Expenses';
  String manageShop = 'Manage Shop';
}

bool authorization({
  required String authorized,
  required BuildContext context,
}) {
  Map<String, dynamic> emp = employees.firstWhere(
    (emp) => emp['position'] == userGeneral(context).role,
  );
  if (emp['auths'].contains(authorized)) {
    return true;
  } else {
    return false;
  }
}
